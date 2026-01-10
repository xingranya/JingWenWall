import { baseUrl } from "@/utils/env";
import { handlePageResult } from "@/utils/api-helper";

/**
 * 获取用户收藏的帖子
 * 新架构：使用论坛我收藏的帖子API
 * 后端PageResult返回格式：{code: 200, msg: "success", rows: [...], total: N}
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
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => {
                console.error('[收藏列表接口失败]', err);
                reject('网络请求失败，请检查网络连接');
            }
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
