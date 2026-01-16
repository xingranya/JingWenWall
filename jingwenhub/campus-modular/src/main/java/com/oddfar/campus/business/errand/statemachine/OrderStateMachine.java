package com.oddfar.campus.business.errand.statemachine;

import com.oddfar.campus.business.errand.enums.OrderStatus;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * 跑腿订单状态机
 * 定义订单状态的合法流转路径
 *
 * 状态流转图:
 * WAITING -> ACCEPTED -> PICKING -> DELIVERING -> CONFIRMING -> COMPLETED
 *    |                                                        ^
 *    +--------------------------------------------------------+
 *                          CANCELLED (任意时刻可取消)
 *
 * @author jingwen
 */
@Slf4j
@Component
public class OrderStateMachine {

    /** 状态流转映射表: 当前状态 -> 允许的下一状态集合 */
    private final Map<OrderStatus, Set<OrderStatus>> transitionMap;

    /** 状态流转别名映射 (用于业务场景) */
    private final Map<String, OrderStatusTransition> aliasTransitions;

    public OrderStateMachine() {
        this.transitionMap = new EnumMap<>(OrderStatus.class);
        this.aliasTransitions = new HashMap<>();
        initializeTransitions();
        initializeAliasTransitions();
    }

    /**
     * 初始化状态流转规则
     */
    private void initializeTransitions() {
        // 待接单 -> 已接单
        transitionMap.put(OrderStatus.WAITING, Set.of(OrderStatus.ACCEPTED, OrderStatus.CANCELLED));

        // 已接单 -> 取件中
        transitionMap.put(OrderStatus.ACCEPTED, Set.of(OrderStatus.PICKING, OrderStatus.CANCELLED));

        // 取件中 -> 配送中
        transitionMap.put(OrderStatus.PICKING, Set.of(OrderStatus.DELIVERING, OrderStatus.CANCELLED));

        // 配送中 -> 待确认
        transitionMap.put(OrderStatus.DELIVERING, Set.of(OrderStatus.CONFIRMING));

        // 待确认 -> 已完成
        transitionMap.put(OrderStatus.CONFIRMING, Set.of(OrderStatus.COMPLETED));

        // 已完成 -> 终态
        transitionMap.put(OrderStatus.COMPLETED, Set.of());

        // 已取消 -> 终态
        transitionMap.put(OrderStatus.CANCELLED, Set.of());
    }

    /**
     * 初始化状态流转别名 (用于业务场景映射)
     */
    private void initializeAliasTransitions() {
        // 骑手接单
        aliasTransitions.put("ACCEPT", new OrderStatusTransition(OrderStatus.WAITING, OrderStatus.ACCEPTED));

        // 开始取件
        aliasTransitions.put("PICK_UP", new OrderStatusTransition(OrderStatus.ACCEPTED, OrderStatus.PICKING));

        // 开始配送
        aliasTransitions.put("DELIVER", new OrderStatusTransition(OrderStatus.PICKING, OrderStatus.DELIVERING));

        // 送达待确认
        aliasTransitions.put("CONFIRM", new OrderStatusTransition(OrderStatus.DELIVERING, OrderStatus.CONFIRMING));

        // 完成订单
        aliasTransitions.put("COMPLETE", new OrderStatusTransition(OrderStatus.CONFIRMING, OrderStatus.COMPLETED));

        // 取消订单 (从任意可取消状态)
        aliasTransitions.put("CANCEL", new OrderStatusTransition(null, OrderStatus.CANCELLED));

        // 系统自动完成 (超时自动确认)
        aliasTransitions.put("AUTO_COMPLETE", new OrderStatusTransition(OrderStatus.CONFIRMING, OrderStatus.COMPLETED));

        // 系统自动取消 (超时未接单)
        aliasTransitions.put("AUTO_CANCEL", new OrderStatusTransition(OrderStatus.WAITING, OrderStatus.CANCELLED));
    }

    /**
     * 检查状态流转是否合法
     *
     * @param current 当前状态
     * @param next    下一状态
     * @return true=合法; false=非法
     */
    public boolean canTransition(OrderStatus current, OrderStatus next) {
        if (current == null || next == null) {
            log.warn("状态流转检查失败: 当前状态或下一状态为空");
            return false;
        }

        Set<OrderStatus> allowedStates = transitionMap.get(current);
        if (allowedStates == null) {
            log.warn("状态流转检查失败: 当前状态 {} 未定义流转规则", current);
            return false;
        }

        boolean allowed = allowedStates.contains(next);
        if (!allowed) {
            log.warn("状态流转检查失败: {} -> {} 不在允许的流转路径中", current, next);
        }

        return allowed;
    }

    /**
     * 使用别名检查状态流转是否合法
     *
     * @param current 当前状态
     * @param alias   流转别名
     * @return true=合法; false=非法
     */
    public boolean canTransitionByAlias(OrderStatus current, String alias) {
        OrderStatusTransition transition = aliasTransitions.get(alias);
        if (transition == null) {
            log.warn("状态流转别名不存在: {}", alias);
            return false;
        }

        // 取消订单的特殊处理: 可以从任意非终态状态取消
        if ("CANCEL".equals(alias) || "AUTO_CANCEL".equals(alias)) {
            return !isTerminalState(current);
        }

        // 检查当前状态是否匹配
        if (transition.fromStatus != null && !transition.fromStatus.equals(current)) {
            log.warn("状态流转别名 {} 要求当前状态为 {}, 实际为 {}",
                    alias, transition.fromStatus, current);
            return false;
        }

        return canTransition(current, transition.toStatus);
    }

    /**
     * 使用别名执行状态流转
     *
     * @param current 当前状态
     * @param alias   流转别名
     * @return 下一状态; 如果流转不合法则返回null
     */
    public OrderStatus transitionByAlias(OrderStatus current, String alias) {
        if (!canTransitionByAlias(current, alias)) {
            return null;
        }

        OrderStatusTransition transition = aliasTransitions.get(alias);
        return transition != null ? transition.toStatus : null;
    }

    /**
     * 检查是否是终态 (已完成或已取消)
     *
     * @param status 订单状态
     * @return true=终态; false=非终态
     */
    public boolean isTerminalState(OrderStatus status) {
        return status == OrderStatus.COMPLETED || status == OrderStatus.CANCELLED;
    }

    /**
     * 检查是否可取消
     *
     * @param status 订单状态
     * @return true=可取消; false=不可取消
     */
    public boolean isCancellable(OrderStatus status) {
        return !isTerminalState(status) && status != OrderStatus.CONFIRMING;
    }

    /**
     * 获取状态的允许流转列表
     *
     * @param current 当前状态
     * @return 允许的下一状态集合
     */
    public Set<OrderStatus> getAllowedTransitions(OrderStatus current) {
        return transitionMap.getOrDefault(current, Set.of());
    }

    /**
     * 状态流转记录
     */
    private static class OrderStatusTransition {
        private final OrderStatus fromStatus;
        private final OrderStatus toStatus;

        public OrderStatusTransition(OrderStatus fromStatus, OrderStatus toStatus) {
            this.fromStatus = fromStatus;
            this.toStatus = toStatus;
        }
    }
}
