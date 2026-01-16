package com.oddfar.campus.business.errand.service;

import com.oddfar.campus.business.errand.domain.entity.BusErrandOrderEntity;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.errand.enums.PayStatus;
import com.oddfar.campus.business.errand.domain.enums.OrderStatus;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.business.service.BusStudentService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 跑腿订单取消退款测试
 *
 * @author jingwen
 */
@Slf4j
@SpringBootTest
@Transactional
public class ErrandOrderCancelRefundTest {

    @Autowired
    private ErrandOrderService errandOrderService;

    @Autowired
    private BusStudentService studentService;

    @Test
    @DisplayName("取消已支付订单 - 应退款到余额")
    @WithMockUser(username = "publisher")
    public void testCancelPaidOrder_ShouldRefundToBalance() {
        // 准备测试数据
        Long orderId = 1L;  // 假设数据库中存在一个已支付的订单
        Long publisherId = 1L;
        BigDecimal initialBalance = new BigDecimal("100.00");
        BigDecimal expectedRefund = new BigDecimal("10.00");

        // 获取用户当前余额
        BusStudentEntity student = studentService.getByUserId(publisherId);
        assertNotNull(student, "学生信息不存在");

        BigDecimal balanceBefore = student.getBalance();
        log.info("退款前余额: {}", balanceBefore);

        // 执行取消订单操作
        String reason = "不想要了";
        errandOrderService.cancelOrder(orderId, reason);

        // 验证退款
        BusStudentEntity updatedStudent = studentService.getByUserId(publisherId);
        BigDecimal balanceAfter = updatedStudent.getBalance();
        log.info("退款后余额: {}", balanceAfter);

        // 验证余额增加了订单金额
        BigDecimal expectedBalance = balanceBefore.add(expectedRefund);
        assertEquals(expectedBalance, balanceAfter, "余额应该增加退款金额");

        // 验证订单状态
        BusErrandOrderEntity cancelledOrder = errandOrderService.getById(orderId);
        assertEquals(OrderStatus.CANCELLED.getCode(), cancelledOrder.getStatus());
        assertEquals(reason, cancelledOrder.getCancelReason());
        assertEquals(PayStatus.PAID.getCode(), cancelledOrder.getPayStatus());
    }

    @Test
    @DisplayName("取消未支付订单 - 不应退款")
    @WithMockUser(username = "publisher")
    public void testCancelUnpaidOrder_ShouldNotRefund() {
        // 准备测试数据
        Long orderId = 2L;  // 假设存在一个未支付的订单
        Long publisherId = 2L;

        // 获取用户当前余额
        BusStudentEntity student = studentService.getByUserId(publisherId);
        assertNotNull(student, "学生信息不存在");

        BigDecimal balanceBefore = student.getBalance();
        log.info("取消前余额: {}", balanceBefore);

        // 执行取消订单操作
        String reason = "不需要了";
        errandOrderService.cancelOrder(orderId, reason);

        // 验证余额未变化
        BusStudentEntity updatedStudent = studentService.getByUserId(publisherId);
        BigDecimal balanceAfter = updatedStudent.getBalance();
        log.info("取消后余额: {}", balanceAfter);

        assertEquals(balanceBefore, balanceAfter, "未支付订单取消时余额不应变化");

        // 验证订单状态
        BusErrandOrderEntity cancelledOrder = errandOrderService.getById(orderId);
        assertEquals(OrderStatus.CANCELLED.getCode(), cancelledOrder.getStatus());
    }

    @Test
    @DisplayName("取消已完成订单 - 应抛出异常")
    @WithMockUser(username = "publisher")
    public void testCancelCompletedOrder_ShouldThrowException() {
        Long orderId = 3L;  // 假设存在一个已完成的订单

        assertThrows(ServiceException.class, () -> {
            errandOrderService.cancelOrder(orderId, "想取消");
        }, "已完成订单不应允许取消");
    }

    @Test
    @DisplayName("取消正在进行中的订单 - 应抛出异常")
    @WithMockUser(username = "publisher")
    public void testCancelInProgressOrder_ShouldThrowException() {
        Long orderId = 4L;  // 假设存在一个进行中的订单

        assertThrows(ServiceException.class, () -> {
            errandOrderService.cancelOrder(orderId, "不想做了");
        }, "进行中的订单不应允许取消");
    }

    @Test
    @DisplayName("非订单发布者取消订单 - 应抛出异常")
    @WithMockUser(username = "other")
    public void testCancelOrderByOtherUser_ShouldThrowException() {
        Long orderId = 1L;  // 属于用户1的订单

        assertThrows(ServiceException.class, () -> {
            errandOrderService.cancelOrder(orderId, "恶意取消");
        }, "非订单发布者不应允许取消");
    }
}
