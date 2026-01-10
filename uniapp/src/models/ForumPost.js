/**
 * 论坛帖子数据模型工厂
 * 确保前端字段与后端 ForumPostVO 严格一致
 */
export function createEmptyForumPost() {
  return {
    postId: null,
    userId: null,
    categoryId: null,
    categoryName: '',
    title: '',
    content: '',
    images: [],
    isAnonymous: 0,
    isDraft: 0,
    viewCount: 0,
    likeCount: 0,
    commentCount: 0,
    collectCount: 0,
    status: 0,
    nickName: '',
    avatar: '',
    isLiked: false,
    isCollected: false,
    createTime: '',
    updateTime: ''
  };
}
