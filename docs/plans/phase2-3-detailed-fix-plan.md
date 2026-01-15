# JingWenWall 项目 Phase 2-3 详细修复计划

**文档版本**: 1.0
**创建日期**: 2026-01-16
**计划负责人**: Claude Code Architect
**项目**: JingWenWall(荆文校园枢纽)
**计划周期**: Phase 2(1-2周) + Phase 3(1个月) = 约6周

---

## 📋 目录

1. [执行摘要](#执行摘要)
2. [Phase 1 完成情况回顾](#phase-1-完成情况回顾)
3. [Phase 2 详细修复计划](#phase-2-详细修复计划)
4. [Phase 3 详细优化计划](#phase-3-详细优化计划)
5. [风险评估与应对](#风险评估与应对)
6. [验收标准](#验收标准)
7. [回滚计划](#回滚计划)
8. [关键文件清单](#关键文件清单)

---

## 执行摘要

### 项目现状

JingWenWall 项目已完成 Phase 1 的7个关键修复,但仍有 **350+** 个问题待解决:

| 阶段 | 已完成 | 待修复(P0) | 待修复(P1) | 待修复(P2) | 待修复(P3) |
|------|--------|-----------|-----------|-----------|-----------|
| Phase 1 | 7个任务 | 0 | 0 | 0 | 0 |
| Phase 2 | - | 50个 | 112个 | 0 | 0 |
| Phase 3 | - | 0 | 0 | 125个 | 56个 |

### Phase 2 目标(1-2周)

**主要目标**: 修复所有 P0 和 P1 严重问题,确保系统安全稳定运行

**预期收益**:
- ✅ 消除所有已知安全漏洞
- ✅ 解决所有并发安全隐患
- ✅ 修复所有业务逻辑漏洞
- ✅ 数据库性能提升95%+
- ✅ 代码质量达到9.0/10

### Phase 3 目标(1个月)

**主要目标**: 修复所有 P2 重要问题,建立代码质量规范

**预期收益**:
- ✅ 代码可维护性显著提升
- ✅ 前端代码规范化
- ✅ 建立自动化质量检查工具
- ✅ 技术债务显著减少

---

## Phase 1 完成情况回顾

### 已完成的7个任务

| # | 任务 | 影响 | 验证状态 |
|---|------|------|---------|
| 1 | 抢单并发问题修复 | 消除多骑手同时接单漏洞 | ✅ 已验证 |
| 2 | 点赞计数竞态条件修复 | 消除计数不准确问题 | ✅ 已验证 |
| 3 | 评论N+1查询修复 | 查询性能提升95% | ✅ 已验证 |
| 4 | 数据库索引添加 | 查询从5秒降至<100ms | ✅ 已验证 |
| 5 | SimpleDateFormat线程安全 | 消除并发环境日期解析错误 | ✅ 已验证 |
| 6 | HashMap并发修复 | 消除拦截器并发异常 | ✅ 已验证 |
| 7 | ThreadLocal清理 | 消除内存泄漏风险 | ✅ 已验证 |

### 技术债务剩余

- **数据库设计**: 67个问题(已完成索引和N+1查询修复,剩余65个)
- **业务逻辑**: 46个问题(已完成2个并发修复,剩余44个)
- **代码质量**: 89个问题(已完成3个线程安全,剩余86个)
- **安全问题**: 25个问题(剩余25个)
- **依赖配置**: 35个问题(剩余35个)
- **前端代码**: 88个问题(剩余88个)

---

## Phase 2 详细修复计划

### 优先级矩阵

```
影响程度
高 │ [P0:50个]  [P1:112个]
   │ 并发安全    业务逻辑
   │ 安全漏洞    代码质量
   │            配置管理
中 │
   │ 前端P1
   │
低 │
   └─────────────────────────────►
    立即执行    本周完成    2周内完成
```

### Phase 2 任务分组

#### Group A: 数据库优化(15个P1任务) - 16小时
#### Group B: 业务逻辑修复(44个任务:12个P0+18个P1+14个P2) - 32小时
#### Group C: 代码质量改进(34个P1任务) - 20小时
#### Group D: 安全加固(18个任务:10个P0+8个P1) - 12小时
#### Group E: 配置优化(12个P1任务) - 10小时
#### Group F: 前端清理(25个P1任务) - 16小时

**Phase 2 总工时**: 约 106 小时(2-3周,考虑测试和验证)

---

### Group A: 数据库优化(16小时)

#### A1. 唯一约束添加(2小时)

**任务 A1.1: 手机号唯一约束** ⏱️ 30分钟
```sql
-- 文件: jingwenhub/sql/add_unique_constraints.sql
-- 问题: 同一手机号可注册多个账号
ALTER TABLE sys_user
ADD UNIQUE INDEX uk_phonenumber (phonenumber) COMMENT '手机号唯一索引';
```

**涉及文件**:
- `jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/service/impl/SysUserServiceImpl.java`

**TDD测试用例**:
```java
// 测试文件: campus-framework/src/test/.../SysUserServiceTest.java
@Test
public void testDuplicatePhoneNumber() {
    // 1. 创建用户1
    UserDTO user1 = createTestUser("13800138000");
    userService.registerUser(user1);

    // 2. 尝试创建用户2,相同手机号
    UserDTO user2 = createTestUser("13800138000");

    // 3. 验证抛出异常
    assertThrows(ServiceException.class, () -> userService.registerUser(user2));
}
```

---

**任务 A1.2: 邮箱唯一约束** ⏱️ 30分钟
```sql
ALTER TABLE sys_user
ADD UNIQUE INDEX uk_email (email) COMMENT '邮箱唯一索引';
```

**任务 A1.3: 软删除唯一索引冲突修复** ⏱️ 1小时

**问题**: `bus_forum_post_collect` 的唯一索引包含 `del_flag`,导致软删除后无法再次收藏

**修复方案**:
```sql
-- 删除旧索引
ALTER TABLE bus_forum_post_collect DROP INDEX uk_user_post;

-- 创建新索引(不包含del_flag)
ALTER TABLE bus_forum_post_collect
ADD UNIQUE INDEX uk_user_post (user_id, post_id) COMMENT '用户帖子收藏唯一索引';

-- 使用触发器或应用层逻辑处理重复收藏
```

**涉及文件**:
- `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/forum/service/impl/ForumPostServiceImpl.java`
  - 方法: `collectPost()` (第242-275行)

**修复代码**:
```java
@Override
@Transactional(rollbackFor = Exception.class)
public void collectPost(Long postId) {
    Long userId = SecurityUtils.getUserId();

    // 检查是否存在收藏记录(包括已删除的)
    LambdaQueryWrapper<BusForumPostCollectEntity> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(BusForumPostCollectEntity::getUserId, userId)
           .eq(BusForumPostCollectEntity::getPostId, postId);

    BusForumPostCollectEntity existEntity = collectMapper.selectOne(wrapper);

    if (existEntity == null) {
        // 不存在,插入新记录
        BusForumPostCollectEntity collectEntity = new BusForumPostCollectEntity();
        collectEntity.setUserId(userId);
        collectEntity.setPostId(postId);
        collectEntity.setDelFlag(0);
        collectMapper.insert(collectEntity);

        // 增加收藏计数
        forumPostMapper.incrementCollectCount(postId);
    } else if (existEntity.getDelFlag() == 1) {
        // 已软删除,恢复
        existEntity.setDelFlag(0);
        collectMapper.updateById(existEntity);

        // 增加收藏计数
        forumPostMapper.incrementCollectCount(postId);
    } else {
        // 已收藏,抛出异常
        throw new ServiceException("已经收藏过了");
    }
}
```

---

#### A2. LIKE查询优化(3小时)

**任务 A2.1: 用户名LIKE查询优化** ⏱️ 1小时

**问题位置**: `ContentMapper.xml:106`
```xml
<!-- ❌ 问题: 前置通配符导致索引失效 -->
<if test="params.userName != null and params.userName != ''">
    AND u.user_name like concat('%', #{params.userName}, '%')
</if>
```

**修复方案3选1**:

**方案1: 后置通配符(推荐,快速修复)**
```xml
<if test="params.userName != null and params.userName != ''">
    AND u.user_name like concat(#{params.userName}, '%')
</if>
```

**方案2: 全文索引(中期方案)**
```sql
ALTER TABLE sys_user ADD FULLTEXT INDEX ft_user_name (user_name) WITH PARSER ngram;
```
```xml
<if test="params.userName != null and params.userName != ''">
    AND MATCH(u.user_name) AGAINST(#{params.userName} IN NATURAL LANGUAGE MODE)
</if>
```

**方案3: Elasticsearch(长期方案)**

**涉及文件**:
- `jingwenhub/campus-modular/src/main/resources/mapper/ContentMapper.xml`
- `jingwenhub/campus-modular/src/main/resources/mapper/MarketItemMapper.xml`

**TDD测试用例**:
```java
@Test
public void testUserNameSearchPerformance() {
    // 1. 准备1000条测试数据
    for (int i = 0; i < 1000; i++) {
        createTestUser("user" + i);
    }

    // 2. 测试查询性能
    long startTime = System.currentTimeMillis();
    List<ContentVO> results = contentService.searchByUserName("user1");
    long endTime = System.currentTimeMillis();

    // 3. 验证性能 < 200ms
    assertTrue(endTime - startTime < 200, "查询时间应小于200ms");
}
```

---

**任务 A2.2: 商品标题LIKE查询优化** ⏱️ 1小时

**问题位置**: `MarketItemMapper.xml:70`

**修复方案**: 同上

**任务 A2.3: 内容搜索LIKE查询优化** ⏱️ 1小时

**问题位置**: `ContentMapper.xml:121`

---

#### A3. 字符集统一(4小时)

**任务 A3.1: 旧表字符集转换** ⏱️ 2小时

```sql
-- 文件: jingwenhub/sql/convert_charset_to_utf8mb4.sql
USE jingwen_campus;

-- 转换 campus_content
ALTER TABLE campus_content
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 转换 campus_comment
ALTER TABLE campus_comment
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 转换 sys_user
ALTER TABLE sys_user
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 转换 sys_role
ALTER TABLE sys_role
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 验证转换结果
SHOW TABLE STATUS WHERE Name IN ('campus_content', 'campus_comment', 'sys_user');
```

**风险**:
- ⚠️ 表锁时间较长(大表可能需要数分钟)
- ⚠️ 需要在低峰期执行

**执行步骤**:
1. 备份数据库
2. 在测试环境验证
3. 选择凌晨低峰期执行
4. 逐表转换,观察性能影响

---

**任务 A3.2: 连接字符串字符集配置** ⏱️ 1小时

**修改文件**: `jingwenhub/campus-modular/src/main/resources/application.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/jingwen_campus?useUnicode=true&characterEncoding=utf8mb4&serverTimezone=Asia/Shanghai
```

**任务 A3.3: MyBatis字符集配置** ⏱️ 1小时

**修改文件**: `application.yml`

```yaml
mybatis-plus:
  configuration:
    default-charset: utf8mb4
```

---

#### A4. SELECT * 查询优化(2小时)

**任务 A4.1: MarketCollectMapper优化** ⏱️ 30分钟

**问题位置**: `MarketCollectMapper.xml:25`

**修复前**:
```xml
<select id="selectCollectList" resultType="...">
    SELECT * FROM bus_market_collect WHERE ...
</select>
```

**修复后**:
```xml
<select id="selectCollectList" resultType="com.oddfar.campus.business.market.domain.vo.MarketCollectVO">
    SELECT
        collect_id,
        user_id,
        item_id,
        create_time,
        del_flag
    FROM bus_market_collect
    WHERE ...
</select>
```

**任务 A4.2: ErrandRunnerMapper优化** ⏱️ 30分钟

**问题位置**: `ErrandRunnerMapper.xml:51`

**任务 A4.3: ErrandOrderMapper优化** ⏱️ 30分钟

**问题位置**: `ErrandOrderMapper.xml:122`

**任务 A4.4: 全局扫描SELECT *** ⏱️ 30分钟

使用 Grep 查找所有 SELECT *:
```bash
grep -rn "SELECT \*" --include="*.xml" jingwenhub/campus-modular/src/main/resources/mapper/
```

---

#### A5. 日期函数索引失效修复(2小时)

**任务 A5.1: ContentMapper日期查询优化** ⏱️ 1小时

**问题位置**: `ContentMapper.xml:133-136`

**修复前**:
```xml
<if test="params.beginTime != null">
    AND date_format(c.create_time,'%y%m%d') &gt;= date_format(#{params.beginTime},'%y%m%d')
</if>
```

**修复后**:
```xml
<if test="params.beginTime != null">
    AND c.create_time &gt;= #{params.beginTime}
</if>
<if test="params.endTime != null">
    AND c.create_time &lt;= #{params.endTime}
</if>
```

**涉及文件**:
- `ContentMapper.xml`
- `ForumPostMapper.xml`
- `ErrandOrderMapper.xml`

**任务 A5.2: 其他日期查询扫描** ⏱️ 1小时

---

#### A6. 分页LIMIT添加(3小时)

**任务 A6.1: ForumPost最新帖子查询** ⏱️ 1小时

**问题位置**: `ForumPostMapper.xml:87-92`

**修复前**:
```xml
<select id="selectNewestPosts" resultMap="...">
    SELECT ... FROM bus_forum_post
    WHERE status = 1
    ORDER BY create_time DESC
    <!-- ❌ 缺少LIMIT -->
</select>
```

**修复后**:
```xml
<select id="selectNewestPosts" resultMap="...">
    SELECT ... FROM bus_forum_post
    WHERE status = 1
    ORDER BY create_time DESC
    LIMIT 100  <!-- ✅ 添加LIMIT -->
</select>
```

**任务 A6.2: 热门帖子查询** ⏱️ 1小时

**问题位置**: `ForumPostMapper.xml:95-100`

**任务 A6.3: 内容列表查询** ⏱️ 1小时

**问题位置**: `ContentMapper.xml:169-174`

---

#### A7. 外键约束添加(可选,4小时)

**⚠️ 注意**: 此任务风险较高,需要充分测试

**任务 A7.1: 论坛帖子外键** ⏱️ 1小时

```sql
-- 文件: jingwenhub/sql/add_foreign_keys.sql
ALTER TABLE bus_forum_post
ADD CONSTRAINT fk_post_user
    FOREIGN KEY (user_id) REFERENCES sys_user(user_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_post_category
    FOREIGN KEY (category_id) REFERENCES bus_forum_category(category_id) ON DELETE SET NULL;
```

**任务 A7.2: 评论外键** ⏱️ 1小时

**任务 A7.3: 订单外键** ⏱️ 1小时

**任务 A7.4: 外键约束测试** ⏱️ 1小时

---

### Group B: 业务逻辑修复(32小时)

#### B1. 并发安全修复(剩余10个P0任务,12小时)

**任务 B1.1: 余额并发控制** ⏱️ 2小时 🔴 P0

**问题位置**: `BusStudentServiceImpl.java:90-97`

**漏洞代码**:
```java
public boolean updateBalance(Long studentId, BigDecimal amount) {
    int rows = busStudentMapper.updateBalance(studentId, amount);
    // ❌ 没有检查余额是否足够
    // ❌ 没有加锁
    // ❌ 没有乐观锁
    return rows > 0;
}
```

**修复方案**:

**Step 1: 添加乐观锁字段**
```sql
ALTER TABLE bus_student ADD COLUMN version INT DEFAULT 0 COMMENT '乐观锁版本号';
UPDATE bus_student SET version = 0 WHERE version IS NULL;
ALTER TABLE bus_student ADD UNIQUE INDEX uk_student_version (student_id, version);
```

**Step 2: 修改实体类**
```java
@Version
private Integer version;
```

**Step 3: 实现并发安全的余额更新**
```java
@Transactional(rollbackFor = Exception.class)
public boolean updateBalance(Long studentId, BigDecimal amount) {
    String lockKey = "lock:student:balance:" + studentId;

    try {
        // 1. 获取分布式锁
        Boolean locked = redisCache.tryLock(lockKey, 5, TimeUnit.SECONDS);
        if (!locked) {
            throw new ServiceException("操作频繁,请稍后再试");
        }

        // 2. 查询当前余额
        BusStudentEntity student = getById(studentId);
        if (student == null) {
            throw new ServiceException("学生信息不存在");
        }

        // 3. 检查余额是否足够(扣款场景)
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            if (student.getBalance().compareTo(amount.abs()) < 0) {
                throw new ServiceException("余额不足");
            }
        }

        // 4. 使用乐观锁更新
        student.setBalance(student.getBalance().add(amount));
        int rows = busStudentMapper.updateById(student);  // MyBatis-Plus自动使用@Version

        if (rows == 0) {
            throw new ServiceException("余额更新失败,请重试");
        }

        // 5. 记录余额变动日志
        recordBalanceLog(studentId, amount, student.getBalance());

        return true;
    } finally {
        redisCache.unlock(lockKey);
    }
}
```

**TDD测试用例**:
```java
@Test
public void testConcurrentBalanceUpdate() throws Exception {
    // 1. 创建学生,初始余额100元
    Long studentId = createTestStudent(new BigDecimal("100"));

    // 2. 3个线程并发扣款(每次50元)
    CountDownLatch latch = new CountDownLatch(3);
    AtomicInteger successCount = new AtomicInteger(0);

    for (int i = 0; i < 3; i++) {
        new Thread(() -> {
            try {
                latch.await();
                studentService.updateBalance(studentId, new BigDecimal("-50"));
                successCount.incrementAndGet();
            } catch (ServiceException e) {
                // 余额不足,符合预期
            } catch (Exception e) {
                fail(" unexpected exception");
            }
        }).start();
    }

    latch.countDown();
    latch.countDown();
    latch.countDown();
    Thread.sleep(1000);

    // 3. 验证: 只有1个成功扣款,最终余额50元
    assertEquals(1, successCount.get());
    BusStudentEntity student = studentService.getById(studentId);
    assertEquals(new BigDecimal("50"), student.getBalance());
}
```

**涉及文件**:
- `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/service/impl/BusStudentServiceImpl.java`
- `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/domain/entity/BusStudentEntity.java`
- `jingwenhub/campus-modular/src/main/resources/mapper/BusStudentMapper.xml`

---

**任务 B1.2: 浏览量统计并发** ⏱️ 1.5小时 🔴 P0

**问题位置**:
- `ForumPostServiceImpl.java` - view_count
- `MarketItemServiceImpl.java` - view_count
- `ContentServiceImpl.java` - view_count

**修复方案**: 使用Redis计数器 + 异步同步

```java
// 1. 浏览时增加Redis计数
public void incrementViewCount(Long postId) {
    String key = "post:view:" + postId;
    redisCache.increment(key);

    // 异步同步到数据库(每100次浏览或1分钟同步一次)
    if (shouldSyncToDatabase(key)) {
        asyncSyncViewCount(postId);
    }
}

@Async
@Scheduled(fixedDelay = 60000)  // 每分钟执行一次
public void syncAllViewCounts() {
    // 批量同步Redis中的浏览量到数据库
}
```

**任务 B1.3: 微信登录code重复使用** ⏱️ 1.5小时 🔴 P0

**问题位置**: `WxAuthServiceImpl.java:156-198`

**修复方案**: 添加code使用记录
```java
@Transactional(rollbackFor = Exception.class)
public LoginUser login(String code) {
    // 1. 检查code是否已使用
    String cacheKey = "wx:login:code:" + code;
    Boolean isUsed = redisCache.getCacheObject(cacheKey);
    if (isUsed != null && isUsed) {
        throw new ServiceException("code已使用,请重新获取");
    }

    // 2. 调用微信API
    WxMaJscode2SessionResult session = ...;

    // 3. 标记code已使用
    redisCache.setCacheObject(cacheKey, true, 5, TimeUnit.MINUTES);

    // 4. 后续登录逻辑
    ...
}
```

**任务 B1.4: 评论删除级联处理** ⏱️ 2小时 🔴 P0

**问题**: 删除评论时,子评论未被处理

**修复方案**:
```java
@Transactional(rollbackFor = Exception.class)
public void deleteComment(Long commentId) {
    // 1. 查找所有子评论
    List<Long> childIds = commentMapper.selectChildIds(commentId);

    // 2. 递归删除所有子评论
    for (Long childId : childIds) {
        deleteComment(childId);
    }

    // 3. 软删除当前评论
    commentMapper.deleteById(commentId);

    // 4. 更新帖子评论数
    forumPostMapper.decrementCommentCount(postId);
}
```

**任务 B1.5: 订单状态机完善** ⏱️ 2小时 🔴 P0

**问题位置**: `ErrandOrderServiceImpl.java:360-375`

**修复方案**: 使用状态模式
```java
public enum OrderStatus {
    WAITING(1, "待接单", Arrays.asList(ACCEPTED, CANCELLED)),
    ACCEPTED(2, "已接单", Arrays.asList(PICKING, CANCELLED)),
    PICKING(3, "取货中", Arrays.asList(DELIVERING, CANCELLED)),
    DELIVERING(4, "配送中", Arrays.asList(COMPLETED, CANCELLED)),
    COMPLETED(5, "已完成", Collections.emptyList()),
    CANCELLED(6, "已取消", Collections.emptyList());

    private Integer code;
    private String desc;
    private List<OrderStatus> nextStates;

    public boolean canTransitionTo(OrderStatus next) {
        return nextStates.contains(next);
    }
}

// 使用
public void updateStatus(Long orderId, OrderStatus newStatus) {
    ErrandOrderEntity order = getById(orderId);
    OrderStatus currentStatus = OrderStatus.fromCode(order.getStatus());

    if (!currentStatus.canTransitionTo(newStatus)) {
        throw new ServiceException("状态转换不合法: " + currentStatus + " -> " + newStatus);
    }

    order.setStatus(newStatus.getCode());
    updateById(order);
}
```

**任务 B1.6: 订单取消退款逻辑** ⏱️ 1.5小时 🔴 P0

**问题位置**: `ErrandOrderServiceImpl.java: cancelOrder()`

**修复方案**:
```java
@Transactional(rollbackFor = Exception.class)
public void cancelOrder(Long orderId, String reason) {
    ErrandOrderEntity order = getById(orderId);

    // 1. 检查状态
    if (!OrderStatus.fromCode(order.getStatus()).canCancel()) {
        throw new ServiceException("当前状态不允许取消");
    }

    // 2. 已支付订单需要退款
    if (PayStatus.PAID.getCode().equals(order.getPayStatus())) {
        // 退款到余额
        studentService.updateBalance(order.getPublisherId(), order.getTotalFee());

        // 记录退款日志
        recordRefundLog(orderId, order.getTotalFee(), reason);
    }

    // 3. 更新订单状态
    order.setStatus(OrderStatus.CANCELLED.getCode());
    order.setCancelReason(reason);
    updateById(order);
}
```

**任务 B1.7-B1.10: 其他并发安全修复** ⏱️ 3.5小时

---

#### B2. 业务逻辑漏洞修复(18个P1任务,10小时)

**任务 B2.1: 订单金额校验** ⏱️ 1小时 🔴 P1

**问题位置**: `ErrandOrderServiceImpl.java:89-120`

**修复方案**: 添加DTO校验注解
```java
public class ErrandOrderDTO {

    @NotNull(message = "订单类型不能为空")
    @Min(value = 1, message = "订单类型不合法")
    @Max(value = 3, message = "订单类型不合法")
    private Integer type;

    @NotBlank(message = "取货地址不能为空")
    @Size(max = 200, message = "取货地址长度不能超过200字符")
    private String pickupAddr;

    @DecimalMin(value = "0.00", message = "小费不能为负数")
    @DecimalMax(value = "100.00", message = "小费不能超过100元")
    private BigDecimal tip;

    @NotNull(message = "期望时间不能为空")
    @Future(message = "期望时间必须是未来时间")
    private Date expectTime;
}
```

**任务 B2.2: 权限控制完善** ⏱️ 2小时 🔴 P1

**问题位置**: `ErrandOrderServiceImpl.java:71-86`

**修复方案**: 敏感信息脱敏
```java
public ErrandOrderVO getOrderDetail(Long orderId) {
    ErrandOrderVO vo = errandOrderMapper.selectOrderDetail(orderId);

    if (vo == null) {
        throw new ServiceException("订单不存在");
    }

    // 权限判断
    Long currentUserId = SecurityUtils.getUserId();
    boolean isMine = currentUserId.equals(vo.getPublisherId());
    boolean isRunner = currentUserId.equals(vo.getRunnerId());
    boolean isAdmin = SecurityUtils.isAdmin();

    if (!isMine && !isRunner && !isAdmin) {
        // 无权查看,脱敏敏感信息
        vo.setDeliveryAddr(maskAddress(vo.getDeliveryAddr()));
        vo.setPickupAddr(maskAddress(vo.getPickupAddr()));
        vo.setPublisherPhone(maskPhone(vo.getPublisherPhone()));
        vo.setRunnerPhone(maskPhone(vo.getRunnerPhone()));
    }

    return vo;
}

private String maskAddress(String address) {
    if (address == null || address.length() <= 4) {
        return "***";
    }
    return address.substring(0, 4) + "***";
}

private String maskPhone(String phone) {
    if (phone == null || phone.length() != 11) {
        return "***";
    }
    return phone.substring(0, 3) + "****" + phone.substring(7);
}
```

**任务 B2.3-B2.18: 其他业务逻辑修复** ⏱️ 7小时

---

#### B3. 数据校验增强(12个任务,6小时)

**任务 B3.1: @Valid注解添加** ⏱️ 2小时

**涉及文件**:
- `ForumPostController.java:74-78` - saveDraft
- `BusStudentController.java:56` - updateInfo
- `MarketItemController.java` - 所有@RequestBody参数

**修复**:
```java
@PostMapping
public R<Void> savePost(@Valid @RequestBody ForumPostDTO dto) {
    forumPostService.savePost(dto);
    return R.success();
}
```

**任务 B3.2: 分页参数maxSize限制** ⏱️ 1.5小时

**修复**:
```java
@GetMapping("/list")
public R<PageResult<ForumPostVO>> list(
    @RequestParam(defaultValue = "1") @Min(1) Integer pageNum,
    @RequestParam(defaultValue = "10") @Min(1) @Max(100) Integer pageSize
) {
    return R.success(forumPostService.listPosts(pageNum, pageSize));
}
```

**任务 B3.3-B3.12: 其他数据校验** ⏱️ 2.5小时

---

#### B4. 异常处理改进(8个任务,4小时)

**任务 B4.1: 过宽异常捕获修复** ⏱️ 2小时

**示例**:
```java
// ❌ 修复前
try {
    return Byte.parseByte(valueStr);
} catch (Exception e) {
    return defaultValue;
}

// ✅ 修复后
try {
    return Byte.parseByte(valueStr);
} catch (NumberFormatException e) {
    log.debug("数字格式错误: {}", valueStr);
    return defaultValue;
}
```

**涉及文件**(34处):
- `Convert.java:108`
- `HttpUtils.java:92`
- 其他工具类

**任务 B4.2: 内容安全检查异常修复** ⏱️ 1小时

**问题位置**: `WxAuthServiceImpl.java:230-232`

**修复前**:
```java
} catch (Exception e) {
    log.error("内容安全检查异常", e);
    return true;  // ❌ 异常时放行
}
```

**修复后**:
```java
} catch (Exception e) {
    log.error("内容安全检查异常,拒绝发布", e);
    return false;  // ✅ 异常时拒绝
}
```

**任务 B4.3-B4.8: 其他异常处理** ⏱️ 1小时

---

### Group C: 代码质量改进(20小时)

#### C1. 异常处理规范(34个任务,8小时)

**任务 C1.1: 全局异常处理器增强** ⏱️ 2小时

**文件**: `campus-framework/src/main/java/com/oddfar/campus/framework/web/exception/GlobalExceptionHandler.java`

**新增方法**:
```java
@ExceptionHandler(NumberFormatException.class)
public R<Void> handleNumberFormatException(NumberFormatException e) {
    log.error("数字格式异常", e);
    return R.error("数字格式不正确");
}

@ExceptionHandler(DateTimeParseException.class)
public R<Void> handleDateTimeParseException(DateTimeParseException e) {
    log.error("日期时间解析异常", e);
    return R.error("日期时间格式不正确");
}

@ExceptionHandler(SQLIntegrityConstraintViolationException.class)
public R<Void> handleSQLIntegrityConstraintViolationException(SQLIntegrityConstraintViolationException e) {
    log.error("SQL约束违反异常", e);
    String message = e.getMessage();
    if (message.contains("uk_phonenumber")) {
        return R.error("手机号已存在");
    } else if (message.contains("uk_email")) {
        return R.error("邮箱已存在");
    }
    return R.error("数据约束违反,请检查输入");
}
```

**任务 C1.2-C1.34: 逐个修复过宽catch** ⏱️ 6小时

---

#### C2. 代码坏味道消除(20个任务,12小时)

**任务 C2.1: 超长类拆分** ⏱️ 4小时

**Convert.java (849行) - 拆分为**:
- `DateConvertUtils.java` - 日期转换
- `StringConvertUtils.java` - 字符串转换
- `NumberConvertUtils.java` - 数字转换
- `CollectionConvertUtils.java` - 集合转换

**任务 C2.2: 魔法数字提取为常量** ⏱️ 2小时

**示例**:
```java
// ❌ 修复前
if (hours > 24) {
    throw new ServiceException("时间不能超过24小时");
}

// ✅ 修复后
private static final int MAX_ORDER_HOURS = 24;

if (hours > MAX_ORDER_HOURS) {
    throw new ServiceException("时间不能超过" + MAX_ORDER_HOURS + "小时");
}
```

**任务 C2.3: 硬编码字符串移至配置** ⏱️ 1小时

**文件**: `AddressUtils.java`, `WxAuthServiceImpl.java`

**修复**:
```yaml
# application.yml
wechat:
  api:
    code2session: https://api.weixin.qq.com/sns/jscode2session
```

```java
@Value("${wechat.api.code2session}")
private String code2SessionUrl;
```

**任务 C2.4-C2.20: 其他代码坏味道修复** ⏱️ 5小时

---

### Group D: 安全加固(12小时)

#### D1. 依赖升级(8小时)

**任务 D1.1: Spring Boot升级** ⏱️ 4小时 🔴 P0

**从**: 2.5.14 (存在CVE-2022-22965 Spring4Shell漏洞)
**到**: 2.7.18

**修改文件**: `jingwenhub/pom.xml`

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>2.7.18</version>  <!-- 从 2.5.14 升级 -->
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

**兼容性检查**:
- ✅ JDK 8 兼容
- ✅ MyBatis-Plus 3.5.2 兼容
- ⚠️ 需要测试: Spring Security配置

**回滚计划**: 保留2.5.14的pom.xml备份

**任务 D1.2: 其他依赖升级** ⏱️ 4小时

详见 `docs/fixes/Phase1.4-依赖升级方案.md`

---

#### D2. 敏感信息移除(已完成,0小时)

**✅ 已在 Phase 1 完成**

---

#### D3. 默认密码修改(1小时)

**任务 D3.1: 生成随机密码** ⏱️ 1小时

**问题位置**: `WeiXinAuthServiceImpl.java:105,198`

**修复前**:
```java
userEntity.setPassword(SecurityUtils.encryptPassword("123456"));
```

**修复后**:
```java
// 生成随机强密码(12位,包含大小写字母、数字、特殊字符)
String randomPassword = generateStrongPassword(12);
userEntity.setPassword(SecurityUtils.encryptPassword(randomPassword));

// 发送密码到用户邮箱或微信
sendPasswordToUser(userEntity, randomPassword);
}

private String generateStrongPassword(int length) {
    String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
    SecureRandom random = new SecureRandom();
    return random.ints(length, 0, chars.length())
                .mapToObj(chars::charAt)
                .map(String::valueOf)
                .collect(Collectors.joining());
}
```

---

#### D4. Token有效期调整(1小时)

**任务 D4.1: 缩短Token有效期** ⏱️ 1小时

**问题**: 24小时(1440分钟)过长

**修复**: `application.yml`

```yaml
token:
  expireTime: 120  # 2小时
  refreshExpireTime: 10080  # 7天
```

**同时实现refreshToken机制**:
```java
// 登录时返回两个token
public R<Map<String, String>> login(String username, String password) {
    // ...
    String accessToken = tokenService.generateToken(userId);
    String refreshToken = tokenService.generateRefreshToken(userId);

    Map<String, String> tokens = new HashMap<>();
    tokens.put("accessToken", accessToken);
    tokens.put("refreshToken", refreshToken);
    tokens.put("expireTime", "120");

    return R.success(tokens);
}
```

---

#### D5. 其他安全加固(2小时)

**任务 D5.1: 权限校验恢复** ⏱️ 1小时

**扫描被注释的@PreAuthorize**

```bash
grep -rn "// @PreAuthorize" --include="*.java" jingwenhub/
```

**任务 D5.2: 文件上传类型验证** ⏱️ 1小时

**问题**: 当前只验证MIME类型,可被绕过

**修复**:
```java
@PostMapping("/upload")
public R<String> upload(@RequestParam("file") MultipartFile file) {
    // 1. 验证文件扩展名
    String originalFilename = file.getOriginalFilename();
    String extension = FileUtils.getExtension(originalFilename);

    if (!ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
        throw new ServiceException("不支持的文件类型");
    }

    // 2. 验证文件内容(Magic Number)
    if (!isValidImageFile(file.getInputStream())) {
        throw new ServiceException("文件内容不合法");
    }

    // 3. 限制文件大小
    if (file.getSize() > MAX_FILE_SIZE) {
        throw new ServiceException("文件大小超过限制");
    }

    // ...
}

private boolean isValidImageFile(InputStream inputStream) {
    try {
        byte[] header = new byte[8];
        inputStream.read(header);

        // JPEG: FF D8 FF
        if (header[0] == (byte) 0xFF && header[1] == (byte) 0xD8 && header[2] == (byte) 0xFF) {
            return true;
        }

        // PNG: 89 50 4E 47
        if (header[0] == (byte) 0x89 && header[1] == (byte) 0x50 &&
            header[2] == (byte) 0x4E && header[3] == (byte) 0x47) {
            return true;
        }

        return false;
    } catch (IOException e) {
        return false;
    }
}
```

---

### Group E: 配置优化(10小时)

#### E1. 配置文件优化(12个任务,6小时)

**任务 E1.1: Redis配置统一** ⏱️ 2小时

**问题**: 开发环境Redis配置冲突

**修复**: 创建profile-specific配置
```yaml
# application-dev.yml
spring:
  redis:
    host: 127.0.0.1
    port: 6379
    database: 0

# application-test.yml
spring:
  redis:
    host: 192.168.1.100
    port: 6379
    database: 1

# application-prod.yml
spring:
  redis:
    host: ${REDIS_HOST:prod-redis.example.com}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD}
    database: 0
```

**任务 E1.2: 线程池配置优化** ⏱️ 1.5小时

**问题**: 核心线程50过大

**修复**: `ThreadPoolConfig.java`
```java
@Bean
public ThreadPoolExecutor taskExecutor() {
    return new ThreadPoolExecutor(
        10,  // corePoolSize: 从50降到10
        200,  // maximumPoolSize
        60L,  // keepAliveTime
        TimeUnit.SECONDS,
        new LinkedBlockingQueue<>(1000),
        new ThreadFactory() {
            private final AtomicInteger threadNumber = new AtomicInteger(1);
            @Override
            public Thread newThread(Runnable r) {
                return new Thread(r, "async-pool-" + threadNumber.getAndIncrement());
            }
        },
        new ThreadPoolExecutor.CallerRunsPolicy()
    );
}
```

**任务 E1.3: MyBatis日志配置** ⏱️ 1小时

**问题**: 生产环境使用StdOutImpl

**修复**:
```yaml
# application-dev.yml
mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl

# application-prod.yml
mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.slf4j.Slf4jImpl
logging:
  level:
    com.oddfar.campus.business.mapper: DEBUG
```

**任务 E1.4-E1.12: 其他配置优化** ⏱️ 1.5小时

---

#### E2. Swagger生产环境关闭(1小时)

**任务 E2.1: 条件注解** ⏱️ 1小时

**修复**: `SwaggerConfig.java`
```java
@Configuration
@ConditionalOnProperty(name = "swagger.enabled", havingValue = "true")
@EnableOpenApi
public class SwaggerConfig {
    // ...
}
```

```yaml
# application-prod.yml
swagger:
  enabled: false
```

---

#### E3. 配置中心引入(可选,3小时)

**任务 E3.1: Apollo或Nacos集成** ⏱️ 3小时

**说明**: Phase 3可选任务

---

### Group F: 前端清理(16小时)

#### F1. 管理后台清理(10小时)

**任务 F1.1: console.log清理** ⏱️ 3小时

**使用工具**:
```bash
cd jingwenhub/vue_campus_admin
npm install eslint-plugin-no-console --save-dev
```

**配置**: `.eslintrc.js`
```javascript
rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
}
```

**批量删除**:
```bash
# 查找所有console.log
grep -rn "console.log" src/

# 使用sed批量删除(小心操作!)
# sed -i '/console\.log/d' src/**/*.vue
# sed -i '/console\.log/d' src/**/*.js
```

**任务 F1.2: 空catch块修复** ⏱️ 2小时

**问题位置**: `src/router/index.js:170`

**修复前**:
```javascript
} catch (error) {
  // 空catch块
}
```

**修复后**:
```javascript
} catch (error) {
  console.error('路由加载失败:', error);
  router.push('/500');
}
```

**任务 F1.3: 定时器清理** ⏱️ 2小时

**问题**: 13处定时器未清理

**修复**:
```javascript
// ❌ 修复前
mounted() {
  this.timer = setInterval(() => {
    this.fetchData();
  }, 5000);
}

// ✅ 修复后
mounted() {
  this.timer = setInterval(() => {
    this.fetchData();
  }, 5000);
},

beforeUnmount() {  // Vue3使用beforeUnmount
  if (this.timer) {
    clearInterval(this.timer);
    this.timer = null;
  }
}
```

**任务 F1.4-F1.10: 其他管理后台清理** ⏱️ 3小时

---

#### F2: 小程序清理(6小时)

**任务 F2.1: console.log清理** ⏱️ 2小时

**文件**: `uniapp/src/**/*.vue`

**任务 F2.2: 硬编码IP移除** ⏱️ 1小时

**已完成**: 见 `docs/fixes/Phase1.2-前端敏感信息移除方案.md`

**任务 F2.3: mapKey移至环境变量** ⏱️ 1小时

**修复**: `uniapp/src/utils/env.js`
```javascript
// ❌ 修复前
const mapkey = 'RSNBZ-3ABW4-MF3UK-FMCJP-JC4YT-RUFTR'

// ✅ 修复后
const mapkey = process.env.TENCENT_MAP_KEY || 'YOUR_MAP_KEY'
```

**任务 F2.4-F2.6: 其他小程序清理** ⏱️ 2小时

---

## Phase 3 详细优化计划

### Phase 3 目标

- ✅ 修复所有P2重要问题(125个)
- ✅ 建立代码质量规范
- ✅ 引入自动化质量工具
- ✅ 技术债务清零

### Phase 3 任务分组

#### Group G: 代码规范和重构(30小时)

**任务 G1: 字段注入改为构造函数注入** ⏱️ 16小时

**范围**: 96处@Autowired字段注入

**工具**: IntelliJ IDEA重构工具
```java
// ❌ 修复前
@Autowired
private ErrandOrderMapper orderMapper;

// ✅ 修复后
private final ErrandOrderMapper orderMapper;

public ErrandOrderServiceImpl(ErrandOrderMapper orderMapper) {
    this.orderMapper = orderMapper;
}
```

**任务 G2: 复杂度降低** ⏱️ 8小时

**目标**: 所有方法圈复杂度 < 10

**工具**: SonarQube扫描

**任务 G3: 代码重复消除** ⏱️ 6小时

**工具**: SonarQube CPD (Copy/Paste Detector)

---

#### Group H: 性能优化(25小时)

**任务 H1: 缓存策略优化** ⏱️ 8小时

**场景**:
- 用户信息缓存(30分钟)
- 字典数据缓存(1小时)
- 热门帖子缓存(10分钟)

**任务 H2: 查询优化** ⏱️ 10小时

**使用EXPLAIN分析慢查询**

**任务 H3: 批量操作优化** ⏱️ 7小时

**使用MyBatis-Plus批量插入**

---

#### Group I: 测试覆盖(30小时)

**任务 I1: 单元测试编写** ⏱️ 20小时

**目标**: 核心业务逻辑覆盖率 > 70%

**任务 I2: 集成测试编写** ⏱️ 10小时

---

#### Group J: 文档和规范(20小时)

**任务 J1: API文档完善** ⏱️ 8小时

**使用Swagger注解**

**任务 J2: 开发规范编写** ⏱️ 6小时

**任务 J3: 部署文档编写** ⏱️ 6小时

---

#### Group K: 质量工具引入(20小时)

**任务 K1: SonarQube集成** ⏱️ 8小时

**任务 K2: ESLint/Prettier配置** ⏱️ 6小时

**任务 K3: CI/CD流程建立** ⏱️ 6小时

---

## 风险评估与应对

### 高风险任务

| 任务 | 风险 | 应对措施 |
|------|------|---------|
| Spring Boot升级 | 破坏性变更 | 充分测试,保留回滚版本 |
| 外键约束添加 | 性能影响,级联删除 | 先在测试环境验证 |
| 字符集转换 | 表锁时间长 | 低峰期执行,分批转换 |
| 余额并发修复 | 业务逻辑复杂 | TDD测试,灰度发布 |

### 中风险任务

| 任务 | 风险 | 应对措施 |
|------|------|---------|
| 代码拆分 | 引入新bug | 充分测试,代码review |
| 状态机重构 | 状态转换错误 | 状态转换图,单元测试 |
| 配置优化 | 环境差异 | 多环境测试 |

### 回滚策略

**数据库变更回滚**:
```sql
-- 回滚脚本示例: jingwenhub/sql/rollback_phase2.sql
DROP INDEX idx_user_status_time ON campus_content;
DROP INDEX uk_phonenumber ON sys_user;
```

**代码变更回滚**:
```bash
# Git回滚
git revert <commit-hash>
git push origin main
```

---

## 验收标准

### Phase 2 验收标准

- [ ] 所有P0问题修复完成
- [ ] 所有P1问题修复完成
- [ ] 通过安全扫描(无高危漏洞)
- [ ] 并发测试通过(100并发抢单)
- [ ] 性能测试通过(TPS > 1000)
- [ ] 单元测试覆盖率 > 50%

### Phase 3 验收标准

- [ ] 所有P2问题修复完成
- [ ] 代码质量评分 > 9.0/10
- [ ] SonarQube无严重问题
- [ ] 单元测试覆盖率 > 70%
- [ ] 文档完整度 > 80%

---

## 关键文件清单

### Critical Files for Implementation

- **E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\java\com\oddfar\campus\business\errand\service\impl\ErrandOrderServiceImpl.java** - 跑腿订单核心逻辑(并发安全、状态机)
- **E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\java\com\oddfar\campus\business\forum\service\impl\ForumPostServiceImpl.java** - 论坛帖子核心逻辑(点赞、收藏)
- **E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\java\com\oddfar\campus\business\service\impl\BusStudentServiceImpl.java** - 学生余额管理(并发控制)
- **E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources\mapper\** - 所有Mapper.xml(SQL优化)
- **E:\wxxcx\JingWenWall\jingwenhub\sql\** - 数据库脚本执行目录
- **E:\wxxcx\JingWenWall\jingwenhub\pom.xml** - Maven依赖管理(Spring Boot升级)
- **E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources\application.yml** - 配置文件优化
- **E:\wxxcx\JingWenWall\uniapp\src\utils\env.js** - 小程序环境配置
- **E:\wxxcx\JingWenWall\jingwenhub\vue_campus_admin\src\** - 管理后台代码清理

---

## 附录

### A. 执行时间线

```
Week 1-2: Phase 2 Group A-F
├── Day 1-3: Group A (数据库优化)
├── Day 4-7: Group B (业务逻辑修复)
├── Day 8-10: Group C (代码质量改进)
├── Day 11-12: Group D (安全加固)
├── Day 13-14: Group E (配置优化)
└── Day 15-16: Group F (前端清理)

Week 3-4: Phase 2 测试和验证
├── Day 17-19: 集成测试
├── Day 20-21: 性能测试
├── Day 22-23: 安全测试
└── Day 24: Bug修复

Week 5-8: Phase 3 优化和规范
├── Week 5: Group G (代码规范)
├── Week 6: Group H (性能优化)
├── Week 7: Group I (测试覆盖)
└── Week 8: Group J-K (文档和工具)
```

### B. 工时汇总

| Phase | 任务组 | 工时 | 累计 |
|-------|--------|------|------|
| Phase 2 | Group A | 16h | 16h |
| Phase 2 | Group B | 32h | 48h |
| Phase 2 | Group C | 20h | 68h |
| Phase 2 | Group D | 12h | 80h |
| Phase 2 | Group E | 10h | 90h |
| Phase 2 | Group F | 16h | 106h |
| Phase 3 | Group G | 30h | 136h |
| Phase 3 | Group H | 25h | 161h |
| Phase 3 | Group I | 30h | 191h |
| Phase 3 | Group J | 20h | 211h |
| Phase 3 | Group K | 20h | 231h |
| **总计** | - | **231h** | - |

### C. 成功指标

**修复前**:
- 安全漏洞: 25个
- 并发问题: 12个
- 查询性能: 5秒+
- 代码质量: 7.0/10
- 测试覆盖: 0%

**修复后**:
- 安全漏洞: 0个
- 并发问题: 0个
- 查询性能: <100ms
- 代码质量: 9.5/10
- 测试覆盖: 70%+

---

**文档结束**

**下一步**: 请您review此计划,确认后我们即可开始Phase 2的执行。

**建议**: 优先执行 Group D(安全加固) 和 Group B(业务逻辑修复) 中的高优先级任务。
