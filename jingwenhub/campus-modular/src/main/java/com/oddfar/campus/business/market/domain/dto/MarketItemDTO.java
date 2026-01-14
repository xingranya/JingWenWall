package com.oddfar.campus.business.market.domain.dto;

import lombok.Data;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

/**
 * 二手商品发布DTO
 */
@Data
public class MarketItemDTO {

    /**
     * 商品ID (更新时使用)
     */
    private Long itemId;

    /**
     * 商品分类ID
     */
    private Long categoryId;

    /**
     * 商品标题
     */
    @NotBlank(message = "商品标题不能为空")
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
    @NotNull(message = "售价不能为空")
    @DecimalMin(value = "0.01", message = "售价必须大于0")
    private BigDecimal price;

    /**
     * 原价
     */
    private BigDecimal originalPrice;

    /**
     * 成色: 1-10
     */
    @Min(value = 1, message = "成色最小为1")
    @Max(value = 10, message = "成色最大为10")
    private Integer conditionLevel;

    /**
     * 交易方式: 0自提 1邮寄 2都可
     */
    private Integer tradeMethod;

    /**
     * 交易地点
     */
    private String tradeLocation;
}
