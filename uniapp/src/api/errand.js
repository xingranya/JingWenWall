import { baseUrl } from "@/utils/env";
import { handlePageResult } from "@/utils/api-helper";

/**
 * 获取待接单列表
 */
export const getWaitingOrders = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/waiting?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取订单详情
 */
export const getOrderDetail = (orderId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/${orderId}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject(res.data.msg || '获取失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 创建订单
 */
export const createOrder = (data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: data,
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '创建失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 接单/抢单
 */
export const acceptOrder = (orderId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/${orderId}/accept`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '接单失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 更新订单状态
 * @param {Number} orderId 订单ID
 * @param {Number} status 新状态: 2取件中 3配送中 4待确认
 */
export const updateOrderStatus = (orderId, status) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/${orderId}/status?status=${status}`,
            method: 'PUT',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '更新失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 取消订单
 */
export const cancelOrder = (orderId, reason = '') => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/${orderId}/cancel?reason=${encodeURIComponent(reason)}`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '取消失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 确认完成订单
 */
export const confirmComplete = (orderId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/${orderId}/confirm`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '确认失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取我发布的订单
 */
export const getMyPublishedOrders = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/published?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取我接的订单 (骑手)
 */
export const getMyAcceptedOrders = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/accepted?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 模拟支付成功 (测试用)
 */
export const mockPaySuccess = (orderId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/orders/${orderId}/mock-pay`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '支付失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

// ==================== 骑手相关 ====================

/**
 * 申请成为骑手
 */
export const applyRunner = (data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/runner/apply`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: data,
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '申请失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取我的骑手信息
 */
export const getMyRunnerInfo = () => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/runner/mine`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject(res.data.msg || '获取失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 检查是否是骑手
 */
export const checkIsRunner = () => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/errand/runner/check`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    // R.ok().put("isRunner", isRunner) 返回格式: {code, msg, isRunner}
                    resolve(res.data.isRunner || false);
                } else {
                    resolve(false);
                }
            },
            fail: () => resolve(false)
        });
    });
};

// 兼容旧接口名称
export const publishErrand = createOrder;
export const getErrandList = getWaitingOrders;
