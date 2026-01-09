package com.oddfar.campus.business.forum.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oddfar.campus.business.forum.domain.dto.ForumCommentDTO;
import com.oddfar.campus.business.forum.domain.entity.BusForumCommentEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumCommentVO;
import com.oddfar.campus.common.domain.PageResult;

import java.util.List;

/**
 * 贴吧评论服务接口
 */
public interface ForumCommentService extends IService<BusForumCommentEntity> {
    
    /**
     * 获取帖子的评论列表(包含二级评论)
     * @param postId 帖子ID
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ForumCommentVO> getCommentList(Long postId, Integer pageNum, Integer pageSize);
    
    /**
     * 发布评论
     * @param commentDTO 评论内容
     * @return 评论ID
     */
    Long publishComment(ForumCommentDTO commentDTO);
    
    /**
     * 删除评论
     * @param commentId 评论ID
     */
    void deleteComment(Long commentId);
    
    /**
     * 点赞评论
     * @param commentId 评论ID
     */
    void likeComment(Long commentId);
    
    /**
     * 取消点赞评论
     * @param commentId 评论ID
     */
    void unlikeComment(Long commentId);
}
