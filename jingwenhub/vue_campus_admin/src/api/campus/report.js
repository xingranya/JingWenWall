import request from '@/utils/request'

// 查询举报列表
export function listReport(query) {
  return request({
    url: '/admin/report/list',
    method: 'get',
    params: query
  })
}

// 获取举报详情
export function getReport(reportId) {
  return request({
    url: '/admin/report/' + reportId,
    method: 'get'
  })
}

// 处理举报
export function handleReport(reportId, handled, remark) {
  return request({
    url: '/admin/report/handle/' + reportId,
    method: 'post',
    params: { handled, remark }
  })
}

// 批量处理举报
export function batchHandleReport(reportIds, handled, remark) {
  return request({
    url: '/admin/report/batch-handle',
    method: 'post',
    params: { handled, remark },
    data: reportIds
  })
}

// 删除举报
export function delReport(reportIds) {
  return request({
    url: '/admin/report/' + reportIds,
    method: 'delete'
  })
}

// 获取举报统计
export function getReportStats() {
  return request({
    url: '/admin/report/stats',
    method: 'get'
  })
}
