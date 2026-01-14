package com.oddfar.campus.business.errand.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 骑手信息VO
 */
@Data
public class RunnerVO {

    /**
     * 骑手ID
     */
    private Long runnerId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 用户昵称
     */
    private String nickName;

    /**
     * 用户头像
     */
    private String avatar;

    /**
     * 手机号
     */
    private String phonenumber;

    /**
     * 真实姓名 (脱敏)
     */
    private String realName;

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
     * 状态描述
     */
    private String statusDesc;

    /**
     * 审核备注
     */
    private String auditRemark;

    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;
}
