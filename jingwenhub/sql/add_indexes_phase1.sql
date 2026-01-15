-- ============================================
-- JingWenWall 数据库索引优化 - 第一批
-- 执行时间: 2026-01-16
-- 目标: 解决核心表查询性能问题,从5秒+降至<100ms
-- ============================================

USE jingwen_campus;

-- 1. campus_content 表索引
-- 优化场景: 用户内容列表、分类内容查询、内容时间线
ALTER TABLE campus_content
ADD INDEX idx_user_status_time (user_id, status, create_time DESC),
ADD INDEX idx_category_status (category_id, status),
ADD INDEX idx_status_create_time (status, create_time DESC);

-- 2. campus_comment 表索引
-- 优化场景: 内容评论列表、用户评论查询、评论时间线
ALTER TABLE campus_comment
ADD INDEX idx_content_parent_time (content_id, parent_id, create_time DESC),
ADD INDEX idx_user_del_time (user_id, del_flag, create_time DESC);

-- 3. bus_forum_post 表索引
-- 优化场景: 用户帖子列表、分类帖子查询、帖子时间线
ALTER TABLE bus_forum_post
ADD INDEX idx_user_status_time (user_id, status, create_time DESC),
ADD INDEX idx_category_status (category_id, status);

-- 4. bus_forum_comment 表索引
-- 优化场景: 帖子评论列表、评论时间线
ALTER TABLE bus_forum_comment
ADD INDEX idx_post_parent_time (post_id, parent_id, create_time DESC);

-- 5. bus_errand_order 表索引
-- 优化场景: 订单状态查询、跑腿员订单列表、订单时间线
ALTER TABLE bus_errand_order
ADD INDEX idx_status_pay_time (status, pay_status, create_time DESC),
ADD INDEX idx_runner_status (runner_id, status);

-- ============================================
-- 验证索引创建结果
-- ============================================

-- 验证 campus_content 索引
SHOW INDEX FROM campus_content WHERE Key_name LIKE 'idx_%';

-- 验证 campus_comment 索引
SHOW INDEX FROM campus_comment WHERE Key_name LIKE 'idx_%';

-- 验证 bus_forum_post 索引
SHOW INDEX FROM bus_forum_post WHERE Key_name LIKE 'idx_%';

-- 验证 bus_forum_comment 索引
SHOW INDEX FROM bus_forum_comment WHERE Key_name LIKE 'idx_%';

-- 验证 bus_errand_order 索引
SHOW INDEX FROM bus_errand_order WHERE Key_name LIKE 'idx_%';
