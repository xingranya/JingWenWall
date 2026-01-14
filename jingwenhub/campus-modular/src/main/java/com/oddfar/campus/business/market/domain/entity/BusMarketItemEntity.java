package com.oddfar.campus.business.market.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * 二手商品实体
 */
@Data
@TableName(value = "bus_market_item", autoResultMap = true)
public class BusMarketItemEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 商品ID
     */
    @TableId(value = "item_id", type = IdType.ASSIGN_ID)
    private Long itemId;

    /**
     * 发布者ID
     */
    private Long userId;

    /**
     * 商品分类ID
     */
    private Long categoryId;

    /**
     * 商品标题
     */
    private String title;

    /**
     * 商品描述
     */
    private String description;

    /**
     * 图片列表(JSON)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
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
     * 交易方式: 0自提 1邮寄 2都可
     */
    private Integer tradeMethod;

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
     * 状态: 0待审核 1在售 2已售 3下架
     */
    private Integer status;

    /**
     * 逻辑删除
     */
    @TableLogic
    @JsonIgnore
    private Integer delFlag;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;

    // ========== 非数据库字段 ==========

    /**
     * 发布者昵称
     */
    @TableField(exist = false)
    private String nickName;

    /**
     * 发布者头像
     */
    @TableField(exist = false)
    private String avatar;

    /**
     * 分类名称
     */
    @TableField(exist = false)
    private String categoryName;

    /**
     * 状态描述
     */
    @TableField(exist = false)
    private String statusDesc;

    /**
     * 当前用户是否收藏
     */
    @TableField(exist = false)
    private Boolean isCollected;
}
