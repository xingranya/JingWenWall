/**
 * 通用分页结果处理器
 * 统一处理后端 R.ok().put(PageResult) 返回的格式
 */
export function handlePageResult(res) {
  if (res.data && res.data.code === 200) {
    return {
      rows: res.data.rows || [],
      total: res.data.total || 0
    };
  } else {
    const errorMsg = res.data ? res.data.msg : '网络请求失败';
    console.error('[API Error]:', errorMsg);
    throw new Error(errorMsg);
  }
}
