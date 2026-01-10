package com.oddfar.campus.business.forum.mapper;

import com.oddfar.campus.business.forum.domain.entity.BusForumPostLikeEntity;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import org.apache.ibatis.annotations.Select;
import java.util.List;

/**
 * 帖子点赞Mapper接口
 */
@Mapper
public interface ForumPostLikeMapper extends BaseMapperX<BusForumPostLikeEntity> {
    
    /**
     * 忽略逻辑删除，查询最新的一条记录（按时间降序）
     */
    @Select("SELECT * FROM bus_forum_post_like WHERE user_id = #{userId} AND post_id = #{postId} ORDER BY create_time DESC LIMIT 1")
    BusForumPostLikeEntity selectOnePhysical(@Param("userId") Long userId, @Param("postId") Long postId);

    /**
     * 查询用户点赞的帖子ID列表
     * @param userId 用户ID
     * @return 帖子ID列表
     */
    List<Long> selectLikedPostIds(@Param("userId") Long userId);
}
