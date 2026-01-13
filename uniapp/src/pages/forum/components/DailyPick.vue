<!--
  每日精选卡片组件
  用于展示推荐内容
  参考 campus_social_feed 模板样式
-->
<template>
  <view class="daily-pick-card" @click="handleClick">
    <view class="absolute-badge">
      <view class="badge-content glass-effect">
        <text class="badge-text">每日精选</text>
      </view>
    </view>
    
    <view class="card-content">
      <!-- 左侧图片 -->
      <image 
        class="pick-image" 
        :src="data.image || '/static/carousel/image1.jpg'" 
        mode="aspectFill"
      />
      
      <!-- 右侧内容 -->
      <view class="pick-info">
        <view class="pick-header">
          <view class="author-row">
            <image class="avatar-xs" :src="data.avatar || '/static/default_avatar.jpg'" />
            <text class="author-name">{{ data.author || '校学生会' }}</text>
          </view>
          <text class="pick-title line-clamp-2">{{ data.title || '校园音乐节震撼开幕！' }}</text>
          <text class="pick-desc line-clamp-2">{{ data.desc || '今晚7点，南操场不见不散！' }}</text>
        </view>
        
        <view class="pick-footer">
          <view class="stat-row">
            <view class="stat-item">
              <uni-icons type="fire" size="14" color="#94a3b8" />
              <text>{{ data.hot || '1.2k' }}</text>
            </view>
            <view class="stat-item">
              <uni-icons type="chat" size="14" color="#94a3b8" />
              <text>{{ data.comments || 328 }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'DailyPick',
  components: {
    uniIcons
  },
  props: {
    data: {
      type: Object,
      default: () => ({})
    }
  },
  methods: {
    handleClick() {
      // TODO: 跳转详情
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.daily-pick-card {
  position: relative;
  background-color: $background-light;
  border-radius: $radius-lg;
  border: 1rpx solid $border-light;
  overflow: hidden;
  margin-bottom: $spacing-md;
  box-shadow: $shadow-soft;
}

.absolute-badge {
  position: absolute;
  top: 24rpx;
  right: 24rpx;
  z-index: 10;
}

.badge-content {
  padding: 8rpx 16rpx;
  background-color: rgba(0, 0, 0, 0.4);
  border-radius: $radius-sm;
}

.badge-text {
  font-size: 20rpx; // $font-xs
  font-weight: 700;
  color: #ffffff;
}

.card-content {
  display: flex;
  padding: 24rpx;
  gap: 24rpx;
}

.pick-image {
  width: 200rpx; // 约 1/3 宽度
  height: 260rpx; // 4:3 比例调整
  border-radius: $radius-default;
  background-color: $surface-light;
}

.pick-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.author-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
}

.avatar-xs {
  width: 32rpx;
  height: 32rpx;
  border-radius: 50%;
}

.author-name {
  font-size: $font-xs;
  color: $text-secondary-light;
}

.pick-title {
  font-size: 32rpx;
  font-weight: 700;
  color: $text-primary-light;
  line-height: 1.3;
  margin-bottom: 8rpx;
}

.pick-desc {
  font-size: $font-sm;
  color: $text-secondary-light;
  line-height: 1.4;
}

.stat-row {
  display: flex;
  gap: 24rpx;
  margin-top: 16rpx;
  
  .stat-item {
    display: flex;
    align-items: center;
    gap: 4rpx;
    font-size: $font-xs;
    color: $text-tertiary-light;
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .daily-pick-card {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }
  
  .pick-title {
    color: $text-primary-dark;
  }
  
  .pick-desc {
    color: $text-secondary-dark;
  }
  
  .author-name {
    color: $text-tertiary-dark;
  }
}
</style>
