import { get, post, del } from "@/utils/request";

/**
 * 获取用户收藏的帖子
 * 新架构：使用论坛我收藏的帖子API
 * 后端PageResult返回格式：{code: 200, msg: "success", rows: [...], total: N}
 */
export const fetchCollectedTopics = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/forum/posts/collected', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 收藏帖子
 * 新架构：使用论坛收藏API
 */
export const collectTopic = (postId) => {
    return post(`/api/v1/forum/posts/${postId}/collect`);
};

/**
 * 取消收藏帖子
 * 新架构：使用论坛取消收藏API
 */
export const uncollectTopic = (postId) => {
    return del(`/api/v1/forum/posts/${postId}/collect`);
};
