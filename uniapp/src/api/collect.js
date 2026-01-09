import { baseUrl } from "@/utils/env";

/**
 * 获取用户收藏的帖子
 * 新架构：使用论坛我收藏的帖子API
 */
export const fetchCollectedTopics = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/collected?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.data);
                    console.log('获取收藏帖子成功', res.data.data);
                } else {
                    reject(new Error('获取收藏帖子失败'));
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 收藏帖子
 * 新架构：使用论坛收藏API
 */
export const collectTopic = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/collect`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '收藏失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};

/**
 * 取消收藏帖子
 * 新架构：使用论坛取消收藏API
 */
export const uncollectTopic = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/collect`,
            method: 'DELETE',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '取消收藏失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};
