package com.oddfar.campus.business.errand.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oddfar.campus.business.errand.domain.entity.BusErrandOrderEntity;
import com.oddfar.campus.business.errand.domain.vo.ErrandOrderVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 跑腿订单Mapper
 */
@Mapper
public interface ErrandOrderMapper extends BaseMapper<BusErrandOrderEntity> {

    /**
     * 查询待接单列表
     * @return 订单列表
     */
    List<ErrandOrderVO> selectWaitingOrders();

    /**
     * 查询订单详情
     * @param orderId 订单ID
     * @return 订单详情
     */
    ErrandOrderVO selectOrderDetail(@Param("orderId") Long orderId);

    /**
     * 查询用户发布的订单
     * @param userId 用户ID
     * @return 订单列表
     */
    List<ErrandOrderVO> selectPublishedOrders(@Param("userId") Long userId);

    /**
     * 查询骑手接的订单
     * @param runnerId 骑手ID
     * @return 订单列表
     */
    List<ErrandOrderVO> selectAcceptedOrders(@Param("runnerId") Long runnerId);

    /**
     * 根据订单号查询订单
     * @param orderNo 订单号
     * @return 订单实体
     */
    BusErrandOrderEntity selectByOrderNo(@Param("orderNo") String orderNo);

    /**
     * 乐观锁更新订单状态
     * @param orderId 订单ID
     * @param oldStatus 原状态
     * @param newStatus 新状态
     * @param version 版本号
     * @return 影响行数
     */
    int updateStatusWithVersion(@Param("orderId") Long orderId, 
                                @Param("oldStatus") Integer oldStatus,
                                @Param("newStatus") Integer newStatus,
                                @Param("version") Integer version);

    // ==================== 管理后台方法 ====================

    /**
     * 管理后台-查询订单列表
     * @param status 状态筛选
     * @return 订单列表
     */
    List<ErrandOrderVO> selectAdminOrderList(@Param("status") Integer status);
}
