import { get, post, put } from "@/utils/request";
import { canTransition, OrderStatusNames, showTransitionErrorToast } from "@/utils/order-status.js";

/**
 * 获取待接单列表
 */
export const getWaitingOrders = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/errand/orders/waiting', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 获取订单详情
 */
export const getOrderDetail = (orderId) => {
    return get(`/api/v1/errand/orders/${orderId}`)
        .then(response => response.data);
};

/**
 * 创建订单
 */
export const createOrder = (data) => {
    return post('/api/v1/errand/orders', data);
};

/**
 * 接单/抢单
 */
export const acceptOrder = (orderId) => {
    return post(`/api/v1/errand/orders/${orderId}/accept`);
};

/**
 * 更新订单状态
 * @param {Number} orderId 订单ID
 * @param {Number} status 新状态: 2取件中 3配送中 4待确认
 * @param {Number} currentStatus 当前状态（可选，用于前端验证）
 * @returns {Promise}
 */
export const updateOrderStatus = (orderId, status, currentStatus = null) => {
    // 前端验证：如果提供了当前状态，检查状态转换是否合法
    if (currentStatus !== null) {
        if (!canTransition(currentStatus, status)) {
            // 显示错误提示
            showTransitionErrorToast(currentStatus, status);

            // 返回已拒绝的Promise
            return Promise.reject({
                msg: `不能从${OrderStatusNames[currentStatus]}转换为${OrderStatusNames[status]}`,
                code: 400
            });
        }
    }

    return put(`/api/v1/errand/orders/${orderId}/status`, null, { status });
};

/**
 * 取消订单
 */
export const cancelOrder = (orderId, reason = '') => {
    return post(`/api/v1/errand/orders/${orderId}/cancel`, { reason: encodeURIComponent(reason) });
};

/**
 * 确认完成订单
 */
export const confirmComplete = (orderId) => {
    return post(`/api/v1/errand/orders/${orderId}/confirm`);
};

/**
 * 获取我发布的订单
 */
export const getMyPublishedOrders = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/errand/orders/published', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 获取我接的订单 (骑手)
 */
export const getMyAcceptedOrders = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/errand/orders/accepted', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 模拟支付成功 (测试用)
 */
export const mockPaySuccess = (orderId) => {
    return post(`/api/v1/errand/orders/${orderId}/mock-pay`);
};

// ==================== 骑手相关 ====================

/**
 * 申请成为骑手
 */
export const applyRunner = (data) => {
    return post('/api/v1/errand/runner/apply', data);
};

/**
 * 获取我的骑手信息
 */
export const getMyRunnerInfo = () => {
    return get('/api/v1/errand/runner/mine')
        .then(response => response.data);
};

/**
 * 检查是否是骑手
 */
export const checkIsRunner = () => {
    return get('/api/v1/errand/runner/check')
        .then(response => response.isRunner || false);
};

// 兼容旧接口名称
export const publishErrand = createOrder;
export const getErrandList = getWaitingOrders;
