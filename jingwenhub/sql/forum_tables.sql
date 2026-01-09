-- =============================================
-- 贴吧模块数据库表结构
-- 创建时间: 2026-01-09
-- =============================================

-- 1. 分类表
CREATE TABLE IF NOT EXISTS `bus_category` (
    `category_id` BIGINT NOT NULL COMMENT '分类ID',
    `category_name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '分类描述',
    `icon` VARCHAR(200) DEFAULT NULL COMMENT '分类图标',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 0 COMMENT '状态(0-正常, 1-禁用)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `create_user` BIGINT DEFAULT NULL COMMENT '创建人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `update_user` BIGINT DEFAULT NULL COMMENT '更新人',
    `del_flag` BIT DEFAULT 0 COMMENT '删除标志(0-未删除, 1-已删除)',
    PRIMARY KEY (`category_id`),
    KEY `idx_sort` (`sort`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类表';

-- 2. 帖子表
CREATE TABLE IF NOT EXISTS `bus_forum_post` (
    `post_id` BIGINT NOT NULL COMMENT '帖子ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `category_id` BIGINT DEFAULT NULL COMMENT '分类ID',
    `title` VARCHAR(100) NOT NULL COMMENT '帖子标题',
    `content` TEXT NOT NULL COMMENT '帖子内容',
    `images` VARCHAR(2000) DEFAULT NULL COMMENT '图片URL列表(JSON数组)',
    `is_anonymous` TINYINT DEFAULT 0 COMMENT '是否匿名(0-否, 1-是)',
    `is_draft` TINYINT DEFAULT 0 COMMENT '是否草稿(0-否, 1-是)',
    `view_count` INT DEFAULT 0 COMMENT '浏览次数',
    `like_count` INT DEFAULT 0 COMMENT '点赞次数',
    `comment_count` INT DEFAULT 0 COMMENT '评论次数',
    `collect_count` INT DEFAULT 0 COMMENT '收藏次数',
    `status` TINYINT DEFAULT 0 COMMENT '状态(0-正常, 1-禁用)',
    `ip` VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
    `address` VARCHAR(200) DEFAULT NULL COMMENT '地理位置',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `create_user` BIGINT DEFAULT NULL COMMENT '创建人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `update_user` BIGINT DEFAULT NULL COMMENT '更新人',
    `del_flag` BIT DEFAULT 0 COMMENT '删除标志(0-未删除, 1-已删除)',
    PRIMARY KEY (`post_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_create_time` (`create_time`),
    KEY `idx_is_draft` (`is_draft`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='贴吧帖子表';

-- 3. 帖子点赞表
CREATE TABLE IF NOT EXISTS `bus_forum_post_like` (
    `like_id` BIGINT NOT NULL COMMENT '点赞ID',
    `post_id` BIGINT NOT NULL COMMENT '帖子ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `create_user` BIGINT DEFAULT NULL COMMENT '创建人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `update_user` BIGINT DEFAULT NULL COMMENT '更新人',
    `del_flag` BIT DEFAULT 0 COMMENT '删除标志(0-未删除, 1-已删除)',
    PRIMARY KEY (`like_id`),
    UNIQUE KEY `uk_post_user` (`post_id`, `user_id`, `del_flag`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子点赞表';

-- 4. 帖子收藏表
CREATE TABLE IF NOT EXISTS `bus_forum_post_collect` (
    `collect_id` BIGINT NOT NULL COMMENT '收藏ID',
    `post_id` BIGINT NOT NULL COMMENT '帖子ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `create_user` BIGINT DEFAULT NULL COMMENT '创建人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `update_user` BIGINT DEFAULT NULL COMMENT '更新人',
    `del_flag` BIT DEFAULT 0 COMMENT '删除标志(0-未删除, 1-已删除)',
    PRIMARY KEY (`collect_id`),
    UNIQUE KEY `uk_post_user` (`post_id`, `user_id`, `del_flag`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_post_id` (`post_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子收藏表';

-- 5. 帖子评论表
CREATE TABLE IF NOT EXISTS `bus_forum_comment` (
    `comment_id` BIGINT NOT NULL COMMENT '评论ID',
    `post_id` BIGINT NOT NULL COMMENT '帖子ID',
    `user_id` BIGINT NOT NULL COMMENT '评论用户ID',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父评论ID(0表示一级评论)',
    `to_user_id` BIGINT DEFAULT NULL COMMENT '回复目标用户ID(二级评论时使用)',
    `content` TEXT NOT NULL COMMENT '评论内容',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `status` TINYINT DEFAULT 0 COMMENT '状态(0-正常, 1-禁用)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `create_user` BIGINT DEFAULT NULL COMMENT '创建人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `update_user` BIGINT DEFAULT NULL COMMENT '更新人',
    `del_flag` BIT DEFAULT 0 COMMENT '删除标志(0-未删除, 1-已删除)',
    PRIMARY KEY (`comment_id`),
    KEY `idx_post_id` (`post_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子评论表';

-- =============================================
-- 示例数据(可选)
-- =============================================

-- 插入默认分类
INSERT INTO `bus_category` (`category_id`, `category_name`, `description`, `sort`, `status`) 
VALUES 
    (1001, '校园生活', '分享校园生活趣事', 1, 0),
    (1002, '学习交流', '学术讨论和学习经验分享', 2, 0),
    (1003, '失物招领', '失物报失和拾到物品认领', 3, 0),
    (1004, '二手交易', '闲置物品交易', 4, 0),
    (1005, '社团活动', '社团招新和活动宣传', 5, 0),
    (1006, '其他', '其他相关内容', 99, 0)
ON DUPLICATE KEY UPDATE category_name = VALUES(category_name);
