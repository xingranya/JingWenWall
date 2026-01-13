<!--
  服务列表组件
  展示我的订单、我的发布、设置等列表项
-->
<template>
  <view class="service-list">
    <!-- 分组标题 (可选) -->
    <view v-if="title" class="group-title safe-padding">
      <text>{{ title }}</text>
    </view>
    
    <view class="list-container">
      <view 
        v-for="(item, index) in list" 
        :key="index"
        class="list-item"
        @click="handleClick(item)"
      >
        <view class="item-left">
          <view class="icon-box" :style="{ backgroundColor: item.bg || 'rgba(0,127,255,0.1)' }">
            <uni-icons :type="item.icon" size="20" :color="item.color || '#007fff'" />
          </view>
          <text class="item-label">{{ item.label }}</text>
        </view>
        
        <view class="item-right">
          <text v-if="item.value" class="item-value">{{ item.value }}</text>
          <uni-icons type="right" size="16" color="#94a3b8" />
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'ServiceList',
  components: {
    uniIcons
  },
  props: {
    title: {
      type: String,
      default: ''
    },
    list: {
      type: Array,
      default: () => []
    }
  },
  methods: {
    handleClick(item) {
      this.$emit('click', item);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.service-list {
  margin-bottom: $spacing-lg;
}

.safe-padding {
  padding: 0 40rpx;
}

.group-title {
  font-size: $font-sm;
  font-weight: 700;
  color: $text-secondary-light;
  margin-bottom: $spacing-sm;
}

.list-container {
  background-color: $background-light;
  margin: 0 40rpx;
  border-radius: $radius-lg;
  overflow: hidden;
  box-shadow: $shadow-soft;
  border: 1rpx solid $border-light;
}

.list-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx 32rpx;
  transition: all 0.2s ease;
  
  &:active {
    background-color: $surface-light;
  }
  
  &:not(:last-child) {
    border-bottom: 1rpx solid $border-light;
  }
}

.item-left {
  display: flex;
  align-items: center;
  gap: 24rpx;
}

.icon-box {
  width: 72rpx;
  height: 72rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.item-label {
  font-size: $font-base;
  font-weight: 600;
  color: $text-primary-light;
}

.item-right {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.item-value {
  font-size: $font-xs;
  color: $text-secondary-light;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .group-title {
    color: $text-secondary-dark;
  }
  
  .list-container {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }
  
  .list-item:not(:last-child) {
    border-bottom-color: rgba(255, 255, 255, 0.05);
  }
  
  .item-label {
    color: $text-primary-dark;
  }
  
  .list-item:active {
    background-color: rgba(255, 255, 255, 0.05);
  }
}
</style>
