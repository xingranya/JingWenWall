package com.oddfar.campus.business.report.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 举报目标类型枚举
 */
@Getter
@AllArgsConstructor
public enum ReportTargetType {

    POST(0, "帖子"),
    COMMENT(1, "评论"),
    USER(2, "用户"),
    ITEM(3, "商品"),
    JOB(4, "兼职");

    private final Integer code;
    private final String desc;

    public static String getDescByCode(Integer code) {
        if (code == null) return "未知";
        for (ReportTargetType type : values()) {
            if (type.code.equals(code)) {
                return type.getDesc();
            }
        }
        return "未知";
    }
}
