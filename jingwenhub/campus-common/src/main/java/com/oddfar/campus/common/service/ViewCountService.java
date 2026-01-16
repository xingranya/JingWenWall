package com.oddfar.campus.common.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * 浏览量计数服务 - 使用Redis缓存 + 异步同步数据库
 */
@Slf4j
@Service
public class ViewCountService {

    private static final String VIEW_COUNT_PREFIX = "view:count:";

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    /**
     * 增加浏览量（线程安全）
     */
    public void incrementViewCount(String resourceType, Long resourceId) {
        String key = VIEW_COUNT_PREFIX + resourceType + ":" + resourceId;
        try {
            redisTemplate.opsForValue().increment(key);
            redisTemplate.expire(key, 7, TimeUnit.DAYS);
        } catch (Exception e) {
            log.error("增加浏览量失败: resourceType={}, resourceId={}", resourceType, resourceId, e);
        }
    }

    /**
     * 获取Redis中的浏览量计数
     */
    public Integer getViewCount(String resourceType, Long resourceId) {
        String key = VIEW_COUNT_PREFIX + resourceType + ":" + resourceId;
        Object count = redisTemplate.opsForValue().get(key);
        return count != null ? (Integer) count : null;
    }

    /**
     * 批量同步浏览量到数据库（定时任务）
     */
    @Scheduled(fixedDelay = 60000)
    public void syncViewCountsToDatabase() {
        log.debug("开始同步浏览量到数据库");

        try {
            // 1. 扫描所有 view:count:* 键
            Set<String> keys = redisTemplate.keys(VIEW_COUNT_PREFIX + "*");
            if (keys == null || keys.isEmpty()) {
                log.debug("没有需要同步的浏览量");
                return;
            }

            // 2. 按资源类型分组
            Map<String, Map<Long, Integer>> grouped = groupByResourceType(keys);

            // 3. 批量更新到数据库
            for (Map.Entry<String, Map<Long, Integer>> entry : grouped.entrySet()) {
                String resourceType = entry.getKey();
                Map<Long, Integer> counts = entry.getValue();

                switch (resourceType) {
                    case "post":
                        syncPostsViewCount(counts);
                        break;
                    case "item":
                        syncItemsViewCount(counts);
                        break;
                    case "content":
                        syncContentViewCount(counts);
                        break;
                }
            }

            // 4. 删除已同步的Redis键
            redisTemplate.delete(keys);

            log.debug("浏览量同步完成，同步了 {} 个资源", keys.size());

        } catch (Exception e) {
            log.error("同步浏览量到数据库失败", e);
        }
    }

    private Map<String, Map<Long, Integer>> groupByResourceType(Set<String> keys) {
        Map<String, Map<Long, Integer>> grouped = new HashMap<>();

        for (String key : keys) {
            // key format: view:count:post:123
            String[] parts = key.split(":");
            if (parts.length != 4) continue;

            String resourceType = parts[2];
            Long resourceId = Long.valueOf(parts[3]);
            Integer count = (Integer) redisTemplate.opsForValue().get(key);

            grouped.computeIfAbsent(resourceType, k -> new HashMap<>())
                   .put(resourceId, count);
        }

        return grouped;
    }

    private void syncPostsViewCount(Map<Long, Integer> counts) {
        // TODO: 调用 ForumPostMapper 批量更新
        log.debug("同步帖子浏览量: {}", counts.size());
    }

    private void syncItemsViewCount(Map<Long, Integer> counts) {
        // TODO: 调用 MarketItemMapper 批量更新
        log.debug("同步商品浏览量: {}", counts.size());
    }

    private void syncContentViewCount(Map<Long, Integer> counts) {
        // TODO: 调用 ContentMapper 批量更新
        log.debug("同步内容浏览量: {}", counts.size());
    }
}
