<template>
  <view class="market-card" @click="handleClick">
    <!-- 商品图片 -->
    <view class="img-wrapper">
      <image 
        class="goods-img" 
        :src="imageUrl" 
        mode="aspectFill"
        lazy-load
      />
      <!-- 成色标签 -->
      <view class="condition-tag" v-if="item.statusTag">
        <text>{{ item.statusTag }}</text>
      </view>
    </view>
    
    <!-- 卡片内容 -->
    <view class="card-body">
      <!-- 商品描述 -->
      <text class="goods-title">{{ item.content }}</text>
      
      <!-- 价格与原价 -->
      <view class="price-section">
        <view class="current-price">
          <text class="symbol">¥</text>
          <text class="amount">{{ formatPrice(item.price) }}</text>
        </view>
        <text class="original-price" v-if="item.originalPrice">¥{{ item.originalPrice }}</text>
      </view>
      
      <!-- 用户信息 -->
      <view class="seller-info">
        <image 
          class="seller-avatar" 
          :src="sellerAvatar" 
          mode="aspectFill" 
        />
        <text class="seller-name">{{ sellerName }}</text>
        <view class="view-count" v-if="item.viewCount">
          <uni-icons type="eye" size="12" color="#94a3b8" />
          <text>{{ item.viewCount }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'MarketCard',
  props: {
    item: {
      type: Object,
      required: true
    }
  },
  computed: {
    imageUrl() {
      if (this.item.fileUrl && this.item.fileUrl.length > 0) {
        return this.item.fileUrl[0]; 
      }
      return '/static/logo.png';
    },
    sellerAvatar() {
      return (this.item.params && this.item.params.avatar) || '/static/default_avatar.jpg';
    },
    sellerName() {
      return (this.item.params && this.item.params.nickName) || '匿名用户';
    }
  },
  methods: {
    handleClick() {
      this.$emit('click', this.item);
    },
    formatPrice(price) {
      if (!price) return '0';
      const num = parseFloat(price);
      return num % 1 === 0 ? num.toString() : num.toFixed(2);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.market-card {
  background: #ffffff;
  border-radius: $radius-lg;
  overflow: hidden;
  box-shadow: 0 2rpx 16rpx rgba(0, 0, 0, 0.06);
  transition: all 0.25s ease;
  
  &:active {
    transform: scale(0.98);
    box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.04);
  }
}

.img-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 1;
  background: $background-dim;
}

.goods-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.condition-tag {
  position: absolute;
  top: 12rpx;
  left: 12rpx;
  background: linear-gradient(135deg, rgba(255, 149, 0, 0.95) 0%, rgba(255, 123, 0, 0.95) 100%);
  padding: 6rpx 16rpx;
  border-radius: 8rpx;
  
  text {
    font-size: 20rpx;
    color: #ffffff;
    font-weight: 600;
  }
}

.card-body {
  padding: 20rpx;
}

.goods-title {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  font-size: 26rpx;
  color: $text-primary-light;
  line-height: 1.5;
  font-weight: 500;
  margin-bottom: 16rpx;
  min-height: 78rpx;
}

.price-section {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
  margin-bottom: 16rpx;
}

.current-price {
  color: $accent-red;
  font-weight: 700;
  
  .symbol {
    font-size: 22rpx;
  }
  
  .amount {
    font-size: 36rpx;
    letter-spacing: -1rpx;
  }
}

.original-price {
  font-size: 22rpx;
  color: $text-tertiary-light;
  text-decoration: line-through;
}

.seller-info {
  display: flex;
  align-items: center;
  gap: 10rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid rgba(0, 0, 0, 0.04);
}

.seller-avatar {
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  background: $surface-light;
}

.seller-name {
  flex: 1;
  font-size: 22rpx;
  color: $text-secondary-light;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.view-count {
  display: flex;
  align-items: center;
  gap: 4rpx;
  
  text {
    font-size: 20rpx;
    color: $text-tertiary-light;
  }
}

@media (prefers-color-scheme: dark) {
  .market-card {
    background: $card-dark;
  }
  
  .goods-title {
    color: $text-primary-dark;
  }
  
  .seller-info {
    border-top-color: rgba(255, 255, 255, 0.06);
  }
  
  .seller-name {
    color: $text-secondary-dark;
  }
}
</style>
