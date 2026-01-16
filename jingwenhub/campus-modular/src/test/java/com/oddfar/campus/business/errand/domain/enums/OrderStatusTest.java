package com.oddfar.campus.business.errand.domain.enums;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * OrderStatus 状态机单元测试
 */
@DisplayName("订单状态机测试")
class OrderStatusTest {

    @Test
    @DisplayName("正常状态流转: 待接单 -> 已接单")
    void testWaitingToAccepted() {
        OrderStatus current = OrderStatus.WAITING;
        OrderStatus next = OrderStatus.ACCEPTED;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("正常状态流转: 已接单 -> 取货中")
    void testAcceptedToPicking() {
        OrderStatus current = OrderStatus.ACCEPTED;
        OrderStatus next = OrderStatus.PICKING;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("正常状态流转: 取货中 -> 配送中")
    void testPickingToDelivering() {
        OrderStatus current = OrderStatus.PICKING;
        OrderStatus next = OrderStatus.DELIVERING;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("正常状态流转: 配送中 -> 待确认")
    void testDeliveringToConfirming() {
        OrderStatus current = OrderStatus.DELIVERING;
        OrderStatus next = OrderStatus.CONFIRMING;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("正常状态流转: 待确认 -> 已完成")
    void testConfirmingToCompleted() {
        OrderStatus current = OrderStatus.CONFIRMING;
        OrderStatus next = OrderStatus.COMPLETED;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("任意状态可取消: 待接单 -> 已取消")
    void testWaitingToCancelled() {
        OrderStatus current = OrderStatus.WAITING;
        OrderStatus next = OrderStatus.CANCELLED;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("任意状态可取消: 已接单 -> 已取消")
    void testAcceptedToCancelled() {
        OrderStatus current = OrderStatus.ACCEPTED;
        OrderStatus next = OrderStatus.CANCELLED;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("任意状态可取消: 取货中 -> 已取消")
    void testPickingToCancelled() {
        OrderStatus current = OrderStatus.PICKING;
        OrderStatus next = OrderStatus.CANCELLED;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("任意状态可取消: 配送中 -> 已取消")
    void testDeliveringToCancelled() {
        OrderStatus current = OrderStatus.DELIVERING;
        OrderStatus next = OrderStatus.CANCELLED;

        assertTrue(current.canTransitionTo(next));
        assertEquals(next, current.transitionTo(next));
    }

    @Test
    @DisplayName("非法状态流转: 待接单 -> 配送中 (跳过步骤)")
    void testInvalidTransition_WaitingToDelivering() {
        OrderStatus current = OrderStatus.WAITING;
        OrderStatus next = OrderStatus.DELIVERING;

        assertFalse(current.canTransitionTo(next));
        assertThrows(IllegalStateException.class, () -> current.transitionTo(next));
    }

    @Test
    @DisplayName("非法状态流转: 已完成 -> 已接单 (终态无法流转)")
    void testInvalidTransition_CompletedToAccepted() {
        OrderStatus current = OrderStatus.COMPLETED;
        OrderStatus next = OrderStatus.ACCEPTED;

        assertFalse(current.canTransitionTo(next));
        assertThrows(IllegalStateException.class, () -> current.transitionTo(next));
    }

    @Test
    @DisplayName("非法状态流转: 已取消 -> 待接单 (终态无法流转)")
    void testInvalidTransition_CancelledToWaiting() {
        OrderStatus current = OrderStatus.CANCELLED;
        OrderStatus next = OrderStatus.WAITING;

        assertFalse(current.canTransitionTo(next));
        assertThrows(IllegalStateException.class, () -> current.transitionTo(next));
    }

    @Test
    @DisplayName("非法状态流转: 待确认 -> 已取消 (待确认不可取消)")
    void testInvalidTransition_ConfirmingToCancelled() {
        OrderStatus current = OrderStatus.CONFIRMING;
        OrderStatus next = OrderStatus.CANCELLED;

        assertFalse(current.canTransitionTo(next));
        assertThrows(IllegalStateException.class, () -> current.transitionTo(next));
    }

    @Test
    @DisplayName("终态检查: 已完成")
    void testIsTerminalState_Completed() {
        assertTrue(OrderStatus.COMPLETED.isTerminalState());
    }

    @Test
    @DisplayName("终态检查: 已取消")
    void testIsTerminalState_Cancelled() {
        assertTrue(OrderStatus.CANCELLED.isTerminalState());
    }

    @Test
    @DisplayName("终态检查: 待接单 (非终态)")
    void testIsTerminalState_Waiting() {
        assertFalse(OrderStatus.WAITING.isTerminalState());
    }

    @Test
    @DisplayName("可取消性检查: 待接单")
    void testIsCancellable_Waiting() {
        assertTrue(OrderStatus.WAITING.isCancellable());
    }

    @Test
    @DisplayName("可取消性检查: 已接单")
    void testIsCancellable_Accepted() {
        assertTrue(OrderStatus.ACCEPTED.isCancellable());
    }

    @Test
    @DisplayName("可取消性检查: 取货中")
    void testIsCancellable_Picking() {
        assertTrue(OrderStatus.PICKING.isCancellable());
    }

    @Test
    @DisplayName("可取消性检查: 配送中")
    void testIsCancellable_Delivering() {
        assertTrue(OrderStatus.DELIVERING.isCancellable());
    }

    @Test
    @DisplayName("可取消性检查: 待确认 (不可取消)")
    void testIsCancellable_Confirming() {
        assertFalse(OrderStatus.CONFIRMING.isCancellable());
    }

    @Test
    @DisplayName("可取消性检查: 已完成 (终态不可取消)")
    void testIsCancellable_Completed() {
        assertFalse(OrderStatus.COMPLETED.isCancellable());
    }

    @Test
    @DisplayName("可取消性检查: 已取消 (终态不可取消)")
    void testIsCancellable_Cancelled() {
        assertFalse(OrderStatus.CANCELLED.isCancellable());
    }

    @Test
    @DisplayName("fromCode: 正常获取")
    void testFromCode_Success() {
        assertEquals(OrderStatus.WAITING, OrderStatus.fromCode(1));
        assertEquals(OrderStatus.ACCEPTED, OrderStatus.fromCode(2));
        assertEquals(OrderStatus.PICKING, OrderStatus.fromCode(3));
        assertEquals(OrderStatus.DELIVERING, OrderStatus.fromCode(4));
        assertEquals(OrderStatus.CONFIRMING, OrderStatus.fromCode(5));
        assertEquals(OrderStatus.COMPLETED, OrderStatus.fromCode(6));
        assertEquals(OrderStatus.CANCELLED, OrderStatus.fromCode(7));
    }

    @Test
    @DisplayName("fromCode: 无效code")
    void testFromCode_InvalidCode() {
        assertThrows(IllegalArgumentException.class, () -> OrderStatus.fromCode(999));
    }

    @Test
    @DisplayName("fromCode: null值")
    void testFromCode_Null() {
        assertThrows(IllegalArgumentException.class, () -> OrderStatus.fromCode(null));
    }

    @Test
    @DisplayName("getDescByCode: 正常获取")
    void testGetDescByCode_Success() {
        assertEquals("待接单", OrderStatus.getDescByCode(1));
        assertEquals("已接单", OrderStatus.getDescByCode(2));
        assertEquals("已完成", OrderStatus.getDescByCode(6));
        assertEquals("已取消", OrderStatus.getDescByCode(7));
    }

    @Test
    @DisplayName("getDescByCode: 无效code返回默认值")
    void testGetDescByCode_InvalidCode() {
        assertEquals("未知状态", OrderStatus.getDescByCode(999));
    }

    @Test
    @DisplayName("getCode: 获取状态码")
    void testGetCode() {
        assertEquals(1, OrderStatus.WAITING.getCode());
        assertEquals(2, OrderStatus.ACCEPTED.getCode());
        assertEquals(6, OrderStatus.COMPLETED.getCode());
        assertEquals(7, OrderStatus.CANCELLED.getCode());
    }

    @Test
    @DisplayName("getDesc: 获取描述")
    void testGetDesc() {
        assertEquals("待接单", OrderStatus.WAITING.getDesc());
        assertEquals("已接单", OrderStatus.ACCEPTED.getDesc());
        assertEquals("已完成", OrderStatus.COMPLETED.getDesc());
        assertEquals("已取消", OrderStatus.CANCELLED.getDesc());
    }

    @Test
    @DisplayName("完整订单生命周期测试")
    void testCompleteOrderLifecycle() {
        // 模拟完整订单生命周期
        OrderStatus status = OrderStatus.WAITING;
        assertEquals(OrderStatus.WAITING, status);

        // 接单
        status = status.transitionTo(OrderStatus.ACCEPTED);
        assertEquals(OrderStatus.ACCEPTED, status);

        // 取货
        status = status.transitionTo(OrderStatus.PICKING);
        assertEquals(OrderStatus.PICKING, status);

        // 配送
        status = status.transitionTo(OrderStatus.DELIVERING);
        assertEquals(OrderStatus.DELIVERING, status);

        // 送达
        status = status.transitionTo(OrderStatus.CONFIRMING);
        assertEquals(OrderStatus.CONFIRMING, status);

        // 完成
        status = status.transitionTo(OrderStatus.COMPLETED);
        assertEquals(OrderStatus.COMPLETED, status);

        // 验证终态
        assertTrue(status.isTerminalState());
        assertFalse(status.isCancellable());
    }

    @Test
    @DisplayName("取消订单生命周期测试")
    void testCancelledOrderLifecycle() {
        // 模拟取消订单流程
        OrderStatus status = OrderStatus.WAITING;

        // 接单
        status = status.transitionTo(OrderStatus.ACCEPTED);
        assertEquals(OrderStatus.ACCEPTED, status);

        // 取消
        status = status.transitionTo(OrderStatus.CANCELLED);
        assertEquals(OrderStatus.CANCELLED, status);

        // 验证终态
        assertTrue(status.isTerminalState());
        assertFalse(status.isCancellable());
    }

    @Test
    @DisplayName("非法流转异常消息")
    void testTransitionTo_ExceptionMessage() {
        IllegalStateException exception = assertThrows(
                IllegalStateException.class,
                () -> OrderStatus.WAITING.transitionTo(OrderStatus.COMPLETED)
        );

        assertTrue(exception.getMessage().contains("不允许的状态转换"));
        assertTrue(exception.getMessage().contains("待接单"));
        assertTrue(exception.getMessage().contains("已完成"));
    }

    @Test
    @DisplayName("canTransitionTo: null目标状态")
    void testCanTransitionTo_NullTarget() {
        assertFalse(OrderStatus.WAITING.canTransitionTo(null));
    }

    @Test
    @DisplayName("状态转换组合: 取货中可转为配送中或已取消")
    void testPickingTransitions() {
        OrderStatus picking = OrderStatus.PICKING;

        // 可以转配送中
        assertTrue(picking.canTransitionTo(OrderStatus.DELIVERING));

        // 可以转已取消
        assertTrue(picking.canTransitionTo(OrderStatus.CANCELLED));

        // 不能转其他状态
        assertFalse(picking.canTransitionTo(OrderStatus.WAITING));
        assertFalse(picking.canTransitionTo(OrderStatus.ACCEPTED));
        assertFalse(picking.canTransitionTo(OrderStatus.CONFIRMING));
        assertFalse(picking.canTransitionTo(OrderStatus.COMPLETED));
    }

    @Test
    @DisplayName("状态转换组合: 已完成无后续状态")
    void testCompletedNoTransitions() {
        OrderStatus completed = OrderStatus.COMPLETED;

        // 终态无法转换到任何状态
        assertFalse(completed.canTransitionTo(OrderStatus.WAITING));
        assertFalse(completed.canTransitionTo(OrderStatus.ACCEPTED));
        assertFalse(completed.canTransitionTo(OrderStatus.PICKING));
        assertFalse(completed.canTransitionTo(OrderStatus.DELIVERING));
        assertFalse(completed.canTransitionTo(OrderStatus.CONFIRMING));
        assertFalse(completed.canTransitionTo(OrderStatus.CANCELLED));
        assertFalse(completed.canTransitionTo(OrderStatus.COMPLETED));
    }
}
