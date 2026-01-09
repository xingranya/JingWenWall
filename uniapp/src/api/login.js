import {baseUrl} from "@/utils/env";

/**
 * token校验与续签
 * 注：当前后端使用 JWT，不需要额外的 token 校验接口
 * JWT 会在每次请求时自动校验
 */
export const checkTokenService = () => {
    return new Promise((resolve, reject) => {
        const token = uni.getStorageSync('token');
        
        if (!token) {
            console.log('token 不存在');
            reject(new Error('token 不存在'));
            return;
        }
        
        // JWT token 直接返回有效
        // 如果后端有具体的 token 校验接口，可以在这里调用
        console.log('token 存在，直接返回');
        resolve({ valid: true });
    });
}

/**
 * 用户微信小程序登录
 * @param {Object} LoginData - 包含 code 的登录数据
 */
export const userLoginService = (LoginData) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: baseUrl + '/api/v1/wx/auth/login',  // 使用新的微信登录接口
            method: 'POST',
            header: {
                'Content-Type': 'application/json'
            },
            data: LoginData,  // 直接传递对象，uni.request 会自动序列化
            success: function (res) {
                console.log('微信登录响应:', res);
                
                // 检查响应状态
                if (res.statusCode === 200 && res.data.code === 200) {
                    // 获取 token （根据 WxLoginVO 的结构）
                    const token = res.data.data.token;
                    
                    if (token) {
                        console.log('登录成功，保存 token:', token);
                        uni.setStorageSync('token', token);
                        
                        // 保存用户信息
                        if (res.data.data.studentInfo) {
                            uni.setStorageSync('userInfo', res.data.data.studentInfo);
                        }
                        
                        resolve(res.data);
                    } else {
                        console.error('token 不存在');
                        reject(new Error('token 不存在'));
                    }
                } else {
                    console.error('登录失败:', res.data.msg || '未知错误');
                    reject(new Error(res.data.msg || '登录失败'));
                }
            },
            fail: function (error) {
                console.error('请求失败:', error);
                reject(error);
            }
        });
    });
}
