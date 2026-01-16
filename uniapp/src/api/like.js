import { post, del } from "@/utils/request";

/**
 * 点赞帖子
 * 新架构：使用论坛点赞API
 */
export const likeTopic = (postId) => {
    return post(`/api/v1/forum/posts/${postId}/like`);
};

/**
 * 取消点赞帖子
 * 新架构：使用论坛取消点赞API
 */
export const unlikeTopic = (postId) => {
    return del(`/api/v1/forum/posts/${postId}/like`);
};
