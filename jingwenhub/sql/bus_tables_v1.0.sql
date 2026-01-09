-- ============================================
-- 荆文校园综合服务平台 - 业务表设计 v1.0
-- 执行前请确保已创建数据库: jingwen_campus
-- ============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------
-- 1. 学生信息扩展表 (与 sys_user 1:1 关联)
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_student`;
CREATE TABLE `bus_student` (
  `student_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '关联sys_user的user_id',
  `openid` varchar(64) DEFAULT NULL COMMENT '微信OpenID',
  `unionid` varchar(64) DEFAULT NULL COMMENT '微信UnionID',
  `student_no` varchar(32) DEFAULT NULL COMMENT '学号',
  `real_name` varchar(32) DEFAULT NULL COMMENT '真实姓名',
  `college` varchar(64) DEFAULT NULL COMMENT '学院',
  `major` varchar(64) DEFAULT NULL COMMENT '专业',
  `grade` varchar(10) DEFAULT NULL COMMENT '年级',
  `credit_score` int(11) DEFAULT 100 COMMENT '信用分 (初始100)',
  `balance` decimal(10,2) DEFAULT 0.00 COMMENT '钱包余额',
  `is_verified` tinyint(1) DEFAULT 0 COMMENT '是否实名认证 (0否 1是)',
  `is_runner` tinyint(1) DEFAULT 0 COMMENT '是否认证骑手 (0否 1是)',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  UNIQUE KEY `uk_openid` (`openid`),
  KEY `idx_student_no` (`student_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生信息扩展表';

-- -------------------------------------------
-- 2. 贴吧帖子表 (迁移并优化自 jingwenWall topic)
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_forum_post`;
CREATE TABLE `bus_forum_post` (
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID (雪花算法)',
  `user_id` bigint(20) NOT NULL COMMENT '发布者user_id',
  `category_id` bigint(20) NOT NULL COMMENT '板块ID (关联campus_category)',
  `title` varchar(100) DEFAULT NULL COMMENT '标题 (可选)',
  `content` text COMMENT '文本内容',
  `images` json DEFAULT NULL COMMENT '图片列表(JSON数组)',
  `is_anonymous` tinyint(1) DEFAULT 0 COMMENT '是否匿名 (0否 1是)',
  `is_draft` tinyint(1) DEFAULT 0 COMMENT '是否草稿 (0否 1是)',
  `view_count` int(11) DEFAULT 0 COMMENT '浏览量',
  `like_count` int(11) DEFAULT 0 COMMENT '点赞数',
  `comment_count` int(11) DEFAULT 0 COMMENT '评论数',
  `collect_count` int(11) DEFAULT 0 COMMENT '收藏数',
  `status` tinyint(4) DEFAULT 0 COMMENT '状态: 0审核中 1正常 2下架 3拒绝',
  `ip` varchar(64) DEFAULT NULL COMMENT '发布IP',
  `address` varchar(100) DEFAULT NULL COMMENT '发布地址',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint(20) DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint(20) DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='贴吧帖子表';

-- -------------------------------------------
-- 3. 帖子点赞表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_forum_like`;
CREATE TABLE `bus_forum_like` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`user_id`, `post_id`),
  KEY `idx_post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子点赞表';

-- -------------------------------------------
-- 4. 帖子收藏表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_forum_collect`;
CREATE TABLE `bus_forum_collect` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`user_id`, `post_id`),
  KEY `idx_post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子收藏表';

-- -------------------------------------------
-- 5. 帖子评论表 (优化自 campus_comment)
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_forum_comment`;
CREATE TABLE `bus_forum_comment` (
  `comment_id` bigint(20) NOT NULL COMMENT '评论ID',
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID',
  `user_id` bigint(20) NOT NULL COMMENT '评论者ID',
  `parent_id` bigint(20) DEFAULT 0 COMMENT '父评论ID (0为一级评论)',
  `root_id` bigint(20) DEFAULT NULL COMMENT '根评论ID (方便查询整个评论树)',
  `to_user_id` bigint(20) DEFAULT NULL COMMENT '回复目标用户ID',
  `content` varchar(500) NOT NULL COMMENT '评论内容',
  `like_count` int(11) DEFAULT 0 COMMENT '点赞数',
  `ip` varchar(64) DEFAULT NULL COMMENT '评论IP',
  `address` varchar(100) DEFAULT NULL COMMENT '评论地址',
  `status` tinyint(4) DEFAULT 1 COMMENT '状态: 0审核中 1正常 2删除',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`comment_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子评论表';

-- -------------------------------------------
-- 6. 评论点赞表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_forum_comment_like`;
CREATE TABLE `bus_forum_comment_like` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `comment_id` bigint(20) NOT NULL COMMENT '评论ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`user_id`, `comment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论点赞表';

-- -------------------------------------------
-- 7. 跑腿订单表 (核心盈利模块)
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_errand_order`;
CREATE TABLE `bus_errand_order` (
  `order_id` bigint(20) NOT NULL COMMENT '订单ID (雪花算法)',
  `order_no` varchar(64) NOT NULL COMMENT '订单号 (业务号)',
  `publisher_id` bigint(20) NOT NULL COMMENT '发布者ID',
  `runner_id` bigint(20) DEFAULT NULL COMMENT '接单骑手ID',
  `type` tinyint(4) NOT NULL COMMENT '类型: 0取快递 1代买餐 2寄快递 3排队 4其他',
  `pickup_addr` varchar(255) DEFAULT NULL COMMENT '取件地址',
  `pickup_lat` decimal(10,6) DEFAULT NULL COMMENT '取件纬度',
  `pickup_lng` decimal(10,6) DEFAULT NULL COMMENT '取件经度',
  `delivery_addr` varchar(255) NOT NULL COMMENT '送达地址',
  `delivery_lat` decimal(10,6) DEFAULT NULL COMMENT '送达纬度',
  `delivery_lng` decimal(10,6) DEFAULT NULL COMMENT '送达经度',
  `goods_desc` varchar(255) DEFAULT NULL COMMENT '物品描述',
  `goods_weight` varchar(50) DEFAULT NULL COMMENT '物品重量',
  `expect_time` datetime DEFAULT NULL COMMENT '期望送达时间',
  `tip` decimal(10,2) DEFAULT 0.00 COMMENT '小费',
  `base_fee` decimal(10,2) NOT NULL COMMENT '基础配送费',
  `total_fee` decimal(10,2) NOT NULL COMMENT '总费用',
  `runner_fee` decimal(10,2) DEFAULT NULL COMMENT '骑手佣金',
  `platform_fee` decimal(10,2) DEFAULT NULL COMMENT '平台抽成',
  `pay_status` tinyint(4) DEFAULT 0 COMMENT '支付状态: 0未支付 1已支付 2已退款',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `pay_order_no` varchar(64) DEFAULT NULL COMMENT '支付订单号',
  `status` tinyint(4) DEFAULT 0 COMMENT '订单状态: 0待接单 1已接单 2取件中 3配送中 4待确认 5已完成 6已取消',
  `cancel_reason` varchar(255) DEFAULT NULL COMMENT '取消原因',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `version` int(11) DEFAULT 0 COMMENT '乐观锁版本号',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_publisher_id` (`publisher_id`),
  KEY `idx_runner_id` (`runner_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='跑腿订单表';

-- -------------------------------------------
-- 8. 骑手认证表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_errand_runner`;
CREATE TABLE `bus_errand_runner` (
  `runner_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '骑手ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `real_name` varchar(32) NOT NULL COMMENT '真实姓名',
  `id_card` varchar(18) NOT NULL COMMENT '身份证号',
  `id_card_front` varchar(255) DEFAULT NULL COMMENT '身份证正面照',
  `id_card_back` varchar(255) DEFAULT NULL COMMENT '身份证背面照',
  `student_card` varchar(255) DEFAULT NULL COMMENT '学生证照片',
  `total_orders` int(11) DEFAULT 0 COMMENT '完成订单数',
  `total_income` decimal(10,2) DEFAULT 0.00 COMMENT '累计收入',
  `rating` decimal(3,2) DEFAULT 5.00 COMMENT '评分',
  `status` tinyint(4) DEFAULT 0 COMMENT '状态: 0待审核 1通过 2拒绝 3禁用',
  `audit_remark` varchar(255) DEFAULT NULL COMMENT '审核备注',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`runner_id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='骑手认证表';

-- -------------------------------------------
-- 9. 二手商品表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_market_item`;
CREATE TABLE `bus_market_item` (
  `item_id` bigint(20) NOT NULL COMMENT '商品ID',
  `user_id` bigint(20) NOT NULL COMMENT '发布者ID',
  `category_id` bigint(20) DEFAULT NULL COMMENT '商品分类ID',
  `title` varchar(100) NOT NULL COMMENT '商品标题',
  `description` text COMMENT '商品描述',
  `images` json DEFAULT NULL COMMENT '图片列表(JSON)',
  `price` decimal(10,2) NOT NULL COMMENT '售价',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `condition_level` tinyint(4) DEFAULT 9 COMMENT '成色: 1-10',
  `trade_method` tinyint(4) DEFAULT 0 COMMENT '交易方式: 0自提 1邮寄 2都可',
  `trade_location` varchar(255) DEFAULT NULL COMMENT '交易地点',
  `view_count` int(11) DEFAULT 0 COMMENT '浏览量',
  `collect_count` int(11) DEFAULT 0 COMMENT '收藏数',
  `status` tinyint(4) DEFAULT 0 COMMENT '状态: 0待审核 1在售 2已售 3下架',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`item_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二手商品表';

-- -------------------------------------------
-- 10. 兼职信息表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_job_post`;
CREATE TABLE `bus_job_post` (
  `job_id` bigint(20) NOT NULL COMMENT '兼职ID',
  `publisher_id` bigint(20) NOT NULL COMMENT '发布者ID (商家或管理员)',
  `title` varchar(100) NOT NULL COMMENT '职位标题',
  `company_name` varchar(100) DEFAULT NULL COMMENT '公司/店铺名称',
  `description` text COMMENT '职位描述',
  `requirements` text COMMENT '任职要求',
  `salary_type` tinyint(4) DEFAULT 0 COMMENT '薪资类型: 0日结 1周结 2月结',
  `salary_min` decimal(10,2) DEFAULT NULL COMMENT '薪资下限',
  `salary_max` decimal(10,2) DEFAULT NULL COMMENT '薪资上限',
  `salary_unit` varchar(20) DEFAULT '元/小时' COMMENT '薪资单位',
  `work_time` varchar(255) DEFAULT NULL COMMENT '工作时间',
  `work_location` varchar(255) DEFAULT NULL COMMENT '工作地点',
  `contact_name` varchar(32) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `contact_wechat` varchar(50) DEFAULT NULL COMMENT '联系微信',
  `headcount` int(11) DEFAULT 1 COMMENT '招聘人数',
  `applied_count` int(11) DEFAULT 0 COMMENT '已申请人数',
  `view_count` int(11) DEFAULT 0 COMMENT '浏览量',
  `is_top` tinyint(1) DEFAULT 0 COMMENT '是否置顶',
  `top_expire_time` datetime DEFAULT NULL COMMENT '置顶过期时间',
  `status` tinyint(4) DEFAULT 0 COMMENT '状态: 0待审核 1招聘中 2已结束 3下架',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`job_id`),
  KEY `idx_publisher_id` (`publisher_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_top` (`is_top`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='兼职信息表';

-- -------------------------------------------
-- 11. 兼职申请表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_job_application`;
CREATE TABLE `bus_job_application` (
  `application_id` bigint(20) NOT NULL COMMENT '申请ID',
  `job_id` bigint(20) NOT NULL COMMENT '兼职ID',
  `user_id` bigint(20) NOT NULL COMMENT '申请者ID',
  `resume` text COMMENT '简历/自我介绍',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `status` tinyint(4) DEFAULT 0 COMMENT '状态: 0待处理 1通过 2拒绝',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`application_id`),
  KEY `idx_job_id` (`job_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='兼职申请表';

-- -------------------------------------------
-- 12. 举报表 (通用)
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_report`;
CREATE TABLE `bus_report` (
  `report_id` bigint(20) NOT NULL COMMENT '举报ID',
  `reporter_id` bigint(20) NOT NULL COMMENT '举报人ID',
  `target_type` tinyint(4) NOT NULL COMMENT '举报目标类型: 0帖子 1评论 2用户 3商品 4兼职',
  `target_id` bigint(20) NOT NULL COMMENT '举报目标ID',
  `reason_type` varchar(50) DEFAULT NULL COMMENT '举报原因类型',
  `reason_detail` text COMMENT '详细描述',
  `images` json DEFAULT NULL COMMENT '举报截图',
  `status` tinyint(4) DEFAULT 0 COMMENT '状态: 0待处理 1已处理 2已忽略',
  `handle_remark` varchar(255) DEFAULT NULL COMMENT '处理备注',
  `handle_user_id` bigint(20) DEFAULT NULL COMMENT '处理人ID',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `del_flag` bit(1) DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '举报时间',
  PRIMARY KEY (`report_id`),
  KEY `idx_target` (`target_type`, `target_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='举报表';

-- -------------------------------------------
-- 13. 钱包流水表
-- -------------------------------------------
DROP TABLE IF EXISTS `bus_wallet_record`;
CREATE TABLE `bus_wallet_record` (
  `record_id` bigint(20) NOT NULL COMMENT '记录ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `type` tinyint(4) NOT NULL COMMENT '类型: 0充值 1提现 2收入 3支出 4退款',
  `amount` decimal(10,2) NOT NULL COMMENT '金额',
  `balance_before` decimal(10,2) DEFAULT NULL COMMENT '变动前余额',
  `balance_after` decimal(10,2) DEFAULT NULL COMMENT '变动后余额',
  `related_order_no` varchar(64) DEFAULT NULL COMMENT '关联订单号',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='钱包流水表';

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- 执行完成提示
-- ============================================
-- 请确认以下13张表已成功创建:
-- 1. bus_student          - 学生信息扩展表
-- 2. bus_forum_post       - 贴吧帖子表
-- 3. bus_forum_like       - 帖子点赞表
-- 4. bus_forum_collect    - 帖子收藏表
-- 5. bus_forum_comment    - 帖子评论表
-- 6. bus_forum_comment_like - 评论点赞表
-- 7. bus_errand_order     - 跑腿订单表
-- 8. bus_errand_runner    - 骑手认证表
-- 9. bus_market_item      - 二手商品表
-- 10. bus_job_post        - 兼职信息表
-- 11. bus_job_application - 兼职申请表
-- 12. bus_report          - 举报表
-- 13. bus_wallet_record   - 钱包流水表
