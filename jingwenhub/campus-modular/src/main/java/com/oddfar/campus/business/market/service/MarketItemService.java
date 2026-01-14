package com.oddfar.campus.business.market.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oddfar.campus.business.market.domain.dto.MarketItemDTO;
import com.oddfar.campus.business.market.domain.entity.BusMarketItemEntity;
import com.oddfar.campus.business.market.domain.vo.MarketItemVO;
import com.oddfar.campus.common.domain.PageResult;

/**
 * 二手交易服务接口
 */
public interface MarketItemService extends IService<BusMarketItemEntity> {

    /**
     * 获取商品列表
     * @param categoryId 分类ID
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<MarketItemVO> getItemList(Long categoryId, Integer pageNum, Integer pageSize);

    /**
     * 获取商品详情
     * @param itemId 商品ID
     * @return 商品详情
     */
    MarketItemVO getItemDetail(Long itemId);

    /**
     * 发布商品
     * @param itemDTO 商品信息
     * @return 商品ID
     */
    Long publishItem(MarketItemDTO itemDTO);

    /**
     * 更新商品
     * @param itemDTO 商品信息
     */
    void updateItem(MarketItemDTO itemDTO);

    /**
     * 删除商品
     * @param itemId 商品ID
     */
    void deleteItem(Long itemId);

    /**
     * 标记为已售
     * @param itemId 商品ID
     */
    void markSold(Long itemId);

    /**
     * 下架商品
     * @param itemId 商品ID
     */
    void offShelf(Long itemId);

    /**
     * 收藏商品
     * @param itemId 商品ID
     */
    void collectItem(Long itemId);

    /**
     * 取消收藏
     * @param itemId 商品ID
     */
    void uncollectItem(Long itemId);

    /**
     * 获取我发布的商品
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<MarketItemVO> getMyItems(Integer pageNum, Integer pageSize);

    /**
     * 获取我收藏的商品
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<MarketItemVO> getMyCollects(Integer pageNum, Integer pageSize);

    /**
     * 搜索商品
     * @param keyword 关键词
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<MarketItemVO> searchItems(String keyword, Integer pageNum, Integer pageSize);

    // ==================== 管理后台方法 ====================

    /**
     * 获取管理后台商品列表
     * @param status 状态筛选
     * @param categoryId 分类ID
     * @param keyword 关键词
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<MarketItemVO> getAdminItemList(Integer status, Long categoryId, String keyword, Integer pageNum, Integer pageSize);

    /**
     * 管理员下架商品
     * @param itemId 商品ID
     * @param reason 下架原因
     */
    void adminOffShelf(Long itemId, String reason);

    /**
     * 管理员恢复上架
     * @param itemId 商品ID
     */
    void adminOnShelf(Long itemId);

    /**
     * 管理员删除商品
     * @param itemId 商品ID
     */
    void adminDeleteItem(Long itemId);

    /**
     * 获取总商品数
     * @return 数量
     */
    Long getTotalCount();

    /**
     * 根据状态获取商品数
     * @param status 状态
     * @return 数量
     */
    Long getCountByStatus(Integer status);
}
