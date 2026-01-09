import { baseUrl } from "@/utils/env";

/**
 * 获取最新帖子列表（分页）
 * 新架构：使用论坛API
 */
export const getRecords = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        console.log(`开始调用getRecords, pageNum=${pageNum}, pageSize=${pageSize}`);
        const token = uni.getStorageSync('token');
        console.log(`当前 token:`, token ? '存在' : '不存在');
        
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/newest?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            timeout: 30000,  // 增加超时时间到30秒
            success: (res) => {
                console.log('getRecords 响应:', res);
                console.log('statusCode:', res.statusCode);
                console.log('data:', res.data);
                
                // 先检查响应是否有效
                if (!res || !res.data) {
                    console.error('响应无效: res 或 res.data 为 null/undefined');
                    reject('响应无效');
                    return;
                }
                
                // 检查 HTTP 状态码
                if (res.statusCode === 200) {
                    // 检查业务状态码
                    if (res.data.code === 200) {
                        console.log('获取话题列表成功:', res.data);
                        // 直接返回 res.data，它已经包含了 rows 和 total
                        resolve(res.data);
                    } else {
                        console.error('业务报错, code:', res.data.code, 'msg:', res.data.msg);
                        reject(res.data.msg || '加载失败');
                    }
                } else {
                    console.error('HTTP错误, statusCode:', res.statusCode);
                    reject(`HTTP错误: ${res.statusCode}`);
                }
            },
            fail: (err) => {
                console.error('getRecords 请求失败:', err);
                reject(err);
            },
            complete: () => {
                console.log('getRecords 请求完成');
            }
        });
    });
};

/**
 * 上传单个文件（图片）
 * 新架构：使用校园文件上传API
 */
export const uploadSingleFile = (filePath) => {
    return new Promise((resolve, reject) => {
        uni.uploadFile({
            url: `${baseUrl}/campus/imageUpload`,
            filePath: filePath,
            name: 'file',
            header: {
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    const responseData = JSON.parse(res.data);
                    if (responseData.code === 200) {
                        resolve(responseData.data)
                    } else {
                        reject('上传失败: ' + responseData.msg);
                    }
                } catch (e) {
                    reject('解析失败');
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};

/**
 * 删除单个文件
 * 注意：新架构暂时保留此接口，但可能需要后端补充对应的删除接口
 */
export const deleteSingleFile = (urlToDelete) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/campus/file/delete`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: { url: urlToDelete },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(urlToDelete);
                } else {
                    reject('删除失败: ' + res.data.msg);
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
 * 新架构：使用论坛发布API
 */
export const uploadTopic = (data) => {
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
 * 获取我发布的帖子
 * 新架构：使用论坛我的帖子API
 */
export const getPublishedPosts = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/mine?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject(new Error('Failed to fetch published posts'));
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取帖子详情
 * 新架构：使用论坛帖子详情API
 */
export const fetchTopic = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
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
 * 删除帖子
 * 新架构：使用论坛删除帖子API
 */
export const deleteTopic = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/${postId}`,
            method: 'DELETE',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '删除失败');
                }
            },
            fail: (err) => reject(err),
        });
    });
};

/**
 * 获取草稿（用于检查是否存在）
 * 新架构：使用论坛草稿API，通过返回值判断是否存在
 */
export const checkDraftExistence = () => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/draft`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    // 如果有数据则草稿存在
                    resolve(res.data.data ? true : false);
                } else {
                    resolve(false);
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
 * 新架构：使用论坛草稿API
 */
export const getDraft = () => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/posts/draft`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject('获取草稿失败: ' + res.data.msg);
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
 * 新架构：使用论坛草稿API
 */
export const saveDraft = (data) => {
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
                    resolve(res.data.data);
                } else {
                    reject('保存草稿失败: ' + res.data.msg);
                }
            },
            fail: (err) => {
                reject(err);
            }
        });
    });
};
