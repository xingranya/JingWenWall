-- =====================================================
-- JingWenCampus 数据迁移回滚脚本
-- 仅在迁移失败时执行！
-- 版本: 1.0
-- 日期: 2026-01-16
-- =====================================================

USE jingwen_campus;

-- =====================================================
-- 警告：执行此脚本将撤销迁移操作！
-- =====================================================

SELECT '⚠️  WARNING: This will rollback the migration!' AS warning;
SELECT '⚠️  Make sure you want to proceed!' AS warning;

-- =====================================================
-- 步骤1: 删除已迁移的数据
-- =====================================================

SELECT 'Step 1: Deleting migrated data...' AS status;

-- 从备份数据中获取已迁移的ID，并删除
SET @post_ids := (SELECT GROUP_CONCAT(content_id) FROM campus_content_backup_20260116);
SET @comment_ids := (SELECT GROUP_CONCAT(co_id) FROM campus_comment_backup_20260116);
SET @category_ids := (SELECT GROUP_CONCAT(category_id) FROM campus_category_backup_20260116);
SET @love_ids := (SELECT GROUP_CONCAT(love_id) FROM campus_content_love_backup_20260116);

-- 删除迁移到 bus_forum_post 的数据
IF @post_ids IS NOT NULL THEN
    DELETE FROM bus_forum_post
    WHERE FIND_IN_SET(post_id, @post_ids) > 0;
END IF;

SELECT CONCAT('Deleted ', ROW_COUNT(), ' posts from bus_forum_post') AS result;

-- 删除迁移到 bus_forum_comment 的数据
IF @comment_ids IS NOT NULL THEN
    DELETE FROM bus_forum_comment
    WHERE FIND_IN_SET(comment_id, @comment_ids) > 0;
END IF;

SELECT CONCAT('Deleted ', ROW_COUNT(), ' comments from bus_forum_comment') AS result;

-- 删除迁移到 bus_category 的数据
IF @category_ids IS NOT NULL THEN
    DELETE FROM bus_category
    WHERE FIND_IN_SET(category_id, @category_ids) > 0;
END IF;

SELECT CONCAT('Deleted ', ROW_COUNT(), ' categories from bus_category') AS result;

-- 删除迁移到 bus_forum_post_like 的数据
IF @love_ids IS NOT NULL THEN
    DELETE FROM bus_forum_post_like
    WHERE FIND_IN_SET(id, @love_ids) > 0;
END IF;

SELECT CONCAT('Deleted ', ROW_COUNT(), ' likes from bus_forum_post_like') AS result;

-- =====================================================
-- 步骤2: 恢复旧表名称
-- =====================================================

SELECT 'Step 2: Restoring old table names...' AS status;

-- 恢复 campus_content
RENAME TABLE
    campus_content_deprecated_20260116 TO campus_content;

-- 恢复 campus_comment
RENAME TABLE
    campus_comment_deprecated_20260116 TO campus_comment;

-- 恢复 campus_category
RENAME TABLE
    campus_category_deprecated_20260116 TO campus_category;

-- 恢复 campus_content_love
RENAME TABLE
    campus_content_love_deprecated_20260116 TO campus_content_love;

-- 恢复 campus_tag (如果需要)
-- RENAME TABLE campus_tag_deprecated_20260116 TO campus_tag;

-- 恢复 campus_content_tag (如果需要)
-- RENAME TABLE campus_content_tag_deprecated_20260116 TO campus_content_tag;

SELECT 'Old table names restored successfully!' AS status;

-- =====================================================
-- 步骤3: 验证回滚结果
-- =====================================================

SELECT 'Step 3: Verifying rollback...' AS status;

-- 验证 campus_content 表已恢复
SELECT 'campus_content restored:' AS check_name;
SELECT COUNT(*) AS record_count FROM campus_content;

-- 验证 campus_comment 表已恢复
SELECT 'campus_comment restored:' AS check_name;
SELECT COUNT(*) AS record_count FROM campus_comment;

-- 验证 campus_category 表已恢复
SELECT 'campus_category restored:' AS check_name;
SELECT COUNT(*) AS record_count FROM campus_category;

-- 验证 campus_content_love 表已恢复
SELECT 'campus_content_love restored:' AS check_name;
SELECT COUNT(*) AS record_count FROM campus_content_love;

-- 验证备份数据仍存在
SELECT 'Backup tables still exist:' AS check_name;
SELECT
    'campus_content_backup_20260116' AS table_name,
    (SELECT COUNT(*) FROM campus_content_backup_20260116) AS record_count
UNION ALL
SELECT
    'campus_comment_backup_20260116',
    (SELECT COUNT(*) FROM campus_comment_backup_20260116)
UNION ALL
SELECT
    'campus_category_backup_20260116',
    (SELECT COUNT(*) FROM campus_category_backup_20260116)
UNION ALL
SELECT
    'campus_content_love_backup_20260116',
    (SELECT COUNT(*) FROM campus_content_love_backup_20260116);

-- =====================================================
-- 步骤4: 清理备份数据（可选）
-- =====================================================

-- 注意：建议保留备份数据至少30天！
-- 以下SQL仅在确认回滚成功且不需要备份数据时执行

/*
-- 确认是否删除备份数据
SELECT '⚠️  WARNING: About to delete backup tables!' AS warning;
SELECT '⚠️  Keep backups for at least 30 days!' AS warning;

-- 删除备份数据（谨慎执行！）
DROP TABLE IF EXISTS campus_content_backup_20260116;
DROP TABLE IF EXISTS campus_comment_backup_20260116;
DROP TABLE IF EXISTS campus_category_backup_20260116;
DROP TABLE IF EXISTS campus_content_love_backup_20260116;

SELECT 'Backup tables deleted' AS status;
*/

-- =====================================================
-- 回滚完成
-- =====================================================

SELECT '========== Rollback Complete! ==========' AS summary;
SELECT 'Database has been restored to pre-migration state' AS status;
SELECT 'Next steps:' AS section;
SELECT '1. Verify application is working correctly' AS step
UNION ALL
SELECT '2. Fix migration issues'
UNION ALL
SELECT '3. Re-run migration when ready';

-- =====================================================
-- 说明
-- =====================================================
-- 此脚本会：
--   1. 删除已迁移到新表的数据
--   2. 恢复旧表名称
--   3. 保留备份数据供验证
--
-- 注意：
--   - 执行前确保应用已停止
--   - 执行后重启应用验证功能
--   - 备份数据建议保留30天
--   - 如果回滚后数据有问题，可从备份表恢复
-- =====================================================
