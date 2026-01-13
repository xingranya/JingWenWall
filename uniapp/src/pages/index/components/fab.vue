<template>
  <view class="fab-wrapper">
    <!-- 展开菜单 -->
    <view v-if="isOpen" class="fab-menu">
      <view class="fab-menu-item" @click="navigateToTopicPage">
        <uni-icons type="compose" size="20" color="#007AFF" />
        <text class="fab-menu-text">发布话题</text>
      </view>
      <view class="fab-menu-item" @click="navigateToFavoritesPage">
        <uni-icons type="star" size="20" color="#ff9500" />
        <text class="fab-menu-text">我的收藏</text>
      </view>
    </view>
    
    <!-- 主按钮 -->
    <view class="fab-btn" :class="{ 'fab-btn-active': isOpen }" @click="toggleMenu">
      <view class="fab-icon-wrapper" :class="{ 'fab-icon-rotate': isOpen }">
        <uni-icons type="plusempty" size="28" color="#ffffff" />
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  components: {
    uniIcons
  },
  data() {
    return {
      isOpen: false
    }
  },
  methods: {
    toggleMenu() {
      this.isOpen = !this.isOpen;
    },
    navigateToTopicPage() {
      this.isOpen = false;
      uni.navigateTo({
        url: '/pages/topic/create'
      });
    },
    navigateToFavoritesPage() {
      this.isOpen = false;
      uni.navigateTo({
        url: '/pages/favorites/index'
      });
    }
  }
}
</script>

<style lang="scss" scoped>
/* 悬浮发布按钮 - 统一蓝色样式 */
.fab-wrapper {
  position: fixed;
  right: 40rpx;
  bottom: calc(160rpx + env(safe-area-inset-bottom));
  z-index: 999;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.fab-btn {
  width: 112rpx;
  height: 112rpx;
  border-radius: 50%;
  background-color: #007AFF;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 32rpx rgba(0, 122, 255, 0.4);
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.95);
  }
  
  &.fab-btn-active {
    background-color: #ff3b30;
    box-shadow: 0 8rpx 32rpx rgba(255, 59, 48, 0.4);
  }
}

/* 图标旋转动画 */
.fab-icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.3s ease;
}

.fab-icon-rotate {
  transform: rotate(45deg);
}

.fab-menu {
  margin-bottom: 20rpx;
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.fab-menu-item {
  display: flex;
  align-items: center;
  background: #fff;
  padding: 20rpx 28rpx;
  border-radius: 48rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.12);
  
  &:active {
    background: #f5f5f5;
    transform: scale(0.98);
  }
}

.fab-menu-text {
  font-size: 28rpx;
  color: #333;
  margin-left: 12rpx;
  white-space: nowrap;
  font-weight: 500;
}

/* 深色模式 */
@media (prefers-color-scheme: dark) {
  .fab-btn {
    background-color: #0A84FF;
    box-shadow: 0 8rpx 32rpx rgba(10, 132, 255, 0.4);
    
    &.fab-btn-active {
      background-color: #ff453a;
    }
  }
  
  .fab-menu-item {
    background: #2c2c2e;
  }
  
  .fab-menu-text {
    color: #fff;
  }
}
</style>
