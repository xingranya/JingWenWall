package com.oddfar.campus.business.errand.domain.enums;

import java.util.Arrays;
import java.util.Collections;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * 跑腿订单状态枚举 (内置状态机)
 *
 * 状态流转图:
 * WAITING(1) -> ACCEPTED(2) -> PICKING(3) -> DELIVERING(4) -> CONFIRMING(5) -> COMPLETED(6)
 *     |                                                                        ^
 *     +------------------------------------------------------------------------+
 *                           CANCELLED(7) (任意时刻可取消)
 */
public enum OrderStatus {

    WAITING(1, "待接单"),
    ACCEPTED(2, "已接单"),
    PICKING(3, "取货中"),
    DELIVERING(4, "配送中"),
    CONFIRMING(5, "待确认"),
    COMPLETED(6, "已完成"),
    CANCELLED(7, "已取消");

    private final Integer code;
    private final String desc;
    private static final Map<OrderStatus, List<OrderStatus>> TRANSITIONS = new EnumMap<>(OrderStatus.class);

    static {
        TRANSITIONS.put(WAITING, Arrays.asList(ACCEPTED, CANCELLED));
        TRANSITIONS.put(ACCEPTED, Arrays.asList(PICKING, CANCELLED));
        TRANSITIONS.put(PICKING, Arrays.asList(DELIVERING, CANCELLED));
        TRANSITIONS.put(DELIVERING, Arrays.asList(CONFIRMING, CANCELLED));
        TRANSITIONS.put(CONFIRMING, Arrays.asList(COMPLETED));
        TRANSITIONS.put(COMPLETED, Collections.emptyList());
        TRANSITIONS.put(CANCELLED, Collections.emptyList());
    }

    OrderStatus(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public Integer getCode() {
        return code;
    }

    public String getDesc() {
        return desc;
    }

    /**
     * 检查是否可以转换到目标状态
     *
     * @param target 目标状态
     * @return true=可以转换; false=不可以转换
     */
    public boolean canTransitionTo(OrderStatus target) {
        if (target == null) {
            return false;
        }
        List<OrderStatus> allowed = TRANSITIONS.getOrDefault(this, Collections.emptyList());
        return allowed.contains(target);
    }

    /**
     * 执行状态转换 (如果不合法则抛出异常)
     *
     * @param target 目标状态
     * @return 目标状态
     * @throws IllegalStateException 如果状态转换不合法
     */
    public OrderStatus transitionTo(OrderStatus target) {
        if (!canTransitionTo(target)) {
            throw new IllegalStateException(
                    String.format("不允许的状态转换: %s(%d) -> %s(%d)",
                            this.desc, this.code, target.desc, target.code));
        }
        return target;
    }

    /**
     * 检查是否是终态 (已完成或已取消)
     *
     * @return true=终态; false=非终态
     */
    public boolean isTerminalState() {
        return this == COMPLETED || this == CANCELLED;
    }

    /**
     * 检查是否可取消
     *
     * @return true=可取消; false=不可取消
     */
    public boolean isCancellable() {
        return !isTerminalState() && this != CONFIRMING;
    }

    /**
     * 根据code获取枚举
     *
     * @param code 状态码
     * @return OrderStatus枚举
     * @throws IllegalArgumentException 如果code无效
     */
    public static OrderStatus fromCode(Integer code) {
        if (code == null) {
            throw new IllegalArgumentException("订单状态码不能为空");
        }
        for (OrderStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("无效的订单状态码: " + code);
    }

    /**
     * 根据code获取描述
     *
     * @param code 状态码
     * @return 状态描述
     */
    public static String getDescByCode(Integer code) {
        try {
            return fromCode(code).getDesc();
        } catch (IllegalArgumentException e) {
            return "未知状态";
        }
    }

}
