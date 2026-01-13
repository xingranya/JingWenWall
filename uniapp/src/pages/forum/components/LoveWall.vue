<!--
  表白墙组件
  Grid 布局展示表白内容
  参考 campus_social_feed 模板样式
-->
<template>
  <view class="love-wall-section">
    <view class="section-header safe-padding">
      <view class="title-row">
        <uni-icons type="heart-filled" size="20" color="#ec4899" />
        <text class="title-text">表白墙</text>
      </view>
      <text class="more-text">更多</text>
    </view>
    
    <view class="love-grid safe-padding">
      <view 
        v-for="(item, index) in list" 
        :key="index"
        class="love-card"
        :class="index % 2 === 0 ? 'bg-pink' : 'bg-purple'"
        @click="handleClick(item)"
      >
        <text class="love-content line-clamp-3">{{ item.content }}</text>
        
        <view class="love-footer">
          <text class="time-text">{{ item.time || '刚刚' }}</text>
          <view class="tag" :class="index % 2 === 0 ? 'tag-pink' : 'tag-purple'">
            <text class="tag-label">{{ item.type === 'find' ? '捞人' : '表白' }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'LoveWall',
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

.love-wall-section {
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

.love-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16rpx;
}

.love-card {
  border-radius: $radius-lg;
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 200rpx;
  border: 1rpx solid transparent;
  
  &.bg-pink {
    background: linear-gradient(135deg, #fff1f2 0%, #ffffff 100%);
    border-color: #ffe4e6;
  }
  
  &.bg-purple {
    background: linear-gradient(135deg, #f3e8ff 0%, #ffffff 100%);
    border-color: #f3e8ff;
  }
}

.love-content {
  font-size: $font-xs;
  font-weight: 700;
  color: $text-primary-light;
  line-height: 1.5;
}

.love-footer {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.time-text {
  font-size: 20rpx;
  color: $text-tertiary-light;
}

.tag {
  padding: 4rpx 12rpx;
  border-radius: 8rpx;
  
  &.tag-pink {
    background-color: #fce7f3;
    .tag-label { color: #db2777; }
  }
  
  &.tag-purple {
    background-color: #f3e8ff;
    .tag-label { color: #9333ea; }
  }
}

.tag-label {
  font-size: 20rpx;
  font-weight: 500;
}

// 深色模式适配
@media (prefers-color-scheme: dark) {
  .title-text {
    color: $text-primary-dark;
  }

  .love-card {
    &.bg-pink {
      background: linear-gradient(135deg, rgba(131, 24, 67, 0.2) 0%, rgba(30, 41, 59, 0.5) 100%);
      border-color: rgba(131, 24, 67, 0.3);
    }
    
    &.bg-purple {
      background: linear-gradient(135deg, rgba(88, 28, 135, 0.2) 0%, rgba(30, 41, 59, 0.5) 100%);
      border-color: rgba(88, 28, 135, 0.3);
    }
  }
  
  .love-content {
    color: $text-primary-dark;
  }
}
</style>
