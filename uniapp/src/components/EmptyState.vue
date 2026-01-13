<!--
  空状态组件
  展示暂无数据提示
-->
<template>
  <view class="empty-state">
    <image 
      class="empty-image" 
      src="/static/empty_state.png" 
      mode="aspectFit" 
      v-if="image"
    />
    <view v-else class="empty-icon-wrapper">
       <uni-icons type="info" size="48" color="#94a3b8" />
    </view>
    <text class="empty-text">{{ text || '暂无数据' }}</text>
    <button v-if="btnText" class="action-btn" @click="handleAction">{{ btnText }}</button>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'EmptyState',
  components: {
    uniIcons
  },
  props: {
    text: {
      type: String,
      default: ''
    },
    image: {
      type: String,
      default: ''
    },
    btnText: {
      type: String,
      default: ''
    }
  },
  methods: {
    handleAction() {
      this.$emit('click');
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80rpx 40rpx;
}

.empty-image {
  width: 240rpx;
  height: 240rpx;
  margin-bottom: 32rpx;
}

.empty-icon-wrapper {
  margin-bottom: 24rpx;
  opacity: 0.5;
}

.empty-text {
  font-size: $font-base;
  color: $text-tertiary-light;
  margin-bottom: 32rpx;
}

.action-btn {
  background-color: $primary;
  color: #ffffff;
  font-size: $font-sm;
  padding: 0 48rpx;
  height: 72rpx;
  line-height: 72rpx;
  border-radius: $radius-full;
  
  &:active {
    opacity: 0.9;
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .empty-text {
    color: $text-tertiary-dark;
  }
}
</style>
