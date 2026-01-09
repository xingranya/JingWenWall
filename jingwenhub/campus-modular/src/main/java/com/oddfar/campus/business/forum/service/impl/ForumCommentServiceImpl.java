package com.oddfar.campus.business.forum.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.forum.domain.dto.ForumCommentDTO;
import com.oddfar.campus.business.forum.domain.entity.BusForumCommentEntity;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumCommentVO;
import com.oddfar.campus.business.forum.mapper.ForumCommentMapper;
import com.oddfar.campus.business.forum.mapper.ForumPostMapper;
import com.oddfar.campus.business.forum.service.ForumCommentService;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 贴吧评论服务实现
 */
@Service
public class ForumCommentServiceImpl extends ServiceImpl<ForumCommentMapper, BusForumCommentEntity> 
        implements ForumCommentService {
    
    @Autowired
    private ForumCommentMapper commentMapper;
    
    @Autowired
    private ForumPostMapper postMapper;
    
    @Override
    public PageResult<ForumCommentVO> getCommentList(Long postId, Integer pageNum, Integer pageSize) {
        // 分页查询一级评论
        PageHelper.startPage(pageNum, pageSize);
        List<ForumCommentVO> firstLevelComments = commentMapper.selectFirstLevelComments(postId);
        PageInfo<ForumCommentVO> pageInfo = new PageInfo<>(firstLevelComments);
        
        // 为每个一级评论查询其二级评论
        firstLevelComments.forEach(comment -> {
            List<ForumCommentVO> replies = commentMapper.selectSecondLevelComments(comment.getCommentId());
            comment.setReplies(replies);
        });
        
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long publishComment(ForumCommentDTO commentDTO) {
        Long userId = SecurityUtils.getUserId();
        
        // 验证帖子是否存在
        BusForumPostEntity post = postMapper.selectById(commentDTO.getPostId());
        if (post == null) {
            throw new ServiceException("帖子不存在");
        }
        
        // 如果是二级评论,验证父评论是否存在
        if (commentDTO.getParentId() != null && commentDTO.getParentId() > 0) {
            BusForumCommentEntity parentComment = this.getById(commentDTO.getParentId());
            if (parentComment == null) {
                throw new ServiceException("父评论不存在");
            }
        }
        
        // 创建评论
        BusForumCommentEntity entity = new BusForumCommentEntity();
        BeanUtils.copyProperties(commentDTO, entity);
        entity.setUserId(userId);
        entity.setLikeCount(0);
        entity.setStatus(0);
        
        this.save(entity);
        
        // 更新帖子评论数
        post.setCommentCount(post.getCommentCount() + 1);
        postMapper.updateById(post);
        
        return entity.getCommentId();
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteComment(Long commentId) {
        Long userId = SecurityUtils.getUserId();
        
        BusForumCommentEntity comment = this.getById(commentId);
        if (comment == null) {
            throw new ServiceException("评论不存在");
        }
        
        if (!comment.getUserId().equals(userId)) {
            throw new ServiceException("无权删除此评论");
        }
        
        // 删除评论
        this.removeById(commentId);
        
        // 更新帖子评论数
        BusForumPostEntity post = postMapper.selectById(comment.getPostId());
        if (post != null && post.getCommentCount() > 0) {
            post.setCommentCount(post.getCommentCount() - 1);
            postMapper.updateById(post);
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void likeComment(Long commentId) {
        BusForumCommentEntity comment = this.getById(commentId);
        if (comment == null) {
            throw new ServiceException("评论不存在");
        }
        
        // TODO: 添加点赞记录表,避免重复点赞
        // 这里简化处理,直接增加点赞数
        comment.setLikeCount(comment.getLikeCount() + 1);
        this.updateById(comment);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void unlikeComment(Long commentId) {
        BusForumCommentEntity comment = this.getById(commentId);
        if (comment == null) {
            throw new ServiceException("评论不存在");
        }
        
        // TODO: 删除点赞记录
        // 这里简化处理,直接减少点赞数
        if (comment.getLikeCount() > 0) {
            comment.setLikeCount(comment.getLikeCount() - 1);
            this.updateById(comment);
        }
    }
}
