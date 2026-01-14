<template>
  <view class="topic-view">
    <scroll-view scroll-y class="topic-scroll" :refresher-enabled="false" @scrolltolower="loadComments">
      <view class="safe-padding content-wrapper">
        <view v-if="topicRecord && topicRecord.postId" class="post-card">
          <view class="post-header">
            <view class="user-left">
              <image class="avatar avatar-md" :src="formatAvatarUrl(topicRecord.avatar)" mode="aspectFill" />
              <view class="user-meta">
                <text class="user-name line-clamp-1">{{ topicRecord.nickName || '匿名用户' }}</text>
                <text class="post-time">{{ formatTime(topicRecord.createTime) }}</text>
              </view>
            </view>
            <view class="header-actions" @click.stop="showActionSheet">
              <view class="icon-btn">
                <uni-icons type="more" size="22" :color="iconMutedColor" />
              </view>
            </view>
          </view>

          <view v-if="topicRecord.title" class="post-title">{{ topicRecord.title }}</view>
          <view v-if="topicRecord.content" class="post-content">
            <text selectable>{{ topicRecord.content }}</text>
          </view>

          <view v-if="postImages.length" class="image-grid" :class="imageGridClass">
            <view
              v-for="(img, index) in postImages"
              :key="index"
              class="image-item"
              @click.stop="previewPostImages(index)"
            >
              <image class="post-image" :src="img" mode="aspectFill" />
            </view>
          </view>

          <view class="post-stats">
            <text class="stat">浏览 {{ topicRecord.viewCount || 0 }}</text>
            <text class="dot">·</text>
            <text class="stat">点赞 {{ topicRecord.likeCount || 0 }}</text>
            <text class="dot">·</text>
            <text class="stat">评论 {{ topicRecord.commentCount || 0 }}</text>
            <text class="dot">·</text>
            <text class="stat">收藏 {{ topicRecord.collectCount || 0 }}</text>
          </view>
        </view>

        <view class="comment-section">
          <view class="section-header">
            <text class="section-title">全部评论</text>
            <text class="section-count">({{ topicRecord.commentCount || 0 }})</text>
          </view>

          <view v-if="comments && comments.length" class="comment-list">
            <view v-for="(comment, index) in comments" :key="comment.commentId || comment.id || index" class="comment-item">
              <image class="avatar avatar-md" :src="formatAvatarUrl(comment.avatar)" mode="aspectFill" />
              <view class="comment-main">
                <view class="comment-head">
                  <view class="comment-meta">
                    <text class="comment-name line-clamp-1">{{ comment.nickName || '匿名用户' }}</text>
                    <text class="comment-time">{{ formatTime(comment.createTime) }}</text>
                  </view>
                  <view class="comment-more" @click.stop="showCommentActionSheet(comment)">
                    <uni-icons type="more" size="18" :color="iconMutedColor" />
                  </view>
                </view>

                <view v-if="comment.content" class="comment-text">
                  <text selectable>{{ comment.content }}</text>
                </view>

                <view class="comment-actions">
                  <view class="action-btn" @click.stop="toggleCommentLike(comment)">
                    <uni-icons
                      :type="comment.isLiked ? 'heart-filled' : 'heart'"
                      size="18"
                      :color="comment.isLiked ? likedColor : iconMutedColor"
                    />
                    <text class="action-text">{{ comment.likeCount || 0 }}</text>
                  </view>
                  <view class="action-btn" @click.stop="replyToComment(comment)">
                    <uni-icons type="chatbubble" size="18" :color="iconMutedColor" />
                    <text class="action-text">回复</text>
                  </view>
                </view>
              </view>
            </view>
            <uni-load-more :status="loadMoreStatus" @loadmore="loadComments" />
          </view>

          <view v-else class="empty-comment">
            <text class="empty-text">暂无评论，快来发表第一条评论吧~</text>
          </view>
        </view>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <view class="bar-inner">
        <view class="bar-input" @click="openCommentPopup">
          <uni-icons type="compose" size="18" :color="iconMutedColor" />
          <text class="bar-placeholder">说点什么...</text>
        </view>
        <view class="bar-actions">
          <view class="bar-btn" @click.stop="handleLike">
            <uni-icons :type="topicRecord.isLiked ? 'heart-filled' : 'heart'" size="22" :color="topicRecord.isLiked ? likedColor : iconMutedColor" />
            <text class="bar-count">{{ topicRecord.likeCount || 0 }}</text>
          </view>
          <view class="bar-btn" @click.stop="handleCollect">
            <uni-icons :type="topicRecord.isCollected ? 'star-filled' : 'star'" size="22" :color="topicRecord.isCollected ? collectedColor : iconMutedColor" />
            <text class="bar-count">{{ topicRecord.collectCount || 0 }}</text>
          </view>
          <view class="bar-btn" @click.stop="openCommentPopup">
            <uni-icons type="chatbubble" size="22" :color="iconMutedColor" />
            <text class="bar-count">{{ topicRecord.commentCount || 0 }}</text>
          </view>
        </view>
      </view>
    </view>

    <uni-popup ref="commentPopup" type="bottom" :safe-area="true">
      <view class="comment-popup">
        <view class="popup-header">
          <text class="popup-title">发表评论</text>
          <view class="popup-close" @click="closeCommentPopup">
            <uni-icons type="closeempty" size="20" :color="iconMutedColor" />
          </view>
        </view>
        <view class="popup-body">
          <uni-easyinput
            v-model="commentContent"
            type="textarea"
            :autoHeight="true"
            maxlength="500"
            placeholder="请输入评论内容..."
            :focus="true"
            class="popup-input"
          />
          <button class="popup-submit btn-primary" @click="submitComment">发送</button>
        </view>
      </view>
    </uni-popup>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';
import uniPopup from '@dcloudio/uni-ui/lib/uni-popup/uni-popup.vue';
import uniLoadMore from '@dcloudio/uni-ui/lib/uni-load-more/uni-load-more.vue';
import uniEasyinput from '@dcloudio/uni-ui/lib/uni-easyinput/uni-easyinput.vue';

import { deleteTopic, fetchTopic } from "@/api/topic";

import {
  deleteComment,
  fetchComments,
  likeComment,
  submitComment,
  unlikeComment,
} from "@/api/comment";

import {likeTopic, unlikeTopic} from "@/api/like";
import {collectTopic, uncollectTopic} from "@/api/collect";
import {getCurrentUserInfo} from "@/api/user";
import { baseUrl } from "@/utils/env";
import { createEmptyForumPost } from "@/models/ForumPost";

export default {
  components: {
    uniIcons,
    uniPopup,
    uniLoadMore,
    uniEasyinput,
  },
  data() {
    return {
      topicRecord: createEmptyForumPost(),
      userInfoMap: {},
      isLiked: false,
      isCollected: false,
      commentContent: "", // 确保在这里正确初始化
      comments: [],
      loadMoreStatus: 'more',
      currentUserId: '',
      topicId: '',
      page: 1,
      pageSize: 5,
      commentCount: 0,
      likeCount: 0,
      collectCount: 0,
      commentLikeCount: 0,
    };
  },
  computed: {
    iconMutedColor() {
      return '#94a3b8';
    },
    likedColor() {
      return '#ff3b30';
    },
    collectedColor() {
      return '#ffcc00';
    },
    postImages() {
      const list = Array.isArray(this.topicRecord?.images) ? this.topicRecord.images : [];
      return list
        .filter((x) => typeof x === 'string' && x.trim())
        .map((x) => this.formatMediaUrl(x.trim()));
    },
    imageGridClass() {
      const n = this.postImages.length;
      if (n <= 1) return 'count-1';
      if (n === 2) return 'count-2';
      return 'count-3';
    }
  },
  async onLoad(options) {
    const topicId = options?.topicId || options?.postId || options?.id;
    this.topicId = topicId;
    try {
      this.currentUserId = await this.getCurrentUserIdSafely();
      const post = await fetchTopic(topicId);
      this.topicRecord = this.normalizePost(post, topicId);
      await this.loadComments();
    } catch (error) {
      console.error("加载数据失败:", error);
      await uni.showToast({
        title: '加载数据失败',
        icon: 'none'
      });
    }
  },
  onReachBottom() {
    this.loadComments();
  },
  methods: {
    normalizePost(post, fallbackId) {
      const base = createEmptyForumPost();
      const source = post && typeof post === 'object' ? post : {};
      const postId = source.postId || source.id || fallbackId || null;
      const images = source.images || source.imgURLs || [];
      return {
        ...base,
        ...source,
        postId,
        images: Array.isArray(images) ? images : [],
      };
    },

    async getCurrentUserIdSafely() {
      try {
        const currentUser = await getCurrentUserInfo();
        const id = currentUser?.userId || currentUser?.id || '';
        if (id) return String(id);
      } catch (e) {
        console.error('获取当前用户信息失败:', e);
      }
      try {
        const raw = uni.getStorageSync('userInfo');
        const parsed = typeof raw === 'string' ? JSON.parse(raw) : raw;
        const id = parsed?.userId || parsed?.id || '';
        return id ? String(id) : '';
      } catch (e) {
        return '';
      }
    },

    fetchTopicNoCache(postId) {
      return new Promise((resolve, reject) => {
        uni.request({
          url: `${baseUrl}/api/v1/forum/posts/${postId}?_t=${Date.now()}`,
          method: 'GET',
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${uni.getStorageSync('token')}`
          },
          success: (res) => {
            if (res.statusCode === 200 && res.data && res.data.code === 200) {
              resolve(res.data.data);
            } else {
              reject(res?.data?.msg || '获取失败');
            }
          },
          fail: (err) => reject(err),
        });
      });
    },

    /**
     * 加载评论
     */
    async loadComments() {
      if (this.loadMoreStatus === 'loading' || this.loadMoreStatus === 'noMore') {
        return;
      }
      this.loadMoreStatus = 'loading';
      try {
        const res = await fetchComments(this.topicId, this.page, this.pageSize);
        const commentList = res.rows || res.records || [];
        if (commentList && commentList.length > 0) {
          this.comments = this.comments.concat(commentList);
          if (commentList.length < this.pageSize) {
            this.loadMoreStatus = 'noMore';
          } else {
            this.loadMoreStatus = 'more';
            this.page++;
          }
        } else {
          this.loadMoreStatus = 'noMore';
        }
      } catch (error) {
        console.error('请求失败', error);
        this.loadMoreStatus = 'more';
        await uni.showToast({title: '加载失败', icon: 'none'});
      }
    },

    /**
     * 格式化媒体URL，确保包含baseUrl
     */
    formatMediaUrl(url) {
      if (!url || typeof url !== 'string') return '';
      const v = url.trim();
      if (!v) return '';
      if (/^https?:\/\//i.test(v) || /^data:/i.test(v)) return v;
      if (v.startsWith('//')) return `https:${v}`;
      if (v.startsWith('/static/')) return v;
      if (v.startsWith('static/')) return `/${v}`;
      if (v.startsWith('/')) return `${baseUrl}${v}`;
      return `${baseUrl}/${v}`;
    },

    formatAvatarUrl(url) {
      return this.formatMediaUrl(url) || '/static/default_avatar.jpg';
    },

    formatTime(time) {
      if (!time) return '';
      const s = String(time);
      if (s.includes(' ')) return s.split(' ')[0];
      if (s.includes('T')) return s.split('T')[0];
      return s;
    },

    previewPostImages(index) {
      const urls = this.postImages;
      const current = urls[index] || urls[0];
      if (!current) return;
      uni.previewImage({
        urls,
        current,
      });
    },
    /**
     * 显示操作菜单
     */
    showActionSheet() {
      const isAuthor = String(this.currentUserId) && String(this.currentUserId) === String(this.topicRecord.userId);
      const itemList = isAuthor ? ['删除', '举报'] : ['举报'];

      uni.showActionSheet({
        itemList: itemList,
        success: (res) => {
          if (isAuthor && res.tapIndex === 0) {
            this.deleteTopic();
          } else if ((isAuthor && res.tapIndex === 1) || (!isAuthor && res.tapIndex === 0)) {
            uni.navigateTo({
              url: `/pages/topic/report?topicId=${this.topicRecord.postId}`,
            });
          }
        },
        fail: (res) => {
          console.log(res.errMsg);
        }
      });
    },

    /**
     * 显示评论操作菜单
     */
    showCommentActionSheet(comment) {
      const isAuthor = String(this.currentUserId) === String(comment.userId);
      const itemList = isAuthor ? ['删除', '举报'] : ['举报'];

      uni.showActionSheet({
        itemList: itemList,
        success: (res) => {
          if (isAuthor && res.tapIndex === 0) {
            // 作者选择了“删除”
            this.deleteCommentAction(comment);
          } else if ((isAuthor && res.tapIndex === 1) || (!isAuthor && res.tapIndex === 0)) {
            uni.navigateTo({
              url: `/pages/topic/report?topicId=${this.topicRecord.postId}&commentId=${comment.commentId || comment.id}`,
            });
          }
        },
        fail: (res) => {
          console.log(res.errMsg);
        }
      });
    },

    /**
     * 打开评论弹窗
     */
    openCommentPopup() {
      this.$refs.commentPopup.open();
    },

    closeCommentPopup() {
      this.$refs.commentPopup.close();
    },

    // 创建话题不在该页面
    /**
     * 删除话题
     */
    async deleteTopic() {
      const postId = this.topicRecord?.postId;
      if (!postId) {
        await uni.showToast({ title: '删除失败', icon: 'none' });
        return;
      }

      const isAuthor = String(this.currentUserId) && String(this.currentUserId) === String(this.topicRecord.userId);
      if (!isAuthor) {
        await uni.showToast({ title: '无权限删除', icon: 'none' });
        return;
      }

      try {
        const res = await uni.showModal({
          title: '确认删除',
          content: '确定要删除此项吗？',
          confirmText: '删除',
          cancelText: '取消',
        });

        if (!res.confirm) return;

        const beforeStatus = this.topicRecord?.status;
        const deleteMsg = await deleteTopic(postId);

        let isReallyDeleted = false;
        for (let i = 0; i < 3; i++) {
          try {
            const post = await this.fetchTopicNoCache(postId);
            const afterStatus = post?.status;
            if (afterStatus !== undefined && beforeStatus !== undefined && String(afterStatus) !== String(beforeStatus)) {
              isReallyDeleted = true;
              break;
            }
            isReallyDeleted = false;
          } catch (e) {
            isReallyDeleted = true;
            break;
          }
          await new Promise((r) => setTimeout(r, 250 * (i + 1)));
        }

        if (!isReallyDeleted) {
          await uni.showToast({ title: String(deleteMsg || '删除未生效，请稍后重试'), icon: 'none' });
          return;
        }

        this.topicRecord = createEmptyForumPost();
        this.comments = [];
        this.page = 1;
        this.loadMoreStatus = 'more';

        try {
          const deletedId = String(postId);
          uni.setStorageSync('deletedPostId', deletedId);
          uni.$emit && uni.$emit('topic:deleted', deletedId);
        } catch (e) {
        }

        await uni.showToast({ title: '删除成功', icon: 'success' });

        setTimeout(() => {
          const pages = getCurrentPages();
          if (pages && pages.length > 1) {
            uni.navigateBack({ delta: 1 });
          } else {
            uni.reLaunch({ url: '/pages/index/index' });
          }
        }, 500);
      } catch (error) {
        console.error('删除失败:', error);
        await uni.showToast({ title: String(error?.message || error || '删除失败'), icon: 'none' });
      }
    },

    /**
     * 处理点赞操作
     */
    async handleLike() {
      try {
        if (this.topicRecord.isLiked) {
          await unlikeTopic(this.topicRecord.postId);
          this.topicRecord.isLiked = false;
          this.topicRecord.likeCount = Math.max(0, this.topicRecord.likeCount - 1);
          await uni.showToast({ title: "取消点赞成功", icon: "success" });
        } else {
          await likeTopic(this.topicRecord.postId);
          this.topicRecord.isLiked = true;
          this.topicRecord.likeCount += 1;
          await uni.showToast({ title: "点赞成功", icon: "success" });
        }
      } catch (error) {
        console.error("点赞操作失败:", error);
        await uni.showToast({ title: "操作失败", icon: "none" });
      }
    },

    /**
     * 处理收藏操作
     */
    async handleCollect() {
      try {
        if (this.topicRecord.isCollected) {
          await uncollectTopic(this.topicRecord.postId);
          this.topicRecord.isCollected = false;
          this.topicRecord.collectCount = Math.max(0, this.topicRecord.collectCount - 1);
          await uni.showToast({ title: "取消收藏成功", icon: "success" });
        } else {
          await collectTopic(this.topicRecord.postId);
          this.topicRecord.isCollected = true;
          this.topicRecord.collectCount += 1;
          await uni.showToast({ title: "收藏成功", icon: "success" });
        }
      } catch (error) {
        console.error("收藏操作失败:", error);
        await uni.showToast({ title: "操作失败", icon: "none" });
      }
    },

    /**
     * 提交评论
     */
    async submitComment() {
      if (!this.commentContent.trim()) {
        await uni.showToast({ title: "评论内容不能为空", icon: "none" });
        return;
      }
      try {
        await submitComment(this.topicRecord.postId, this.commentContent);
        await uni.showToast({ title: "评论成功", icon: "success" });
        await this.refreshComments();
        this.commentContent = "";
        this.$refs.commentPopup.close();
      } catch (error) {
        console.error("评论失败:", error);
        await uni.showToast({ title: String(error || '评论失败') , icon: "none" });
      }
    },

    /**
     * 刷新评论列表和计数
     */
    async refreshComments() {
      try {
        const post = await fetchTopic(this.topicRecord.postId);
        this.topicRecord = this.normalizePost(post, this.topicRecord.postId);
        this.page = 1;
        this.comments = [];
        this.loadMoreStatus = 'more';
        await this.loadComments();
      } catch (error) {
        console.error("刷新评论失败:", error);
        await uni.showToast({title: "刷新评论失败", icon: "none"});
      }
    },

    /**
     * 删除评论
     */
    async deleteCommentAction(comment) {
      try {
        const res = await uni.showModal({
          title: '确认删除',
          content: '您确定要删除这条评论吗？',
          confirmText: '删除',
          cancelText: '取消',
        });

        if (res.confirm) {
          const commentId = comment.commentId || comment.id;
          await deleteComment(commentId);
          await uni.showToast({ title: '删除成功', icon: 'success' });
          await this.refreshComments();
        }
      } catch (error) {
        console.error('删除评论失败:', error);
        await uni.showToast({ title: '删除失败', icon: 'none' });
      }
    },

    /**
     * 回复评论
     */
    async replyToComment(comment) {
      // TODO: 实现回复评论功能
      await uni.showToast({ title: "回复评论功能暂未开放", icon: "none" });
    },

    /**
     * 点赞/取消点赞评论
     */
    async toggleCommentLike(comment) {
      try {
        if (comment.isLiked) {
          await unlikeComment(comment.commentId);
          comment.isLiked = false;
          comment.likeCount = Math.max(0, comment.likeCount - 1);
          await uni.showToast({ title: "取消点赞成功", icon: "success" });
        } else {
          await likeComment(comment.commentId);
          comment.isLiked = true;
          comment.likeCount += 1;
          await uni.showToast({ title: "点赞成功", icon: "success" });
        }
      } catch (error) {
        console.error("评论点赞操作失败:", error);
        await uni.showToast({ title: "操作失败", icon: "none" });
      }
    }
  },
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.topic-view {
  height: 100vh;
  background-color: $background-dim;
}

.topic-scroll {
  height: 100%;
}

.safe-padding {
  padding-left: 40rpx;
  padding-right: 40rpx;
}

.content-wrapper {
  padding-top: $spacing-md;
  padding-bottom: calc(160rpx + env(safe-area-inset-bottom));
}

.post-card {
  background-color: $background-light;
  border-radius: $radius-lg;
  box-shadow: $shadow-soft;
  border: 1rpx solid $border-light;
  overflow: hidden;
  padding: $spacing-lg;
}

.post-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: $spacing-md;
}

.user-left {
  display: flex;
  align-items: center;
  gap: 16rpx;
  min-width: 0;
}

.avatar {
  border-radius: $radius-full;
  background-color: $surface-light;
}

.user-meta {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.user-name {
  font-size: $font-sm;
  font-weight: 700;
  color: $text-primary-light;
  line-height: 1.2;
}

.post-time {
  font-size: $font-xs;
  color: $text-tertiary-light;
  margin-top: 4rpx;
}

.header-actions {
  flex: 0 0 auto;
}

.icon-btn {
  width: 80rpx;
  height: 80rpx;
  border-radius: $radius-full;
  background-color: $surface-light;
  display: flex;
  align-items: center;
  justify-content: center;

  &:active {
    transform: scale(0.95);
    background-color: darken($surface-light, 5%);
  }
}

.post-title {
  font-size: $font-xl;
  font-weight: 800;
  color: $text-primary-light;
  letter-spacing: -1rpx;
  margin-bottom: $spacing-sm;
}

.post-content {
  font-size: $font-base;
  color: $text-primary-light;
  line-height: 1.7;
  margin-bottom: $spacing-md;
  word-break: break-all;
}

.image-grid {
  display: grid;
  gap: 16rpx;
  margin-top: $spacing-sm;
  margin-bottom: $spacing-md;
}

.image-grid.count-1 {
  grid-template-columns: 1fr;
}

.image-grid.count-2 {
  grid-template-columns: 1fr 1fr;
}

.image-grid.count-3 {
  grid-template-columns: 1fr 1fr 1fr;
}

.image-item {
  position: relative;
  width: 100%;
  border-radius: $radius-md;
  overflow: hidden;
  background-color: $surface-light;
}

.image-item::before {
  content: '';
  display: block;
  padding-bottom: 100%;
}

.post-image {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

.post-stats {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8rpx;
  font-size: $font-xs;
  color: $text-tertiary-light;
  padding-top: $spacing-sm;
  border-top: 1rpx solid $border-light;
}

.stat {
  color: $text-secondary-light;
}

.dot {
  color: $text-tertiary-light;
}

.comment-section {
  margin-top: $spacing-lg;
}

.section-header {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
  margin-bottom: $spacing-md;
}

.section-title {
  font-size: $font-lg;
  font-weight: 800;
  color: $text-primary-light;
}

.section-count {
  font-size: $font-sm;
  color: $text-tertiary-light;
}

.comment-list {
  background-color: $background-light;
  border-radius: $radius-lg;
  box-shadow: $shadow-soft;
  border: 1rpx solid $border-light;
  overflow: hidden;
}

.comment-item {
  display: flex;
  gap: 16rpx;
  padding: $spacing-lg;
  border-bottom: 1rpx solid $border-light;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-main {
  flex: 1;
  min-width: 0;
}

.comment-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12rpx;
}

.comment-meta {
  min-width: 0;
}

.comment-name {
  font-size: $font-sm;
  font-weight: 700;
  color: $text-primary-light;
}

.comment-time {
  display: block;
  margin-top: 4rpx;
  font-size: $font-xs;
  color: $text-tertiary-light;
}

.comment-more {
  width: 64rpx;
  height: 64rpx;
  border-radius: $radius-full;
  background-color: $surface-light;
  display: flex;
  align-items: center;
  justify-content: center;

  &:active {
    transform: scale(0.95);
    background-color: darken($surface-light, 5%);
  }
}

.comment-text {
  margin-top: $spacing-sm;
  font-size: $font-base;
  color: $text-primary-light;
  line-height: 1.6;
  word-break: break-all;
}

.comment-actions {
  display: flex;
  align-items: center;
  gap: 24rpx;
  margin-top: $spacing-sm;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 8rpx 12rpx;
  border-radius: $radius-full;
  background-color: $surface-light;

  &:active {
    transform: scale(0.98);
    background-color: darken($surface-light, 5%);
  }
}

.action-text {
  font-size: $font-xs;
  color: $text-secondary-light;
  font-weight: 600;
}

.empty-comment {
  background-color: $background-light;
  border-radius: $radius-lg;
  padding: $spacing-xl;
  border: 1rpx solid $border-light;
  text-align: center;
}

.empty-text {
  font-size: $font-sm;
  color: $text-tertiary-light;
}

.bottom-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 16rpx 24rpx calc(16rpx + env(safe-area-inset-bottom));
  background-color: rgba(255, 255, 255, 0.9);
  border-top: 1rpx solid $border-light;
  box-shadow: $shadow-nav;
  backdrop-filter: blur(20rpx);
  -webkit-backdrop-filter: blur(20rpx);
}

.bar-inner {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.bar-input {
  flex: 1;
  height: 88rpx;
  border-radius: $radius-full;
  background-color: $surface-light;
  border: 1rpx solid $border-light;
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 0 24rpx;

  &:active {
    background-color: darken($surface-light, 3%);
  }
}

.bar-placeholder {
  font-size: $font-sm;
  color: $text-tertiary-light;
}

.bar-actions {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.bar-btn {
  height: 88rpx;
  border-radius: $radius-full;
  background-color: $surface-light;
  border: 1rpx solid $border-light;
  padding: 0 20rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;

  &:active {
    transform: scale(0.98);
    background-color: darken($surface-light, 5%);
  }
}

.bar-count {
  font-size: $font-xs;
  color: $text-secondary-light;
  font-weight: 700;
}

.comment-popup {
  background-color: $background-light;
  border-top-left-radius: $radius-2xl;
  border-top-right-radius: $radius-2xl;
  padding: $spacing-lg;
  border: 1rpx solid $border-light;
}

.popup-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: $spacing-md;
}

.popup-title {
  font-size: $font-lg;
  font-weight: 800;
  color: $text-primary-light;
}

.popup-close {
  width: 72rpx;
  height: 72rpx;
  border-radius: $radius-full;
  background-color: $surface-light;
  display: flex;
  align-items: center;
  justify-content: center;

  &:active {
    transform: scale(0.95);
    background-color: darken($surface-light, 5%);
  }
}

.popup-body {
  display: flex;
  flex-direction: column;
  gap: $spacing-md;
}

.popup-input {
  border-radius: $radius-lg;
  overflow: hidden;
}

.popup-submit {
  width: 100%;
}

@media (prefers-color-scheme: dark) {
  .topic-view {
    background-color: $background-dark;
  }

  .post-card,
  .comment-list,
  .empty-comment,
  .comment-popup {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }

  .user-name,
  .post-title,
  .post-content,
  .section-title,
  .comment-name,
  .comment-text,
  .popup-title {
    color: $text-primary-dark;
  }

  .post-time,
  .section-count,
  .comment-time,
  .empty-text {
    color: $text-tertiary-dark;
  }

  .post-stats,
  .comment-item {
    border-bottom-color: rgba(255, 255, 255, 0.05);
  }

  .post-stats {
    border-top-color: rgba(255, 255, 255, 0.05);
  }

  .icon-btn,
  .comment-more,
  .action-btn,
  .bar-input,
  .bar-btn,
  .popup-close {
    background-color: $surface-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }

  .bottom-bar {
    background-color: rgba(27, 27, 29, 0.9);
    border-top-color: rgba(255, 255, 255, 0.05);
  }
}
</style>
