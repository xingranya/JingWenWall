/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80043 (8.0.43)
 Source Host           : localhost:3306
 Source Schema         : jingwen_campus

 Target Server Type    : MySQL
 Target Server Version : 80043 (8.0.43)
 File Encoding         : 65001

 Date: 10/01/2026 00:19:34
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bus_category
-- ----------------------------
DROP TABLE IF EXISTS `bus_category`;
CREATE TABLE `bus_category`  (
  `category_id` bigint NOT NULL COMMENT '分类ID',
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类描述',
  `icon` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类图标',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态(0-正常, 1-禁用)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '删除标志(0-未删除, 1-已删除)',
  PRIMARY KEY (`category_id`) USING BTREE,
  INDEX `idx_sort`(`sort` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_category
-- ----------------------------
INSERT INTO `bus_category` VALUES (1001, '校园生活', '分享校园生活趣事', NULL, 1, 0, '2026-01-09 23:25:14', NULL, '2026-01-09 23:25:14', NULL, b'0');
INSERT INTO `bus_category` VALUES (1002, '学习交流', '学术讨论和学习经验分享', NULL, 2, 0, '2026-01-09 23:25:14', NULL, '2026-01-09 23:25:14', NULL, b'0');
INSERT INTO `bus_category` VALUES (1003, '失物招领', '失物报失和拾到物品认领', NULL, 3, 0, '2026-01-09 23:25:14', NULL, '2026-01-09 23:25:14', NULL, b'0');
INSERT INTO `bus_category` VALUES (1004, '二手交易', '闲置物品交易', NULL, 4, 0, '2026-01-09 23:25:14', NULL, '2026-01-09 23:25:14', NULL, b'0');
INSERT INTO `bus_category` VALUES (1005, '社团活动', '社团招新和活动宣传', NULL, 5, 0, '2026-01-09 23:25:14', NULL, '2026-01-09 23:25:14', NULL, b'0');
INSERT INTO `bus_category` VALUES (1006, '其他', '其他相关内容', NULL, 99, 0, '2026-01-09 23:25:14', NULL, '2026-01-09 23:25:14', NULL, b'0');

-- ----------------------------
-- Table structure for bus_errand_order
-- ----------------------------
DROP TABLE IF EXISTS `bus_errand_order`;
CREATE TABLE `bus_errand_order`  (
  `order_id` bigint NOT NULL COMMENT '订单ID (雪花算法)',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单号 (业务号)',
  `publisher_id` bigint NOT NULL COMMENT '发布者ID',
  `runner_id` bigint NULL DEFAULT NULL COMMENT '接单骑手ID',
  `type` tinyint NOT NULL COMMENT '类型: 0取快递 1代买餐 2寄快递 3排队 4其他',
  `pickup_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取件地址',
  `pickup_lat` decimal(10, 6) NULL DEFAULT NULL COMMENT '取件纬度',
  `pickup_lng` decimal(10, 6) NULL DEFAULT NULL COMMENT '取件经度',
  `delivery_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '送达地址',
  `delivery_lat` decimal(10, 6) NULL DEFAULT NULL COMMENT '送达纬度',
  `delivery_lng` decimal(10, 6) NULL DEFAULT NULL COMMENT '送达经度',
  `goods_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物品描述',
  `goods_weight` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物品重量',
  `expect_time` datetime NULL DEFAULT NULL COMMENT '期望送达时间',
  `tip` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '小费',
  `base_fee` decimal(10, 2) NOT NULL COMMENT '基础配送费',
  `total_fee` decimal(10, 2) NOT NULL COMMENT '总费用',
  `runner_fee` decimal(10, 2) NULL DEFAULT NULL COMMENT '骑手佣金',
  `platform_fee` decimal(10, 2) NULL DEFAULT NULL COMMENT '平台抽成',
  `pay_status` tinyint NULL DEFAULT 0 COMMENT '支付状态: 0未支付 1已支付 2已退款',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `pay_order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付订单号',
  `status` tinyint NULL DEFAULT 0 COMMENT '订单状态: 0待接单 1已接单 2取件中 3配送中 4待确认 5已完成 6已取消',
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消原因',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_publisher_id`(`publisher_id` ASC) USING BTREE,
  INDEX `idx_runner_id`(`runner_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '跑腿订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_errand_order
-- ----------------------------

-- ----------------------------
-- Table structure for bus_errand_runner
-- ----------------------------
DROP TABLE IF EXISTS `bus_errand_runner`;
CREATE TABLE `bus_errand_runner`  (
  `runner_id` bigint NOT NULL AUTO_INCREMENT COMMENT '骑手ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `real_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '真实姓名',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '身份证号',
  `id_card_front` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证正面照',
  `id_card_back` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证背面照',
  `student_card` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学生证照片',
  `total_orders` int NULL DEFAULT 0 COMMENT '完成订单数',
  `total_income` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '累计收入',
  `rating` decimal(3, 2) NULL DEFAULT 5.00 COMMENT '评分',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态: 0待审核 1通过 2拒绝 3禁用',
  `audit_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核备注',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`runner_id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '骑手认证表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_errand_runner
-- ----------------------------

-- ----------------------------
-- Table structure for bus_forum_collect
-- ----------------------------
DROP TABLE IF EXISTS `bus_forum_collect`;
CREATE TABLE `bus_forum_collect`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_forum_collect
-- ----------------------------

-- ----------------------------
-- Table structure for bus_forum_comment
-- ----------------------------
DROP TABLE IF EXISTS `bus_forum_comment`;
CREATE TABLE `bus_forum_comment`  (
  `comment_id` bigint NOT NULL COMMENT '评论ID',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `user_id` bigint NOT NULL COMMENT '评论者ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父评论ID (0为一级评论)',
  `root_id` bigint NULL DEFAULT NULL COMMENT '根评论ID (方便查询整个评论树)',
  `to_user_id` bigint NULL DEFAULT NULL COMMENT '回复目标用户ID',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `like_count` int NULL DEFAULT 0 COMMENT '点赞数',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论IP',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论地址',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态: 0审核中 1正常 2删除',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_forum_comment
-- ----------------------------

-- ----------------------------
-- Table structure for bus_forum_comment_like
-- ----------------------------
DROP TABLE IF EXISTS `bus_forum_comment_like`;
CREATE TABLE `bus_forum_comment_like`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `comment_id` bigint NOT NULL COMMENT '评论ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`user_id`, `comment_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评论点赞表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_forum_comment_like
-- ----------------------------

-- ----------------------------
-- Table structure for bus_forum_like
-- ----------------------------
DROP TABLE IF EXISTS `bus_forum_like`;
CREATE TABLE `bus_forum_like`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子点赞表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_forum_like
-- ----------------------------

-- ----------------------------
-- Table structure for bus_forum_post
-- ----------------------------
DROP TABLE IF EXISTS `bus_forum_post`;
CREATE TABLE `bus_forum_post`  (
  `post_id` bigint NOT NULL COMMENT '帖子ID (雪花算法)',
  `user_id` bigint NOT NULL COMMENT '发布者user_id',
  `category_id` bigint NOT NULL COMMENT '板块ID (关联campus_category)',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标题 (可选)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '文本内容',
  `images` json NULL COMMENT '图片列表(JSON数组)',
  `is_anonymous` tinyint(1) NULL DEFAULT 0 COMMENT '是否匿名 (0否 1是)',
  `is_draft` tinyint(1) NULL DEFAULT 0 COMMENT '是否草稿 (0否 1是)',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览量',
  `like_count` int NULL DEFAULT 0 COMMENT '点赞数',
  `comment_count` int NULL DEFAULT 0 COMMENT '评论数',
  `collect_count` int NULL DEFAULT 0 COMMENT '收藏数',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态: 0审核中 1正常 2下架 3拒绝',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发布IP',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发布地址',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`post_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '贴吧帖子表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_forum_post
-- ----------------------------
INSERT INTO `bus_forum_post` VALUES (3001, 2, 1001, '欢迎来到校园墙！', '这是第一条测试帖子，欢迎大家在这里分享校园生活。', '[\"https://picsum.photos/300/200\"]', 0, 0, 1, 1, 0, 0, 0, '192.168.1.100', '北京', b'0', '2026-01-09 23:54:16', NULL, '2026-01-09 23:54:16', 2009598766385987585);
INSERT INTO `bus_forum_post` VALUES (3002, 2, 1002, '求购二手教材', '求购《数据结构与算法》教材。', '[]', 0, 0, 3, 2, 1, 1, 0, '192.168.1.101', '清华', b'0', '2026-01-09 23:54:16', NULL, '2026-01-09 23:54:16', NULL);
INSERT INTO `bus_forum_post` VALUES (3003, 2, 1003, '寻找学习伙伴', '我在自学Java，希望能找到一起学习的小伙伴。', '[]', 0, 0, 5, 3, 2, 0, 0, '192.168.1.102', '北大', b'0', '2026-01-09 23:54:16', NULL, '2026-01-09 23:54:16', NULL);
INSERT INTO `bus_forum_post` VALUES (3004, 1, 1001, '管理员的测试帖子', '这是管理员发布的测试帖子。', '[]', 0, 0, 10, 5, 3, 2, 0, '192.168.1.1', '校园', b'0', '2026-01-09 23:53:28', NULL, '2026-01-09 23:53:28', NULL);

-- ----------------------------
-- Table structure for bus_forum_post_collect
-- ----------------------------
DROP TABLE IF EXISTS `bus_forum_post_collect`;
CREATE TABLE `bus_forum_post_collect`  (
  `collect_id` bigint NOT NULL COMMENT '收藏ID',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '删除标志(0-未删除, 1-已删除)',
  PRIMARY KEY (`collect_id`) USING BTREE,
  UNIQUE INDEX `uk_post_user`(`post_id` ASC, `user_id` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_forum_post_collect
-- ----------------------------

-- ----------------------------
-- Table structure for bus_forum_post_like
-- ----------------------------
DROP TABLE IF EXISTS `bus_forum_post_like`;
CREATE TABLE `bus_forum_post_like`  (
  `like_id` bigint NOT NULL COMMENT '点赞ID',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '删除标志(0-未删除, 1-已删除)',
  PRIMARY KEY (`like_id`) USING BTREE,
  UNIQUE INDEX `uk_post_user`(`post_id` ASC, `user_id` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子点赞表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_forum_post_like
-- ----------------------------
INSERT INTO `bus_forum_post_like` VALUES (2009660243956576257, 3001, 2009598766385987585, '2026-01-10 00:15:15', 2009598766385987585, '2026-01-10 00:15:16', NULL, b'1');
INSERT INTO `bus_forum_post_like` VALUES (2009660253792219137, 3001, 2009598766385987585, '2026-01-10 00:15:17', 2009598766385987585, '2026-01-10 00:15:16', NULL, b'0');

-- ----------------------------
-- Table structure for bus_job_application
-- ----------------------------
DROP TABLE IF EXISTS `bus_job_application`;
CREATE TABLE `bus_job_application`  (
  `application_id` bigint NOT NULL COMMENT '申请ID',
  `job_id` bigint NOT NULL COMMENT '兼职ID',
  `user_id` bigint NOT NULL COMMENT '申请者ID',
  `resume` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '简历/自我介绍',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态: 0待处理 1通过 2拒绝',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`application_id`) USING BTREE,
  INDEX `idx_job_id`(`job_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '兼职申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_job_application
-- ----------------------------

-- ----------------------------
-- Table structure for bus_job_post
-- ----------------------------
DROP TABLE IF EXISTS `bus_job_post`;
CREATE TABLE `bus_job_post`  (
  `job_id` bigint NOT NULL COMMENT '兼职ID',
  `publisher_id` bigint NOT NULL COMMENT '发布者ID (商家或管理员)',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '职位标题',
  `company_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公司/店铺名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '职位描述',
  `requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '任职要求',
  `salary_type` tinyint NULL DEFAULT 0 COMMENT '薪资类型: 0日结 1周结 2月结',
  `salary_min` decimal(10, 2) NULL DEFAULT NULL COMMENT '薪资下限',
  `salary_max` decimal(10, 2) NULL DEFAULT NULL COMMENT '薪资上限',
  `salary_unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '元/小时' COMMENT '薪资单位',
  `work_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作时间',
  `work_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作地点',
  `contact_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_wechat` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系微信',
  `headcount` int NULL DEFAULT 1 COMMENT '招聘人数',
  `applied_count` int NULL DEFAULT 0 COMMENT '已申请人数',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览量',
  `is_top` tinyint(1) NULL DEFAULT 0 COMMENT '是否置顶',
  `top_expire_time` datetime NULL DEFAULT NULL COMMENT '置顶过期时间',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态: 0待审核 1招聘中 2已结束 3下架',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`job_id`) USING BTREE,
  INDEX `idx_publisher_id`(`publisher_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_is_top`(`is_top` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '兼职信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_job_post
-- ----------------------------

-- ----------------------------
-- Table structure for bus_market_item
-- ----------------------------
DROP TABLE IF EXISTS `bus_market_item`;
CREATE TABLE `bus_market_item`  (
  `item_id` bigint NOT NULL COMMENT '商品ID',
  `user_id` bigint NOT NULL COMMENT '发布者ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '商品分类ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品描述',
  `images` json NULL COMMENT '图片列表(JSON)',
  `price` decimal(10, 2) NOT NULL COMMENT '售价',
  `original_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价',
  `condition_level` tinyint NULL DEFAULT 9 COMMENT '成色: 1-10',
  `trade_method` tinyint NULL DEFAULT 0 COMMENT '交易方式: 0自提 1邮寄 2都可',
  `trade_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '交易地点',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览量',
  `collect_count` int NULL DEFAULT 0 COMMENT '收藏数',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态: 0待审核 1在售 2已售 3下架',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '二手商品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_market_item
-- ----------------------------

-- ----------------------------
-- Table structure for bus_report
-- ----------------------------
DROP TABLE IF EXISTS `bus_report`;
CREATE TABLE `bus_report`  (
  `report_id` bigint NOT NULL COMMENT '举报ID',
  `reporter_id` bigint NOT NULL COMMENT '举报人ID',
  `target_type` tinyint NOT NULL COMMENT '举报目标类型: 0帖子 1评论 2用户 3商品 4兼职',
  `target_id` bigint NOT NULL COMMENT '举报目标ID',
  `reason_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '举报原因类型',
  `reason_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '详细描述',
  `images` json NULL COMMENT '举报截图',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态: 0待处理 1已处理 2已忽略',
  `handle_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理备注',
  `handle_user_id` bigint NULL DEFAULT NULL COMMENT '处理人ID',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '举报时间',
  PRIMARY KEY (`report_id`) USING BTREE,
  INDEX `idx_target`(`target_type` ASC, `target_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '举报表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_report
-- ----------------------------

-- ----------------------------
-- Table structure for bus_student
-- ----------------------------
DROP TABLE IF EXISTS `bus_student`;
CREATE TABLE `bus_student`  (
  `student_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '关联sys_user的user_id',
  `openid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信OpenID',
  `unionid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信UnionID',
  `student_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学号',
  `real_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `college` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学院',
  `major` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '专业',
  `grade` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '年级',
  `credit_score` int NULL DEFAULT 100 COMMENT '信用分 (初始100)',
  `balance` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '钱包余额',
  `is_verified` tinyint(1) NULL DEFAULT 0 COMMENT '是否实名认证 (0否 1是)',
  `is_runner` tinyint(1) NULL DEFAULT 0 COMMENT '是否认证骑手 (0否 1是)',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`student_id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_openid`(`openid` ASC) USING BTREE,
  INDEX `idx_student_no`(`student_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生信息扩展表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_student
-- ----------------------------
INSERT INTO `bus_student` VALUES (6, 2009598766385987585, 'o0jpQ3RbbAwk86WaYUlnTJu2foN4', NULL, NULL, NULL, NULL, NULL, NULL, 100, 0.00, 0, 0, b'0', '2026-01-09 20:10:57', '2026-01-09 20:10:57');
INSERT INTO `bus_student` VALUES (7, 2000000000000000000, 'o_test_openid_123456', NULL, '测试学号001', '张三', '计算机学院', '软件工程', '2022级', 100, 0.00, 1, 0, b'0', '2026-01-09 23:45:17', '2026-01-09 23:45:17');

-- ----------------------------
-- Table structure for bus_wallet_record
-- ----------------------------
DROP TABLE IF EXISTS `bus_wallet_record`;
CREATE TABLE `bus_wallet_record`  (
  `record_id` bigint NOT NULL COMMENT '记录ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `type` tinyint NOT NULL COMMENT '类型: 0充值 1提现 2收入 3支出 4退款',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `balance_before` decimal(10, 2) NULL DEFAULT NULL COMMENT '变动前余额',
  `balance_after` decimal(10, 2) NULL DEFAULT NULL COMMENT '变动后余额',
  `related_order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联订单号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '钱包流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bus_wallet_record
-- ----------------------------

-- ----------------------------
-- Table structure for campus_category
-- ----------------------------
DROP TABLE IF EXISTS `campus_category`;
CREATE TABLE `campus_category`  (
  `category_id` bigint NOT NULL COMMENT '分类主键',
  `category_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '分类名',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父分类id',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `slug` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '缩略名',
  `description` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '描述',
  `type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `icon` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '分类图标\n',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除(1:已删除，0:未删除)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`category_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of campus_category
-- ----------------------------
INSERT INTO `campus_category` VALUES (1, '最新墙', 0, 0, 'newest', '最近的墙内容(菜单默认选择这个)', 'Y', 'system', '0', b'0', '2022-12-30 20:11:41', 1, '2023-01-01 22:23:49', 1);
INSERT INTO `campus_category` VALUES (123, '表白墙', 0, 2, 'friends', '', 'N', 'system', '0', b'0', '2021-10-15 10:32:00', NULL, '2023-04-07 19:30:12', 1);
INSERT INTO `campus_category` VALUES (1449212758636646402, '表白', 123, 1, 'debunk', '吐槽描述', 'N', 'system', '0', b'0', '2021-10-16 11:17:01', NULL, '2023-01-01 22:26:29', 1);
INSERT INTO `campus_category` VALUES (1465662542308495361, '分享墙', 0, 3, 'share', '', 'N', 'system', '0', b'0', '2021-11-30 20:42:35', NULL, '2022-12-26 17:57:48', 1);
INSERT INTO `campus_category` VALUES (1602336520042287105, '日常分享', 1465662542308495361, 2, 'daily_sharing', NULL, 'N', 'system', '0', b'0', '2022-12-13 00:16:11', 1, '2022-12-26 17:57:51', 1);
INSERT INTO `campus_category` VALUES (1644302032332709889, '交友', 123, 2, 'make_friends', NULL, 'N', 'system', '0', b'0', '2023-04-07 19:32:09', 1, '2023-04-07 19:32:08', 1);
INSERT INTO `campus_category` VALUES (1644302999660847105, '买卖墙', 0, 4, 'buy_and_sell', NULL, 'N', 'system', '0', b'0', '2023-04-07 19:35:59', 1, '2023-04-07 19:35:59', 1);
INSERT INTO `campus_category` VALUES (1644303286433800193, '求购', 1644302999660847105, 1, 'want_to_buy', NULL, 'N', 'system', '0', b'0', '2023-04-07 19:37:08', 1, '2023-04-07 19:37:07', 1);
INSERT INTO `campus_category` VALUES (1644303516352962562, '出售', 1644302999660847105, 2, 'sell', NULL, 'N', 'system', '0', b'0', '2023-04-07 19:38:03', 1, '2023-04-07 19:38:02', 1);
INSERT INTO `campus_category` VALUES (1644309509791080449, '综合墙', 0, 6, 'synthesize', NULL, 'N', 'system', '0', b'0', '2023-04-07 20:01:52', 1, '2023-04-07 20:01:51', NULL);
INSERT INTO `campus_category` VALUES (1644309673171804161, '实习兼职', 1644309509791080449, 1, 'Internship_part-time_job', NULL, 'N', 'system', '0', b'0', '2023-04-07 20:02:31', 1, '2023-04-07 20:02:30', 1);
INSERT INTO `campus_category` VALUES (1644309825320181762, '吐槽', 1644309509791080449, 2, 'roast', NULL, 'N', NULL, '0', b'0', '2023-04-07 20:03:07', 1, '2023-04-07 20:03:06', 1);

-- ----------------------------
-- Table structure for campus_comment
-- ----------------------------
DROP TABLE IF EXISTS `campus_comment`;
CREATE TABLE `campus_comment`  (
  `comment_id` bigint NOT NULL COMMENT '评论主键',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '上级id',
  `one_level_id` bigint NULL DEFAULT NULL COMMENT '所属的一级评论id',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户id',
  `to_user_id` bigint NULL DEFAULT NULL COMMENT '所回复目标评论的用户id',
  `content_id` bigint NULL DEFAULT NULL COMMENT '内容id',
  `co_content` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '评论内容',
  `ip` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '评论时的ip',
  `address` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '评论时的地址',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除(1:已删除，0:未删除)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`comment_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of campus_comment
-- ----------------------------

-- ----------------------------
-- Table structure for campus_content
-- ----------------------------
DROP TABLE IF EXISTS `campus_content`;
CREATE TABLE `campus_content`  (
  `content_id` bigint NOT NULL COMMENT '内容主键',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户id',
  `category_id` bigint NULL DEFAULT NULL COMMENT '类别id',
  `content` varchar(700) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发表的内容',
  `status` tinyint(1) NULL DEFAULT NULL COMMENT '状态：0审核,1正常,2下架,3拒绝（审核不通过）',
  `type` tinyint(1) NULL DEFAULT NULL COMMENT '类型：0文字,1图片,2视频',
  `file_count` int NULL DEFAULT NULL COMMENT '文件数量',
  `love_count` int NULL DEFAULT 0 COMMENT '点赞数量',
  `is_anonymous` tinyint(1) NULL DEFAULT 0 COMMENT '0不匿名，1匿名',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除(1:已删除，0:未删除)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`content_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of campus_content
-- ----------------------------
INSERT INTO `campus_content` VALUES (1, 1, 1449212758636646402, '欢迎使用校园信息墙项目\n开源地址：https://github.com/oddfar/campus\n欢迎大家 Star 和 Fork 支持~', 1, 0, 0, 0, 1, NULL, b'0', '2022-03-05 10:55:04', NULL, '2023-02-26 14:26:33', 1);
INSERT INTO `campus_content` VALUES (2, 1, 1602336520042287105, 'hello world\nhello world\nhello world\nhello world', 1, 0, 1, 1, 0, NULL, b'0', '2022-12-13 00:01:47', NULL, '2023-12-24 23:53:38', 1);
INSERT INTO `campus_content` VALUES (3, 1, 1602336520042287105, '你好，welcome\n开源地址：https://github.com/oddfar/campus\n欢迎大家 Star 和 Fork 支持~', 1, 0, 1, 0, 0, NULL, b'0', '2022-12-13 00:01:47', NULL, '2023-12-24 23:53:41', 1);
INSERT INTO `campus_content` VALUES (1629730419490693121, 1594285543804383234, 1449212758636646402, '你好\n你好\n你好\n你好\n你好\n你好\n你好', 2, 0, 0, 1, 0, NULL, b'1', '2023-02-26 14:29:46', 1594285543804383234, '2023-09-11 11:35:40', 1);
INSERT INTO `campus_content` VALUES (1635923493036249089, 1594285543804383234, 1449212758636646402, '1232131', 2, 0, 0, 0, 0, NULL, b'1', '2023-03-15 16:38:49', 1594285543804383234, '2023-09-11 11:35:42', 1);
INSERT INTO `campus_content` VALUES (1635923549986508801, 1594285543804383234, 1602336520042287105, '1111111', 2, 0, 0, 1, 0, NULL, b'1', '2023-03-15 16:39:03', 1594285543804383234, '2023-09-11 11:35:44', 1);
INSERT INTO `campus_content` VALUES (1644584732895301634, 1594285543804383234, 1449212758636646402, '123', 1, 0, 0, 0, 0, NULL, b'1', '2023-04-08 14:15:30', 1594285543804383234, '2023-04-08 22:26:13', NULL);
INSERT INTO `campus_content` VALUES (1644638851867873282, 1594285543804383234, 1449212758636646402, '1', 2, 1, 1, 0, 0, NULL, b'1', '2023-04-08 17:50:33', 1594285543804383234, '2023-09-11 11:35:01', 1);
INSERT INTO `campus_content` VALUES (1644645933589467137, 1594285543804383234, 1449212758636646402, '2', 2, 1, 2, 0, 0, NULL, b'1', '2023-04-08 18:18:41', 1594285543804383234, '2023-09-11 11:35:03', 1);
INSERT INTO `campus_content` VALUES (1644708092667236354, 1594285543804383234, 1449212758636646402, '3', 2, 1, 3, 0, 0, NULL, b'1', '2023-04-08 22:25:41', 1594285543804383234, '2023-09-11 11:35:04', 1);
INSERT INTO `campus_content` VALUES (1645955280757866497, 1, 1602336520042287105, '把回忆拼好给你', 1, 2, 1, 2, 0, NULL, b'1', '2023-04-12 09:01:34', 1, '2024-01-07 12:05:07', 1);
INSERT INTO `campus_content` VALUES (1645961851969748993, 1, 1602336520042287105, '柯基', 1, 2, 1, 1, 0, NULL, b'1', '2023-04-12 09:27:41', 1, '2024-01-07 12:05:09', 1594285543804383234);
INSERT INTO `campus_content` VALUES (1656224490817863682, 1, 1449212758636646402, '1', 1, 2, 1, 0, 0, NULL, b'1', '2023-05-10 17:07:44', 1, '2024-01-07 12:05:12', 1);
INSERT INTO `campus_content` VALUES (1674977777075437569, 2, 1602336520042287105, '欢迎大家报考山河大学，我在山河大等你！', 1, 1, 3, 888, 0, NULL, b'1', '2023-07-01 11:26:36', 2, '2024-01-07 12:05:14', 1);
INSERT INTO `campus_content` VALUES (1674980529281253378, 2, 1602336520042287105, '山河大学@柴柴写字', 2, 1, 1, 666, 0, NULL, b'1', '2023-07-01 11:17:32', 2, '2024-01-07 12:04:59', 1);
INSERT INTO `campus_content` VALUES (1674988784673964034, 2, 1602336520042287105, '山河大学记录片传奇@不张常', 2, 2, 1, 999, 0, NULL, b'1', '2023-07-01 11:50:21', 2, '2024-01-07 12:04:57', 1);

-- ----------------------------
-- Table structure for campus_content_love
-- ----------------------------
DROP TABLE IF EXISTS `campus_content_love`;
CREATE TABLE `campus_content_love`  (
  `user_id` bigint NOT NULL COMMENT '用户id',
  `content_id` bigint NOT NULL COMMENT '文章id',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`user_id`, `content_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of campus_content_love
-- ----------------------------
INSERT INTO `campus_content_love` VALUES (2, 1645955280757866497, '2023-12-25 00:20:26');
INSERT INTO `campus_content_love` VALUES (2, 1674977777075437569, '2023-12-24 23:58:59');
INSERT INTO `campus_content_love` VALUES (1594285543804383234, 2, '2023-02-26 14:33:17');
INSERT INTO `campus_content_love` VALUES (1594285543804383234, 1629730419490693121, '2023-03-29 16:29:37');
INSERT INTO `campus_content_love` VALUES (1594285543804383234, 1635923549986508801, '2023-03-29 16:28:22');
INSERT INTO `campus_content_love` VALUES (1594285543804383234, 1645955280757866497, '2023-05-09 09:09:29');
INSERT INTO `campus_content_love` VALUES (1594285543804383234, 1645961851969748993, '2023-05-09 09:09:28');

-- ----------------------------
-- Table structure for campus_content_tag
-- ----------------------------
DROP TABLE IF EXISTS `campus_content_tag`;
CREATE TABLE `campus_content_tag`  (
  `content_id` bigint NOT NULL COMMENT '内容id',
  `tag_id` bigint NOT NULL COMMENT '标签id',
  PRIMARY KEY (`content_id`, `tag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of campus_content_tag
-- ----------------------------
INSERT INTO `campus_content_tag` VALUES (1, 1);
INSERT INTO `campus_content_tag` VALUES (1, 2);
INSERT INTO `campus_content_tag` VALUES (1, 3);
INSERT INTO `campus_content_tag` VALUES (2, 1);
INSERT INTO `campus_content_tag` VALUES (2, 2);

-- ----------------------------
-- Table structure for campus_file
-- ----------------------------
DROP TABLE IF EXISTS `campus_file`;
CREATE TABLE `campus_file`  (
  `file_id` bigint NOT NULL,
  `content_id` bigint NULL DEFAULT NULL COMMENT '文章id',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `url` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '储存url',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`file_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of campus_file
-- ----------------------------

-- ----------------------------
-- Table structure for campus_tag
-- ----------------------------
DROP TABLE IF EXISTS `campus_tag`;
CREATE TABLE `campus_tag`  (
  `tag_id` bigint NOT NULL COMMENT '标签主键',
  `tag_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '标签名',
  `description` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '描述',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除(1:已删除，0:未删除)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`tag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of campus_tag
-- ----------------------------
INSERT INTO `campus_tag` VALUES (1, '测试标签', '测试', '0', b'0', '2022-11-29 20:03:08', 1, '2022-12-01 18:16:16', NULL);
INSERT INTO `campus_tag` VALUES (2, '梅西', '利昂内尔·梅西（Lionel Messi）\n全名利昂内尔·安德烈斯·梅西·库西蒂尼（Lionel Andrés Messi Cuccitini）\n昵称莱奥·梅西（Leo Messi）', '0', b'0', '2022-11-29 20:03:28', 1, '2023-01-16 20:38:34', 1);
INSERT INTO `campus_tag` VALUES (3, '蔡徐坤', '中国内地男歌手、演员、原创音乐制作人、MV导演', '0', b'0', '2023-01-16 20:12:20', 1, '2023-01-16 20:13:54', 1);

-- ----------------------------
-- Table structure for social_user
-- ----------------------------
DROP TABLE IF EXISTS `social_user`;
CREATE TABLE `social_user`  (
  `social_user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '社会化用户表id\n',
  `uuid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '第三方系统的唯一ID',
  `source` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '第三方用户来源',
  PRIMARY KEY (`social_user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1738958687858704386 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '社会化用户表\n' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of social_user
-- ----------------------------

-- ----------------------------
-- Table structure for social_user_auth
-- ----------------------------
DROP TABLE IF EXISTS `social_user_auth`;
CREATE TABLE `social_user_auth`  (
  `user_id` bigint NULL DEFAULT NULL,
  `social_user_id` bigint NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of social_user_auth
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `group_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '所属分类的编码',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除(1:已删除，0:未删除)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1637978359153885187 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, 'Mac本地文件路径', 'sys.local.profile.mac', '~/uploadPath', 'Y', 'file_config', NULL, b'0', '2022-11-10 14:06:44', 1, '2022-11-10 14:07:49', NULL);
INSERT INTO `sys_config` VALUES (2, 'Linux本地文件路径', 'sys.local.profile.linux', '/data/uploadPath', 'Y', 'file_config', NULL, b'0', '2022-01-14 10:59:39', NULL, '2022-01-16 14:11:53', 1);
INSERT INTO `sys_config` VALUES (3, 'Windows本地文件路径', 'sys.local.profile.win', 'D:\\uploadPath', 'Y', 'file_config', NULL, b'0', '2022-01-14 11:00:39', NULL, '2022-01-16 14:11:53', 1);
INSERT INTO `sys_config` VALUES (4, '默认存储文件的bucket名称', 'sys.file.default.bucket', 'defaultBucket', 'Y', 'file_config', NULL, b'0', '2022-01-14 11:03:10', NULL, '2022-01-16 14:11:54', NULL);
INSERT INTO `sys_config` VALUES (5, '文件默认部署的环境地址', 'sys.server.deploy.host', 'http://localhost:8160', 'Y', 'file_config', NULL, b'0', '2022-01-16 14:11:45', NULL, '2022-01-16 14:18:55', NULL);
INSERT INTO `sys_config` VALUES (6, '文件访问是否用nginx映射', 'sys.file.visit.nginx', 'false', 'Y', 'file_config', 'true真，false假', b'0', '2022-01-16 14:40:00', NULL, '2022-01-16 14:40:20', NULL);
INSERT INTO `sys_config` VALUES (7, '信息墙删除且对应文件也删除', 'sys.file.is.delete', 'false', 'Y', 'file_config', 'true墙和文件都删除，false文件转移到别的目录', b'0', '2022-01-17 14:29:11', NULL, '2022-01-18 15:02:14', NULL);
INSERT INTO `sys_config` VALUES (8, '文件默认转移的bucket名称', 'sys.file.move.default.bucket', 'moveBucket', 'Y', 'file_config', NULL, b'0', '2022-01-17 14:31:05', NULL, '2022-01-18 15:09:48', NULL);
INSERT INTO `sys_config` VALUES (101, '阿里云邮件服务accessKeyId', 'sys.aliyun.mail.accessKeyId', '', 'Y', 'mail_config', NULL, b'0', '2022-01-19 10:04:08', NULL, '2022-01-19 10:49:30', NULL);
INSERT INTO `sys_config` VALUES (102, '阿里云邮件服务accessKeySecret', 'sys.aliyun.mail.accessKeySecret', '', 'Y', 'mail_config', NULL, b'0', '2022-01-19 10:07:28', NULL, '2022-01-19 10:49:31', NULL);
INSERT INTO `sys_config` VALUES (113, 'smtp服务器地址', 'sys.email.smtp.host', 'smtp.qq.com', 'Y', 'mail_config', NULL, b'0', '2022-01-19 10:33:50', NULL, '2022-01-24 11:28:13', NULL);
INSERT INTO `sys_config` VALUES (114, 'smtp服务端口', 'sys.email.smtp.port', '465', 'Y', 'mail_config', NULL, b'0', '2022-01-19 10:35:29', NULL, '2022-01-24 11:28:14', NULL);
INSERT INTO `sys_config` VALUES (115, '邮箱的发送方邮箱', 'sys.email.send.account', '3066693006@qq.com', 'Y', 'mail_config', NULL, b'0', '2022-01-19 10:38:17', NULL, '2022-01-24 11:28:15', NULL);
INSERT INTO `sys_config` VALUES (116, '邮箱的密码或者授权码', 'sys.email.password', 'xxxxx', 'Y', 'mail_config', NULL, b'0', '2022-01-19 10:07:31', NULL, '2022-01-19 12:02:57', 1);
INSERT INTO `sys_config` VALUES (117, '邮箱发送时的用户名', 'sys.email.name', '致远', 'Y', 'mail_config', NULL, b'0', '2022-01-19 11:10:47', NULL, '2022-01-24 11:28:19', NULL);
INSERT INTO `sys_config` VALUES (202, '用户默认头像', 'sys.user.default.avatar', 'https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG', 'Y', 'sys_config', NULL, b'0', '2022-02-08 11:35:31', NULL, '2022-02-08 11:40:15', 1);
INSERT INTO `sys_config` VALUES (206, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'sys_config', '初始化密码 123456', b'0', '2022-11-09 01:41:52', 1, '2022-11-09 15:42:09', NULL);
INSERT INTO `sys_config` VALUES (220, '全局日志记录', 'sys.log.global.flag', 'true', 'Y', 'sys_config', '全局日志记录，true则所有请求都将记录日志', b'0', '2023-06-07 21:36:00', 1, '2023-06-08 14:44:00', 1);
INSERT INTO `sys_config` VALUES (300, '验证码类型', 'sys.login.captchaType', 'math', 'Y', 'sys_config', 'math 数组计算 char 字符验证', b'0', '2022-11-10 09:32:40', 1, '2022-11-30 12:14:30', NULL);
INSERT INTO `sys_config` VALUES (301, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'sys_config', '是否开启验证码功能（true开启，false关闭）', b'0', '2023-02-01 21:48:05', 1, '2023-02-01 21:48:34', NULL);
INSERT INTO `sys_config` VALUES (302, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'true', 'Y', 'sys_config', '是否开启注册用户功能（true开启，false关闭）', b'0', '2023-02-01 21:47:39', 1, '2023-02-01 21:48:31', NULL);
INSERT INTO `sys_config` VALUES (1621419076555640833, '绑定邮箱模板', 'campus.mail.bindTemplate', '<h3>您好，#{[userName]}</h3><br />请在#{[expiration]}分内点击以下链接完成邮箱验证<br /><a href=\"#{[url]}\">#{[url]}</a>', 'Y', 'campus_config', '#{[userName]}用户，#{[url]}邮箱验证的链接，#{[expiration]}，有效期', b'0', '2023-02-03 16:03:27', 1, '2023-02-03 16:03:27', 1);
INSERT INTO `sys_config` VALUES (1621419076555640834, '用户匿名头像', 'campus.user.anonymous.image', 'https://gcore.jsdelivr.net/gh/oddfar/static/campus/image/anonymous.jpeg', 'Y', 'campus_config', NULL, b'0', '2022-02-08 11:36:36', NULL, '2023-02-21 08:33:07', 1);
INSERT INTO `sys_config` VALUES (1637978152848654338, '微信小程序APPID', 'campus.wxmp.appid', 'wxc56334f1f425a05f', 'Y', 'campus_config', NULL, b'0', '2023-03-21 08:43:18', 1, '2026-01-09 23:43:09', 1);
INSERT INTO `sys_config` VALUES (1637978359153885186, '微信小程序SECRET', 'campus.wxmp.secret', 'c5e4a048b701be66b35ac4e1e8d4b075', 'Y', 'campus_config', NULL, b'0', '2023-03-21 08:44:08', 1, '2026-01-09 23:43:02', 1);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新者',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除(1:已删除，0:未删除)',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1621418087714918402 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', NULL, 'default', 'Y', '0', '性别男', NULL, NULL, NULL, NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', NULL, 'default', 'N', '0', '性别女', NULL, NULL, NULL, NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (3, 1, '是', 'Y', 'sys_yes_no', NULL, 'success', 'N', '0', NULL, '2022-11-06 06:37:31', 1, '2022-11-06 06:39:34', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (4, 2, '否', 'N', 'sys_yes_no', NULL, 'danger', 'N', '0', NULL, '2022-11-06 06:37:42', 1, '2022-11-06 06:39:34', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', NULL, 'primary', 'Y', '0', '正常状态', NULL, NULL, NULL, NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', NULL, 'danger', 'N', '0', '停用状态', NULL, NULL, NULL, NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (41, 1, '显示', '0', 'sys_show_hide', NULL, 'primary', 'N', '0', '显示菜单', '2022-12-26 21:49:47', 1, '2022-12-26 21:49:47', NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (42, 2, '隐藏', '1', 'sys_show_hide', NULL, 'danger', 'N', '0', '隐藏菜单', '2022-12-26 21:50:10', 1, '2022-12-26 21:50:10', NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (101, 1, '系统配置', 'sys_config', 'sys_config_group', NULL, 'primary', 'N', '0', '配置群组的系统配置', '2022-11-06 19:27:23', NULL, '2022-11-06 06:07:20', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (102, 2, '邮件配置', 'mail_config', 'sys_config_group', NULL, 'primary', 'N', '0', NULL, '2022-11-06 05:38:04', 1, '2022-11-06 06:07:20', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (103, 3, '文件配置', 'file_config', 'sys_config_group', NULL, 'primary', 'N', '0', NULL, '2022-11-06 06:32:45', 1, '2022-11-06 20:32:44', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1597931830248570882, 1, '审核', '0', 'campus_content_status', NULL, 'warning', 'N', '0', NULL, '2022-11-30 20:33:31', 1, '2022-11-30 20:33:31', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1597931939476635650, 2, '正常', '1', 'campus_content_status', NULL, 'success', 'N', '0', NULL, '2022-11-30 20:33:57', 1, '2022-11-30 20:33:57', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1597932004085694466, 3, '下架', '2', 'campus_content_status', NULL, 'danger', 'N', '0', NULL, '2022-11-30 20:34:13', 1, '2022-11-30 20:34:12', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1597932393732341761, 1, '不匿', '0', 'campus_anonymous', NULL, 'primary', 'N', '0', NULL, '2022-11-30 20:35:45', 1, '2022-11-30 20:35:45', NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (1597932469577940994, 2, '匿名', '1', 'campus_anonymous', NULL, 'primary', 'N', '0', NULL, '2022-11-30 20:36:04', 1, '2022-11-30 20:36:03', NULL, b'0');
INSERT INTO `sys_dict_data` VALUES (1599392185411743745, 0, '文字', '0', 'campus_content_type', NULL, 'primary', 'N', '0', '', '2022-12-04 21:16:27', 1, '2022-12-04 21:16:26', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1599392255200768001, 2, '图片', '1', 'campus_content_type', NULL, 'success', 'N', '0', NULL, '2022-12-04 21:16:44', 1, '2022-12-04 21:16:43', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1599392552258154497, 3, '视频', '2', 'campus_content_type', NULL, 'info', 'N', '0', NULL, '2022-12-04 21:17:54', 1, '2022-12-04 21:17:54', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1609558539133521922, 4, '拒绝', '3', 'campus_content_status', NULL, 'danger', 'N', '0', '审核不通过', '2023-01-01 22:33:55', 1, '2023-01-01 22:33:54', 1, b'0');
INSERT INTO `sys_dict_data` VALUES (1621418087714918401, 10, 'campus配置', 'campus_config', 'sys_config_group', NULL, 'primary', 'N', '0', NULL, '2023-02-03 15:59:31', 1, '2023-02-03 15:59:31', NULL, b'0');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新者',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '逻辑删除(1:已删除，0:未删除)',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1607372974271246338 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', '用户性别列表', '2023-03-09 17:31:52', NULL, '2022-11-06 01:10:21', 1, b'0');
INSERT INTO `sys_dict_type` VALUES (2, '系统是否', 'sys_yes_no', '0', '系统是否列表', '2022-11-06 06:37:05', 1, '2022-11-06 20:37:04', 1, b'0');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', '系统开关列表', '2023-03-09 17:31:55', NULL, NULL, NULL, b'0');
INSERT INTO `sys_dict_type` VALUES (4, '菜单状态', 'sys_show_hide', '0', '菜单状态列表', '2022-12-26 21:49:15', 1, '2022-12-26 21:49:15', NULL, b'0');
INSERT INTO `sys_dict_type` VALUES (101, '配置群组', 'sys_config_group', '0', '配置群组', '2022-11-06 05:32:37', 1, '2022-11-06 19:32:37', 1, b'0');
INSERT INTO `sys_dict_type` VALUES (1597931685624774657, '校园墙内容状态', 'campus_content_status', '0', '校园墙内容状态', '2022-11-30 20:32:57', 1, '2022-11-30 20:32:56', NULL, b'0');
INSERT INTO `sys_dict_type` VALUES (1597932303005351938, '是否匿名', 'campus_anonymous', '0', '校园信息墙是否匿名', '2022-11-30 20:35:24', 1, '2022-11-30 20:35:23', NULL, b'0');
INSERT INTO `sys_dict_type` VALUES (1599392072043900930, '校园内类型', 'campus_content_type', '0', '0文字,1图片,2视频', '2022-12-04 21:16:00', 1, '2022-12-04 21:15:59', NULL, b'0');

-- ----------------------------
-- Table structure for sys_log_login
-- ----------------------------
DROP TABLE IF EXISTS `sys_log_login`;
CREATE TABLE `sys_log_login`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '登录成功的用户id\n',
  `user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2009651218120450051 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_log_login
-- ----------------------------
INSERT INTO `sys_log_login` VALUES (2009637090215608322, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '用户不存在/密码错误', '2026-01-09 22:43:14');
INSERT INTO `sys_log_login` VALUES (2009637090215608323, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '密码输入错误1次', '2026-01-09 22:43:14');
INSERT INTO `sys_log_login` VALUES (2009637141138653186, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '密码输入错误2次', '2026-01-09 22:43:26');
INSERT INTO `sys_log_login` VALUES (2009637141138653187, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '用户不存在/密码错误', '2026-01-09 22:43:26');
INSERT INTO `sys_log_login` VALUES (2009637405644046338, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '密码输入错误3次', '2026-01-09 22:44:29');
INSERT INTO `sys_log_login` VALUES (2009637405644046339, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '用户不存在/密码错误', '2026-01-09 22:44:29');
INSERT INTO `sys_log_login` VALUES (2009637656031412227, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '密码输入错误4次', '2026-01-09 22:45:29');
INSERT INTO `sys_log_login` VALUES (2009637656031412228, NULL, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '用户不存在/密码错误', '2026-01-09 22:45:29');
INSERT INTO `sys_log_login` VALUES (2009638081027653634, 1, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-01-09 22:47:10');
INSERT INTO `sys_log_login` VALUES (2009638731597758467, 1, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-01-09 22:49:46');
INSERT INTO `sys_log_login` VALUES (2009651218120450050, 1, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-01-09 23:39:23');

-- ----------------------------
-- Table structure for sys_log_oper
-- ----------------------------
DROP TABLE IF EXISTS `sys_log_oper`;
CREATE TABLE `sys_log_oper`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `app_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '服务名称，一般为spring.application.name',
  `log_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '日志名称',
  `log_content` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '日志记录内容',
  `method` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '请求方式',
  `oper_user_id` bigint NULL DEFAULT NULL COMMENT '操作人员user_id',
  `oper_url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_param` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  PRIMARY KEY (`oper_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2009660276508569602 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_log_oper
-- ----------------------------
INSERT INTO `sys_log_oper` VALUES (2009588454245019650, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0b27fWZv36Mtj63tii3w30RILB37fWZ4\"}', '', 1, '微信登录失败: appsecret missing, rid: 6960e6bc-4d6be936-77f860d2', '2026-01-09 19:29:58');
INSERT INTO `sys_log_oper` VALUES (2009588461341782018, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0d2JWCkl2D6NYg4GKNkl2W2YSb1JWCkz\"}', '', 1, '微信登录失败: appsecret missing, rid: 6960e6be-182e7343-1134149a', '2026-01-09 19:30:00');
INSERT INTO `sys_log_oper` VALUES (2009588470305009665, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0d2SWCkl2K4NYg4Xoill2p4D2z2SWCkn\"}', '', 1, '微信登录失败: appsecret missing, rid: 6960e6c0-0ec7b208-015c622c', '2026-01-09 19:30:02');
INSERT INTO `sys_log_oper` VALUES (2009588669203099650, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0c2miWZv3rBtj63gtE1w3nbZOI1miWZT\"}', '', 1, '微信登录失败: appsecret missing, rid: 6960e6ef-57ad9699-6c5e3e3b', '2026-01-09 19:30:50');
INSERT INTO `sys_log_oper` VALUES (2009591464069181441, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0e2n1e0w3wiMj63N8N2w3y2F1d1n1e0E\"}', '', 1, '微信登录失败: appsecret missing, rid: 6960e98a-5fe3b7a3-7e9736b7', '2026-01-09 19:41:56');
INSERT INTO `sys_log_oper` VALUES (2009598273496547330, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0d25kFkl2bbLYg42bvnl2qsjVx25kFkB\"}', '', 1, 'The signing key\'s size is 152 bits which is not secure enough for the HS512 algorithm.  The JWT JWA Specification (RFC 7518, Section 3.2) states that keys used with HS512 MUST have a size >= 512 bits (the key size must be greater than or equal to the hash output size).  Consider using the io.jsonwebtoken.security.Keys class\'s \'secretKeyFor(SignatureAlgorithm.HS512)\' method to create a key guaranteed to be secure enough for HS512.  See https://tools.ietf.org/html/rfc7518#section-3.2 for more information.', '2026-01-09 20:09:00');
INSERT INTO `sys_log_oper` VALUES (2009598766838972417, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0a20KYZv3Cctj63Mef1w3PgMpF10KYZM\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"creditScore\":100,\"isNewUser\":true,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjAwYzU3MjkxLTcxYzktNGY2Mi1iYzY2LTYzZTJlYjAyMTAyNCJ9.jjUZJuNOmpPzP2HTVYl4veADVRxrtj-0hXQnjxFSbUrpEbLuqrnjYZjWVp2Ur_CK_JiPSxx_BltC4Jg9m2w0Uw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 20:10:57');
INSERT INTO `sys_log_oper` VALUES (2009598784136282114, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0f2jKYZv3ebtj63KUA0w3e9X8o3jKYZ8\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjIwYjkwZWI0LWMyYjktNDkzMS1iNzY2LTRmZWQ5NWU5MDg3MiJ9.GeTpG5xMNdpFPiQNABBvB8FlL0Wu68xjoyjy5R4S1_4E-Qt0aSQ50cUrpPdXMOYK9jP9s_R04_IAmG3xZN-xiw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 20:11:01');
INSERT INTO `sys_log_oper` VALUES (2009599561751855105, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0a2sDFkl2yCMYg4M0Hll2dYMuE4sDFkS\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjMzOWQzZGEwLTllMDYtNGRhMy1hZDFjLTYzNTMxZGE5Mzc0YiJ9.cQ_pGDtGEqQWIPMbAT5lc5fmYWPXXEK15rntIHR7CqU-eHggCczPLDMbCGAfdH1NECGhgEv-xqQph4WoEYj3Zg\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 20:14:07');
INSERT INTO `sys_log_oper` VALUES (2009599570832523266, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0e2CDFkl2CCMYg4SaMnl2zeFex3CDFk-\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImNmOTIxMmRlLWRiZDEtNDQ2NC1hNWYxLTkzOWYxYWMwMmMyMSJ9.RCWlmMZ_1CyDc8sAwhnPvOIvEWWch4gImDatCf8kAWCeQna-JqhEY7OtJbiFUvzpKsiuE8rPUuP7SzGW6UwuJg\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 20:14:09');
INSERT INTO `sys_log_oper` VALUES (2009599753062473730, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0a2jGFkl2iMMYg4NBdnl2SdMN21jGFke\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjE5MjI4ZDg1LTNiM2QtNGU1Ny1hYWYzLTk1OTYxZWNlM2I3NiJ9.ZT5Eo1NW-GXsXcPYi6g3Fe9fmJH86pwv60Q5vbCKCcuT7_KlHFYChGldP_UokKDREVnplxfxqnMVBv4_hAA29A\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 20:14:52');
INSERT INTO `sys_log_oper` VALUES (2009599783311794177, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0b2MGFkl2VMMYg4JEFkl2Jzg8h0MGFk1\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjRkYTM1YjQxLThiMWItNGM5Yi04MWQzLWUyMGRiNzM4NmExNSJ9.a02pXX6WPei8cJ9iRRg6WiNRlReeKqJKoerEsCO5F5QN4n6t7dRBApZXAv3rt0T5mkkAAgYBc5NgsmXra4XtNw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 20:15:00');
INSERT INTO `sys_log_oper` VALUES (2009617531819651074, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0b2Th30w3j3Dj63scz1w38rzxL2Th30B\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjYwNjFmZmM1LWZjYjMtNDVjOS1iODg2LTUwNDY5NmZjZGFjMCJ9.q85m_3zh9nkrmoucrQw766yd8EGuYBdFcNpbnaatcbHG2GpmIWbcHZcj23JfvhHo-C6koUzzYZuwiWQ7ceLr4w\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 21:25:31');
INSERT INTO `sys_log_oper` VALUES (2009617540938067969, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0b2yZJkl23mWYg4O2gll27oHbg3yZJkf\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjM5NDU5YzA4LTgxYjMtNDRlZC1iNzQyLTkzZmFiYjFkZWUwZSJ9.LLH7RzLvn3Zs4RCoafU4bCOxUfgE29wuW8XOrNJYe1RFxhD6tLbdYB1QjPQLFzbFCqa6dodrYGxLDsuI1QFyYQ\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 21:25:33');
INSERT INTO `sys_log_oper` VALUES (2009625939398488065, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0b2G1Mkl2hMXYg42YHll2LYCsx1G1MkQ\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImE4YzMyZjlmLWI2YjUtNDhhYS1hODhjLWUyNjEzM2I2MmU0ZSJ9.CtsYTRLPSx8fGFnRyt3t5Cz1Ve3hpvA51HIduFk6QBlxxe9jS8vJkzhIwvRJeONoAK5jHHM5IUV-NUfE5Be9Qw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 21:58:56');
INSERT INTO `sys_log_oper` VALUES (2009625947879370754, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0e2P1Mkl2oLXYg4XjMml2A7arA0P1Mk1\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImQzNzBhMTc3LWViMTktNDE1NS04YzgzLTcxZWYyYWMzNTBjZCJ9.3x1NBqxwpg7a9v9hxh8R9HzthRmVK8rEk5wlDOsljnnDvxzZ0nqEzOVZ4eGScwC0dF9EIY3jw3ZPSJAraIc1lw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 21:58:58');
INSERT INTO `sys_log_oper` VALUES (2009625950672777217, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', NULL, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 21:58:58');
INSERT INTO `sys_log_oper` VALUES (2009625957727596545, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.hot()', 'GET', NULL, '/api/v1/forum/posts/hot', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 21:59:00');
INSERT INTO `sys_log_oper` VALUES (2009625962538463233, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', NULL, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 21:59:01');
INSERT INTO `sys_log_oper` VALUES (2009625967676485634, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.getDraft()', 'GET', NULL, '/api/v1/forum/posts/draft', '127.0.0.1', '{}', '', 1, '获取用户ID异常', '2026-01-09 21:59:02');
INSERT INTO `sys_log_oper` VALUES (2009626019128012801, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.hot()', 'GET', NULL, '/api/v1/forum/posts/hot', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 21:59:15');
INSERT INTO `sys_log_oper` VALUES (2009626021913030658, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', NULL, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 21:59:15');
INSERT INTO `sys_log_oper` VALUES (2009633464134942721, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0a2IT4ll2gcKYg4Iqznl2jvB3O0IT4lg\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImI5ZGFhMDA0LTFmZTgtNGUwMi1hOTdhLWYwNzgwMWFlYzk0OCJ9.jLvpSU4HmomTWRvwXlLg7_Q4g1AJawnvR0K3l7n1-dsL_DGrS8voBW1bEFbxNpNEcloBtg57jph_xdCp_PaqFg\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 22:28:50');
INSERT INTO `sys_log_oper` VALUES (2009633484678643713, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', NULL, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 22:28:55');
INSERT INTO `sys_log_oper` VALUES (2009634938952892417, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:34:41');
INSERT INTO `sys_log_oper` VALUES (2009634943654707201, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:34:42');
INSERT INTO `sys_log_oper` VALUES (2009634954274684929, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:34:45');
INSERT INTO `sys_log_oper` VALUES (2009635104405602306, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:35:21');
INSERT INTO `sys_log_oper` VALUES (2009635119538651137, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:35:24');
INSERT INTO `sys_log_oper` VALUES (2009635123519045633, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:35:25');
INSERT INTO `sys_log_oper` VALUES (2009635124169162754, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:35:25');
INSERT INTO `sys_log_oper` VALUES (2009635140409507842, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:35:29');
INSERT INTO `sys_log_oper` VALUES (2009635283108118530, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:36:03');
INSERT INTO `sys_log_oper` VALUES (2009635301273649153, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:36:08');
INSERT INTO `sys_log_oper` VALUES (2009635305379872770, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:36:09');
INSERT INTO `sys_log_oper` VALUES (2009635341316669442, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"username\":\"admin\"}', '', 1, '验证码失效', '2026-01-09 22:36:17');
INSERT INTO `sys_log_oper` VALUES (2009637090215608324, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"10\",\"username\":\"admin\",\"uuid\":\"e8445bf927d14b8e837e3686bd404081\"}', '', 1, '用户不存在/密码错误', '2026-01-09 22:43:14');
INSERT INTO `sys_log_oper` VALUES (2009637110184689665, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"10\",\"username\":\"admin\",\"uuid\":\"093b86809cef48a697553afbf1a38f00\"}', '', 1, '验证码错误', '2026-01-09 22:43:19');
INSERT INTO `sys_log_oper` VALUES (2009637141138653188, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"5\",\"username\":\"admin\",\"uuid\":\"3a96b99ca3144772ae0f640289ded56d\"}', '', 1, '用户不存在/密码错误', '2026-01-09 22:43:26');
INSERT INTO `sys_log_oper` VALUES (2009637405644046337, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"18\",\"username\":\"admin\",\"uuid\":\"27c8026e810d4e4a92e26beb64025c9e\"}', '', 1, '用户不存在/密码错误', '2026-01-09 22:44:29');
INSERT INTO `sys_log_oper` VALUES (2009637656031412226, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"0\",\"username\":\"admin\",\"uuid\":\"58c3a51be2e943cba6ebfeac68c4ff8e\"}', '', 1, '用户不存在/密码错误', '2026-01-09 22:45:29');
INSERT INTO `sys_log_oper` VALUES (2009638081157677057, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"7\",\"username\":\"admin\",\"uuid\":\"82eb62fabb3741fdb0bb47ceb2885500\"}', '{\"msg\":\"success\",\"code\":200,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjVkZGZhODg0LWE3YjAtNDhiZi04OTQwLTM1NzIwMTAwZGI0NyJ9.t8dB_RWJOogOyC4z0CNUHDQ2kgm5-MYEpUkx_GCxedYsJ2a_pYbayywvyhFd63UyF0cDqjrY_fs9RzxUdra1FQ\"}', 0, NULL, '2026-01-09 22:47:10');
INSERT INTO `sys_log_oper` VALUES (2009638081744879617, 'oddfar', 'API接口日志记录', '获取用户信息', 'com.oddfar.campus.admin.controller.system.SysLoginController.getInfo()', 'GET', 1, '/getInfo', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"permissions\":[\"*:*:*\"],\"roles\":[\"admin\"],\"user\":{\"admin\":true,\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"createTime\":\"2022-10-05 15:28:43\",\"createUser\":0,\"email\":\"oddfar@163.com\",\"loginDate\":\"2024-01-07 11:58:57\",\"loginIp\":\"127.0.0.1\",\"nickName\":\"admin\",\"params\":{},\"password\":\"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\",\"phonenumber\":\"15888888888\",\"remark\":\"管理员\",\"roles\":[{\"admin\":true,\"flag\":false,\"menuCheckStrictly\":false,\"params\":{},\"roleId\":1,\"roleKey\":\"admin\",\"roleName\":\"超级管理员\",\"roleSort\":\"1\",\"status\":\"0\"}],\"sex\":\"0\",\"status\":\"0\",\"userId\":1,\"userName\":\"admin\"}}', 0, NULL, '2026-01-09 22:47:11');
INSERT INTO `sys_log_oper` VALUES (2009638082537603073, 'oddfar', 'API接口日志记录', '获取路由信息', 'com.oddfar.campus.admin.controller.system.SysLoginController.getRouters()', 'GET', 1, '/getRouters', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"alwaysShow\":true,\"children\":[{\"component\":\"system/user/index\",\"hidden\":false,\"meta\":{\"icon\":\"user\",\"noCache\":false,\"title\":\"用户管理\"},\"name\":\"User\",\"path\":\"user\",\"query\":\"\"},{\"component\":\"system/role/index\",\"hidden\":false,\"meta\":{\"icon\":\"peoples\",\"noCache\":false,\"title\":\"角色管理\"},\"name\":\"Role\",\"path\":\"role\",\"query\":\"\"},{\"component\":\"system/menu/index\",\"hidden\":false,\"meta\":{\"icon\":\"tree-table\",\"noCache\":false,\"title\":\"菜单管理\"},\"name\":\"Menu\",\"path\":\"menu\",\"query\":\"\"},{\"component\":\"system/dict/index\",\"hidden\":false,\"meta\":{\"icon\":\"dict\",\"noCache\":false,\"title\":\"字典管理\"},\"name\":\"Dict\",\"path\":\"dict\",\"query\":\"\"},{\"component\":\"system/config/index\",\"hidden\":false,\"meta\":{\"icon\":\"edit\",\"noCache\":false,\"title\":\"参数设置\"},\"name\":\"Config\",\"path\":\"config\",\"query\":\"\"},{\"alwaysShow\":true,\"children\":[{\"component\":\"monitor/operlog/index\",\"hidden\":false,\"meta\":{\"icon\":\"form\",\"noCache\":false,\"title\":\"操作日志\"},\"name\":\"Operlog\",\"path\":\"operlog\",\"query\":\"\"},{\"component\":\"monitor/logininfor/index\",\"hidden\":false,\"meta\":{\"icon\":\"logininfor\",\"noCache\":false,\"title\":\"登录日志\"},\"name\":\"Logininfor\",\"path\":\"logininfor\",\"query\":\"\"}],\"component\":\"ParentView\",\"hidden\":false,\"meta\":{\"icon\":\"log\",\"noCache\":false,\"title\":\"日志管理\"},\"name\":\"Log\",\"path\":\"log\",\"query\":\"\",\"redirect\":\"noRedirect\"}],\"component\":\"Layout\",\"hidden\":false,\"meta\":{\"icon\":\"system\",\"noCache\":false,\"title\":\"系统管理\"},\"name\":\"System\",\"path\":\"/system\",\"query\":\"\",\"redirect\":\"noRedirect\"},{\"alwaysShow\":true,\"children\":[{\"component\":\"tool/build/index\",\"hidden\":false,\"meta\":{\"icon\":\"build\",\"noCache\":false,\"title\":\"表单构建\"},\"name\":\"Build\",\"path\":\"build\",\"query\":\"\"},{\"component\":\"tool/swagger/index\",\"hidden\":false,\"meta\":{\"icon\":\"swagger\",\"noCache\":false,\"title\":\"系统接口\"},\"name\":\"Swagger\",\"path\":\"swagger\",\"query\":\"\"}],\"component\":\"Layout\",\"hidden\":false,\"meta\":{\"icon\":\"tool\",\"noCache\":false,\"title\":\"系统工具\"},\"name\":\"Tool\",\"path\":\"/tool\",\"query\":\"\",\"redirect\":\"noRedirect\"},{\"alwaysShow\":true,\"children\":[{\"component\":\"campus/conte', 0, NULL, '2026-01-09 22:47:11');
INSERT INTO `sys_log_oper` VALUES (2009638102288580610, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_user_sex', '127.0.0.1', '{dictType=sys_user_sex}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"default\":true,\"dictCode\":1,\"dictLabel\":\"男\",\"dictSort\":1,\"dictType\":\"sys_user_sex\",\"dictValue\":\"0\",\"isDefault\":\"Y\",\"listClass\":\"default\",\"params\":{},\"remark\":\"性别男\",\"status\":\"0\"},{\"default\":false,\"dictCode\":2,\"dictLabel\":\"女\",\"dictSort\":2,\"dictType\":\"sys_user_sex\",\"dictValue\":\"1\",\"isDefault\":\"N\",\"listClass\":\"default\",\"params\":{},\"remark\":\"性别女\",\"status\":\"0\"}]}', 0, NULL, '2026-01-09 22:47:15');
INSERT INTO `sys_log_oper` VALUES (2009638102288580611, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_normal_disable', '127.0.0.1', '{dictType=sys_normal_disable}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"default\":true,\"dictCode\":6,\"dictLabel\":\"正常\",\"dictSort\":1,\"dictType\":\"sys_normal_disable\",\"dictValue\":\"0\",\"isDefault\":\"Y\",\"listClass\":\"primary\",\"params\":{},\"remark\":\"正常状态\",\"status\":\"0\"},{\"default\":false,\"dictCode\":7,\"dictLabel\":\"停用\",\"dictSort\":2,\"dictType\":\"sys_normal_disable\",\"dictValue\":\"1\",\"isDefault\":\"N\",\"listClass\":\"danger\",\"params\":{},\"remark\":\"停用状态\",\"status\":\"0\"}]}', 0, NULL, '2026-01-09 22:47:15');
INSERT INTO `sys_log_oper` VALUES (2009638103517511681, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.admin.controller.system.SysConfigController.getConfigKey()', 'GET', 1, '/system/config/configKey/sys.user.initPassword', '127.0.0.1', '{configKey=sys.user.initPassword}', '{\"msg\":\"123456\",\"code\":200}', 0, NULL, '2026-01-09 22:47:16');
INSERT INTO `sys_log_oper` VALUES (2009638103580426241, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.admin.controller.system.SysUserController.page()', 'GET', 1, '/system/user/list', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":3,\"code\":200,\"rows\":[{\"admin\":true,\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"createTime\":\"2022-10-05 15:28:43\",\"createUser\":0,\"email\":\"oddfar@163.com\",\"loginDate\":\"2026-01-09 22:47:10\",\"loginIp\":\"127.0.0.1\",\"nickName\":\"admin\",\"params\":{},\"password\":\"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\",\"phonenumber\":\"15888888888\",\"remark\":\"管理员\",\"sex\":\"0\",\"status\":\"0\",\"updateTime\":\"2026-01-09 22:47:10\",\"updateUser\":1,\"userId\":1,\"userName\":\"admin\"},{\"admin\":false,\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"createTime\":\"2022-10-05 15:28:43\",\"createUser\":0,\"email\":\"a_zhiyuan@163.com\",\"loginDate\":\"2023-12-25 00:23:54\",\"loginIp\":\"127.0.0.1\",\"nickName\":\"致远\",\"params\":{},\"password\":\"$2a$10$CgOz7rzHEqUDjPO9h6N0Y.ecwB.1HpIXx4UC9DwZU.NY9zyMJ/meS\",\"phonenumber\":\"15666666666\",\"remark\":\"测试\",\"sex\":\"1\",\"status\":\"0\",\"updateTime\":\"2023-12-25 00:23:54\",\"userId\":2,\"userName\":\"zhiyuan\"},{\"admin\":false,\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"createTime\":\"2026-01-09 20:10:57\",\"email\":\"\",\"loginDate\":\"2026-01-09 22:28:50\",\"loginIp\":\"\",\"nickName\":\"微信用户\",\"params\":{},\"password\":\"$2a$10$k8EbUy8HEmahCd/.5vxpvOmZ3wBmRCn1l92/.wBlSnuKK5PhmyXie\",\"phonenumber\":\"\",\"sex\":\"0\",\"status\":\"0\",\"updateTime\":\"2026-01-09 22:28:50\",\"userId\":2009598766385987585,\"userName\":\"wx_o0jpQ3RbbAwk86Wa\"}]}', 0, NULL, '2026-01-09 22:47:16');
INSERT INTO `sys_log_oper` VALUES (2009638120571551745, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_show_hide', '127.0.0.1', '{dictType=sys_show_hide}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"createTime\":\"2022-12-26 21:49:47\",\"createUser\":1,\"default\":false,\"dictCode\":41,\"dictLabel\":\"显示\",\"dictSort\":1,\"dictType\":\"sys_show_hide\",\"dictValue\":\"0\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"remark\":\"显示菜单\",\"status\":\"0\",\"updateTime\":\"2022-12-26 21:49:47\"},{\"createTime\":\"2022-12-26 21:50:10\",\"createUser\":1,\"default\":false,\"dictCode\":42,\"dictLabel\":\"隐藏\",\"dictSort\":2,\"dictType\":\"sys_show_hide\",\"dictValue\":\"1\",\"isDefault\":\"N\",\"listClass\":\"danger\",\"params\":{},\"remark\":\"隐藏菜单\",\"status\":\"0\",\"updateTime\":\"2022-12-26 21:50:10\"}]}', 0, NULL, '2026-01-09 22:47:20');
INSERT INTO `sys_log_oper` VALUES (2009638120705769474, 'oddfar', 'API接口日志记录', '菜单管理-分页', 'com.oddfar.campus.admin.controller.system.SysMenuController.list()', 'GET', 1, '/system/menu/list', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"children\":[],\"createTime\":\"2022-10-05 15:28:43\",\"icon\":\"system\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":1,\"menuName\":\"系统管理\",\"menuType\":\"M\",\"orderNum\":1,\"params\":{},\"parentId\":0,\"path\":\"system\",\"perms\":\"\",\"query\":\"\",\"remark\":\"系统管理目录\",\"status\":\"0\",\"updateTime\":\"2022-11-14 14:41:50\",\"updateUser\":1,\"visible\":\"0\"},{\"children\":[],\"createTime\":\"2022-10-05 15:28:43\",\"icon\":\"tool\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":3,\"menuName\":\"系统工具\",\"menuType\":\"M\",\"orderNum\":3,\"params\":{},\"parentId\":0,\"path\":\"tool\",\"perms\":\"\",\"query\":\"\",\"remark\":\"系统工具目录\",\"status\":\"0\",\"visible\":\"0\"},{\"children\":[],\"createTime\":\"2022-10-05 15:28:43\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"源码地址\",\"menuType\":\"M\",\"orderNum\":10,\"params\":{},\"parentId\":0,\"path\":\"https://github.com/oddfar/campus-example\",\"perms\":\"\",\"query\":\"\",\"remark\":\"若依官网地址\",\"status\":\"0\",\"updateTime\":\"2022-11-21 17:11:40\",\"updateUser\":1,\"visible\":\"0\"},{\"children\":[],\"component\":\"system/user/index\",\"createTime\":\"2022-10-05 15:28:43\",\"icon\":\"user\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":100,\"menuName\":\"用户管理\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"user\",\"perms\":\"system:user:list\",\"query\":\"\",\"remark\":\"用户管理菜单\",\"status\":\"0\",\"visible\":\"0\"},{\"children\":[],\"component\":\"system/role/index\",\"createTime\":\"2022-10-05 15:28:43\",\"icon\":\"peoples\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":101,\"menuName\":\"角色管理\",\"menuType\":\"C\",\"orderNum\":2,\"params\":{},\"parentId\":1,\"path\":\"role\",\"perms\":\"system:role:list\",\"query\":\"\",\"remark\":\"角色管理菜单\",\"status\":\"0\",\"visible\":\"0\"},{\"children\":[],\"component\":\"system/menu/index\",\"createTime\":\"2022-10-05 15:28:43\",\"icon\":\"tree-table\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":102,\"menuName\":\"菜单管理\",\"menuType\":\"C\",\"orderNum\":3,\"params\":{},\"parentId\":1,\"path\":\"menu\",\"perms\":\"system:menu:list\",\"query\":\"\",\"remark\":\"菜单管理菜单\",\"status\":\"0\",\"visible\":\"0\"},{\"children\":[],\"component\":\"system/dict/index\",\"createTime\":\"2022-10-05 15:28:43\",\"icon\":\"dict\",\"isCache\":\"0\",\"isFrame\":\"1\",\"me', 0, NULL, '2026-01-09 22:47:20');
INSERT INTO `sys_log_oper` VALUES (2009638127064334337, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.admin.controller.system.SysRoleController.list()', 'GET', 1, '/system/role/list', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":5,\"code\":200,\"rows\":[{\"admin\":true,\"createTime\":\"2022-10-05 15:28:43\",\"flag\":false,\"menuCheckStrictly\":true,\"params\":{},\"remark\":\"超级管理员\",\"roleId\":1,\"roleKey\":\"admin\",\"roleName\":\"超级管理员\",\"roleSort\":\"1\",\"status\":\"0\"},{\"admin\":false,\"createTime\":\"2022-10-05 15:28:43\",\"flag\":false,\"menuCheckStrictly\":true,\"params\":{},\"remark\":\"普通角色\",\"roleId\":2,\"roleKey\":\"common\",\"roleName\":\"普通角色\",\"roleSort\":\"2\",\"status\":\"0\",\"updateTime\":\"2022-12-19 22:13:17\",\"updateUser\":1},{\"admin\":false,\"createTime\":\"2022-11-20 19:04:06\",\"createUser\":1,\"flag\":false,\"menuCheckStrictly\":true,\"params\":{},\"roleId\":1594285449147330561,\"roleKey\":\"campus:common\",\"roleName\":\"普通用户\",\"roleSort\":\"0\",\"status\":\"0\",\"updateTime\":\"2023-02-24 13:14:02\",\"updateUser\":1},{\"admin\":false,\"createTime\":\"2023-02-24 13:56:04\",\"createUser\":1,\"flag\":false,\"menuCheckStrictly\":true,\"params\":{},\"remark\":\"审核信息墙内容，可以修改信息墙内容\",\"roleId\":1628997165540274178,\"roleKey\":\"campus:auditor\",\"roleName\":\"审核员\",\"roleSort\":\"0\",\"status\":\"0\",\"updateTime\":\"2023-02-24 14:11:29\",\"updateUser\":1},{\"admin\":false,\"createTime\":\"2023-02-24 13:58:00\",\"createUser\":1,\"flag\":false,\"menuCheckStrictly\":true,\"params\":{},\"remark\":\"只可浏览信息墙，点赞信息墙，不可发表墙和评论\",\"roleId\":1628997651572027394,\"roleKey\":\"campus:glance\",\"roleName\":\"浏览用户\",\"roleSort\":\"0\",\"status\":\"0\",\"updateTime\":\"2023-02-24 14:10:46\",\"updateUser\":1}]}', 0, NULL, '2026-01-09 22:47:21');
INSERT INTO `sys_log_oper` VALUES (2009638285789380610, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/campus_content_status', '127.0.0.1', '{dictType=campus_content_status}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"createTime\":\"2022-11-30 20:33:31\",\"createUser\":1,\"default\":false,\"dictCode\":1597931830248570882,\"dictLabel\":\"审核\",\"dictSort\":1,\"dictType\":\"campus_content_status\",\"dictValue\":\"0\",\"isDefault\":\"N\",\"listClass\":\"warning\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-30 20:33:31\",\"updateUser\":1},{\"createTime\":\"2022-11-30 20:33:57\",\"createUser\":1,\"default\":false,\"dictCode\":1597931939476635650,\"dictLabel\":\"正常\",\"dictSort\":2,\"dictType\":\"campus_content_status\",\"dictValue\":\"1\",\"isDefault\":\"N\",\"listClass\":\"success\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-30 20:33:57\",\"updateUser\":1},{\"createTime\":\"2022-11-30 20:34:13\",\"createUser\":1,\"default\":false,\"dictCode\":1597932004085694466,\"dictLabel\":\"下架\",\"dictSort\":3,\"dictType\":\"campus_content_status\",\"dictValue\":\"2\",\"isDefault\":\"N\",\"listClass\":\"danger\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-30 20:34:12\",\"updateUser\":1},{\"createTime\":\"2023-01-01 22:33:55\",\"createUser\":1,\"default\":false,\"dictCode\":1609558539133521922,\"dictLabel\":\"拒绝\",\"dictSort\":4,\"dictType\":\"campus_content_status\",\"dictValue\":\"3\",\"isDefault\":\"N\",\"listClass\":\"danger\",\"params\":{},\"remark\":\"审核不通过\",\"status\":\"0\",\"updateTime\":\"2023-01-01 22:33:54\",\"updateUser\":1}]}', 0, NULL, '2026-01-09 22:47:59');
INSERT INTO `sys_log_oper` VALUES (2009638287035088897, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/campus_anonymous', '127.0.0.1', '{dictType=campus_anonymous}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"createTime\":\"2022-11-30 20:35:45\",\"createUser\":1,\"default\":false,\"dictCode\":1597932393732341761,\"dictLabel\":\"不匿\",\"dictSort\":1,\"dictType\":\"campus_anonymous\",\"dictValue\":\"0\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-30 20:35:45\"},{\"createTime\":\"2022-11-30 20:36:04\",\"createUser\":1,\"default\":false,\"dictCode\":1597932469577940994,\"dictLabel\":\"匿名\",\"dictSort\":2,\"dictType\":\"campus_anonymous\",\"dictValue\":\"1\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-30 20:36:03\"}]}', 0, NULL, '2026-01-09 22:48:00');
INSERT INTO `sys_log_oper` VALUES (2009638287102197762, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/campus_content_type', '127.0.0.1', '{dictType=campus_content_type}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"createTime\":\"2022-12-04 21:16:27\",\"createUser\":1,\"default\":false,\"dictCode\":1599392185411743745,\"dictLabel\":\"文字\",\"dictSort\":0,\"dictType\":\"campus_content_type\",\"dictValue\":\"0\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"remark\":\"\",\"status\":\"0\",\"updateTime\":\"2022-12-04 21:16:26\",\"updateUser\":1},{\"createTime\":\"2022-12-04 21:16:44\",\"createUser\":1,\"default\":false,\"dictCode\":1599392255200768001,\"dictLabel\":\"图片\",\"dictSort\":2,\"dictType\":\"campus_content_type\",\"dictValue\":\"1\",\"isDefault\":\"N\",\"listClass\":\"success\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-12-04 21:16:43\",\"updateUser\":1},{\"createTime\":\"2022-12-04 21:17:54\",\"createUser\":1,\"default\":false,\"dictCode\":1599392552258154497,\"dictLabel\":\"视频\",\"dictSort\":3,\"dictType\":\"campus_content_type\",\"dictValue\":\"2\",\"isDefault\":\"N\",\"listClass\":\"info\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-12-04 21:17:54\",\"updateUser\":1}]}', 0, NULL, '2026-01-09 22:48:00');
INSERT INTO `sys_log_oper` VALUES (2009638287169306626, 'campus', 'API接口日志记录', '查询分类列表选择器', 'com.oddfar.campus.business.controller.admin.CategoryController.listSelect()', 'GET', 1, '/admin/category/listSelect', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"categoryId\":1,\"categoryName\":\"最新墙\",\"createTime\":\"2022-12-30 20:11:41\",\"createUser\":1,\"description\":\"最近的墙内容(菜单默认选择这个)\",\"hasChildren\":false,\"icon\":\"system\",\"orderNum\":0,\"params\":{},\"parentId\":0,\"slug\":\"newest\",\"status\":\"0\",\"type\":\"Y\",\"updateTime\":\"2023-01-01 22:23:49\",\"updateUser\":1},{\"categoryId\":1449212758636646402,\"categoryName\":\"表白\",\"createTime\":\"2021-10-16 11:17:01\",\"description\":\"吐槽描述\",\"hasChildren\":false,\"icon\":\"system\",\"orderNum\":1,\"params\":{},\"parentId\":123,\"slug\":\"debunk\",\"status\":\"0\",\"type\":\"N\",\"updateTime\":\"2023-01-01 22:26:29\",\"updateUser\":1},{\"categoryId\":1644303286433800193,\"categoryName\":\"求购\",\"createTime\":\"2023-04-07 19:37:08\",\"createUser\":1,\"hasChildren\":false,\"icon\":\"system\",\"orderNum\":1,\"params\":{},\"parentId\":1644302999660847105,\"slug\":\"want_to_buy\",\"status\":\"0\",\"type\":\"N\",\"updateTime\":\"2023-04-07 19:37:07\",\"updateUser\":1},{\"categoryId\":1644309673171804161,\"categoryName\":\"实习兼职\",\"createTime\":\"2023-04-07 20:02:31\",\"createUser\":1,\"hasChildren\":false,\"icon\":\"system\",\"orderNum\":1,\"params\":{},\"parentId\":1644309509791080449,\"slug\":\"Internship_part-time_job\",\"status\":\"0\",\"type\":\"N\",\"updateTime\":\"2023-04-07 20:02:30\",\"updateUser\":1},{\"categoryId\":123,\"categoryName\":\"表白墙\",\"createTime\":\"2021-10-15 10:32:00\",\"description\":\"\",\"hasChildren\":false,\"icon\":\"system\",\"orderNum\":2,\"params\":{},\"parentId\":0,\"slug\":\"friends\",\"status\":\"0\",\"type\":\"N\",\"updateTime\":\"2023-04-07 19:30:12\",\"updateUser\":1},{\"categoryId\":1602336520042287105,\"categoryName\":\"日常分享\",\"createTime\":\"2022-12-13 00:16:11\",\"createUser\":1,\"hasChildren\":false,\"icon\":\"system\",\"orderNum\":2,\"params\":{},\"parentId\":1465662542308495361,\"slug\":\"daily_sharing\",\"status\":\"0\",\"type\":\"N\",\"updateTime\":\"2022-12-26 17:57:51\",\"updateUser\":1},{\"categoryId\":1644302032332709889,\"categoryName\":\"交友\",\"createTime\":\"2023-04-07 19:32:09\",\"createUser\":1,\"hasChildren\":false,\"icon\":\"system\",\"orderNum\":2,\"params\":{},\"parentId\":123,\"slug\":\"make_friends\",\"status\":\"0\",\"type\":\"N\",\"updateTime\":\"2023-04-07', 0, NULL, '2026-01-09 22:48:00');
INSERT INTO `sys_log_oper` VALUES (2009638287366438914, 'campus', 'API接口日志记录', '分页', 'com.oddfar.campus.business.controller.admin.ContentController.page()', 'GET', 1, '/admin/content/list', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":3,\"code\":200,\"rows\":[{\"categoryId\":1602336520042287105,\"content\":\"hello world\\nhello world\\nhello world\\nhello world\",\"contentId\":2,\"createTime\":\"2022-12-13 00:01:47\",\"fileCount\":1,\"isAnonymous\":0,\"loveCount\":1,\"params\":{\"nickName\":\"admin\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"userName\":\"admin\",\"userId\":1,\"categoryName\":\"日常分享\",\"categoryId\":1602336520042287105},\"status\":1,\"tags\":[{\"contentId\":2,\"tagId\":1,\"tagName\":\"测试标签\"},{\"contentId\":2,\"tagId\":2,\"tagName\":\"梅西\"}],\"type\":0,\"userId\":1},{\"categoryId\":1602336520042287105,\"content\":\"你好，welcome\\n开源地址：https://github.com/oddfar/campus\\n欢迎大家 Star 和 Fork 支持~\",\"contentId\":3,\"createTime\":\"2022-12-13 00:01:47\",\"fileCount\":1,\"isAnonymous\":0,\"loveCount\":0,\"params\":{\"nickName\":\"admin\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"userName\":\"admin\",\"userId\":1,\"categoryName\":\"日常分享\",\"categoryId\":1602336520042287105},\"status\":1,\"tags\":[],\"type\":0,\"userId\":1},{\"categoryId\":1449212758636646402,\"content\":\"欢迎使用校园信息墙项目\\n开源地址：https://github.com/oddfar/campus\\n欢迎大家 Star 和 Fork 支持~\",\"contentId\":1,\"createTime\":\"2022-03-05 10:55:04\",\"fileCount\":0,\"isAnonymous\":1,\"loveCount\":0,\"params\":{\"nickName\":\"匿名用户\",\"avatar\":\"https://gcore.jsdelivr.net/gh/oddfar/static/campus/image/anonymous.jpeg\",\"categoryName\":\"表白\",\"categoryId\":1449212758636646402},\"status\":1,\"tags\":[{\"contentId\":1,\"tagId\":1,\"tagName\":\"测试标签\"},{\"contentId\":1,\"tagId\":2,\"tagName\":\"梅西\"},{\"contentId\":1,\"tagId\":3,\"tagName\":\"蔡徐坤\"}],\"type\":0}]}', 0, NULL, '2026-01-09 22:48:00');
INSERT INTO `sys_log_oper` VALUES (2009638359135174657, 'oddfar', 'API接口日志记录', '个人信息管理-查询', 'com.oddfar.campus.admin.controller.system.SysProfileController.profile()', 'GET', 1, '/system/user/profile', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"admin\":true,\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"createTime\":\"2022-10-05 15:28:43\",\"createUser\":0,\"email\":\"oddfar@163.com\",\"loginDate\":\"2024-01-07 11:58:57\",\"loginIp\":\"127.0.0.1\",\"nickName\":\"admin\",\"params\":{},\"password\":\"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\",\"phonenumber\":\"15888888888\",\"remark\":\"管理员\",\"roles\":[{\"admin\":true,\"flag\":false,\"menuCheckStrictly\":false,\"params\":{},\"roleId\":1,\"roleKey\":\"admin\",\"roleName\":\"超级管理员\",\"roleSort\":\"1\",\"status\":\"0\"}],\"sex\":\"0\",\"status\":\"0\",\"userId\":1,\"userName\":\"admin\"},\"roleGroup\":\"超级管理员\"}', 0, NULL, '2026-01-09 22:48:17');
INSERT INTO `sys_log_oper` VALUES (2009638513019994114, 'oddfar', 'API接口日志记录', '字典类型管理-分页', 'com.oddfar.campus.admin.controller.system.SysDictTypeController.list()', 'GET', 1, '/system/dict/type/list', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":8,\"code\":200,\"rows\":[{\"createTime\":\"2023-03-09 17:31:52\",\"dictId\":1,\"dictName\":\"用户性别\",\"dictType\":\"sys_user_sex\",\"params\":{},\"remark\":\"用户性别列表\",\"status\":\"0\",\"updateTime\":\"2022-11-06 01:10:21\",\"updateUser\":1},{\"createTime\":\"2022-11-06 06:37:05\",\"createUser\":1,\"dictId\":2,\"dictName\":\"系统是否\",\"dictType\":\"sys_yes_no\",\"params\":{},\"remark\":\"系统是否列表\",\"status\":\"0\",\"updateTime\":\"2022-11-06 20:37:04\",\"updateUser\":1},{\"createTime\":\"2023-03-09 17:31:55\",\"dictId\":3,\"dictName\":\"系统开关\",\"dictType\":\"sys_normal_disable\",\"params\":{},\"remark\":\"系统开关列表\",\"status\":\"0\"},{\"createTime\":\"2022-12-26 21:49:15\",\"createUser\":1,\"dictId\":4,\"dictName\":\"菜单状态\",\"dictType\":\"sys_show_hide\",\"params\":{},\"remark\":\"菜单状态列表\",\"status\":\"0\",\"updateTime\":\"2022-12-26 21:49:15\"},{\"createTime\":\"2022-11-06 05:32:37\",\"createUser\":1,\"dictId\":101,\"dictName\":\"配置群组\",\"dictType\":\"sys_config_group\",\"params\":{},\"remark\":\"配置群组\",\"status\":\"0\",\"updateTime\":\"2022-11-06 19:32:37\",\"updateUser\":1},{\"createTime\":\"2022-11-30 20:32:57\",\"createUser\":1,\"dictId\":1597931685624774657,\"dictName\":\"校园墙内容状态\",\"dictType\":\"campus_content_status\",\"params\":{},\"remark\":\"校园墙内容状态\",\"status\":\"0\",\"updateTime\":\"2022-11-30 20:32:56\"},{\"createTime\":\"2022-11-30 20:35:24\",\"createUser\":1,\"dictId\":1597932303005351938,\"dictName\":\"是否匿名\",\"dictType\":\"campus_anonymous\",\"params\":{},\"remark\":\"校园信息墙是否匿名\",\"status\":\"0\",\"updateTime\":\"2022-11-30 20:35:23\"},{\"createTime\":\"2022-12-04 21:16:00\",\"createUser\":1,\"dictId\":1599392072043900930,\"dictName\":\"校园内类型\",\"dictType\":\"campus_content_type\",\"params\":{},\"remark\":\"0文字,1图片,2视频\",\"status\":\"0\",\"updateTime\":\"2022-12-04 21:15:59\"}]}', 0, NULL, '2026-01-09 22:48:53');
INSERT INTO `sys_log_oper` VALUES (2009638523417673729, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_config_group', '127.0.0.1', '{dictType=sys_config_group}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"createTime\":\"2022-11-06 19:27:23\",\"default\":false,\"dictCode\":101,\"dictLabel\":\"系统配置\",\"dictSort\":1,\"dictType\":\"sys_config_group\",\"dictValue\":\"sys_config\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"remark\":\"配置群组的系统配置\",\"status\":\"0\",\"updateTime\":\"2022-11-06 06:07:20\",\"updateUser\":1},{\"createTime\":\"2022-11-06 05:38:04\",\"createUser\":1,\"default\":false,\"dictCode\":102,\"dictLabel\":\"邮件配置\",\"dictSort\":2,\"dictType\":\"sys_config_group\",\"dictValue\":\"mail_config\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-06 06:07:20\",\"updateUser\":1},{\"createTime\":\"2022-11-06 06:32:45\",\"createUser\":1,\"default\":false,\"dictCode\":103,\"dictLabel\":\"文件配置\",\"dictSort\":3,\"dictType\":\"sys_config_group\",\"dictValue\":\"file_config\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-06 20:32:44\",\"updateUser\":1},{\"createTime\":\"2023-02-03 15:59:31\",\"createUser\":1,\"default\":false,\"dictCode\":1621418087714918401,\"dictLabel\":\"campus配置\",\"dictSort\":10,\"dictType\":\"sys_config_group\",\"dictValue\":\"campus_config\",\"isDefault\":\"N\",\"listClass\":\"primary\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2023-02-03 15:59:31\"}]}', 0, NULL, '2026-01-09 22:48:56');
INSERT INTO `sys_log_oper` VALUES (2009638523417673730, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_yes_no', '127.0.0.1', '{dictType=sys_yes_no}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"createTime\":\"2022-11-06 06:37:31\",\"createUser\":1,\"default\":false,\"dictCode\":3,\"dictLabel\":\"是\",\"dictSort\":1,\"dictType\":\"sys_yes_no\",\"dictValue\":\"Y\",\"isDefault\":\"N\",\"listClass\":\"success\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-06 06:39:34\",\"updateUser\":1},{\"createTime\":\"2022-11-06 06:37:42\",\"createUser\":1,\"default\":false,\"dictCode\":4,\"dictLabel\":\"否\",\"dictSort\":2,\"dictType\":\"sys_yes_no\",\"dictValue\":\"N\",\"isDefault\":\"N\",\"listClass\":\"danger\",\"params\":{},\"status\":\"0\",\"updateTime\":\"2022-11-06 06:39:34\",\"updateUser\":1}]}', 0, NULL, '2026-01-09 22:48:56');
INSERT INTO `sys_log_oper` VALUES (2009638523417673731, 'oddfar', 'API接口日志记录', '参数配置管理-分页', 'com.oddfar.campus.admin.controller.system.SysConfigController.page()', 'GET', 1, '/system/config/page', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":25,\"code\":200,\"rows\":[{\"configId\":1,\"configKey\":\"sys.local.profile.mac\",\"configName\":\"Mac本地文件路径\",\"configType\":\"Y\",\"configValue\":\"~/uploadPath\",\"createTime\":\"2022-11-10 14:06:44\",\"createUser\":1,\"groupCode\":\"file_config\",\"params\":{},\"updateTime\":\"2022-11-10 14:07:49\"},{\"configId\":2,\"configKey\":\"sys.local.profile.linux\",\"configName\":\"Linux本地文件路径\",\"configType\":\"Y\",\"configValue\":\"/data/uploadPath\",\"createTime\":\"2022-01-14 10:59:39\",\"groupCode\":\"file_config\",\"params\":{},\"updateTime\":\"2022-01-16 14:11:53\",\"updateUser\":1},{\"configId\":3,\"configKey\":\"sys.local.profile.win\",\"configName\":\"Windows本地文件路径\",\"configType\":\"Y\",\"configValue\":\"D:\\\\uploadPath\",\"createTime\":\"2022-01-14 11:00:39\",\"groupCode\":\"file_config\",\"params\":{},\"updateTime\":\"2022-01-16 14:11:53\",\"updateUser\":1},{\"configId\":4,\"configKey\":\"sys.file.default.bucket\",\"configName\":\"默认存储文件的bucket名称\",\"configType\":\"Y\",\"configValue\":\"defaultBucket\",\"createTime\":\"2022-01-14 11:03:10\",\"groupCode\":\"file_config\",\"params\":{},\"updateTime\":\"2022-01-16 14:11:54\"},{\"configId\":5,\"configKey\":\"sys.server.deploy.host\",\"configName\":\"文件默认部署的环境地址\",\"configType\":\"Y\",\"configValue\":\"http://localhost:8160\",\"createTime\":\"2022-01-16 14:11:45\",\"groupCode\":\"file_config\",\"params\":{},\"updateTime\":\"2022-01-16 14:18:55\"},{\"configId\":6,\"configKey\":\"sys.file.visit.nginx\",\"configName\":\"文件访问是否用nginx映射\",\"configType\":\"Y\",\"configValue\":\"false\",\"createTime\":\"2022-01-16 14:40:00\",\"groupCode\":\"file_config\",\"params\":{},\"remark\":\"true真，false假\",\"updateTime\":\"2022-01-16 14:40:20\"},{\"configId\":7,\"configKey\":\"sys.file.is.delete\",\"configName\":\"信息墙删除且对应文件也删除\",\"configType\":\"Y\",\"configValue\":\"false\",\"createTime\":\"2022-01-17 14:29:11\",\"groupCode\":\"file_config\",\"params\":{},\"remark\":\"true墙和文件都删除，false文件转移到别的目录\",\"updateTime\":\"2022-01-18 15:02:14\"},{\"configId\":8,\"configKey\":\"sys.file.move.default.bucket\",\"configName\":\"文件默认转移的bucket名称\",\"configType\":\"Y\",\"configValue\":\"moveBucket\",\"createTime\":\"2022-01-17 14:31:05\",\"groupCode\":\"file_config\",\"params\":{},\"upda', 0, NULL, '2026-01-09 22:48:56');
INSERT INTO `sys_log_oper` VALUES (2009638544724738050, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_oper_type', '127.0.0.1', '{dictType=sys_oper_type}', '{\"msg\":\"success\",\"code\":200,\"data\":[]}', 0, NULL, '2026-01-09 22:49:01');
INSERT INTO `sys_log_oper` VALUES (2009638546020777986, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_common_status', '127.0.0.1', '{dictType=sys_common_status}', '{\"msg\":\"success\",\"code\":200,\"data\":[]}', 0, NULL, '2026-01-09 22:49:01');
INSERT INTO `sys_log_oper` VALUES (2009638731597758466, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"2\",\"username\":\"admin\",\"uuid\":\"b6c0add981e04f8cb6f4cf9d0e5acadd\"}', '{\"msg\":\"success\",\"code\":200,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImExODlhNDZiLWU4MDYtNDA5NC1hZTBmLWJmNWYwYzczYzQzZiJ9.3EBOFPeif6ASIq7nW2U61RYbqwN0cpYs7gO_8asdPdpMWEerCfjS3qkYwCaL7Rmu5frbMqZi97X9L8FQSwL1cw\"}', 0, NULL, '2026-01-09 22:49:46');
INSERT INTO `sys_log_oper` VALUES (2009639192547573761, 'oddfar', 'API接口日志记录', '获取用户信息', 'com.oddfar.campus.admin.controller.system.SysLoginController.getInfo()', 'GET', 1, '/getInfo', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"permissions\":[\"*:*:*\"],\"roles\":[\"admin\"],\"user\":{\"admin\":true,\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"createTime\":\"2022-10-05 15:28:43\",\"createUser\":0,\"email\":\"oddfar@163.com\",\"loginDate\":\"2026-01-09 22:47:10\",\"loginIp\":\"127.0.0.1\",\"nickName\":\"admin\",\"params\":{},\"password\":\"$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2\",\"phonenumber\":\"15888888888\",\"remark\":\"管理员\",\"roles\":[{\"admin\":true,\"flag\":false,\"menuCheckStrictly\":false,\"params\":{},\"roleId\":1,\"roleKey\":\"admin\",\"roleName\":\"超级管理员\",\"roleSort\":\"1\",\"status\":\"0\"}],\"sex\":\"0\",\"status\":\"0\",\"userId\":1,\"userName\":\"admin\"}}', 0, NULL, '2026-01-09 22:51:35');
INSERT INTO `sys_log_oper` VALUES (2009639192937644033, 'oddfar', 'API接口日志记录', '获取路由信息', 'com.oddfar.campus.admin.controller.system.SysLoginController.getRouters()', 'GET', 1, '/getRouters', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"alwaysShow\":true,\"children\":[{\"component\":\"system/user/index\",\"hidden\":false,\"meta\":{\"icon\":\"user\",\"noCache\":false,\"title\":\"用户管理\"},\"name\":\"User\",\"path\":\"user\",\"query\":\"\"},{\"component\":\"system/role/index\",\"hidden\":false,\"meta\":{\"icon\":\"peoples\",\"noCache\":false,\"title\":\"角色管理\"},\"name\":\"Role\",\"path\":\"role\",\"query\":\"\"},{\"component\":\"system/menu/index\",\"hidden\":false,\"meta\":{\"icon\":\"tree-table\",\"noCache\":false,\"title\":\"菜单管理\"},\"name\":\"Menu\",\"path\":\"menu\",\"query\":\"\"},{\"component\":\"system/dict/index\",\"hidden\":false,\"meta\":{\"icon\":\"dict\",\"noCache\":false,\"title\":\"字典管理\"},\"name\":\"Dict\",\"path\":\"dict\",\"query\":\"\"},{\"component\":\"system/config/index\",\"hidden\":false,\"meta\":{\"icon\":\"edit\",\"noCache\":false,\"title\":\"参数设置\"},\"name\":\"Config\",\"path\":\"config\",\"query\":\"\"},{\"alwaysShow\":true,\"children\":[{\"component\":\"monitor/operlog/index\",\"hidden\":false,\"meta\":{\"icon\":\"form\",\"noCache\":false,\"title\":\"操作日志\"},\"name\":\"Operlog\",\"path\":\"operlog\",\"query\":\"\"},{\"component\":\"monitor/logininfor/index\",\"hidden\":false,\"meta\":{\"icon\":\"logininfor\",\"noCache\":false,\"title\":\"登录日志\"},\"name\":\"Logininfor\",\"path\":\"logininfor\",\"query\":\"\"}],\"component\":\"ParentView\",\"hidden\":false,\"meta\":{\"icon\":\"log\",\"noCache\":false,\"title\":\"日志管理\"},\"name\":\"Log\",\"path\":\"log\",\"query\":\"\",\"redirect\":\"noRedirect\"}],\"component\":\"Layout\",\"hidden\":false,\"meta\":{\"icon\":\"system\",\"noCache\":false,\"title\":\"系统管理\"},\"name\":\"System\",\"path\":\"/system\",\"query\":\"\",\"redirect\":\"noRedirect\"},{\"alwaysShow\":true,\"children\":[{\"component\":\"tool/build/index\",\"hidden\":false,\"meta\":{\"icon\":\"build\",\"noCache\":false,\"title\":\"表单构建\"},\"name\":\"Build\",\"path\":\"build\",\"query\":\"\"},{\"component\":\"tool/swagger/index\",\"hidden\":false,\"meta\":{\"icon\":\"swagger\",\"noCache\":false,\"title\":\"系统接口\"},\"name\":\"Swagger\",\"path\":\"swagger\",\"query\":\"\"}],\"component\":\"Layout\",\"hidden\":false,\"meta\":{\"icon\":\"tool\",\"noCache\":false,\"title\":\"系统工具\"},\"name\":\"Tool\",\"path\":\"/tool\",\"query\":\"\",\"redirect\":\"noRedirect\"},{\"alwaysShow\":true,\"children\":[{\"component\":\"campus/conte', 0, NULL, '2026-01-09 22:51:36');
INSERT INTO `sys_log_oper` VALUES (2009639195353563137, 'oddfar', 'API接口日志记录', '字典数据管理-根据字典类型查询字典数据信息', 'com.oddfar.campus.admin.controller.system.SysDictDataController.dictType()', 'GET', 1, '/system/dict/data/type/sys_normal_disable', '127.0.0.1', '{dictType=sys_normal_disable}', '{\"msg\":\"success\",\"code\":200,\"data\":[{\"default\":true,\"dictCode\":6,\"dictLabel\":\"正常\",\"dictSort\":1,\"dictType\":\"sys_normal_disable\",\"dictValue\":\"0\",\"isDefault\":\"Y\",\"listClass\":\"primary\",\"params\":{},\"remark\":\"正常状态\",\"status\":\"0\"},{\"default\":false,\"dictCode\":7,\"dictLabel\":\"停用\",\"dictSort\":2,\"dictType\":\"sys_normal_disable\",\"dictValue\":\"1\",\"isDefault\":\"N\",\"listClass\":\"danger\",\"params\":{},\"remark\":\"停用状态\",\"status\":\"0\"}]}', 0, NULL, '2026-01-09 22:51:36');
INSERT INTO `sys_log_oper` VALUES (2009639196666380290, 'oddfar', 'API接口日志记录', '字典类型管理-分页', 'com.oddfar.campus.admin.controller.system.SysDictTypeController.list()', 'GET', 1, '/system/dict/type/list', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":8,\"code\":200,\"rows\":[{\"createTime\":\"2023-03-09 17:31:52\",\"dictId\":1,\"dictName\":\"用户性别\",\"dictType\":\"sys_user_sex\",\"params\":{},\"remark\":\"用户性别列表\",\"status\":\"0\",\"updateTime\":\"2022-11-06 01:10:21\",\"updateUser\":1},{\"createTime\":\"2022-11-06 06:37:05\",\"createUser\":1,\"dictId\":2,\"dictName\":\"系统是否\",\"dictType\":\"sys_yes_no\",\"params\":{},\"remark\":\"系统是否列表\",\"status\":\"0\",\"updateTime\":\"2022-11-06 20:37:04\",\"updateUser\":1},{\"createTime\":\"2023-03-09 17:31:55\",\"dictId\":3,\"dictName\":\"系统开关\",\"dictType\":\"sys_normal_disable\",\"params\":{},\"remark\":\"系统开关列表\",\"status\":\"0\"},{\"createTime\":\"2022-12-26 21:49:15\",\"createUser\":1,\"dictId\":4,\"dictName\":\"菜单状态\",\"dictType\":\"sys_show_hide\",\"params\":{},\"remark\":\"菜单状态列表\",\"status\":\"0\",\"updateTime\":\"2022-12-26 21:49:15\"},{\"createTime\":\"2022-11-06 05:32:37\",\"createUser\":1,\"dictId\":101,\"dictName\":\"配置群组\",\"dictType\":\"sys_config_group\",\"params\":{},\"remark\":\"配置群组\",\"status\":\"0\",\"updateTime\":\"2022-11-06 19:32:37\",\"updateUser\":1},{\"createTime\":\"2022-11-30 20:32:57\",\"createUser\":1,\"dictId\":1597931685624774657,\"dictName\":\"校园墙内容状态\",\"dictType\":\"campus_content_status\",\"params\":{},\"remark\":\"校园墙内容状态\",\"status\":\"0\",\"updateTime\":\"2022-11-30 20:32:56\"},{\"createTime\":\"2022-11-30 20:35:24\",\"createUser\":1,\"dictId\":1597932303005351938,\"dictName\":\"是否匿名\",\"dictType\":\"campus_anonymous\",\"params\":{},\"remark\":\"校园信息墙是否匿名\",\"status\":\"0\",\"updateTime\":\"2022-11-30 20:35:23\"},{\"createTime\":\"2022-12-04 21:16:00\",\"createUser\":1,\"dictId\":1599392072043900930,\"dictName\":\"校园内类型\",\"dictType\":\"campus_content_type\",\"params\":{},\"remark\":\"0文字,1图片,2视频\",\"status\":\"0\",\"updateTime\":\"2022-12-04 21:15:59\"}]}', 0, NULL, '2026-01-09 22:51:36');
INSERT INTO `sys_log_oper` VALUES (2009639460228055041, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', NULL, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 22:52:39');
INSERT INTO `sys_log_oper` VALUES (2009641299275259906, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 22:59:58');
INSERT INTO `sys_log_oper` VALUES (2009645708688355330, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 23:17:29');
INSERT INTO `sys_log_oper` VALUES (2009645717362176002, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 23:17:31');
INSERT INTO `sys_log_oper` VALUES (2009646293974118401, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 23:19:49');
INSERT INTO `sys_log_oper` VALUES (2009646847643217922, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 23:22:01');
INSERT INTO `sys_log_oper` VALUES (2009646870636392450, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 23:22:06');
INSERT INTO `sys_log_oper` VALUES (2009647265790160898, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 23:23:40');
INSERT INTO `sys_log_oper` VALUES (2009647365350354946, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 23:24:04');
INSERT INTO `sys_log_oper` VALUES (2009647372036075522, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.getDraft()', 'GET', 1, '/api/v1/forum/posts/draft', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200}', 0, NULL, '2026-01-09 23:24:06');
INSERT INTO `sys_log_oper` VALUES (2009647395951996929, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 23:24:11');
INSERT INTO `sys_log_oper` VALUES (2009647403103285250, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '', 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\r\n### The error may exist in file [E:\\wxxcx\\JingWenWall\\jingwenhub\\campus-modular\\target\\classes\\mapper\\ForumPostMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: SELECT count(0) FROM bus_forum_post p LEFT JOIN sys_user u ON p.user_id = u.user_id LEFT JOIN bus_category c ON p.category_id = c.category_id WHERE p.del_flag = 0 AND p.is_draft = 0 AND p.status = 0\r\n### Cause: java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Table \'jingwen_campus.bus_category\' doesn\'t exist', '2026-01-09 23:24:13');
INSERT INTO `sys_log_oper` VALUES (2009647907665448961, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":0,\"code\":200,\"rows\":[]}', 0, NULL, '2026-01-09 23:26:13');
INSERT INTO `sys_log_oper` VALUES (2009647950568984577, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 23:26:24');
INSERT INTO `sys_log_oper` VALUES (2009647961897799681, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":0,\"code\":200,\"rows\":[]}', 0, NULL, '2026-01-09 23:26:26');
INSERT INTO `sys_log_oper` VALUES (2009647968629657602, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":0,\"code\":200,\"rows\":[]}', 0, NULL, '2026-01-09 23:26:28');
INSERT INTO `sys_log_oper` VALUES (2009647981061574658, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.getDraft()', 'GET', 1, '/api/v1/forum/posts/draft', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200}', 0, NULL, '2026-01-09 23:26:31');
INSERT INTO `sys_log_oper` VALUES (2009648030340452354, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":0,\"code\":200,\"rows\":[]}', 0, NULL, '2026-01-09 23:26:43');
INSERT INTO `sys_log_oper` VALUES (2009648030663413762, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.saveDraft()', 'POST', 1, '/api/v1/forum/posts/draft', '127.0.0.1', '{\"content\":\"123\",\"isDraft\":1}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO bus_forum_post  ( post_id, user_id,   content,   is_draft,     status,   create_time, create_user,   del_flag )  VALUES  ( ?, ?,   ?,   ?,     ?,   ?, ?,   ? )\r\n### Cause: java.sql.SQLException: Field \'category_id\' doesn\'t have a default value\n; Field \'category_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'category_id\' doesn\'t have a default value', '2026-01-09 23:26:43');
INSERT INTO `sys_log_oper` VALUES (2009651218376302594, 'oddfar', 'API接口日志记录', '登录方法', 'com.oddfar.campus.admin.controller.system.SysLoginController.login()', 'POST', NULL, '/login', '127.0.0.1', '{\"code\":\"42\",\"username\":\"admin\",\"uuid\":\"eb16d4ad8d1b453fa3fd0e9713ef3fab\"}', '{\"msg\":\"success\",\"code\":200,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjA5YWJmYmJjLTdlMjgtNGUzZC04MzkxLTU3YWY3MmNhOWQ0MyJ9.ObakvsKgNztSpYZzOwC0bPkGLIGXLpXNd0ffBGi_jf7NwHw3l3VJRkG-vMMz39MSVW-N11KnqJSHeXmM38u9Dw\"}', 0, NULL, '2026-01-09 23:39:23');
INSERT INTO `sys_log_oper` VALUES (2009652413539049473, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":0,\"code\":200,\"rows\":[]}', 0, NULL, '2026-01-09 23:44:08');
INSERT INTO `sys_log_oper` VALUES (2009652433193558017, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":0,\"code\":200,\"rows\":[]}', 0, NULL, '2026-01-09 23:44:12');
INSERT INTO `sys_log_oper` VALUES (2009652445063438337, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 23:44:15');
INSERT INTO `sys_log_oper` VALUES (2009652449178050561, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":0,\"code\":200,\"rows\":[]}', 0, NULL, '2026-01-09 23:44:16');
INSERT INTO `sys_log_oper` VALUES (2009652827823038466, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:45:46');
INSERT INTO `sys_log_oper` VALUES (2009652836673019906, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:45:48');
INSERT INTO `sys_log_oper` VALUES (2009652843396489217, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:45:50');
INSERT INTO `sys_log_oper` VALUES (2009652897293295617, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:46:03');
INSERT INTO `sys_log_oper` VALUES (2009652903962238977, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:46:04');
INSERT INTO `sys_log_oper` VALUES (2009653167142232065, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:47:07');
INSERT INTO `sys_log_oper` VALUES (2009653176340340737, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 1, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"学生信息不存在\",\"code\":500}', 0, NULL, '2026-01-09 23:47:09');
INSERT INTO `sys_log_oper` VALUES (2009653187476217857, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:47:12');
INSERT INTO `sys_log_oper` VALUES (2009653380661682177, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 1, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":2,\"code\":200,\"rows\":[{\"address\":\"清华大学\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材，最好是最新版的，价格可议。有意请联系！\",\"createTime\":\"2026-01-09 23:45:43\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"postId\":1000000000000000002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:45:43\",\"userId\":2000000000000000000,\"viewCount\":3},{\"address\":\"北京市海淀区\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活的点点滴滴。\",\"createTime\":\"2026-01-09 23:45:28\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"postId\":1000000000000000001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:45:28\",\"userId\":2000000000000000000,\"viewCount\":1}]}', 0, NULL, '2026-01-09 23:47:58');
INSERT INTO `sys_log_oper` VALUES (2009655921277509633, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0a2zAc0w3sxKj63V251w34STrH3zAc0X\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImI5MTk2NWEzLWFjYTUtNGUyMC1hYTJiLWMzMDJlYjJjMWE1YiJ9.3JMzZxRT-4LWii6hubVwTKD7fiBUR7wc_e7SqVHnbom9MIUaL4rmGlTOagIRmbiibcCfG3n_TZ9iYTs2ZijcUA\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 23:58:04');
INSERT INTO `sys_log_oper` VALUES (2009655927602520066, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-09 23:58:05');
INSERT INTO `sys_log_oper` VALUES (2009655939216547842, 'campus', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.BusStudentController.getInfo()', 'GET', 2009598766385987585, '/student/get/info', '127.0.0.1', '{}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"balance\":0.00,\"createTime\":\"2026-01-09 20:10:57\",\"creditScore\":100,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"openid\":\"o0jpQ3RbbAwk86WaYUlnTJu2foN4\",\"phonenumber\":\"\",\"studentId\":6,\"updateTime\":\"2026-01-09 20:10:57\",\"userId\":2009598766385987585,\"userName\":\"wx_o0jpQ3RbbAwk86Wa\"}}', 0, NULL, '2026-01-09 23:58:08');
INSERT INTO `sys_log_oper` VALUES (2009655947324137473, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-09 23:58:10');
INSERT INTO `sys_log_oper` VALUES (2009655992043806722, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0b2kAc0w3NwKj63djX2w3Vhpe10kAc0O\"}', '', 1, 'ConnectException: Connection timed out: connect', '2026-01-09 23:58:21');
INSERT INTO `sys_log_oper` VALUES (2009656092153454593, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0c29Dc0w3hwKj63Pfi1w3oEJmy39Dc08\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjNlYjEzMWZkLTFlNzItNGI5My05ZjZhLTA4MmQ1NjBhMjY4YiJ9.NOiVhiYLzCE-yD2gA2xhHyNC7ztW-kchRwLSWePM3DNac8tAzrq56sI64D5nhNPTP8dd6v593oHjP-xgyfGBxg\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-09 23:58:45');
INSERT INTO `sys_log_oper` VALUES (2009656098251972609, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-09 23:58:46');
INSERT INTO `sys_log_oper` VALUES (2009656836902461441, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0b2OvTkl2Rn3Zg4cGEnl291SJp4OvTkb\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjA3YzgzNWExLWU1YzUtNGU3MS04YmJmLTRkMGE5ZDllYjg1YSJ9.zcRM2_17twyfoqj98Hwuf5W1scIHqyw0E-k6eD1iJjinBfDMy62OaOrsZkeCqF6FCyqI9P0I1Ly2mrI9LTdWbw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-10 00:01:42');
INSERT INTO `sys_log_oper` VALUES (2009656841604276225, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:01:43');
INSERT INTO `sys_log_oper` VALUES (2009657334988648449, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0a2hDTkl2Zq3Zg49x9ml2s2QCt0hDTkk\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjU0ZjE5OGRmLTg2ZWUtNGEyNy05MTgzLTVhZmQyZTY1NGI2MyJ9.2fITVtmKMQ3Ssr69AmOmwgiq_MfQP9ZYs9k-8mfdPsGKkMQsBdvRFZBjpXcAPr72UO1S4pZdafb_dFBhefdGwA\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-10 00:03:41');
INSERT INTO `sys_log_oper` VALUES (2009657335580045314, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:03:41');
INSERT INTO `sys_log_oper` VALUES (2009657341661786114, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:03:43');
INSERT INTO `sys_log_oper` VALUES (2009658009583726593, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0c2U2WZv3Jbyj63RgG1w3Y2de10U2WZM\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjhkMWZhZmYzLTAzNTAtNGM5OC05NWE3LTk1NWRkN2Q0MjA4ZCJ9.eBMKOHPqqurexgx5aIiMp00UT3zNJxZUnkYK4N476J-__2cXocpG-kbo3j0x_9HAet_-IRxxrEsyCX9gn1z0Yg\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-10 00:06:22');
INSERT INTO `sys_log_oper` VALUES (2009658009713750017, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:06:22');
INSERT INTO `sys_log_oper` VALUES (2009658012704288769, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:06:23');
INSERT INTO `sys_log_oper` VALUES (2009658627069161473, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0e2GTCkl2iWRYg47Hvnl2IyrDv2GTCka\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjZhM2QwNDUxLTExM2YtNDEwNS1iNDIwLTFkN2NkMTZlMzdlYiJ9.LCGHEwtWkYERtXRl04rK0Hnmo2hGVfOBEskQYRm6NTh4NegOoEOl_kHvELGHEcvY8OL1RHdnHExio-9S1GL7Cw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-10 00:08:49');
INSERT INTO `sys_log_oper` VALUES (2009658627585060866, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:08:49');
INSERT INTO `sys_log_oper` VALUES (2009658633037656066, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:08:50');
INSERT INTO `sys_log_oper` VALUES (2009659098945138690, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0e2L0Dkl2e5SYg4qtcll2FLKiG3L0DkQ\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImVmZTQwZDkyLWEzYTYtNDc2ZS04NmUxLWE1NWNhMzI2MzFmZSJ9.kiH-GMu-Z767B4b8phjSgUYpKIYOHofwOlOrPlf_Lcj6Ca7pFafDBxMGW1Jj-eAeF3w_HZUM_-8c3tNPXH9hEw\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-10 00:10:41');
INSERT INTO `sys_log_oper` VALUES (2009659099469426690, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:10:42');
INSERT INTO `sys_log_oper` VALUES (2009659104238350338, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:10:43');
INSERT INTO `sys_log_oper` VALUES (2009660234125127681, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.controller.web.WxAuthController.login()', 'POST', NULL, '/api/v1/wx/auth/login', '127.0.0.1', '{\"code\":\"0c2OhDkl21mRYg4p1Nnl2MMxYa4OhDkr\"}', '{\"msg\":\"success\",\"code\":200,\"data\":{\"avatar\":\"https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG\",\"creditScore\":100,\"isNewUser\":false,\"isRunner\":0,\"isVerified\":0,\"nickName\":\"微信用户\",\"phonenumber\":\"\",\"studentId\":6,\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjQyZTk4NDQ0LTEyM2MtNGYyYy04M2JiLTk5YjgxNDRkZTI0OCJ9.XIQBuoos5LeryTkfk61ObOgok30E-3c2yk8AQ02aBic7qYPZIv0AA6HO7HnqtAg5gYgjDV7CDWAF57jbKBYwww\",\"userId\":2009598766385987585}}', 0, NULL, '2026-01-10 00:15:12');
INSERT INTO `sys_log_oper` VALUES (2009660234703941634, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:15:12');
INSERT INTO `sys_log_oper` VALUES (2009660238696919041, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.newest()', 'GET', 2009598766385987585, '/api/v1/forum/posts/newest', '127.0.0.1', '{}', '{\"msg\":\"success\",\"total\":4,\"code\":200,\"rows\":[{\"address\":\"北京\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":0,\"commentCount\":0,\"content\":\"这是第一条测试帖子，欢迎大家在这里分享校园生活。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[\"https://picsum.photos/300/200\"],\"ip\":\"192.168.1.100\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":0,\"nickName\":\"致远\",\"postId\":3001,\"status\":0,\"title\":\"欢迎来到校园墙！\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":1},{\"address\":\"清华\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1002,\"categoryName\":\"学习交流\",\"collectCount\":1,\"commentCount\":1,\"content\":\"求购《数据结构与算法》教材。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.101\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":2,\"nickName\":\"致远\",\"postId\":3002,\"status\":0,\"title\":\"求购二手教材\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":3},{\"address\":\"北大\",\"avatar\":\"/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg\",\"categoryId\":1003,\"categoryName\":\"失物招领\",\"collectCount\":0,\"commentCount\":2,\"content\":\"我在自学Java，希望能找到一起学习的小伙伴。\",\"createTime\":\"2026-01-09 23:54:16\",\"images\":[],\"ip\":\"192.168.1.102\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":3,\"nickName\":\"致远\",\"postId\":3003,\"status\":0,\"title\":\"寻找学习伙伴\",\"updateTime\":\"2026-01-09 23:54:16\",\"userId\":2,\"viewCount\":5},{\"address\":\"校园\",\"avatar\":\"/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg\",\"categoryId\":1001,\"categoryName\":\"校园生活\",\"collectCount\":2,\"commentCount\":3,\"content\":\"这是管理员发布的测试帖子。\",\"createTime\":\"2026-01-09 23:53:28\",\"images\":[],\"ip\":\"192.168.1.1\",\"isAnonymous\":0,\"isCollected\":false,\"isDraft\":0,\"isLiked\":false,\"likeCount\":5,\"nickName\":\"admin\",\"postId\":3004,\"status\":0,\"title\":\"管理员的测试帖子\",\"updateTime\":\"2026-01-09 23:53:28\",\"userId\":1,\"viewCount\":10}]}', 0, NULL, '2026-01-10 00:15:13');
INSERT INTO `sys_log_oper` VALUES (2009660244149514242, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.like()', 'POST', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '3001', '{\"msg\":\"success\",\"code\":200}', 0, NULL, '2026-01-10 00:15:15');
INSERT INTO `sys_log_oper` VALUES (2009660251451797505, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '{\"msg\":\"success\",\"code\":200}', 0, NULL, '2026-01-10 00:15:16');
INSERT INTO `sys_log_oper` VALUES (2009660253918048257, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.like()', 'POST', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '3001', '{\"msg\":\"success\",\"code\":200}', 0, NULL, '2026-01-10 00:15:17');
INSERT INTO `sys_log_oper` VALUES (2009660256375910402, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:17');
INSERT INTO `sys_log_oper` VALUES (2009660264806461441, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:19');
INSERT INTO `sys_log_oper` VALUES (2009660269151760386, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:20');
INSERT INTO `sys_log_oper` VALUES (2009660271521542146, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:21');
INSERT INTO `sys_log_oper` VALUES (2009660272440094722, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:21');
INSERT INTO `sys_log_oper` VALUES (2009660273224429569, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:21');
INSERT INTO `sys_log_oper` VALUES (2009660274067484674, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:22');
INSERT INTO `sys_log_oper` VALUES (2009660274851819521, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:22');
INSERT INTO `sys_log_oper` VALUES (2009660275720040450, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:22');
INSERT INTO `sys_log_oper` VALUES (2009660276508569601, 'oddfar', 'API接口日志记录', '', 'com.oddfar.campus.business.forum.controller.ForumPostController.unlike()', 'DELETE', 2009598766385987585, '/api/v1/forum/posts/3001/like', '127.0.0.1', '{postId=3001}', '', 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\r\n### The error may exist in com/oddfar/campus/business/forum/mapper/ForumPostLikeMapper.java (best guess)\r\n### The error may involve com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper.delete-Inline\r\n### The error occurred while setting parameters\r\n### SQL: UPDATE bus_forum_post_like SET del_flag=1   WHERE  del_flag=0  AND (user_id = ? AND post_id = ?)\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'\n; Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'3001-2009598766385987585-\\x01\' for key \'bus_forum_post_like.uk_post_user\'', '2026-01-10 00:15:22');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '路由参数',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '备注',
  `del_flag` bit(1) NULL DEFAULT NULL COMMENT '逻辑删除(1:已删除，0:未删除)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建者',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1597931148678365187 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', 1, 0, 'M', '0', '0', '', 'system', '系统管理目录', b'0', '2022-10-05 15:28:43', 1, '2022-11-14 14:41:50', NULL);
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', 1, 0, 'M', '0', '0', '', 'monitor', '系统监控目录', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', 1, 0, 'M', '0', '0', '', 'tool', '系统工具目录', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (4, '源码地址', 0, 10, 'https://github.com/oddfar/campus-example', NULL, '', 0, 0, 'M', '0', '0', '', 'guide', '若依官网地址', b'0', '2022-10-05 15:28:43', 1, '2022-11-21 17:11:40', NULL);
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', '用户管理菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', '角色管理菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', '菜单管理菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', '部门管理菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', '岗位管理菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', '字典管理菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', '参数设置菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', '通知公告菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', 1, 0, 'M', '0', '0', '', 'log', '日志管理菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', '在线用户菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', '定时任务菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', '数据监控菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', '服务监控菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', '缓存监控菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', '缓存列表菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', '表单构建菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', '代码生成菜单', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', '系统接口菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', '操作日志菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', '登录日志菜单', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', '', b'0', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', '', b'1', '2022-10-05 15:28:43', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1597918884311171073, '校园信息墙', 0, 5, 'campus', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'education', '', b'0', '2022-11-30 19:42:05', NULL, '2022-11-30 19:42:04', 1);
INSERT INTO `sys_menu` VALUES (1597929330846040066, '内容管理', 1597918884311171073, 2, 'content', 'campus/content/index', NULL, 1, 0, 'C', '0', '0', 'campus:content:list', 'content', '', b'0', '2022-11-30 20:23:35', 1, '2022-11-30 20:23:35', 1);
INSERT INTO `sys_menu` VALUES (1597930331497922562, '评论管理', 1597918884311171073, 6, 'comment', 'campus/comment/index', NULL, 1, 0, 'C', '0', '0', 'campus:comment:list', 'comment', '', b'0', '2022-11-30 20:27:34', 1, '2022-11-30 20:27:33', 1);
INSERT INTO `sys_menu` VALUES (1597930928431267841, '类别管理', 1597918884311171073, 3, 'category', 'campus/category/index', NULL, 1, 0, 'C', '0', '0', 'campus:category:list', 'category', '', b'0', '2022-11-30 20:29:56', 1, '2022-11-30 20:29:56', 1);
INSERT INTO `sys_menu` VALUES (1597931148678365186, '标签管理', 1597918884311171073, 4, 'tag', 'campus/tag/index', NULL, 1, 0, 'C', '0', '0', 'campus:tag:list', 'tag', '', b'0', '2022-11-30 20:30:49', 1, '2022-11-30 20:30:48', 1);

-- ----------------------------
-- Table structure for sys_resource
-- ----------------------------
DROP TABLE IF EXISTS `sys_resource`;
CREATE TABLE `sys_resource`  (
  `resource_id` bigint NOT NULL COMMENT '资源id',
  `app_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '应用编码',
  `resource_code` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '资源编码',
  `resource_name` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '资源名称',
  `class_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '类名称',
  `method_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '方法名称',
  `modular_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '资源模块名称，一般为控制器名称',
  `url` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '资源url',
  `http_method` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'http请求方法',
  `resource_biz_type` tinyint NULL DEFAULT 1 COMMENT '资源的业务类型：1-业务类，2-系统类',
  `required_permission_flag` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否需要鉴权：Y-是，N-否',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`resource_id`) USING BTREE,
  INDEX `RESOURCE_CODE_URL`(`resource_code` ASC, `url` ASC) USING BTREE COMMENT '资源code和url的联合索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '需要认证的接口资源controller' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_resource
-- ----------------------------
INSERT INTO `sys_resource` VALUES (2009657309504057345, 'oddfar', 'oddfar.sys_dict_type.edit', '字典类型管理-修改', 'SysDictTypeController', 'edit', '字典类型管理', '/system/dict/type', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309504057346, 'campus', 'campus.bus_student.update_info', 'updateInfo', 'BusStudentController', 'updateInfo', '学生信息管理', '/student/update/info', 'put', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309504057347, 'campus', 'campus.comment.list', 'list', 'CommentController', 'list', '评论管理', '/admin/comment/list', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309504057348, 'oddfar', 'oddfar.sys_dict_type.optionselect', '字典类型管理-获取字典选择框列表', 'SysDictTypeController', 'optionselect', '字典类型管理', '/system/dict/type/optionselect', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309504057349, 'campus', 'campus.category.edit', '修改分类', 'CategoryController', 'edit', '分类管理', '/admin/category', 'put', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309504057350, 'oddfar', 'oddfar.sys_login.get_routers', '获取路由信息', 'SysLoginController', 'getRouters', '登录路由', '/getRouters', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000386, 'oddfar', 'oddfar.sys_menu.tree_select', '菜单管理-获取菜单下拉树列表', 'SysMenuController', 'treeSelect', '菜单管理', '/system/menu/treeselect', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000387, 'campus', 'campus.user_action.image_upload', '图片文件上传', 'UserActionController', 'imageUpload', '用户操作api', '/campus/imageUpload', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000388, 'oddfar', 'oddfar.sys_role.remove', 'remove', 'SysRoleController', 'remove', '角色管理', '/system/role/{roleIds}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000389, 'campus', 'campus.bus_student.get_info', 'getInfo', 'BusStudentController', 'getInfo', '学生信息管理', '/student/get/info', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000390, 'oddfar', 'oddfar.sys_menu.role_menu_treeselect', '菜单管理-加载对应角色菜单列表树', 'SysMenuController', 'roleMenuTreeselect', '菜单管理', '/system/menu/roleMenuTreeselect/{roleId}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000391, 'oddfar', 'oddfar.sys_profile.update_profile', '个人信息管理-修改', 'SysProfileController', 'updateProfile', '个人信息管理', '/system/user/profile', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000392, 'campus', 'campus.user_account.send_reset_pwd_code', 'sendResetPwdCode', 'UserAccountController', 'sendResetPwdCode', '用户账户操作api', '/campus/pwd-code', 'post', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000393, 'oddfar', 'oddfar.sys_role.add', 'add', 'SysRoleController', 'add', '角色管理', '/system/role', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000394, 'campus', 'campus.comment_info.to_comment', '添加评论', 'CommentInfoController', 'toComment', '评论api', '/campus/toComment', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000395, 'oddfar', 'oddfar.sys_login.login', '登录方法', 'SysLoginController', 'login', '登录路由', '/login', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000396, 'oddfar', 'oddfar.sys_role.get_info', 'getInfo', 'SysRoleController', 'getInfo', '角色管理', '/system/role/{roleId}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000397, 'oddfar', 'oddfar.sys_user.auth_role', 'authRole', 'SysUserController', 'authRole', '用户管理', '/system/user/authRole/{userId}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000398, 'oddfar', 'oddfar.sys_config.edit', '参数配置管理-修改', 'SysConfigController', 'edit', '参数配置管理', '/system/config', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000399, 'oddfar', 'oddfar.sys_menu.edit', '菜单管理-修改', 'SysMenuController', 'edit', '菜单管理', '/system/menu', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000400, 'campus', 'campus.content.page', '分页', 'ContentController', 'page', '内容管理', '/admin/content/list', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000401, 'oddfar', 'oddfar.sys_user.insert_auth_role', 'insertAuthRole', 'SysUserController', 'insertAuthRole', '用户管理', '/system/user/authRole', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000402, 'oddfar', 'oddfar.sys_logininfor.list', '登录日志-分类列表', 'SysLogininforController', 'list', '登录日志管理', '/monitor/logininfor/list', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000403, 'oddfar', 'oddfar.sys_config.refresh_cache', '参数配置管理-刷新缓存', 'SysConfigController', 'refreshCache', '参数配置管理', '/system/config/refreshCache', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000404, 'oddfar', 'oddfar.sys_role.cancel_auth_user_all', 'cancelAuthUserAll', 'SysRoleController', 'cancelAuthUserAll', '角色管理', '/system/role/authUser/cancelAll', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000405, 'oddfar', 'oddfar.sys_operlog.clean', '操作日志-清空', 'SysOperlogController', 'clean', '操作日志管理', '/monitor/operlog/clean', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000406, 'oddfar', 'oddfar.sys_dict_type.get_info', '字典类型管理-查询', 'SysDictTypeController', 'getInfo', '字典类型管理', '/system/dict/type/{dictId}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000407, 'oddfar', 'oddfar.sys_user.update', 'update', 'SysUserController', 'update', '用户管理', '/system/user', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000408, 'oddfar', 'oddfar.sys_api_resource.edit_role_resource', '修改对应角色api资源', 'SysApiResourceController', 'editRoleResource', '资源管理', '/system/resource/roleApi', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309546000409, 'oddfar', 'oddfar.sys_role.unallocated_list', 'unallocatedList', 'SysRoleController', 'unallocatedList', '角色管理', '/system/role/authUser/unallocatedList', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914946, 'oddfar', 'oddfar.sys_logininfor.clean', '登录日志-清空', 'SysLogininforController', 'clean', '登录日志管理', '/monitor/logininfor/clean', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914947, 'campus', 'campus.campus_info.category_list', '查询分类列表', 'CampusInfoController', 'categoryList', '校园墙信息api', '/campus/categoryList', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914948, 'campus', 'campus.content_info.del_content', '删除自己的校园墙', 'ContentInfoController', 'delContent', '信息墙api', '/campus/delContent/{contentId}', 'delete', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914949, 'oddfar', 'oddfar.sys_role.change_status', 'changeStatus', 'SysRoleController', 'changeStatus', '角色管理', '/system/role/changeStatus', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914950, 'oddfar', 'oddfar.sys_logininfor.remove', '登录日志-删除', 'SysLogininforController', 'remove', '登录日志管理', '/monitor/logininfor/{infoIds}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914951, 'campus', 'campus.tag.add', 'add', 'TagController', 'add', '标签管理', '/admin/tag', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914952, 'campus', 'campus.comment_info.get_comment', '添加评论', 'CommentInfoController', 'getComment', '评论api', '/campus/getComment', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914953, 'oddfar', 'oddfar.sys_dict_data.remove', '字典数据管理-删除', 'SysDictDataController', 'remove', '字典数据管理', '/system/dict/data/{dictCodes}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914954, 'campus', 'campus.content_info.get_content_by_id', '查询信息墙详细内容', 'ContentInfoController', 'getContentById', '信息墙api', '/campus/getContent', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914955, 'oddfar', 'oddfar.sys_dict_data.get_info', '字典数据管理-查询', 'SysDictDataController', 'getInfo', '字典数据管理', '/system/dict/data/{dictCode}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914956, 'campus', 'campus.content_info.get_own_love_content', '查询点赞的信息墙列表', 'ContentInfoController', 'getOwnLoveContent', '信息墙api', '/campus/getOwnLoveContent', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914957, 'campus', 'campus.comment.add', 'add', 'CommentController', 'add', '评论管理', '/admin/comment', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914958, 'campus', 'campus.tag.list', 'list', 'TagController', 'list', '标签管理', '/admin/tag/list', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914959, 'oddfar', 'oddfar.sys_login.get_info', '获取用户信息', 'SysLoginController', 'getInfo', '登录路由', '/getInfo', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914960, 'campus', 'campus.content.get_info', '获取校园墙内容', 'ContentController', 'getInfo', '内容管理', '/admin/content/{contentId}', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914961, 'oddfar', 'oddfar.sys_user.reset_pwd', 'resetPwd', 'SysUserController', 'resetPwd', '用户管理', '/system/user/resetPwd', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914962, 'oddfar', 'oddfar.sys_menu.get_info', '菜单管理-查询', 'SysMenuController', 'getInfo', '菜单管理', '/system/menu/{menuId}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914963, 'oddfar', 'oddfar.sys_role.cancel_auth_user', 'cancelAuthUser', 'SysRoleController', 'cancelAuthUser', '角色管理', '/system/role/authUser/cancel', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914964, 'oddfar', 'oddfar.sys_menu.remove', '菜单管理-删除', 'SysMenuController', 'remove', '菜单管理', '/system/menu/{menuId}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914965, 'oddfar', 'oddfar.sys_role.list', 'list', 'SysRoleController', 'list', '角色管理', '/system/role/list', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914966, 'oddfar', 'oddfar.sys_dict_type.refresh_cache', '字典类型管理-刷新', 'SysDictTypeController', 'refreshCache', '字典类型管理', '/system/dict/type/refreshCache', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914967, 'oddfar', 'oddfar.sys_menu.add', '菜单管理-新增', 'SysMenuController', 'add', '菜单管理', '/system/menu', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914968, 'oddfar', 'oddfar.sys_user.page', 'page', 'SysUserController', 'page', '用户管理', '/system/user/list', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914969, 'oddfar', 'oddfar.sys_role.allocated_list', 'allocatedList', 'SysRoleController', 'allocatedList', '角色管理', '/system/role/authUser/allocatedList', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914970, 'campus', 'campus.tag.remove', 'remove', 'TagController', 'remove', '标签管理', '/admin/tag/{tagIds}', 'delete', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914971, 'oddfar', 'oddfar.sys_dict_data.edit', '字典数据管理-修改', 'SysDictDataController', 'edit', '字典数据管理', '/system/dict/data', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914972, 'campus', 'campus.category.remove', '删除分类', 'CategoryController', 'remove', '分类管理', '/admin/category/{categoryId}', 'delete', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914973, 'campus', 'campus.user_account.send_mail', 'sendMail', 'UserAccountController', 'sendMail', '用户账户操作api', '/campus/bindMail', 'post', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914974, 'oddfar', 'oddfar.sys_operlog.list', '操作日志-分页', 'SysOperlogController', 'list', '操作日志管理', '/monitor/operlog/list', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914975, 'campus', 'campus.category.add', '新增分类', 'CategoryController', 'add', '分类管理', '/admin/category', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914976, 'oddfar', 'oddfar.sys_role.select_auth_user_all', 'selectAuthUserAll', 'SysRoleController', 'selectAuthUserAll', '角色管理', '/system/role/authUser/selectAll', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914977, 'oddfar', 'oddfar.sys_config.add', '参数配置管理-新增', 'SysConfigController', 'add', '参数配置管理', '/system/config', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309608914978, 'oddfar', 'oddfar.sys_dict_type.remove', '字典类型管理-删除', 'SysDictTypeController', 'remove', '字典类型管理', '/system/dict/type/{dictIds}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023809, 'campus', 'campus.comment_info.get_comment_children_list', '查询一级评论的子评论', 'CommentInfoController', 'getCommentChildrenList', '评论api', '/campus/getCommentChildrenList', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023810, 'campus', 'campus.content.remove', '删除校园墙内容', 'ContentController', 'remove', '内容管理', '/admin/content/{contentIds}', 'delete', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023811, 'oddfar', 'oddfar.sys_config.get_info', '参数配置管理-查询id信息', 'SysConfigController', 'getInfo', '参数配置管理', '/system/config/{id}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023812, 'oddfar', 'oddfar.sys_config.remove', '参数配置管理-删除', 'SysConfigController', 'remove', '参数配置管理', '/system/config/{configIds}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023813, 'campus', 'campus.comment_info.get_own_comment_list', '分页查询自己发布或回复的评论列表', 'CommentInfoController', 'getOwnCommentList', '评论api', '/campus/getOwnComment', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023814, 'campus', 'campus.content.edit', '修改信息墙内容', 'ContentController', 'edit', '内容管理', '/admin/content/', 'put', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023815, 'oddfar', 'oddfar.sys_dict_data.add', '字典数据管理-新增', 'SysDictDataController', 'add', '字典数据管理', '/system/dict/data', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023816, 'campus', 'campus.content_info.own_contents', '查看自己的单个信息墙', 'ContentInfoController', 'ownContents', '信息墙api', '/campus/ownContents', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023817, 'oddfar', 'oddfar.sys_dict_data.dict_type', '字典数据管理-根据字典类型查询字典数据信息', 'SysDictDataController', 'dictType', '字典数据管理', '/system/dict/data/type/{dictType}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023818, 'oddfar', 'oddfar.sys_profile.avatar', '个人信息管理-头像上次', 'SysProfileController', 'avatar', '个人信息管理', '/system/user/profile/avatar', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023819, 'oddfar', 'oddfar.sys_config.get_config_key', 'getConfigKey', 'SysConfigController', 'getConfigKey', '参数配置管理', '/system/config/configKey/{configKey:.+}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023820, 'campus', 'campus.category.list', '查询分类列表', 'CategoryController', 'list', '分类管理', '/admin/category/list', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023821, 'oddfar', 'oddfar.sys_user.get_info', 'getInfo', 'SysUserController', 'getInfo', '用户管理', '/system/user/{userId}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023822, 'campus', 'campus.comment.edit', 'edit', 'CommentController', 'edit', '评论管理', '/admin/comment', 'put', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023823, 'campus', 'campus.comment_info.get_one_level_comment', '查询一级评论', 'CommentInfoController', 'getOneLevelComment', '评论api', '/campus/getOneLevelComment', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023824, 'campus', 'campus.user_account.change_pwd', 'changePwd', 'UserAccountController', 'changePwd', '用户账户操作api', '/campus/changePwd', 'post', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023825, 'oddfar', 'oddfar.sys_config.page', '参数配置管理-分页', 'SysConfigController', 'page', '参数配置管理', '/system/config/page', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023826, 'campus', 'campus.comment_info.get_comment_children', '分页查询一级评论的子评论', 'CommentInfoController', 'getCommentChildren', '评论api', '/campus/getCommentChildren', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023827, 'campus', 'campus.comment_info.del_own_comment', '删除自己的评论', 'CommentInfoController', 'delOwnComment', '评论api', '/campus/delOwnComment', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023828, 'oddfar', 'oddfar.sys_menu.list', '菜单管理-分页', 'SysMenuController', 'list', '菜单管理', '/system/menu/list', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023829, 'campus', 'campus.user_action.zan_content', '点赞', 'UserActionController', 'zanContent', '用户操作api', '/campus/zan/{contentId}', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023830, 'oddfar', 'oddfar.sys_dict_type.list', '字典类型管理-分页', 'SysDictTypeController', 'list', '字典类型管理', '/system/dict/type/list', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023831, 'campus', 'campus.content_info.get_content_list', '查询信息墙内容列表', 'ContentInfoController', 'getContentList', '信息墙api', '/campus/contentList', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023832, 'oddfar', 'oddfar.sys_profile.update_pwd', '个人信息管理-重置密码', 'SysProfileController', 'updatePwd', '个人信息管理', '/system/user/profile/updatePwd', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023833, 'oddfar', 'oddfar.sys_user.remove', 'remove', 'SysUserController', 'remove', '用户管理', '/system/user/{userIds}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023834, 'campus', 'campus.user_account.email_validate', 'emailValidate', 'UserAccountController', 'emailValidate', '用户账户操作api', '/campus/email-validate', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023835, 'campus', 'campus.user_account.have_mail', 'haveMail', 'UserAccountController', 'haveMail', '用户账户操作api', '/campus/haveMail', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023836, 'campus', 'campus.content_info.to_content', '发表信息墙', 'ContentInfoController', 'toContent', '信息墙api', '/campus/sendContent', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023837, 'campus', 'campus.content_info.get_simple_hot_content', '查询信息墙内容列表', 'ContentInfoController', 'getSimpleHotContent', '信息墙api', '/campus/simpleHotContent', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023838, 'oddfar', 'oddfar.sys_user.add', 'add', 'SysUserController', 'add', '用户管理', '/system/user', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023839, 'campus', 'campus.category.list_select', '查询分类列表选择器', 'CategoryController', 'listSelect', '分类管理', '/admin/category/listSelect', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023840, 'campus', 'campus.user_action.video_upload', '视频文件上传', 'UserActionController', 'videoUpload', '用户操作api', '/campus/videoUpload', 'post', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023841, 'oddfar', 'oddfar.sys_user.change_status', 'changeStatus', 'SysUserController', 'changeStatus', '用户管理', '/system/user/changeStatus', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023842, 'oddfar', 'oddfar.sys_dict_data.page', '字典数据管理-分页', 'SysDictDataController', 'page', '字典数据管理', '/system/dict/data/list', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023843, 'campus', 'campus.campus_info.category_children', '查询分类子列表', 'CampusInfoController', 'categoryChildren', '校园墙信息api', '/campus/categoryChildren/{categoryId}', 'get', 1, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023844, 'campus', 'campus.category.get_info', '获取分类详细信息', 'CategoryController', 'getInfo', '分类管理', '/admin/category/{categoryId}', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023845, 'oddfar', 'oddfar.sys_operlog.remove', '操作日志-删除', 'SysOperlogController', 'remove', '操作日志管理', '/monitor/operlog/{operIds}', 'delete', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023846, 'campus', 'campus.comment.get_info', 'getInfo', 'CommentController', 'getInfo', '评论管理', '/admin/comment/{commentId}', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023847, 'oddfar', 'oddfar.sys_api_resource.role_menu_tree_select', '资源管理-加载对应角色资源列表树', 'SysApiResourceController', 'roleMenuTreeSelect', '资源管理', '/system/resource/roleApiTreeselect/{roleId}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023848, 'oddfar', 'oddfar.sys_profile.profile', '个人信息管理-查询', 'SysProfileController', 'profile', '个人信息管理', '/system/user/profile', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023849, 'oddfar', 'oddfar.sys_logininfor.unlock', '登录日志-解锁', 'SysLogininforController', 'unlock', '登录日志管理', '/monitor/logininfor/unlock/{userName}', 'get', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023850, 'oddfar', 'oddfar.sys_dict_type.add', '字典类型管理-新增', 'SysDictTypeController', 'add', '字典类型管理', '/system/dict/type', 'post', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309676023851, 'campus', 'campus.tag.get_info', 'getInfo', 'TagController', 'getInfo', '标签管理', '/admin/tag/{tagId}', 'get', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309743132673, 'campus', 'campus.tag.edit', 'edit', 'TagController', 'edit', '标签管理', '/admin/tag', 'put', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309743132674, 'campus', 'campus.comment.remove', 'remove', 'CommentController', 'remove', '评论管理', '/admin/comment/{commentIds}', 'delete', 1, 'Y', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');
INSERT INTO `sys_resource` VALUES (2009657309743132675, 'oddfar', 'oddfar.sys_role.edit', 'edit', 'SysRoleController', 'edit', '角色管理', '/system/role', 'put', 2, 'N', b'0', NULL, '2026-01-10 00:03:35', NULL, '2026-01-10 00:03:34');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `del_flag` bit(1) NULL DEFAULT b'0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1628997651572027395 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, 1, '0', '超级管理员', b'0', NULL, '2022-10-05 15:28:43', NULL, NULL);
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, 1, '0', '普通角色', b'0', NULL, '2022-10-05 15:28:43', 1, '2022-12-19 22:13:17');
INSERT INTO `sys_role` VALUES (1594285449147330561, '普通用户', 'campus:common', 0, 1, '0', NULL, b'0', 1, '2022-11-20 19:04:06', 1, '2023-02-24 13:14:02');
INSERT INTO `sys_role` VALUES (1628997165540274178, '审核员', 'campus:auditor', 0, 1, '0', '审核信息墙内容，可以修改信息墙内容', b'0', 1, '2023-02-24 13:56:04', 1, '2023-02-24 14:11:29');
INSERT INTO `sys_role` VALUES (1628997651572027394, '浏览用户', 'campus:glance', 0, 1, '0', '只可浏览信息墙，点赞信息墙，不可发表墙和评论', b'0', 1, '2023-02-24 13:58:00', 1, '2023-02-24 14:10:46');

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1597918884311171073);
INSERT INTO `sys_role_menu` VALUES (2, 1597929330846040066);
INSERT INTO `sys_role_menu` VALUES (2, 1597930331497922562);
INSERT INTO `sys_role_menu` VALUES (2, 1597930928431267841);
INSERT INTO `sys_role_menu` VALUES (2, 1597931148678365186);
INSERT INTO `sys_role_menu` VALUES (1594285449147330561, 4);
INSERT INTO `sys_role_menu` VALUES (1628997165540274178, 1597918884311171073);
INSERT INTO `sys_role_menu` VALUES (1628997165540274178, 1597929330846040066);

-- ----------------------------
-- Table structure for sys_role_resource
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_resource`;
CREATE TABLE `sys_role_resource`  (
  `resource_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '资源编码',
  `role_id` bigint NOT NULL COMMENT '角色id',
  PRIMARY KEY (`role_id`, `resource_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '角色资源关联' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_resource
-- ----------------------------
INSERT INTO `sys_role_resource` VALUES ('campus.comment_info.del_own_comment', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.comment_info.get_own_comment_list', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.comment_info.to_comment', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.content_info.del_content', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.content_info.get_own_love_content', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.content_info.own_contents', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.content_info.to_content', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.user_action.image_upload', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.user_action.video_upload', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.user_action.zan_content', 1594285449147330561);
INSERT INTO `sys_role_resource` VALUES ('campus.content.edit', 1628997165540274178);
INSERT INTO `sys_role_resource` VALUES ('campus.content.get_info', 1628997165540274178);
INSERT INTO `sys_role_resource` VALUES ('campus.content.page', 1628997165540274178);
INSERT INTO `sys_role_resource` VALUES ('campus.content.remove', 1628997165540274178);
INSERT INTO `sys_role_resource` VALUES ('campus.content_info.del_content', 1628997651572027394);
INSERT INTO `sys_role_resource` VALUES ('campus.content_info.get_own_love_content', 1628997651572027394);
INSERT INTO `sys_role_resource` VALUES ('campus.content_info.own_contents', 1628997651572027394);
INSERT INTO `sys_role_resource` VALUES ('campus.user_action.zan_content', 1628997651572027394);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `user_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `login_ip` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `del_flag` bit(1) NULL DEFAULT NULL COMMENT '逻辑删除(1:已删除，0:未删除)',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2009598766385987586 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', 'admin', '00', 'oddfar@163.com', '15888888888', '0', '/profile/avatar/2023/05/10/blob_20230510172840A002.jpeg', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '127.0.0.1', '2026-01-09 23:39:23', '管理员', 0, '2022-10-05 15:28:43', 1, '2026-01-09 23:39:23', b'0');
INSERT INTO `sys_user` VALUES (2, 'zhiyuan', '致远', '00', 'a_zhiyuan@163.com', '15666666666', '1', '/profile/avatar/2023/07/01/blob_20230701101949A001.jpeg', '$2a$10$CgOz7rzHEqUDjPO9h6N0Y.ecwB.1HpIXx4UC9DwZU.NY9zyMJ/meS', '0', '127.0.0.1', '2023-12-25 00:23:54', '测试', 0, '2022-10-05 15:28:43', NULL, '2023-12-25 00:23:54', b'0');
INSERT INTO `sys_user` VALUES (2000000000000000001, 'test_user', '测试用户', '00', 'test@example.com', '13800138000', '0', '', '123456', '0', '', NULL, NULL, NULL, '2026-01-09 23:45:04', NULL, NULL, NULL);
INSERT INTO `sys_user` VALUES (2009598766385987585, 'wx_o0jpQ3RbbAwk86Wa', '微信用户', '00', '', '', '0', 'https://img0.baidu.com/it/u=1183896628,1403534286&fm=253&fmt=auto&app=138&f=PNG', '$2a$10$k8EbUy8HEmahCd/.5vxpvOmZ3wBmRCn1l92/.wBlSnuKK5PhmyXie', '0', '', '2026-01-10 00:15:12', NULL, NULL, '2026-01-09 20:10:57', NULL, '2026-01-10 00:15:12', b'0');

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);
INSERT INTO `sys_user_role` VALUES (2, 1594285449147330561);

SET FOREIGN_KEY_CHECKS = 1;
