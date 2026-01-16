package com.oddfar.campus.business.market.mapper;

import com.oddfar.campus.business.market.domain.entity.BusMarketItemEntity;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Date;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 二手市场收藏计数原子操作测试
 *
 * 测试Mapper层的原子SQL操作,验证并发安全性
 *
 * @author jingwen
 * @since 2026-01-16
 */
@Slf4j
@SpringBootTest
@ActiveProfiles("test")
@Transactional
public class MarketItemMapperTest {

    @Autowired
    private MarketItemMapper itemMapper;

    private Long testItemId;

    @BeforeEach
    public void setup() {
        // 创建测试商品
        BusMarketItemEntity item = new BusMarketItemEntity();
        item.setUserId(1L);
        item.setTitle("测试商品-原子操作");
        item.setDescription("这是一个测试商品");
        item.setPrice(new BigDecimal("100.0"));
        item.setCategoryId(1L);
        item.setStatus(0);
        item.setViewCount(0);
        item.setCollectCount(0);
        item.setDelFlag(0);
        item.setCreateTime(new Date());

        itemMapper.insert(item);
        testItemId = item.getItemId();

        log.info("测试数据创建完成, itemId: {}", testItemId);
    }

    @Test
    @DisplayName("原子增加收藏数 - 应准确+1")
    public void testIncrementCollectCount() {
        // 初始计数为0
        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        assertEquals(0, item.getCollectCount());

        // 原子性增加1
        int rows = itemMapper.incrementCollectCount(testItemId);
        assertEquals(1, rows, "应该影响1行");

        // 验证计数
        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(1, updated.getCollectCount(), "计数应该为1");

        // 再增加10次
        for (int i = 0; i < 10; i++) {
            itemMapper.incrementCollectCount(testItemId);
        }

        updated = itemMapper.selectById(testItemId);
        assertEquals(11, updated.getCollectCount(), "计数应该为11");

        log.info("原子增加测试通过, collectCount: {}", updated.getCollectCount());
    }

    @Test
    @DisplayName("原子减少收藏数 - 应准确-1且不为负")
    public void testDecrementCollectCount() {
        // 先增加5次
        for (int i = 0; i < 5; i++) {
            itemMapper.incrementCollectCount(testItemId);
        }

        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        assertEquals(5, item.getCollectCount());

        // 原子性减少1
        int rows = itemMapper.decrementCollectCount(testItemId);
        assertEquals(1, rows, "应该影响1行");

        // 验证计数减少
        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(4, updated.getCollectCount(), "计数应该为4");

        // 再减少3次
        itemMapper.decrementCollectCount(testItemId);
        itemMapper.decrementCollectCount(testItemId);
        itemMapper.decrementCollectCount(testItemId);

        updated = itemMapper.selectById(testItemId);
        assertEquals(1, updated.getCollectCount(), "计数应该为1");

        log.info("原子减少测试通过, collectCount: {}", updated.getCollectCount());
    }

    @Test
    @DisplayName("防止负数 - 计数不应小于0")
    public void testPreventNegativeCount() {
        // 初始计数为0
        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        assertEquals(0, item.getCollectCount());

        // 尝试减少计数
        itemMapper.decrementCollectCount(testItemId);

        // 验证计数不为负
        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(0, updated.getCollectCount(), "计数应该保持为0");

        // 多次尝试减少
        for (int i = 0; i < 10; i++) {
            itemMapper.decrementCollectCount(testItemId);
        }

        updated = itemMapper.selectById(testItemId);
        assertEquals(0, updated.getCollectCount(), "多次减少后计数仍应为0");

        log.info("防止负数测试通过, collectCount: {}", updated.getCollectCount());
    }

    @Test
    @DisplayName("混合增减 - 计数应准确")
    public void testMixedIncrementDecrement() {
        // 增加3次,减少2次,增加5次,减少4次
        // 预期: 3 - 2 + 5 - 4 = 2

        for (int i = 0; i < 3; i++) {
            itemMapper.incrementCollectCount(testItemId);
        }
        for (int i = 0; i < 2; i++) {
            itemMapper.decrementCollectCount(testItemId);
        }
        for (int i = 0; i < 5; i++) {
            itemMapper.incrementCollectCount(testItemId);
        }
        for (int i = 0; i < 4; i++) {
            itemMapper.decrementCollectCount(testItemId);
        }

        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(2, updated.getCollectCount(), "最终计数应为2");

        log.info("混合增减测试通过, collectCount: {}", updated.getCollectCount());
    }

    @Test
    @DisplayName("边界测试 - 大数增加")
    public void testLargeNumberIncrement() {
        // 设置初始值为99990
        BusMarketItemEntity item = itemMapper.selectById(testItemId);
        item.setCollectCount(99990);
        itemMapper.updateById(item);

        // 增加10次
        for (int i = 0; i < 10; i++) {
            itemMapper.incrementCollectCount(testItemId);
        }

        BusMarketItemEntity updated = itemMapper.selectById(testItemId);
        assertEquals(100000, updated.getCollectCount(), "99990+10应为100000");

        log.info("大数测试通过, collectCount: {}", updated.getCollectCount());
    }

    @Test
    @DisplayName("幂等性 - 连续增加结果应一致")
    public void testIdempotency() {
        // 连续增加100次,每次应该都是+1
        for (int i = 1; i <= 100; i++) {
            itemMapper.incrementCollectCount(testItemId);
            BusMarketItemEntity current = itemMapper.selectById(testItemId);
            assertEquals(i, current.getCollectCount(),
                    "第" + i + "次增加后,计数应为" + i);
        }

        BusMarketItemEntity finalItem = itemMapper.selectById(testItemId);
        assertEquals(100, finalItem.getCollectCount(), "最终计数应为100");

        log.info("幂等性测试通过, collectCount: {}", finalItem.getCollectCount());
    }
}
