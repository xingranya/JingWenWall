package com.oddfar.campus.business.forum.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 贴吧评论实体
 */
@Data
@TableName("bus_forum_comment")
public class BusForumCommentEntity implements Serializable {
    
    private static final long serialVersionUID = 1L;

    @TableId(value = "comment_id", type = IdType.ASSIGN_ID)
    private Long commentId;
    
    /** 帖子ID */
    private Long postId;
    
    /** 评论用户ID */
    private Long userId;
    
    /** 父评论ID (0表示一级评论) */
    private Long parentId;
    
    /** 根评论ID (用于聚合显示) */
    private Long rootId;

    /** 回复目标用户ID (二级评论时使用) */
    private Long toUserId;
    
    /** 评论内容 */
    private String content;
    
    /** 点赞数 */
    private Integer likeCount;
    
    /** IP地址 */
    private String ip;
    
    /** 地理位置 */
    private String address;
    
    /** 状态 (0-正常, 1-禁用) */
    private Integer status;

    /** 删除标志 (0-正常, 1-删除) */
    @TableLogic
    private Integer delFlag;

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;

    /** 更新时间 */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;
    
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
