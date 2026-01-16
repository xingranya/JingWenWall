/**
 * 订单状态工具类
 * 用于验证跑腿订单状态转换是否合法
 *
 * 对应后端 OrderStatus 枚举:
 * 1: 待接单 (PENDING)
 * 2: 取件中 (PICKING_UP)
 * 3: 配送中 (DELIVERING)
 * 4: 待确认 (PENDING_CONFIRMATION)
 * 5: 已完成 (COMPLETED)
 * 6: 已取消 (CANCELLED)
 * 7: 已支付 (PAID)
 */

/**
 * 订单状态枚举
 */
export const OrderStatus = {
    PENDING: 1,              // 待接单
    PICKING_UP: 2,           // 取件中
    DELIVERING: 3,           // 配送中
    PENDING_CONFIRMATION: 4, // 待确认
    COMPLETED: 5,            // 已完成
    CANCELLED: 6,            // 已取消
    PAID: 7                  // 已支付
};

/**
 * 订单状态名称映射（中文）
 */
export const OrderStatusNames = {
    [OrderStatus.PENDING]: '待接单',
    [OrderStatus.PICKING_UP]: '取件中',
    [OrderStatus.DELIVERING]: '配送中',
    [OrderStatus.PENDING_CONFIRMATION]: '待确认',
    [OrderStatus.COMPLETED]: '已完成',
    [OrderStatus.CANCELLED]: '已取消',
    [OrderStatus.PAID]: '已支付'
};

/**
 * 允许的状态转换规则
 * key: 当前状态
 * value: 允许转换到的状态数组
 */
const ALLOWED_TRANSITIONS = {
    // 待接单 -> 取件中、已取消
    [OrderStatus.PENDING]: [OrderStatus.PICKING_UP, OrderStatus.CANCELLED],

    // 取件中 -> 配送中、已取消
    [OrderStatus.PICKING_UP]: [OrderStatus.DELIVERING, OrderStatus.CANCELLED],

    // 配送中 -> 待确认、已取消
    [OrderStatus.DELIVERING]: [OrderStatus.PENDING_CONFIRMATION, OrderStatus.CANCELLED],

    // 待确认 -> 已完成
    [OrderStatus.PENDING_CONFIRMATION]: [OrderStatus.COMPLETED],

    // 已完成 -> 终态（不能再转换）
    [OrderStatus.COMPLETED]: [],

    // 已取消 -> 终态（不能再转换）
    [OrderStatus.CANCELLED]: [],

    // 已支付 -> 待接单、已取消
    [OrderStatus.PAID]: [OrderStatus.PENDING, OrderStatus.CANCELLED]
};

/**
 * 验证状态转换是否合法
 * @param {number} fromStatus - 当前状态
 * @param {number} toStatus - 目标状态
 * @returns {boolean} 是否允许转换
 */
export function canTransition(fromStatus, toStatus) {
    const allowed = ALLOWED_TRANSITIONS[fromStatus] || [];
    return allowed.includes(toStatus);
}

/**
 * 获取状态转换错误信息
 * @param {number} fromStatus - 当前状态
 * @param {number} toStatus - 目标状态
 * @returns {string|null} 错误信息，如果允许转换则返回null
 */
export function getTransitionError(fromStatus, toStatus) {
    // 如果状态相同
    if (fromStatus === toStatus) {
        return `订单已经是${OrderStatusNames[toStatus]}状态`;
    }

    // 如果不允许转换
    if (!canTransition(fromStatus, toStatus)) {
        return `不能从${OrderStatusNames[fromStatus]}转换为${OrderStatusNames[toStatus]}`;
    }

    // 允许转换
    return null;
}

/**
 * 获取允许的下一个状态列表
 * @param {number} currentStatus - 当前状态
 * @returns {Array} 允许的状态数组
 */
export function getAllowedNextStatuses(currentStatus) {
    return ALLOWED_TRANSITIONS[currentStatus] || [];
}

/**
 * 检查状态是否为终态（不能再转换）
 * @param {number} status - 订单状态
 * @returns {boolean} 是否为终态
 */
export function isTerminalStatus(status) {
    return status === OrderStatus.COMPLETED || status === OrderStatus.CANCELLED;
}

/**
 * 检查状态是否为可取消状态
 * @param {number} status - 订单状态
 * @returns {boolean} 是否可取消
 */
export function isCancellableStatus(status) {
    const allowed = ALLOWED_TRANSITIONS[status] || [];
    return allowed.includes(OrderStatus.CANCELLED);
}

/**
 * 安全地更新订单状态（带前端验证）
 * 在调用API前先验证，提升用户体验
 *
 * @param {number} orderId - 订单ID
 * @param {number} currentStatus - 当前状态
 * @param {number} newStatus - 新状态
 * @param {Function} apiCall - API调用函数
 * @returns {Promise}
 *
 * @example
 * import { updateOrderStatus } from '@/api/errand.js';
 * import { safeUpdateOrderStatus } from '@/utils/order-status.js';
 *
 * // 使用方式1: 直接传入API函数
 * await safeUpdateOrderStatus(orderId, currentStatus, newStatus, updateOrderStatus);
 *
 * // 使用方式2: 使用Promise包装
 * await safeUpdateOrderStatus(orderId, currentStatus, newStatus, (orderId, status) => {
 *     return updateOrderStatus(orderId, status);
 * });
 */
export async function safeUpdateOrderStatus(orderId, currentStatus, newStatus, apiCall) {
    // 验证状态转换
    const error = getTransitionError(currentStatus, newStatus);

    if (error) {
        // 返回错误Promise
        return Promise.reject(error);
    }

    // 调用API
    try {
        const result = await apiCall(orderId, newStatus);
        return result;
    } catch (err) {
        // API调用失败
        throw err;
    }
}

/**
 * 显示状态转换错误提示
 * @param {number} fromStatus - 当前状态
 * @param {number} toStatus - 目标状态
 */
export function showTransitionErrorToast(fromStatus, toStatus) {
    const error = getTransitionError(fromStatus, toStatus);

    if (error) {
        uni.showToast({
            title: error,
            icon: 'none',
            duration: 3000
        });
        return true;
    }

    return false;
}

export default {
    OrderStatus,
    OrderStatusNames,
    canTransition,
    getTransitionError,
    getAllowedNextStatuses,
    isTerminalStatus,
    isCancellableStatus,
    safeUpdateOrderStatus,
    showTransitionErrorToast
};
