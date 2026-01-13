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

// API (假设有对应 API，暂时 Mock 或复用现有)
// import { getErrandOrders, acceptOrder } from '@/api/order';

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
      isRefreshing: false,
      
      // Mock Data
      mockOrders: [
        {
          id: 1,
          nickName: '王同学',
          avatar: '/static/default_avatar.jpg',
          createTime: new Date().getTime() - 300000,
          location: '西区宿舍',
          goodsDesc: '求带一份黄焖鸡米饭，微辣，西区食堂二楼那家。送到3号楼楼下即可，谢谢！',
          totalFee: '5.00',
          typeStr: '食堂带饭'
        },
        {
          id: 2,
          nickName: '李学霸',
          avatar: '/static/default_avatar.jpg',
          createTime: new Date().getTime() - 720000,
          location: '图书馆',
          goodsDesc: '急需帮忙打印一份实验报告，大概15页，黑白双面。我在图书馆正门等。',
          totalFee: '3.00',
          typeStr: '打印服务'
        }
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
      
      // 模拟请求延迟
      setTimeout(() => {
        if (this.isRefreshing) {
          this.orderList = [...this.mockOrders];
          this.isRefreshing = false;
        } else {
          this.orderList = [...this.orderList, ...this.mockOrders];
        }
        
        // 模拟数据不够
        if (this.page > 1) {
             this.loadMoreStatus = 'noMore';
        } else {
             this.loadMoreStatus = 'more';
             this.page++;
        }
        
      }, 500);
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
    
    handleServiceClick(item) {
      // 携带类型跳转发布或筛选
      uni.showToast({
        title: `选择了${item.label}`,
        icon: 'none'
      });
    },
    
    handleAccept(order) {
      uni.showModal({
        title: '接单确认',
        content: '确定要接下这个订单吗？完成后将获得佣金。',
        success: (res) => {
          if (res.confirm) {
             uni.showToast({
               title: '抢单成功',
               icon: 'success'
             });
          }
        }
      });
    },
    
    goToDetail(order) {
      uni.navigateTo({
        url: `/pages/order/detail?id=${order.id}`
      });
    },
    
    goToPublish() {
      // 之前的发布页路径是 pages/order/order (在 pages.json 中被重用)，
      // 但现在 pages/order/order 变成了列表页。
      // 需要确认是否有独立的发布页。
      // 根据 pages.json，'pages/order/order' 原来 title 是 '发布订单'。
      // 现在的设计将 'pages/order/order' 改为了列表页。
      // 我们需要一个新的发布页，或者复用原来的逻辑但拆分路由。
      // 假设暂时跳转到一个未创建的发布页，或弹窗。
      uni.showToast({
        title: '发布功能开发中',
        icon: 'none'
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
