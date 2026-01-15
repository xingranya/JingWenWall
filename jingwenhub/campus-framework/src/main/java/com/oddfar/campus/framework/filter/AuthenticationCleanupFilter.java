package com.oddfar.campus.framework.filter;

import com.oddfar.campus.framework.security.context.AuthenticationContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 认证信息清理过滤器
 *
 * 在每次请求结束后清理 ThreadLocal，防止内存泄漏
 *
 * 问题: 线程池环境下，ThreadLocal 可能导致内存泄漏
 * 解决: 在请求结束时自动清理 ThreadLocal
 *
 * @author claude
 * @since 2026-01-16
 */
@Component
public class AuthenticationCleanupFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {
        try {
            filterChain.doFilter(request, response);
        } finally {
            // ✅ 清理 ThreadLocal，防止内存泄漏
            AuthenticationContextHolder.clearContext();
        }
    }
}
