import { baseUrl } from "@/utils/env";
import { handlePageResult } from "@/utils/api-helper";

/**
 * 获取商品列表
 */
export const getMarketItems = (categoryId = null, pageNum = 1, pageSize = 10) => {
    let url = `${baseUrl}/api/v1/market/items?pageNum=${pageNum}&pageSize=${pageSize}`;
    if (categoryId) {
        url += `&categoryId=${categoryId}`;
    }
    return new Promise((resolve, reject) => {
        uni.request({
            url: url,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取商品详情
 */
export const getItemDetail = (itemId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/${itemId}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.data);
                } else {
                    reject(res.data.msg || '获取失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 发布商品
 */
export const publishItem = (data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: data,
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data);
                } else {
                    reject(res.data.msg || '发布失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 更新商品
 */
export const updateItem = (itemId, data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/${itemId}`,
            method: 'PUT',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            data: data,
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '更新失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 删除商品
 */
export const deleteItem = (itemId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/${itemId}`,
            method: 'DELETE',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '删除失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 标记为已售
 */
export const markItemSold = (itemId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/${itemId}/sold`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '操作失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 下架商品
 */
export const offShelfItem = (itemId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/${itemId}/off-shelf`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '下架失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 收藏商品
 */
export const collectItem = (itemId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/${itemId}/collect`,
            method: 'POST',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '收藏失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 取消收藏商品
 */
export const uncollectItem = (itemId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/${itemId}/collect`,
            method: 'DELETE',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                if (res.statusCode === 200 && res.data.code === 200) {
                    resolve(res.data.msg);
                } else {
                    reject(res.data.msg || '取消收藏失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取我发布的商品
 */
export const getMyItems = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/mine?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 获取我收藏的商品
 */
export const getMyCollectedItems = (pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/collected?pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 搜索商品
 */
export const searchItems = (keyword, pageNum = 1, pageSize = 10) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/market/items/search?keyword=${encodeURIComponent(keyword)}&pageNum=${pageNum}&pageSize=${pageSize}`,
            method: 'GET',
            header: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${uni.getStorageSync('token')}`
            },
            success: (res) => {
                try {
                    resolve(handlePageResult(res));
                } catch (err) {
                    reject(err.message);
                }
            },
            fail: (err) => reject(err)
        });
    });
};

// 兼容旧接口名称
export const publishMarketItem = publishItem;
export const getMarketList = getMarketItems;
