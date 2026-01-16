-- =====================================================
-- JingWenCampus 旧表清理脚本
-- ⚠️ 警告：此脚本会永久删除旧表，执行前请确认：
--   1. 新表（bus_*）已经正常运行至少30天
--   2. 所有数据已成功迁移
--   3. 应用代码已完全切换到新表
--   4. 已创建数据库备份
--
-- 版本: 1.0
-- 日期: 2026-01-16
-- =====================================================

USE jingwen_campus;

-- =====================================================
-- 执行前检查
-- =====================================================

-- 检查即将删除的旧表
SELECT '========== 待删除的旧表 ==========' AS summary;
SELECT
    TABLE_NAME,
    TABLE_ROWS,
    ROUND(data_length / 1024 / 1024, 2) AS 'Size(MB)',
    ROUND(data_length / 1024 / 1024, 2) AS 'Data(MB)',
    ROUND(index_length / 1024 / 1024, 2) AS 'Index(MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE 'campus_%'
ORDER BY data_length DESC;

-- 检查对应的新表是否存在且数据正常
SELECT '========== 对应的新表状态 ==========' AS summary;
SELECT 'bus_category (对应 campus_category):' AS item;
SELECT
    COUNT(*) AS row_count,
    MIN(create_time) AS earliest_data,
    MAX(create_time) AS latest_data
FROM bus_category
WHERE category_id <= 1000;

SELECT 'bus_forum_post (对应 campus_content):' AS item;
SELECT
    COUNT(*) AS row_count,
    MIN(create_time) AS earliest_data,
    MAX(create_time) AS latest_data
FROM bus_forum_post;

SELECT 'bus_forum_comment (对应 campus_comment):' AS item;
SELECT
    COUNT(*) AS row_count,
    MIN(create_time) AS earliest_data,
    MAX(create_time) AS latest_data
FROM bus_forum_comment;

SELECT 'bus_forum_post_like (对应 campus_content_love):' AS item;
SELECT
    COUNT(*) AS row_count,
    MIN(create_time) AS earliest_data,
    MAX(create_time) AS latest_data
FROM bus_forum_post_like;

-- =====================================================
-- 数据完整性验证
-- =====================================================

SELECT '========== 数据完整性验证 ==========' AS summary;

-- 验证新表数据量合理（至少有一些数据）
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM bus_category WHERE category_id <= 1000) > 0 THEN '✓ bus_category 有数据'
        ELSE '✗ 警告：bus_category 无数据'
    END AS check_result
UNION ALL
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM bus_forum_post) > 0 THEN '✓ bus_forum_post 有数据'
        ELSE '✗ 警告：bus_forum_post 无数据'
    END AS check_result
UNION ALL
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM bus_forum_comment) > 0 THEN '✓ bus_forum_comment 有数据'
        ELSE '✗ 警告：bus_forum_comment 无数据'
    END AS check_result
UNION ALL
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM bus_forum_post_like) > 0 THEN '✓ bus_forum_post_like 有数据'
        ELSE '✗ 警告：bus_forum_post_like 无数据'
    END AS check_result;

-- =====================================================
-- 删除旧表
-- ⚠️ 以下操作将永久删除数据！
-- =====================================================

-- 注意：实际执行时请取消以下注释
-- 建议逐个执行并在每个删除后验证应用是否正常

/*
-- 删除旧表（按依赖关系排序）
DROP TABLE IF EXISTS campus_content_tag;    -- 内容-标签关联表
DROP TABLE IF EXISTS campus_tag;             -- 标签表
DROP TABLE IF EXISTS campus_content_love;    -- 内容点赞表
DROP TABLE IF EXISTS campus_comment;         -- 评论表
DROP TABLE IF EXISTS campus_content;         -- 内容表
DROP TABLE IF EXISTS campus_category;        -- 分类表

-- campus_file 保留（通用文件表，如需要可删除）
-- DROP TABLE IF EXISTS campus_file;
*/

SELECT '========== 清理完成 ==========' AS summary;
SELECT '已删除的旧表:' AS section;
SELECT 'campus_content_tag' AS item
UNION ALL
SELECT 'campus_tag'
UNION ALL
SELECT 'campus_content_love'
UNION ALL
SELECT 'campus_comment'
UNION ALL
SELECT 'campus_content'
UNION ALL
SELECT 'campus_category';

-- =====================================================
-- 清理后验证
-- =====================================================

-- 确认旧表已删除
SELECT '========== 验证：确认旧表已删除 ==========' AS summary;
SELECT
    TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE 'campus_%';

-- 确认新表仍然存在
SELECT '========== 验证：确认新表正常 ==========' AS summary;
SELECT
    TABLE_NAME,
    TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE 'bus_%'
ORDER BY TABLE_NAME;

-- =====================================================
-- 清理备份表（如果存在且确认不需要）
-- =====================================================

-- 检查是否有备份表
SELECT '========== 检查备份表 ==========' AS summary;
SELECT
    TABLE_NAME,
    TABLE_ROWS,
    ROUND(data_length / 1024 / 1024, 2) AS 'Size(MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'jingwen_campus'
  AND TABLE_NAME LIKE '%backup%'
ORDER BY TABLE_NAME;

-- 如果确认备份表不再需要，可以删除：
-- DROP TABLE IF EXISTS campus_content_backup_20260116;
-- DROP TABLE IF EXISTS campus_comment_backup_20260116;
-- DROP TABLE IF EXISTS campus_category_backup_20260116;
-- DROP TABLE IF EXISTS campus_content_love_backup_20260116;

-- =====================================================
-- 执行建议
-- =====================================================

SELECT '========== 执行建议 ==========' AS summary;
SELECT '1. 在测试环境先执行此脚本' AS step
UNION ALL
SELECT '2. 确认应用功能正常'
UNION ALL
SELECT '3. 监控数据库性能和错误日志'
UNION ALL
SELECT '4. 保留备份表至少7天'
UNION ALL
SELECT '5. 确认无误后再删除备份表';

-- =====================================================
-- 回滚方案（如果需要）
-- =====================================================

-- 如果删除旧表后发现数据丢失，可以从备份表恢复：
-- RENAME TABLE campus_content_backup_20260116 TO campus_content;
-- RENAME TABLE campus_comment_backup_20260116 TO campus_comment;
-- RENAME TABLE campus_category_backup_20260116 TO campus_category;
-- RENAME TABLE campus_content_love_backup_20260116 TO campus_content_love;

-- 然后重新执行 migrate_campus_to_bus.sql 进行迁移

-- =====================================================
-- 完成
-- =====================================================
