package com.oddfar.campus.business.forum.mapper;

import com.oddfar.campus.business.forum.domain.entity.BusForumCommentEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumCommentVO;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 贴吧评论Mapper接口
 */
@Mapper
public interface ForumCommentMapper extends BaseMapperX<BusForumCommentEntity> {
    
    /**
     * 查询帖子的一级评论列表
     * @param postId 帖子ID
     * @return 评论VO列表
     */
    List<ForumCommentVO> selectFirstLevelComments(@Param("postId") Long postId);
    
    /**
     * 查询二级评论列表
     * @param parentId 父评论ID
     * @return 评论VO列表
     */
    List<ForumCommentVO> selectSecondLevelComments(@Param("parentId") Long parentId);

    /**
     * 批量查询二级评论列表
     * @param commentIds 父评论ID列表
     * @return 评论VO列表
     */
    List<ForumCommentVO> selectSecondLevelBatch(@Param("commentIds") List<Long> commentIds);

    /**
     * 查询评论详情
     * @param commentId 评论ID
     * @return 评论VO
     */
    ForumCommentVO selectCommentDetail(@Param("commentId") Long commentId);
}
