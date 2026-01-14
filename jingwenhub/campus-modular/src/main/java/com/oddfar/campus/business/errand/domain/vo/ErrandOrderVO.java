package com.oddfar.campus.business.errand.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 跑腿订单VO
 */
@Data
public class ErrandOrderVO {

    /**
     * 订单ID
     */
    private Long orderId;

    /**
     * 订单号
     */
    private String orderNo;

    /**
     * 发布者ID
     */
    private Long publisherId;

    /**
     * 发布者昵称
     */
    private String publisherName;

    /**
     * 发布者头像
     */
    private String publisherAvatar;

    /**
     * 发布者手机号 (仅接单后可见)
     */
    private String publisherPhone;

    /**
     * 骑手ID
     */
    private Long runnerId;

    /**
     * 骑手昵称
     */
    private String runnerName;

    /**
     * 骑手头像
     */
    private String runnerAvatar;

    /**
     * 骑手手机号
     */
    private String runnerPhone;

    /**
     * 骑手评分
     */
    private BigDecimal runnerRating;

    /**
     * 类型: 0取快递 1代买餐 2寄快递 3排队 4其他
     */
    private Integer type;

    /**
     * 类型描述
     */
    private String typeDesc;

    /**
     * 取件地址
     */
    private String pickupAddr;

    /**
     * 取件经纬度
     */
    private BigDecimal pickupLat;
    private BigDecimal pickupLng;

    /**
     * 送达地址
     */
    private String deliveryAddr;

    /**
     * 送达经纬度
     */
    private BigDecimal deliveryLat;
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
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm", timezone = "GMT+8")
    private Date expectTime;

    /**
     * 小费
     */
    private BigDecimal tip;

    /**
     * 基础配送费
     */
    private BigDecimal baseFee;

    /**
     * 总费用
     */
    private BigDecimal totalFee;

    /**
     * 骑手佣金
     */
    private BigDecimal runnerFee;

    /**
     * 支付状态
     */
    private Integer payStatus;

    /**
     * 支付状态描述
     */
    private String payStatusDesc;

    /**
     * 订单状态
     */
    private Integer status;

    /**
     * 状态描述
     */
    private String statusDesc;

    /**
     * 取消原因
     */
    private String cancelReason;

    /**
     * 备注
     */
    private String remark;

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

    /**
     * 是否是当前用户发布的
     */
    private Boolean isMine;

    /**
     * 是否是当前用户接的单
     */
    private Boolean isMyAccept;
}
