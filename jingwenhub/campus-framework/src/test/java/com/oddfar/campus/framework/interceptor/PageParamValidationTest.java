package com.oddfar.campus.framework.interceptor;

import com.oddfar.campus.common.validation.PageParamUtils;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 分页参数验证测试
 *
 * @author jingwen
 * @since 2026-01-16
 */
@Slf4j
public class PageParamValidationTest {

    @Test
    @DisplayName("正常分页参数 - 应该通过验证")
    public void testValidPageParams() {
        // 正常参数
        assertDoesNotThrow(() -> PageParamUtils.validate(1, 10));
        assertDoesNotThrow(() -> PageParamUtils.validate(100, 20));
        assertDoesNotThrow(() -> PageParamUtils.validate(10000, 100));

        // 边界值
        assertDoesNotThrow(() -> PageParamUtils.validate(1, 1));
        assertDoesNotThrow(() -> PageParamUtils.validate(10000, 100));
    }

    @Test
    @DisplayName("pageNum 为 0 - 应该抛出异常")
    public void testPageNumZero() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> PageParamUtils.validate(0, 10)
        );
        assertTrue(exception.getMessage().contains("页码超出范围"));
        log.info("异常信息: {}", exception.getMessage());
    }

    @Test
    @DisplayName("pageNum 为负数 - 应该抛出异常")
    public void testPageNumNegative() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> PageParamUtils.validate(-1, 10)
        );
        assertTrue(exception.getMessage().contains("页码超出范围"));
        log.info("异常信息: {}", exception.getMessage());
    }

    @Test
    @DisplayName("pageNum 超过最大值 - 应该抛出异常")
    public void testPageNumExceedsMax() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> PageParamUtils.validate(10001, 10)
        );
        assertTrue(exception.getMessage().contains("页码超出范围"));
        log.info("异常信息: {}", exception.getMessage());
    }

    @Test
    @DisplayName("pageSize 为 0 - 应该抛出异常")
    public void testPageSizeZero() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> PageParamUtils.validate(1, 0)
        );
        assertTrue(exception.getMessage().contains("每页数量超出范围"));
        log.info("异常信息: {}", exception.getMessage());
    }

    @Test
    @DisplayName("pageSize 为负数 - 应该抛出异常")
    public void testPageSizeNegative() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> PageParamUtils.validate(1, -1)
        );
        assertTrue(exception.getMessage().contains("每页数量超出范围"));
        log.info("异常信息: {}", exception.getMessage());
    }

    @Test
    @DisplayName("pageSize 超过最大值 - 应该抛出异常")
    public void testPageSizeExceedsMax() {
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> PageParamUtils.validate(1, 101)
        );
        assertTrue(exception.getMessage().contains("每页数量超出范围"));
        log.info("异常信息: {}", exception.getMessage());
    }

    @Test
    @DisplayName("pageSize 为极大值 - 应该抛出异常")
    public void testPageSizeHugeValue() {
        // 测试恶意传入极大值 (可能导致 OOM)
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> PageParamUtils.validate(1, 999999)
        );
        assertTrue(exception.getMessage().contains("每页数量超出范围"));
        log.info("异常信息: {}", exception.getMessage());
    }

    @Test
    @DisplayName("参数为 null - 应该通过验证")
    public void testNullParams() {
        // null 参数表示不传分页,应该通过
        assertDoesNotThrow(() -> PageParamUtils.validate(null, null));
        assertDoesNotThrow(() -> PageParamUtils.validate(null, 10));
        assertDoesNotThrow(() -> PageParamUtils.validate(1, null));
    }

    @Test
    @DisplayName("safePageNum - 应该返回安全值")
    public void testSafePageNum() {
        // 正常值
        assertEquals(10, PageParamUtils.safePageNum(10));

        // null 应返回默认值
        assertEquals(1, PageParamUtils.safePageNum(null));

        // 小于最小值应返回最小值
        assertEquals(1, PageParamUtils.safePageNum(0));
        assertEquals(1, PageParamUtils.safePageNum(-100));

        // 大于最大值应返回最大值
        assertEquals(10000, PageParamUtils.safePageNum(10001));
        assertEquals(10000, PageParamUtils.safePageNum(99999));
    }

    @Test
    @DisplayName("safePageSize - 应该返回安全值")
    public void testSafePageSize() {
        // 正常值
        assertEquals(20, PageParamUtils.safePageSize(20));

        // null 应返回默认值 10
        assertEquals(10, PageParamUtils.safePageSize(null));

        // 小于最小值应返回最小值
        assertEquals(1, PageParamUtils.safePageSize(0));
        assertEquals(1, PageParamUtils.safePageSize(-50));

        // 大于最大值应返回最大值
        assertEquals(100, PageParamUtils.safePageSize(101));
        assertEquals(100, PageParamUtils.safePageSize(9999));
    }
}
