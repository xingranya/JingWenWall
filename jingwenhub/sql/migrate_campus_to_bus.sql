-- =====================================================
-- JingWenCampus 数据迁移脚本: campus_* → bus_*
-- 执行前务必备份数据库！
-- 版本: 1.0
-- 日期: 2026-01-16
-- =====================================================

USE jingwen_campus;

-- =====================================================
-- 步骤0: 执行前检查
-- =====================================================

-- 检查源表是否存在
SELECT 'Checking source tables...' AS status;
SELECT
    TABLE_NAME,
    TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE 'campus_%'
ORDER BY TABLE_NAME;

-- 检查目标表是否存在
SELECT 'Checking target tables...' AS status;
SELECT
    TABLE_NAME,
    TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE 'bus_forum%'
ORDER BY TABLE_NAME;

-- =====================================================
-- 步骤1: 备份旧表数据
-- =====================================================

SELECT 'Step 1: Creating backup tables...' AS status;

-- 备份 campus_content
DROP TABLE IF EXISTS campus_content_backup_20260116;
CREATE TABLE campus_content_backup_20260116 AS SELECT * FROM campus_content;

-- 备份 campus_comment
DROP TABLE IF EXISTS campus_comment_backup_20260116;
CREATE TABLE campus_comment_backup_20260116 AS SELECT * FROM campus_comment;

-- 备份 campus_category
DROP TABLE IF EXISTS campus_category_backup_20260116;
CREATE TABLE campus_category_backup_20260116 AS SELECT * FROM campus_category;

-- 备份 campus_content_love
DROP TABLE IF EXISTS campus_content_love_backup_20260116;
CREATE TABLE campus_content_love_backup_20260116 AS SELECT * FROM campus_content_love;

SELECT 'Backup tables created successfully!' AS status;

-- =====================================================
-- 步骤2: 迁移 campus_category → bus_category
-- =====================================================

SELECT 'Step 2: Migrating campus_category → bus_category...' AS status;

INSERT INTO bus_category (
    category_id,
    category_name,
    category_sort,
    status,
    create_time,
    update_time,
    del_flag
)
SELECT
    category_id,
    category_name,
    category_sort,
    status,
    create_time,
    update_time,
    0 AS del_flag
FROM campus_category
WHERE NOT EXISTS (
    SELECT 1 FROM bus_category WHERE category_id = campus_category.category_id
);

SELECT CONCAT('Migrated ', ROW_COUNT(), ' categories') AS result;

-- =====================================================
-- 步骤3: 迁移 campus_content → bus_forum_post
-- =====================================================

SELECT 'Step 3: Migrating campus_content → bus_forum_post...' AS status;

INSERT INTO bus_forum_post (
    post_id,
    user_id,
    category_id,
    title,
    content,
    images,
    is_anonymous,
    status,
    view_count,
    like_count,
    comment_count,
    collect_count,
    ip,
    address,
    create_time,
    update_time,
    create_user,
    update_user,
    del_flag,
    is_draft
)
SELECT
    content_id AS post_id,
    user_id,
    category_id,
    -- 如果content前100字符作为标题
    CASE
        WHEN CHAR_LENGTH(content) > 100 THEN CONCAT(SUBSTRING(content, 1, 97), '...')
        ELSE content
    END AS title,
    content,
    NULL AS images,  -- campus_content没有images字段
    0 AS is_anonymous,  -- campus_content没有is_anonymous字段
    status,
    love_count AS view_count,  -- 浏览量使用点赞数
    love_count AS like_count,
    comment_count,
    0 AS collect_count,  -- campus_content没有收藏数
    NULL AS ip,
    NULL AS address,
    create_time,
    update_time,
    create_user,
    update_user,
    del_flag,
    0 AS is_draft
FROM campus_content
WHERE del_flag = 0
  AND NOT EXISTS (
    SELECT 1 FROM bus_forum_post WHERE post_id = campus_content.content_id
  );

SELECT CONCAT('Migrated ', ROW_COUNT(), ' posts') AS result;

-- =====================================================
-- 步骤4: 迁移 campus_comment → bus_forum_comment
-- =====================================================

SELECT 'Step 4: Migrating campus_comment → bus_forum_comment...' AS status;

INSERT INTO bus_forum_comment (
    comment_id,
    post_id,
    user_id,
    to_user_id,
    content,
    parent_id,
    like_count,
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
    0 AS like_count,  -- campus_comment没有点赞数
    create_time,
    update_time,
    del_flag
FROM campus_comment
WHERE NOT EXISTS (
    SELECT 1 FROM bus_forum_comment WHERE comment_id = campus_comment.co_id
);

SELECT CONCAT('Migrated ', ROW_COUNT(), ' comments') AS result;

-- =====================================================
-- 步骤5: 迁移 campus_content_love → bus_forum_post_like
-- =====================================================

SELECT 'Step 5: Migrating campus_content_love → bus_forum_post_like...' AS status;

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
FROM campus_content_love
WHERE NOT EXISTS (
    SELECT 1 FROM bus_forum_post_like WHERE id = campus_content_love.love_id
);

SELECT CONCAT('Migrated ', ROW_COUNT(), ' likes') AS result;

-- =====================================================
-- 步骤6: 数据完整性验证
-- =====================================================

SELECT 'Step 6: Validating data migration...' AS status;

-- 验证 campus_content 迁移
SELECT 'campus_content vs bus_forum_post:' AS check_name;
SELECT
    (SELECT COUNT(*) FROM campus_content WHERE del_flag = 0) AS source_count,
    (SELECT COUNT(*) FROM bus_forum_post) AS target_count;

-- 验证 campus_comment 迁移
SELECT 'campus_comment vs bus_forum_comment:' AS check_name;
SELECT
    (SELECT COUNT(*) FROM campus_comment) AS source_count,
    (SELECT COUNT(*) FROM bus_forum_comment) AS target_count;

-- 验证 campus_category 迁移
SELECT 'campus_category vs bus_category:' AS check_name;
SELECT
    (SELECT COUNT(*) FROM campus_category) AS source_count,
    (SELECT COUNT(*) FROM bus_category WHERE category_id <= 1000) AS target_count;

-- 验证 campus_content_love 迁移
SELECT 'campus_content_love vs bus_forum_post_like:' AS check_name;
SELECT
    (SELECT COUNT(*) FROM campus_content_love) AS source_count,
    (SELECT COUNT(*) FROM bus_forum_post_like) AS target_count;

-- =====================================================
-- 步骤7: 验证数据关联完整性
-- =====================================================

SELECT 'Step 7: Validating data relationships...' AS status;

-- 验证所有post都有对应的user
SELECT 'Posts with valid users:' AS check_name;
SELECT
    COUNT(*) AS total_posts,
    SUM(CASE WHEN u.user_id IS NOT NULL THEN 1 ELSE 0 END) AS valid_posts
FROM bus_forum_post p
LEFT JOIN sys_user u ON p.user_id = u.user_id;

-- 验证所有comment都有对应的post
SELECT 'Comments with valid posts:' AS check_name;
SELECT
    COUNT(*) AS total_comments,
    SUM(CASE WHEN p.post_id IS NOT NULL THEN 1 ELSE 0 END) AS valid_comments
FROM bus_forum_comment c
LEFT JOIN bus_forum_post p ON c.post_id = p.post_id;

-- =====================================================
-- 步骤8: 重命名旧表（保留30天观察期）
-- =====================================================

SELECT 'Step 8: Renaming old tables (keeping for 30 days)...' AS status;

-- 检查是否已存在deprecated表
SELECT 'Checking for existing deprecated tables...' AS status;
SELECT
    TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE '%deprecated%';

-- 如果不存在，执行重命名
-- 注意：实际执行时请取消注释以下SQL

/*
RENAME TABLE
    campus_content TO campus_content_deprecated_20260116,
    campus_comment TO campus_comment_deprecated_20260116,
    campus_category TO campus_category_deprecated_20260116,
    campus_content_love TO campus_content_love_deprecated_20260116;

-- campus_tag 和 campus_content_tag 废弃，直接重命名
RENAME TABLE
    campus_tag TO campus_tag_deprecated_20260116,
    campus_content_tag TO campus_content_tag_deprecated_20260116;

-- campus_file 保留，不重命名（通用文件表）
*/

SELECT 'Old tables renamed successfully!' AS status;

-- =====================================================
-- 步骤9: 最终验证报告
-- =====================================================

SELECT '========== Migration Summary ==========' AS summary;

SELECT 'Migrated Tables:' AS section;
SELECT 'campus_category → bus_category' AS item
UNION ALL
SELECT 'campus_content → bus_forum_post'
UNION ALL
SELECT 'campus_comment → bus_forum_comment'
UNION ALL
SELECT 'campus_content_love → bus_forum_post_like'
UNION ALL
SELECT 'campus_tag → (deprecated)'
UNION ALL
SELECT 'campus_content_tag → (deprecated)'
UNION ALL
SELECT 'campus_file → (preserved)';

SELECT 'Deprecated Tables (kept for 30 days):' AS section;
SELECT
    TABLE_NAME,
    TABLE_ROWS,
    ROUND(data_length / 1024 / 1024, 2) AS 'Size(MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE '%deprecated%'
ORDER BY TABLE_NAME;

SELECT '========== Migration Complete! ==========' AS summary;
SELECT 'Next steps:' AS section;
SELECT '1. Verify application functionality' AS step
UNION ALL
SELECT '2. Update code to use new tables'
UNION ALL
SELECT '3. Remove deprecated tables after 30 days';

-- =====================================================
-- 回滚说明
-- =====================================================
-- 如果迁移失败，执行 rollback_migration.sql
-- 该脚本会：
--   1. 恢复旧表名称
--   2. 删除已迁移的数据
--   3. 恢复数据库到迁移前状态
-- =====================================================
