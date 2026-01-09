package com.oddfar.campus.business.forum.controller;

import com.oddfar.campus.business.forum.domain.dto.ForumCommentDTO;
import com.oddfar.campus.business.forum.domain.vo.ForumCommentVO;
import com.oddfar.campus.business.forum.service.ForumCommentService;
import com.oddfar.campus.common.annotation.Anonymous;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.domain.R;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 贴吧评论控制器
 */
@Api(tags = "贴吧-评论管理")
@RestController
@RequestMapping("/api/v1/forum/comments")
public class ForumCommentController {
    
    @Autowired
    private ForumCommentService commentService;
    
    @Anonymous
    @ApiOperation("获取帖子评论列表")
    @GetMapping("/post/{postId}")
    public R getCommentList(
            @PathVariable Long postId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ForumCommentVO> result = commentService.getCommentList(postId, pageNum, pageSize);
        return R.ok().put(result);
    }
    
    @ApiOperation("发布评论")
    @PostMapping
    public R publishComment(@RequestBody @Validated ForumCommentDTO commentDTO) {
        Long commentId = commentService.publishComment(commentDTO);
        return R.ok().put("commentId", commentId);
    }
    
    @ApiOperation("删除评论")
    @DeleteMapping("/{commentId}")
    public R deleteComment(@PathVariable Long commentId) {
        commentService.deleteComment(commentId);
        return R.ok();
    }
    
    @ApiOperation("点赞评论")
    @PostMapping("/{commentId}/like")
    public R likeComment(@PathVariable Long commentId) {
        commentService.likeComment(commentId);
        return R.ok();
    }
    
    @ApiOperation("取消点赞评论")
    @DeleteMapping("/{commentId}/like")
    public R unlikeComment(@PathVariable Long commentId) {
        commentService.unlikeComment(commentId);
        return R.ok();
    }
}
