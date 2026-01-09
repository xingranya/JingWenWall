package com.oddfar.campus.business.forum.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;
import java.util.List;

/**
 * 帖子视图对象
 */
@Data
public class ForumPostVO {
    
    /** 帖子ID */
    private Long postId;
    
    /** 用户ID */
    private Long userId;
    
    /** 分类ID */
    private Long categoryId;
    
    /** 分类名称 */
    private String categoryName;
    
    /** 标题 */
    private String title;
    
    /** 内容 */
    private String content;
    
    /** 图片列表 */
    private List<String> images;
    
    /** 是否匿名 */
    private Integer isAnonymous;
    
    /** 是否草稿 */
    private Integer isDraft;
    
    /** 浏览次数 */
    private Integer viewCount;
    
    /** 点赞次数 */
    private Integer likeCount;
    
    /** 评论次数 */
    private Integer commentCount;
    
    /** 收藏次数 */
    private Integer collectCount;
    
    /** 状态 (0-正常, 1-禁用) */
    private Integer status;
    
    /** IP地址 */
    private String ip;
    
    /** 地理位置 */
    private String address;
    
    /** 发布者昵称 */
    private String nickName;
    
    /** 发布者头像 */
    private String avatar;
    
    /** 当前用户是否点赞 */
    private Boolean isLiked;
    
    /** 当前用户是否收藏 */
    private Boolean isCollected;
    
    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;
    
    /** 更新时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;
}
