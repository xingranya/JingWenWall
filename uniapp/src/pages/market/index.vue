<template>
  <view class="market-container">
    <!-- 头部搜索/筛选栏 -->
    <view class="search-bar safe-top">
      <view class="search-input">
        <uni-icons type="search" size="18" color="#999" />
        <text class="placeholder">搜索好物</text>
      </view>
    </view>
    
    <scroll-view 
      scroll-y 
      class="main-scroll"
      @scrolltolower="onReachBottom"
      :refresher-enabled="true"
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
    >
      <view class="waterfall-container safe-padding">
        <!-- 左列 -->
        <view class="column">
          <block v-for="(item, index) in leftList" :key="item.contentId">
            <MarketCard :item="item" @click="goToDetail" class="mb-20" />
          </block>
        </view>
        <!-- 右列 -->
        <view class="column">
          <block v-for="(item, index) in rightList" :key="item.contentId">
            <MarketCard :item="item" @click="goToDetail" class="mb-20" />
          </block>
        </view>
      </view>
      
      <!-- 加载更多 -->
      <uni-load-more :status="loadMoreStatus" />
    </scroll-view>
    
    <!-- 悬浮发布按钮 -->
    <view class="float-btn-wrapper safe-bottom">
      <button class="publish-btn" @click="goToPublish">
        <uni-icons type="plusempty" size="24" color="#ffffff" />
        <text>卖闲置</text>
      </button>
    </view>
  </view>
</template>

<script>
// 仅保留业务组件，uni-ui 通过 easycom 自动引入
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
      categoryId: 5 // 假设闲置市场是 5
    };
  },
  onLoad() {
    this.loadData();
  },
  methods: {
    async loadData() {
      if (this.loadMoreStatus === 'loading') return;
      this.loadMoreStatus = 'loading';
      
      try {
        const res = await getMarketList({
            categoryId: this.categoryId,
            pageNum: this.page,
            pageSize: this.pageSize
        });
        
        console.log('Market API Res:', res);
        
        // 兼容 res.rows 或 res.data.rows
        const list = res.rows || (res.data && res.data.rows) || [];
        
        // 分布到瀑布流
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
      }
    },
    
    // 简单的瀑布流分布 (左右交替)
    distributeList(list, isReset) {
      if (isReset) {
        this.leftList = [];
        this.rightList = [];
      }
      
      list.forEach((item, index) => {
        // 简单策略：根据 index 奇偶交替
        const totalIdx = isReset ? index : (this.fullList.length - list.length + index);
        
        if (totalIdx % 2 === 0) {
          this.leftList.push(item);
        } else {
          this.rightList.push(item);
        }
      });
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
      uni.navigateTo({
        url: '/pages/market/publish'
      });
    },
    
    goToDetail(item) {
      // 复用 forum/detail
      uni.navigateTo({
        url: `/pages/forum/detail?id=${item.contentId}`
      });
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
  background-color: $background-dim;
}

.search-bar {
  padding: 24rpx;
  background-color: #fff;
  z-index: 10;
}

.search-input {
  background-color: $background-light;
  height: 72rpx;
  border-radius: 36rpx;
  display: flex;
  align-items: center;
  padding: 0 24rpx;
  gap: 12rpx;
  
  .placeholder {
    font-size: $font-sm;
    color: $text-secondary-light;
  }
}

.main-scroll {
  flex: 1;
  height: 0;
}

.waterfall-container {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding-top: 24rpx;
  padding-bottom: 24rpx;
}

.column {
  width: 48%; // 留出 4% 间隙
  display: flex;
  flex-direction: column;
}

.mb-20 {
  margin-bottom: 20rpx;
}

.safe-padding {
  padding-left: 24rpx;
  padding-right: 24rpx;
}

// 悬浮发布按钮
.float-btn-wrapper {
  position: absolute;
  bottom: calc(48rpx + env(safe-area-inset-bottom));
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  pointer-events: none;
}

.publish-btn {
  pointer-events: auto;
  display: flex;
  align-items: center;
  gap: 12rpx;
  background-color: $accent-orange;
  color: #fff;
  padding: 0 48rpx;
  height: 88rpx;
  border-radius: 44rpx;
  box-shadow: 0 8rpx 24rpx rgba(255, 149, 0, 0.4);
  border: none;
  font-size: 30rpx;
  font-weight: 600;
  
  &::after { border: none; }
  &:active { transform: scale(0.95); }
}

@media (prefers-color-scheme: dark) {
  .market-container {
    background-color: $background-dark;
  }
  .search-bar {
    background-color: #1b1b1d;
  }
  .search-input {
    background-color: rgba(255, 255, 255, 0.1);
  }
}
</style>
