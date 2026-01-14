package com.oddfar.campus.business.errand.domain.dto;

import lombok.Data;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 跑腿订单创建DTO
 */
@Data
public class ErrandOrderDTO {

    /**
     * 订单ID (更新时使用)
     */
    private Long orderId;

    /**
     * 类型: 0取快递 1代买餐 2寄快递 3排队 4其他
     */
    @NotNull(message = "订单类型不能为空")
    private Integer type;

    /**
     * 取件地址
     */
    private String pickupAddr;

    /**
     * 取件纬度
     */
    private BigDecimal pickupLat;

    /**
     * 取件经度
     */
    private BigDecimal pickupLng;

    /**
     * 送达地址
     */
    @NotBlank(message = "送达地址不能为空")
    private String deliveryAddr;

    /**
     * 送达纬度
     */
    private BigDecimal deliveryLat;

    /**
     * 送达经度
     */
    private BigDecimal deliveryLng;

    /**
     * 物品描述
     */
    private String goodsDesc;

    /**
     * 物品重量
     */
    private String goodsWeight;

    /**
     * 期望送达时间
     */
    private Date expectTime;

    /**
     * 小费
     */
    @DecimalMin(value = "0", message = "小费不能为负数")
    private BigDecimal tip;

    /**
     * 备注
     */
    private String remark;
}
