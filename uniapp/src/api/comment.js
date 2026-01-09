import { baseUrl } from "@/utils/env";

/**
 * 获取评论列表
 * 新架构：使用论坛评论API
 */
export const fetchComments = (postId, pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments/post/${postId}?pageNum=${pageNum}&pageSize=${pageSize}`,
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

/**
 * 提交评论
 * 新架构：使用论坛发布评论API
 */
export const submitComment = (postId, content) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: { postId, content },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '评论失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};

/**
 * 删除评论
 * 新架构：使用论坛删除评论API
 */
export const deleteComment = (commentId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments/${commentId}`,
            method: 'DELETE',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '删除评论失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};

/**
 * 点赞评论
 * 新架构：使用论坛点赞评论API
 */
export const likeComment = (commentId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments/${commentId}/like`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '点赞评论失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};

/**
 * 取消点赞评论
 * 新架构：使用论坛取消点赞评论API
 */
export const unlikeComment = (commentId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments/${commentId}/like`,
            method: 'DELETE',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '取消点赞评论失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};
