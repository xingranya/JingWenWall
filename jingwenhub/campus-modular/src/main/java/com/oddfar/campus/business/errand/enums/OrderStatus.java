package com.oddfar.campus.business.errand.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 跑腿订单状态枚举
 */
@Getter
@AllArgsConstructor
public enum OrderStatus {

    WAITING(0, "待接单"),
    ACCEPTED(1, "已接单"),
    PICKING(2, "取件中"),
    DELIVERING(3, "配送中"),
    CONFIRMING(4, "待确认"),
    COMPLETED(5, "已完成"),
    CANCELLED(6, "已取消");

    private final Integer code;
    private final String desc;

    public static OrderStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (OrderStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        return null;
    }
    
    public static String getDescByCode(Integer code) {
        OrderStatus status = fromCode(code);
        return status != null ? status.getDesc() : "未知状态";
    }
}
