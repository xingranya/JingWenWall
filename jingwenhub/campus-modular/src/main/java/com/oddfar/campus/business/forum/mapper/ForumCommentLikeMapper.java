package com.oddfar.campus.business.forum.mapper;

import com.oddfar.campus.business.forum.domain.entity.BusForumCommentLikeEntity;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/**
 * 评论点赞Mapper接口
 */
@Mapper
public interface ForumCommentLikeMapper extends BaseMapperX<BusForumCommentLikeEntity> {
    
    /**
     * 忽略逻辑删除，查询最新的一条记录（按时间降序）
     */
    @Select("SELECT * FROM bus_forum_comment_like WHERE user_id = #{userId} AND comment_id = #{commentId} ORDER BY create_time DESC LIMIT 1")
    BusForumCommentLikeEntity selectOnePhysical(@Param("userId") Long userId, @Param("commentId") Long commentId);
    /**
     * 强制更新逻辑删除标志（绕过逻辑删除检查）
     */
    @Update("UPDATE bus_forum_comment_like SET del_flag = #{delFlag} WHERE user_id = #{userId} AND comment_id = #{commentId}")
    int updateDelFlag(@Param("userId") Long userId, @Param("commentId") Long commentId, @Param("delFlag") Integer delFlag);
}
