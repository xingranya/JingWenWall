-- ============================================
-- JingWenWall 数据库索引优化 - 第二批
-- 执行时间: 2026-01-16
-- 目标: 优化二手市场和举报模块查询性能
-- ============================================

USE jingwen_campus;

-- 1. bus_market_item 表索引
-- 优化场景: 商品列表、分类商品查询、商品搜索、用户商品查询
ALTER TABLE bus_market_item
ADD INDEX idx_status_create_time (status, create_time DESC),
ADD INDEX idx_category_status (category_id, status),
ADD INDEX idx_user_status_time (user_id, status, create_time DESC),
ADD INDEX idx_title_search (title(100)),  -- 前缀索引优化LIKE查询
ADD INDEX idx_desc_search (description(255));  -- 前缀索引优化描述搜索

-- 2. bus_market_collect 表索引 (如果存在)
-- 优化场景: 用户收藏列表查询
ALTER TABLE bus_market_collect
ADD INDEX idx_user_create_time (user_id, create_time DESC),
ADD INDEX idx_item_create_time (item_id, create_time DESC);

-- 3. bus_report 表索引
-- 优化场景: 举报列表查询、用户举报查询、举报状态查询
ALTER TABLE bus_report
ADD INDEX idx_target_type_status (target_type, status, create_time DESC),
ADD INDEX idx_reporter_status_time (reporter_id, status, create_time DESC),
ADD INDEX idx_target_id_type (target_id, target_type);

-- ============================================
-- 索引说明
-- ============================================
--
-- bus_market_item (二手商品表):
-- - idx_status_create_time: 优化商品列表按时间排序
-- - idx_category_status: 优化分类商品查询
-- - idx_user_status_time: 优化用户发布商品查询
-- - idx_title_search: 优化商品标题搜索(前缀索引减少空间占用)
-- - idx_desc_search: 优化商品描述搜索(前缀索引)
--
-- bus_market_collect (商品收藏表):
-- - idx_user_create_time: 优化用户收藏列表
-- - idx_item_create_time: 优化商品收藏统计
--
-- bus_report (举报表):
-- - idx_target_type_status: 优化按目标类型和状态筛选举报
-- - idx_reporter_status_time: 优化用户举报记录查询
-- - idx_target_id_type: 优化特定对象举报查询
--
-- ============================================
-- 验证索引创建结果
-- ============================================

-- 验证 bus_market_item 索引
SHOW INDEX FROM bus_market_item WHERE Key_name LIKE 'idx_%';

-- 验证 bus_market_collect 索引
SHOW INDEX FROM bus_market_collect WHERE Key_name LIKE 'idx_%';

-- 验证 bus_report 索引
SHOW INDEX FROM bus_report WHERE Key_name LIKE 'idx_%';

-- ============================================
-- 性能验证查询
-- ============================================

-- 测试商品列表查询性能 (应该使用 idx_status_create_time)
EXPLAIN SELECT * FROM bus_market_item
WHERE status = 1
ORDER BY create_time DESC
LIMIT 20;

-- 测试分类商品查询 (应该使用 idx_category_status)
EXPLAIN SELECT * FROM bus_market_item
WHERE category_id = 1001 AND status = 1
ORDER BY create_time DESC;

-- 测试商品搜索 (应该使用 idx_title_search)
EXPLAIN SELECT * FROM bus_market_item
WHERE title LIKE '%书本%'
AND status = 1;

-- 测试举报列表查询 (应该使用 idx_target_type_status)
EXPLAIN SELECT * FROM bus_report
WHERE target_type = 'post' AND status = 0
ORDER BY create_time DESC;
