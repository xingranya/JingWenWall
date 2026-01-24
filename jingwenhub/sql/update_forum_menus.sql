-- =============================================
-- 管理后台论坛菜单迁移 SQL
-- 将老的内容/评论/标签管理替换为新的论坛管理
-- =============================================

-- 1. 删除老的一级菜单 "校园信息墙"（如果存在）
DELETE FROM sys_role_menu WHERE menu_id IN (
    SELECT menu_id FROM sys_menu WHERE menu_name IN ('内容管理', '评论管理', '标签管理')
);

DELETE FROM sys_menu WHERE menu_name IN ('内容管理', '评论管理', '标签管理');

-- 2. 添加 "论坛管理" 一级菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '论坛管理', 0, 2, 'forum', NULL, '', 1, 0, 'M', '0', '0', '', 'peoples', 'admin', NOW(), '', NULL, '论坛管理目录'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '论坛管理' AND parent_id = 0);

-- 获取论坛管理菜单ID
SET @forum_menu_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '论坛管理' AND parent_id = 0 LIMIT 1);
SET @forum_menu_id = IFNULL(@forum_menu_id, 2100);

-- 3. 添加帖子管理菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '帖子管理', @forum_menu_id, 1, 'post', 'campus/forum/post/index', '', 1, 0, 'C', '0', '0', 'campus:forum:post:list', 'edit', 'admin', NOW(), '', NULL, '论坛帖子管理菜单'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '帖子管理' AND component = 'campus/forum/post/index');

-- 4. 添加评论管理菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '评论管理', @forum_menu_id, 2, 'comment', 'campus/forum/comment/index', '', 1, 0, 'C', '0', '0', 'campus:forum:comment:list', 'message', 'admin', NOW(), '', NULL, '论坛评论管理菜单'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '评论管理' AND component = 'campus/forum/comment/index');

-- 5. 更新分类管理菜单的父级为论坛管理（如果存在）
UPDATE sys_menu SET parent_id = @forum_menu_id, order_num = 3
WHERE menu_name = '分类管理' AND parent_id = 0;

-- 6. 为管理员角色分配新菜单权限
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @forum_menu_id);

SET @post_menu_id = (SELECT menu_id FROM sys_menu WHERE component = 'campus/forum/post/index' LIMIT 1);
SET @comment_menu_id = (SELECT menu_id FROM sys_menu WHERE component = 'campus/forum/comment/index' LIMIT 1);
SET @category_menu_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '分类管理' AND parent_id = @forum_menu_id LIMIT 1);

INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @post_menu_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @comment_menu_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @category_menu_id);

-- 完成提示
SELECT '论坛菜单迁移完成！请刷新管理后台页面查看新菜单。' AS message;
