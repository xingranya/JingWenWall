<template>
  <view class="market-container">
    <!-- 顶部区域 -->
    <view class="header-area safe-top">
      <!-- 页面标题 -->
      <view class="page-header">
        <view class="header-left">
          <text class="page-title">校园市场</text>
          <text class="page-subtitle">发现好物 · 闲置变现</text>
        </view>
        <view class="header-actions">
          <view class="icon-btn" @click="handleSearch">
            <uni-icons type="search" size="20" color="#0c141d" />
          </view>
        </view>
      </view>
      
      <!-- 分类筛选 -->
      <scroll-view scroll-x class="category-scroll" :show-scrollbar="false">
        <view class="category-list">
          <view 
            v-for="(cat, idx) in categories" 
            :key="idx"
            class="category-item"
            :class="{ active: currentCategory === cat.id }"
            @click="switchCategory(cat.id)"
          >
            <text>{{ cat.name }}</text>
          </view>
        </view>
      </scroll-view>
    </view>
    
    <scroll-view 
      scroll-y 
      class="main-scroll"
      @scrolltolower="onReachBottom"
      :refresher-enabled="true"
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
    >
      <!-- 空状态 -->
      <view class="empty-state" v-if="!loading && fullList.length === 0">
        <image src="/static/empty-box.png" mode="aspectFit" class="empty-img" />
        <text class="empty-text">暂无商品，快来发布第一个吧</text>
      </view>
      
      <view class="waterfall-container" v-else>
        <!-- 左列 -->
        <view class="column">
          <block v-for="(item, index) in leftList" :key="item.contentId">
            <MarketCard :item="item" @click="goToDetail" />
          </block>
        </view>
        <!-- 右列 -->
        <view class="column">
          <block v-for="(item, index) in rightList" :key="item.contentId">
            <MarketCard :item="item" @click="goToDetail" />
          </block>
        </view>
      </view>
      
      <!-- 加载更多 -->
      <uni-load-more :status="loadMoreStatus" v-if="fullList.length > 0" />
      
      <!-- 底部安全区 -->
      <view class="bottom-space"></view>
    </scroll-view>
    
    <!-- 悬浮发布按钮 -->
    <view class="float-btn-wrapper safe-bottom">
      <button class="publish-btn" @click="goToPublish">
        <view class="btn-icon">
          <uni-icons type="plusempty" size="20" color="#ffffff" />
        </view>
        <text>发布闲置</text>
      </button>
    </view>
  </view>
</template>

<script>
import MarketCard from './components/MarketCard.vue';
import { getMarketList } from '@/api/market.js';

export default {
  components: {
    MarketCard
  },
  data() {
    return {
      fullList: [],
      leftList: [],
      rightList: [],
      page: 1,
      pageSize: 10,
      loadMoreStatus: 'more',
      isRefreshing: false,
      loading: false,
      categoryId: 5,
      currentCategory: 0,
      categories: [
        { id: 0, name: '全部' },
        { id: 1, name: '数码电子' },
        { id: 2, name: '书籍教材' },
        { id: 3, name: '生活用品' },
        { id: 4, name: '服饰鞋包' },
        { id: 5, name: '运动户外' },
        { id: 6, name: '其他' }
      ]
    };
  },
  onLoad() {
    this.loadData();
  },
  methods: {
    async loadData() {
      if (this.loadMoreStatus === 'loading') return;
      this.loadMoreStatus = 'loading';
      this.loading = true;
      
      try {
        // 传递正确的分类ID参数
        const categoryParam = this.currentCategory > 0 ? this.currentCategory : null;
        const res = await getMarketList(categoryParam, this.page, this.pageSize);
        const list = res.rows || (res.data && res.data.rows) || [];
        
        if (this.isRefreshing) {
          this.fullList = list;
          this.distributeList(list, true);
          this.isRefreshing = false;
        } else {
          this.fullList = [...this.fullList, ...list];
          this.distributeList(list, false);
        }
        
        if (list.length < this.pageSize) {
          this.loadMoreStatus = 'noMore';
        } else {
          this.loadMoreStatus = 'more';
          this.page++;
        }
      } catch (err) {
        console.error('Market load error:', err);
        this.loadMoreStatus = 'more';
        if (this.isRefreshing) this.isRefreshing = false;
      } finally {
        this.loading = false;
      }
    },
    
    distributeList(list, isReset) {
      if (isReset) {
        this.leftList = [];
        this.rightList = [];
      }
      
      list.forEach((item, index) => {
        const totalIdx = isReset ? index : (this.fullList.length - list.length + index);
        if (totalIdx % 2 === 0) {
          this.leftList.push(item);
        } else {
          this.rightList.push(item);
        }
      });
    },
    
    switchCategory(catId) {
      if (this.currentCategory === catId) return;
      this.currentCategory = catId;
      this.page = 1;
      this.fullList = [];
      this.leftList = [];
      this.rightList = [];
      this.loadData();
    },
    
    handleSearch() {
      uni.showToast({ title: '搜索功能开发中', icon: 'none' });
    },
    
    onRefresh() {
      this.isRefreshing = true;
      this.page = 1;
      this.loadData();
    },
    
    onReachBottom() {
      if (this.loadMoreStatus === 'more') {
        this.loadData();
      }
    },
    
    goToPublish() {
      uni.navigateTo({ url: '/pages/market/publish' });
    },
    
    goToDetail(item) {
      uni.navigateTo({ url: `/pages/forum/detail?id=${item.contentId}` });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.market-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(180deg, #fff9f5 0%, $background-dim 100%);
}

.header-area {
  background: #ffffff;
  padding-bottom: 0;
  box-shadow: $shadow-soft;
  z-index: 10;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32rpx 32rpx 24rpx;
}

.header-left {
  display: flex;
  flex-direction: column;
}

.page-title {
  font-size: 44rpx;
  font-weight: 800;
  color: $text-primary-light;
  letter-spacing: 2rpx;
}

.page-subtitle {
  font-size: 22rpx;
  color: $text-tertiary-light;
  margin-top: 4rpx;
  font-weight: 400;
}

.header-actions {
  display: flex;
  gap: 16rpx;
}

.icon-btn {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  background: $surface-light;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.92);
    background: darken($surface-light, 5%);
  }
}

.category-scroll {
  white-space: nowrap;
  padding: 0 32rpx 24rpx;
}

.category-list {
  display: inline-flex;
  gap: 16rpx;
}

.category-item {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 16rpx 32rpx;
  border-radius: $radius-full;
  background: $surface-light;
  font-size: 26rpx;
  color: $text-secondary-light;
  font-weight: 500;
  transition: all 0.25s ease;
  
  &.active {
    background: linear-gradient(135deg, $accent-orange 0%, #ff7b00 100%);
    color: #ffffff;
    font-weight: 600;
    box-shadow: 0 6rpx 20rpx rgba(255, 149, 0, 0.35);
  }
  
  &:active:not(.active) {
    background: darken($surface-light, 5%);
  }
}

.main-scroll {
  flex: 1;
  height: 0;
}

.waterfall-container {
  display: flex;
  justify-content: space-between;
  padding: 24rpx 24rpx 0;
}

.column {
  width: calc(50% - 8rpx);
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120rpx 60rpx;
  
  .empty-img {
    width: 240rpx;
    height: 240rpx;
    opacity: 0.6;
    margin-bottom: 32rpx;
  }
  
  .empty-text {
    font-size: 28rpx;
    color: $text-tertiary-light;
  }
}

.bottom-space {
  height: 200rpx;
}

.float-btn-wrapper {
  position: fixed;
  bottom: calc(48rpx + env(safe-area-inset-bottom));
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  pointer-events: none;
  z-index: 100;
}

.publish-btn {
  pointer-events: auto;
  display: flex;
  align-items: center;
  gap: 12rpx;
  background: linear-gradient(135deg, $accent-orange 0%, #ff7b00 100%);
  color: #fff;
  padding: 0 40rpx 0 32rpx;
  height: 96rpx;
  border-radius: 48rpx;
  box-shadow: 0 12rpx 36rpx rgba(255, 123, 0, 0.4);
  border: none;
  font-size: 30rpx;
  font-weight: 600;
  letter-spacing: 1rpx;
  
  .btn-icon {
    width: 44rpx;
    height: 44rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.25);
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  &::after { border: none; }
  
  &:active { 
    transform: scale(0.95);
    box-shadow: 0 6rpx 20rpx rgba(255, 123, 0, 0.3);
  }
}

@media (prefers-color-scheme: dark) {
  .market-container {
    background: linear-gradient(180deg, #1f1f22 0%, $background-dark 100%);
  }
  
  .header-area {
    background: #1b1b1d;
  }
  
  .page-title {
    color: $text-primary-dark;
  }
  
  .icon-btn {
    background: $surface-dark;
  }
  
  .category-item {
    background: $surface-dark;
    color: $text-secondary-dark;
    
    &.active {
      background: linear-gradient(135deg, $accent-orange 0%, #ff7b00 100%);
      color: #ffffff;
    }
  }
}
</style>
