package com.oddfar.campus.business.market.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oddfar.campus.business.market.domain.entity.BusMarketItemEntity;
import com.oddfar.campus.business.market.domain.vo.MarketItemVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 二手商品Mapper
 */
@Mapper
public interface MarketItemMapper extends BaseMapper<BusMarketItemEntity> {

    /**
     * 查询商品列表
     * @param categoryId 分类ID
     * @return 商品列表
     */
    List<MarketItemVO> selectItemList(@Param("categoryId") Long categoryId);

    /**
     * 查询商品详情
     * @param itemId 商品ID
     * @return 商品详情
     */
    MarketItemVO selectItemDetail(@Param("itemId") Long itemId);

    /**
     * 查询用户发布的商品
     * @param userId 用户ID
     * @return 商品列表
     */
    List<MarketItemVO> selectItemsByUserId(@Param("userId") Long userId);

    /**
     * 搜索商品
     * @param keyword 关键词
     * @return 商品列表
     */
    List<MarketItemVO> searchItems(@Param("keyword") String keyword);

    /**
     * 更新浏览次数
     * @param itemId 商品ID
     * @return 影响行数
     */
    int updateViewCount(@Param("itemId") Long itemId);

    // ==================== 管理后台方法 ====================

    /**
     * 管理后台-查询商品列表
     * @param status 状态筛选
     * @param categoryId 分类ID
     * @param keyword 关键词
     * @return 商品列表
     */
    List<MarketItemVO> selectAdminItemList(@Param("status") Integer status, 
                                           @Param("categoryId") Long categoryId,
                                           @Param("keyword") String keyword);

    /**
     * 统计总商品数
     * @return 数量
     */
    Long countTotal();

    /**
     * 按状态统计商品数
     * @param status 状态
     * @return 数量
     */
    Long countByStatus(@Param("status") Integer status);
}
