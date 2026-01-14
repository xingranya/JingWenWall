package com.oddfar.campus.business.domain.auth;

import lombok.Data;

/**
 * 微信小程序LoginBody
 */
@Data
public class WxMPLoginBody {
    /**
     * 用户名
     */
    private String username;

    /**
     * 用户密码
     */
    private String password;

    /**
     * 微信小程序登录返回的code
     */
    private String code;

    /**
     * 用户信息原始数据
     */
    private String rawData;

    /**
     * 签名
     */
    private String signature;

    /**
     * 加密数据
     */
    private String encryptedData;

    /**
     * 偏移量
     */
    private String iv;
}
