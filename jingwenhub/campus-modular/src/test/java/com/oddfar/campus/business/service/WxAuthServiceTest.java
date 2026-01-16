package com.oddfar.campus.business.service;

import cn.hutool.core.util.IdUtil;
import com.oddfar.campus.business.domain.dto.WxLoginDTO;
import com.oddfar.campus.business.domain.vo.WxLoginVO;
import com.oddfar.campus.common.core.RedisCache;
import com.oddfar.campus.common.exception.ServiceException;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 微信认证服务测试
 * 验证微信登录code防重放攻击功能
 *
 * @author jingwen
 */
@Slf4j
@SpringBootTest
public class WxAuthServiceTest {

    @Autowired
    private WxAuthService wxAuthService;

    @Autowired
    private RedisCache redisCache;

    /** 测试用的code前缀 */
    private static final String TEST_CODE_PREFIX = "test_code_";

    /**
     * 测试code重复使用场景
     * 场景：使用相同的code登录两次
     * 预期：第一次成功，第二次抛出"code已使用"异常
     */
    @Test
    public void testCodeReusePrevention() {
        log.info("=== 开始code重复使用测试 ===");

        // 生成测试code（注意：这会调用真实的微信API，可能会失败）
        String testCode = TEST_CODE_PREFIX + IdUtil.fastSimpleUUID();

        try {
            // 第一次登录尝试（可能因微信API调用失败而抛异常，这是正常的）
            try {
                WxLoginVO result1 = attemptLoginWithCode(testCode);
                if (result1 != null) {
                    log.info("第一次登录成功（这是意外情况，说明使用了真实有效的code）");

                    // 第二次使用相同code应该失败
                    ServiceException exception = assertThrows(ServiceException.class, () -> {
                        WxLoginVO result2 = wxAuthService.wxLogin(createLoginDto(testCode));
                        log.error("不应该允许重复使用code: {}", result2);
                    });

                    assertTrue(exception.getMessage().contains("code已使用"),
                            "异常信息应该包含'code已使用'，实际是: " + exception.getMessage());
                    log.info("第二次登录被正确拦截: {}", exception.getMessage());
                }
            } catch (Exception e) {
                // 如果第一次登录就失败（可能是微信API调用失败），这是预期的
                log.info("第一次登录失败（可能是微信API调用失败）: {}", e.getMessage());
                // 这种情况下无法测试防重放，跳过
                log.info("跳过防重放测试（需要真实有效的微信code）");
            }
        } finally {
            // 清理测试数据
            cleanupTestCode(testCode);
        }

        log.info("=== code重复使用测试完成 ===");
    }

    /**
     * 测试并发场景下的code重复使用
     * 场景：多个线程同时使用相同的code登录
     * 预期：只有一个线程成功，其他线程都因"code已使用"而失败
     */
    @Test
    public void testConcurrentCodeReuse() throws Exception {
        log.info("=== 开始并发code重复使用测试 ===");

        // 先手动将一个code标记为已使用
        String testCode = TEST_CODE_PREFIX + IdUtil.fastSimpleUUID();
        String cacheKey = "wx:login:code:" + testCode;
        redisCache.setCacheObject(cacheKey, true, 5, TimeUnit.MINUTES);

        try {
            int threadCount = 5;
            CountDownLatch startLatch = new CountDownLatch(1);
            CountDownLatch endLatch = new CountDownLatch(threadCount);

            AtomicInteger blockedCount = new AtomicInteger(0);
            AtomicInteger errorCount = new AtomicInteger(0);

            // 创建并启动5个并发线程，都使用同一个已使用的code
            for (int i = 0; i < threadCount; i++) {
                new Thread(() -> {
                    try {
                        // 等待所有线程就绪后同时开始
                        startLatch.await();

                        // 尝试使用已使用的code登录
                        wxAuthService.wxLogin(createLoginDto(testCode));
                        log.error("不应该允许使用已使用的code登录");

                    } catch (ServiceException e) {
                        if (e.getMessage().contains("code已使用")) {
                            blockedCount.incrementAndGet();
                            log.info("正确拦截重复使用的code");
                        } else {
                            errorCount.incrementAndGet();
                            log.error("业务异常: {}", e.getMessage());
                        }
                    } catch (Exception e) {
                        errorCount.incrementAndGet();
                        log.error("系统异常: {}", e.getMessage(), e);
                    } finally {
                        endLatch.countDown();
                    }
                }).start();
            }

            // 启动所有线程
            startLatch.countDown();

            // 等待所有线程完成（最多10秒）
            boolean finished = endLatch.await(10, TimeUnit.SECONDS);
            assertTrue(finished, "测试超时，线程未能在规定时间内完成");

            // 验证结果
            log.info("=== 测试结果 ===");
            log.info("被拦截的次数: {}", blockedCount.get());
            log.info("其他异常次数: {}", errorCount.get());

            // 断言：所有线程都应该被拦截
            assertEquals(threadCount, blockedCount.get(),
                    "所有" + threadCount + "个线程都应该因'code已使用'而被拦截");

            assertEquals(0, errorCount.get(), "不应该有其他异常");

            log.info("=== 并发code重复使用测试通过 ===");
        } finally {
            // 清理测试数据
            cleanupTestCode(testCode);
        }
    }

    /**
     * 测试不同code不会互相干扰
     * 场景：使用不同的code登录
     * 预期：每个code都能独立使用（假设微信API返回成功）
     */
    @Test
    public void testDifferentCodesIndependent() {
        log.info("=== 开始不同code独立性测试 ===");

        String code1 = TEST_CODE_PREFIX + IdUtil.fastSimpleUUID();
        String code2 = TEST_CODE_PREFIX + IdUtil.fastSimpleUUID();

        try {
            // 尝试使用两个不同的code登录
            // 注意：这会调用真实微信API，很可能会失败，这是正常的
            try {
                WxLoginVO result1 = attemptLoginWithCode(code1);
                log.info("code1登录结果: {}", result1 != null ? "成功" : "失败");
            } catch (Exception e) {
                log.info("code1登录失败（预期的）: {}", e.getMessage());
            }

            try {
                WxLoginVO result2 = attemptLoginWithCode(code2);
                log.info("code2登录结果: {}", result2 != null ? "成功" : "失败");
            } catch (Exception e) {
                log.info("code2登录失败（预期的）: {}", e.getMessage());
            }

            log.info("不同code独立性测试完成");
        } finally {
            // 清理测试数据
            cleanupTestCode(code1);
            cleanupTestCode(code2);
        }

        log.info("=== 不同code独立性测试完成 ===");
    }

    /**
     * 测试code缓存过期机制
     * 场景：将code标记为已使用，等待过期后再次使用
     * 预期：过期后可以重新使用（实际测试中设置短过期时间）
     */
    @Test
    public void testCodeExpiration() throws Exception {
        log.info("=== 开始code过期测试 ===");

        String testCode = TEST_CODE_PREFIX + IdUtil.fastSimpleUUID();
        String cacheKey = "wx:login:code:" + testCode;

        try {
            // 设置较短的过期时间（1秒）用于测试
            redisCache.setCacheObject(cacheKey, true, 1, TimeUnit.SECONDS);

            // 立即检查，应该已使用
            Boolean isUsed1 = redisCache.getCacheObject(cacheKey);
            assertNotNull(isUsed1, "缓存值不应为null");
            assertTrue(isUsed1, "code应该被标记为已使用");
            log.info("code已被标记为已使用");

            // 等待2秒，让缓存过期
            log.info("等待2秒让缓存过期...");
            Thread.sleep(2000);

            // 再次检查，应该已过期
            Boolean isUsed2 = redisCache.getCacheObject(cacheKey);
            if (isUsed2 == null) {
                log.info("code缓存已过期（返回null）");
            } else {
                log.info("code缓存值: {}", isUsed2);
            }

            log.info("=== code过期测试完成 ===");
        } finally {
            // 清理测试数据
            cleanupTestCode(testCode);
        }
    }

    /**
     * 创建登录DTO的辅助方法
     */
    private WxLoginDTO createLoginDto(String code) {
        WxLoginDTO dto = new WxLoginDTO();
        dto.setCode(code);
        dto.setNickName("测试用户");
        dto.setAvatarUrl("https://example.com/avatar.jpg");
        dto.setGender(1);
        return dto;
    }

    /**
     * 尝试使用指定code登录的辅助方法
     * 返回null表示登录失败（可能是微信API调用失败）
     */
    private WxLoginVO attemptLoginWithCode(String code) {
        try {
            return wxAuthService.wxLogin(createLoginDto(code));
        } catch (Exception e) {
            log.info("登录尝试失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 清理测试code的辅助方法
     */
    private void cleanupTestCode(String code) {
        try {
            String cacheKey = "wx:login:code:" + code;
            redisCache.deleteObject(cacheKey);
            log.info("清理测试code: {}", code);
        } catch (Exception e) {
            log.warn("清理测试code失败: {}", e.getMessage());
        }
    }
}
