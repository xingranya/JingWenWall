-- 二手商品收藏表（补充）
-- 执行此SQL添加缺失的表

-- ----------------------------
-- Table structure for bus_market_collect
-- ----------------------------
DROP TABLE IF EXISTS `bus_market_collect`;
CREATE TABLE `bus_market_collect` (
  `collect_id` bigint NOT NULL COMMENT '收藏ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `item_id` bigint NOT NULL COMMENT '商品ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `del_flag` int NULL DEFAULT 0 COMMENT '删除标志(0-未删除, 1-已删除)',
  PRIMARY KEY (`collect_id`) USING BTREE,
  UNIQUE INDEX `uk_user_item`(`user_id` ASC, `item_id` ASC) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品收藏表' ROW_FORMAT = Dynamic;
