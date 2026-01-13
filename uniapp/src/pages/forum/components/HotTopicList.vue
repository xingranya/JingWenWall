<!--
  热榜组件
  横向滚动展示热门话题
  参考 campus_social_feed 模板样式
-->
<template>
  <view class="hot-topic-section">
    <view class="section-header safe-padding">
      <view class="title-row">
        <uni-icons type="fire" size="20" color="#e11d48" />
        <text class="title-text">热榜</text>
      </view>
      <text class="more-text">更多</text>
    </view>
    
    <scroll-view scroll-x class="hot-scroll no-scrollbar" :show-scrollbar="false">
      <view class="hot-list">
        <view 
          v-for="(item, index) in list" 
          :key="index"
          class="hot-card"
          @click="handleClick(item)"
        >
          <view class="hot-card-header">
            <text class="hot-title line-clamp-2">{{ item.title }}</text>
            <text class="rank-badge">TOP {{ index + 1 }}</text>
          </view>
          
          <view class="hot-card-footer">
            <view class="tag-row">
              <text class="tag-text">#{{ item.tag || '校园生活' }}</text>
              <text class="dot">•</text>
              <text class="hot-val">{{ item.hot || '2.3w' }} 热度</text>
            </view>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'HotTopicList',
  components: {
    uniIcons
  },
  props: {
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

.hot-topic-section {
  padding-bottom: $spacing-md;
}

.safe-padding {
  padding: 0 24rpx;
  margin-bottom: $spacing-sm;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title-row {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.title-text {
  font-size: $font-base;
  font-weight: 700;
  color: $text-primary-light;
}

.more-text {
  font-size: $font-xs;
  color: $text-tertiary-light;
}

.hot-scroll {
  white-space: nowrap;
}

.hot-list {
  display: flex;
  padding: 0 24rpx;
  gap: 16rpx;
}

.hot-card {
  display: inline-flex;
  flex-direction: column;
  justify-content: space-between;
  width: 500rpx;
  background-color: $background-light;
  border-radius: $radius-lg;
  padding: 24rpx;
  border: 1rpx solid $border-light;
  white-space: normal; // 允许内部换行
  box-shadow: $shadow-soft;
}

.hot-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.hot-title {
  font-size: $font-base;
  font-weight: 700;
  color: $text-primary-light;
  line-height: 1.4;
}

.rank-badge {
  font-size: $font-xs;
  font-weight: 800;
  color: #e11d48;
  white-space: nowrap;
}

.hot-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tag-row {
  display: flex;
  align-items: center;
  font-size: $font-xs;
  color: $text-secondary-light;
  gap: 8rpx;
  
  .tag-text {
    color: $primary;
    font-weight: 500;
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .hot-card {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }
  
  .title-text, .hot-title {
    color: $text-primary-dark;
  }
  
  .tag-row {
    color: $text-secondary-dark;
  }
}
</style>
