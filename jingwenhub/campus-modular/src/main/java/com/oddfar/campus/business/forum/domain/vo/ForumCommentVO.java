package com.oddfar.campus.business.forum.domain.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;
import java.util.List;

/**
 * 评论视图对象
 */
@Data
public class ForumCommentVO {
    
    /** 评论ID */
    private Long commentId;
    
    /** 帖子ID */
    private Long postId;
    
    /** 评论用户ID */
    private Long userId;
    
    /** 父评论ID */
    private Long parentId;
    
    /** 回复目标用户ID */
    private Long toUserId;
    
    /** 评论内容 */
    private String content;
    
    /** 点赞数 */
    private Integer likeCount;
    
    /** 状态 */
    private Integer status;
    
    /** 评论者昵称 */
    private String nickName;
    
    /** 评论者头像 */
    private String avatar;
    
    /** 回复目标用户昵称 */
    private String toUserNickName;
    
    /** 当前用户是否点赞 */
    private Boolean isLiked;
    
    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;
    
    /** 子评论列表 (二级评论) */
    private List<ForumCommentVO> replies;
}
