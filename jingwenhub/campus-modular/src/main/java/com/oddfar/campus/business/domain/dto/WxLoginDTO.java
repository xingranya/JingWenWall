package com.oddfar.campus.business.domain.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 微信小程序登录请求DTO
 * 
 * @author jingwen
 */
@Data
public class WxLoginDTO {
    
    /**
     * 微信临时登录凭证 code
     */
    @NotBlank(message = "code不能为空")
    private String code;
    
    /**
     * 加密数据 (获取手机号时需要)
     */
    private String encryptedData;
    
    /**
     * 加密算法初始向量
     */
    private String iv;
    
    /**
     * 用户昵称
     */
    private String nickName;
    
    /**
     * 用户头像URL
     */
    private String avatarUrl;
    
    /**
     * 性别 (0未知 1男 2女)
     */
    private Integer gender;
}
