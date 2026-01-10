/**
 * 论坛业务类型定义
 */

// 分页结果通用接口
export interface PageResult<T> {
  rows: T[];
  total: number;
}

// 帖子视图对象 (对应后端 ForumPostVO)
export interface ForumPostVO {
  postId: number;
  userId: number;
  categoryId: number;
  categoryName: string;
  title: string;
  content: string;
  images: string[];
  isAnonymous: number;
  isDraft: number;
  viewCount: number;
  likeCount: number;
  commentCount: number;
  collectCount: number;
  status: number;
  nickName: string;
  avatar: string;
  isLiked: boolean;
  isCollected: boolean;
  createTime: string;
  updateTime: string;
}

// 评论视图对象 (对应后端 ForumCommentVO)
export interface ForumCommentVO {
  commentId: number;
  postId: number;
  userId: number;
  parentId: number;
  toUserId: number;
  content: string;
  likeCount: number;
  status: number;
  nickName: string;
  avatar: string;
  toUserNickName: string;
  isLiked: boolean;
  createTime: string;
  replies?: ForumCommentVO[];
}
