import { get, post, put, del } from "@/utils/request";

/**
 * 获取最新帖子列表（分页）
 * 新架构：使用论坛API
 */
export const getRecords = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/forum/posts/newest', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 上传单个文件（图片）
 * 新架构：使用校园文件上传API
 */
export const uploadSingleFile = (filePath) => {
    return new Promise((resolve, reject) => {
        const token = uni.getStorageSync('token');

        uni.uploadFile({
            url: '/campus/imageUpload',
            filePath: filePath,
            name: 'file',
            header: {
                'Authorization': `Bearer ${token}`
            },
            success: (res) => {
                try {
                    const responseData = JSON.parse(res.data);
                    if (responseData.code === 200) {
                        resolve(responseData.data);
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
    return post('/campus/file/delete', { fileUrl: urlToDelete });
};

/**
 * 发布帖子
 * 新架构：使用论坛发布API
 */
export const uploadTopic = (data) => {
    return post('/api/v1/forum/posts', data);
};

/**
 * 获取我发布的帖子
 * 新架构：使用论坛我的帖子API
 */
export const getPublishedPosts = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/forum/posts/mine', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 获取帖子详情
 * 新架构：使用论坛帖子详情API
 */
export const fetchTopic = (postId) => {
    return get(`/api/v1/forum/posts/${postId}`)
        .then(response => response.data);
};

/**
 * 删除帖子
 * 新架构：使用论坛删除帖子API
 */
export const deleteTopic = (postId) => {
    return del(`/api/v1/forum/posts/${postId}`);
};

/**
 * 获取草稿（用于检查是否存在）
 * 新架构：使用论坛草稿API，通过返回值判断是否存在
 */
export const checkDraftExistence = () => {
    return get('/api/v1/forum/posts/draft')
        .then(response => response.data ? true : false);
};

/**
 * 获取草稿
 * 新架构：使用论坛草稿API
 */
export const getDraft = () => {
    return get('/api/v1/forum/posts/draft')
        .then(response => response.data);
};

/**
 * 保存草稿
 * 新架构：使用论坛草稿API
 */
export const saveDraft = (data) => {
    return post('/api/v1/forum/posts/draft', data)
        .then(response => response.data);
};
