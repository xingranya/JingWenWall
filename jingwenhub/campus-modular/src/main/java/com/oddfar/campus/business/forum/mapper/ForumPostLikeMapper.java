package com.oddfar.campus.business.forum.mapper;

import com.oddfar.campus.business.forum.domain.entity.BusForumPostLikeEntity;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 帖子点赞Mapper接口
 */
@Mapper
public interface ForumPostLikeMapper extends BaseMapperX<BusForumPostLikeEntity> {
    
    /**
     * 查询用户点赞的帖子ID列表
     * @param userId 用户ID
     * @return 帖子ID列表
     */
    List<Long> selectLikedPostIds(@Param("userId") Long userId);
}
