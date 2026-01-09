import { baseUrl } from "@/utils/env";

/**
 * 获取当前用户信息
 * 新架构：使用后端BusStudentController的接口
 */
export const getCurrentUserInfo = () => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/student/get/info`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject(res.data.msg);
                }
            },
            fail: (err) => reject(err),
        });
    });
};
