package com.oddfar.campus.common.core;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.CacheManager;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.junit.jupiter.api.extension.ExtendWith;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

/**
 * RedisCache 分布式锁测试
 *
 * @author test
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = { RedisCacheTest.TestConfig.class, com.oddfar.campus.common.config.RedisConfig.class, RedisCache.class })
public class RedisCacheTest {

    @Configuration
    static class TestConfig {
        @Bean
        public RedisConnectionFactory redisConnectionFactory() {
            return new LettuceConnectionFactory("127.0.0.1", 6379);
        }

        @Bean
        public CacheManager cacheManager() {
            return new ConcurrentMapCacheManager();
        }
    }

    @Autowired
    private RedisCache redisCache;

    /**
     * 测试防止锁误删
     * 场景：线程A获取锁后执行超时，锁自动过期，线程B获取锁。
     * 线程A执行完毕调用unlock()不应删除线程B的锁。
     */
    @Test
    public void testLockMisdeletionPrevention() throws Exception {
        String lockKey = "test:lock:misdeletion";

        // 线程A获取锁（超时1秒）
        AtomicBoolean threadAGotLock = new AtomicBoolean(false);
        Thread threadA = new Thread(() -> {
            boolean locked = redisCache.tryLock(lockKey, 1, TimeUnit.SECONDS);
            threadAGotLock.set(locked);
            if (locked) {
                try {
                    Thread.sleep(1500); // 故意等待超过锁超时时间
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                // 此时锁已过期，线程B可能持有锁
                redisCache.unlock(lockKey); // 不应该删除线程B的锁
            }
        });

        // 线程B尝试获取锁
        AtomicBoolean threadBGotLock = new AtomicBoolean(false);
        AtomicBoolean threadBStillHasLock = new AtomicBoolean(false);
        Thread threadB = new Thread(() -> {
            try {
                Thread.sleep(200); // 等待线程A先获取锁
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            // 尝试多次获取锁（线程A的锁1秒后过期）
            for (int i = 0; i < 10; i++) {
                if (redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS)) {
                    threadBGotLock.set(true);

                    // 持有锁期间
                    try {
                        Thread.sleep(500);
                        // 验证锁仍然存在
                        threadBStillHasLock.set(redisCache.hasKey("lock:" + lockKey));
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    // 释放自己的锁
                    redisCache.unlock(lockKey);
                    break;
                }
                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        threadA.start();
        threadB.start();

        threadA.join();
        threadB.join();

        // 验证：线程A成功获取锁
        assertTrue(threadAGotLock.get(), "线程A应该成功获取锁");
        // 验证：线程B成功获取锁（因为线程A的锁超时）
        assertTrue(threadBGotLock.get(), "线程B应该成功获取锁");
        // 验证：线程B的锁没有被线程A误删
        assertTrue(threadBStillHasLock.get(), "线程B的锁应该仍然存在（未被线程A误删）");
    }

    /**
     * 测试并发锁
     * 场景：10个线程同时竞争同一个锁，验证只有1个线程能成功获取锁
     */
    @Test
    public void testConcurrentLock() throws Exception {
        String lockKey = "test:lock:concurrent";
        int threadCount = 10;
        CountDownLatch startLatch = new CountDownLatch(1);
        CountDownLatch endLatch = new CountDownLatch(threadCount);
        AtomicInteger successCount = new AtomicInteger(0);

        for (int i = 0; i < threadCount; i++) {
            new Thread(() -> {
                try {
                    startLatch.await(); // 等待所有线程就绪

                    boolean locked = redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS);
                    if (locked) {
                        successCount.incrementAndGet();
                        try {
                            Thread.sleep(100);
                        } finally {
                            redisCache.unlock(lockKey);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    endLatch.countDown();
                }
            }).start();
        }

        startLatch.countDown(); // 所有线程同时开始
        endLatch.await(10, TimeUnit.SECONDS);

        // 验证：只有1个线程成功获取锁
        assertEquals(1, successCount.get(), "应该只有1个线程成功获取锁");
    }

    /**
     * 测试基本的锁获取和释放
     */
    @Test
    public void testBasicLock() {
        String lockKey = "test:lock:basic";

        // 获取锁
        boolean locked = redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS);
        assertTrue(locked, "应该成功获取锁");

        // 验证锁存在
        assertTrue(redisCache.hasKey("lock:" + lockKey), "锁应该存在");

        // 释放锁
        redisCache.unlock(lockKey);

        // 验证锁已释放
        assertFalse(redisCache.hasKey("lock:" + lockKey), "锁应该已释放");
    }

    /**
     * 测试锁的重试机制
     */
    @Test
    public void testTryLockWithRetry() {
        String lockKey = "test:lock:retry";

        // 先获取锁
        boolean locked1 = redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS);
        assertTrue(locked1, "第一次应该成功获取锁");

        // 在另一个线程中尝试获取锁（带重试）
        Thread thread = new Thread(() -> {
            // 使用重试机制尝试获取锁（会失败，因为锁已被持有）
            boolean locked2 = redisCache.tryLockWithRetry(lockKey, 1, TimeUnit.SECONDS, 3);
            assertFalse(locked2, "重试获取锁应该失败（锁已被占用）");
        });

        thread.start();
        try {
            thread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        // 释放锁
        redisCache.unlock(lockKey);
    }

    /**
     * 测试未持有锁时释放锁
     * 场景：当前线程没有持有锁，调用unlock()应该安全返回，不会删除其他线程的锁
     */
    @Test
    public void testUnlockWithoutLock() {
        String lockKey = "test:lock:unlockWithoutLock";

        // 线程A获取锁
        Thread threadA = new Thread(() -> {
            boolean locked = redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS);
            assertTrue(locked, "线程A应该成功获取锁");

            try {
                Thread.sleep(500); // 持有锁500ms
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            // 验证锁仍然存在
            assertTrue(redisCache.hasKey("lock:" + lockKey), "线程A的锁应该仍然存在");

            redisCache.unlock(lockKey);
        });

        // 线程B尝试释放锁（但线程B没有持有锁）
        Thread threadB = new Thread(() -> {
            try {
                Thread.sleep(200); // 等待线程A先获取锁
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            // 线程B调用unlock，但不持有锁，应该安全返回
            redisCache.unlock(lockKey);

            // 验证线程A的锁仍然存在
            assertTrue(redisCache.hasKey("lock:" + lockKey), "线程A的锁应该仍然存在（线程B无法释放）");
        });

        threadA.start();
        threadB.start();

        try {
            threadA.join();
            threadB.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    /**
     * 测试锁超时
     */
    @Test
    public void testLockTimeout() throws Exception {
        String lockKey = "test:lock:timeout";

        // 获取锁（超时1秒）
        boolean locked = redisCache.tryLock(lockKey, 1, TimeUnit.SECONDS);
        assertTrue(locked, "应该成功获取锁");

        // 等待锁过期
        Thread.sleep(1500);

        // 验证锁已过期
        assertFalse(redisCache.hasKey("lock:" + lockKey), "锁应该已过期");

        // 现在可以重新获取锁
        boolean lockedAgain = redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS);
        assertTrue(lockedAgain, "锁过期后应该可以重新获取");

        redisCache.unlock(lockKey);
    }
}
