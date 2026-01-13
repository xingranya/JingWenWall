<!--
  跑腿/求助订单卡片
  参考 campus_marketplace 模板样式
-->
<template>
  <view class="errand-card" @click="handleClick">
    <!-- 头部：发布者信息和价格 -->
    <view class="card-header">
      <view class="user-row">
        <image class="avatar-md" :src="order.avatar || '/static/default_avatar.jpg'" mode="aspectFill" />
        <view class="user-meta">
          <text class="user-name">{{ order.nickName || '匿名同学' }}</text>
          <text class="post-info">{{ formatTime(order.createTime) }} · {{ order.location || '未知位置' }}</text>
        </view>
      </view>
      <view class="price-badge">
        <text class="currency">¥</text>
        <text class="amount">{{ order.totalFee || '0.00' }}</text>
      </view>
    </view>
    
    <!-- 内容描述 -->
    <view class="card-body">
      <text class="order-desc line-clamp-3">{{ order.content || order.goodsDesc }}</text>
    </view>
    
    <!-- 底部：标签和操作按钮 -->
    <view class="card-footer">
      <view class="tags">
        <view class="tag tag-orange">
          <text class="tag-label">{{ order.typeStr || '跑腿' }}</text>
        </view>
      </view>
      
      <button class="accept-btn" @click.stop="handleAccept">
        接单
      </button>
    </view>
  </view>
</template>

<script>
export default {
  name: 'ErrandCard',
  props: {
    order: {
      type: Object,
      required: true
    }
  },
  methods: {
    handleClick() {
      this.$emit('click', this.order);
    },
    handleAccept() {
      this.$emit('accept', this.order);
    },
    formatTime(time) {
      if (!time) return '';
      // 简单处理时间显示
      // 实际可以使用 dayjs 或统一工具函数
      const date = new Date(time);
      const now = new Date();
      const diff = (now - date) / 1000 / 60; // 分钟
      
      if (diff < 60) return `${Math.ceil(diff)}分钟前`;
      if (diff < 1440) return `${Math.ceil(diff / 60)}小时前`;
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.errand-card {
  background-color: $background-light;
  border-radius: $radius-lg;
  padding: 32rpx;
  margin-bottom: 24rpx;
  box-shadow: $shadow-soft;
  border: 1rpx solid transparent; // 预留深色模式边框
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24rpx;
}

.user-row {
  display: flex;
  align-items: center;
  gap: 24rpx;
}

.user-meta {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: $font-sm;
  font-weight: 700;
  color: $text-primary-light;
}

.post-info {
  font-size: 20rpx;
  color: $text-secondary-light;
  margin-top: 4rpx;
}

.price-badge {
  display: flex;
  align-items: baseline;
  color: $accent-orange;
  font-weight: 800;
  
  .currency {
    font-size: $font-xs;
    margin-right: 2rpx;
  }
  
  .amount {
    font-size: $font-lg;
  }
}

.card-body {
  margin-bottom: 32rpx;
}

.order-desc {
  font-size: $font-base;
  color: $text-primary-light;
  line-height: 1.6;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tags {
  display: flex;
  gap: 16rpx;
}

.tag-label {
  font-size: 20rpx;
  font-weight: 600;
}

.accept-btn {
  margin: 0;
  background-color: rgba(0, 127, 255, 0.1);
  color: $primary;
  font-size: 24rpx;
  font-weight: 700;
  border-radius: $radius-full;
  padding: 0 32rpx;
  height: 56rpx;
  line-height: 56rpx;
  border: none;
  
  &::after {
    border: none;
  }
  
  &:active {
    background-color: rgba(0, 127, 255, 0.2);
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .errand-card {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.05);
  }
  
  .user-name, .order-desc {
    color: $text-primary-dark;
  }
  
  .post-info {
    color: $text-secondary-dark;
  }
  
  .accept-btn {
    background-color: rgba(0, 127, 255, 0.2);
    color: $primary;
  }
}
</style>
