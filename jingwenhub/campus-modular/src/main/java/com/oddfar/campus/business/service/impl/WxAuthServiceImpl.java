package com.oddfar.campus.business.service.impl;

import cn.hutool.core.util.IdUtil;
import cn.hutool.http.HttpUtil;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.oddfar.campus.business.config.WechatMiniProperties;
import com.oddfar.campus.business.domain.dto.WxLoginDTO;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.domain.vo.WxLoginVO;
import com.oddfar.campus.business.service.BusStudentService;
import com.oddfar.campus.business.service.WxAuthService;
import com.oddfar.campus.common.core.RedisCache;
import com.oddfar.campus.common.domain.entity.SysUserEntity;
import com.oddfar.campus.common.domain.model.LoginUser;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import com.oddfar.campus.common.utils.StringUtils;
import com.oddfar.campus.framework.service.SysUserService;
import com.oddfar.campus.framework.web.service.TokenService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

/**
 * 微信认证服务实现
 * 
 * @author jingwen
 */
@Slf4j
@Service
public class WxAuthServiceImpl implements WxAuthService {
    
    /** AccessToken 缓存 Key */
    private static final String WX_ACCESS_TOKEN_KEY = "wx:access_token";
    
    /** AccessToken 有效期 (秒) */
    private static final int ACCESS_TOKEN_EXPIRE_TIME = 7000;
    
    @Autowired
    private WechatMiniProperties wechatProperties;
    
    @Autowired
    private BusStudentService busStudentService;
    
    @Autowired
    private SysUserService sysUserService;
    
    @Autowired
    private TokenService tokenService;
    
    @Autowired
    private RedisCache redisCache;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public WxLoginVO wxLogin(WxLoginDTO wxLoginDTO) {
        // 1. 调用微信接口获取 openid 和 session_key
        String code = wxLoginDTO.getCode();
        Map<String, Object> params = new HashMap<>();
        params.put("appid", wechatProperties.getAppId());
        params.put("secret", wechatProperties.getAppSecret());
        params.put("js_code", code);
        params.put("grant_type", "authorization_code");
        
        String response = HttpUtil.get(wechatProperties.getLoginUrl(), params);
        log.info("微信登录响应: {}", response);
        
        JSONObject jsonResult = JSON.parseObject(response);
        
        // 检查错误
        if (jsonResult.containsKey("errcode") && jsonResult.getIntValue("errcode") != 0) {
            log.error("微信登录失败: {}", jsonResult.getString("errmsg"));
            throw new ServiceException("微信登录失败: " + jsonResult.getString("errmsg"));
        }
        
        String openid = jsonResult.getString("openid");
        String unionid = jsonResult.getString("unionid");
        
        if (StringUtils.isEmpty(openid)) {
            throw new ServiceException("获取openid失败");
        }
        
        log.info("微信登录成功, openid: {}", openid);
        
        // 2. 查询是否已存在学生信息
        BusStudentEntity student = busStudentService.getByOpenid(openid);
        boolean isNewUser = (student == null);
        
        SysUserEntity sysUser;
        
        if (isNewUser) {
            // 3. 新用户 - 创建 sys_user 和 bus_student
            sysUser = createWxUser(openid, wxLoginDTO.getNickName(), wxLoginDTO.getAvatarUrl(), wxLoginDTO.getGender());
            student = busStudentService.createStudent(sysUser.getUserId(), openid, unionid);
            log.info("新用户注册成功, userId: {}, studentId: {}", sysUser.getUserId(), student.getStudentId());
        } else {
            // 4. 老用户 - 获取用户信息，更新登录时间
            sysUser = sysUserService.selectUserById(Objects.requireNonNull(student).getUserId());
            if (sysUser == null) {
                throw new ServiceException("用户信息不存在");
            }
            
            // 更新用户昵称和头像 (如果有传入)
            if (StringUtils.isNotEmpty(wxLoginDTO.getNickName()) || StringUtils.isNotEmpty(wxLoginDTO.getAvatarUrl())) {
                if (StringUtils.isNotEmpty(wxLoginDTO.getNickName())) {
                    sysUser.setNickName(wxLoginDTO.getNickName());
                }
                if (StringUtils.isNotEmpty(wxLoginDTO.getAvatarUrl())) {
                    sysUser.setAvatar(wxLoginDTO.getAvatarUrl());
                }
                sysUserService.updateUserProfile(sysUser);
            }
            
            // 更新登录时间
            sysUser.setLoginDate(new Date());
            sysUserService.updateUserProfile(sysUser);
        }
        
        // 5. 生成 JWT Token
        LoginUser loginUser = new LoginUser(sysUser.getUserId(), sysUser, new HashSet<>(), new HashSet<>());
        String token = tokenService.createToken(loginUser);
        
        // 6. 填充学生关联信息
        student.setNickName(sysUser.getNickName());
        student.setAvatar(sysUser.getAvatar());
        student.setPhonenumber(sysUser.getPhonenumber());
        
        // 7. 构建返回结果
        return WxLoginVO.fromStudent(student, token, isNewUser);
    }
    
    @Override
    public String getAccessToken() {
        // 先从缓存获取
        String accessToken = redisCache.getCacheObject(WX_ACCESS_TOKEN_KEY);
        if (StringUtils.isNotEmpty(accessToken)) {
            return accessToken;
        }
        
        // 缓存不存在，请求新的 token
        return refreshAccessToken();
    }
    
    @Override
    public String refreshAccessToken() {
        Map<String, Object> params = new HashMap<>();
        params.put("appid", wechatProperties.getAppId());
        params.put("secret", wechatProperties.getAppSecret());
        params.put("grant_type", "client_credential");
        
        String response = HttpUtil.get(wechatProperties.getAccessTokenUrl(), params);
        JSONObject jsonResult = JSON.parseObject(response);
        
        if (jsonResult.containsKey("errcode") && jsonResult.getIntValue("errcode") != 0) {
            log.error("获取AccessToken失败: {}", jsonResult.getString("errmsg"));
            throw new ServiceException("获取AccessToken失败");
        }
        
        String accessToken = jsonResult.getString("access_token");
        Long expiresIn = jsonResult.getLong("expires_in");
        
        // 存入缓存 (提前100秒过期，避免边界问题)
        redisCache.setCacheObject(WX_ACCESS_TOKEN_KEY, accessToken, 
                ACCESS_TOKEN_EXPIRE_TIME, TimeUnit.SECONDS);
        
        log.info("AccessToken刷新成功, 有效期: {}秒", expiresIn);
        return accessToken;
    }
    
    @Override
    public boolean bindPhone(Long userId, String phoneCode) {
        // 使用 phoneCode 获取手机号
        String accessToken = getAccessToken();
        String url = "https://api.weixin.qq.com/wxa/business/getuserphonenumber?access_token=" + accessToken;
        
        Map<String, Object> params = new HashMap<>();
        params.put("code", phoneCode);
        
        String response = HttpUtil.post(url, JSON.toJSONString(params));
        JSONObject jsonResult = JSON.parseObject(response);
        
        if (jsonResult.getIntValue("errcode") != 0) {
            log.error("获取手机号失败: {}", jsonResult.getString("errmsg"));
            return false;
        }
        
        JSONObject phoneInfo = jsonResult.getJSONObject("phone_info");
        String phoneNumber = phoneInfo.getString("purePhoneNumber");
        
        // 更新用户手机号
        SysUserEntity user = sysUserService.selectUserById(userId);
        user.setPhonenumber(phoneNumber);
        sysUserService.updateUserProfile(user);
        
        log.info("绑定手机号成功, userId: {}, phone: {}", userId, phoneNumber);
        return true;
    }
    
    @Override
    public boolean checkTextContent(String content, String openid, int scene) {
        try {
            String accessToken = getAccessToken();
            String url = wechatProperties.getMsgSecCheckUrl() + "?access_token=" + accessToken;
            
            Map<String, Object> params = new HashMap<>();
            params.put("content", content);
            params.put("version", 2);
            params.put("scene", scene);
            params.put("openid", openid);
            
            String response = HttpUtil.post(url, JSON.toJSONString(params));
            JSONObject jsonResult = JSON.parseObject(response);
            
            if (jsonResult.getIntValue("errcode") == 0) {
                JSONObject result = jsonResult.getJSONObject("result");
                String suggest = result.getString("suggest");
                return "pass".equals(suggest);
            }
            
            return true; // 接口异常时放行
        } catch (Exception e) {
            log.error("内容安全检查异常", e);
            return true; // 异常时放行，避免影响用户体验
        }
    }
    
    /**
     * 创建微信用户 (sys_user)
     */
    private SysUserEntity createWxUser(String openid, String nickName, String avatarUrl, Integer gender) {
        SysUserEntity user = new SysUserEntity();
        
        // 使用 openid 的前16位作为用户名 (确保唯一性)
        String userName = "wx_" + openid.substring(0, Math.min(openid.length(), 16));
        user.setUserName(userName);
        
        // 昵称
        user.setNickName(StringUtils.isNotEmpty(nickName) ? nickName : "微信用户");
        
        // 头像
        if (StringUtils.isNotEmpty(avatarUrl)) {
            user.setAvatar(avatarUrl);
        }
        
        // 性别 (0未知 1男 2女)
        if (gender != null) {
            user.setSex(String.valueOf(gender));
        } else {
            user.setSex("0");
        }
        
        // 随机密码 (微信用户不需要密码登录)
        user.setPassword(SecurityUtils.encryptPassword(IdUtil.fastSimpleUUID()));
        
        // 状态正常
        user.setStatus("0");
        
        // 设置创建时间
        user.setCreateTime(new Date());
        user.setLoginDate(new Date());
        
        // 插入用户
        sysUserService.insertUser(user);
        
        // 分配默认角色 (普通用户)
        // 可以根据需要调整默认角色
        // sysUserService.insertUserAuth(user.getUserId(), new Long[]{2L});
        
        return user;
    }
}
