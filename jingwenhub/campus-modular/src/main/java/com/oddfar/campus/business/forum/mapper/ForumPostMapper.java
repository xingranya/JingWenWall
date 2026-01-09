package com.oddfar.campus.business.forum.mapper;

import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumPostVO;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 贴吧帖子Mapper接口
 */
@Mapper
public interface ForumPostMapper extends BaseMapperX<BusForumPostEntity> {
    
    /**
     * 查询帖子列表(带用户信息)
     * @param categoryId 分类ID (可选)
     * @return 帖子VO列表
     */
    List<ForumPostVO> selectPostList(@Param("categoryId") Long categoryId);
    
    /**
     * 查询帖子详情(带用户信息)
     * @param postId 帖子ID
     * @return 帖子VO
     */
    ForumPostVO selectPostDetail(@Param("postId") Long postId);
    
    /**
     * 查询最新帖子列表
     * @return 帖子VO列表
     */
    List<ForumPostVO> selectNewestPosts();
    
    /**
     * 查询热门帖子列表
     * @return 帖子VO列表
     */
    List<ForumPostVO> selectHotPosts();
    
    /**
     * 查询用户发布的帖子
     * @param userId 用户ID
     * @return 帖子VO列表
     */
    List<ForumPostVO> selectPostsByUserId(@Param("userId") Long userId);
    
    /**
     * 查询用户收藏的帖子ID列表
     * @param userId 用户ID
     * @return 帖子ID列表
     */
    List<Long> selectCollectedPostIds(@Param("userId") Long userId);
    
    /**
     * 查询用户收藏的帖子详情列表
     * @param postIds 帖子ID列表
     * @return 帖子VO列表
     */
    List<ForumPostVO> selectPostsByIds(@Param("postIds") List<Long> postIds);
    
    /**
     * 更新帖子浏览次数
     * @param postId 帖子ID
     */
    void updateViewCount(@Param("postId") Long postId);
}
