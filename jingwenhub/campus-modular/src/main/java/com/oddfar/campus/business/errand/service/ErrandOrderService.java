package com.oddfar.campus.business.errand.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oddfar.campus.business.errand.domain.dto.ErrandOrderDTO;
import com.oddfar.campus.business.errand.domain.entity.BusErrandOrderEntity;
import com.oddfar.campus.business.errand.domain.vo.ErrandOrderVO;
import com.oddfar.campus.common.domain.PageResult;

/**
 * 跑腿订单服务接口
 */
public interface ErrandOrderService extends IService<BusErrandOrderEntity> {

    /**
     * 获取待接单列表
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ErrandOrderVO> getWaitingOrders(Integer pageNum, Integer pageSize);

    /**
     * 获取订单详情
     * @param orderId 订单ID
     * @return 订单详情
     */
    ErrandOrderVO getOrderDetail(Long orderId);

    /**
     * 创建订单
     * @param orderDTO 订单信息
     * @return 订单ID
     */
    Long createOrder(ErrandOrderDTO orderDTO);

    /**
     * 抢单/接单
     * @param orderId 订单ID
     */
    void acceptOrder(Long orderId);

    /**
     * 更新订单状态
     * @param orderId 订单ID
     * @param status 新状态
     */
    void updateOrderStatus(Long orderId, Integer status);

    /**
     * 取消订单
     * @param orderId 订单ID
     * @param reason 取消原因
     */
    void cancelOrder(Long orderId, String reason);

    /**
     * 确认完成
     * @param orderId 订单ID
     */
    void confirmComplete(Long orderId);

    /**
     * 获取我发布的订单
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ErrandOrderVO> getMyPublishedOrders(Integer pageNum, Integer pageSize);

    /**
     * 获取我接的订单 (骑手)
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ErrandOrderVO> getMyAcceptedOrders(Integer pageNum, Integer pageSize);

    /**
     * 模拟支付成功 (测试用)
     * @param orderId 订单ID
     */
    void mockPaySuccess(Long orderId);

    // ==================== 管理后台方法 ====================

    /**
     * 获取管理后台订单列表
     * @param status 状态筛选
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ErrandOrderVO> getAdminOrderList(Integer status, Integer pageNum, Integer pageSize);

    /**
     * 管理员取消订单
     * @param orderId 订单ID
     * @param reason 取消原因
     */
    void adminCancelOrder(Long orderId, String reason);

    /**
     * 删除订单
     * @param orderId 订单ID
     */
    void deleteOrder(Long orderId);
}
