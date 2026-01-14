package com.oddfar.campus.business.errand.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 跑腿订单实体
 */
@Data
@TableName("bus_errand_order")
public class BusErrandOrderEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 订单ID (雪花算法)
     */
    @TableId(value = "order_id", type = IdType.ASSIGN_ID)
    private Long orderId;

    /**
     * 订单号 (业务号)
     */
    private String orderNo;

    /**
     * 发布者ID
     */
    private Long publisherId;

    /**
     * 接单骑手ID
     */
    private Long runnerId;

    /**
     * 类型: 0取快递 1代买餐 2寄快递 3排队 4其他
     */
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
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
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
     * 平台抽成
     */
    private BigDecimal platformFee;

    /**
     * 支付状态: 0未支付 1已支付 2已退款
     */
    private Integer payStatus;

    /**
     * 支付时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date payTime;

    /**
     * 支付订单号
     */
    private String payOrderNo;

    /**
     * 订单状态: 0待接单 1已接单 2取件中 3配送中 4待确认 5已完成 6已取消
     */
    private Integer status;

    /**
     * 取消原因
     */
    private String cancelReason;

    /**
     * 备注
     */
    private String remark;

    /**
     * 乐观锁版本号
     */
    @Version
    private Integer version;

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
    private String publisherName;

    /**
     * 发布者头像
     */
    @TableField(exist = false)
    private String publisherAvatar;

    /**
     * 发布者手机号
     */
    @TableField(exist = false)
    private String publisherPhone;

    /**
     * 骑手昵称
     */
    @TableField(exist = false)
    private String runnerName;

    /**
     * 骑手头像
     */
    @TableField(exist = false)
    private String runnerAvatar;

    /**
     * 骑手手机号
     */
    @TableField(exist = false)
    private String runnerPhone;

    /**
     * 类型描述
     */
    @TableField(exist = false)
    private String typeDesc;

    /**
     * 状态描述
     */
    @TableField(exist = false)
    private String statusDesc;
}
