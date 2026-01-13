import { request } from "@/utils/request";

/**
 * 发布闲置物品
 * @param {Object} data 
 */
export const publishMarketItem = (data) => {
    return request({
        url: '/campus/sendContent',
        method: 'POST',
        params: data
    });
};

/**
 * 获取闲置列表
 * @param {Object} params
 */
export const getMarketList = (params) => {
    return request({
        url: '/campus/contentList',
        method: 'GET',
        params: params
    });
};
