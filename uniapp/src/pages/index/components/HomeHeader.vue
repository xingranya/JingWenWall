<!--
  首页头部组件
  包含用户头像和通知按钮
  参考 campus_home_dashboard 模板样式
-->
<template>
  <view class="header">
    <view class="header-inner">
      <!-- 用户头像 -->
      <view class="avatar-wrapper" @click="goToProfile">
        <image 
          class="avatar" 
          :src="userAvatar || '/static/default_avatar.jpg'" 
          mode="aspectFill"
        />
        <!-- 在线状态指示器 -->
        <view class="status-dot"></view>
      </view>
      
      <!-- 通知按钮 -->
      <view class="notification-btn" @click="goToNotifications">
        <uni-icons type="notification" size="24" color="#64748b" />
        <!-- 红点角标 -->
        <view v-if="hasUnread" class="notification-badge"></view>
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'HomeHeader',
  components: {
    uniIcons
  },
  props: {
    // 用户头像 URL
    userAvatar: {
      type: String,
      default: ''
    },
    // 是否有未读消息
    hasUnread: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    /**
     * 跳转到个人中心
     */
    goToProfile() {
      uni.navigateTo({
        url: '/pages/person/person'
      });
    },
    /**
     * 跳转到消息通知
     */
    goToNotifications() {
      uni.navigateTo({
        url: '/pages/message/index'
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.header {
  position: sticky;
  top: 0;
  z-index: 40;
  background-color: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20rpx);
  -webkit-backdrop-filter: blur(20rpx);
  transition: all 0.3s ease;
}

.header-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 40rpx;
}

.avatar-wrapper {
  position: relative;
  cursor: pointer;
}

.avatar {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  border: 4rpx solid #ffffff;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  background-color: #e2e8f0;
}

.status-dot {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 24rpx;
  height: 24rpx;
  border-radius: 50%;
  background-color: #22c55e;
  border: 4rpx solid #ffffff;
}

.notification-btn {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  background-color: $surface-light;
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.95);
    background-color: darken($surface-light, 5%);
  }
}

.notification-badge {
  position: absolute;
  top: 16rpx;
  right: 20rpx;
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  background-color: #ef4444;
  border: 4rpx solid #ffffff;
  box-shadow: 0 2rpx 8rpx rgba(239, 68, 68, 0.3);
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .header {
    background-color: rgba(27, 27, 29, 0.9);
  }
  
  .avatar {
    border-color: #334155;
  }
  
  .status-dot {
    border-color: $background-dark;
  }
  
  .notification-btn {
    background-color: $card-dark;
  }
  
  .notification-badge {
    border-color: $card-dark;
  }
}
</style>
