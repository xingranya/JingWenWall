import { get, put } from "@/utils/request";
import { baseUrl } from "@/utils/env";

/**
 * 获取当前用户信息
 * 新架构：使用后端BusStudentController的接口
 */
export const getCurrentUserInfo = () => {
    return get('/student/get/info');
};

/**
 * 更新用户信息
 * @param {Object} data 用户信息
 * @param {String} data.username 用户名
 * @param {String} data.avatar 头像URL
 * @param {Number} data.sex 性别 (1:男性, 2:女性)
 * @param {String} data.studentid 学号
 */
export const updateUserInfo = (data) => {
    return put('/student/update/info', data);
};

/**
 * 上传头像
 * @param {String} filePath 本地文件路径
 */
export const uploadAvatar = (filePath) => {
    return new Promise((resolve, reject) => {
        uni.uploadFile({
            url: `${baseUrl}/student/common/upload`,
            filePath: filePath,
            name: 'files',
            header: {
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    const responseData = JSON.parse(res.data);
                    if (responseData.code === 1) {
                        resolve(responseData);
                    } else {
                        reject(responseData.msg || '上传失败');
                    }
                } catch (e) {
                    reject('解析响应失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};
