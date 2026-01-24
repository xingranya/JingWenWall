package com.oddfar.campus.business.controller.admin;

import com.oddfar.campus.business.forum.domain.entity.BusForumCommentEntity;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.domain.vo.ForumCommentVO;
import com.oddfar.campus.business.forum.domain.vo.ForumPostVO;
import com.oddfar.campus.business.forum.service.ForumCommentService;
import com.oddfar.campus.business.forum.service.ForumPostService;
import com.oddfar.campus.common.annotation.ApiResource;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.domain.R;
import com.oddfar.campus.common.enums.ResBizTypeEnum;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * 论坛管理（管理后台）
 */
@Api(tags = "论坛管理-后台")
@RestController
@RequestMapping("/admin/forum")
@ApiResource(name = "论坛管理", appCode = "campus", resBizType = ResBizTypeEnum.BUSINESS)
public class ForumAdminController {

    @Autowired
    private ForumPostService forumPostService;

    @Autowired
    private ForumCommentService forumCommentService;

    // ==================== 帖子管理 ====================

    @ApiOperation("获取帖子列表")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/post/list", name = "帖子列表")
    public R getPostList(
            @ApiParam("用户ID") @RequestParam(required = false) Long userId,
            @ApiParam("分类ID") @RequestParam(required = false) Long categoryId,
            @ApiParam("状态: 0正常 1禁用") @RequestParam(required = false) Integer status,
            @ApiParam("标题关键词") @RequestParam(required = false) String title,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ForumPostVO> result = forumPostService.getAdminPostList(userId, categoryId, status, title, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取帖子详情")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/post/{postId}", name = "获取帖子详情")
    public R getPostDetail(@PathVariable Long postId) {
        ForumPostVO detail = forumPostService.getDetail(postId);
        return R.ok(detail);
    }

    @ApiOperation("修改帖子")
    @PreAuthorize("@ss.resourceAuth()")
    @PutMapping(value = "/post", name = "修改帖子")
    public R updatePost(@RequestBody BusForumPostEntity post) {
        forumPostService.updatePost(post);
        return R.ok("修改成功");
    }

    @ApiOperation("删除帖子")
    @PreAuthorize("@ss.resourceAuth()")
    @DeleteMapping(value = "/post/{postIds}", name = "删除帖子")
    public R deletePost(@PathVariable Long[] postIds) {
        forumPostService.adminDeletePosts(postIds);
        return R.ok("删除成功");
    }

    @ApiOperation("审核帖子")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/post/audit/{postId}", name = "审核帖子")
    public R auditPost(
            @PathVariable Long postId,
            @ApiParam("状态: 0正常 1禁用") @RequestParam Integer status) {
        forumPostService.updatePostStatus(postId, status);
        return R.ok("操作成功");
    }

    // ==================== 评论管理 ====================

    @ApiOperation("获取评论列表")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/comment/list", name = "评论列表")
    public R getCommentList(
            @ApiParam("帖子ID") @RequestParam(required = false) Long postId,
            @ApiParam("用户ID") @RequestParam(required = false) Long userId,
            @ApiParam("状态: 0正常 1禁用") @RequestParam(required = false) Integer status,
            @ApiParam("内容关键词") @RequestParam(required = false) String content,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ForumCommentVO> result = forumCommentService.getAdminCommentList(postId, userId, status, content, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取评论详情")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/comment/{commentId}", name = "获取评论详情")
    public R getCommentDetail(@PathVariable Long commentId) {
        BusForumCommentEntity comment = forumCommentService.getById(commentId);
        return R.ok(comment);
    }

    @ApiOperation("删除评论")
    @PreAuthorize("@ss.resourceAuth()")
    @DeleteMapping(value = "/comment/{commentIds}", name = "删除评论")
    public R deleteComment(@PathVariable Long[] commentIds) {
        forumCommentService.adminDeleteComments(commentIds);
        return R.ok("删除成功");
    }

    @ApiOperation("审核评论")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/comment/audit/{commentId}", name = "审核评论")
    public R auditComment(
            @PathVariable Long commentId,
            @ApiParam("状�? 0正常 1禁用") @RequestParam Integer status) {
        forumCommentService.updateCommentStatus(commentId, status);
        return R.ok("操作成功");
    }
}
