# Task Plan: JingWenWall Phase 2 并发安全与数据修复

## Goal
完成JingWenWall项目的Phase 2修复工作，包括数据库优化、安全加固、业务逻辑修复和数据校验增强。

## Phases

### Phase 1: Group A - 数据库优化 (5个任务)
- [ ] A2: LIKE查询优化
- [ ] A3: 字符集统一
- [ ] A4: SELECT*优化
- [ ] A5: 日期函数索引
- [ ] A6: 分页LIMIT优化

### Phase 2: Group D - 安全加固 (2个任务)
- [ ] D3.1: 默认密码修改
- [ ] D4.1: Token有效期调整

### Phase 3: Group B2 - 业务逻辑漏洞修复 (2个任务)
- [ ] B2.1: 订单金额校验
- [ ] B2.2: 权限控制完善

### Phase 4: Group B3 - 数据校验增强 (2个任务)
- [ ] B3.1: @Valid注解
- [ ] B3.2: 分页参数限制

---

## Phase 1: Group A - 数据库优化

### A2: LIKE查询优化

**问题**: LIKE '%keyword%' 不会使用索引

**需要修改的文件**:
1. `E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources\mapper\ContentMapper.xml`
2. `E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources\mapper\MarketItemMapper.xml`
3. `E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources\mapper\ForumPostMapper.xml`

**修改方案**:
- 将 `LIKE '%keyword%'` 改为 `LIKE 'keyword%'` (前缀匹配可以使用索引)
- 或者使用全文索引 (FULLTEXT index)
- 对于大文本字段，考虑使用ElasticSearch

**Git Commit**: `fix(sql): 优化LIKE查询使用前缀匹配`

---

### A3: 字符集统一

**问题**: 数据库字符集不一致可能导致乱码

**需要修改的文件**:
1. `E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources\application.yml`

**修改方案**:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/jingwen_campus?useUnicode=true&characterEncoding=utf8mb4&useSSL=false&serverTimezone=Asia/Shanghai
```

**Git Commit**: `fix(sql): 统一数据库连接字符集为utf8mb4`

---

### A4: SELECT*优化

**问题**: SELECT* 获取所有字段，浪费资源

**需要修改的文件**:
所有Mapper.xml文件，包括但不限于:
- `ContentMapper.xml`
- `ForumPostMapper.xml`
- `MarketItemMapper.xml`
- `ErrandOrderMapper.xml`
- `BusStudentMapper.xml`
- 等等...

**修改方案**:
- 将 `SELECT *` 改为 `SELECT 具体字段`
- 只查询需要的字段

**Git Commit**: `fix(sql): 将SELECT*改为具体字段查询`

---

### A5: 日期函数索引

**问题**: 在WHERE子句中对日期字段使用函数会导致索引失效

**需要修改的文件**:
检查所有Mapper.xml中的日期查询

**修改方案**:
- 将 `WHERE DATE(create_time) = '2024-01-01'`
- 改为 `WHERE create_time >= '2024-01-01 00:00:00' AND create_time <= '2024-01-01 23:59:59'`

**Git Commit**: `fix(sql): 优化日期查询避免函数索引失效`

---

### A6: 分页LIMIT优化

**问题**: 深分页 `LIMIT 1000000, 10` 性能差

**需要修改的文件**:
所有涉及分页的Mapper.xml

**修改方案**:
- 使用 "延迟关联" (Delayed Join)
- 或者使用游标分页 (基于ID的分页)
- 例如:
```sql
-- 原查询
SELECT * FROM t ORDER BY id LIMIT 1000000, 10;

-- 优化后
SELECT t.* FROM t JOIN (SELECT id FROM t ORDER BY id LIMIT 1000000, 10) tmp ON t.id = tmp.id;
```

**Git Commit**: `fix(sql): 优化深分页查询使用延迟关联`

---

## Phase 2: Group D - 安全加固

### D3.1: 默认密码修改

**问题**: 微信登录用户使用默认密码存在安全风险

**需要修改的文件**:
`E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\java\com\oddfar\campus\web\service\impl\WeiXinAuthServiceImpl.java`

**修改方案**:
- 不设置默认密码或使用随机密码
- 微信登录用户不允许密码登录

**Git Commit**: `fix(security): 移除微信登录用户默认密码`

---

### D4.1: Token有效期调整

**问题**: Token有效期过长或过短都会影响安全

**需要修改的文件**:
`E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources\application.yml`

**修改方案**:
```yaml
token:
  expireTime: 720  # 12小时 (单位: 分钟)
```

**Git Commit**: `fix(security): 调整Token有效期为12小时`

---

## Phase 3: Group B2 - 业务逻辑漏洞修复

### B2.1: 订单金额校验

**问题**: 订单金额可能被篡改

**需要修改的文件**:
`E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\java\com\oddfar\campus\business\errand\service\impl\ErrandOrderServiceImpl.java`

**修改方案**:
- 在创建订单时校验金额是否与商品/服务价格一致
- 后端重新计算订单金额，不直接使用前端传来的值

**Git Commit**: `fix(errand): 添加订单金额校验逻辑`

---

### B2.2: 权限控制完善

**问题**: 部分接口缺少权限校验

**需要修改的文件**:
检查所有Controller的权限注解

**修改方案**:
- 确保所有业务接口都有 `@PreAuthorize` 注解
- 或者在Service层进行权限校验

**Git Commit**: `fix(security): 完善业务接口权限控制`

---

## Phase 4: Group B3 - 数据校验增强

### B3.1: @Valid注解

**问题**: 缺少请求参数校验

**需要修改的文件**:
所有Controller中的DTO参数

**修改方案**:
- 在DTO中添加 `@NotNull`, `@NotBlank`, `@Size`, `@Min`, `@Max` 等注解
- 在Controller方法中添加 `@Valid` 或 `@Validated` 注解

**Git Commit**: `feat(validation): 添加请求参数@Valid校验`

---

### B3.2: 分页参数限制

**问题**: 分页参数可能过大导致性能问题

**需要修改的文件**:
所有分页查询的Controller

**修改方案**:
- 限制 pageSize 最大值 (如100)
- 限制 pageNum 最小值为1

**Git Commit**: `feat(validation): 限制分页参数范围`

---

## Status

**Currently in Phase 1** - 正在执行Group A数据库优化任务

## Progress
- ✅ Group B1 (6个并发安全任务)
- ✅ Task A1 (SQL唯一约束)
- ⏳ Group A2-A6 (数据库优化) - 进行中
- ⏳ Group D (安全加固)
- ⏳ Group B2 (业务逻辑漏洞修复)
- ⏳ Group B3 (数据校验增强)
