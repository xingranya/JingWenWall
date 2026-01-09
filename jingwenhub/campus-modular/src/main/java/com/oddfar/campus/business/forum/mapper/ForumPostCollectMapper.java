package com.oddfar.campus.business.forum.mapper;

import com.oddfar.campus.business.forum.domain.entity.BusForumPostCollectEntity;
import com.oddfar.campus.common.core.BaseMapperX;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 帖子收藏Mapper接口
 */
@Mapper
public interface ForumPostCollectMapper extends BaseMapperX<BusForumPostCollectEntity> {
    
    /**
     * 查询用户收藏的帖子ID列表
     * @param userId 用户ID
     * @return 帖子ID列表
     */
    List<Long> selectCollectedPostIds(@Param("userId") Long userId);
}
