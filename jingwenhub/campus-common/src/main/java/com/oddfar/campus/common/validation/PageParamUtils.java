package com.oddfar.campus.common.validation;

import javax.validation.ConstraintValidator;
import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * 分页参数验证工具
 *
 * 用于限制分页参数的范围,防止恶意用户传入极端值导致OOM
 *
 * @author jingwen
 * @since 2026-01-16
 */
public class PageParamUtils {

    /**
     * 页码最小值
     */
    public static final int MIN_PAGE_NUM = 1;

    /**
     * 页码最大值 (防止深分页)
     */
    public static final int MAX_PAGE_NUM = 10000;

    /**
     * 每页数量最小值
     */
    public static final int MIN_PAGE_SIZE = 1;

    /**
     * 每页数量最大值 (防止OOM)
     */
    public static final int MAX_PAGE_SIZE = 100;

    /**
     * 验证并规范化分页参数
     *
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @throws IllegalArgumentException 参数超出范围
     */
    public static void validate(Integer pageNum, Integer pageSize) {
        if (pageNum != null && (pageNum < MIN_PAGE_NUM || pageNum > MAX_PAGE_NUM)) {
            throw new IllegalArgumentException(
                String.format("页码超出范围,应在%d-%d之间", MIN_PAGE_NUM, MAX_PAGE_NUM));
        }

        if (pageSize != null && (pageSize < MIN_PAGE_SIZE || pageSize > MAX_PAGE_SIZE)) {
            throw new IllegalArgumentException(
                String.format("每页数量超出范围,应在%d-%d之间", MIN_PAGE_SIZE, MAX_PAGE_SIZE));
        }
    }

    /**
     * 验证并返回安全的页码
     *
     * @param pageNum 页码
     * @return 安全的页码(不小于MIN_PAGE_NUM)
     */
    public static int safePageNum(Integer pageNum) {
        if (pageNum == null) {
            return MIN_PAGE_NUM;
        }
        return Math.max(MIN_PAGE_NUM, Math.min(MAX_PAGE_NUM, pageNum));
    }

    /**
     * 验证并返回安全的每页数量
     *
     * @param pageSize 每页数量
     * @return 安全的每页数量(在MIN_PAGE_SIZE到MAX_PAGE_SIZE之间)
     */
    public static int safePageSize(Integer pageSize) {
        if (pageSize == null) {
            return 10; // 默认每页10条
        }
        return Math.max(MIN_PAGE_SIZE, Math.min(MAX_PAGE_SIZE, pageSize));
    }
}
