import { request } from "@/utils/request";

/**
 * 发布跑腿/求助
 * @param {Object} data 
 */
export const publishErrand = (data) => {
    return request({
        url: '/campus/sendContent',
        method: 'POST',
        params: data
    });
};

/**
 * 获取跑腿列表
 * @param {Object} params
 */
export const getErrandList = (params) => {
    return request({
        url: '/campus/contentList',
        method: 'GET',
        params: params
    });
};

/**
 * 接单 (实际上可能只是简单的状态变更或通知，具体看后端逻辑，暂时假设通过评论或私信沟通)
 * 或者如果有接单接口，在这里添加
 */
