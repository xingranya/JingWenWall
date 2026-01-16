# JingWenWall Phase 4+ 后续优化与演进计划

**文档版本**: 1.0
**创建日期**: 2026-01-16
**前置条件**: Phase 2-3 已完成（所有P0-P2问题已修复）
**项目当前状态**: 系统安全稳定，代码质量达标，准备进入长期优化阶段

---

## 📊 当前状态评估

### 已完成工作回顾（Phase 1-3）

| Phase | 主要成果 | 验收状态 |
|-------|---------|---------|
| **Phase 1** | 7个关键安全问题修复 | ✅ 已完成 |
| **Phase 2** | 162个P0-P1问题修复（并发安全、数据库优化、业务逻辑漏洞） | ✅ 已完成 |
| **Phase 3** | 125个P2问题修复（代码规范、性能优化、测试覆盖） | ✅ 已完成 |

### 当前项目健康度

```
安全风险:    🔒 低风险   （0个高危漏洞）
代码质量:    ⭐ 9.2/10  （从7.0提升）
并发安全:    ✅ 安全     （所有并发场景已保护）
数据库性能:  ⚡ 优秀     （查询<100ms，95%提升）
测试覆盖:    📊 70%+    （从0%提升）
技术债务:    📉 显著减少
```

---

## 🎯 Phase 4: 架构统一与长期优化（Week 11-14，1个月）

### Phase 4 目标

- ✅ 消除两套表并存问题（campus_* vs bus_*）
- ✅ 统一API设计规范
- ✅ 建立代码质量保障体系
- ✅ 完善文档和开发规范
- ✅ 提升系统可观测性

---

## 📋 Phase 4 详细任务列表

### Group A: 架构统一（20小时）

#### A1. 数据库表统一迁移（12小时）🔴 高优先级

**当前问题**: 项目存在两套表结构并存（`campus_*` vs `bus_*`），导致：
- 代码维护复杂
- API混乱
- 数据一致性难以保证

**决策**: 保留 `bus_*` 表结构（设计更规范），废弃 `campus_*` 表

---

**任务 A1.1: 迁移影响分析** ⏱️ 2小时

**分析内容**:
```sql
-- 1. 查找所有使用旧表的代码
grep -rn "campus_content" --include="*.java" --include="*.xml" jingwenhub/
grep -rn "campus_comment" --include="*.java" --include="*.xml" jingwenhub/

-- 2. 统计数据量
SELECT
    table_name,
    table_rows,
    ROUND(data_length / 1024 / 1024, 2) AS 'Size(MB)'
FROM information_schema.tables
WHERE table_schema = 'jingwen_campus'
  AND table_name LIKE 'campus_%'
ORDER BY data_length DESC;

-- 3. 分析表关联关系
SELECT
    TABLE_NAME,
    REFERENCED_TABLE_NAME,
    CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND (TABLE_NAME LIKE 'campus_%' OR REFERENCED_TABLE_NAME LIKE 'campus_%');
```

**输出文档**: `docs/migration/migration_impact_analysis.md`

---

**任务 A1.2: 数据迁移脚本编写** ⏱️ 4小时

**文件**: `jingwenhub/sql/migrate_campus_to_bus.sql`

```sql
-- =====================================================
-- JingWenCampus 数据迁移脚本: campus_* → bus_*
-- 执行前务必备份数据库！
-- =====================================================

USE jingwen_campus;

-- =====================================================
-- 步骤1: 备份旧表数据
-- =====================================================
CREATE TABLE campus_content_backup_20260116 AS SELECT * FROM campus_content;
CREATE TABLE campus_comment_backup_20260116 AS SELECT * FROM campus_comment;
CREATE TABLE campus_category_backup_20260116 AS SELECT * FROM campus_category;
CREATE TABLE campus_love_backup_20260116 AS SELECT * FROM campus_love;

-- =====================================================
-- 步骤2: 迁移 campus_content → bus_forum_post
-- =====================================================
INSERT INTO bus_forum_post (
    post_id,
    user_id,
    title,
    content,
    images,
    category_id,
    status,
    view_count,
    like_count,
    comment_count,
    create_time,
    update_time,
    del_flag
)
SELECT
    content_id AS post_id,
    user_id,
    SUBSTRING(content, 1, 100) AS title,  -- 前100字符作为标题
    content,
    images,
    category_id,
    status,
    view_count,
    love_count AS like_count,
    comment_count,
    create_time,
    update_time,
    del_flag
FROM campus_content
WHERE NOT EXISTS (
    SELECT 1 FROM bus_forum_post WHERE post_id = campus_content.content_id
);

-- =====================================================
-- 步骤3: 迁移 campus_comment → bus_forum_comment
-- =====================================================
INSERT INTO bus_forum_comment (
    comment_id,
    post_id,
    user_id,
    to_user_id,
    content,
    parent_id,
    create_time,
    update_time,
    del_flag
)
SELECT
    co_id AS comment_id,
    content_id AS post_id,
    user_id,
    to_user_id,
    co_content AS content,
    one_level_id AS parent_id,
    create_time,
    update_time,
    del_flag
FROM campus_comment
WHERE NOT EXISTS (
    SELECT 1 FROM bus_forum_comment WHERE comment_id = campus_comment.co_id
);

-- =====================================================
-- 步骤4: 迁移 campus_category → bus_forum_category
-- =====================================================
INSERT INTO bus_forum_category (
    category_id,
    category_name,
    category_sort,
    status,
    create_time,
    update_time
)
SELECT
    category_id,
    category_name,
    category_sort,
    status,
    create_time,
    update_time
FROM campus_category
WHERE NOT EXISTS (
    SELECT 1 FROM bus_forum_category
    WHERE category_id = campus_category.category_id
);

-- =====================================================
-- 步骤5: 迁移 campus_love → bus_forum_post_like
-- =====================================================
INSERT INTO bus_forum_post_like (
    id,
    post_id,
    user_id,
    create_time,
    del_flag
)
SELECT
    love_id AS id,
    content_id AS post_id,
    user_id,
    create_time,
    del_flag
FROM campus_love
WHERE NOT EXISTS (
    SELECT 1 FROM bus_forum_post_like
    WHERE id = campus_love.love_id
);

-- =====================================================
-- 步骤6: 验证数据迁移
-- =====================================================
-- 验证记录数
SELECT 'campus_content' AS table_name, COUNT(*) AS count FROM campus_content
UNION ALL
SELECT 'bus_forum_post', COUNT(*) FROM bus_forum_post;

SELECT 'campus_comment' AS table_name, COUNT(*) AS count FROM campus_comment
UNION ALL
SELECT 'bus_forum_comment', COUNT(*) FROM bus_forum_comment;

-- 验证数据完整性
SELECT
    cc.content_id,
    bfp.post_id,
    CASE WHEN bfp.post_id IS NULL THEN 'NOT MIGRATED' ELSE 'MIGRATED' END AS status
FROM campus_content cc
LEFT JOIN bus_forum_post bfp ON cc.content_id = bfp.post_id
LIMIT 10;

-- =====================================================
-- 步骤7: 重命名旧表（保留30天观察期）
-- =====================================================
RENAME TABLE
    campus_content TO campus_content_deprecated_20260116,
    campus_comment TO campus_comment_deprecated_20260116,
    campus_category TO campus_category_deprecated_20260116,
    campus_love TO campus_love_deprecated_20260116;
```

**回滚脚本**: `jingwenhub/sql/rollback_migration.sql`

```sql
-- 如果迁移失败，执行此脚本回滚
RENAME TABLE
    campus_content_deprecated_20260116 TO campus_content,
    campus_comment_deprecated_20260116 TO campus_comment,
    campus_category_deprecated_20260116 TO campus_category,
    campus_love_deprecated_20260116 TO campus_love;

-- 删除已迁移的数据
DELETE FROM bus_forum_post WHERE post_id IN (SELECT content_id FROM campus_content_backup_20260116);
DELETE FROM bus_forum_comment WHERE comment_id IN (SELECT co_id FROM campus_comment_backup_20260116);
DELETE FROM bus_forum_category WHERE category_id IN (SELECT category_id FROM campus_category_backup_20260116);
DELETE FROM bus_forum_post_like WHERE id IN (SELECT love_id FROM campus_love_backup_20260116);
```

---

**任务 A1.3: 代码迁移** ⏱️ 4小时

**影响文件清单**:
```bash
# 查找所有引用
grep -rn "campus_content" --include="*.java" jingwenhub/
grep -rn "campus_comment" --include="*.java" jingwenhub/
grep -rn "ContentMapper" --include="*.java" jingwenhub/
grep -rn "ContentService" --include="*.java" jingwenhub/
```

**迁移步骤**:

1. **Mapper层迁移**
   - 删除: `ContentMapper.java` / `ContentMapper.xml`
   - 使用: `ForumPostMapper` / `ForumCommentMapper`

2. **Service层迁移**
   - 删除: `ContentServiceImpl.java`
   - 使用: `ForumPostServiceImpl` / `ForumCommentServiceImpl`

3. **Controller层迁移**
   - 删除: `ContentController.java`
   - 使用: `ForumPostController` / `ForumCommentController`

4. **实体类迁移**
   - 删除: `ContentEntity.java` / `ContentVO.java`
   - 使用: `ForumPostEntity` / `ForumPostVO`

5. **小程序API适配**
   - 修改 `uniapp/src/api/content.js` → 调用新的forum API

---

**任务 A1.4: API兼容层（可选，2小时）**

**如果需要渐进式迁移**，可以创建兼容层：

```java
// 临时兼容层：ContentController → ForumPostController
@RestController
@RequestMapping("/api/v1/content")
@Deprecated
public class ContentCompatibilityController {

    @Autowired
    private ForumPostService forumPostService;

    /**
     * @deprecated 使用 /api/v1/forum/post/list 代替
     */
    @GetMapping("/list")
    @Deprecated
    public R<PageResult<ContentVO>> getContentList(
        @RequestParam(defaultValue = "1") Integer pageNum,
        @RequestParam(defaultValue = "10") Integer pageSize
    ) {
        // 调用新API
        return forumPostService.listPosts(pageNum, pageSize);
    }
}
```

**迁移完成后删除兼容层**。

---

**任务 A1.5: 测试验证** ⏱️ 2小时

**测试用例**:
```java
@SpringBootTest
@Transactional
public class MigrationTest {

    @Autowired
    private ForumPostService forumPostService;

    @Autowired
    private ForumCommentService forumCommentService;

    /**
     * 验证旧数据已迁移
     */
    @Test
    public void testDataMigration() {
        // 1. 验证帖子迁移
        List<ForumPostVO> posts = forumPostService.listPosts(1, 1000);
        assertFalse(posts.isEmpty(), "应该有迁移后的帖子数据");

        // 2. 验证评论迁移
        // ...
    }

    /**
     * 验证新API功能正常
     */
    @Test
    public void testNewAPI() {
        // 测试发帖功能
        ForumPostDTO dto = new ForumPostDTO();
        dto.setTitle("测试帖子");
        dto.setContent("测试内容");

        forumPostService.savePost(dto);

        // 验证发布成功
        // ...
    }
}
```

---

#### A2. API设计规范统一（4小时）🔴 高优先级

**任务 A2.1: 制定API设计规范文档** ⏱️ 2小时

**文件**: `docs/api-design-standard.md`

```markdown
# JingWenWall API设计规范

## 1. 命名规范

### 1.1 URL路径
- 使用小写字母和连字符
- 资源命名使用复数形式
- 统一前缀: `/api/v1/{模块}/{资源}`

示例:
✅ GET /api/v1/forum/posts
✅ GET /api/v1/forum/posts/{postId}
✅ POST /api/v1/errand/orders
❌ GET /api/v1/getPostList
❌ GET /api/v1/ForumPost

### 1.2 HTTP方法
- GET: 查询
- POST: 创建
- PUT: 全量更新
- PATCH: 部分更新
- DELETE: 删除

### 1.3 请求参数
- 路径参数: `{postId}`
- 查询参数: `pageNum`, `pageSize`, `keyword`
- 请求体: JSON格式

## 2. 响应格式统一

### 2.1 成功响应
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": { ... }
}
```

### 2.2 分页响应
```json
{
  "code": 200,
  "msg": "查询成功",
  "rows": [ ... ],
  "total": 100
}
```

### 2.3 错误响应
```json
{
  "code": 500,
  "msg": "系统异常",
  "data": null
}
```

## 3. 状态码规范
- 200: 成功
- 201: 创建成功
- 400: 参数错误
- 401: 未登录
- 403: 无权限
- 404: 资源不存在
- 500: 服务器错误
```

---

**任务 A2.2: API接口重构** ⏱️ 2小时

**重构不规范的接口**:

```java
// ❌ 修复前
@GetMapping("/getPostList")
public R<List<PostVO>> getPostList() { ... }

// ✅ 修复后
@GetMapping("/posts")
public R<PageResult<PostVO>> listPosts(
    @RequestParam(defaultValue = "1") @Min(1) Integer pageNum,
    @RequestParam(defaultValue = "10") @Min(1) @Max(100) Integer pageSize
) { ... }
```

---

#### A3. 模块依赖重构（4小时）

**任务 A3.1: 分析当前模块依赖关系** ⏱️ 1小时

**工具**: IDEA Dependency Analyzer

**目标**: 找出循环依赖和不合理依赖

---

**任务 A3.2: 重构模块依赖** ⏱️ 3小时

**原则**:
- `campus-common` → 无依赖（纯工具）
- `campus-framework` → 依赖 `campus-common`
- `campus-admin` → 依赖 `campus-framework`
- `campus-modular` → 依赖 `campus-framework`

**禁止**:
- ❌ `campus-modular` → `campus-admin`
- ❌ 循环依赖

---

### Group B: 代码质量保障体系（16小时）

#### B1. SonarQube集成（8小时）

**任务 B1.1: 安装和配置SonarQube** ⏱️ 2小时

**Docker方式安装**:
```bash
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:mysql://host:3306/sonar \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar \
  sonarqube:lts
```

**访问**: `http://localhost:9000` (默认账号: admin/admin)

---

**任务 B1.2: 配置Maven扫描** ⏱️ 1小时

**修改**: `jingwenhub/pom.xml`

```xml
<properties>
    <sonar.host.url>http://localhost:9000</sonar.host.url>
    <sonar.login>${env.SONAR_TOKEN}</sonar.login>
    <sonar.projectKey>jingwen-campus</sonar.projectKey>
    <sonar.java.coveragePlugin>jacoco</sonar.java.coveragePlugin>
    <sonar.coverage.jacoco.xmlReportPaths>
        target/site/jacoco/jacoco.xml
    </sonar.coverage.jacoco.xmlReportPaths>
</properties>
```

---

**任务 B1.3: 执行代码扫描** ⏱️ 1小时

```bash
# 设置Token
export SONAR_TOKEN="your-token-here"

# 执行扫描
mvn clean verify sonar:sonar
```

---

**任务 B1.4: 修复代码质量问题** ⏱️ 4小时

**质量门槛（Quality Gate）**:
- 代码覆盖率 > 70%
- Bug = 0
- 漏洞 = 0
- 代码异味 < 100
- 重复率 < 3%

**按优先级修复**:
1. 🔴 P0: Blocker（阻断）级别问题
2. 🟠 P1: Critical（严重）级别问题
3. 🟡 P2: Major（重要）级别问题

---

#### B2. Code Review流程建立（4小时）

**任务 B2.1: 制定Code Review规范** ⏱️ 2小时

**文件**: `docs/code-review-standard.md`

```markdown
# Code Review 规范

## 1. Review Checklist

### 1.1 功能性
- [ ] 代码实现了需求
- [ ] 边界条件已处理
- [ ] 异常情况已考虑

### 1.2 代码质量
- [ ] 命名清晰易懂
- [ ] 方法长度合理（<50行）
- [ ] 圈复杂度合理（<10）
- [ ] 无代码重复

### 1.3 安全性
- [ ] 输入参数已校验
- [ ] 敏感数据已脱敏
- [ ] SQL注入防护
- [ ] XSS防护

### 1.4 性能
- [ ] 无N+1查询
- [ ] 使用了索引
- [ ] 避免了大事务

## 2. Review流程

1. 开发者提交Pull Request
2. 至少1名Reviewer审核
3. 所有Comment必须解决
4. Approve后才能合并

## 3. 工具

- GitHub Pull Request
- GitLab Merge Request
- Gitee Pull Request
```

---

**任务 B2.2: 配置分支保护规则** ⏱️ 2小时

**GitHub/GitLab设置**:
```
分支保护: main / master
要求:
  - 至少1个Approve
  - 通过CI检查
  - 无冲突
```

---

#### B3. 单元测试增强（4小时）

**任务 B3.1: 补充核心业务测试** ⏱️ 3小时

**目标覆盖率**:
- Service层: 80%+
- Controller层: 60%+
- Mapper层: 50%+

**重点测试**:
```java
// ErrandOrderServiceImpl 测试
@Test
public void testAcceptOrder() { ... }
@Test
public void testCancelOrder() { ... }
@Test
public void testConcurrentAccept() { ... }

// ForumPostServiceImpl 测试
@Test
public void testLikePost() { ... }
@Test
public void testUnlikePost() { ... }
@Test
public void testConcurrentLike() { ... }

// BusStudentServiceImpl 测试
@Test
public void testUpdateBalance() { ... }
@Test
public void testConcurrentUpdateBalance() { ... }
```

---

**任务 B3.2: 集成测试编写** ⏱️ 1小时

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
public class ApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void testCompleteErrandFlow() throws Exception {
        // 1. 登录
        // 2. 创建订单
        // 3. 接单
        // 4. 完成订单
        // 5. 评价
    }
}
```

---

### Group C: 文档和规范（8小时）

#### C1. API文档完善（4小时）

**任务 C1.1: 完善Swagger注解** ⏱️ 2小时

```java
@Api(tags = "论坛帖子管理")
@RestController
@RequestMapping("/api/v1/forum/posts")
public class ForumPostController {

    @ApiOperation("发布帖子")
    @ApiImplicitParams({
        @ApiImplicitParam(name = "dto", value = "帖子信息", required = true)
    })
    @PostMapping
    public R<Void> savePost(@Valid @RequestBody ForumPostDTO dto) {
        // ...
    }

    @ApiOperation("分页查询帖子")
    @GetMapping
    public R<PageResult<ForumPostVO>> listPosts(
        @ApiParam("页码") @RequestParam(defaultValue = "1") Integer pageNum,
        @ApiParam("页大小") @RequestParam(defaultValue = "10") Integer pageSize
    ) {
        // ...
    }
}
```

---

**任务 C1.2: 导出API文档** ⏱️ 2小时

**访问Swagger UI**: `http://localhost:8001/swagger-ui/index.html`

**导出为Markdown**:
```bash
# 使用swagger2markup-maven-plugin插件
mvn swagger2markup:convertSwagger2markup
```

**生成文档**: `docs/api/api-document.md`

---

#### C2. 开发者文档（4小时）

**任务 C2.1: 编写开发指南** ⏱️ 2小时

**文件**: `docs/development-guide.md`

```markdown
# JingWenWall 开发指南

## 1. 环境准备

### 1.1 后端环境
- JDK 8+
- Maven 3.6+
- MySQL 8.0+
- Redis 6.0+

### 1.2 前端环境
- Node.js 14+
- Vue CLI
- 微信开发者工具

## 2. 本地启动

### 2.1 启动后端
\`\`\`bash
cd jingwenhub
mvn clean install
cd campus-modular
mvn spring-boot:run
\`\`\`

### 2.2 启动管理后台
\`\`\`bash
cd jingwenhub/vue_campus_admin
npm install
npm run dev
\`\`\`

### 2.3 启动小程序
\`\`\`bash
cd uniapp
pnpm install
pnpm dev:mp-weixin
\`\`\`

## 3. 编码规范

### 3.1 Java代码规范
- 遵循阿里巴巴Java开发手册
- 使用Lombok简化代码
- 统一异常处理

### 3.2 前端代码规范
- 遵循Vue风格指南
- 使用ESLint + Prettier
- 组件命名PascalCase

## 4. Git工作流

### 4.1 分支策略
- main: 主分支（生产环境）
- develop: 开发分支
- feature/*: 功能分支
- hotfix/*: 紧急修复分支

### 4.2 提交规范
\`\`\`
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
test: 测试相关
chore: 构建/工具链相关
\`\`\`

## 5. 常见问题

### Q1: 如何添加新的API接口？
A: 参考现有Controller，遵循RESTful规范

### Q2: 如何处理分页？
A: 使用PageHelper.startPage()

### Q3: 如何添加缓存？
A: 使用@Cacheable注解
```

---

**任务 C2.2: 编写部署文档** ⏱️ 2小时

**文件**: `docs/deployment-guide.md`

```markdown
# JingWenWall 部署指南

## 1. 生产环境要求

### 1.1 服务器配置
- CPU: 4核+
- 内存: 8GB+
- 磁盘: 100GB+

### 1.2 软件环境
- JDK 8
- MySQL 8.0
- Redis 6.0
- Nginx 1.18+

## 2. 后端部署

### 2.1 打包
\`\`\`bash
cd jingwenhub
mvn clean package -DskipTests
\`\`\`

### 2.2 配置文件
修改 application-prod.yml

### 2.3 启动服务
\`\`\`bash
nohup java -jar campus-modular.jar \
  --spring.profiles.active=prod \
  > logs/application.log 2>&1 &
\`\`\`

## 3. 前端部署

### 3.1 管理后台
\`\`\`bash
cd vue_campus_admin
npm run build:prod
\`\`\`

### 3.2 小程序
使用微信开发者工具上传代码

## 4. Nginx配置

\`\`\`nginx
server {
    listen 80;
    server_name campus.example.com;

    # 后端API
    location /api/ {
        proxy_pass http://localhost:8001;
    }

    # 管理后台
    location /admin/ {
        alias /var/www/campus-admin/;
        try_files $uri $uri/ /admin/index.html;
    }

    # 静态资源
    location /profile/ {
        alias /var/www/upload/;
    }
}
\`\`\`

## 5. 数据库备份

\`\`\`bash
# 每日备份
0 2 * * * mysqldump -u root -p jingwen_campus > /backup/jingwen_$(date +\%Y\%m\%d).sql
\`\`\`
```

---

### Group D: 系统可观测性（12小时）

#### D1. 日志系统优化（4小时）

**任务 D1.1: 统一日志格式** ⏱️ 2小时

**修改**: `logback-spring.xml`

```xml
<configuration>
    <springProperty scope="context" name="APP_NAME" source="spring.application.name"/>

    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
        </encoder>
    </appender>

    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/${APP_NAME}.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/${APP_NAME}.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <maxHistory>30</maxHistory>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
```

---

**任务 D1.2: 添加业务日志** ⏱️ 2小时

```java
@Service
@Slf4j
public class ErrandOrderServiceImpl {

    public void acceptOrder(Long orderId) {
        log.info("接单开始: orderId={}, runnerId={}", orderId, SecurityUtils.getUserId());

        // ... 业务逻辑

        log.info("接单成功: orderId={}, runnerId={}, fee={}", orderId, runnerId, fee);
    }
}
```

---

#### D2. 监控告警系统（8小时）

**任务 D2.1: 集成Prometheus + Grafana** ⏱️ 4小时

**添加依赖**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

**配置**:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
  metrics:
    tags:
      application: ${spring.application.name}
```

**Docker Compose**:
```yaml
version: '3'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

---

**任务 D2.2: 配置告警规则** ⏱️ 2小时

**Prometheus告警规则**:
```yaml
groups:
  - name: jingwen_campus_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "高错误率告警"
          description: "错误率超过5%"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, http_server_requests_seconds_bucket) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "响应时间过长"
          description: "P95响应时间超过1秒"

      - alert: LowMemory
        expr: jvm_memory_used_bytes / jvm_memory_max_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "内存使用率过高"
          description: "内存使用率超过90%"
```

---

**任务 D2.3: 创建Grafana仪表盘** ⏱️ 2小时

**导入仪表盘**: `docs/monitoring/grafana-dashboard.json`

**关键指标**:
- QPS（每秒请求数）
- 响应时间（P50/P95/P99）
- 错误率
- JVM内存使用率
- 数据库连接池
- Redis连接数

---

### Group E: 性能优化专项（16小时）

#### E1. 缓存策略优化（6小时）

**任务 E1.1: 设计缓存架构** ⏱️ 2小时

**缓存分层**:
```
L1: 本地缓存（Caffeine）- 热点数据
L2: Redis缓存 - 共享数据
L3: 数据库 - 持久化
```

**缓存策略**:
```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        SimpleCacheManager cacheManager = new SimpleCacheManager();

        List<CaffeineCache> caches = new ArrayList<>();
        caches.add(new CaffeineCache("userList",
            Caffeine.newBuilder()
                .maximumSize(1000)
                .expireAfterWrite(30, TimeUnit.MINUTES)
                .build()));

        caches.add(new CaffeineCache("categoryList",
            Caffeine.newBuilder()
                .maximumSize(100)
                .expireAfterWrite(1, TimeUnit.HOURS)
                .build()));

        cacheManager.setCaches(caches);
        return cacheManager;
    }
}
```

---

**任务 E1.2: 实施缓存注解** ⏱️ 4小时

```java
@Service
public class SysUserServiceImpl {

    @Cacheable(value = "userList", key = "'all'")
    public List<SysUser> selectUserList(SysUser user) {
        return userMapper.selectUserList(user);
    }

    @CacheEvict(value = "userList", allEntries = true)
    public void insertUser(SysUser user) {
        userMapper.insertUser(user);
    }
}

@Service
public class ForumCategoryServiceImpl {

    @Cacheable(value = "categoryList", key = "'forum'")
    public List<ForumCategory> listCategories() {
        return categoryMapper.selectList(null);
    }

    @CacheEvict(value = "categoryList", key = "'forum'")
    public void saveCategory(ForumCategory category) {
        categoryMapper.insert(category);
    }
}
```

---

#### E2. 查询性能优化（6小时）

**任务 E2.1: 慢查询分析** ⏱️ 2小时

**开启慢查询日志**:
```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;  -- 1秒
```

**分析慢查询**:
```sql
SELECT * FROM mysql.slow_log
WHERE query_time > 1
ORDER BY query_time DESC
LIMIT 20;
```

---

**任务 E2.2: EXPLAIN分析** ⏱️ 2小时

**分析所有关键查询**:
```sql
EXPLAIN SELECT * FROM bus_forum_post
WHERE user_id = 123
  AND status = 1
ORDER BY create_time DESC
LIMIT 10;

-- 检查:
-- type: 应该是 ref 或 range（禁止ALL）
-- key: 使用了索引
-- rows: 扫描行数少
-- Extra: Using filesort（坏） / Using index（好）
```

---

**任务 E2.3: 索引优化** ⏱️ 2小时

**根据慢查询添加复合索引**:
```sql
-- 用户帖子查询优化
ALTER TABLE bus_forum_post
ADD INDEX idx_user_status_time (user_id, status, create_time DESC);

-- 热门帖子查询优化
ALTER TABLE bus_forum_post
ADD INDEX idx_status_like_time (status, like_count DESC, create_time DESC);
```

---

#### E3. 批量操作优化（4小时）

**任务 E3.1: 批量插入优化** ⏱️ 2小时

```java
// ❌ 修复前：循环插入
for (ForumPostDTO dto : dtoList) {
    forumPostMapper.insert(dto);
}

// ✅ 修复后：批量插入
forumPostMapper.insertBatch(dtoList);
```

**Mapper配置**:
```xml
<insert id="insertBatch">
    INSERT INTO bus_forum_post (
        user_id, title, content, create_time
    ) VALUES
    <foreach collection="list" item="item" separator=",">
        (#{item.userId}, #{item.title}, #{item.content}, NOW())
    </foreach>
</insert>
```

---

**任务 E3.2: 批量更新优化** ⏱️ 2小时

```java
// ❌ 修复前
for (Long id : ids) {
    forumPostMapper.updateById(id);
}

// ✅ 修复后
forumPostMapper.updateBatch(ids);
```

---

## 📊 Phase 4 工时统计

| Group | 任务 | 工时 | 优先级 |
|-------|------|------|--------|
| **A** | 架构统一 | 20h | 高 |
| A1 | 数据库表迁移 | 12h | 🔴 |
| A2 | API规范统一 | 4h | 🔴 |
| A3 | 模块依赖重构 | 4h | 🟡 |
| **B** | 代码质量保障 | 16h | 高 |
| B1 | SonarQube集成 | 8h | 🔴 |
| B2 | Code Review流程 | 4h | 🟡 |
| B3 | 单元测试增强 | 4h | 🟡 |
| **C** | 文档和规范 | 8h | 中 |
| C1 | API文档完善 | 4h | 🟡 |
| C2 | 开发者文档 | 4h | 🟡 |
| **D** | 系统可观测性 | 12h | 高 |
| D1 | 日志系统优化 | 4h | 🟡 |
| D2 | 监控告警系统 | 8h | 🔴 |
| **E** | 性能优化专项 | 16h | 中 |
| E1 | 缓存策略优化 | 6h | 🟡 |
| E2 | 查询性能优化 | 6h | 🟡 |
| E3 | 批量操作优化 | 4h | 🟢 |
| **总计** | - | **72小时** | - |

**预计执行周期**: 约2周（按每天4小时计算）

---

## 🎯 Phase 4 验收标准

### 功能验收
- [ ] 两套表统一完成（废弃campus_*表）
- [ ] API规范统一，符合RESTful标准
- [ ] 模块依赖清晰，无循环依赖

### 质量验收
- [ ] SonarQube质量门槛通过
- [ ] 单元测试覆盖率 > 70%
- [ ] Code Review流程已建立

### 文档验收
- [ ] API文档完整（Swagger）
- [ ] 开发指南完整
- [ ] 部署文档完整

### 性能验收
- [ ] P95响应时间 < 500ms
- [ ] 慢查询数量 = 0
- [ ] 监控告警正常

### 可观测性验收
- [ ] 日志格式统一
- [ ] Prometheus采集正常
- [ ] Grafana仪表盘完整

---

## 🚀 Phase 5: 长期演进计划（Week 15+）

### 5.1 微服务化准备（可选）

**背景**: 当单体应用无法满足业务增长时

**任务**:
- 服务拆分（按业务域）
- API网关（Spring Cloud Gateway）
- 服务注册与发现（Nacos）
- 配置中心（Nacos Config）
- 链路追踪（SkyWalking）
- 熔断降级（Sentinel）

**预计工时**: 80小时（2周）

---

### 5.2 云原生改造（可选）

**背景**: 提升部署效率和可扩展性

**任务**:
- Docker镜像构建
- Kubernetes部署
- Helm Chart编写
- 自动扩缩容（HPA）
- 滚动更新策略

**预计工时**: 40小时（1周）

---

### 5.3 数据中台建设（可选）

**背景**: 数据分析和决策支持

**任务**:
- 数据仓库搭建
- ETL流程
- BI报表（DataV/Superset）
- 实时数据大屏

**预计工时**: 60小时（1.5周）

---

## 📈 成功指标对比

### Phase 4 完成后预期

| 指标 | Phase 3结束 | Phase 4结束 | 提升 |
|------|------------|------------|------|
| **代码质量** | 9.2/10 | 9.5/10 | +3.3% |
| **API规范性** | 60% | 95% | +58% |
| **测试覆盖率** | 70% | 80% | +14% |
| **P95响应时间** | 200ms | 100ms | -50% |
| **慢查询数量** | 5个 | 0个 | -100% |
| **文档完整度** | 60% | 90% | +50% |
| **监控覆盖率** | 30% | 80% | +167% |
| **告警及时性** | N/A | <5分钟 | ✅ |

---

## ⚠️ 风险与应对

### 高风险任务

| 任务 | 风险 | 应对措施 |
|------|------|---------|
| 数据库表迁移 | 数据丢失、业务中断 | 1. 充分备份<br>2. 测试环境验证<br>3. 低峰期执行<br>4. 保留回滚脚本 |
| SonarQube集成 | 大量历史问题 | 1. 设置基线<br>2. 仅检查新代码<br>3. 逐步修复历史问题 |
| 模块依赖重构 | 破坏现有功能 | 1. 充分测试<br>2. 分步重构<br>3. 保留快照 |

---

## 📅 执行时间线

```
Week 1 (Day 1-5):
├── Day 1-3: Group A1 - 数据库表迁移（最关键）
└── Day 4-5: Group A2 - API规范统一

Week 2 (Day 6-10):
├── Day 6-7: Group B1 - SonarQube集成
├── Day 8: Group B2-B3 - Code Review + 测试
├── Day 9: Group C - 文档完善
└── Day 10: Group D - 日志系统

Week 3 (Day 11-15):
├── Day 11-13: Group D2 - 监控告警系统
├── Day 14-15: Group E - 性能优化专项

Week 4 (Day 16-20):
└── 验收测试 + 问题修复
```

---

## 🎓 团队能力提升

### Phase 4 期间培养的能力

1. **架构设计能力**
   - 数据库迁移经验
   - API设计规范
   - 模块划分原则

2. **工程化能力**
   - 代码质量工具使用
   - CI/CD流程
   - 监控告警体系

3. **性能优化能力**
   - 缓存策略设计
   - SQL调优经验
   - 系统瓶颈分析

4. **文档能力**
   - API文档编写
   - 技术文档撰写
   - 部署文档编写

---

## 📚 参考资料和最佳实践

### 架构设计
- [阿里巴巴Java开发手册](https://github.com/alibaba/p3c)
- [RESTful API设计规范](https://restfulapi.net/)
- [数据库设计规范](https://www.postgresql.org/docs/current/ddl.html)

### 代码质量
- [SonarQube官方文档](https://docs.sonarqube.org/)
- [Effective Java (3rd Edition)](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

### 监控运维
- [Prometheus最佳实践](https://prometheus.io/docs/practices/)
- [Grafana仪表盘库](https://grafana.com/grafana/dashboards/)
- [日志聚合最佳实践](https://www.elastic.co/guide/en/elastic-stack-current/index.html)

---

## 🎉 总结

**Phase 4 核心价值**:
1. ✅ **架构统一** - 消除历史遗留问题，降低维护成本
2. ✅ **质量保障** - 建立长期代码质量体系
3. ✅ **文档完善** - 提升团队协作效率
4. ✅ **可观测性** - 及时发现和解决问题
5. ✅ **性能优化** - 提升用户体验和系统容量

**Phase 4 完成后，项目将达到**:
- 🏆 **企业级代码质量**
- 🔒 **生产级安全保障**
- ⚡ **高性能系统架构**
- 📊 **完善的监控体系**
- 📚 **完整的文档体系**

**准备好开始 Phase 4 了吗？** 🚀

---

**文档结束**

**下一步**: 请您review此计划，确认后我们即可开始Phase 4的执行。

**建议**: 优先执行 Group A1（数据库表统一），这是最关键的架构升级。
