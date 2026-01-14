package com.oddfar.campus.business.forum.mapper;

import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumPostVO;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

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

    /**
     * 忽略逻辑删除，查询帖子元信息
     * @param postId 帖子ID
     */
    @Select("SELECT post_id, user_id, CAST(del_flag AS UNSIGNED) AS del_flag FROM bus_forum_post WHERE post_id = #{postId} LIMIT 1")
    BusForumPostEntity selectPostMetaPhysical(@Param("postId") Long postId);

    /**
     * 逻辑删除帖子（强制写 del_flag = 1）
     * @param postId 帖子ID
     * @param userId 当前用户ID
     */
    @Update("UPDATE bus_forum_post SET del_flag = b'1' WHERE post_id = #{postId} AND user_id = #{userId} AND del_flag = b'0'")
    int markDeleted(@Param("postId") Long postId, @Param("userId") Long userId);
}
