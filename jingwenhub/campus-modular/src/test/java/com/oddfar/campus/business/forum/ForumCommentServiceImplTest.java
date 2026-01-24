package com.oddfar.campus.business.forum;

import com.oddfar.campus.business.forum.domain.entity.BusForumCommentEntity;
import com.oddfar.campus.business.forum.domain.entity.BusForumPostEntity;
import com.oddfar.campus.business.forum.mapper.ForumCommentMapper;
import com.oddfar.campus.business.forum.mapper.ForumPostMapper;
import com.oddfar.campus.business.forum.service.ForumCommentService;
import com.oddfar.campus.common.exception.ServiceException;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 论坛评论服务测试
 * 验证评论级联删除功能
 *
 * @author jingwen
 */
@Slf4j
@SpringBootTest
@ActiveProfiles("test")
@Transactional
public class ForumCommentServiceImplTest {

    @Autowired
    private ForumCommentService commentService;

    @Autowired
    private ForumCommentMapper commentMapper;

    @Autowired
    private ForumPostMapper postMapper;

    private Long testPostId;
    private Long testUserId = 1L; // 测试用户ID

    /**
     * 创建测试帖子和评论数据
     */
    @BeforeEach
    public void setup() {
        // 1. 创建测试帖子
        BusForumPostEntity post = new BusForumPostEntity();
        post.setUserId(testUserId);
        post.setTitle("测试帖子-评论级联删除");
        post.setContent("这是一个测试帖子的内容");
        post.setStatus(0);
        post.setViewCount(0);
        post.setLikeCount(0);
        post.setCommentCount(0);
        post.setDelFlag(0);
        postMapper.insert(post);
        testPostId = post.getPostId();

        log.info("测试环境准备完成, postId: {}", testPostId);
    }

    /**
     * 测试删除一级评论时级联删除所有二级评论
     *
     * 测试场景:
     * 1. 创建1个一级评论
     * 2. 创建3个二级评论作为该一级评论的子评论
     * 3. 为其中一个二级评论再创建2个三级评论
     * 4. 删除一级评论
     * 5. 验证所有子评论都被软删除 (del_flag = 1)
     * 6. 验证帖子评论数正确减少
     */
    @Test
    public void testDeleteCommentCascade() {
        log.info("=== 开始评论级联删除测试 ===");

        // 1. 创建一级评论
        Long firstLevelId = createComment(testPostId, 0L, "一级评论");

        // 2. 创建3个二级评论
        Long secondLevel1 = createComment(testPostId, firstLevelId, "二级评论1");
        Long secondLevel2 = createComment(testPostId, firstLevelId, "二级评论2");
        Long secondLevel3 = createComment(testPostId, firstLevelId, "二级评论3");

        // 3. 为第二个二级评论创建2个三级评论
        Long thirdLevel1 = createComment(testPostId, secondLevel2, "三级评论1");
        Long thirdLevel2 = createComment(testPostId, secondLevel2, "三级评论2");

        // 刷新帖子评论数
        updatePostCommentCount(testPostId, 6); // 1 + 3 + 2 = 6条评论

        log.info("创建评论树:");
        log.info("  - 一级评论: {}", firstLevelId);
        log.info("    - 二级评论1: {}", secondLevel1);
        log.info("    - 二级评论2: {} (有子评论)", secondLevel2);
        log.info("      - 三级评论1: {}", thirdLevel1);
        log.info("      - 三级评论2: {}", thirdLevel2);
        log.info("    - 二级评论3: {}", secondLevel3);

        // 4. 删除一级评论
        commentService.deleteComment(firstLevelId);

        // 5. 验证所有评论都被软删除
        assertTrue(isCommentDeleted(firstLevelId), "一级评论应该被删除");
        assertTrue(isCommentDeleted(secondLevel1), "二级评论1应该被删除");
        assertTrue(isCommentDeleted(secondLevel2), "二级评论2应该被删除");
        assertTrue(isCommentDeleted(secondLevel3), "二级评论3应该被删除");
        assertTrue(isCommentDeleted(thirdLevel1), "三级评论1应该被删除");
        assertTrue(isCommentDeleted(thirdLevel2), "三级评论2应该被删除");

        // 6. 验证帖子评论数正确减少
        BusForumPostEntity post = postMapper.selectById(testPostId);
        assertEquals(0, post.getCommentCount(), "帖子评论数应该减少到0");

        log.info("=== 评论级联删除测试通过 ===");
    }

    /**
     * 测试删除二级评论时只删除该评论及其子评论
     *
     * 测试场景:
     * 1. 创建1个一级评论
     * 2. 创建2个二级评论
     * 3. 为第一个二级评论创建2个三级评论
     * 4. 删除第一个二级评论
     * 5. 验证该二级评论及其子评论被删除
     * 6. 验证另一个二级评论未被删除
     * 7. 验证一级评论未被删除
     */
    @Test
    public void testDeleteSecondLevelComment() {
        log.info("=== 开始删除二级评论测试 ===");

        // 1. 创建一级评论
        Long firstLevelId = createComment(testPostId, 0L, "一级评论");

        // 2. 创建2个二级评论
        Long secondLevel1 = createComment(testPostId, firstLevelId, "二级评论1");
        Long secondLevel2 = createComment(testPostId, firstLevelId, "二级评论2");

        // 3. 为第一个二级评论创建2个三级评论
        Long thirdLevel1 = createComment(testPostId, secondLevel1, "三级评论1");
        Long thirdLevel2 = createComment(testPostId, secondLevel1, "三级评论2");

        // 刷新帖子评论数
        updatePostCommentCount(testPostId, 4); // 1 + 2 + 1 = 4条评论

        log.info("创建评论树:");
        log.info("  - 一级评论: {}", firstLevelId);
        log.info("    - 二级评论1: {} (将被删除)", secondLevel1);
        log.info("      - 三级评论1: {}", thirdLevel1);
        log.info("      - 三级评论2: {}", thirdLevel2);
        log.info("    - 二级评论2: {} (应该保留)", secondLevel2);

        // 4. 删除第一个二级评论
        commentService.deleteComment(secondLevel1);

        // 5. 验证
        assertFalse(isCommentDeleted(firstLevelId), "一级评论不应该被删除");
        assertTrue(isCommentDeleted(secondLevel1), "二级评论1应该被删除");
        assertFalse(isCommentDeleted(secondLevel2), "二级评论2不应该被删除");
        assertTrue(isCommentDeleted(thirdLevel1), "三级评论1应该被删除");
        assertTrue(isCommentDeleted(thirdLevel2), "三级评论2应该被删除");

        // 6. 验证帖子评论数正确减少 (删除了3条: 1个二级+2个三级)
        BusForumPostEntity post = postMapper.selectById(testPostId);
        assertEquals(1, post.getCommentCount(), "帖子评论数应该是1");

        log.info("=== 删除二级评论测试通过 ===");
    }

    /**
     * 测试删除没有子评论的评论
     *
     * 测试场景:
     * 1. 创建1个一级评论
     * 2. 创建1个二级评论
     * 3. 删除二级评论
     * 4. 验证只删除了该评论
     * 5. 验证帖子评论数减少1
     */
    @Test
    public void testDeleteLeafComment() {
        log.info("=== 开始删除叶子节点评论测试 ===");

        // 1. 创建一级评论
        Long firstLevelId = createComment(testPostId, 0L, "一级评论");

        // 2. 创建二级评论(叶子节点)
        Long secondLevelId = createComment(testPostId, firstLevelId, "二级评论");

        // 刷新帖子评论数
        updatePostCommentCount(testPostId, 2);

        // 3. 删除二级评论
        commentService.deleteComment(secondLevelId);

        // 4. 验证
        assertFalse(isCommentDeleted(firstLevelId), "一级评论不应该被删除");
        assertTrue(isCommentDeleted(secondLevelId), "二级评论应该被删除");

        // 5. 验证帖子评论数减少1
        BusForumPostEntity post = postMapper.selectById(testPostId);
        assertEquals(1, post.getCommentCount(), "帖子评论数应该是1");

        log.info("=== 删除叶子节点评论测试通过 ===");
    }

    /**
     * 测试删除不存在的评论
     * 预期: 抛出ServiceException
     */
    @Test
    public void testDeleteNonExistentComment() {
        log.info("=== 开始删除不存在评论测试 ===");

        Long nonExistentId = 999999L;

        ServiceException exception = assertThrows(ServiceException.class, () -> {
            commentService.deleteComment(nonExistentId);
        });

        assertTrue(exception.getMessage().contains("评论不存在"),
                "异常信息应该包含'评论不存在'");

        log.info("=== 删除不存在评论测试通过 ===");
    }

    /**
     * 测试多层嵌套评论的级联删除
     *
     * 测试场景:
     * 创建一个5层深的评论树，删除根节点，验证所有子孙节点都被删除
     */
    @Test
    public void testDeepNestedCommentDeletion() {
        log.info("=== 开始深层嵌套评论删除测试 ===");

        // 创建5层深的评论树
        Long level1 = createComment(testPostId, 0L, "第1层评论");
        Long level2 = createComment(testPostId, level1, "第2层评论");
        Long level3 = createComment(testPostId, level2, "第3层评论");
        Long level4 = createComment(testPostId, level3, "第4层评论");
        Long level5 = createComment(testPostId, level4, "第5层评论");

        // 刷新帖子评论数
        updatePostCommentCount(testPostId, 5);

        log.info("创建5层深的评论树: {} -> {} -> {} -> {} -> {}",
                level1, level2, level3, level4, level5);

        // 删除根节点
        commentService.deleteComment(level1);

        // 验证所有层级的评论都被删除
        assertTrue(isCommentDeleted(level1), "第1层评论应该被删除");
        assertTrue(isCommentDeleted(level2), "第2层评论应该被删除");
        assertTrue(isCommentDeleted(level3), "第3层评论应该被删除");
        assertTrue(isCommentDeleted(level4), "第4层评论应该被删除");
        assertTrue(isCommentDeleted(level5), "第5层评论应该被删除");

        // 验证帖子评论数
        BusForumPostEntity post = postMapper.selectById(testPostId);
        assertEquals(0, post.getCommentCount(), "帖子评论数应该是0");

        log.info("=== 深层嵌套评论删除测试通过 ===");
    }

    /**
     * 测试批量删除一级评论
     *
     * 测试场景:
     * 创建多个独立的评论树，删除其中一个根节点，验证不影响其他树
     */
    @Test
    public void testDeleteMultipleCommentTrees() {
        log.info("=== 开始批量删除评论树测试 ===");

        // 创建2个独立的评论树
        Long tree1Root = createComment(testPostId, 0L, "树1-根评论");
        Long tree1Child1 = createComment(testPostId, tree1Root, "树1-子评论1");
        Long tree1Child2 = createComment(testPostId, tree1Root, "树1-子评论2");

        Long tree2Root = createComment(testPostId, 0L, "树2-根评论");
        Long tree2Child1 = createComment(testPostId, tree2Root, "树2-子评论1");

        // 刷新帖子评论数
        updatePostCommentCount(testPostId, 5);

        log.info("创建2个独立的评论树:");
        log.info("  树1: {} -> [{}, {}]", tree1Root, tree1Child1, tree1Child2);
        log.info("  树2: {} -> [{}]", tree2Root, tree2Child1);

        // 删除树1的根节点
        commentService.deleteComment(tree1Root);

        // 验证树1被完全删除
        assertTrue(isCommentDeleted(tree1Root), "树1根评论应该被删除");
        assertTrue(isCommentDeleted(tree1Child1), "树1子评论1应该被删除");
        assertTrue(isCommentDeleted(tree1Child2), "树1子评论2应该被删除");

        // 验证树2未被影响
        assertFalse(isCommentDeleted(tree2Root), "树2根评论不应该被删除");
        assertFalse(isCommentDeleted(tree2Child1), "树2子评论1不应该被删除");

        // 验证帖子评论数正确 (删除了3条)
        BusForumPostEntity post = postMapper.selectById(testPostId);
        assertEquals(2, post.getCommentCount(), "帖子评论数应该是2");

        log.info("=== 批量删除评论树测试通过 ===");
    }

    // ========== 辅助方法 ==========

    /**
     * 创建测试评论
     */
    private Long createComment(Long postId, Long parentId, String content) {
        BusForumCommentEntity comment = new BusForumCommentEntity();
        comment.setPostId(postId);
        comment.setUserId(testUserId);
        comment.setParentId(parentId);
        comment.setRootId(parentId == 0 ? 0L : parentId);
        comment.setToUserId(parentId == 0 ? null : testUserId);
        comment.setContent(content);
        comment.setLikeCount(0);
        comment.setStatus(0);
        comment.setDelFlag(0);

        commentMapper.insert(comment);
        log.debug("创建评论: commentId={}, parentId={}, content={}",
                comment.getCommentId(), parentId, content);

        return comment.getCommentId();
    }

    /**
     * 更新帖子评论数
     */
    private void updatePostCommentCount(Long postId, int count) {
        BusForumPostEntity post = postMapper.selectById(postId);
        post.setCommentCount(count);
        postMapper.updateById(post);
    }

    /**
     * 检查评论是否被删除
     */
    private boolean isCommentDeleted(Long commentId) {
        BusForumCommentEntity comment = commentMapper.selectById(commentId);
        return comment != null && comment.getDelFlag() == 1;
    }
}
