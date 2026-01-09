package com.oddfar.campus.business.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 微信小程序配置属性
 * 
 * @author jingwen
 */
@Data
@Component
@ConfigurationProperties(prefix = "wechat.mini")
public class WechatMiniProperties {
    
    /**
     * 小程序 AppID
     */
    private String appId;
    
    /**
     * 小程序 AppSecret
     */
    private String appSecret;
    
    /**
     * 登录接口URL
     */
    private String loginUrl = "https://api.weixin.qq.com/sns/jscode2session";
    
    /**
     * 获取AccessToken接口URL
     */
    private String accessTokenUrl = "https://api.weixin.qq.com/cgi-bin/token";
    
    /**
     * 内容安全检查URL
     */
    private String msgSecCheckUrl = "https://api.weixin.qq.com/wxa/msg_sec_check";
}
