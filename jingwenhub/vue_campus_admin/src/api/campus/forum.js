import request from '@/utils/request'

// ==================== 帖子管理 ====================

// 查询帖子列表
export function listPost(query) {
  return request({
    url: '/admin/forum/post/list',
    method: 'get',
    params: query
  })
}

// 获取帖子详情
export function getPost(postId) {
  return request({
    url: '/admin/forum/post/' + postId,
    method: 'get'
  })
}

// 修改帖子
export function updatePost(data) {
  return request({
    url: '/admin/forum/post',
    method: 'put',
    data: data
  })
}

// 删除帖子
export function delPost(postIds) {
  return request({
    url: '/admin/forum/post/' + postIds,
    method: 'delete'
  })
}

// 审核帖子
export function auditPost(postId, status) {
  return request({
    url: '/admin/forum/post/audit/' + postId,
    method: 'post',
    params: { status }
  })
}

// ==================== 评论管理 ====================

// 查询评论列表
export function listComment(query) {
  return request({
    url: '/admin/forum/comment/list',
    method: 'get',
    params: query
  })
}

// 获取评论详情
export function getComment(commentId) {
  return request({
    url: '/admin/forum/comment/' + commentId,
    method: 'get'
  })
}

// 删除评论
export function delComment(commentIds) {
  return request({
    url: '/admin/forum/comment/' + commentIds,
    method: 'delete'
  })
}

// 审核评论
export function auditComment(commentId, status) {
  return request({
    url: '/admin/forum/comment/audit/' + commentId,
    method: 'post',
    params: { status }
  })
}
