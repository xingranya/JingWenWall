<!--
  分类标签滚动组件
  横向滚动选择分类
  参考 campus_social_feed 模板样式
-->
<template>
  <view class="category-scroll-container">
    <scroll-view scroll-x class="category-scroll no-scrollbar" :show-scrollbar="false">
      <view class="category-list">
        <view
          v-for="(item, index) in categories"
          :key="index"
          class="category-item"
          :class="{ active: current === index }"
          @click="handleSelect(index)"
        >
          <text class="category-text">{{ item.name }}</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script>
export default {
  name: 'CategoryScroll',
  props: {
    current: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      categories: [
        { name: '推荐', type: 'recommend' },
        { name: '热榜', type: 'hot' },
        { name: '表白墙', type: 'love' },
        { name: '失物招领', type: 'lost' },
        { name: '闲置', type: 'secondhand' },
        { name: '日常', type: 'daily' },
        { name: '求助', type: 'help' }
      ]
    };
  },
  methods: {
    handleSelect(index) {
      if (this.current === index) return;
      this.$emit('change', index);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.category-scroll-container {
  padding: 16rpx 0;
  background-color: transparent;
}

.category-scroll {
  white-space: nowrap;
}

.category-list {
  display: flex;
  padding: 0 24rpx;
  gap: 16rpx;
}

.category-item {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 12rpx 32rpx;
  border-radius: $radius-full;
  background-color: $background-light;
  border: 2rpx solid $border-light;
  transition: all 0.2s ease;
  
  &.active {
    background-color: $text-primary-light;
    border-color: $text-primary-light;
    
    .category-text {
      color: #ffffff;
      font-weight: 700;
    }
  }
  
  &:not(.active):active {
    background-color: darken($background-light, 5%);
  }
  
  // 深色模式下的激活态适配逻辑需要单独处理，这里仅做通用处理
}

.category-text {
  font-size: $font-sm;
  color: $text-secondary-light;
  font-weight: 500;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .category-item {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.1);
    
    &.active {
      background-color: #ffffff;
      border-color: #ffffff;
      
      .category-text {
        color: #000000;
      }
    }
  }
  
  .category-text {
    color: $text-secondary-dark;
  }
}
</style>
