<template>
  <view class="forum-container">
    <!-- 头部搜索 -->
    <ForumHeader />
    
    <!-- 分类导航 (吸顶) -->
    <view class="category-sticky">
      <CategoryScroll :current="currentTab" @change="onTabChange" />
    </view>
    
    <scroll-view 
      scroll-y 
      class="forum-scroll"
      @scrolltolower="onReachBottom"
      :refresher-enabled="true"
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
    >
      <view class="content-wrapper safe-padding">
        <!-- 推荐 Tab 展示组合内容 -->
        <block v-if="currentTab === 0">
          <!-- 每日精选 -->
          <DailyPick :data="dailyPickData" />
          
          <!-- 热榜 -->
          <HotTopicList :list="hotList" @click="goToDetail" />
          
          <!-- 表白墙 -->
          <LoveWall :list="loveList" @click="goToDetail" />
          
          <!-- 闲置交易区域 (标题+列表) -->
          <view class="section-header mt-4 mb-2">
            <view class="title-row">
              <uni-icons type="shop" size="20" color="#22c55e" />
              <text class="title-text">闲置交易</text>
            </view>
            <text class="more-text">查看全部</text>
          </view>
        </block>
        
        <!-- 帖子列表 (推荐页下展示混合流，其他页展示分类流) -->
        <view class="feed-list">
           <block v-for="(post, index) in postList" :key="index">
             <FeedCard 
               :post="post" 
               :show-interactions="true"
               @click="goToDetail(post)"
               @collect="handleCollect(post)"
             />
           </block>
        </view>
        
        <!-- 加载状态 -->
        <uni-load-more :status="loadMoreStatus" />
      </view>
    </scroll-view>
    
    <!-- 悬浮发布按钮 -->
    <view class="fab-wrapper" @click="goToPublish">
      <view class="fab-btn">
        <uni-icons type="plusempty" size="28" color="#ffffff" />
      </view>
    </view>
    
    <!-- 底部导航 -->
    <TabBar :current="2" />
  </view>
</template>

<script>
import ForumHeader from './components/ForumHeader.vue';
import CategoryScroll from './components/CategoryScroll.vue';
import DailyPick from './components/DailyPick.vue';
import HotTopicList from './components/HotTopicList.vue';
import LoveWall from './components/LoveWall.vue';
import FeedCard from '@/pages/index/components/FeedCard.vue'; // 复用首页卡片
import TabBar from '@/components/TabBar.vue';

import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';
import uniLoadMore from '@dcloudio/uni-ui/lib/uni-load-more/uni-load-more.vue';

import { getNewestPosts, getHotPosts } from '@/api/forum';
import { collectTopic, uncollectTopic } from "@/api/collect";

export default {
  components: {
    ForumHeader,
    CategoryScroll,
    DailyPick,
    HotTopicList,
    LoveWall,
    FeedCard,
    TabBar,
    uniIcons,
    uniLoadMore
  },
  data() {
    return {
      currentTab: 0,
      postList: [],
      pageNum: 1,
      pageSize: 10,
      loadMoreStatus: 'more',
      isRefreshing: false,
      
      // Mock Data for Demo
      dailyPickData: {
        title: '校园音乐节今晚震撼开幕！',
        desc: '准备好你的荧光棒了吗？今晚7点，南操场不见不散！',
        image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA9ey2T5dja4XFhGAU_NSs3tGVgJo60XUvh9_ouize7CBk-HzYiVyQc7p764Q1s84i6vd057XxDH7iS56D0l9euZYlk3pjNej2FjXhzhvLh7-iiGHR9hUqiOGicaTO3L638-jQl2xcbC32HKsmj8xWwo_miZnAD1idAGq6OQlrrTEmEdkfyTrtS8_y28YSjcgoTDHbBrl531B6ZiaWUciDbpziEmGS7bCtn0LpZaaQrYKdbC_rUVsjQi6THq3pFB0IOaHi3xxHQVjEP',
        author: '校学生会',
        hot: '1.2k',
        comments: 328
      },
      hotList: [],
      loveList: [
        { content: '那个在图书馆三楼靠窗位置穿白色毛衣的男生，你认真看书的样子真的很帅...', time: '刚刚', type: 'find' },
        { content: '有没有人组队寒假去哈尔滨旅游呀？目前缺2人，男女不限！', time: '15分钟前', type: 'team' }
      ]
    };
  },
  onLoad() {
    this.loadData();
    // 并行加载热榜
    this.loadHotList();
  },
  methods: {
    async loadData() {
      if (this.loadMoreStatus === 'loading') return;
      this.loadMoreStatus = 'loading';
      
      try {
        // 根据 Tab 选择 API
        // 简单处理：推荐/热榜用不同接口，其他暂用最新
        let apiMethod = getNewestPosts;
        if (this.currentTab === 1) apiMethod = getHotPosts;
        
        // TODO: 实际项目中应根据 CategoryScroll 的 type 传参
        const res = await apiMethod(this.pageNum, this.pageSize);
        
        const newPosts = (res.rows || []).map(item => ({
          ...item,
          createTime: item.createTime || item.updatedAt,
          nickName: item.nickName || item.username || '匿名',
          avatar: item.avatar || '/static/default_avatar.jpg',
          images: item.imgURLs || item.images || []
        }));
        
        if (this.isRefreshing) {
          this.postList = newPosts;
          this.isRefreshing = false;
        } else {
          this.postList = [...this.postList, ...newPosts];
        }
        
        if (newPosts.length < this.pageSize) {
          this.loadMoreStatus = 'noMore';
        } else {
          this.loadMoreStatus = 'more';
          this.pageNum++;
        }
      } catch (e) {
        this.loadMoreStatus = 'more';
        this.isRefreshing = false;
        console.error(e);
      }
    },
    
    async loadHotList() {
      try {
        const res = await getHotPosts(1, 4);
        this.hotList = (res.rows || []).map(item => ({
          title: item.title,
          hot: item.viewCount || 0,
          tag: '校园热点',
          postId: item.postId
        }));
      } catch (e) {
        console.error(e);
      }
    },
    
    onTabChange(index) {
      if (this.currentTab === index) return;
      this.currentTab = index;
      this.isRefreshing = true;
      this.pageNum = 1;
      this.postList = [];
      this.loadData();
    },
    
    onRefresh() {
      this.isRefreshing = true;
      this.pageNum = 1;
      this.loadData();
      if (this.currentTab === 0) {
        this.loadHotList();
      }
    },
    
    onReachBottom() {
      if (this.loadMoreStatus === 'more') {
        this.loadData();
      }
    },
    
    goToDetail(post) {
      const id = post.postId || post.id;
      if (id) {
        uni.navigateTo({
          url: `/pages/forum/detail?postId=${id}`
        });
      }
    },
    
    goToPublish() {
      uni.navigateTo({
        url: '/pages/forum/publish'
      });
    },

    async handleCollect(post) {
       try {
        if (post.isCollected) {
          await uncollectTopic(post.postId || post.id);
          post.isCollected = false;
          uni.showToast({ title: "取消收藏", icon: "success" });
        } else {
          await collectTopic(post.postId || post.id);
          post.isCollected = true;
          uni.showToast({ title: "已收藏", icon: "success" });
        }
      } catch (error) {
        uni.showToast({ title: "操作失败", icon: "none" });
      }
    },
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.forum-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $background-dim;
}

.category-sticky {
  position: sticky;
  top: 72rpx; // 头部高度 (ForumHeader 的高度大概这个位，需调整)
  z-index: 39;
  background-color: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20rpx);
}

.forum-scroll {
  flex: 1;
  height: 0;
}

.safe-padding {
  padding: 24rpx;
  padding-bottom: calc(120rpx + env(safe-area-inset-bottom));
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

// 悬浮发布按钮
.fab-wrapper {
  position: fixed;
  right: 40rpx;
  bottom: calc(140rpx + env(safe-area-inset-bottom));
  z-index: 50;
}

.fab-btn {
  width: 112rpx;
  height: 112rpx;
  border-radius: 50%;
  background-color: $text-primary-light;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.2);
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.95);
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .forum-container {
    background-color: $background-dark;
  }
  
  .category-sticky {
    background-color: rgba(27, 27, 29, 0.95);
  }
  
  .title-text {
    color: $text-primary-dark;
  }
  
  .fab-btn {
    background-color: #ffffff;
    
    ::v-deep .uni-icons {
      color: #000000 !important;
    }
  }
}
</style>
