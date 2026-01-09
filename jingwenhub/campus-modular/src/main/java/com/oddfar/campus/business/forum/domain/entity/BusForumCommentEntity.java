package com.oddfar.campus.business.forum.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.oddfar.campus.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 贴吧评论实体
 */
@Data
@TableName("bus_forum_comment")
@EqualsAndHashCode(callSuper = true)
public class BusForumCommentEntity extends BaseEntity {
    
    @TableId(value = "comment_id", type = IdType.ASSIGN_ID)
    private Long commentId;
    
    /** 帖子ID */
    private Long postId;
    
    /** 评论用户ID */
    private Long userId;
    
    /** 父评论ID (0表示一级评论) */
    private Long parentId;
    
    /** 回复目标用户ID (二级评论时使用) */
    private Long toUserId;
    
    /** 评论内容 */
    private String content;
    
    /** 点赞数 */
    private Integer likeCount;
    
    /** 状态 (0-正常, 1-禁用) */
    private Integer status;
    
    // ========== 非数据库字段 ==========
    
    /** 评论者昵称 */
    @TableField(exist = false)
    private String nickName;
    
    /** 评论者头像 */
    @TableField(exist = false)
    private String avatar;
    
    /** 回复目标用户昵称 */
    @TableField(exist = false)
    private String toUserNickName;
    
    /** 当前用户是否点赞 */
    @TableField(exist = false)
    private Boolean isLiked;
}
