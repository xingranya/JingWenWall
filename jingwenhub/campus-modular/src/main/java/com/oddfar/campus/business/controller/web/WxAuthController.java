package com.oddfar.campus.business.controller.web;

import com.oddfar.campus.business.domain.dto.WxLoginDTO;
import com.oddfar.campus.business.domain.vo.WxLoginVO;
import com.oddfar.campus.business.service.WxAuthService;
import com.oddfar.campus.common.annotation.Anonymous;
import com.oddfar.campus.common.domain.R;
import com.oddfar.campus.common.utils.SecurityUtils;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 微信认证控制器
 * 
 * @author jingwen
 */
@Api(tags = "微信认证")
@RestController
@RequestMapping("/api/v1/wx/auth")
public class WxAuthController {
    
    @Autowired
    private WxAuthService wxAuthService;
    
    /**
     * 微信小程序登录
     */
    @Anonymous
    @ApiOperation("微信小程序登录")
    @PostMapping("/login")
    public R login(@RequestBody @Validated WxLoginDTO wxLoginDTO) {
        WxLoginVO loginVO = wxAuthService.wxLogin(wxLoginDTO);
        return R.ok(loginVO);
    }
    
    /**
     * 绑定手机号
     */
    @ApiOperation("绑定手机号")
    @PostMapping("/bindPhone")
    public R bindPhone(@RequestParam String phoneCode) {
        Long userId = SecurityUtils.getUserId();
        boolean success = wxAuthService.bindPhone(userId, phoneCode);
        return success ? R.ok() : R.error("绑定失败");
    }
    
    /**
     * 获取当前用户信息
     */
    @ApiOperation("获取当前用户信息")
    @GetMapping("/userInfo")
    public R getUserInfo() {
        Long userId = SecurityUtils.getUserId();
        // 返回当前登录用户的详细信息
        return R.ok(SecurityUtils.getLoginUser());
    }
    
    /**
     * 检查文本内容安全性 (测试用)
     */
    @ApiOperation("检查文本内容安全性")
    @PostMapping("/checkText")
    public R checkText(@RequestParam String content, @RequestParam(defaultValue = "3") int scene) {
        Long userId = SecurityUtils.getUserId();
        // 需要获取用户的openid，这里简化处理
        boolean safe = wxAuthService.checkTextContent(content, "", scene);
        return R.ok(safe);
    }
}
