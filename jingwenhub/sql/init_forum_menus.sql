-- =============================================
-- 管理后台菜单完整更新 SQL（修复版）
-- 执行此脚本后刷新管理后台页面即可看到新菜单
-- =============================================

USE jingwen_campus;

-- 1. 先删除所有老的校园信息墙相关菜单和权限
DELETE FROM sys_role_menu WHERE menu_id IN (
    SELECT menu_id FROM sys_menu WHERE menu_name IN ('内容管理', '评论管理', '标签管理', '帖子管理', '分类管理')
    AND parent_id IN (0, (SELECT menu_id FROM sys_menu WHERE menu_name = '校园信息墙' AND parent_id = 0 LIMIT 1))
);

DELETE FROM sys_menu WHERE menu_name IN ('内容管理', '评论管理', '标签管理');

-- 删除老的"校园信息墙"一级菜单（如果存在）
DELETE FROM sys_menu WHERE menu_name = '校园信息墙' AND parent_id = 0;

-- 2. 创建"论坛管理"一级菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES ('论坛管理', 0, 2, 'forum', NULL, '', 1, 0, 'M', '0', '0', '', 'peoples', '论坛管理目录');

-- 获取论坛管理菜单ID
SET @forum_menu_id = LAST_INSERT_ID();

-- 3. 创建"帖子管理"菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES ('帖子管理', @forum_menu_id, 1, 'post', 'campus/forum/post/index', '', 1, 0, 'C', '0', '0', 'campus:forum:post:list', 'edit', '论坛帖子管理菜单');

SET @post_menu_id = LAST_INSERT_ID();

-- 添加帖子管理的按钮权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES
('帖子查询', @post_menu_id, 1, '#', '', '', 1, 0, 'F', '0', '0', 'campus:forum:post:query', '#', ''),
('帖子修改', @post_menu_id, 2, '#', '', '', 1, 0, 'F', '0', '0', 'campus:forum:post:edit', '#', ''),
('帖子删除', @post_menu_id, 3, '#', '', '', 1, 0, 'F', '0', '0', 'campus:forum:post:remove', '#', ''),
('帖子审核', @post_menu_id, 4, '#', '', '', 1, 0, 'F', '0', '0', 'campus:forum:post:audit', '#', '');

-- 4. 创建"评论管理"菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES ('评论管理', @forum_menu_id, 2, 'comment', 'campus/forum/comment/index', '', 1, 0, 'C', '0', '0', 'campus:forum:comment:list', 'message', '论坛评论管理菜单');

SET @comment_menu_id = LAST_INSERT_ID();

-- 添加评论管理的按钮权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES
('评论查询', @comment_menu_id, 1, '#', '', '', 1, 0, 'F', '0', '0', 'campus:forum:comment:query', '#', ''),
('评论删除', @comment_menu_id, 2, '#', '', '', 1, 0, 'F', '0', '0', 'campus:forum:comment:remove', '#', ''),
('评论审核', @comment_menu_id, 3, '#', '', '', 1, 0, 'F', '0', '0', 'campus:forum:comment:audit', '#', '');

-- 5. 更新或创建"分类管理"菜单
-- 先删除旧的分类管理（如果存在）
DELETE FROM sys_menu WHERE menu_name = '分类管理' AND parent_id = 0;

-- 创建新的分类管理菜单（归属于论坛管理）
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES ('分类管理', @forum_menu_id, 3, 'category', 'campus/category/index', '', 1, 0, 'C', '0', '0', 'campus:category:list', 'tree-table', '分类管理菜单');

SET @category_menu_id = LAST_INSERT_ID();

-- 添加分类管理的按钮权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES
('分类查询', @category_menu_id, 1, '#', '', '', 1, 0, 'F', '0', '0', 'campus:category:query', '#', ''),
('分类新增', @category_menu_id, 2, '#', '', '', 1, 0, 'F', '0', '0', 'campus:category:add', '#', ''),
('分类修改', @category_menu_id, 3, '#', '', '', 1, 0, 'F', '0', '0', 'campus:category:edit', '#', ''),
('分类删除', @category_menu_id, 4, '#', '', '', 1, 0, 'F', '0', '0', 'campus:category:remove', '#', '');

-- 6. 为管理员角色（role_id=1）分配所有新菜单权限
INSERT IGNORE INTO sys_role_menu (role_id, menu_id)
SELECT 1, menu_id FROM sys_menu WHERE parent_id = @forum_menu_id OR menu_id = @forum_menu_id;

-- 7. 验证插入结果
SELECT
    m.menu_id,
    m.menu_name,
    m.parent_id,
    m.order_num,
    m.path,
    m.component,
    m.menu_type,
    CASE WHEN m.menu_type = 'M' THEN '一级菜单'
         WHEN m.menu_type = 'C' THEN '页面菜单'
         WHEN m.menu_type = 'F' THEN '按钮权限'
    END AS menu_type_name,
    m.status
FROM sys_menu m
WHERE m.menu_id = @forum_menu_id
   OR m.parent_id = @forum_menu_id
ORDER BY m.parent_id, m.order_num;

-- 完成提示
SELECT '============================================' AS '';
SELECT '论坛菜单创建完成！' AS message;
SELECT '请按以下步骤操作：' AS '';
SELECT '1. 刷新管理后台页面（Ctrl + F5）' AS '';
SELECT '2. 重新登录管理后台' AS '';
SELECT '3. 即可在左侧菜单看到"论坛管理"模块' AS '';
SELECT '============================================' AS '';
