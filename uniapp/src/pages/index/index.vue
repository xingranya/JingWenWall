<template>
  <view class="home-container">
    <!-- 1. 顶部导航与用户信息 -->
    <HomeHeader 
      :user-avatar="userInfo.avatar" 
      :has-unread="hasUnread"
    />

    <scroll-view 
      scroll-y 
      class="main-scroll"
      @scrolltolower="onReachBottom"
      :refresher-enabled="true"
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
    >
      <!-- 2. 欢迎标题 -->
      <view class="welcome-section safe-padding">
        <text class="welcome-text">
          早上好，<text class="user-name">{{ userInfo.nickName || '同学' }}</text>
        </text>
      </view>

      <!-- 3. 全局通知 (保留原有逻辑) -->
      <view class="notice-section safe-padding" v-if="showNotice">
        <view class="notice-card glass-effect">
          <uni-icons type="sound" size="20" color="#ff9500" />
          <text class="notice-text">荆文Wall 当前还处于开发阶段！</text>
          <uni-icons type="closeempty" size="20" color="#94a3b8" @click="closeNotice" />
        </view>
      </view>

      <!-- 4. 快捷入口 -->
      <QuickEntry />

      <!-- 5. 轮播图 (暂时保留，后续优化样式) -->
      <view class="swiper-section safe-padding">
        <CustomSwiper 
          :imgList="imgList" 
          :indicator-dots="true" 
          :autoplay="true" 
          :interval="4000" 
          :duration="500"
          style="border-radius: 24rpx; overflow: hidden;"
        />
      </view>

      <!-- 6. 校园精选 (Feed 流) -->
      <view class="feed-section pb-safe-nav">
        <view class="section-header safe-padding">
          <text class="section-title">校园精选</text>
          <text class="section-more" @click="goToForum">查看全部</text>
        </view>
        
        <view class="feed-list safe-padding">
          <FeedCard 
            v-for="(record, index) in records" 
            :key="index"
            :post="record"
            :show-interactions="true"
            @click="handleCardClick"
            @collect="handleCollect"
          />
        </view>
        
        <!-- 加载状态 -->
        <uni-load-more :status="loadMoreStatus" />
      </view>
    </scroll-view>

    <!-- 7. 悬浮按钮 (发布) -->
    <FabComponent />
    
    <!-- 8. 自定义底部导航栏 -->
    <TabBar :current="0" />
  </view>
</template>

<script>
import HomeHeader from './components/HomeHeader.vue';
import QuickEntry from './components/QuickEntry.vue';
import FeedCard from './components/FeedCard.vue';
// 保留原有组件
import CustomSwiper from './components/swipper.vue';
import FabComponent from './components/fab.vue';
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';
import uniLoadMore from '@dcloudio/uni-ui/lib/uni-load-more/uni-load-more.vue';
import TabBar from '@/components/TabBar.vue';

// API 引入
import { getRecords } from "@/api/topic";
import { userLoginService } from "@/api/login";
import { likeTopic, unlikeTopic } from "@/api/like";
import { collectTopic, uncollectTopic } from "@/api/collect";

export default {
  components: {
    HomeHeader,
    QuickEntry,
    FeedCard,
    CustomSwiper,
    FabComponent,
    uniIcons,
    uniLoadMore,
    uniIcons,
    uniLoadMore,
    TabBar
  },
  data() {
    return {
      userInfo: {
        nickName: '同学',
        avatar: ''
      },
      hasUnread: true, // 模拟未读消息
      showNotice: true,
      
      // 轮播图数据
      imgList: [
        { img: '/static/carousel/image1.jpg' },
        { img: '/static/carousel/image2.jpg' },
        { img: '/static/carousel/image3.jpg' },
        { img: '/static/carousel/image4.jpg' },
        { img: '/static/carousel/image5.jpg' },
        { img: '/static/carousel/image6.jpg' }
      ],
      
      // Feed流数据
      page: 1,
      records: [],
      loadMoreStatus: 'more',
      isRefreshing: false,
    };
  },
  onLoad() {
    this.checkPrivacy();
    this.init();
    this.getUserInfo();
  },
  onShow() {
    // 每次显示时刷新数据，或者根据策略刷新
    if (this.records.length === 0) {
      this.page = 1;
      this.loadMoreStatus = 'more';
      this.fetchRecords();
    }
  },
  methods: {
    checkPrivacy() {
      const hasAgreed = uni.getStorageSync('hasAgreedPrivacy');
      if (!hasAgreed) {
        uni.reLaunch({
          url: '/pages/transition/agreement'
        });
      }
    },
    
    /**
     * 获取用户信息
     */
    getUserInfo() {
      // 尝试从本地存储获取
      const userInfoStr = uni.getStorageSync('userInfo');
      if (userInfoStr) {
        try {
          const info = JSON.parse(userInfoStr);
          // 适配字段名
          this.userInfo = {
            nickName: info.nickName || info.username || '同学',
            avatar: info.avatar || ''
          };
        } catch (e) {
          console.error('解析用户信息失败', e);
        }
      }
    },
    
    /**
     * 初始化登录
     */
    async init() {
      const existingToken = uni.getStorageSync('token');
      if (existingToken) {
        return;
      }
      
      // 微信登录逻辑 (保持原有)
      uni.login({
        provider: 'weixin',
        success: async (loginRes) => {
          try {
            const res = await userLoginService({ code: loginRes.code });
            // 保存 token
            // 假设 loginService 内部或返回处理了 token
            // 此处保持逻辑框架
            this.fetchRecords();
          } catch (error) {
            console.error('登录失败:', error);
          }
        }
      });
    },

    /**
     * 获取话题列表
     */
    async fetchRecords() {
      if (this.loadMoreStatus === 'loading' || this.loadMoreStatus === 'noMore') return;
      
      this.loadMoreStatus = 'loading';
      
      try {
        const res = await getRecords(this.page, 10);
        const newRecords = (res.rows || []).map(item => ({
          ...item,
          // 适配 FeedCard 需要的字段
          images: item.imgURLs || [],
          // 格式化时间
          createTime: item.updatedAt || item.createTime,
          // 确保有头像
          avatar: item.avatar || '/static/default_avatar.jpg',
          // 确保有昵称
          nickName: item.username || '匿名同学'
        }));
        
        if (this.isRefreshing) {
          this.records = newRecords;
          this.isRefreshing = false;
        } else {
          this.records = [...this.records, ...newRecords];
        }
        
        if (newRecords.length < 10) {
          this.loadMoreStatus = 'noMore';
        } else {
          this.loadMoreStatus = 'more';
          this.page++;
        }
      } catch (err) {
        this.loadMoreStatus = 'more';
        this.isRefreshing = false;
        uni.showToast({ title: '加载失败', icon: 'none' });
      }
    },

    /**
     * 下拉刷新
     */
    onRefresh() {
      this.isRefreshing = true;
      this.page = 1;
      this.loadMoreStatus = 'more';
      this.fetchRecords();
    },

    /**
     * 触底加载
     */
    onReachBottom() {
      if (this.loadMoreStatus === 'more') {
        this.fetchRecords();
      }
    },

    /**
     * 关闭通知
     */
    closeNotice() {
      this.showNotice = false;
    },

    /**
     * 跳转到帖子详情
     */
    handleCardClick(post) {
      uni.navigateTo({
        url: `/pages/topic/view?topicId=${post.postId || post.id}`
      });
    },

    /**
     * 处理收藏
     */
    async handleCollect(post) {
      // 保持原有收藏逻辑
       try {
        if (post.isCollected) {
          await uncollectTopic(post.postId || post.id);
          post.isCollected = false;
          post.collectCount = Math.max(0, post.collectCount - 1);
          uni.showToast({ title: "取消收藏", icon: "success" });
        } else {
          await collectTopic(post.postId || post.id);
          post.isCollected = true;
          post.collectCount += 1;
          uni.showToast({ title: "已收藏", icon: "success" });
        }
      } catch (error) {
        uni.showToast({ title: "操作失败", icon: "none" });
      }
    },

    goToForum() {
      uni.switchTab({ url: '/pages/forum/index' });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.home-container {
  height: 100vh;
  background-color: $background-dim;
  display: flex;
  flex-direction: column;
}

.main-scroll {
  flex: 1;
  height: 0; // 配合 flex: 1 确保滚动区正确
}

.safe-padding {
  padding-left: 40rpx;
  padding-right: 40rpx;
}

.pb-safe-nav {
  padding-bottom: calc(120rpx + env(safe-area-inset-bottom));
}

// 欢迎标题区域
.welcome-section {
  padding-top: $spacing-sm;
  padding-bottom: $spacing-lg;
  
  .welcome-text {
    font-size: 68rpx;
    font-weight: 800;
    color: $text-primary-light;
    line-height: 1.1;
    letter-spacing: -2rpx;
  }
  
  .user-name {
    color: $primary;
    display: block; // 换行显示名字
  }
}

// 通知卡片
.notice-section {
  margin-bottom: $spacing-lg;

  .notice-card {
    display: flex;
    align-items: center;
    gap: 16rpx;
    padding: 16rpx 24rpx;
    background-color: rgba(255, 149, 0, 0.1);
    border-radius: $radius-lg;
    border: 1rpx solid rgba(255, 149, 0, 0.2);
  }

  .notice-text {
    flex: 1;
    font-size: $font-sm;
    color: $accent-orange;
    font-weight: 600;
  }
}

// 轮播图区域
.swiper-section {
  margin-bottom: $spacing-xl;
}

// Feed流区域
.feed-section {
  .section-header {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    margin-bottom: $spacing-md;
  }
  
  .section-title {
    font-size: 44rpx;
    font-weight: 700;
    color: $text-primary-light;
    line-height: 1;
  }
  
  .section-more {
    font-size: $font-sm;
    color: $primary;
    font-weight: 600;
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .home-container {
    background-color: $background-dark;
  }
  
  .welcome-section .welcome-text {
    color: $text-primary-dark;
  }
  
  .feed-section .section-title {
    color: $text-primary-dark;
  }
}
</style>
