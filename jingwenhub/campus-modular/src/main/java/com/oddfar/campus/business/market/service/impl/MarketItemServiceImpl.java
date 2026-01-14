package com.oddfar.campus.business.market.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.market.domain.dto.MarketItemDTO;
import com.oddfar.campus.business.market.domain.entity.BusMarketCollectEntity;
import com.oddfar.campus.business.market.domain.entity.BusMarketItemEntity;
import com.oddfar.campus.business.market.domain.vo.MarketItemVO;
import com.oddfar.campus.business.market.enums.MarketItemStatus;
import com.oddfar.campus.business.market.mapper.MarketCollectMapper;
import com.oddfar.campus.business.market.mapper.MarketItemMapper;
import com.oddfar.campus.business.market.service.MarketItemService;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 二手交易服务实现
 */
@Slf4j
@Service
public class MarketItemServiceImpl extends ServiceImpl<MarketItemMapper, BusMarketItemEntity>
        implements MarketItemService {

    @Autowired
    private MarketItemMapper itemMapper;

    @Autowired
    private MarketCollectMapper collectMapper;

    @Override
    public PageResult<MarketItemVO> getItemList(Long categoryId, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<MarketItemVO> list = itemMapper.selectItemList(categoryId);
        fillItemDesc(list);
        fillUserCollectStatus(list);
        PageInfo<MarketItemVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    public MarketItemVO getItemDetail(Long itemId) {
        // 更新浏览次数
        itemMapper.updateViewCount(itemId);
        
        MarketItemVO vo = itemMapper.selectItemDetail(itemId);
        if (vo == null) {
            throw new ServiceException("商品不存在");
        }
        
        fillItemDesc(vo);
        
        // 填充当前用户标识
        if (SecurityUtils.isLogin()) {
            Long userId = SecurityUtils.getUserId();
            vo.setIsMine(userId.equals(vo.getUserId()));
            vo.setIsCollected(checkUserCollect(userId, itemId));
        }
        
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long publishItem(MarketItemDTO itemDTO) {
        Long userId = SecurityUtils.getUserId();
        
        BusMarketItemEntity entity = new BusMarketItemEntity();
        BeanUtils.copyProperties(itemDTO, entity);
        entity.setUserId(userId);
        entity.setStatus(MarketItemStatus.PENDING.getCode());
        entity.setViewCount(0);
        entity.setCollectCount(0);
        entity.setDelFlag(0);
        entity.setCreateTime(new Date());
        
        // 默认设置
        if (entity.getConditionLevel() == null) {
            entity.setConditionLevel(9);
        }
        if (entity.getTradeMethod() == null) {
            entity.setTradeMethod(0);
        }
        
        this.save(entity);
        
        log.info("商品发布成功, itemId: {}", entity.getItemId());
        return entity.getItemId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateItem(MarketItemDTO itemDTO) {
        Long userId = SecurityUtils.getUserId();
        
        BusMarketItemEntity entity = this.getById(itemDTO.getItemId());
        if (entity == null) {
            throw new ServiceException("商品不存在");
        }
        if (!entity.getUserId().equals(userId)) {
            throw new ServiceException("无权修改此商品");
        }
        
        BeanUtils.copyProperties(itemDTO, entity);
        entity.setUpdateTime(new Date());
        this.updateById(entity);
        
        log.info("商品更新成功, itemId: {}", entity.getItemId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteItem(Long itemId) {
        Long userId = SecurityUtils.getUserId();
        
        BusMarketItemEntity entity = this.getById(itemId);
        if (entity == null) {
            throw new ServiceException("商品不存在");
        }
        if (!entity.getUserId().equals(userId)) {
            throw new ServiceException("无权删除此商品");
        }
        
        entity.setDelFlag(1);
        this.updateById(entity);
        
        log.info("商品删除成功, itemId: {}", itemId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void markSold(Long itemId) {
        Long userId = SecurityUtils.getUserId();
        
        BusMarketItemEntity entity = this.getById(itemId);
        if (entity == null) {
            throw new ServiceException("商品不存在");
        }
        if (!entity.getUserId().equals(userId)) {
            throw new ServiceException("无权操作此商品");
        }
        
        entity.setStatus(MarketItemStatus.SOLD.getCode());
        entity.setUpdateTime(new Date());
        this.updateById(entity);
        
        log.info("商品已标记为已售, itemId: {}", itemId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void offShelf(Long itemId) {
        Long userId = SecurityUtils.getUserId();
        
        BusMarketItemEntity entity = this.getById(itemId);
        if (entity == null) {
            throw new ServiceException("商品不存在");
        }
        if (!entity.getUserId().equals(userId)) {
            throw new ServiceException("无权操作此商品");
        }
        
        entity.setStatus(MarketItemStatus.OFF_SHELF.getCode());
        entity.setUpdateTime(new Date());
        this.updateById(entity);
        
        log.info("商品已下架, itemId: {}", itemId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void collectItem(Long itemId) {
        Long userId = SecurityUtils.getUserId();
        
        // 检查商品是否存在
        BusMarketItemEntity item = this.getById(itemId);
        if (item == null) {
            throw new ServiceException("商品不存在");
        }
        
        // 查询物理记录
        BusMarketCollectEntity existCollect = collectMapper.selectOnePhysical(userId, itemId);
        
        if (existCollect != null) {
            if (existCollect.getDelFlag() == 0) {
                throw new ServiceException("已经收藏过了");
            } else {
                // 恢复收藏
                collectMapper.updateDelFlag(userId, itemId, 0);
            }
        } else {
            // 新增收藏
            BusMarketCollectEntity collectEntity = new BusMarketCollectEntity();
            collectEntity.setUserId(userId);
            collectEntity.setItemId(itemId);
            collectEntity.setDelFlag(0);
            collectEntity.setCreateTime(new Date());
            collectMapper.insert(collectEntity);
        }
        
        // 更新商品收藏数
        item.setCollectCount(item.getCollectCount() + 1);
        this.updateById(item);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void uncollectItem(Long itemId) {
        Long userId = SecurityUtils.getUserId();
        
        int rows = collectMapper.updateDelFlag(userId, itemId, 1);
        if (rows > 0) {
            // 更新商品收藏数
            BusMarketItemEntity item = this.getById(itemId);
            if (item != null && item.getCollectCount() > 0) {
                item.setCollectCount(item.getCollectCount() - 1);
                this.updateById(item);
            }
        }
    }

    @Override
    public PageResult<MarketItemVO> getMyItems(Integer pageNum, Integer pageSize) {
        Long userId = SecurityUtils.getUserId();
        PageHelper.startPage(pageNum, pageSize);
        List<MarketItemVO> list = itemMapper.selectItemsByUserId(userId);
        fillItemDesc(list);
        PageInfo<MarketItemVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    public PageResult<MarketItemVO> getMyCollects(Integer pageNum, Integer pageSize) {
        Long userId = SecurityUtils.getUserId();
        
        List<Long> itemIds = collectMapper.selectCollectedItemIds(userId);
        if (itemIds.isEmpty()) {
            return new PageResult<>(new ArrayList<>(), 0L);
        }
        
        PageHelper.startPage(pageNum, pageSize);
        List<MarketItemVO> list = itemIds.stream()
                .map(itemMapper::selectItemDetail)
                .filter(vo -> vo != null)
                .collect(Collectors.toList());
        fillItemDesc(list);
        
        PageInfo<MarketItemVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    public PageResult<MarketItemVO> searchItems(String keyword, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<MarketItemVO> list = itemMapper.searchItems(keyword);
        fillItemDesc(list);
        fillUserCollectStatus(list);
        PageInfo<MarketItemVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    /**
     * 填充商品描述信息
     */
    private void fillItemDesc(List<MarketItemVO> list) {
        list.forEach(this::fillItemDesc);
    }

    private void fillItemDesc(MarketItemVO vo) {
        vo.setStatusDesc(MarketItemStatus.getDescByCode(vo.getStatus()));
        vo.setConditionDesc(vo.getConditionLevel() + "成新");
        
        switch (vo.getTradeMethod()) {
            case 0:
                vo.setTradeMethodDesc("自提");
                break;
            case 1:
                vo.setTradeMethodDesc("邮寄");
                break;
            case 2:
                vo.setTradeMethodDesc("自提/邮寄");
                break;
            default:
                vo.setTradeMethodDesc("面议");
        }
    }

    /**
     * 填充用户收藏状态
     */
    private void fillUserCollectStatus(List<MarketItemVO> list) {
        if (list.isEmpty() || !SecurityUtils.isLogin()) {
            return;
        }
        
        Long userId = SecurityUtils.getUserId();
        List<Long> collectedIds = collectMapper.selectCollectedItemIds(userId);
        
        list.forEach(vo -> vo.setIsCollected(collectedIds.contains(vo.getItemId())));
    }

    /**
     * 检查用户是否收藏了商品
     */
    private boolean checkUserCollect(Long userId, Long itemId) {
        List<Long> collectedIds = collectMapper.selectCollectedItemIds(userId);
        return collectedIds.contains(itemId);
    }

    // ==================== 管理后台方法 ====================

    @Override
    public PageResult<MarketItemVO> getAdminItemList(Integer status, Long categoryId, String keyword, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<MarketItemVO> list = itemMapper.selectAdminItemList(status, categoryId, keyword);
        fillItemDesc(list);
        PageInfo<MarketItemVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void adminOffShelf(Long itemId, String reason) {
        BusMarketItemEntity entity = this.getById(itemId);
        if (entity == null) {
            throw new ServiceException("商品不存在");
        }
        
        entity.setStatus(MarketItemStatus.OFF_SHELF.getCode());
        entity.setUpdateTime(new Date());
        this.updateById(entity);
        
        log.info("管理员下架商品 {}, 原因: {}", itemId, reason);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void adminOnShelf(Long itemId) {
        BusMarketItemEntity entity = this.getById(itemId);
        if (entity == null) {
            throw new ServiceException("商品不存在");
        }
        
        entity.setStatus(MarketItemStatus.ON_SALE.getCode());
        entity.setUpdateTime(new Date());
        this.updateById(entity);
        
        log.info("管理员恢复上架商品 {}", itemId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void adminDeleteItem(Long itemId) {
        BusMarketItemEntity entity = this.getById(itemId);
        if (entity == null) {
            throw new ServiceException("商品不存在");
        }
        
        entity.setDelFlag(1);
        entity.setUpdateTime(new Date());
        this.updateById(entity);
        
        log.info("管理员删除商品 {}", itemId);
    }

    @Override
    public Long getTotalCount() {
        return itemMapper.countTotal();
    }

    @Override
    public Long getCountByStatus(Integer status) {
        return itemMapper.countByStatus(status);
    }
}
