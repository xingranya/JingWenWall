package com.oddfar.campus.business.forum.domain.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.oddfar.campus.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 帖子收藏实体
 */
@Data
@TableName("bus_forum_post_collect")
@EqualsAndHashCode(callSuper = true)
public class BusForumPostCollectEntity extends BaseEntity {
    
    @TableId(value = "collect_id", type = IdType.ASSIGN_ID)
    private Long collectId;
    
    private Long postId;
    
    private Long userId;
}
