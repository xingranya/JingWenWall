import request from '@/utils/request'

// ==================== 订单管理 ====================

// 查询跑腿订单列表
export function listOrder(query) {
  return request({
    url: '/admin/errand/order/list',
    method: 'get',
    params: query
  })
}

// 获取订单详情
export function getOrder(orderId) {
  return request({
    url: '/admin/errand/order/' + orderId,
    method: 'get'
  })
}

// 取消订单
export function cancelOrder(orderId, reason) {
  return request({
    url: '/admin/errand/order/' + orderId + '/cancel',
    method: 'post',
    params: { reason }
  })
}

// 删除订单
export function delOrder(orderIds) {
  return request({
    url: '/admin/errand/order/' + orderIds,
    method: 'delete'
  })
}

// ==================== 骑手管理 ====================

// 查询骑手列表
export function listRunner(query) {
  return request({
    url: '/admin/errand/runner/list',
    method: 'get',
    params: query
  })
}

// 审核骑手
export function auditRunner(runnerId, passed, remark) {
  return request({
    url: '/admin/errand/runner/audit/' + runnerId,
    method: 'post',
    params: { passed, remark }
  })
}

// 禁用骑手
export function disableRunner(runnerId, reason) {
  return request({
    url: '/admin/errand/runner/disable/' + runnerId,
    method: 'post',
    params: { reason }
  })
}

// 启用骑手
export function enableRunner(runnerId) {
  return request({
    url: '/admin/errand/runner/enable/' + runnerId,
    method: 'post'
  })
}
