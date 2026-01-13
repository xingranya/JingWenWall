<!--
  页面加载状组件
  展示加载动画
-->
<template>
  <view class="page-loading" v-if="show">
    <view class="loading-spinner"></view>
    <text class="loading-text">加载中...</text>
  </view>
</template>

<script>
export default {
  name: 'PageLoading',
  props: {
    show: {
      type: Boolean,
      default: false
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.page-loading {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 9999;
  background-color: $background-light;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.loading-spinner {
  width: 64rpx;
  height: 64rpx;
  border: 4rpx solid rgba(0, 127, 255, 0.1);
  border-top-color: $primary;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 24rpx;
}

.loading-text {
  font-size: $font-sm;
  color: $text-secondary-light;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .page-loading {
    background-color: $background-dark;
  }
  
  .loading-text {
    color: $text-secondary-dark;
  }
}
</style>
