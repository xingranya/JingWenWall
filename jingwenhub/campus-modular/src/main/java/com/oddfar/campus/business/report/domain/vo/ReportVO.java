package com.oddfar.campus.business.report.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;
import java.util.List;

/**
 * 举报VO
 */
@Data
public class ReportVO {

    /**
     * 举报ID
     */
    private Long reportId;

    /**
     * 举报人ID
     */
    private Long reporterId;

    /**
     * 举报人昵称
     */
    private String reporterName;

    /**
     * 举报人头像
     */
    private String reporterAvatar;

    /**
     * 举报目标类型
     */
    private Integer targetType;

    /**
     * 目标类型描述
     */
    private String targetTypeDesc;

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
    private List<String> images;

    /**
     * 状态
     */
    private Integer status;

    /**
     * 状态描述
     */
    private String statusDesc;

    /**
     * 处理备注
     */
    private String handleRemark;

    /**
     * 处理时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date handleTime;

    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;
}
