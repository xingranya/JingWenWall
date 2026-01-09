import { baseUrl } from "@/utils/env";

/**
 * 点赞帖子
 * 新架构：使用论坛点赞API
 */
export const likeTopic = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/like`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '点赞失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};

/**
 * 取消点赞帖子
 * 新架构：使用论坛取消点赞API
 */
export const unlikeTopic = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/like`,
            method: 'DELETE',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '取消点赞失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};
