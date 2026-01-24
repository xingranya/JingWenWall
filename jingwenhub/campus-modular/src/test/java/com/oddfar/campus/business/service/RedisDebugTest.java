package com.oddfar.campus.business.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class RedisDebugTest {

    @Autowired
    @Qualifier("redisStringObjectTemplate")
    private RedisTemplate<String, Object> redisTemplate;

    @Test
    public void testRedisIncrement() {
        String key = "test:increment:debug";
        // 清理
        redisTemplate.delete(key);

        // 增加
        Long result = redisTemplate.opsForValue().increment(key);
        assertNotNull(result, "increment result should not be null");
        System.out.println("Increment result type: " + result.getClass().getName());
        System.out.println("Increment result: " + result);

        // 读取
        Object value = redisTemplate.opsForValue().get(key);
        System.out.println("Get result type: " + (value != null ? value.getClass().getName() : "null"));
        System.out.println("Get result: " + value);

        // 清理
        redisTemplate.delete(key);

        assertNotNull(value);
    }
}
