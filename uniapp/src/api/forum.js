import { get, post, del } from '@/utils/request';

/**
 * ==================== 帖子相关 ====================
 */

/**
 * 获取最新帖子列表
 * @param {Number} pageNum 页码
 * @param {Number} pageSize 每页数量
 */
export const getNewestPosts = (pageNum = 1, pageSize = 10) => {
    return get(`/forum/posts/newest`, { pageNum, pageSize });
};

/**
 * 获取热门帖子列表
 * @param {Number} pageNum 页码
 * @param {Number} pageSize 每页数量
 */
export const getHotPosts = (pageNum = 1, pageSize = 10) => {
    return get(`/forum/posts/hot`, { pageNum, pageSize });
};

/**
 * 根据分类获取帖子列表
 * @param {Number} categoryId 分类ID
 * @param {Number} pageNum 页码
 * @param {Number} pageSize 每页数量
 */
export const getCategoryPosts = (categoryId, pageNum = 1, pageSize = 10) => {
    return get(`/forum/posts/category/${categoryId}`, { pageNum, pageSize });
};

/**
 * 获取帖子详情
 * @param {Number} postId 帖子ID
 */
export const getPostDetail = (postId) => {
    return get(`/forum/posts/${postId}`);
};

/**
 * 发布帖子
 * @param {Object} data 帖子数据
 * @param {String} data.title 标题
 * @param {String} data.content 内容
 * @param {Number} data.categoryId 分类ID
 * @param {Array} data.images 图片列表
 * @param {Number} data.isAnonymous 是否匿名 (0否 1是)
 */
export const publishPost = (data) => {
    return post('/forum/posts', data);
};

/**
 * 保存草稿
 * @param {Object} data 草稿数据
 */
export const saveDraft = (data) => {
    return post('/forum/posts/draft', data);
};

/**
 * 获取我的草稿
 */
export const getMyDrafts = () => {
    return get('/forum/posts/draft');
};

/**
 * 删除帖子
 * @param {Number} postId 帖子ID
 */
export const deletePost = (postId) => {
    return del(`/forum/posts/${postId}`);
};

/**
 * ==================== 点赞相关 ====================
 */

/**
 * 点赞帖子
 * @param {Number} postId 帖子ID
 */
export const likePost = (postId) => {
    return post(`/forum/posts/${postId}/like`);
};

/**
 * 取消点赞帖子
 * @param {Number} postId 帖子ID
 */
export const unlikePost = (postId) => {
    return del(`/forum/posts/${postId}/like`);
};

/**
 * ==================== 收藏相关 ====================
 */

/**
 * 收藏帖子
 * @param {Number} postId 帖子ID
 */
export const collectPost = (postId) => {
    return post(`/forum/posts/${postId}/collect`);
};

/**
 * 取消收藏帖子
 * @param {Number} postId 帖子ID
 */
export const uncollectPost = (postId) => {
    return del(`/forum/posts/${postId}/collect`);
};

/**
 * 获取我收藏的帖子
 * @param {Number} pageNum 页码
 * @param {Number} pageSize 每页数量
 */
export const getMyCollectedPosts = (pageNum = 1, pageSize = 10) => {
    return get('/forum/posts/collected', { pageNum, pageSize });
};

/**
 * 获取我发布的帖子
 * @param {Number} pageNum 页码
 * @param {Number} pageSize 每页数量
 */
export const getMyPosts = (pageNum = 1, pageSize = 10) => {
    return get('/forum/posts/mine', { pageNum, pageSize });
};

/**
 * ==================== 评论相关 ====================
 */

/**
 * 获取帖子评论列表
 * @param {Number} postId 帖子ID
 * @param {Number} pageNum 页码
 * @param {Number} pageSize 每页数量
 */
export const getPostComments = (postId, pageNum = 1, pageSize = 10) => {
    return get(`/forum/comments/post/${postId}`, { pageNum, pageSize });
};

/**
 * 发布评论
 * @param {Object} data 评论数据
 * @param {Number} data.postId 帖子ID
 * @param {Number} data.parentId 父评论ID
 * @param {String} data.content 评论内容
 * @param {Number} data.toUserId 被回复用户ID
 */
export const publishComment = (data) => {
    return post('/forum/comments', data);
};

/**
 * 删除评论
 * @param {Number} commentId 评论ID
 */
export const deleteComment = (commentId) => {
    return del(`/forum/comments/${commentId}`);
};

/**
 * 点赞评论
 * @param {Number} commentId 评论ID
 */
export const likeComment = (commentId) => {
    return post(`/forum/comments/${commentId}/like`);
};

/**
 * 取消点赞评论
 * @param {Number} commentId 评论ID
 */
export const unlikeComment = (commentId) => {
    return del(`/forum/comments/${commentId}/like`);
};

// 默认导出
export default {
    // 帖子相关
    getNewestPosts,
    getHotPosts,
    getCategoryPosts,
    getPostDetail,
    publishPost,
    saveDraft,
    getMyDrafts,
    deletePost,
    // 点赞相关
    likePost,
    unlikePost,
    // 收藏相关
    collectPost,
    uncollectPost,
    getMyCollectedPosts,
    getMyPosts,
    // 评论相关
    getPostComments,
    publishComment,
    deleteComment,
    likeComment,
    unlikeComment
};
