package com.oddfar.campus.business.forum.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 评论点赞实体
 */
@Data
@TableName("bus_forum_comment_like")
public class BusForumCommentLikeEntity implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @TableId(value = "like_id", type = IdType.ASSIGN_ID)
    private Long likeId;
    
    private Long commentId;
    
    private Long userId;
    
    @TableField(fill = FieldFill.INSERT)
    private Date createTime;
    
    @TableLogic
    @TableField(fill = FieldFill.INSERT)
    private Integer delFlag;
}
