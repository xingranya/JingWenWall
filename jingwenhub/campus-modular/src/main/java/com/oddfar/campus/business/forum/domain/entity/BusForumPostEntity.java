package com.oddfar.campus.business.forum.domain.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.oddfar.campus.common.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

/**
 * 贴吧帖子实体
 */
@Data
@TableName(value = "bus_forum_post", autoResultMap = true)
@EqualsAndHashCode(callSuper = true)
public class BusForumPostEntity extends BaseEntity {
    
    @TableId(value = "post_id", type = IdType.ASSIGN_ID)
    private Long postId;
    
    private Long userId;
    
    private Long categoryId;
    
    private String title;
    
    private String content;
    
    /** JSON 数组存储图片 URL */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> images;
    
    private Integer isAnonymous;
    
    private Integer isDraft;
    
    private Integer viewCount;
    
    private Integer likeCount;
    
    private Integer commentCount;
    
    private Integer collectCount;
    
    private Integer status;
    
    private String ip;
    
    private String address;
    
    // ========== 非数据库字段 ==========
    
    /** 发布者昵称 */
    @TableField(exist = false)
    private String nickName;
    
    /** 发布者头像 */
    @TableField(exist = false)
    private String avatar;
    
    /** 当前用户是否点赞 */
    @TableField(exist = false)
    private Boolean isLiked;
    
    /** 当前用户是否收藏 */
    @TableField(exist = false)
    private Boolean isCollected;
    
    /** 分类名称 */
    @TableField(exist = false)
    private String categoryName;
}
