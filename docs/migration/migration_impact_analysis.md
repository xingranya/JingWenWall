# 数据库表迁移影响分析报告

**生成时间**: 2026-01-16
**项目**: JingWenWall Phase 4 - 架构统一
**任务**: A1.1 迁移影响分析

---

## 1. 执行摘要

### 迁移目标
将项目中的旧表结构 `campus_*` 统一迁移到 `bus_*` 表结构，消除两套表并存问题。

### 影响评估
- **数据量**: 极低风险 (总共48条记录)
- **代码影响**: 中等 (约32个文件需要修改)
- **业务影响**: 低 (campus_content使用率低，已有bus_forum_post替代)
- **建议**: ✅ 可以安全执行迁移

---

## 2. 当前表结构对比

### 2.1 旧表 (campus_*) 统计

| 表名 | 记录数 | 数据大小 | 索引大小 | 状态 |
|------|--------|----------|----------|------|
| campus_content | 16 | 0.02MB | 0.00MB | 需迁移 |
| campus_comment | 0 | 0.02MB | 0.00MB | 空表 |
| campus_category | 12 | 0.02MB | 0.00MB | 需迁移 |
| campus_content_love | 7 | 0.02MB | 0.00MB | 需迁移 |
| campus_content_tag | 5 | 0.02MB | 0.00MB | 需迁移 |
| campus_file | 5 | 0.02MB | 0.00MB | 需迁移 |
| campus_tag | 3 | 0.02MB | 0.00MB | 需迁移 |
| **总计** | **48** | **0.14MB** | **0.00MB** | - |

### 2.2 新表 (bus_*) 统计

| 表名 | 记录数 | 数据大小 | 状态 |
|------|--------|----------|------|
| bus_forum_post | 8 | 0.02MB | 迁移目标 |
| bus_forum_comment | 4 | 0.02MB | 迁移目标 |
| bus_category | 6 | 0.02MB | 迁移目标 |
| bus_forum_post_like | 5 | 0.02MB | 迁移目标 |
| bus_forum_post_collect | 0 | 0.02MB | 迁移目标 |

---

## 3. 表映射关系

| 旧表 (campus_*) | 新表 (bus_*) | 迁移策略 | 备注 |
|-----------------|--------------|----------|------|
| campus_content | bus_forum_post | 数据合并 | 标题取content前100字符 |
| campus_comment | bus_forum_comment | 数据合并 | co_id → comment_id |
| campus_category | bus_category | 数据合并 | 结构相同 |
| campus_content_love | bus_forum_post_like | 数据合并 | love_id → id |
| campus_content_tag | (废弃) | 不迁移 | 使用新标签系统 |
| campus_file | (保留) | 不迁移 | 通用文件表，独立使用 |
| campus_tag | (废弃) | 不迁移 | 使用新标签系统 |

---

## 4. 代码影响分析

### 4.1 实体类 (Entity) - 8个文件

```
需要删除/迁移:
├── ContentEntity.java          → 使用 ForumPostEntity
├── CommentEntity.java          → 使用 ForumCommentEntity
├── CategoryEntity.java         → 合并到 bus_category
├── TagEntity.java              → (废弃，使用论坛标签)
├── ContentLoveEntity.java      → 使用 ForumPostLikeEntity
├── ContentTagEntity.java       → (废弃)
├── FileEntity.java             → (保留，通用表)
└── CampusFileEntity.java       → (保留，通用表)
```

### 4.2 Mapper层 - 2个文件

```
需要删除:
├── ContentMapper.java          → 使用 ForumPostMapper
└── CommentMapper.java          → 使用 ForumCommentMapper
```

### 4.3 Service层 - 6个文件

```
需要迁移:
├── ContentService.java         → 使用 ForumPostService
├── ContentServiceImpl.java     → 迁移逻辑到 ForumPostServiceImpl
├── CommentService.java         → 使用 ForumCommentService
├── CommentServiceImpl.java     → 迁移逻辑到 ForumCommentServiceImpl
├── CategoryService.java        → 合并到 BusCategoryService
├── TagService.java             → (废弃，使用论坛标签)
└── ContentLoveServiceImpl.java → 使用 ForumPostLikeService
```

### 4.4 Controller层 - 8个文件

```
需要迁移:
小程序端:
├── ContentInfoController.java  → 使用 ForumPostController
├── CommentInfoController.java  → 使用 ForumCommentController
└── CampusInfoController.java   → (综合控制器，需拆分)

管理后台:
├── ContentController.java      → 使用 ForumPostController (admin)
├── CommentController.java      → 使用 ForumCommentController (admin)
├── CategoryController.java     → 使用 BusCategoryController (admin)
└── TagController.java          → (废弃，使用论坛标签)
```

### 4.5 XML Mapper - 2个文件

```
需要删除:
├── ContentMapper.xml           → 使用 ForumPostMapper.xml
└── CommentMapper.xml           → 使用 ForumCommentMapper.xml
```

### 4.6 测试文件 - 1个文件

```
需要更新:
└── ContentServiceImplTest.java → 使用 ForumPostServiceImplTest
```

### 4.7 影响统计

| 类型 | 文件数 | 操作类型 |
|------|--------|----------|
| Entity | 8 | 删除/迁移 |
| Mapper | 2 | 删除 |
| Service | 7 | 迁移/删除 |
| Controller | 8 | 迁移/删除 |
| XML Mapper | 2 | 删除 |
| 测试 | 1 | 更新 |
| **总计** | **28** | - |

---

## 5. API影响分析

### 5.1 小程序端 API

需要废弃的旧API:
```
GET  /api/v1/content/list       → 使用 /api/v1/forum/posts/list
POST /api/v1/content/send       → 使用 /api/v1/forum/posts
GET  /api/v1/comment/list       → 使用 /api/v1/forum/comments
POST /api/v1/comment/toComment  → 使用 /api/v1/forum/comments
```

### 5.2 管理后台 API

需要废弃的旧API:
```
GET  /admin/content/list        → 使用 /admin/forum/posts
POST /admin/content             → 使用 /admin/forum/posts
GET  /admin/comment/list        → 使用 /admin/forum/comments
GET  /admin/category/list       → 使用 /admin/category (统一)
```

---

## 6. 数据依赖关系

### 6.1 外键关系

```sql
-- campus_content 外键依赖
campus_content.user_id → sys_user.user_id
campus_content.category_id → campus_category.category_id

-- campus_comment 外键依赖
campus_comment.content_id → campus_content.content_id
campus_comment.user_id → sys_user.user_id
campus_comment.to_user_id → sys_user.user_id

-- campus_content_love 外键依赖
campus_content_love.content_id → campus_content.content_id
campus_content_love.user_id → sys_user.user_id

-- campus_content_tag 外键依赖
campus_content_tag.content_id → campus_content.content_id
campus_content_tag.tag_id → campus_tag.tag_id
```

### 6.2 迁移顺序

```
1. campus_tag → (不迁移，废弃)
2. campus_content_tag → (不迁移，废弃)
3. campus_content_love → bus_forum_post_like (依赖content)
4. campus_comment → bus_forum_comment (依赖content)
5. campus_content → bus_forum_post (主表)
6. campus_category → bus_category (独立表)
7. campus_file → (保留，不迁移)
```

---

## 7. 风险评估

### 7.1 技术风险

| 风险项 | 级别 | 说明 | 应对措施 |
|--------|------|------|----------|
| 数据丢失 | 🟢 低 | 数据量小(48条)，已备份 | 迁移前完整备份 |
| 业务中断 | 🟢 低 | campus表使用率低 | 低峰期执行 |
| API兼容性 | 🟡 中 | 小程序可能调用旧API | 提供兼容层或通知更新 |
| 代码bug | 🟡 中 | 代码迁移可能引入bug | 充分测试 |
| 回滚困难 | 🟢 低 | 保留旧表30天 | 可快速回滚 |

### 7.2 业务风险

| 风险项 | 级别 | 说明 | 应对措施 |
|--------|------|------|----------|
| 用户体验 | 🟢 低 | 数据量小，影响范围小 | 提前通知用户 |
| 功能缺失 | 🟢 低 | bus表功能更完善 | 迁移后功能增强 |
| 数据不一致 | 🟢 低 | 数据量小，容易验证 | 迁移后验证 |

---

## 8. 迁移策略

### 8.1 推荐方案: 渐进式迁移 ⭐

```
阶段1: 数据迁移 (1小时)
├── 备份旧表数据
├── 执行数据迁移脚本
├── 验证数据完整性
└── 重命名旧表 (保留30天)

阶段2: API兼容层 (1小时)
├── 创建临时兼容Controller
├── 旧API路由到新Service
├── 添加@Deprecated注解
└── 监控旧API调用

阶段3: 代码迁移 (2-3小时)
├── 迁移Entity类
├── 迁移Service层
├── 迁移Controller层
├── 更新单元测试
└── 集成测试

阶段4: 清理工作 (1小时)
├── 删除兼容层
├── 删除旧代码
├── 删除旧表 (30天后)
└── 更新文档
```

### 8.2 替代方案: 直接迁移

```
优点: 一次性彻底解决
缺点: 风险较高，需要大量测试
适用场景: 项目处于早期，用户量小
```

---

## 9. 迁移时间估算

| 阶段 | 任务 | 工时 | 负责人 |
|------|------|------|--------|
| 准备 | 编写迁移脚本 | 1h | 待定 |
| 执行 | 数据迁移与验证 | 1h | 待定 |
| 开发 | API兼容层 | 1h | 待定 |
| 开发 | 代码迁移 | 3h | 待定 |
| 测试 | 单元测试 | 1h | 待定 |
| 测试 | 集成测试 | 1h | 待定 |
| 清理 | 删除旧代码 | 1h | 待定 |
| **总计** | - | **9h** | - |

---

## 10. 验收标准

### 10.1 数据完整性
- [ ] 所有campus_content数据已迁移到bus_forum_post
- [ ] 所有campus_comment数据已迁移到bus_forum_comment
- [ ] 所有campus_category数据已迁移到bus_category
- [ ] 所有campus_content_love数据已迁移到bus_forum_post_like
- [ ] 数据记录数一致
- [ ] 关联关系完整

### 10.2 功能完整性
- [ ] 新API功能正常
- [ ] 旧API兼容层工作正常(如启用)
- [ ] 小程序端功能无异常
- [ ] 管理后台功能无异常

### 10.3 性能要求
- [ ] API响应时间无劣化
- [ ] 数据库查询无性能下降

### 10.4 测试覆盖
- [ ] 单元测试通过率100%
- [ ] 集成测试通过率100%
- [ ] 回归测试通过

---

## 11. 回滚方案

### 11.1 回滚触发条件
- 数据迁移失败
- 功能测试不通过
- 性能严重下降
- 发现严重bug

### 11.2 回滚步骤

```bash
# 1. 恢复旧表名称
RENAME TABLE
    campus_content_deprecated_20260116 TO campus_content,
    campus_comment_deprecated_20260116 TO campus_comment,
    campus_category_deprecated_20260116 TO campus_category,
    campus_content_love_deprecated_20260116 TO campus_content_love;

# 2. 删除已迁移的数据
DELETE FROM bus_forum_post WHERE post_id IN (SELECT content_id FROM campus_content_backup_20260116);

# 3. 恢复代码版本
git checkout <迁移前版本>

# 4. 重新部署服务
```

---

## 12. 下一步行动

### 立即执行 (A1.2)

1. ✅ 编写数据迁移SQL脚本
2. ✅ 编写回滚SQL脚本
3. ✅ 在测试环境验证迁移脚本
4. ✅ 执行数据迁移
5. ✅ 验证数据完整性

### 后续任务 (A1.3-A1.5)

6. 创建API兼容层 (可选)
7. 迁移Entity、Service、Controller代码
8. 更新单元测试和集成测试
9. 执行回归测试
10. 清理旧代码和旧表

---

## 13. 结论

### 迁移可行性: ✅ 高度可行

**理由**:
1. 数据量极小 (48条记录)，迁移风险低
2. 新表结构更完善，功能更强
3. 代码影响范围可控 (28个文件)
4. 有完整的回滚方案

**建议**:
- 采用**渐进式迁移**方案
- 在**低峰期**执行
- 保留**API兼容层**2周
- 保留**旧表**30天用于回滚

**预期收益**:
- ✅ 消除两套表并存问题
- ✅ 简化代码维护
- ✅ 统一API设计
- ✅ 降低长期维护成本

---

**报告生成时间**: 2026-01-16
**分析者**: Claude Code
**版本**: 1.0
