import { get, post, put, del } from "@/utils/request";

/**
 * 获取商品列表
 */
export const getMarketItems = (categoryId = null, pageNum = 1, pageSize = 10) => {
    const params = { pageNum, pageSize };
    if (categoryId) {
        params.categoryId = categoryId;
    }
    return get('/api/v1/market/items', params)
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 获取商品详情
 */
export const getItemDetail = (itemId) => {
    return get(`/api/v1/market/items/${itemId}`)
        .then(response => response.data);
};

/**
 * 发布商品
 */
export const publishItem = (data) => {
    return post('/api/v1/market/items', data);
};

/**
 * 更新商品
 */
export const updateItem = (itemId, data) => {
    return put(`/api/v1/market/items/${itemId}`, data);
};

/**
 * 删除商品
 */
export const deleteItem = (itemId) => {
    return del(`/api/v1/market/items/${itemId}`);
};

/**
 * 标记为已售
 */
export const markItemSold = (itemId) => {
    return post(`/api/v1/market/items/${itemId}/sold`);
};

/**
 * 下架商品
 */
export const offShelfItem = (itemId) => {
    return post(`/api/v1/market/items/${itemId}/off-shelf`);
};

/**
 * 收藏商品
 */
export const collectItem = (itemId) => {
    return post(`/api/v1/market/items/${itemId}/collect`);
};

/**
 * 取消收藏商品
 */
export const uncollectItem = (itemId) => {
    return del(`/api/v1/market/items/${itemId}/collect`);
};

/**
 * 获取我发布的商品
 */
export const getMyItems = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/market/items/mine', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 获取我收藏的商品
 */
export const getMyCollectedItems = (pageNum = 1, pageSize = 10) => {
    return get('/api/v1/market/items/collected', { pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

/**
 * 搜索商品
 */
export const searchItems = (keyword, pageNum = 1, pageSize = 10) => {
    return get('/api/v1/market/items/search', { keyword: encodeURIComponent(keyword), pageNum, pageSize })
        .then(response => ({
            rows: response.rows || [],
            total: response.total || 0
        }));
};

// 兼容旧接口名称
export const publishMarketItem = publishItem;
export const getMarketList = getMarketItems;
