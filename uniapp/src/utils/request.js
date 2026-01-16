import {baseUrl} from '@/utils/env'

/**
 * HTTP错误码映射表
 * 用于显示用户友好的错误提示
 */
const HTTP_ERROR_MESSAGES = {
    400: '请求参数错误，请检查输入',
    401: '登录已过期，请重新登录',
    403: '没有权限执行此操作',
    404: '请求的资源不存在',
    405: '请求方法不允许',
    408: '请求超时，请稍后重试',
    500: '服务器错误，请稍后重试',
    502: '网关错误，请稍后重试',
    503: '服务暂时不可用',
    504: '网关超时，请稍后重试'
};

/**
 * 业务错误码映射表
 * 后端返回的自定义错误码
 */
const BUSINESS_ERROR_MESSAGES = {
    400: '请求参数错误',
    401: '登录已过期',
    403: '权限不足',
    404: '资源不存在',
    500: '服务器内部错误'
};

/**
 * Token过期处理
 * 清除本地存储并跳转到登录页
 */
function handleTokenExpired() {
    // 清除Token和用户信息
    uni.removeStorageSync('token');
    uni.removeStorageSync('userInfo');

    // 显示提示并跳转登录页
    uni.showModal({
        title: '登录过期',
        content: '您的登录已过期，请重新登录',
        showCancel: false,
        success: () => {
            // 使用 reLaunch 跳转到登录页，清空页面栈
            uni.reLaunch({
                url: '/pages/transition/login'
            });
        }
    });
}

/**
 * 显示错误提示
 * @param {string} msg - 错误消息
 * @param {number} code - 错误码
 */
function showErrorToast(msg, code) {
    // 401错误特殊处理（已在上层处理）
    if (code === 401) {
        return;
    }

    // 显示Toast提示
    uni.showToast({
        title: msg || '操作失败',
        icon: 'none',
        duration: 3000
    });
}

/**
 * 网络请求封装
 * 支持：
 * - 自动添加Token
 * - 统一错误处理
 * - Token过期检测
 * - 友好错误提示
 *
 * @param {Object} options - 请求配置
 * @param {string} options.url - 请求路径
 * @param {Object} options.params - 请求参数
 * @param {string} options.method - 请求方法 (GET/POST/PUT/DELETE)
 * @param {boolean} options.showError - 是否显示错误提示 (默认true)
 * @returns {Promise} - 返回Promise对象
 */
export function request({url='', params={}, method='GET', showError = true}) {

    const token = uni.getStorageSync('token');
    let header = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        // 使用 Authorization 头传递 token，与后端配置一致
        // 后端期望格式：Authorization: Bearer <token>
        'Authorization': token ? `Bearer ${token}` : ''
    }

    return new Promise((resolve, reject) => {
        uni.request({
            url: baseUrl + url,
            data: params,
            header: header,
            method: method,
            timeout: 30000, // 30秒超时
            success: (res) => {
                const {data, statusCode} = res;

                // ============================================
                // 1. 处理HTTP状态码错误
                // ============================================

                // 401 Unauthorized - Token过期或无效
                if (statusCode === 401) {
                    console.warn('[Request] Token expired:', url);
                    handleTokenExpired();
                    reject({
                        msg: '登录已过期',
                        code: 401,
                        url: url
                    });
                    return;
                }

                // 其他HTTP错误 (400, 403, 404, 500等)
                if (statusCode >= 400) {
                    const errorMsg = HTTP_ERROR_MESSAGES[statusCode] || data.msg || '请求失败';
                    console.error('[Request] HTTP Error:', statusCode, errorMsg, url);

                    if (showError) {
                        showErrorToast(errorMsg, statusCode);
                    }

                    reject({
                        msg: errorMsg,
                        code: statusCode,
                        url: url
                    });
                    return;
                }

                // ============================================
                // 2. 处理业务错误码
                // ============================================

                // 后端返回格式: { code: 200, msg: "成功", data: {...} }
                // 或: { code: 1, msg: "成功", data: {...} }

                // 成功响应
                if (data.code === 200 || data.code === 1) {
                    console.log('[Request] Success:', url, data);
                    resolve(res.data);
                    return;
                }

                // 业务错误 (后端返回的 code 不是200或1)
                const businessErrorMsg = BUSINESS_ERROR_MESSAGES[data.code] || data.msg || '操作失败';

                // 401业务错误码
                if (data.code === 401) {
                    console.warn('[Request] Token expired (business code):', url);
                    handleTokenExpired();
                    reject({
                        msg: businessErrorMsg,
                        code: data.code,
                        url: url
                    });
                    return;
                }

                // 其他业务错误
                console.error('[Request] Business Error:', data.code, businessErrorMsg, url);

                if (showError) {
                    showErrorToast(businessErrorMsg, data.code);
                }

                reject({
                    msg: businessErrorMsg,
                    code: data.code,
                    url: url
                });
            },
            fail: (err) => {
                // ============================================
                // 3. 处理网络错误
                // ============================================

                console.error('[Request] Network Error:', err);

                const errorMsg = '网络连接失败，请检查网络设置';

                if (showError) {
                    showErrorToast(errorMsg, null);
                }

                reject({
                    msg: errorMsg,
                    code: null,
                    error: err,
                    url: url
                });
            }
        });
    });
}

/**
 * GET请求快捷方法
 */
export function get(url, params = {}) {
    return request({
        url,
        params,
        method: 'GET'
    });
}

/**
 * POST请求快捷方法
 */
export function post(url, params = {}) {
    return request({
        url,
        params,
        method: 'POST'
    });
}

/**
 * PUT请求快捷方法
 */
export function put(url, params = {}) {
    return request({
        url,
        params,
        method: 'PUT'
    });
}

/**
 * DELETE请求快捷方法
 */
export function del(url, params = {}) {
    return request({
        url,
        params,
        method: 'DELETE'
    });
}

// 默认导出
export default {
    request,
    get,
    post,
    put,
    delete: del
};
