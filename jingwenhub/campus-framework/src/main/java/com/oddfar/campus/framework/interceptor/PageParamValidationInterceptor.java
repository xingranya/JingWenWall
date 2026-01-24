package com.oddfar.campus.framework.interceptor;

import com.oddfar.campus.common.validation.PageParamUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 分页参数验证拦截器
 *
 * 自动验证所有包含pageNum或pageSize参数的请求
 * 防止恶意用户传入极端值导致OOM
 *
 * @author jingwen
 * @since 2026-01-16
 */
@Slf4j
@Component
public class PageParamValidationInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
            @NonNull Object handler) throws Exception {
        // 获取请求参数
        String pageNumStr = request.getParameter("pageNum");
        String pageSizeStr = request.getParameter("pageSize");

        // 如果请求不包含分页参数,直接放行
        if (pageNumStr == null && pageSizeStr == null) {
            return true;
        }

        try {
            // 解析参数
            Integer pageNum = pageNumStr != null ? Integer.parseInt(pageNumStr) : null;
            Integer pageSize = pageSizeStr != null ? Integer.parseInt(pageSizeStr) : null;

            // 验证参数
            PageParamUtils.validate(pageNum, pageSize);

            log.debug("分页参数验证通过: pageNum={}, pageSize={}", pageNum, pageSize);
            return true;

        } catch (NumberFormatException e) {
            log.warn("分页参数格式错误: pageNum={}, pageSize={}", pageNumStr, pageSizeStr);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":400,\"msg\":\"分页参数格式错误\"}");
            return false;

        } catch (IllegalArgumentException e) {
            log.warn("分页参数超出范围: {}", e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":400,\"msg\":\"" + e.getMessage() + "\"}");
            return false;
        }
    }
}
