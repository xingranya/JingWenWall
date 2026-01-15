package com.oddfar.campus.business.service;

import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.common.exception.ServiceException;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 学生服务并发测试
 * 验证余额更新的并发安全性
 *
 * @author jingwen
 */
@Slf4j
@SpringBootTest
public class BusStudentServiceTest {

    @Autowired
    private BusStudentService studentService;

    private List<Long> testStudentIds = new ArrayList<>();

    /**
     * 创建测试学生（初始余额100元）
     */
    @BeforeEach
    public void setup() {
        // 创建测试学生
        Long studentId1 = createTestStudent(new BigDecimal("100"));
        Long studentId2 = createTestStudent(new BigDecimal("50"));
        testStudentIds.add(studentId1);
        testStudentIds.add(studentId2);
        log.info("测试环境准备完成，测试学生ID: {}", testStudentIds);
    }

    /**
     * 测试并发扣款场景
     * 场景：3个线程并发扣款50元，初始余额100元
     * 预期：只有1个扣款成功，最终余额50元，其他2个线程因余额不足失败
     */
    @Test
    public void testConcurrentDeduction() throws Exception {
        Long studentId = testStudentIds.get(0);
        BigDecimal initialBalance = new BigDecimal("100");
        BigDecimal deductionAmount = new BigDecimal("-50");

        log.info("=== 开始并发扣款测试 ===");
        log.info("初始余额: {}", initialBalance);

        int threadCount = 3;
        CountDownLatch startLatch = new CountDownLatch(1);
        CountDownLatch endLatch = new CountDownLatch(threadCount);

        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger insufficientCount = new AtomicInteger(0);
        AtomicInteger errorCount = new AtomicInteger(0);

        // 创建并启动3个并发线程
        for (int i = 0; i < threadCount; i++) {
            new Thread(() -> {
                try {
                    // 等待所有线程就绪后同时开始
                    startLatch.await();

                    // 执行扣款操作
                    studentService.updateBalance(studentId, deductionAmount);
                    successCount.incrementAndGet();
                    log.info("扣款成功");

                } catch (ServiceException e) {
                    if (e.getMessage().contains("余额不足")) {
                        insufficientCount.incrementAndGet();
                        log.info("余额不足（符合预期）: {}", e.getMessage());
                    } else {
                        errorCount.incrementAndGet();
                        log.error("业务异常: {}", e.getMessage());
                    }
                } catch (Exception e) {
                    errorCount.incrementAndGet();
                    log.error("系统异常: {}", e.getMessage(), e);
                } finally {
                    endLatch.countDown();
                }
            }).start();
        }

        // 启动所有线程
        startLatch.countDown();

        // 等待所有线程完成（最多10秒）
        boolean finished = endLatch.await(10, java.util.concurrent.TimeUnit.SECONDS);
        assertTrue(finished, "测试超时，线程未能在规定时间内完成");

        // 验证结果
        log.info("=== 测试结果 ===");
        log.info("成功扣款次数: {}", successCount.get());
        log.info("余额不足次数: {}", insufficientCount.get());
        log.info("错误次数: {}", errorCount.get());

        // 断言：只有1个扣款成功
        assertEquals(1, successCount.get(), "应该只有1个扣款成功");

        // 断言：2个因余额不足失败
        assertEquals(2, insufficientCount.get(), "应该有2个因余额不足失败");

        // 断言：最终余额为50元
        BusStudentEntity student = studentService.getById(studentId);
        BigDecimal expectedBalance = new BigDecimal("50");
        assertEquals(expectedBalance, student.getBalance(),
                "最终余额应该是50元，实际是：" + student.getBalance());

        log.info("=== 并发扣款测试通过 ===");
    }

    /**
     * 测试并发充值场景
     * 场景：3个线程并发充值10元，初始余额50元
     * 预期：3个充值都成功，最终余额80元
     */
    @Test
    public void testConcurrentRecharge() throws Exception {
        Long studentId = testStudentIds.get(1);
        BigDecimal initialBalance = new BigDecimal("50");
        BigDecimal rechargeAmount = new BigDecimal("10");

        log.info("=== 开始并发充值测试 ===");
        log.info("初始余额: {}", initialBalance);

        int threadCount = 3;
        CountDownLatch startLatch = new CountDownLatch(1);
        CountDownLatch endLatch = new CountDownLatch(threadCount);

        AtomicInteger successCount = new AtomicInteger(0);

        // 创建并启动3个并发线程
        for (int i = 0; i < threadCount; i++) {
            new Thread(() -> {
                try {
                    startLatch.await();

                    studentService.updateBalance(studentId, rechargeAmount);
                    successCount.incrementAndGet();
                    log.info("充值成功");

                } catch (Exception e) {
                    log.error("充值异常: {}", e.getMessage(), e);
                } finally {
                    endLatch.countDown();
                }
            }).start();
        }

        startLatch.countDown();
        endLatch.await(10, java.util.concurrent.TimeUnit.SECONDS);

        // 验证结果
        log.info("=== 测试结果 ===");
        log.info("成功充值次数: {}", successCount.get());

        assertEquals(3, successCount.get(), "应该有3个充值成功");

        BusStudentEntity student = studentService.getById(studentId);
        BigDecimal expectedBalance = new BigDecimal("80");
        assertEquals(expectedBalance, student.getBalance(),
                "最终余额应该是80元，实际是：" + student.getBalance());

        log.info("=== 并发充值测试通过 ===");
    }

    /**
     * 测试余额不足场景
     * 场景：余额10元，尝试扣款20元
     * 预期：抛出ServiceException，余额不变
     */
    @Test
    public void testInsufficientBalance() {
        Long studentId = createTestStudent(new BigDecimal("10"));

        log.info("=== 开始余额不足测试 ===");

        // 尝试扣款20元，应该失败
        ServiceException exception = assertThrows(ServiceException.class, () -> {
            studentService.updateBalance(studentId, new BigDecimal("-20"));
        });

        assertTrue(exception.getMessage().contains("余额不足"),
                "异常信息应该包含'余额不足'");

        // 验证余额未变
        BusStudentEntity student = studentService.getById(studentId);
        assertEquals(new BigDecimal("10"), student.getBalance(),
                "余额应该保持不变");

        log.info("=== 余额不足测试通过 ===");
    }

    /**
     * 测试学生不存在场景
     * 预期：抛出ServiceException
     */
    @Test
    public void testStudentNotExists() {
        log.info("=== 开始学生不存在测试 ===");

        Long nonExistentId = 999999L;

        ServiceException exception = assertThrows(ServiceException.class, () -> {
            studentService.updateBalance(nonExistentId, new BigDecimal("10"));
        });

        assertTrue(exception.getMessage().contains("学生信息不存在"),
                "异常信息应该包含'学生信息不存在'");

        log.info("=== 学生不存在测试通过 ===");
    }

    /**
     * 测试分布式锁场景
     * 场景：同一个学生快速连续更新余额
     * 预期：第二次操作等待锁释放后成功执行
     */
    @Test
    public void testDistributedLock() throws Exception {
        Long studentId = createTestStudent(new BigDecimal("100"));

        log.info("=== 开始分布式锁测试 ===");

        CountDownLatch latch = new CountDownLatch(2);
        AtomicInteger successCount = new AtomicInteger(0);

        // 两个线程同时操作
        for (int i = 0; i < 2; i++) {
            new Thread(() -> {
                try {
                    studentService.updateBalance(studentId, new BigDecimal("-10"));
                    successCount.incrementAndGet();
                } catch (Exception e) {
                    log.error("操作失败: {}", e.getMessage());
                } finally {
                    latch.countDown();
                }
            }).start();
        }

        latch.await(10, java.util.concurrent.TimeUnit.SECONDS);

        assertEquals(2, successCount.get(), "两个操作都应该成功");

        BusStudentEntity student = studentService.getById(studentId);
        assertEquals(new BigDecimal("80"), student.getBalance(),
                "最终余额应该是80元");

        log.info("=== 分布式锁测试通过 ===");
    }

    /**
     * 创建测试学生的辅助方法
     *
     * @param initialBalance 初始余额
     * @return 学生ID
     */
    private Long createTestStudent(BigDecimal initialBalance) {
        BusStudentEntity student = new BusStudentEntity();
        student.setUserId(0L); // 测试用户
        student.setOpenid("test_openid_" + System.currentTimeMillis());
        student.setUnionid("test_unionid_" + System.currentTimeMillis());
        student.setStudentNo("TEST" + System.currentTimeMillis());
        student.setRealName("测试用户");
        student.setCollege("测试学院");
        student.setMajor("测试专业");
        student.setGrade("2024");
        student.setCreditScore(100);
        student.setBalance(initialBalance);
        student.setIsVerified(0);
        student.setIsRunner(0);
        student.setDelFlag(0);

        studentService.save(student);
        log.info("创建测试学生: studentId={}, balance={}", student.getStudentId(), initialBalance);

        return student.getStudentId();
    }
}
