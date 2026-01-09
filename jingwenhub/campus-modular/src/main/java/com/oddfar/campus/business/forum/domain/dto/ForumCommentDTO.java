package com.oddfar.campus.business.forum.domain.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 评论数据传输对象
 */
@Data
public class ForumCommentDTO {
    
    /** 帖子ID */
    @NotNull(message = "帖子ID不能为空")
    private Long postId;
    
    /** 父评论ID (0表示一级评论) */
    private Long parentId = 0L;
    
    /** 回复目标用户ID (二级评论时使用) */
    private Long toUserId;
    
    /** 评论内容 */
    @NotBlank(message = "评论内容不能为空")
    private String content;
}
