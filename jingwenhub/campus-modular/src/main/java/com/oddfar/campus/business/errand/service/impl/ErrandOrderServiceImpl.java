package com.oddfar.campus.business.errand.service.impl;

import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.errand.domain.dto.ErrandOrderDTO;
import com.oddfar.campus.business.errand.domain.entity.BusErrandOrderEntity;
import com.oddfar.campus.business.errand.domain.entity.BusErrandRunnerEntity;
import com.oddfar.campus.business.errand.domain.vo.ErrandOrderVO;
import com.oddfar.campus.business.errand.domain.enums.OrderStatus;
import com.oddfar.campus.business.errand.enums.ErrandType;
import com.oddfar.campus.business.errand.enums.PayStatus;
import com.oddfar.campus.business.errand.mapper.ErrandOrderMapper;
import com.oddfar.campus.business.errand.mapper.ErrandRunnerMapper;
import com.oddfar.campus.business.errand.service.ErrandOrderService;
import com.oddfar.campus.business.service.BusStudentService;
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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * 跑腿订单服务实现
 */
@Slf4j
@Service
@SuppressWarnings("null")
public class ErrandOrderServiceImpl extends ServiceImpl<ErrandOrderMapper, BusErrandOrderEntity>
        implements ErrandOrderService {

    /** 基础配送费 */
    @Value("${errand.base-fee:3.00}")
    private String baseFeeConfig;

    /** 平台抽成比例 */
    @Value("${errand.platform-rate:0.15}")
    private String platformRateConfig;

    /** 小费最大值 */
    private static final BigDecimal MAX_TIP = new BigDecimal("100.00");

    /** 小费最小值 */
    private static final BigDecimal MIN_TIP = new BigDecimal("0.00");

    @Autowired
    private ErrandOrderMapper errandOrderMapper;

    @Autowired
    private ErrandRunnerMapper runnerMapper;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private BusStudentService studentService;

    /** 订单号格式化器 */
    private static final DateTimeFormatter ORDER_NO_FORMATTER =
            DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

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

        // 校验小费金额（防止金额篡改）
        BigDecimal tip = orderDTO.getTip() != null ? orderDTO.getTip() : BigDecimal.ZERO;
        if (tip.compareTo(MIN_TIP) < 0 || tip.compareTo(MAX_TIP) > 0) {
            throw new ServiceException("小费金额必须在" + MIN_TIP + "到" + MAX_TIP + "之间");
        }

        // 计算费用（后端重新计算，不直接使用前端传来的值）
        BigDecimal baseFee = new BigDecimal(baseFeeConfig);
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

            // 5. ✅ 修复: 使用 updateById 一次更新所有字段 (MyBatis-Plus 自动使用 @Version 乐观锁)
            order.setRunnerId(runnerId);
            order.setRunnerFee(runnerFee);
            order.setPlatformFee(platformFee);
            order.setStatus(OrderStatus.ACCEPTED.getCode());
            order.setUpdateTime(new Date());

            // ✅ updateById 会自动使用 @Version 注解进行乐观锁控制
            boolean success = this.updateById(order);

            if (!success) {
                throw new ServiceException("抢单失败,订单已被接单");
            }

            log.info("订单 {} 被骑手 {} 接单, 佣金: {}, 平台抽成: {}", orderId, runnerId, runnerFee, platformFee);
            
        } finally {
            if (locked) {
                releaseLock(lockKey);
            }
        }
    }

    private boolean tryAcquireLock(String key, long timeout, TimeUnit unit) {
        return redisCache.tryLock(key, timeout, unit);
    }

    private void releaseLock(String key) {
        redisCache.unlock(key);
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

        // 状态流转校验 (使用枚举内置的状态机)
        OrderStatus currentStatus = OrderStatus.fromCode(order.getStatus());
        OrderStatus newStatus = OrderStatus.fromCode(status);

        // 使用状态机检查转换是否合法
        if (!currentStatus.canTransitionTo(newStatus)) {
            throw new ServiceException(
                    String.format("订单状态不允许此操作: %s -> %s",
                            currentStatus.getDesc(), newStatus.getDesc()));
        }

        order.setStatus(status);
        order.setUpdateTime(new Date());
        this.updateById(order);

        log.info("订单 {} 状态更新: {} -> {}, 操作用户: {}", orderId, currentStatus.getDesc(), newStatus.getDesc(), userId);
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

        // 使用状态机检查是否可取消
        OrderStatus currentStatus = OrderStatus.fromCode(order.getStatus());
        if (!currentStatus.isCancellable()) {
            throw new ServiceException("订单当前状态无法取消: " + currentStatus.getDesc());
        }

        // 新增: 已支付订单需要退款
        if (order.getPayStatus() != null && order.getPayStatus().equals(PayStatus.PAID.getCode())) {
            // 退款到余额
            BusStudentEntity student = studentService.getByUserId(order.getPublisherId());
            if (student != null) {
                BigDecimal refundAmount = order.getTotalFee();
                studentService.updateBalance(student.getStudentId(), refundAmount);

                log.info("订单取消退款: orderId={}, publisherId={}, refundAmount={}",
                        orderId, order.getPublisherId(), refundAmount);
            }
        }

        order.setStatus(OrderStatus.CANCELLED.getCode());
        order.setCancelReason(reason);
        order.setUpdateTime(new Date());
        this.updateById(order);

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
        String timestamp = LocalDateTime.now().format(ORDER_NO_FORMATTER);
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

        // 使用状态机检查是否可取消
        OrderStatus currentStatus = OrderStatus.fromCode(order.getStatus());
        if (currentStatus.isTerminalState()) {
            throw new ServiceException("订单已完成或已取消，无法再次取消");
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
