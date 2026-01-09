package com.oddfar.campus.business.forum.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oddfar.campus.business.forum.domain.dto.ForumPostDTO;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumPostVO;
import com.oddfar.campus.common.domain.PageResult;

/**
 * 贴吧帖子服务接口
 */
public interface ForumPostService extends IService<BusForumPostEntity> {
    
    /**
     * 分页查询帖子列表
     * @param categoryId 分类ID (可选)
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ForumPostVO> pageList(Long categoryId, Integer pageNum, Integer pageSize);
    
    /**
     * 获取最新帖子
     */
    PageResult<ForumPostVO> newestList(Integer pageNum, Integer pageSize);
    
    /**
     * 获取热门帖子
     */
    PageResult<ForumPostVO> hotList(Integer pageNum, Integer pageSize);
    
    /**
     * 获取帖子详情
     * @param postId 帖子ID
     * @return 帖子详情
     */
    ForumPostVO getDetail(Long postId);
    
    /**
     * 发布帖子
     * @param postDTO 帖子内容
     * @return 帖子ID
     */
    Long publish(ForumPostDTO postDTO);
    
    /**
     * 保存草稿
     * @param postDTO 帖子内容
     * @return 帖子ID
     */
    Long saveDraft(ForumPostDTO postDTO);
    
    /**
     * 获取用户草稿
     * @param userId 用户ID
     * @return 草稿内容
     */
    ForumPostVO getDraft(Long userId);
    
    /**
     * 删除帖子
     * @param postId 帖子ID
     */
    void deletePost(Long postId);
    
    /**
     * 点赞帖子
     * @param postId 帖子ID
     */
    void likePost(Long postId);
    
    /**
     * 取消点赞
     * @param postId 帖子ID
     */
    void unlikePost(Long postId);
    
    /**
     * 收藏帖子
     * @param postId 帖子ID
     */
    void collectPost(Long postId);
    
    /**
     * 取消收藏
     * @param postId 帖子ID
     */
    void uncollectPost(Long postId);
    
    /**
     * 获取用户发布的帖子
     * @param userId 用户ID
     */
    PageResult<ForumPostVO> getUserPosts(Long userId, Integer pageNum, Integer pageSize);
    
    /**
     * 获取用户收藏的帖子
     * @param userId 用户ID
     */
    PageResult<ForumPostVO> getUserCollects(Long userId, Integer pageNum, Integer pageSize);
}
