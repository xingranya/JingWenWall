package com.oddfar.campus.business.report.domain.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 举报DTO
 */
@Data
public class ReportDTO {

    /**
     * 举报目标类型: 0帖子 1评论 2用户 3商品 4兼职
     */
    @NotNull(message = "举报目标类型不能为空")
    private Integer targetType;

    /**
     * 举报目标ID
     */
    @NotNull(message = "举报目标不能为空")
    private Long targetId;

    /**
     * 举报原因类型
     */
    @NotBlank(message = "举报原因不能为空")
    private String reasonType;

    /**
     * 详细描述
     */
    private String reasonDetail;

    /**
     * 举报截图
     */
    private List<String> images;
}
