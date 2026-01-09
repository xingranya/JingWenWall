package com.oddfar.campus.business.forum.domain.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.util.List;

/**
 * 帖子数据传输对象
 */
@Data
public class ForumPostDTO {
    
    /** 帖子ID (更新时使用) */
    private Long postId;
    
    /** 分类ID */
    private Long categoryId;
    
    /** 标题 */
    @NotBlank(message = "标题不能为空")
    private String title;
    
    /** 内容 */
    @NotBlank(message = "内容不能为空")
    private String content;
    
    /** 图片列表 */
    private List<String> images;
    
    /** 是否匿名 (0-否, 1-是) */
    private Integer isAnonymous;
    
    /** 是否草稿 (0-否, 1-是) */
    private Integer isDraft;
}
