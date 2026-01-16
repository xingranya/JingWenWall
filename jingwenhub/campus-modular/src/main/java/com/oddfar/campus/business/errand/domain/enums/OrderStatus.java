package com.oddfar.campus.business.errand.domain.enums;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

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

    WAITING(1, "待接单", Arrays.asList(Transition.ACCEPT, Transition.CANCEL)),
    ACCEPTED(2, "已接单", Arrays.asList(Transition.PICK_UP, Transition.CANCEL)),
    PICKING(3, "取货中", Arrays.asList(Transition.DELIVER, Transition.CANCEL)),
    DELIVERING(4, "配送中", Arrays.asList(Transition.CONFIRM, Transition.CANCEL)),
    CONFIRMING(5, "待确认", Arrays.asList(Transition.COMPLETE)),
    COMPLETED(6, "已完成", Collections.emptyList()),
    CANCELLED(7, "已取消", Collections.emptyList());

    private final Integer code;
    private final String desc;
    private final List<Transition> allowedTransitions;

    OrderStatus(Integer code, String desc, List<Transition> allowedTransitions) {
        this.code = code;
        this.desc = desc;
        this.allowedTransitions = allowedTransitions;
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
        return allowedTransitions.stream()
                .anyMatch(t -> t.targetStatus == target);
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

    /**
     * 状态转换定义
     */
    private enum Transition {
        ACCEPT(ACCEPTED),       // 接单: 待接单 -> 已接单
        PICK_UP(PICKING),       // 取货: 已接单 -> 取货中
        DELIVER(DELIVERING),    // 配送: 取货中 -> 配送中
        CONFIRM(CONFIRMING),    // 送达: 配送中 -> 待确认
        COMPLETE(COMPLETED),    // 完成: 待确认 -> 已完成
        CANCEL(CANCELLED);      // 取消: 任意状态 -> 已取消

        final OrderStatus targetStatus;

        Transition(OrderStatus targetStatus) {
            this.targetStatus = targetStatus;
        }
    }
}
