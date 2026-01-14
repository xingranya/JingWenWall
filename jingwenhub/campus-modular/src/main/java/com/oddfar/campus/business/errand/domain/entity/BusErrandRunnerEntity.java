package com.oddfar.campus.business.errand.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 骑手认证实体
 */
@Data
@TableName("bus_errand_runner")
public class BusErrandRunnerEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 骑手ID
     */
    @TableId(value = "runner_id", type = IdType.AUTO)
    private Long runnerId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 真实姓名
     */
    private String realName;

    /**
     * 身份证号
     */
    private String idCard;

    /**
     * 身份证正面照
     */
    private String idCardFront;

    /**
     * 身份证背面照
     */
    private String idCardBack;

    /**
     * 学生证照片
     */
    private String studentCard;

    /**
     * 完成订单数
     */
    private Integer totalOrders;

    /**
     * 累计收入
     */
    private BigDecimal totalIncome;

    /**
     * 评分
     */
    private BigDecimal rating;

    /**
     * 状态: 0待审核 1通过 2拒绝 3禁用
     */
    private Integer status;

    /**
     * 审核备注
     */
    private String auditRemark;

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
     * 用户昵称
     */
    @TableField(exist = false)
    private String nickName;

    /**
     * 用户头像
     */
    @TableField(exist = false)
    private String avatar;

    /**
     * 手机号
     */
    @TableField(exist = false)
    private String phonenumber;

    /**
     * 状态描述
     */
    @TableField(exist = false)
    private String statusDesc;
}
