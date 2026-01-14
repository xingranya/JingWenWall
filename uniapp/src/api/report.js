import { baseUrl } from "@/utils/env";

/**
 * 举报目标类型
 */
export const ReportTargetType = {
    POST: 0,      // 帖子
    COMMENT: 1,   // 评论
    USER: 2,      // 用户
    ITEM: 3,      // 商品
    JOB: 4        // 兼职
};

/**
 * 举报原因选项
 */
export const ReportReasons = [
    { value: 'spam', label: '垃圾广告' },
    { value: 'porn', label: '色情低俗' },
    { value: 'violence', label: '暴力血腥' },
    { value: 'fraud', label: '欺诈骗钱' },
    { value: 'harassment', label: '骚扰辱骂' },
    { value: 'illegal', label: '违法违规' },
    { value: 'infringement', label: '侵权举报' },
    { value: 'other', label: '其他原因' }
];

/**
 * 提交举报
 * @param {Object} data { targetType, targetId, reasonType, reasonDetail, images }
 */
export const submitReport = (data) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/report`,
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
                    reject(res.data.msg || '举报失败');
                }
            },
            fail: (err) => reject(err)
        });
    });
};

/**
 * 举报帖子
 */
export const reportPost = (postId, reasonType, reasonDetail = '', images = []) => {
    return submitReport({
        targetType: ReportTargetType.POST,
        targetId: postId,
        reasonType,
        reasonDetail,
        images
    });
};

/**
 * 举报评论
 */
export const reportComment = (commentId, reasonType, reasonDetail = '', images = []) => {
    return submitReport({
        targetType: ReportTargetType.COMMENT,
        targetId: commentId,
        reasonType,
        reasonDetail,
        images
    });
};

/**
 * 举报用户
 */
export const reportUser = (userId, reasonType, reasonDetail = '', images = []) => {
    return submitReport({
        targetType: ReportTargetType.USER,
        targetId: userId,
        reasonType,
        reasonDetail,
        images
    });
};

/**
 * 举报商品
 */
export const reportItem = (itemId, reasonType, reasonDetail = '', images = []) => {
    return submitReport({
        targetType: ReportTargetType.ITEM,
        targetId: itemId,
        reasonType,
        reasonDetail,
        images
    });
};
