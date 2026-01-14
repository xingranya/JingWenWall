-- =============================================
-- 管理后台新增菜单 SQL
-- 跑腿管理、二手市场管理、举报管理
-- 执行此脚本后刷新管理后台页面即可看到新菜单
-- =============================================

-- 1. 添加 "业务管理" 一级菜单 (如果不存在)
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '业务管理', 0, 3, 'business', null, '', 1, 0, 'M', '0', '0', '', 'chart', 'admin', NOW(), '', null, '业务管理目录'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0);

-- 获取业务管理菜单ID (假设为 2000，实际需要根据插入后的ID调整)
SET @business_menu_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '业务管理' AND parent_id = 0 LIMIT 1);

-- 如果没有找到业务管理菜单，使用默认ID
SET @business_menu_id = IFNULL(@business_menu_id, 2000);

-- 2. 添加跑腿管理菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '跑腿管理', @business_menu_id, 1, 'errand', 'campus/errand/index', '', 1, 0, 'C', '0', '0', 'campus:errand:list', 'peoples', 'admin', NOW(), '', null, '跑腿订单管理菜单'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '跑腿管理' AND component = 'campus/errand/index');

-- 3. 添加二手市场管理菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '二手市场', @business_menu_id, 2, 'market', 'campus/market/index', '', 1, 0, 'C', '0', '0', 'campus:market:list', 'shopping', 'admin', NOW(), '', null, '二手商品管理菜单'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '二手市场' AND component = 'campus/market/index');

-- 4. 添加举报管理菜单
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '举报管理', @business_menu_id, 3, 'report', 'campus/report/index', '', 1, 0, 'C', '0', '0', 'campus:report:list', 'message', 'admin', NOW(), '', null, '举报管理菜单'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_name = '举报管理' AND component = 'campus/report/index');

-- 5. 为管理员角色分配新菜单权限 (假设管理员角色ID为1)
-- 获取新增菜单的ID
SET @errand_menu_id = (SELECT menu_id FROM sys_menu WHERE component = 'campus/errand/index' LIMIT 1);
SET @market_menu_id = (SELECT menu_id FROM sys_menu WHERE component = 'campus/market/index' LIMIT 1);
SET @report_menu_id = (SELECT menu_id FROM sys_menu WHERE component = 'campus/report/index' LIMIT 1);

-- 分配给管理员角色
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @business_menu_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @errand_menu_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @market_menu_id);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, @report_menu_id);

-- 完成提示
SELECT '菜单添加完成！请刷新管理后台页面查看新菜单。' AS message;
