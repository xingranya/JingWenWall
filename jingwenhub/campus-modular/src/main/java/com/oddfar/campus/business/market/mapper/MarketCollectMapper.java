package com.oddfar.campus.business.market.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oddfar.campus.business.market.domain.entity.BusMarketCollectEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 商品收藏Mapper
 */
@Mapper
public interface MarketCollectMapper extends BaseMapper<BusMarketCollectEntity> {

    /**
     * 查询用户收藏的商品ID列表
     * @param userId 用户ID
     * @return 商品ID列表
     */
    List<Long> selectCollectedItemIds(@Param("userId") Long userId);

    /**
     * 查询物理记录(忽略逻辑删除)
     * @param userId 用户ID
     * @param itemId 商品ID
     * @return 收藏实体
     */
    BusMarketCollectEntity selectOnePhysical(@Param("userId") Long userId, @Param("itemId") Long itemId);

    /**
     * 更新删除标志
     * @param userId 用户ID
     * @param itemId 商品ID
     * @param delFlag 删除标志
     * @return 影响行数
     */
    int updateDelFlag(@Param("userId") Long userId, @Param("itemId") Long itemId, @Param("delFlag") Integer delFlag);
}
