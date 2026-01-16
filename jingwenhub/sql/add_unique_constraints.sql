-- ============================================
-- 数据库唯一约束添加脚本
-- 创建日期: 2026-01-16
-- ============================================

USE jingwen_campus;

-- 1. 手机号唯一约束
-- 问题: 同一手机号可以注册多个账号
-- 解决方案: 添加唯一索引
ALTER TABLE sys_user
ADD UNIQUE INDEX uk_phonenumber (phonenumber) COMMENT '手机号唯一索引';

-- 2. 邮箱唯一约束
-- 问题: 同一邮箱可以注册多个账号
-- 解决方案: 添加唯一索引（允许NULL）
ALTER TABLE sys_user
ADD UNIQUE INDEX uk_email (email) COMMENT '邮箱唯一索引';

-- 3. 修复软删除唯一索引冲突
-- 问题: bus_forum_post_collect 的唯一索引包含 del_flag
--       导致软删除后无法再次收藏
-- 解决方案: 重建唯一索引，移除 del_flag

-- 删除旧索引（如果存在）
DROP INDEX IF EXISTS uk_post_user ON bus_forum_post_collect;

-- 创建新的唯一索引（不包含 del_flag）
ALTER TABLE bus_forum_post_collect
ADD UNIQUE INDEX uk_user_post (user_id, post_id) COMMENT '用户帖子收藏唯一索引（无软删除字段）';

-- 验证索引创建
SHOW INDEX FROM sys_user WHERE Key_name IN ('uk_phonenumber', 'uk_email');
SHOW INDEX FROM bus_forum_post_collect WHERE Key_name = 'uk_user_post';
