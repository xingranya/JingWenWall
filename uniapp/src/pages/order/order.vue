<template>
  <view class="order-container">
    <!-- 自定义头部 (可选，如果 pages.json 设置了标题，这里主要用作背景装饰或额外信息) -->
    <view class="page-header safe-top">
      <view class="header-content">
        <text class="page-title">校园跑腿</text>
        <text class="page-subtitle">互助广场</text>
      </view>
      <uni-icons type="notification" size="24" color="#0c141d" />
    </view>
    
    <scroll-view 
      scroll-y 
      class="main-scroll"
      @scrolltolower="onReachBottom"
      :refresher-enabled="true"
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
    >
      <view class="content-wrapper">
        <!-- 服务类型网格 -->
        <ServiceGrid @click="handleServiceClick" />
        
        <!-- 求助广场标题 -->
        <view class="section-header safe-padding sticky-header">
          <text class="section-title">求助广场</text>
          <view class="filter-btn" @click="handleFilter">
            <text>筛选</text>
            <uni-icons type="settings" size="14" color="#007fff" />
          </view>
        </view>
        
        <!-- 订单列表 -->
        <view class="order-list safe-padding">
          <block v-for="(order, index) in orderList" :key="index">
            <ErrandCard 
              :order="order" 
              @click="goToDetail" 
              @accept="handleAccept" 
            />
          </block>
        </view>
        
        <!-- 加载状态 -->
        <uni-load-more :status="loadMoreStatus" />
      </view>
    </scroll-view>
    
    <!-- 悬浮发布按钮 -->
    <view class="float-btn-wrapper safe-bottom">
      <button class="publish-btn" @click="goToPublish">
        <uni-icons type="plusempty" size="20" color="#ffffff" />
        <text>发布需求</text>
      </button>
    </view>
    
    <!-- 底部导航 -->
    <TabBar :current="1" />
  </view>
</template>

<script>
// 组件
import ServiceGrid from './components/ServiceGrid.vue';
import ErrandCard from './components/ErrandCard.vue';
import TabBar from '@/components/TabBar.vue';
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';
import uniLoadMore from '@dcloudio/uni-ui/lib/uni-load-more/uni-load-more.vue';

import { getWaitingOrders, acceptOrder } from '@/api/errand.js';

export default {
  components: {
    ServiceGrid,
    ErrandCard,
    TabBar,
    uniIcons,
    uniLoadMore
  },
  data() {
    return {
      orderList: [],
      page: 1,
      pageSize: 10,
      loadMoreStatus: 'more',
      isRefreshing: false
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
        const res = await getWaitingOrders(this.page, this.pageSize);
        
        console.log('跑腿订单API响应:', res);
        
        if (!res) {
          throw new Error('API response is empty');
        }

        // 新架构返回格式：{ rows: [...], total: N }
        const rows = res.rows || [];

        // 适配卡片组件需要的字段
        const list = rows.map(item => ({
            ...item,
            // 兼容旧的字段名
            contentId: item.orderId,
            content: item.goodsDesc,
            params: {
              type: item.type,
              typeDesc: item.typeDesc,
              pickupAddr: item.pickupAddr,
              deliveryAddr: item.deliveryAddr,
              tip: item.tip,
              totalFee: item.totalFee
            }
        }));
        
        if (this.isRefreshing) {
            this.orderList = list;
            this.isRefreshing = false;
        } else {
            this.orderList = [...this.orderList, ...list];
        }
        
        if (list.length < this.pageSize) {
            this.loadMoreStatus = 'noMore';
        } else {
            this.loadMoreStatus = 'more';
            this.page++;
        }
      } catch (err) {
        console.error('加载跑腿订单失败:', err);
        this.loadMoreStatus = 'more';
        if (this.isRefreshing) this.isRefreshing = false;
        uni.showToast({ title: '加载失败', icon: 'none' });
      }
    },
    
    onRefresh() {
      this.isRefreshing = true;
      this.page = 1;
      this.orderList = [];
      this.loadData();
    },
    
    onReachBottom() {
      if (this.loadMoreStatus === 'more') {
        this.loadData();
      }
    },
    
    handleServiceClick(item) {
      if (item.type === 'market') {
          uni.navigateTo({
              url: '/pages/market/index'
          });
          return;
      }
      // 跳转到发布页并带上类型参数
      uni.navigateTo({
        url: `/pages/order/publish?type=${item.type || 0}`
      });
    },
    
    async handleAccept(order) {
      uni.showModal({
        title: '接单确认',
        content: '确定要接下这个订单吗？',
        success: async (res) => {
          if (res.confirm) {
            try {
              await acceptOrder(order.orderId);
              uni.showToast({
                title: '抢单成功',
                icon: 'success'
              });
              // 刷新列表
              this.onRefresh();
            } catch (err) {
              uni.showToast({
                title: err || '抢单失败',
                icon: 'none'
              });
            }
          }
        }
      });
    },
    
    goToDetail(order) {
      uni.navigateTo({
        url: `/pages/order/detail?orderId=${order.orderId}`
      });
    },
    
    goToPublish() {
      uni.navigateTo({
        url: '/pages/order/publish'
      });
    },
    
    handleFilter() {
      // 筛选逻辑
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.order-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $background-dim;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx 40rpx;
  background-color: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20rpx);
}

.header-content {
  display: flex;
  flex-direction: column;
}

.page-title {
  font-size: 40rpx;
  font-weight: 800;
  color: $text-primary-light;
  line-height: 1.2;
}

.page-subtitle {
  font-size: $font-xs;
  color: $text-secondary-light;
  font-weight: 500;
}

.main-scroll {
  flex: 1;
  height: 0;
}

.content-wrapper {
  padding-bottom: 200rpx; // 为悬浮按钮留出空间
}

.safe-padding {
  padding-left: 40rpx;
  padding-right: 40rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-md;
  
  &.sticky-header {
    position: sticky;
    top: 0;
    z-index: 10;
    background-color: $background-dim; // 遮挡内容
    padding-top: 24rpx;
    padding-bottom: 24rpx;
  }
}

.section-title {
  font-size: $font-xl; // 22px ~ 44rpx
  font-weight: 700;
  color: $text-primary-light;
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 4rpx;
  font-size: $font-sm;
  color: $primary;
  font-weight: 600;
}

// 悬浮发布按钮
.float-btn-wrapper {
  position: absolute;
  bottom: calc(140rpx + env(safe-area-inset-bottom));
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  z-index: 50;
  pointer-events: none; // 让 wrapper 不阻挡点击
}

.publish-btn {
  pointer-events: auto;
  display: flex;
  align-items: center;
  gap: 12rpx;
  background-color: $accent-orange;
  color: #ffffff;
  padding: 0 48rpx;
  height: 96rpx;
  border-radius: $radius-full;
  box-shadow: 0 8rpx 32rpx rgba(255, 149, 0, 0.3);
  border: none;
  font-size: 32rpx;
  font-weight: 700;
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.95);
  }
  
  &::after {
    border: none;
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .order-container {
    background-color: $background-dark;
  }
  
  .page-header {
    background-color: rgba(27, 27, 29, 0.9);
  }
  
  .page-title {
    color: $text-primary-dark;
  }
  
  .section-header.sticky-header {
    background-color: $background-dark;
  }
  
  .section-title {
    color: $text-primary-dark;
  }
  
  .uni-icons {
    // 简单适配图标颜色，具体需按需调整
    // color: #ffffff !important; 
  }
}
</style>
