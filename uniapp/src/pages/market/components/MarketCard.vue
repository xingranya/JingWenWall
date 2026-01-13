<template>
  <view class="market-card" @click="handleClick">
    <image 
      class="goods-img" 
      :src="imageUrl" 
      mode="aspectFill" 
    />
    <view class="card-body">
      <text class="goods-desc multi-ellipsis--l2">{{ item.content }}</text>
      
      <view class="tags-row">
        <view class="tag" v-if="item.statusTag">
            <text class="tag-text">{{ item.statusTag }}</text>
        </view>
        <view class="tag" v-if="!item.statusTag">
            <text class="tag-text">闲置</text>
        </view>
      </view>
      
      <view class="price-row">
        <view class="price">
          <text class="symbol">¥</text>
          <text class="num">{{ item.price || '0.00' }}</text>
        </view>
        <text class="location" v-if="item.location">{{ item.location }}</text>
      </view>
      
      <view class="user-row">
        <image class="avatar-xs" :src="(item.params && item.params.avatar) || '/static/default_avatar.jpg'" mode="aspectFill" />
        <text class="user-name text-ellipsis">{{ (item.params && item.params.nickName) || '匿名' }}</text>
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
      // item.fileUrl 是 List<String> 或 String，后端 ContentVo 定义为 List<String> fileUrl
      // 前端接收到的可能是 null, [], 或 ["url1", "url2"]
      if (this.item.fileUrl && this.item.fileUrl.length > 0) {
        return this.item.fileUrl[0]; 
      }
      return '/static/logo.png'; // 占位图
    }
  },
  methods: {
    handleClick() {
      this.$emit('click', this.item);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.market-card {
  background-color: #ffffff;
  border-radius: $radius-md;
  overflow: hidden;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
}

.goods-img {
  width: 100%;
  height: 340rpx; // 瀑布流图片高度，或者固定高度
  background-color: $background-dim;
}

.card-body {
  padding: 16rpx;
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.goods-desc {
  font-size: $font-sm;
  color: $text-primary-light;
  line-height: 1.4;
  height: 2.8em; // 2 lines
}

.tags-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.tag {
  background-color: rgba(255, 149, 0, 0.1);
  padding: 4rpx 8rpx;
  border-radius: 4rpx;
  
  .tag-text {
      font-size: 20rpx;
      color: $accent-orange;
  }
}

.price-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
}

.price {
  color: $accent-red;
  font-weight: 700;
  
  .symbol {
    font-size: 20rpx;
  }
  
  .num {
    font-size: $font-lg;
  }
}

.location {
  font-size: 18rpx;
  color: $text-secondary-light;
}

.user-row {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-top: 4rpx;
}

.avatar-xs {
  width: 32rpx;
  height: 32rpx;
  border-radius: 50%;
}

.user-name {
  font-size: 20rpx;
  color: $text-secondary-light;
  flex: 1;
}

// 通用样式类
.multi-ellipsis--l2 {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
}

.text-ellipsis {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

// Dark Mode
@media (prefers-color-scheme: dark) {
  .market-card {
    background-color: $card-dark;
  }
  .goods-desc {
    color: $text-primary-dark;
  }
  .user-name {
    color: $text-secondary-dark;
  }
}
</style>
