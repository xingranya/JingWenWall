package com.oddfar.campus.business.errand.service.impl;

import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.errand.domain.dto.ErrandOrderDTO;
import com.oddfar.campus.business.errand.domain.entity.BusErrandOrderEntity;
import com.oddfar.campus.business.errand.domain.entity.BusErrandRunnerEntity;
import com.oddfar.campus.business.errand.domain.vo.ErrandOrderVO;
import com.oddfar.campus.business.errand.enums.ErrandType;
import com.oddfar.campus.business.errand.enums.OrderStatus;
import com.oddfar.campus.business.errand.enums.PayStatus;
import com.oddfar.campus.business.errand.mapper.ErrandOrderMapper;
import com.oddfar.campus.business.errand.mapper.ErrandRunnerMapper;
import com.oddfar.campus.business.errand.service.ErrandOrderService;
import com.oddfar.campus.business.mapper.BusStudentMapper;
import com.oddfar.campus.common.core.RedisCache;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * 跑腿订单服务实现
 */
@Slf4j
@Service
public class ErrandOrderServiceImpl extends ServiceImpl<ErrandOrderMapper, BusErrandOrderEntity>
        implements ErrandOrderService {

    /** 基础配送费 */
    @Value("${errand.base-fee:3.00}")
    private String baseFeeConfig;

    /** 平台抽成比例 */
    @Value("${errand.platform-rate:0.15}")
    private String platformRateConfig;

    @Autowired
    private ErrandOrderMapper errandOrderMapper;

    @Autowired
    private ErrandRunnerMapper runnerMapper;

    @Autowired
    private BusStudentMapper studentMapper;

    @Autowired
    private RedisCache redisCache;

    @Override
    public PageResult<ErrandOrderVO> getWaitingOrders(Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ErrandOrderVO> list = errandOrderMapper.selectWaitingOrders();
        fillOrderDesc(list);
        PageInfo<ErrandOrderVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    public ErrandOrderVO getOrderDetail(Long orderId) {
        ErrandOrderVO vo = errandOrderMapper.selectOrderDetail(orderId);
        if (vo == null) {
            throw new ServiceException("订单不存在");
        }
        fillOrderDesc(vo);
        
        // 填充当前用户标识
        if (SecurityUtils.isLogin()) {
            Long userId = SecurityUtils.getUserId();
            vo.setIsMine(userId.equals(vo.getPublisherId()));
            vo.setIsMyAccept(userId.equals(vo.getRunnerId()));
        }
        
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createOrder(ErrandOrderDTO orderDTO) {
        Long userId = SecurityUtils.getUserId();
        
        // 创建订单实体
        BusErrandOrderEntity entity = new BusErrandOrderEntity();
        BeanUtils.copyProperties(orderDTO, entity);
        
        // 生成订单号
        entity.setOrderNo(generateOrderNo());
        entity.setPublisherId(userId);
        
        // 计算费用
        BigDecimal baseFee = new BigDecimal(baseFeeConfig);
        BigDecimal tip = orderDTO.getTip() != null ? orderDTO.getTip() : BigDecimal.ZERO;
        BigDecimal totalFee = baseFee.add(tip);
        
        entity.setBaseFee(baseFee);
        entity.setTotalFee(totalFee);
        
        // 初始状态
        entity.setStatus(OrderStatus.WAITING.getCode());
        entity.setPayStatus(PayStatus.UNPAID.getCode());
        entity.setVersion(0);
        entity.setDelFlag(0);
        entity.setCreateTime(new Date());
        
        this.save(entity);
        
        log.info("订单创建成功, orderId: {}, orderNo: {}", entity.getOrderId(), entity.getOrderNo());
        return entity.getOrderId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void acceptOrder(Long orderId) {
        Long runnerId = SecurityUtils.getUserId();
        
        // 1. 检查是否是认证骑手
        BusErrandRunnerEntity runner = runnerMapper.selectByUserId(runnerId);
        if (runner == null || runner.getStatus() != 1) {
            throw new ServiceException("请先完成骑手认证");
        }
        
        // 2. Redis 分布式锁
        String lockKey = "lock:errand:order:" + orderId;
        boolean locked = false;
        
        try {
            locked = tryAcquireLock(lockKey, 10, TimeUnit.SECONDS);
            if (!locked) {
                throw new ServiceException("手慢了，订单正在被抢");
            }
            
            // 3. 查询订单
            BusErrandOrderEntity order = this.getById(orderId);
            if (order == null) {
                throw new ServiceException("订单不存在");
            }
            if (!OrderStatus.WAITING.getCode().equals(order.getStatus())) {
                throw new ServiceException("订单已被接单或已取消");
            }
            if (order.getPublisherId().equals(runnerId)) {
                throw new ServiceException("不能接自己发布的订单");
            }
            if (!PayStatus.PAID.getCode().equals(order.getPayStatus())) {
                throw new ServiceException("订单未支付");
            }
            
            // 4. 计算骑手佣金和平台抽成
            BigDecimal totalFee = order.getTotalFee();
            BigDecimal platformRate = new BigDecimal(platformRateConfig);
            BigDecimal platformFee = totalFee.multiply(platformRate).setScale(2, RoundingMode.HALF_UP);
            BigDecimal runnerFee = totalFee.subtract(platformFee);
            
            // 5. 更新订单
            order.setRunnerId(runnerId);
            order.setRunnerFee(runnerFee);
            order.setPlatformFee(platformFee);
            order.setStatus(OrderStatus.ACCEPTED.getCode());
            order.setUpdateTime(new Date());
            
            // 乐观锁更新
            int rows = errandOrderMapper.updateStatusWithVersion(
                    orderId, 
                    OrderStatus.WAITING.getCode(), 
                    OrderStatus.ACCEPTED.getCode(), 
                    order.getVersion()
            );
            
            if (rows == 0) {
                throw new ServiceException("抢单失败，请重试");
            }
            
            // 更新骑手信息
            order.setRunnerId(runnerId);
            order.setRunnerFee(runnerFee);
            order.setPlatformFee(platformFee);
            this.updateById(order);
            
            log.info("订单 {} 被骑手 {} 接单", orderId, runnerId);
            
        } finally {
            if (locked) {
                releaseLock(lockKey);
            }
        }
    }

    private boolean tryAcquireLock(String key, long timeout, TimeUnit unit) {
        Boolean result = redisCache.redisTemplate.opsForValue().setIfAbsent(key, "1", timeout, unit);
        return result != null && result;
    }

    private void releaseLock(String key) {
        redisCache.redisTemplate.delete(key);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateOrderStatus(Long orderId, Integer status) {
        Long userId = SecurityUtils.getUserId();
        
        BusErrandOrderEntity order = this.getById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        
        // 检查权限: 只有骑手可以更新状态
        if (!userId.equals(order.getRunnerId())) {
            throw new ServiceException("无权操作此订单");
        }
        
        // 状态流转校验
        OrderStatus currentStatus = OrderStatus.fromCode(order.getStatus());
        OrderStatus newStatus = OrderStatus.fromCode(status);
        
        if (!isValidStatusTransition(currentStatus, newStatus)) {
            throw new ServiceException("订单状态不允许此操作");
        }
        
        order.setStatus(status);
        order.setUpdateTime(new Date());
        this.updateById(order);
        
        log.info("订单 {} 状态更新: {} -> {}", orderId, currentStatus, newStatus);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelOrder(Long orderId, String reason) {
        Long userId = SecurityUtils.getUserId();
        
        BusErrandOrderEntity order = this.getById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        
        // 只有发布者可以取消订单
        if (!userId.equals(order.getPublisherId())) {
            throw new ServiceException("无权取消此订单");
        }
        
        // 只有待接单或已接单的订单可以取消
        if (order.getStatus() > OrderStatus.ACCEPTED.getCode()) {
            throw new ServiceException("订单已开始配送，无法取消");
        }
        
        order.setStatus(OrderStatus.CANCELLED.getCode());
        order.setCancelReason(reason);
        order.setUpdateTime(new Date());
        this.updateById(order);
        
        // TODO: 如果已支付，需要退款处理
        
        log.info("订单 {} 已取消, 原因: {}", orderId, reason);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void confirmComplete(Long orderId) {
        Long userId = SecurityUtils.getUserId();
        
        BusErrandOrderEntity order = this.getById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        
        // 只有发布者可以确认完成
        if (!userId.equals(order.getPublisherId())) {
            throw new ServiceException("无权操作此订单");
        }
        
        // 只有待确认的订单可以确认完成
        if (!OrderStatus.CONFIRMING.getCode().equals(order.getStatus())) {
            throw new ServiceException("订单状态不正确");
        }
        
        order.setStatus(OrderStatus.COMPLETED.getCode());
        order.setUpdateTime(new Date());
        this.updateById(order);
        
        // 更新骑手统计
        if (order.getRunnerId() != null && order.getRunnerFee() != null) {
            runnerMapper.updateRunnerStats(order.getRunnerId(), 1, order.getRunnerFee());
        }
        
        log.info("订单 {} 已完成", orderId);
    }

    @Override
    public PageResult<ErrandOrderVO> getMyPublishedOrders(Integer pageNum, Integer pageSize) {
        Long userId = SecurityUtils.getUserId();
        PageHelper.startPage(pageNum, pageSize);
        List<ErrandOrderVO> list = errandOrderMapper.selectPublishedOrders(userId);
        fillOrderDesc(list);
        PageInfo<ErrandOrderVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    public PageResult<ErrandOrderVO> getMyAcceptedOrders(Integer pageNum, Integer pageSize) {
        Long userId = SecurityUtils.getUserId();
        PageHelper.startPage(pageNum, pageSize);
        List<ErrandOrderVO> list = errandOrderMapper.selectAcceptedOrders(userId);
        fillOrderDesc(list);
        PageInfo<ErrandOrderVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void mockPaySuccess(Long orderId) {
        BusErrandOrderEntity order = this.getById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        
        order.setPayStatus(PayStatus.PAID.getCode());
        order.setPayTime(new Date());
        order.setPayOrderNo("MOCK_" + System.currentTimeMillis());
        order.setUpdateTime(new Date());
        this.updateById(order);
        
        log.info("订单 {} 模拟支付成功", orderId);
    }

    /**
     * 生成订单号
     */
    private String generateOrderNo() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String timestamp = sdf.format(new Date());
        String random = IdUtil.fastSimpleUUID().substring(0, 6).toUpperCase();
        return "ER" + timestamp + random;
    }

    /**
     * 填充订单描述信息
     */
    private void fillOrderDesc(List<ErrandOrderVO> list) {
        list.forEach(this::fillOrderDesc);
    }

    private void fillOrderDesc(ErrandOrderVO vo) {
        vo.setTypeDesc(ErrandType.getDescByCode(vo.getType()));
        vo.setStatusDesc(OrderStatus.getDescByCode(vo.getStatus()));
        vo.setPayStatusDesc(PayStatus.fromCode(vo.getPayStatus()) != null 
                ? PayStatus.fromCode(vo.getPayStatus()).getDesc() : "未知");
    }

    /**
     * 检查状态流转是否合法
     */
    private boolean isValidStatusTransition(OrderStatus current, OrderStatus next) {
        if (current == null || next == null) {
            return false;
        }
        
        switch (current) {
            case ACCEPTED:
                return next == OrderStatus.PICKING;
            case PICKING:
                return next == OrderStatus.DELIVERING;
            case DELIVERING:
                return next == OrderStatus.CONFIRMING;
            default:
                return false;
        }
    }

    // ==================== 管理后台方法 ====================

    @Override
    public PageResult<ErrandOrderVO> getAdminOrderList(Integer status, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ErrandOrderVO> list = errandOrderMapper.selectAdminOrderList(status);
        fillOrderDesc(list);
        PageInfo<ErrandOrderVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void adminCancelOrder(Long orderId, String reason) {
        BusErrandOrderEntity order = this.getById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        
        // 管理员可以取消任何未完成的订单
        if (order.getStatus() >= OrderStatus.COMPLETED.getCode()) {
            throw new ServiceException("订单已完成，无法取消");
        }
        
        order.setStatus(OrderStatus.CANCELLED.getCode());
        order.setCancelReason("管理员取消: " + (reason != null ? reason : ""));
        order.setUpdateTime(new Date());
        this.updateById(order);
        
        log.info("管理员取消订单 {}, 原因: {}", orderId, reason);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteOrder(Long orderId) {
        BusErrandOrderEntity order = this.getById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        
        // 逻辑删除
        order.setDelFlag(1);
        order.setUpdateTime(new Date());
        this.updateById(order);
        
        log.info("订单 {} 已删除", orderId);
    }
}
