import { baseUrl } from "@/utils/env";

/**
 * 获取最新帖子列表
 */
export const getNewestPosts = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/newest?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '加载失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 获取热门帖子列表
 */
export const getHotPosts = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/hot?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '加载失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 获取分类帖子列表
 */
export const getPostsByCategory = (categoryId, pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/category/${categoryId}?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '加载失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 获取帖子详情
 */
export const getPostDetail = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject(res.data.msg || '获取失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 发布帖子
 */
export const publishPost = (data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: data,
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '发布失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 保存草稿
 */
export const savePostDraft = (data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/draft`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: data,
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '保存失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 获取草稿
 */
export const getPostDraft = () => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/draft`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject(res.data.msg || '获取失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 删除帖子
 */
export const deletePost = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}`,
            method: 'DELETE',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '删除失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 点赞帖子
 */
export const likePost = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/like`,
            method: 'POST',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '点赞失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 取消点赞
 */
export const unlikePost = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/like`,
            method: 'DELETE',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '取消失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 收藏帖子
 */
export const collectPost = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/collect`,
            method: 'POST',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '收藏失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 取消收藏
 */
export const uncollectPost = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}/collect`,
            method: 'DELETE',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '取消失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 获取我发布的帖子
 */
export const getMyPosts = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/mine?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '加载失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 获取我收藏的帖子
 */
export const getMyCollects = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/collected?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '加载失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 获取帖子评论列表
 */
export const getPostComments = (postId, pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments/post/${postId}?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '加载失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 发布评论
 */
export const publishComment = (data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: data,
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '评论失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 删除评论
 */
export const deleteComment = (commentId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments/${commentId}`,
            method: 'DELETE',
            header: {
                'content-type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '删除失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};
