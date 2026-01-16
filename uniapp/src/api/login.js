import { post } from "@/utils/request";

/**
 * token校验与续签
 * 注：当前后端使用 JWT，不需要额外的 token 校验接口
 * JWT 会在每次请求时自动校验
 */
export const checkTokenService = () => {
    const token = uni.getStorageSync('token');

    if (!token) {
        console.log('token 不存在');
        return Promise.reject(new Error('token 不存在'));
    }

    // JWT token 直接返回有效
    console.log('token 存在，直接返回');
    return Promise.resolve({ valid: true });
}

/**
 * 用户微信小程序登录
 * @param {Object} LoginData - 包含 code 的登录数据
 */
export const userLoginService = (LoginData) => {
    return post('/api/v1/wx/auth/login', LoginData)
        .then(data => {
            // 获取 token（根据 WxLoginVO 的结构）
            const token = data.data.token;

            if (token) {
                console.log('登录成功，保存 token:', token);
                uni.setStorageSync('token', token);

                // 保存用户信息
                if (data.data.studentInfo) {
                    uni.setStorageSync('userInfo', data.data.studentInfo);
                }

                return data;
            } else {
                console.error('token 不存在');
                throw new Error('token 不存在');
            }
        });
}
