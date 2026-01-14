import request from '@/utils/request'

// 查询商品列表
export function listMarketItem(query) {
  return request({
    url: '/admin/market/list',
    method: 'get',
    params: query
  })
}

// 获取商品详情
export function getMarketItem(itemId) {
  return request({
    url: '/admin/market/' + itemId,
    method: 'get'
  })
}

// 下架商品
export function offShelfItem(itemId, reason) {
  return request({
    url: '/admin/market/' + itemId + '/off-shelf',
    method: 'post',
    params: { reason }
  })
}

// 上架商品
export function onShelfItem(itemId) {
  return request({
    url: '/admin/market/' + itemId + '/on-shelf',
    method: 'post'
  })
}

// 删除商品
export function delMarketItem(itemIds) {
  return request({
    url: '/admin/market/' + itemIds,
    method: 'delete'
  })
}

// 获取统计数据
export function getMarketStats() {
  return request({
    url: '/admin/market/stats',
    method: 'get'
  })
}
