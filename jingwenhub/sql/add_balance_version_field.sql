-- =====================================================
-- 添加学生表乐观锁版本号字段
-- 功能: 修复余额并发控制问题，防止余额变成负数或重复扣款
-- 作者: jingwen
-- 日期: 2026-01-16
-- =====================================================

-- 1. 添加乐观锁版本号字段
ALTER TABLE bus_student ADD COLUMN version INT DEFAULT 0 COMMENT '乐观锁版本号';

-- 2. 初始化现有数据
UPDATE bus_student SET version = 0 WHERE version IS NULL;

-- 3. 添加唯一索引以保证数据一致性
ALTER TABLE bus_student ADD UNIQUE INDEX uk_student_version (student_id, version);

-- =====================================================
-- 说明:
-- - version字段由MyBatis-Plus的@Version注解自动管理
-- - 每次更新时会自动+1，如果version不匹配则更新失败
-- - 配合分布式锁实现完整的并发控制
-- =====================================================
