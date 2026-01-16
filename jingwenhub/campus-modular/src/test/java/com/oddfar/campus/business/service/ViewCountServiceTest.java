package com.oddfar.campus.business.service;

import com.oddfar.campus.common.service.ViewCountService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

/**
 * ViewCountService 并发测试
 * 验证Redis浏览量计数的线程安全性和准确性
 */
@SpringBootTest
public class ViewCountServiceTest {

    @Autowired
    private ViewCountService viewCountService;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    private static final String TEST_RESOURCE_TYPE = "post";
    private static final Long TEST_RESOURCE_ID = 999999L;
    private static final String TEST_KEY = "view:count:post:999999";

    @Test
    public void testIncrementViewCount() {
        // 清理测试数据
        redisTemplate.delete(TEST_KEY);

        // 执行增加浏览量
        viewCountService.incrementViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);

        // 验证Redis中的值
        Integer count = viewCountService.getViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
        assertNotNull(count);
        assertEquals(1, count);

        // 再次增加
        viewCountService.incrementViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
        count = viewCountService.getViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
        assertEquals(2, count);

        // 清理测试数据
        redisTemplate.delete(TEST_KEY);
    }

    @Test
    public void testConcurrentIncrement() throws InterruptedException {
        // 清理测试数据
        redisTemplate.delete(TEST_KEY);

        int threadCount = 100;
        int incrementsPerThread = 10;
        int expectedTotal = threadCount * incrementsPerThread;

        ExecutorService executorService = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);
        AtomicInteger successCount = new AtomicInteger(0);

        // 并发执行浏览量增加
        for (int i = 0; i < threadCount; i++) {
            executorService.submit(() -> {
                try {
                    for (int j = 0; j < incrementsPerThread; j++) {
                        viewCountService.incrementViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
                    }
                    successCount.incrementAndGet();
                } finally {
                    latch.countDown();
                }
            });
        }

        // 等待所有线程完成
        latch.await(10, TimeUnit.SECONDS);
        executorService.shutdown();

        // 验证所有线程都成功执行
        assertEquals(threadCount, successCount.get());

        // 等待Redis操作完成
        Thread.sleep(1000);

        // 验证最终浏览量
        Integer finalCount = viewCountService.getViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
        assertNotNull(finalCount);
        assertEquals(expectedTotal, finalCount,
                "并发增加浏览量后，总数应为 " + expectedTotal + "，实际为 " + finalCount);

        // 清理测试数据
        redisTemplate.delete(TEST_KEY);
    }

    @Test
    public void testConcurrentDifferentResources() throws InterruptedException {
        // 清理测试数据
        for (long i = 1; i <= 10; i++) {
            redisTemplate.delete("view:count:post:" + i);
        }

        int threadCount = 50;
        ExecutorService executorService = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);

        // 并发对不同资源增加浏览量
        for (int i = 0; i < threadCount; i++) {
            final long resourceId = (i % 10) + 1; // 资源ID 1-10
            executorService.submit(() -> {
                try {
                    for (int j = 0; j < 20; j++) {
                        viewCountService.incrementViewCount(TEST_RESOURCE_TYPE, resourceId);
                    }
                } finally {
                    latch.countDown();
                }
            });
        }

        // 等待所有线程完成
        latch.await(10, TimeUnit.SECONDS);
        executorService.shutdown();

        // 验证每个资源的浏览量
        for (long resourceId = 1; resourceId <= 10; resourceId++) {
            Integer count = viewCountService.getViewCount(TEST_RESOURCE_TYPE, resourceId);
            assertNotNull(count);
            // 每个资源应被 5 个线程（50/10）各增加 20 次
            assertEquals(100, count,
                    "资源 " + resourceId + " 的浏览量应为 100，实际为 " + count);
            // 清理
            redisTemplate.delete("view:count:post:" + resourceId);
        }
    }

    @Test
    public void testKeyExpiration() throws InterruptedException {
        // 清理测试数据
        redisTemplate.delete(TEST_KEY);

        // 增加浏览量
        viewCountService.incrementViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);

        // 验证键存在
        Long ttl = redisTemplate.getExpire(TEST_KEY, TimeUnit.DAYS);
        assertTrue(ttl > 0 && ttl <= 7, "TTL应在1-7天之间，实际为 " + ttl + " 天");

        // 验证可以获取值
        Integer count = viewCountService.getViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
        assertNotNull(count);
        assertEquals(1, count);

        // 清理测试数据
        redisTemplate.delete(TEST_KEY);
    }

    @Test
    public void testGetNonExistentViewCount() {
        // 查询不存在的资源浏览量
        Integer count = viewCountService.getViewCount("nonexistent", 99999999L);
        assertNull(count);
    }

    @Test
    public void testHighConcurrencyStress() throws InterruptedException {
        // 清理测试数据
        redisTemplate.delete(TEST_KEY);

        int threadCount = 500;
        int incrementsPerThread = 100;
        int expectedTotal = threadCount * incrementsPerThread;

        ExecutorService executorService = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);

        long startTime = System.currentTimeMillis();

        // 高并发测试
        for (int i = 0; i < threadCount; i++) {
            executorService.submit(() -> {
                try {
                    for (int j = 0; j < incrementsPerThread; j++) {
                        viewCountService.incrementViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
                    }
                } finally {
                    latch.countDown();
                }
            });
        }

        // 等待所有线程完成
        latch.await(30, TimeUnit.SECONDS);
        executorService.shutdown();

        long endTime = System.currentTimeMillis();
        System.out.println("高并发测试完成，耗时: " + (endTime - startTime) + "ms");

        // 等待Redis操作完成
        Thread.sleep(2000);

        // 验证最终浏览量
        Integer finalCount = viewCountService.getViewCount(TEST_RESOURCE_TYPE, TEST_RESOURCE_ID);
        assertNotNull(finalCount);
        assertEquals(expectedTotal, finalCount,
                "高并发测试：浏览量应为 " + expectedTotal + "，实际为 " + finalCount);

        // 清理测试数据
        redisTemplate.delete(TEST_KEY);
    }
}
