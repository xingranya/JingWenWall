package com.oddfar.campus.business.forum.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.forum.domain.dto.ForumPostDTO;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostCollectEntity;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostLikeEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumPostVO;
import com.oddfar.campus.business.forum.mapper.ForumPostCollectMapper;
import com.oddfar.campus.business.forum.mapper.ForumPostLikeMapper;
import com.oddfar.campus.business.forum.mapper.ForumPostMapper;
import com.oddfar.campus.business.forum.service.ForumPostService;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 贴吧帖子服务实现
 */
@Service
public class ForumPostServiceImpl extends ServiceImpl<ForumPostMapper, BusForumPostEntity> 
        implements ForumPostService {
    
    @Autowired
    private ForumPostMapper forumPostMapper;
    
    @Autowired
    private ForumPostLikeMapper likeMapper;
    
    @Autowired
    private ForumPostCollectMapper collectMapper;
    
    @Override
    public PageResult<ForumPostVO> pageList(Long categoryId, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ForumPostVO> list = forumPostMapper.selectPostList(categoryId);
        fillUserLikeAndCollectStatus(list);
        PageInfo<ForumPostVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }
    
    @Override
    public PageResult<ForumPostVO> newestList(Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ForumPostVO> list = forumPostMapper.selectNewestPosts();
        fillUserLikeAndCollectStatus(list);
        PageInfo<ForumPostVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }
    
    @Override
    public PageResult<ForumPostVO> hotList(Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ForumPostVO> list = forumPostMapper.selectHotPosts();
        fillUserLikeAndCollectStatus(list);
        PageInfo<ForumPostVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }
    
    @Override
    public ForumPostVO getDetail(Long postId) {
        // 更新浏览次数
        forumPostMapper.updateViewCount(postId);
        
        ForumPostVO vo = forumPostMapper.selectPostDetail(postId);
        if (vo == null) {
            throw new ServiceException("帖子不存在");
        }
        
        // 填充当前用户的点赞和收藏状态
        if (SecurityUtils.isLogin()) {
            Long userId = SecurityUtils.getUserId();
            vo.setIsLiked(checkUserLike(userId, postId));
            vo.setIsCollected(checkUserCollect(userId, postId));
        }
        
        return vo;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long publish(ForumPostDTO postDTO) {
        Long userId = SecurityUtils.getUserId();
        
        BusForumPostEntity entity = new BusForumPostEntity();
        BeanUtils.copyProperties(postDTO, entity);
        entity.setUserId(userId);
        entity.setIsDraft(0);
        entity.setStatus(0);
        entity.setViewCount(0);
        entity.setLikeCount(0);
        entity.setCommentCount(0);
        entity.setCollectCount(0);
        
        this.save(entity);
        return entity.getPostId();
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long saveDraft(ForumPostDTO postDTO) {
        Long userId = SecurityUtils.getUserId();
        
        BusForumPostEntity entity;
        if (postDTO.getPostId() != null) {
            // 更新现有草稿
            entity = this.getById(postDTO.getPostId());
            if (entity == null || !entity.getUserId().equals(userId)) {
                throw new ServiceException("草稿不存在");
            }
            BeanUtils.copyProperties(postDTO, entity);
        } else {
            // 创建新草稿
            entity = new BusForumPostEntity();
            BeanUtils.copyProperties(postDTO, entity);
            entity.setUserId(userId);
            entity.setStatus(0);
        }
        
        entity.setIsDraft(1);
        this.saveOrUpdate(entity);
        return entity.getPostId();
    }
    
    @Override
    public ForumPostVO getDraft(Long userId) {
        LambdaQueryWrapper<BusForumPostEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumPostEntity::getUserId, userId)
               .eq(BusForumPostEntity::getIsDraft, 1)
               .orderByDesc(BusForumPostEntity::getUpdateTime)
               .last("LIMIT 1");
        
        BusForumPostEntity entity = this.getOne(wrapper);
        if (entity == null) {
            return null;
        }
        
        ForumPostVO vo = new ForumPostVO();
        BeanUtils.copyProperties(entity, vo);
        return vo;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deletePost(Long postId) {
        Long userId = SecurityUtils.getUserId();
        
        BusForumPostEntity entity = this.getById(postId);
        if (entity == null) {
            throw new ServiceException("帖子不存在");
        }
        
        if (!entity.getUserId().equals(userId)) {
            throw new ServiceException("无权删除此帖子");
        }
        
        this.removeById(postId);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void likePost(Long postId) {
        Long userId = SecurityUtils.getUserId();
        
        // 检查是否已点赞（只查询未删除的）
        LambdaQueryWrapper<BusForumPostLikeEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumPostLikeEntity::getUserId, userId)
               .eq(BusForumPostLikeEntity::getPostId, postId)
               .eq(BusForumPostLikeEntity::getDelFlag, 0);  // 只查询未删除的
        
        if (likeMapper.selectCount(wrapper) > 0) {
            throw new ServiceException("已经点赞过了");
        }
        
        // 添加点赞记录
        BusForumPostLikeEntity likeEntity = new BusForumPostLikeEntity();
        likeEntity.setUserId(userId);
        likeEntity.setPostId(postId);
        likeEntity.setDelFlag(0);  // 下檇标记为未删除
        likeMapper.insert(likeEntity);
        
        // 更新帖子点赞数
        BusForumPostEntity post = this.getById(postId);
        if (post != null) {
            post.setLikeCount(post.getLikeCount() + 1);
            this.updateById(post);
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void unlikePost(Long postId) {
        Long userId = SecurityUtils.getUserId();
        
        // 查找点赞记录
        LambdaQueryWrapper<BusForumPostLikeEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumPostLikeEntity::getUserId, userId)
               .eq(BusForumPostLikeEntity::getPostId, postId)
               .eq(BusForumPostLikeEntity::getDelFlag, 0);  // 只查询未删除的
        
        BusForumPostLikeEntity likeEntity = likeMapper.selectOne(wrapper);
        if (likeEntity != null) {
            // 逐辑删除：设置 del_flag = 1
            likeEntity.setDelFlag(1);
            likeMapper.updateById(likeEntity);
            
            // 更新帖子点赞数
            BusForumPostEntity post = this.getById(postId);
            if (post != null && post.getLikeCount() > 0) {
                post.setLikeCount(post.getLikeCount() - 1);
                this.updateById(post);
            }
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void collectPost(Long postId) {
        Long userId = SecurityUtils.getUserId();
        
        // 检查是否已收藏（只查询未删除的）
        LambdaQueryWrapper<BusForumPostCollectEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumPostCollectEntity::getUserId, userId)
               .eq(BusForumPostCollectEntity::getPostId, postId)
               .eq(BusForumPostCollectEntity::getDelFlag, 0);  // 只查询未删除的
        
        if (collectMapper.selectCount(wrapper) > 0) {
            throw new ServiceException("已经收藏过了");
        }
        
        // 添加收藏记录
        BusForumPostCollectEntity collectEntity = new BusForumPostCollectEntity();
        collectEntity.setUserId(userId);
        collectEntity.setPostId(postId);
        collectEntity.setDelFlag(0);  // 下檇标记为未删除
        collectMapper.insert(collectEntity);
        
        // 更新帖子收藏数
        BusForumPostEntity post = this.getById(postId);
        if (post != null) {
            post.setCollectCount(post.getCollectCount() + 1);
            this.updateById(post);
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void uncollectPost(Long postId) {
        Long userId = SecurityUtils.getUserId();
        
        // 查找收藏记录
        LambdaQueryWrapper<BusForumPostCollectEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumPostCollectEntity::getUserId, userId)
               .eq(BusForumPostCollectEntity::getPostId, postId)
               .eq(BusForumPostCollectEntity::getDelFlag, 0);  // 只查询未删除的
        
        BusForumPostCollectEntity collectEntity = collectMapper.selectOne(wrapper);
        if (collectEntity != null) {
            // 逐辑删除：设置 del_flag = 1
            collectEntity.setDelFlag(1);
            collectMapper.updateById(collectEntity);
            
            // 更新帖子收藏数
            BusForumPostEntity post = this.getById(postId);
            if (post != null && post.getCollectCount() > 0) {
                post.setCollectCount(post.getCollectCount() - 1);
                this.updateById(post);
            }
        }
    }
    
    @Override
    public PageResult<ForumPostVO> getUserPosts(Long userId, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ForumPostVO> list = forumPostMapper.selectPostsByUserId(userId);
        fillUserLikeAndCollectStatus(list);
        PageInfo<ForumPostVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }
    
    @Override
    public PageResult<ForumPostVO> getUserCollects(Long userId, Integer pageNum, Integer pageSize) {
        // 获取用户收藏的帖子ID列表
        List<Long> postIds = collectMapper.selectCollectedPostIds(userId);
        
        if (postIds.isEmpty()) {
            return new PageResult<>(new ArrayList<>(), 0L);
        }
        
        PageHelper.startPage(pageNum, pageSize);
        List<ForumPostVO> list = forumPostMapper.selectPostsByIds(postIds);
        fillUserLikeAndCollectStatus(list);
        PageInfo<ForumPostVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }
    
    /**
     * 填充用户的点赞和收藏状态
     */
    private void fillUserLikeAndCollectStatus(List<ForumPostVO> list) {
        if (list.isEmpty() || !SecurityUtils.isLogin()) {
            return;
        }
        
        Long userId = SecurityUtils.getUserId();
        
        // 获取用户点赞的帖子ID列表
        List<Long> likedPostIds = likeMapper.selectLikedPostIds(userId);
        
        // 获取用户收藏的帖子ID列表
        List<Long> collectedPostIds = collectMapper.selectCollectedPostIds(userId);
        
        // 填充状态
        list.forEach(vo -> {
            vo.setIsLiked(likedPostIds.contains(vo.getPostId()));
            vo.setIsCollected(collectedPostIds.contains(vo.getPostId()));
        });
    }
    
    /**
     * 检查用户是否点赞了帖子
     */
    private boolean checkUserLike(Long userId, Long postId) {
        LambdaQueryWrapper<BusForumPostLikeEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumPostLikeEntity::getUserId, userId)
               .eq(BusForumPostLikeEntity::getPostId, postId);
        return likeMapper.selectCount(wrapper) > 0;
    }
    
    /**
     * 检查用户是否收藏了帖子
     */
    private boolean checkUserCollect(Long userId, Long postId) {
        LambdaQueryWrapper<BusForumPostCollectEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BusForumPostCollectEntity::getUserId, userId)
               .eq(BusForumPostCollectEntity::getPostId, postId);
        return collectMapper.selectCount(wrapper) > 0;
    }
}
