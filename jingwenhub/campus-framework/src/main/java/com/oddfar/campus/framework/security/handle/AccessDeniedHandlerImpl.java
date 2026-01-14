package com.oddfar.campus.framework.security.handle;

import com.alibaba.fastjson2.JSON;
import com.oddfar.campus.common.constant.HttpStatus;
import com.oddfar.campus.common.domain.R;
import com.oddfar.campus.common.utils.ServletUtils;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 自定义访问无权限资源时的处理器
 * 
 * @author ruoyi
 */
@Component
public class AccessDeniedHandlerImpl implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {
        int code = HttpStatus.FORBIDDEN;
        String msg = "没有权限，请联系管理员授权";
        ServletUtils.renderString(response, JSON.toJSONString(R.error(code, msg)));
    }
}
