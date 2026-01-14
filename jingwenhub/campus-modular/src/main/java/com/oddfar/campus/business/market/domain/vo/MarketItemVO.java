package com.oddfar.campus.business.market.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * 二手商品VO
 */
@Data
public class MarketItemVO {

    /**
     * 商品ID
     */
    private Long itemId;

    /**
     * 发布者ID
     */
    private Long userId;

    /**
     * 发布者昵称
     */
    private String nickName;

    /**
     * 发布者头像
     */
    private String avatar;

    /**
     * 分类ID
     */
    private Long categoryId;

    /**
     * 分类名称
     */
    private String categoryName;

    /**
     * 商品标题
     */
    private String title;

    /**
     * 商品描述
     */
    private String description;

    /**
     * 图片列表
     */
    private List<String> images;

    /**
     * 售价
     */
    private BigDecimal price;

    /**
     * 原价
     */
    private BigDecimal originalPrice;

    /**
     * 成色: 1-10
     */
    private Integer conditionLevel;

    /**
     * 成色描述
     */
    private String conditionDesc;

    /**
     * 交易方式: 0自提 1邮寄 2都可
     */
    private Integer tradeMethod;

    /**
     * 交易方式描述
     */
    private String tradeMethodDesc;

    /**
     * 交易地点
     */
    private String tradeLocation;

    /**
     * 浏览量
     */
    private Integer viewCount;

    /**
     * 收藏数
     */
    private Integer collectCount;

    /**
     * 状态
     */
    private Integer status;

    /**
     * 状态描述
     */
    private String statusDesc;

    /**
     * 当前用户是否收藏
     */
    private Boolean isCollected;

    /**
     * 是否是当前用户发布
     */
    private Boolean isMine;

    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;

    /**
     * 更新时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;
}
