<!--
  Feed 流卡片组件
  支持多种样式：二手商品、求助/互动、活动通知
  参考 campus_home_dashboard 模板样式
-->
<template>
  <view class="feed-card" @click="handleClick">
    
    <!-- 类型 1: 带大图的卡片 (如二手商品、活动) -->
    <block v-if="post.images && post.images.length > 0">
      <view 
        class="card-image-wrapper"
        :style="{ backgroundImage: `url(${post.images[0]})` }"
      >
        <!-- 分类标签 -->
        <view class="category-tag glass-effect">
          <uni-icons type="tag" size="14" color="#0c141d" />
          <text class="tag-text">{{ post.category || '新鲜事' }}</text>
        </view>
        
        <!-- 收藏按钮 -->
        <view class="bookmark-btn glass-effect" @click.stop="onCollect">
          <uni-icons :type="post.isCollected ? 'star-filled' : 'star'" size="18" :color="post.isCollected ? '#ffcc00' : '#ffffff'" />
        </view>
      </view>
    </block>

    <!-- 头部用户信息 (仅无大图模式显示，或在大图下方显示) -->
    <view class="card-body">
      <!-- 标题和价格 -->
      <view class="card-header-row">
        <view class="title-wrapper">
          <text class="card-title line-clamp-1">{{ post.title }}</text>
          <text class="card-subtitle line-clamp-1">{{ post.content }}</text>
        </view>
        <!-- 价格 (如果是二手商品) -->
        <view v-if="post.price" class="price-tag">
          <text>¥{{ post.price }}</text>
        </view>
      </view>

      <!-- 底部信息：发布者和互动数据 -->
      <view class="card-footer">
        <view class="user-info">
          <image 
            class="avatar-sm" 
            :src="post.avatar || '/static/default_avatar.jpg'" 
            mode="aspectFill"
          />
          <view class="user-meta">
            <text class="user-name">{{ post.nickName || '匿名同学' }}</text>
            <text class="post-time">{{ formatTime(post.createTime) }}</text>
          </view>
        </view>
        
        <!-- 私信按钮或互动数 -->
        <view class="interactions">
          <view v-if="showInteractions" class="interaction-stats">
            <view class="stat-item">
              <uni-icons type="heart" size="16" color="#94a3b8" />
              <text>{{ post.likeCount }}</text>
            </view>
            <view class="stat-item">
              <uni-icons type="chat" size="16" color="#94a3b8" />
              <text>{{ post.commentCount }}</text>
            </view>
          </view>
          <view v-else class="action-btn" @click.stop="onAction">
            <text>查看</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'FeedCard',
  components: {
    uniIcons
  },
  props: {
    post: {
      type: Object,
      required: true
    },
    // 是否显示互动数据（点赞评论数）
    showInteractions: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    handleClick() {
      this.$emit('click', this.post);
    },
    onCollect() {
      this.$emit('collect', this.post);
    },
    onAction() {
      this.$emit('action', this.post);
    },
    formatTime(time) {
      if (!time) return '';
      // 简单处理，可引入 dayjs
      return time.split(' ')[0];
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.feed-card {
  background-color: $background-light;
  border-radius: $radius-lg;
  margin-bottom: $spacing-md;
  box-shadow: $shadow-soft;
  border: 1rpx solid $border-light;
  overflow: hidden;
  transition: all 0.3s ease;
  
  &:active {
    transform: scale(0.98);
  }
}

.card-image-wrapper {
  position: relative;
  width: 100%;
  padding-bottom: 75%; // 4:3 比例
  background-size: cover;
  background-position: center;
  background-color: $surface-light;
}

.category-tag {
  position: absolute;
  top: 24rpx;
  left: 24rpx;
  padding: 8rpx 16rpx;
  border-radius: $radius-sm;
  display: flex;
  align-items: center;
  gap: 8rpx;
  background-color: rgba(255, 255, 255, 0.9);
  
  .tag-text {
    font-size: $font-xs;
    font-weight: 700;
    color: $text-primary-light;
  }
}

.bookmark-btn {
  position: absolute;
  top: 24rpx;
  right: 24rpx;
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background-color: rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  
  &:active {
    background-color: rgba(0, 0, 0, 0.4);
  }
}

.card-body {
  padding: $spacing-md;
}

.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: $spacing-sm;
}

.title-wrapper {
  flex: 1;
  margin-right: $spacing-sm;
}

.card-title {
  font-size: $font-lg;
  font-weight: 700;
  color: $text-primary-light;
  line-height: 1.4;
  margin-bottom: 4rpx;
}

.card-subtitle {
  font-size: $font-sm;
  color: $text-secondary-light;
}

.price-tag {
  font-size: $font-lg;
  font-weight: 700;
  color: $primary;
  background-color: $primary-light;
  padding: 4rpx 12rpx;
  border-radius: $radius-sm;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: $spacing-sm;
  border-top: 1rpx solid $surface-light;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.user-meta {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: $font-xs;
  font-weight: 700;
  color: $text-secondary-light;
}

.post-time {
  font-size: 20rpx;
  color: $text-tertiary-light;
}

.action-btn {
  font-size: $font-xs;
  font-weight: 700;
  color: $primary;
}

.interaction-stats {
  display: flex;
  gap: 20rpx;
  
  .stat-item {
    display: flex;
    align-items: center;
    gap: 4rpx;
    font-size: $font-xs;
    color: $text-tertiary-light;
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .feed-card {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }
  
  .card-title {
    color: $text-primary-dark;
  }
  
  .category-tag {
    background-color: rgba(0, 0, 0, 0.6);
    
    .tag-text {
      color: $text-primary-dark;
    }
  }
  
  .card-footer {
    border-top-color: rgba(255, 255, 255, 0.05);
  }
  
  .user-name {
    color: $text-secondary-dark;
  }
}
</style>
