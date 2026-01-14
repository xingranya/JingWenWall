package com.oddfar.campus.business.report.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * 举报实体
 */
@Data
@TableName(value = "bus_report", autoResultMap = true)
public class BusReportEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 举报ID
     */
    @TableId(value = "report_id", type = IdType.ASSIGN_ID)
    private Long reportId;

    /**
     * 举报人ID
     */
    private Long reporterId;

    /**
     * 举报目标类型: 0帖子 1评论 2用户 3商品 4兼职
     */
    private Integer targetType;

    /**
     * 举报目标ID
     */
    private Long targetId;

    /**
     * 举报原因类型
     */
    private String reasonType;

    /**
     * 详细描述
     */
    private String reasonDetail;

    /**
     * 举报截图
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> images;

    /**
     * 状态: 0待处理 1已处理 2已忽略
     */
    private Integer status;

    /**
     * 处理备注
     */
    private String handleRemark;

    /**
     * 处理人ID
     */
    private Long handleUserId;

    /**
     * 处理时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date handleTime;

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

    // ========== 非数据库字段 ==========

    /**
     * 举报人昵称
     */
    @TableField(exist = false)
    private String reporterName;

    /**
     * 举报人头像
     */
    @TableField(exist = false)
    private String reporterAvatar;

    /**
     * 目标类型描述
     */
    @TableField(exist = false)
    private String targetTypeDesc;

    /**
     * 状态描述
     */
    @TableField(exist = false)
    private String statusDesc;
}
