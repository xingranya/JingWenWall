package com.oddfar.campus.business.forum.controller;

import com.oddfar.campus.business.forum.domain.dto.ForumPostDTO;
import com.oddfar.campus.business.forum.domain.vo.ForumPostVO;
import com.oddfar.campus.business.forum.service.ForumPostService;
import com.oddfar.campus.common.annotation.Anonymous;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.domain.R;
import com.oddfar.campus.common.utils.SecurityUtils;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 贴吧帖子控制器
 */
@Api(tags = "贴吧-帖子管理")
@RestController
@RequestMapping("/api/v1/forum/posts")
public class ForumPostController {
    
    @Autowired
    private ForumPostService forumPostService;
    
    @Anonymous
    @ApiOperation("获取最新帖子列表")
    @GetMapping("/newest")
    public R newest(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ForumPostVO> result = forumPostService.newestList(pageNum, pageSize);
        return R.ok().put(result);
    }
    
    @Anonymous
    @ApiOperation("获取热门帖子列表")
    @GetMapping("/hot")
    public R hot(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ForumPostVO> result = forumPostService.hotList(pageNum, pageSize);
        return R.ok().put(result);
    }
    
    @Anonymous
    @ApiOperation("分类帖子列表")
    @GetMapping("/category/{categoryId}")
    public R listByCategory(
            @PathVariable Long categoryId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ForumPostVO> result = forumPostService.pageList(categoryId, pageNum, pageSize);
        return R.ok().put(result);
    }
    
    @Anonymous
    @ApiOperation("获取帖子详情")
    @GetMapping("/{postId}")
    public R detail(@PathVariable Long postId) {
        ForumPostVO detail = forumPostService.getDetail(postId);
        return R.ok(detail);
    }
    
    @ApiOperation("发布帖子")
    @PostMapping
    public R publish(@RequestBody @Validated ForumPostDTO postDTO) {
        Long postId = forumPostService.publish(postDTO);
        return R.ok().put("postId", postId);
    }
    
    @ApiOperation("保存草稿")
    @PostMapping("/draft")
    public R saveDraft(@RequestBody ForumPostDTO postDTO) {
        Long postId = forumPostService.saveDraft(postDTO);
        return R.ok().put("postId", postId);
    }
    
    @ApiOperation("获取我的草稿")
    @GetMapping("/draft")
    public R getDraft() {
        Long userId = SecurityUtils.getUserId();
        ForumPostVO draft = forumPostService.getDraft(userId);
        return R.ok(draft);
    }
    
    @ApiOperation("删除帖子")
    @DeleteMapping("/{postId}")
    public R delete(@PathVariable Long postId) {
        forumPostService.deletePost(postId);
        return R.ok("删除成功");
    }
    
    @ApiOperation("点赞帖子")
    @PostMapping("/{postId}/like")
    public R like(@PathVariable Long postId) {
        forumPostService.likePost(postId);
        return R.ok();
    }
    
    @ApiOperation("取消点赞")
    @DeleteMapping("/{postId}/like")
    public R unlike(@PathVariable Long postId) {
        forumPostService.unlikePost(postId);
        return R.ok();
    }
    
    @ApiOperation("收藏帖子")
    @PostMapping("/{postId}/collect")
    public R collect(@PathVariable Long postId) {
        forumPostService.collectPost(postId);
        return R.ok();
    }
    
    @ApiOperation("取消收藏")
    @DeleteMapping("/{postId}/collect")
    public R uncollect(@PathVariable Long postId) {
        forumPostService.uncollectPost(postId);
        return R.ok();
    }
    
    @ApiOperation("我发布的帖子")
    @GetMapping("/mine")
    public R myPosts(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        Long userId = SecurityUtils.getUserId();
        PageResult<ForumPostVO> result = forumPostService.getUserPosts(userId, pageNum, pageSize);
        return R.ok().put(result);
    }
    
    @ApiOperation("我收藏的帖子")
    @GetMapping("/collected")
    public R collectedPosts(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        Long userId = SecurityUtils.getUserId();
        PageResult<ForumPostVO> result = forumPostService.getUserCollects(userId, pageNum, pageSize);
        return R.ok().put(result);
    }
}
