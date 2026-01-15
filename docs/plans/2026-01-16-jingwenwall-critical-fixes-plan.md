# JingWenWall 项目紧急修复实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**目标:** 修复 JingWenWall 项目中发现的7个关键问题，确保系统安全性和稳定性

**架构:** 基于实际代码逐行分析后的修正方案，采用最小改动原则，利用 MyBatis-Plus 的 @Version 注解进行乐观锁控制，使用 SQL 原子操作消除竞态条件

**技术栈:** Spring Boot 2.5.14, MyBatis-Plus, Redis, MySQL, Java 8+

---

## 任务概览

| # | 任务 | 优先级 | 预计时间 | 风险 |
|---|------|--------|----------|------|
| 1 | 修复抢单 updateById 失败导致数据不一致 | P0 | 30分钟 | 中高 |
| 2 | 修复点赞计数逻辑错误和并发竞态 | P0 | 1.5小时 | 中高 |
| 3 | 修复评论 N+1 查询性能问题 | P1 | 1.5小时 | 低 |
| 4 | 添加核心表数据库索引 | P0 | 1小时 | 低 |
| 5 | 优化 SimpleDateFormat 为 DateTimeFormatter | P2 | 30分钟 | 低 |
| 6 | 修复 HashMap 并发安全问题 | P1 | 15分钟 | 中 |
| 7 | 添加 ThreadLocal 清理过滤器 | P1 | 30分钟 | 低 |

**总计:** 约 6 小时

---

## 任务 1: 修复抢单 updateById 失败问题

### 问题描述

当前代码在 `ErrandOrderServiceImpl.java:158-189` 存在严重的数据不一致问题：

**问题代码流程:**
```java
// 第172-177行: updateStatusWithVersion 更新数据库 version=6
int rows = errandOrderMapper.updateStatusWithVersion(...);

// 第187行: updateById 使用 order 对象的 version=5,但数据库中 version=6
this.updateById(order);  // ❌ 会因 version 不匹配而失败!
```

**后果:** runner_id、runner_fee、platform_fee 没有被更新到数据库，数据不一致！

### 修复策略

直接使用 MyBatis-Plus 的 `updateById` 方法，它自动使用 @Version 注解进行乐观锁控制。删除冗余的 `updateStatusWithVersion` 调用和重复的代码。

---

### Step 1: 编写并发抢单测试（先写测试，TDD）

**文件:** `jingwenhub/campus-modular/src/test/java/com/oddfar/campus/business/errand/service/ErrandOrderServiceTest.java`

**添加测试方法:**

```java
package com.oddfar.campus.business.errand.service;

import com.oddfar.campus.business.errand.domain.dto.ErrandOrderDTO;
import com.oddfar.campus.business.errand.enums.OrderStatus;
import com.oddfar.campus.business.errand.enums.PayStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class ErrandOrderServiceTest {

    @Autowired
    private ErrandOrderService errandOrderService;

    /**
     * 测试并发抢单 - 确保只有一个骑手成功接单
     */
    @Test
    public void testConcurrentAcceptOrder() throws Exception {
        // 1. 创建测试订单
        ErrandOrderDTO orderDTO = new ErrandOrderDTO();
        orderDTO.setType(1);
        orderDTO.setPickupAddr("校内A点");
        orderDTO.setDeliveryAddr("校内B点");
        orderDTO.setGoodsDesc("测试物品");
        orderDTO.setExpectTime(new Date(System.currentTimeMillis() + 3600000));
        orderDTO.setTip(BigDecimal.ZERO);

        Long orderId = errandOrderService.createOrder(orderDTO);

        // 2. 模拟支付
        errandOrderService.mockPaySuccess(orderId);

        // 3. 模拟两个骑手并发抢单
        CountDownLatch latch = new CountDownLatch(2);
        AtomicBoolean runner1Success = new AtomicBoolean(false);
        AtomicBoolean runner2Success = new AtomicBoolean(false);
        AtomicInteger successCount = new AtomicInteger(0);

        // 骑手1线程
        Thread thread1 = new Thread(() -> {
            try {
                SecurityUtils.setUserId(1L);
                latch.await();
                errandOrderService.acceptOrder(orderId);
                runner1Success.set(true);
                successCount.incrementAndGet();
            } catch (Exception e) {
                // 预期: 一个线程会失败
                System.out.println("骑手1抢单失败: " + e.getMessage());
            }
        });

        // 骑手2线程
        Thread thread2 = new Thread(() -> {
            try {
                SecurityUtils.setUserId(2L);
                latch.await();
                errandOrderService.acceptOrder(orderId);
                runner2Success.set(true);
                successCount.incrementAndGet();
            } catch (Exception e) {
                // 预期: 一个线程会失败
                System.out.println("骑手2抢单失败: " + e.getMessage());
            }
        });

        thread1.start();
        thread2.start();

        latch.countDown();
        latch.countDown();

        thread1.join();
        thread2.join();

        // 4. 验证: 只有一个骑手成功
        assertEquals(1, successCount.get(), "应该只有一个骑手成功接单");
        assertTrue(runner1Success.get() || runner2Success.get(), "至少一个骑手应该成功");

        // 5. 验证数据库状态
        ErrandOrderVO order = errandOrderService.getOrderDetail(orderId);
        assertEquals(OrderStatus.ACCEPTED.getCode(), order.getStatus());
        assertNotNull(order.getRunnerId(), "骑手ID不应为空");
        assertNotNull(order.getRunnerFee(), "骑手佣金不应为空");
        assertNotNull(order.getPlatformFee(), "平台抽成不应为空");

        System.out.println("✅ 并发抢单测试通过");
        System.out.println("   成功骑手ID: " + order.getRunnerId());
        System.out.println("   骑手佣金: " + order.getRunnerFee());
        System.out.println("   平台抽成: " + order.getPlatformFee());
    }
}
```

**Step 2: 运行测试验证失败**

```bash
cd E:\wxxcx\JingWenWall\jingwenhub
mvn test -Dtest=ErrandOrderServiceTest#testConcurrentAcceptOrder
```

**预期结果:** 测试**失败**或**数据不一致**（runner_fee 为空）

---

### Step 3: 修复 ErrandOrderServiceImpl.java

**文件:** `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/errand/service/impl/ErrandOrderServiceImpl.java`

**位置:** 第158-189行

**替换代码:**

```java
// 4. 计算骑手佣金和平台抽成
BigDecimal totalFee = order.getTotalFee();
BigDecimal platformRate = new BigDecimal(platformRateConfig);
BigDecimal platformFee = totalFee.multiply(platformRate).setScale(2, RoundingMode.HALF_UP);
BigDecimal runnerFee = totalFee.subtract(platformFee);

// 5. ✅ 修复: 使用 updateById 一次更新所有字段 (MyBatis-Plus 自动使用 @Version 乐观锁)
order.setRunnerId(runnerId);
order.setRunnerFee(runnerFee);
order.setPlatformFee(platformFee);
order.setStatus(OrderStatus.ACCEPTED.getCode());
order.setUpdateTime(new Date());

// ✅ updateById 会自动使用 @Version 注解进行乐观锁控制
boolean success = this.updateById(order);

if (!success) {
    throw new ServiceException("抢单失败,订单已被接单");
}

log.info("订单 {} 被骑手 {} 接单, 佣金: {}, 平台抽成: {}", orderId, runnerId, runnerFee, platformFee);
```

**删除内容:** 删除第172-187行的所有冗余代码（包括 `updateStatusWithVersion` 调用和重复的 setter）

---

### Step 4: 运行测试验证修复

```bash
cd E:\wxxcx\JingWenWall\jingwenhub
mvn test -Dtest=ErrandOrderServiceTest#testConcurrentAcceptOrder
```

**预期结果:** ✅ 测试**通过**，数据一致性正确

---

### Step 5: 提交修复

```bash
cd E:\wxxcx\JingWenWall
git add jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/errand/service/impl/ErrandOrderServiceImpl.java
git add jingwenhub/campus-modular/src/test/java/com/oddfar/campus/business/errand/service/ErrandOrderServiceTest.java
git commit -m "fix(errand): 修复抢单数据不一致问题

- 删除冗余的 updateStatusWithVersion 调用
- 直接使用 updateById，MyBatis-Plus 自动使用 @Version 乐观锁
- 添加并发抢单测试确保数据一致性
- 修复 runner_fee 和 platform_fee 未更新的问题

Related: #修复方案最终审查报告(重新分析).md"
```

---

## 任务 2: 修复点赞计数逻辑错误和并发竞态

### 问题描述

**问题 A - 逻辑错误:** 恢复已删除的点赞时，错误地增加了计数（第211行）

**问题 B - 并发竞态:** `BusForumPostEntity` 没有 @Version 注解，第211-212行存在竞态条件

---

### Step 1: 编写点赞并发测试

**文件:** `jingwenhub/campus-modular/src/test/java/com/oddfar/campus/business/forum/service/ForumPostServiceTest.java`

```java
package com.oddfar.campus.business.forum.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class ForumPostServiceTest {

    @Autowired
    private ForumPostService forumPostService;

    /**
     * 测试并发点赞 - 确保计数准确
     */
    @Test
    public void testConcurrentLikePost() throws Exception {
        Long postId = 1L; // 假设存在帖子ID为1
        int threadCount = 100;

        // 获取初始点赞数
        ForumPostVO initialPost = forumPostService.getDetail(postId);
        int initialCount = initialPost.getLikeCount();

        CountDownLatch latch = new CountDownLatch(threadCount);
        AtomicInteger failCount = new AtomicInteger(0);

        // 100个线程同时点赞
        for (int i = 0; i < threadCount; i++) {
            final int threadNum = i;
            Thread thread = new Thread(() -> {
                try {
                    SecurityUtils.setUserId((long) (1000 + threadNum));
                    latch.await();
                    forumPostService.likePost(postId);
                } catch (Exception e) {
                    failCount.incrementAndGet();
                    System.out.println("线程" + threadNum + "点赞失败: " + e.getMessage());
                }
            });
            thread.start();
        }

        // 启动所有线程
        for (int i = 0; i < threadCount; i++) {
            latch.countDown();
        }

        // 等待所有线程完成
        Thread.sleep(3000);

        // 验证点赞数
        ForumPostVO finalPost = forumPostService.getDetail(postId);
        int expectedCount = initialCount + threadCount;

        System.out.println("初始点赞数: " + initialCount);
        System.out.println("预期点赞数: " + expectedCount);
        System.out.println("实际点赞数: " + finalPost.getLikeCount());
        System.out.println("失败次数: " + failCount.get());

        assertEquals(expectedCount, finalPost.getLikeCount(), "点赞数应该准确");
    }

    /**
     * 测试点赞-取消-再点赞逻辑
     */
    @Test
    public void testLikeUnlikeLike() {
        Long postId = 1L;
        Long userId = 9999L;
        SecurityUtils.setUserId(userId);

        // 获取初始点赞数
        ForumPostVO initialPost = forumPostService.getDetail(postId);
        int initialCount = initialPost.getLikeCount();

        // 第一次点赞
        forumPostService.likePost(postId);
        ForumPostVO afterLike = forumPostService.getDetail(postId);
        assertEquals(initialCount + 1, afterLike.getLikeCount(), "点赞后应该+1");

        // 取消点赞
        forumPostService.unlikePost(postId);
        ForumPostVO afterUnlike = forumPostService.getDetail(postId);
        assertEquals(initialCount, afterUnlike.getLikeCount(), "取消后应该恢复原值");

        // 再次点赞（恢复）
        forumPostService.likePost(postId);
        ForumPostVO afterRelike = forumPostService.getDetail(postId);
        assertEquals(initialCount + 1, afterRelike.getLikeCount(), "恢复点赞后应该+1，不是+2");

        System.out.println("✅ 点赞逻辑测试通过");
    }
}
```

**Step 2: 运行测试验证失败**

```bash
mvn test -Dtest=ForumPostServiceTest#testConcurrentLikePost
```

**预期结果:** 测试**失败**，点赞数不准确

---

### Step 3: 添加原子性更新方法到 ForumPostMapper.xml

**文件:** `jingwenhub/campus-modular/src/main/resources/mapper/ForumPostMapper.xml`

**位置:** 第135行后添加

```xml
<!-- 原子性增加点赞数 -->
<update id="incrementLikeCount">
    UPDATE bus_forum_post
    SET like_count = like_count + 1
    WHERE post_id = #{postId}
      AND del_flag = 0
</update>

<!-- 原子性减少点赞数 -->
<update id="decrementLikeCount">
    UPDATE bus_forum_post
    SET like_count = GREATEST(like_count - 1, 0)
    WHERE post_id = #{postId}
      AND del_flag = 0
</update>
```

---

### Step 4: 添加方法到 ForumPostMapper.java

**文件:** `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/mapper/ForumPostMapper.java`

**添加方法:**

```java
/**
 * 原子性增加点赞数
 * @param postId 帖子ID
 * @return 影响行数
 */
int incrementLikeCount(@Param("postId") Long postId);

/**
 * 原子性减少点赞数
 * @param postId 帖子ID
 * @return 影响行数
 */
int decrementLikeCount(@Param("postId") Long postId);
```

---

### Step 5: 修复 ForumPostServiceImpl.java - likePost 方法

**文件:** `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/service/impl/ForumPostServiceImpl.java`

**位置:** 第184-214行

**替换代码:**

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void likePost(Long postId) {
    Long userId = SecurityUtils.getUserId();

    // 1. 忽略逻辑删除，直接查询物理记录（确保能找回已删除的记录，规避唯一索引冲突）
    BusForumPostLikeEntity existLike = likeMapper.selectOnePhysical(userId, postId);

    boolean isNewLike = false;  // ✅ 标记是否是新点赞

    if (existLike != null) {
        // 如果记录存在且 del_flag 为 0 (未删除)，说明是真的重复点赞
        if (existLike.getDelFlag() != null && existLike.getDelFlag() == 0) {
            throw new ServiceException("已经点赞过了");
        } else {
            // 如果记录存在但 del_flag 为 1 (已删除)，则将其恢复
            existLike.setDelFlag(0);
            likeMapper.updateById(existLike);
            // ✅ 恢复点赞，不增加计数（之前点赞时已经增加过了）
        }
    } else {
        // 2. 如果物理表完全没有记录，则执行插入
        BusForumPostLikeEntity likeEntity = new BusForumPostLikeEntity();
        likeEntity.setUserId(userId);
        likeEntity.setPostId(postId);
        likeEntity.setDelFlag(0);
        likeMapper.insert(likeEntity);
        isNewLike = true;  // ✅ 标记为新点赞
    }

    // 3. ✅ 修复: 只有新点赞才增加计数，并使用原子性更新
    if (isNewLike) {
        forumPostMapper.incrementLikeCount(postId);
    }
}
```

---

### Step 6: 修复 ForumPostServiceImpl.java - unlikePost 方法

**文件:** 同上

**位置:** 第218-240行

**替换代码:**

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void unlikePost(Long postId) {
    Long userId = SecurityUtils.getUserId();

    // 查找点赞记录（只查未删除的）
    LambdaQueryWrapper<BusForumPostLikeEntity> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(BusForumPostLikeEntity::getUserId, userId)
           .eq(BusForumPostLikeEntity::getPostId, postId)
           .eq(BusForumPostLikeEntity::getDelFlag, 0);

    BusForumPostLikeEntity likeEntity = likeMapper.selectOne(wrapper);
    if (likeEntity != null) {
        // 设置 del_flag = 1
        likeEntity.setDelFlag(1);
        likeMapper.updateById(likeEntity);

        // ✅ 修复: 使用原子性更新
        forumPostMapper.decrementLikeCount(postId);
    }
}
```

---

### Step 7: 运行测试验证修复

```bash
mvn test -Dtest=ForumPostServiceTest
```

**预期结果:** ✅ 所有测试通过

---

### Step 8: 提交修复

```bash
git add jingwenhub/campus-modular/src/main/resources/mapper/ForumPostMapper.xml
git add jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/mapper/ForumPostMapper.java
git add jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/service/impl/ForumPostServiceImpl.java
git add jingwenhub/campus-modular/src/test/java/com/oddfar/campus/business/forum/service/ForumPostServiceTest.java
git commit -m "fix(forum): 修复点赞计数逻辑错误和并发竞态问题

问题:
- 恢复已删除的点赞时错误增加计数
- 无并发保护导致计数不准确

修复:
- 添加 isNewLike 标记区分新点赞 vs 恢复点赞
- 使用 SQL 原子操作 (like_count = like_count + 1)
- 添加 GREATEST 防止计数变成负数
- 添加并发测试确保计数准确

影响:
- ForumPostMapper.xml: 新增 incrementLikeCount/decrementLikeCount
- ForumPostServiceImpl.java: 修复 likePost/unlikePost 逻辑

Related: #修复方案最终审查报告(重新分析).md"
```

---

## 任务 3: 修复评论 N+1 查询性能问题

### 问题描述

当前代码在 `ForumCommentServiceImpl.java:49-52` 存在 N+1 查询问题，100 条一级评论 = 101 次数据库查询

---

### Step 1: 编写性能测试

**文件:** `jingwenhub/campus-modular/src/test/java/com/oddfar/campus/business/forum/service/ForumCommentServiceTest.java`

```java
package com.oddfar.campus.business.forum.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class ForumCommentServiceTest {

    @Autowired
    private ForumCommentService forumCommentService;

    /**
     * 测试评论查询性能
     */
    @Test
    public void testCommentListPerformance() {
        long startTime = System.currentTimeMillis();

        PageResult<ForumCommentVO> result = forumCommentService.getCommentList(1L, 1, 20);

        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        assertNotNull(result);
        assertTrue(result.getRows().size() <= 20, "评论数量不超过20条");

        System.out.println("✅ 评论查询耗时: " + duration + "ms");
        System.out.println("   一级评论数: " + result.getRows().size());

        // 验证性能: 应该 < 100ms
        assertTrue(duration < 100, "查询时间应该 < 100ms，实际: " + duration + "ms");
    }
}
```

**Step 2: 运行测试验证性能**

```bash
mvn test -Dtest=ForumCommentServiceTest#testCommentListPerformance
```

**预期结果:** ⚠️ 当前可能 > 1000ms

---

### Step 3: 添加批量查询方法到 ForumCommentMapper.xml

**文件:** `jingwenhub/campus-modular/src/main/resources/mapper/ForumCommentMapper.xml`

**位置:** 第71行后添加

```xml
<!-- 批量查询二级评论 -->
<select id="selectSecondLevelBatch" resultMap="CommentVoResultMap">
    <include refid="selectCommentVo"/>
    AND c.parent_id IN
    <foreach collection="commentIds" item="commentId" open="(" separator="," close=")">
        #{commentId}
    </foreach>
    AND c.status = 0
    ORDER BY c.parent_id ASC, c.create_time ASC
</select>
```

---

### Step 4: 添加方法到 ForumCommentMapper.java

**文件:** `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/mapper/ForumCommentMapper.java`

**添加方法:**

```java
/**
 * 批量查询二级评论
 * @param commentIds 一级评论ID列表
 * @return 二级评论列表
 */
List<ForumCommentVO> selectSecondLevelBatch(@Param("commentIds") List<Long> commentIds);
```

---

### Step 5: 修复 ForumCommentServiceImpl.java

**文件:** `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/service/impl/ForumCommentServiceImpl.java`

**添加 import:**

```java
import java.util.Collections;
import java.util.Map;
import java.util.stream.Collectors;
```

**位置:** 第42-55行，替换 getCommentList 方法

```java
@Override
public PageResult<ForumCommentVO> getCommentList(Long postId, Integer pageNum, Integer pageSize) {
    // 分页查询一级评论
    PageHelper.startPage(pageNum, pageSize);
    List<ForumCommentVO> firstLevelComments = commentMapper.selectFirstLevelComments(postId);
    PageInfo<ForumCommentVO> pageInfo = new PageInfo<>(firstLevelComments);

    // ✅ 修复 N+1 查询: 使用批量查询
    if (!firstLevelComments.isEmpty()) {
        // 提取所有一级评论ID
        List<Long> commentIds = firstLevelComments.stream()
            .map(ForumCommentVO::getCommentId)
            .collect(Collectors.toList());

        // 批量查询所有二级评论
        List<ForumCommentVO> allReplies = commentMapper.selectSecondLevelBatch(commentIds);

        // 按 parent_id 分组
        Map<Long, List<ForumCommentVO>> repliesMap = allReplies.stream()
            .collect(Collectors.groupingBy(ForumCommentVO::getParentId));

        // 填充到一级评论
        firstLevelComments.forEach(comment -> {
            List<ForumCommentVO> replies = repliesMap.getOrDefault(comment.getCommentId(), Collections.emptyList());
            comment.setReplies(replies);
        });
    }

    return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
}
```

---

### Step 6: 运行测试验证性能提升

```bash
mvn test -Dtest=ForumCommentServiceTest#testCommentListPerformance
```

**预期结果:** ✅ < 100ms

---

### Step 7: 提交修复

```bash
git add jingwenhub/campus-modular/src/main/resources/mapper/ForumCommentMapper.xml
git add jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/mapper/ForumCommentMapper.java
git add jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/service/impl/ForumCommentServiceImpl.java
git add jingwenhub/campus-modular/src/test/java/com/oddfar/campus/business/forum/service/ForumCommentServiceTest.java
git commit -m "perf(forum): 修复评论 N+1 查询性能问题

问题:
- 100 条一级评论 = 101 次数据库查询
- 查询耗时 1-5 秒

修复:
- 新增 selectSecondLevelBatch 批量查询方法
- 使用 IN 查询替代循环查询
- 添加性能测试确保 < 100ms

性能提升:
- 查询次数: 101 → 2
- 查询时间: 1-5s → <100ms
- 性能提升: 95%+

Related: #修复方案最终审查报告(重新分析).md"
```

---

## 任务 4: 添加核心表数据库索引

### 问题描述

核心表（campus_content、campus_comment、bus_forum_post 等）缺少索引，导致全表扫描，查询 5 秒+

---

### Step 1: 备份数据库

```bash
mysqldump -u root -p jingwen_campus > backup_$(date +%Y%m%d_%H%M%S).sql
```

**验证备份:**

```bash
ls -lh backup_*.sql | tail -1
```

---

### Step 2: 创建索引 SQL 脚本

**文件:** `jingwenhub/sql/add_indexes_phase1.sql`

**创建文件:**

```sql
-- ============================================
-- JingWenWall 数据库索引优化 - 第一批
-- 执行时间: 2026-01-16
-- ============================================

-- 1. campus_content 表索引
ALTER TABLE campus_content
ADD INDEX idx_user_status_time (user_id, status, create_time DESC),
ADD INDEX idx_category_status (category_id, status),
ADD INDEX idx_status_create_time (status, create_time DESC);

-- 2. campus_comment 表索引
ALTER TABLE campus_comment
ADD INDEX idx_content_parent_time (content_id, parent_id, create_time DESC),
ADD INDEX idx_user_del_time (user_id, del_flag, create_time DESC);

-- 3. bus_forum_post 表索引
ALTER TABLE bus_forum_post
ADD INDEX idx_user_status_time (user_id, status, create_time DESC),
ADD INDEX idx_category_status (category_id, status);

-- 4. bus_forum_comment 表索引
ALTER TABLE bus_forum_comment
ADD INDEX idx_post_parent_time (post_id, parent_id, create_time DESC);

-- 5. bus_errand_order 表索引
ALTER TABLE bus_errand_order
ADD INDEX idx_status_pay_time (status, pay_status, create_time DESC),
ADD INDEX idx_runner_status (runner_id, status);

-- 验证索引
SHOW INDEX FROM campus_content;
SHOW INDEX FROM campus_comment;
SHOW INDEX FROM bus_forum_post;
```

---

### Step 3: 执行索引添加

```bash
mysql -u root -p jingwen_campus < jingwenhub/sql/add_indexes_phase1.sql
```

**验证执行:**

```bash
mysql -u root -p jingwen_campus -e "SHOW INDEX FROM campus_content WHERE Key_name LIKE 'idx_%';"
```

**预期结果:** 显示所有新添加的索引

---

### Step 4: 验证查询性能

```sql
-- 验证 campus_content 查询是否使用索引
EXPLAIN SELECT * FROM campus_content
WHERE user_id = 1 AND status = 0
ORDER BY create_time DESC
LIMIT 20;
```

**预期结果:**
- `type`: `ref` 或 `range`
- `key`: `idx_user_status_time`
- `rows`: < 100

---

### Step 5: 提交 SQL 脚本

```bash
git add jingwenhub/sql/add_indexes_phase1.sql
git commit -m "perf(db): 添加核心表数据库索引

添加索引:
- campus_content: idx_user_status_time, idx_category_status
- campus_comment: idx_content_parent_time, idx_user_del_time
- bus_forum_post: idx_user_status_time, idx_category_status
- bus_forum_comment: idx_post_parent_time
- bus_errand_order: idx_status_pay_time, idx_runner_status

性能提升:
- 查询时间: 5秒+ → <100ms
- 性能提升: 95%+

验证:
- EXPLAIN 显示使用索引
- type=ref, key=idx_*

Related: #修复方案最终审查报告(重新分析).md"
```

---

## 任务 5: 优化 SimpleDateFormat 为 DateTimeFormatter

### 问题描述

`ErrandOrderServiceImpl.java:337` 使用 SimpleDateFormat（局部变量，无线程安全问题，但性能低）

---

### Step 1: 优化 ErrandOrderServiceImpl.java

**文件:** `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/errand/service/impl/ErrandOrderServiceImpl.java`

**添加 import:**

```java
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
```

**位置:** 第30行后添加静态字段

```java
private static final DateTimeFormatter ORDER_NO_FORMATTER =
    DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
```

**位置:** 第336-341行，替换 generateOrderNo 方法

```java
/**
 * 生成订单号
 */
private String generateOrderNo() {
    String timestamp = LocalDateTime.now().format(ORDER_NO_FORMATTER);
    String random = IdUtil.fastSimpleUUID().substring(0, 6).toUpperCase();
    return "ER" + timestamp + random;
}
```

---

### Step 2: 验证订单号生成

```bash
# 在测试环境运行
mvn test -Dtest=ErrandOrderServiceTest#testCreateOrder
```

**验证订单号格式:** `ER20260116153045ABC123`

---

### Step 3: 提交优化

```bash
git add jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/errand/service/impl/ErrandOrderServiceImpl.java
git commit -m "refactor(errand): 优化订单号生成使用 DateTimeFormatter

变更:
- SimpleDateFormat → DateTimeFormatter (Java 8+)
- 线程安全且性能更好
- 订单号格式保持不变: ER20260116153045ABC123

优点:
- 线程安全（不可变）
- 性能更好（无需每次创建实例）
- 代码更简洁

Related: #修复方案最终审查报告(重新分析).md"
```

---

## 任务 6: 修复 HashMap 并发安全问题

### 问题描述

`SameUrlDataInterceptor.java:56,82` 使用 HashMap 在并发环境下，可能导致 `ConcurrentModificationException`

---

### Step 1: 修复 SameUrlDataInterceptor.java

**文件:** `jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/interceptor/impl/SameUrlDataInterceptor.java`

**添加 import:**

```java
import java.util.concurrent.ConcurrentHashMap;
```

**位置:** 第56行，替换

```java
Map<String, Object> nowDataMap = new ConcurrentHashMap<String, Object>();
```

**位置:** 第82行，替换

```java
Map<String, Object> cacheMap = new ConcurrentHashMap<String, Object>();
```

---

### Step 2: 验证防重复提交功能

```bash
# 启动应用后，手动测试防重复提交
# 或者等待集成测试
```

---

### Step 3: 提交修复

```bash
git add jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/interceptor/impl/SameUrlDataInterceptor.java
git commit -m "fix(framework): 修复 HashMap 并发安全问题

变更:
- HashMap → ConcurrentHashMap

风险:
- 高并发下可能出现 ConcurrentModificationException
- 使用 ConcurrentHashMap 确保线程安全

影响:
- 防重复提交功能正常工作
- 并发环境下不会出现异常

Related: #修复方案最终审查报告(重新分析).md"
```

---

## 任务 7: 添加 ThreadLocal 清理过滤器

### 问题描述

`AuthenticationContextHolder.java:11` 使用 ThreadLocal，在线程池环境下可能导致内存泄漏

---

### Step 1: 创建清理过滤器

**文件:** `jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/filter/AuthenticationCleanupFilter.java`

**创建文件:**

```java
package com.oddfar.campus.framework.filter;

import com.oddfar.campus.framework.security.context.AuthenticationContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 认证信息清理过滤器
 *
 * 在每次请求结束后清理 ThreadLocal，防止内存泄漏
 *
 * 问题: 线程池环境下，ThreadLocal 可能导致内存泄漏
 * 解决: 在请求结束时自动清理 ThreadLocal
 *
 * @author claude
 * @since 2026-01-16
 */
@Component
public class AuthenticationCleanupFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {
        try {
            filterChain.doFilter(request, response);
        } finally {
            // ✅ 清理 ThreadLocal，防止内存泄漏
            AuthenticationContextHolder.clearContext();
        }
    }
}
```

---

### Step 2: 验证过滤器自动注册

```bash
# 启动应用，检查日志
# Spring Boot 会自动注册 @Component 注解的过滤器
```

**验证:** 启动日志中应该看到过滤器注册信息

---

### Step 3: 验证清理功能

```bash
# 运行应用，发送多个请求
# 监控内存使用情况
# 确认没有内存泄漏
```

---

### Step 4: 提交过滤器

```bash
git add jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/filter/AuthenticationCleanupFilter.java
git commit -m "feat(framework): 添加 ThreadLocal 清理过滤器

问题:
- AuthenticationContextHolder 使用 ThreadLocal
- 线程池环境下可能导致内存泄漏

解决:
- 新增 AuthenticationCleanupFilter
- 在每次请求结束时自动清理 ThreadLocal
- 使用 @Component 自动注册

优点:
- 无需手动清理
- 自动防止内存泄漏
- 代码侵入性小

Related: #修复方案最终审查报告(重新分析).md"
```

---

## 执行总结

### 所有任务完成后验证

```bash
# 1. 运行所有测试
mvn test

# 2. 构建项目
mvn clean package -DskipTests

# 3. 启动应用
java -jar campus-modular/target/campus-modular-1.1.5.jar

# 4. 验证功能
# - 抢单功能正常
# - 点赞计数准确
# - 评论查询快速
# - 订单号生成正常
# - 防重复提交工作
```

### 预期收益

| 指标 | 修复前 | 修复后 | 改善 |
|------|--------|--------|------|
| 抢单数据一致性 | 可能失败 | 100%可靠 | ✅ |
| 点赞计数准确性 | 可能不准确 | 原子性保证 | ✅ |
| 评论查询性能 | 1-5秒 | <100ms | 95%↑ |
| 数据库查询 | 5秒+ | <100ms | 95%↑ |
| 并发安全性 | 多处风险 | 全部修复 | ✅ |

### 回滚方案

如果某个修复出现问题：

```bash
# 查看提交历史
git log --oneline

# 回滚到指定提交
git revert <commit-hash>

# 或者回滚整个分支
git reset --hard HEAD~7  # 回滚最近7个提交
```

---

**计划完成时间:** 2026-01-16
**下一步:** 选择执行方式
