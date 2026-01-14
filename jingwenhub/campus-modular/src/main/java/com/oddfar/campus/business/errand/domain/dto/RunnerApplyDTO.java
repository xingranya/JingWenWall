package com.oddfar.campus.business.errand.domain.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;

/**
 * 骑手认证申请DTO
 */
@Data
public class RunnerApplyDTO {

    /**
     * 真实姓名
     */
    @NotBlank(message = "真实姓名不能为空")
    private String realName;

    /**
     * 身份证号
     */
    @NotBlank(message = "身份证号不能为空")
    @Pattern(regexp = "^[1-9]\\d{5}(18|19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])\\d{3}[\\dXx]$", 
             message = "身份证号格式不正确")
    private String idCard;

    /**
     * 身份证正面照
     */
    @NotBlank(message = "请上传身份证正面照")
    private String idCardFront;

    /**
     * 身份证背面照
     */
    @NotBlank(message = "请上传身份证背面照")
    private String idCardBack;

    /**
     * 学生证照片
     */
    private String studentCard;
}
