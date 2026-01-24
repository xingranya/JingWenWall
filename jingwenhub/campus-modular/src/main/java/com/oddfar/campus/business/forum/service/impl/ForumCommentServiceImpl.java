package com.oddfar.campus.business.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.forum.domain.dto.ForumCommentDTO;
import com.oddfar.campus.business.forum.domain.entity.BusForumCommentEntity;
import com.oddfar.campus.business.forum.domain.entity.BusForumCommentLikeEntity;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumCommentVO;
import com.oddfar.campus.business.forum.mapper.ForumCommentLikeMapper;
import com.oddfar.campus.business.forum.mapper.ForumCommentMapper;
import com.oddfar.campus.business.forum.mapper.ForumPostMapper;
import com.oddfar.campus.business.forum.service.ForumCommentService;
import com.oddfar.campus.business.service.BusStudentService;
import com.oddfar.campus.business.service.WxAuthService;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 贴吧评论服务实现
 */
@Slf4j
@Service
public class ForumCommentServiceImpl extends ServiceImpl<ForumCommentMapper, BusForumCommentEntity>
        implements ForumCommentService {

    @Autowired
    private ForumCommentMapper commentMapper;

    @Autowired
    private ForumCommentLikeMapper commentLikeMapper;

    @Autowired
    private ForumPostMapper postMapper;

    @Autowired
    private WxAuthService wxAuthService;

    @Autowired
    private BusStudentService busStudentService;
    
    @Override
    public PageResult<ForumCommentVO> getCommentList(Long postId, Integer pageNum, Integer pageSize) {
        // 分页查询一级评论
        PageHelper.startPage(pageNum, pageSize);
        List<ForumCommentVO> firstLevelComments = commentMapper.selectFirstLevelComments(postId);
        PageInfo<ForumCommentVO> pageInfo = new PageInfo<>(firstLevelComments);

        // ✅ 修复 N+1 查询: 使用批量查询
        if (!firstLevelComments.isEmpty()) {
            // 提取所有一级评论ID
            List<Long> commentIds = firstLevelComments.stream()
                .map(ForumCommentVO::getCommentId)
                .collect(Collectors.toList());

            // 批量查询所有二级评论
            List<ForumCommentVO> allReplies = commentMapper.selectSecondLevelBatch(commentIds);

            // 按 parent_id 分组
            Map<Long, List<ForumCommentVO>> repliesMap = allReplies.stream()
                .collect(Collectors.groupingBy(ForumCommentVO::getParentId));

            // 填充到一级评论
            firstLevelComments.forEach(comment -> {
                List<ForumCommentVO> replies = repliesMap.getOrDefault(comment.getCommentId(), Collections.emptyList());
                comment.setReplies(replies);
            });
        }

        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long publishComment(ForumCommentDTO commentDTO) {
        Long userId = SecurityUtils.getUserId();

        // 1. 内容安全审核
        BusStudentEntity student = busStudentService.getByUserId(userId);
        String openid = student != null ? student.getOpenid() : "";

        if (commentDTO.getContent() != null && !commentDTO.getContent().trim().isEmpty()) {
            boolean contentSafe = wxAuthService.checkTextContent(commentDTO.getContent(), openid, 1);
            if (!contentSafe) {
                throw new ServiceException("评论内容包含违规信息，请修改后重试");
            }
        }

        // 2. 验证帖子是否存在
        BusForumPostEntity post = postMapper.selectById(commentDTO.getPostId());
        if (post == null) {
            throw new ServiceException("帖子不存在");
        }

        // 3. 如果是二级评论,验证父评论是否存在
        if (commentDTO.getParentId() != null && commentDTO.getParentId() > 0) {
            BusForumCommentEntity parentComment = this.getById(commentDTO.getParentId());
            if (parentComment == null) {
                throw new ServiceException("父评论不存在");
            }
        }

        // 4. 创建评论
        BusForumCommentEntity entity = new BusForumCommentEntity();
        BeanUtils.copyProperties(commentDTO, entity);
        entity.setUserId(userId);
        entity.setLikeCount(0);
        entity.setStatus(0);

        this.save(entity);

        // 5. 更新帖子评论数 (原子性更新)
        commentMapper.incrementPostCommentCount(commentDTO.getPostId());

        log.info("用户发布评论成功, userId: {}, commentId: {}, postId: {}",
                userId, entity.getCommentId(), commentDTO.getPostId());

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

        // 使用递归删除处理所有子评论
        int deletedCount = deleteCommentRecursive(commentId);

        // 更新帖子评论数
        BusForumPostEntity post = postMapper.selectById(comment.getPostId());
        if (post != null && post.getCommentCount() >= deletedCount) {
            post.setCommentCount(post.getCommentCount() - deletedCount);
            postMapper.updateById(post);
        }

        log.info("用户删除评论成功, userId: {}, commentId: {}, deletedCount: {}",
                userId, commentId, deletedCount);
    }

    /**
     * 递归删除评论及其所有子评论
     *
     * @param commentId 评论ID
     * @return 删除的评论总数
     */
    private int deleteCommentRecursive(Long commentId) {
        // 1. 查找所有子评论
        LambdaQueryWrapper<BusForumCommentEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumCommentEntity::getParentId, commentId);
        List<BusForumCommentEntity> children = commentMapper.selectList(wrapper);

        int deletedCount = 0;

        // 2. 递归删除所有子评论
        for (BusForumCommentEntity child : children) {
            deletedCount += deleteCommentRecursive(child.getCommentId());
        }

        // 3. 软删除当前评论
        BusForumCommentEntity comment = new BusForumCommentEntity();
        comment.setCommentId(commentId);
        comment.setDelFlag(1);
        commentMapper.updateById(comment);

        deletedCount++;

        log.debug("递归删除评论, commentId: {}, 子评论数: {}, 累计删除: {}",
                commentId, children.size(), deletedCount);

        return deletedCount;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void likeComment(Long commentId) {
        BusForumCommentEntity comment = this.getById(commentId);
        if (comment == null) {
            throw new ServiceException("评论不存在");
        }
                
        Long userId = SecurityUtils.getUserId();
                
        // 1. 忽略逻辑删除，直接查询物理记录
        BusForumCommentLikeEntity existLike = commentLikeMapper.selectOnePhysical(userId, commentId);
                
        if (existLike != null) {
            // 这里放宽一点：只要不是 0，都执行恢复操作
            if (existLike.getDelFlag() != null && existLike.getDelFlag() == 0) {
                throw new ServiceException("已经点赞过了");
            } else {
                // 强制恢复
                commentLikeMapper.updateDelFlag(userId, commentId, 0);
            }
        } else {
            // 插入新记录
            BusForumCommentLikeEntity likeEntity = new BusForumCommentLikeEntity();
            likeEntity.setUserId(userId);
            likeEntity.setCommentId(commentId);
            likeEntity.setDelFlag(0);
            commentLikeMapper.insert(likeEntity);
        }
                
        // 更新评论点赞数
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

        Long userId = SecurityUtils.getUserId();
        System.out.println("[取消点赞] userId=" + userId + ", commentId=" + commentId);

        // 强制执行更新，不进行前置判断，确保物理状态一定会被设为 1
        int rows = commentLikeMapper.updateDelFlag(userId, commentId, 1);
        System.out.println("[取消点赞] 影响行数=" + rows);

        if (rows > 0) {
            // 只有更新成功（即之前确实是点赞状态）才减少计数
            if (comment.getLikeCount() > 0) {
                comment.setLikeCount(comment.getLikeCount() - 1);
                this.updateById(comment);
            }
        }
    }

    // ==================== 管理后台方法实现 ====================

    @Override
    public PageResult<ForumCommentVO> getAdminCommentList(Long postId, Long userId, Integer status, String content, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ForumCommentVO> list = commentMapper.selectAdminCommentList(postId, userId, status, content);
        PageInfo<ForumCommentVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void adminDeleteComments(Long[] commentIds) {
        if (commentIds == null || commentIds.length == 0) {
            throw new ServiceException("评论ID不能为空");
        }
        for (Long commentId : commentIds) {
            this.deleteComment(commentId);
        }
        log.info("批量删除评论成功, count: {}", commentIds.length);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCommentStatus(Long commentId, Integer status) {
        BusForumCommentEntity comment = this.getById(commentId);
        if (comment == null) {
            throw new ServiceException("评论不存在");
        }
        comment.setStatus(status);
        this.updateById(comment);
        log.info("更新评论状态成功, commentId: {}, status: {}", commentId, status);
    }
}
