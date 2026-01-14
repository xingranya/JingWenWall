package com.oddfar.campus.business.errand.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 跑腿订单类型枚举
 */
@Getter
@AllArgsConstructor
public enum ErrandType {

    EXPRESS(0, "取快递"),
    FOOD(1, "代买餐"),
    SEND_EXPRESS(2, "寄快递"),
    QUEUE(3, "排队"),
    OTHER(4, "其他");

    private final Integer code;
    private final String desc;

    public static ErrandType fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (ErrandType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        return null;
    }
    
    public static String getDescByCode(Integer code) {
        ErrandType type = fromCode(code);
        return type != null ? type.getDesc() : "其他";
    }
}
