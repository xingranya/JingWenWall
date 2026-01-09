package com.oddfar.campus.business.service;

import com.oddfar.campus.business.domain.dto.WxLoginDTO;
import com.oddfar.campus.business.domain.vo.WxLoginVO;

/**
 * 微信认证服务接口
 * 
 * @author jingwen
 */
public interface WxAuthService {
    
    /**
     * 微信小程序登录
     * 
     * @param wxLoginDTO 登录请求
     * @return 登录结果 (含 token)
     */
    WxLoginVO wxLogin(WxLoginDTO wxLoginDTO);
    
    /**
     * 获取微信 AccessToken
     * 
     * @return accessToken
     */
    String getAccessToken();
    
    /**
     * 刷新 AccessToken (Token过期时调用)
     * 
     * @return 新的 accessToken
     */
    String refreshAccessToken();
    
    /**
     * 绑定手机号
     * 
     * @param userId 用户ID
     * @param phoneCode 手机号获取凭证
     * @return 是否成功
     */
    boolean bindPhone(Long userId, String phoneCode);
    
    /**
     * 检查文本内容安全性
     * 
     * @param content 文本内容
     * @param openid 用户openid
     * @param scene 场景值 (1资料 2评论 3论坛)
     * @return true-安全 false-不安全
     */
    boolean checkTextContent(String content, String openid, int scene);
}
