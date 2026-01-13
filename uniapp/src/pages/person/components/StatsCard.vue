<!--
  统计数据卡片组件
  展示动态、关注、粉丝等数据
-->
<template>
  <view class="stats-card">
    <view class="stat-item" @click="handleClick('posts')">
      <text class="stat-value">{{ stats.posts || 0 }}</text>
      <text class="stat-label">动态</text>
    </view>
    <view class="divider"></view>
    <view class="stat-item" @click="handleClick('following')">
      <text class="stat-value">{{ stats.following || 0 }}</text>
      <text class="stat-label">关注</text>
    </view>
    <view class="divider"></view>
    <view class="stat-item" @click="handleClick('followers')">
      <text class="stat-value">{{ stats.followers || 0 }}</text>
      <text class="stat-label">粉丝</text>
    </view>
    <view class="divider"></view>
    <view class="stat-item" @click="handleClick('balance')">
      <text class="stat-value">{{ stats.balance || '0.00' }}</text>
      <text class="stat-label">余额</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'StatsCard',
  props: {
    stats: {
      type: Object,
      default: () => ({})
    }
  },
  methods: {
    handleClick(type) {
      this.$emit('click', type);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.stats-card {
  display: flex;
  align-items: center;
  background-color: $background-light;
  border-radius: $radius-lg;
  padding: 32rpx 0;
  margin: 0 40rpx 40rpx;
  box-shadow: $shadow-soft;
  border: 1rpx solid $border-light;
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  
  &:active {
    opacity: 0.7;
  }
}

.stat-value {
  font-size: 36rpx;
  font-weight: 800;
  color: $text-primary-light;
}

.stat-label {
  font-size: $font-xs;
  color: $text-tertiary-light;
  font-weight: 500;
}

.divider {
  width: 2rpx;
  height: 48rpx;
  background-color: $border-light;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .stats-card {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }
  
  .stat-value {
    color: $text-primary-dark;
  }
  
  .stat-label {
    color: $text-secondary-dark;
  }
  
  .divider {
    background-color: rgba(255, 255, 255, 0.1);
  }
}
</style>
