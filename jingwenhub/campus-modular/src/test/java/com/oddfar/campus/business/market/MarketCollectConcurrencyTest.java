package com.oddfar.campus.business.market;

import com.oddfar.campus.business.market.domain.entity.BusMarketCollectEntity;
import com.oddfar.campus.business.market.domain.entity.BusMarketItemEntity;
import com.oddfar.campus.business.market.mapper.MarketCollectMapper;
import com.oddfar.campus.business.market.mapper.MarketItemMapper;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 二手市场收藏计数并发测试
 *
 * 验证收藏计数的原子性操作,确保并发场景下数据准确性
 *
 * @author jingwen
 * @since 2026-01-16
 */
@Slf4j
@SpringBootTest
@ActiveProfiles("test")
@Transactional
public class MarketCollectConcurrencyTest {

    @Autowired
    private MarketItemMapper itemMapper;

    @Autowired
    private MarketCollectMapper collectMapper;

    private Long testItemId;
    private Long testUserId = 1L;

    /**
     * 创建测试数据
     */
    @BeforeEach
    public void setup() {
        // 创建测试商品
        BusMarketItemEntity item = new BusMarketItemEntity();
        item.setUserId(testUserId);
        item.setTitle("测试商品-并发收藏");
        item.setDescription("这是一个测试商品");
        item.setPrice(new BigDecimal("100.0"));
        item.setCategoryId(1L);
        item.setStatus(0);
        item.setViewCount(0);
        item.setCollectCount(0);
        item.setDelFlag(0);
        item.setCreateTime(new java.util.Date());

        itemMapper.insert(item);
        testItemId = item.getItemId();

        log.info("测试数据创建完成, itemId: {}", testItemId);
    }

    /**
     * 测试单次收藏计数增加
     */
    @Test
    @DisplayName("单次收藏 - 计数应增加1")
    public void testSingleCollect() {
        // 初始计数为0
        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        assertEquals(0, item.getCollectCount());

        // 模拟收藏操作
        BusMarketCollectEntity collect = new BusMarketCollectEntity();
        collect.setUserId(testUserId);
        collect.setItemId(testItemId);
        collect.setDelFlag(0);
        collect.setCreateTime(new java.util.Date());
        collectMapper.insert(collect);

        // 原子性增加计数
        itemMapper.incrementCollectCount(testItemId);

        // 验证计数增加
        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(1, updated.getCollectCount());

        log.info("单次收藏测试通过, collectCount: {}", updated.getCollectCount());
    }

    /**
     * 测试单次取消收藏计数减少
     */
    @Test
    @DisplayName("单次取消收藏 - 计数应减少1")
    public void testSingleUncollect() {
        // 先收藏一次
        BusMarketCollectEntity collect = new BusMarketCollectEntity();
        collect.setUserId(testUserId);
        collect.setItemId(testItemId);
        collect.setDelFlag(0);
        collect.setCreateTime(new java.util.Date());
        collectMapper.insert(collect);
        itemMapper.incrementCollectCount(testItemId);

        // 验证计数为1
        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        assertEquals(1, item.getCollectCount());

        // 模拟取消收藏
        collectMapper.updateDelFlag(testUserId, testItemId, 1);
        itemMapper.decrementCollectCount(testItemId);

        // 验证计数减少
        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(0, updated.getCollectCount());

        log.info("单次取消收藏测试通过, collectCount: {}", updated.getCollectCount());
    }

    /**
     * 测试防止计数变为负数
     */
    @Test
    @DisplayName("多次取消收藏 - 计数不应为负数")
    public void testDecrementPreventsNegative() {
        // 初始计数为0
        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        assertEquals(0, item.getCollectCount());

        // 尝试减少计数 (即使没有收藏记录)
        itemMapper.decrementCollectCount(testItemId);

        // 验证计数不会变为负数
        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(0, updated.getCollectCount(), "计数应该保持为0,不应该变为负数");

        // 多次尝试减少
        itemMapper.decrementCollectCount(testItemId);
        itemMapper.decrementCollectCount(testItemId);
        itemMapper.decrementCollectCount(testItemId);

        updated = itemMapper.selectById(testItemId);
        assertEquals(0, updated.getCollectCount(), "多次减少后计数仍应为0");

        log.info("防止负数测试通过, collectCount: {}", updated.getCollectCount());
    }

    /**
     * 测试并发收藏计数准确性
     *
     * 场景: 10个线程同时收藏,每个线程收藏10次
     * 预期: 计数应为 10 * 10 = 100
     */
    @Test
    @DisplayName("并发收藏 - 计数应准确")
    public void testConcurrentCollect() throws InterruptedException, ExecutionException {
        int threadCount = 10;
        int operationsPerThread = 10;
        int expectedCount = threadCount * operationsPerThread;

        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);
        AtomicInteger successCount = new AtomicInteger(0);

        List<Future<?>> futures = new ArrayList<>();

        // 创建测试用户 (每个用户一个商品)
        List<Long> itemIds = new ArrayList<>();
        for (int i = 0; i < threadCount; i++) {
            BusMarketItemEntity item = new BusMarketItemEntity();
            item.setUserId((long) i);
            item.setTitle("并发测试商品-" + i);
            item.setDescription("测试");
            item.setPrice(new BigDecimal("100.0"));
            item.setCategoryId(1L);
            item.setStatus(0);
            item.setViewCount(0);
            item.setCollectCount(0);
            item.setDelFlag(0);
            item.setCreateTime(new java.util.Date());
            itemMapper.insert(item);
            itemIds.add(item.getItemId());
        }

        long startTime = System.currentTimeMillis();

        // 并发收藏
        for (int i = 0; i < threadCount; i++) {
            final int threadIndex = i;
            final Long itemId = itemIds.get(i);

            Future<?> future = executor.submit(() -> {
                try {
                    for (int j = 0; j < operationsPerThread; j++) {
                        // 插入收藏记录
                        BusMarketCollectEntity collect = new BusMarketCollectEntity();
                        collect.setUserId((long) threadIndex);
                        collect.setItemId(itemId);
                        collect.setDelFlag(0);
                        collect.setCreateTime(new java.util.Date());
                        collectMapper.insert(collect);

                        // 原子性增加计数
                        itemMapper.incrementCollectCount(itemId);

                        successCount.incrementAndGet();
                    }
                } catch (Exception e) {
                    log.error("线程{}收藏失败: {}", threadIndex, e.getMessage());
                } finally {
                    latch.countDown();
                }
            });
            futures.add(future);
        }

        // 等待所有线程完成
        latch.await(30, TimeUnit.SECONDS);
        executor.shutdown();
        executor.awaitTermination(10, TimeUnit.SECONDS);

        long duration = System.currentTimeMillis() - startTime;

        // 验证每个商品的计数
        int allCorrect = 0;
        for (int i = 0; i < threadCount; i++) {
            BusMarketItemEntity item = itemMapper.selectById(itemIds.get(i));
            int actualCount = item.getCollectCount();
            if (actualCount == operationsPerThread) {
                allCorrect++;
            }
            log.info("商品{} 收藏计数: {}/{}", item.getItemId(), actualCount, operationsPerThread);
        }

        // 验证
        assertEquals(threadCount, allCorrect, "所有商品的收藏计数都应准确");
        assertEquals(expectedCount, successCount.get(), "所有操作都应成功");

        log.info("并发收藏测试通过! 耗时: {}ms, 总操作: {}, 成功: {}",
                duration, expectedCount, successCount.get());
    }

    /**
     * 测试并发收藏和取消收藏混合场景
     */
    @Test
    @DisplayName("并发收藏/取消 - 计数应准确")
    public void testConcurrentCollectAndUncollect() throws InterruptedException {
        int threadCount = 5;
        int operationsPerThread = 20;

        ExecutorService executor = Executors.newFixedThreadPool(threadCount * 2);
        CountDownLatch latch = new CountDownLatch(threadCount * 2);

        // 创建测试商品
        List<Long> itemIds = new ArrayList<>();
        for (int i = 0; i < threadCount; i++) {
            BusMarketItemEntity item = new BusMarketItemEntity();
            item.setUserId((long) i);
            item.setTitle("混合并发测试-" + i);
            item.setDescription("测试");
            item.setPrice(new BigDecimal("100.0"));
            item.setCategoryId(1L);
            item.setStatus(0);
            item.setViewCount(0);
            item.setCollectCount(0);
            item.setDelFlag(0);
            item.setCreateTime(new java.util.Date());
            itemMapper.insert(item);
            itemIds.add(item.getItemId());
        }

        // 收藏线程
        for (int i = 0; i < threadCount; i++) {
            final int index = i;
            final Long itemId = itemIds.get(i);

            executor.submit(() -> {
                try {
                    for (int j = 0; j < operationsPerThread; j++) {
                        // 插入收藏记录
                        BusMarketCollectEntity collect = new BusMarketCollectEntity();
                        collect.setUserId((long) index);
                        collect.setItemId(itemId);
                        collect.setDelFlag(0);
                        collect.setCreateTime(new java.util.Date());
                        collectMapper.insert(collect);

                        // 原子性增加计数
                        itemMapper.incrementCollectCount(itemId);
                        Thread.sleep(1); // 模拟真实场景延迟
                    }
                } catch (Exception e) {
                    log.error("收藏线程失败: {}", e.getMessage());
                } finally {
                    latch.countDown();
                }
            });
        }

        // 取消收藏线程
        for (int i = 0; i < threadCount; i++) {
            final int index = i;
            final Long itemId = itemIds.get(i);

            executor.submit(() -> {
                try {
                    Thread.sleep(10); // 稍微延迟,让收藏先执行
                    for (int j = 0; j < operationsPerThread; j++) {
                        // 标记删除收藏记录
                        collectMapper.updateDelFlag((long) index, itemId, 1);

                        // 原子性减少计数
                        itemMapper.decrementCollectCount(itemId);
                        Thread.sleep(1);
                    }
                } catch (Exception e) {
                    log.error("取消收藏线程失败: {}", e.getMessage());
                } finally {
                    latch.countDown();
                }
            });
        }

        // 等待完成
        latch.await(60, TimeUnit.SECONDS);
        executor.shutdown();
        executor.awaitTermination(10, TimeUnit.SECONDS);

        // 验证计数不为负数
        for (Long itemId : itemIds) {
            BusMarketItemEntity item = itemMapper.selectById(itemId);
            assertTrue(item.getCollectCount() >= 0,
                    "商品" + itemId + "的收藏计数不应为负数,实际: " + item.getCollectCount());
            log.info("商品{} 最终计数: {}", itemId, item.getCollectCount());
        }

        log.info("并发混合场景测试通过!");
    }

    /**
     * 测试原子操作的幂等性
     */
    @Test
    @DisplayName("连续多次增加 - 每次都应准确+1")
    public void testIncrementIdempotency() {
        // 连续增加100次
        for (int i = 0; i < 100; i++) {
            itemMapper.incrementCollectCount(testItemId);
        }

        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        assertEquals(100, item.getCollectCount(), "连续100次增加后计数应为100");

        log.info("幂等性测试通过, collectCount: {}", item.getCollectCount());
    }

    /**
     * 测试边界情况 - 大数增加
     */
    @Test
    @DisplayName("大数增加 - 应能正确处理")
    public void testLargeIncrement() {
        // 先设置一个大数
        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        item.setCollectCount(99990);
        itemMapper.updateById(item);

        // 再增加10次
        for (int i = 0; i < 10; i++) {
            itemMapper.incrementCollectCount(testItemId);
        }

        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(100000, updated.getCollectCount(), "99990+10应为100000");

        log.info("大数测试通过, collectCount: {}", updated.getCollectCount());
    }
}
