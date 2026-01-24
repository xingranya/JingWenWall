-- =============================================
-- 诊断和修复脚本 - 检查并重建论坛菜单
-- =============================================

USE jingwen_campus;

-- 1. 检查当前论坛相关菜单
SELECT '=== 当前论坛相关菜单 ===' AS '';
SELECT menu_id, menu_name, parent_id, path, component, menu_type, status
FROM sys_menu
WHERE menu_name LIKE '%论坛%' OR menu_name LIKE '%帖子%' OR menu_name LIKE '%评论%' OR path LIKE '%forum%'
ORDER BY parent_id, order_num;

-- 2. 检查管理员角色的菜单权限
SELECT '=== 管理员角色(role_id=1)的菜单数量 ===' AS '';
SELECT COUNT(*) as menu_count FROM sys_role_menu WHERE role_id = 1;

-- 3. 删除所有可能的旧论坛菜单
DELETE FROM sys_role_menu WHERE menu_id IN (
    SELECT menu_id FROM sys_menu
    WHERE menu_name IN ('内容管理', '评论管理', '标签管理', '帖子管理', '分类管理', '论坛管理')
    OR path LIKE '%forum%'
    OR component LIKE '%forum%'
);

DELETE FROM sys_menu WHERE menu_name IN ('内容管理', '评论管理', '标签管理', '帖子管理', '分类管理', '论坛管理');
DELETE FROM sys_menu WHERE path LIKE '%forum%' OR component LIKE '%forum%';

-- 4. 重新创建论坛管理菜单（使用安全的menu_id）
SET @forum_id = 3000;
SET @post_id = 3001;
SET @comment_id = 3002;
SET @category_id = 3003;

-- 论坛管理（一级菜单）
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES (@forum_id, '论坛管理', 0, 2, 'forum', NULL, '', 1, 0, 'M', '0', '0', '', 'peoples', '论坛管理目录')
ON DUPLICATE KEY UPDATE menu_name='论坛管理';

-- 帖子管理（二级菜单）
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES (@post_id, '帖子管理', @forum_id, 1, 'post', 'campus/forum/post/index', '', 1, 0, 'C', '0', '0', 'campus:forum:post:list', 'edit', '论坛帖子管理菜单')
ON DUPLICATE KEY UPDATE component='campus/forum/post/index';

-- 评论管理（二级菜单）
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES (@comment_id, '评论管理', @forum_id, 2, 'comment', 'campus/forum/comment/index', '', 1, 0, 'C', '0', '0', 'campus:forum:comment:list', 'message', '论坛评论管理菜单')
ON DUPLICATE KEY UPDATE component='campus/forum/comment/index';

-- 分类管理（二级菜单）
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, remark)
VALUES (@category_id, '分类管理', @forum_id, 3, 'category', 'campus/category/index', '', 1, 0, 'C', '0', '0', 'campus:category:list', 'tree-table', '分类管理菜单')
ON DUPLICATE KEY UPDATE parent_id=@forum_id;

-- 5. 为管理员角色分配权限
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @forum_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @post_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @comment_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @category_id);

-- 6. 验证结果
SELECT '=== 重建后的论坛菜单 ===' AS '';
SELECT menu_id, menu_name, parent_id, path, component, menu_type, status
FROM sys_menu
WHERE menu_id IN (@forum_id, @post_id, @comment_id, @category_id)
ORDER BY menu_id;

SELECT '=== 管理员角色权限 ===' AS '';
SELECT rm.role_id, m.menu_name, m.component
FROM sys_role_menu rm
JOIN sys_menu m ON rm.menu_id = m.menu_id
WHERE rm.role_id = 1 AND m.menu_id IN (@forum_id, @post_id, @comment_id, @category_id);

-- 7. 检查菜单状态
SELECT '=== 菜单状态检查 ===' AS '';
SELECT
    m.menu_id,
    m.menu_name,
    m.status AS menu_status,
    m.visible,
    rm.role_id
FROM sys_menu m
LEFT JOIN sys_role_menu rm ON m.menu_id = rm.menu_id AND rm.role_id = 1
WHERE m.menu_id IN (@forum_id, @post_id, @comment_id, @category_id);

SELECT '============================================' AS '';
SELECT '修复完成！请执行以下操作：' AS '';
SELECT '1. 复制下面的SQL到MySQL客户端执行' AS '';
SELECT '2. 在管理后台按 Ctrl+Shift+R 清除缓存' AS '';
SELECT '3. 退出并重新登录管理后台' AS '';
SELECT '============================================' AS '';
