package com.oddfar.campus.business.market.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 二手商品状态枚举
 */
@Getter
@AllArgsConstructor
public enum MarketItemStatus {

    PENDING(0, "待审核"),
    ON_SALE(1, "在售"),
    SOLD(2, "已售"),
    OFF_SHELF(3, "已下架");

    private final Integer code;
    private final String desc;

    public static MarketItemStatus fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        for (MarketItemStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        return null;
    }
    
    public static String getDescByCode(Integer code) {
        MarketItemStatus status = fromCode(code);
        return status != null ? status.getDesc() : "未知状态";
    }
}
