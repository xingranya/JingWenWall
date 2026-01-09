package com.oddfar.campus.business.forum.domain.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.oddfar.campus.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 帖子点赞实体
 */
@Data
@TableName("bus_forum_post_like")
@EqualsAndHashCode(callSuper = true)
public class BusForumPostLikeEntity extends BaseEntity {
    
    @TableId(value = "like_id", type = IdType.ASSIGN_ID)
    private Long likeId;
    
    private Long postId;
    
    private Long userId;
}
