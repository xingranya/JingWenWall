<!--
  发现页头部组件
  包含搜索框和功能按钮
  参考 campus_social_feed 模板样式
-->
<template>
  <view class="forum-header safe-top">
    <view class="header-content">
      <!-- 搜索框 -->
      <view class="search-bar" @click="handleSearch">
        <uni-icons type="search" size="20" color="#94a3b8" />
        <text class="placeholder">搜索帖子、用户...</text>
      </view>
      
      <!-- 发布按钮 (可选，如果已有全局悬浮按钮可不需要) -->
      <!-- 这里暂时不放，保持原有设计 -->
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'ForumHeader',
  components: {
    uniIcons
  },
  methods: {
    handleSearch() {
      // TODO: 跳转搜索页
      uni.showToast({
        title: '搜索功能暂未开放',
        icon: 'none'
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.forum-header {
  position: sticky;
  top: 0;
  z-index: 40;
  background-color: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20rpx);
  -webkit-backdrop-filter: blur(20rpx);
  border-bottom: 1rpx solid $border-light;
}

.header-content {
  padding: 16rpx 24rpx;
  display: flex;
  align-items: center;
}

.search-bar {
  flex: 1;
  height: 72rpx;
  background-color: $surface-light;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  padding: 0 24rpx;
  gap: 16rpx;
  transition: all 0.2s ease;
  
  &:active {
    background-color: darken($surface-light, 5%);
  }
}

.placeholder {
  font-size: $font-sm;
  color: $text-tertiary-light;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .forum-header {
    background-color: rgba(27, 27, 29, 0.95);
    border-bottom-color: $border-dark;
  }
  
  .search-bar {
    background-color: $card-dark;
  }
}
</style>
