<template>
  <view class="search-container">
    <!-- 搜索栏 -->
    <view class="search-header">
      <view class="search-bar">
        <uni-icons type="search" size="20" color="#94a3b8" class="search-icon" />
        <input
          class="search-input"
          type="text"
          v-model="keyword"
          placeholder="搜索帖子..."
          :focus="isFocused"
          @confirm="onSearch"
          @input="onInput"
        />
        <uni-icons
          v-if="keyword"
          type="clear"
          size="20"
          color="#94a3b8"
          class="clear-icon"
          @click="clearKeyword"
        />
      </view>
      <text class="cancel-btn" @click="goBack">取消</text>
    </view>

    <!-- 搜索内容区 -->
    <scroll-view scroll-y class="search-content">
      <!-- 搜索结果 -->
      <view v-if="hasSearched" class="result-section">
        <view class="section-header">
          <text class="section-title">搜索结果</text>
          <text class="section-count">({{ totalCount }})</text>
        </view>

        <!-- 结果列表 -->
        <view v-if="postList.length > 0" class="post-list">
          <view
            v-for="(post, index) in postList"
            :key="post.postId || index"
            class="post-item"
            @click="goToDetail(post)"
          >
            <view class="post-title-row">
              <text class="post-title">{{ post.title || '无标题' }}</text>
            </view>
            <text class="post-content line-clamp-2">{{ post.content || '暂无内容' }}</text>
            <view class="post-meta">
              <view class="meta-left">
                <image class="avatar-xs" :src="post.avatar || '/static/default_avatar.jpg'" />
                <text class="author-name">{{ post.nickName || '匿名用户' }}</text>
                <text class="post-time">{{ formatTime(post.createTime) }}</text>
              </view>
              <view class="meta-right">
                <view class="stat-item">
                  <uni-icons type="eye" size="14" color="#94a3b8" />
                  <text>{{ post.viewCount || 0 }}</text>
                </view>
                <view class="stat-item">
                  <uni-icons type="chat" size="14" color="#94a3b8" />
                  <text>{{ post.commentCount || 0 }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>

        <!-- 空状态 -->
        <view v-else class="empty-state">
          <text class="empty-text">未找到相关帖子</text>
          <text class="empty-hint">换个关键词试试吧</text>
        </view>

        <!-- 加载更多 -->
        <uni-load-more v-if="postList.length > 0" :status="loadMoreStatus" @loadmore="loadMore" />
      </view>

      <!-- 历史记录（未搜索时显示） -->
      <view v-else class="history-section">
        <view class="section-header">
          <text class="section-title">搜索历史</text>
          <uni-icons
            v-if="searchHistory.length > 0"
            type="trash"
            size="18"
            color="#94a3b8"
            @click="clearHistory"
          />
        </view>

        <!-- 历史记录列表 -->
        <view v-if="searchHistory.length > 0" class="history-list">
          <view
            v-for="(item, index) in searchHistory"
            :key="index"
            class="history-item"
            @click="searchKeyword(item)"
          >
            <uni-icons type="time" size="16" color="#94a3b8" />
            <text class="history-text">{{ item }}</text>
            <uni-icons
              type="closeempty"
              size="16"
              color="#94a3b8"
              @click.stop="removeHistory(index)"
            />
          </view>
        </view>

        <!-- 空状态 -->
        <view v-else class="empty-history">
          <text class="empty-text">暂无搜索历史</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';
import uniLoadMore from '@dcloudio/uni-ui/lib/uni-load-more/uni-load-more.vue';
import { searchPosts } from '@/api/forum';

export default {
  name: 'ForumSearch',
  components: {
    uniIcons,
    uniLoadMore
  },
  data() {
    return {
      keyword: '',
      isFocused: true,
      hasSearched: false,
      searchHistory: [],
      postList: [],
      totalCount: 0,
      pageNum: 1,
      pageSize: 10,
      loadMoreStatus: 'more'
    };
  },
  onLoad() {
    // 加载搜索历史
    this.loadSearchHistory();
  },
  methods: {
    // 输入事件
    onInput(e) {
      this.keyword = e.detail.value;
    },

    // 搜索
    async onSearch() {
      if (!this.keyword || !this.keyword.trim()) {
        uni.showToast({ title: '请输入搜索关键词', icon: 'none' });
        return;
      }

      const keyword = this.keyword.trim();
      this.hasSearched = true;
      this.pageNum = 1;
      this.postList = [];
      this.loadMoreStatus = 'loading';

      // 保存到历史记录
      this.saveToHistory(keyword);

      try {
        const res = await searchPosts(keyword, null, this.pageNum, this.pageSize);
        const posts = res.rows || [];
        this.postList = posts.map(post => ({
          ...post,
          createTime: post.createTime || post.updatedAt,
          nickName: post.nickName || post.username || '匿名用户',
          avatar: post.avatar || '/static/default_avatar.jpg',
          images: post.imgURLs || post.images || []
        }));
        this.totalCount = res.total || 0;

        if (posts.length < this.pageSize) {
          this.loadMoreStatus = 'noMore';
        } else {
          this.loadMoreStatus = 'more';
        }
      } catch (error) {
        console.error('搜索失败:', error);
        uni.showToast({ title: '搜索失败', icon: 'none' });
        this.loadMoreStatus = 'more';
      }
    },

    // 加载更多
    async loadMore() {
      if (this.loadMoreStatus !== 'more') return;

      this.pageNum++;
      this.loadMoreStatus = 'loading';

      try {
        const res = await searchPosts(this.keyword.trim(), null, this.pageNum, this.pageSize);
        const posts = res.rows || [];
        const newPosts = posts.map(post => ({
          ...post,
          createTime: post.createTime || post.updatedAt,
          nickName: post.nickName || post.username || '匿名用户',
          avatar: post.avatar || '/static/default_avatar.jpg',
          images: post.imgURLs || post.images || []
        }));

        this.postList = [...this.postList, ...newPosts];

        if (posts.length < this.pageSize) {
          this.loadMoreStatus = 'noMore';
        } else {
          this.loadMoreStatus = 'more';
        }
      } catch (error) {
        console.error('加载更多失败:', error);
        this.pageNum--;
        this.loadMoreStatus = 'more';
      }
    },

    // 搜索历史关键词
    searchKeyword(keyword) {
      this.keyword = keyword;
      this.onSearch();
    },

    // 清空关键词
    clearKeyword() {
      this.keyword = '';
      this.isFocused = true;
    },

    // 保存到历史记录
    saveToHistory(keyword) {
      // 移除重复项
      const index = this.searchHistory.indexOf(keyword);
      if (index > -1) {
        this.searchHistory.splice(index, 1);
      }
      // 添加到开头
      this.searchHistory.unshift(keyword);
      // 限制历史记录数量
      if (this.searchHistory.length > 10) {
        this.searchHistory = this.searchHistory.slice(0, 10);
      }
      // 保存到本地存储
      uni.setStorageSync('forum_search_history', JSON.stringify(this.searchHistory));
    },

    // 加载搜索历史
    loadSearchHistory() {
      try {
        const history = uni.getStorageSync('forum_search_history');
        if (history) {
          this.searchHistory = JSON.parse(history);
        }
      } catch (error) {
        console.error('加载搜索历史失败:', error);
      }
    },

    // 清空历史记录
    clearHistory() {
      uni.showModal({
        title: '提示',
        content: '确定要清空搜索历史吗？',
        success: (res) => {
          if (res.confirm) {
            this.searchHistory = [];
            uni.removeStorageSync('forum_search_history');
          }
        }
      });
    },

    // 删除单条历史记录
    removeHistory(index) {
      this.searchHistory.splice(index, 1);
      uni.setStorageSync('forum_search_history', JSON.stringify(this.searchHistory));
    },

    // 跳转详情
    goToDetail(post) {
      const id = post.postId || post.id;
      if (id) {
        uni.navigateTo({
          url: `/pages/forum/detail?postId=${id}`
        });
      }
    },

    // 返回
    goBack() {
      uni.navigateBack();
    },

    // 格式化时间
    formatTime(time) {
      if (!time) return '';
      const now = new Date();
      const timestamp = new Date(time);
      const diff = now - timestamp;

      const minute = 60 * 1000;
      const hour = 60 * minute;
      const day = 24 * hour;

      if (diff < minute) {
        return '刚刚';
      } else if (diff < hour) {
        return Math.floor(diff / minute) + '分钟前';
      } else if (diff < day) {
        return Math.floor(diff / hour) + '小时前';
      } else if (diff < 7 * day) {
        return Math.floor(diff / day) + '天前';
      } else {
        const month = timestamp.getMonth() + 1;
        const date = timestamp.getDate();
        return `${month}月${date}日`;
      }
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.search-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $background-light;
}

.search-header {
  display: flex;
  align-items: center;
  padding: 16rpx 24rpx;
  background-color: $background-light;
  border-bottom: 1rpx solid $border-light;
  gap: 16rpx;
}

.search-bar {
  flex: 1;
  display: flex;
  align-items: center;
  background-color: $surface-light;
  border-radius: $radius-full;
  padding: 16rpx 24rpx;
  gap: 12rpx;
}

.search-icon {
  flex-shrink: 0;
}

.search-input {
  flex: 1;
  font-size: $font-default;
  color: $text-primary-light;
}

.clear-icon {
  flex-shrink: 0;
}

.cancel-btn {
  font-size: $font-default;
  color: $text-secondary-light;
  flex-shrink: 0;
}

.search-content {
  flex: 1;
  padding: 24rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.section-title {
  font-size: $font-lg;
  font-weight: 700;
  color: $text-primary-light;
}

.section-count {
  font-size: $font-default;
  color: $text-secondary-light;
}

// 历史记录
.history-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.history-item {
  display: flex;
  align-items: center;
  padding: 24rpx;
  background-color: $surface-light;
  border-radius: $radius-default;
  gap: 16rpx;
}

.history-text {
  flex: 1;
  font-size: $font-default;
  color: $text-secondary-light;
}

.empty-history {
  padding: 120rpx 0;
  text-align: center;
}

// 搜索结果
.post-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.post-item {
  background-color: $surface-light;
  border-radius: $radius-default;
  padding: 24rpx;
}

.post-title-row {
  margin-bottom: 12rpx;
}

.post-title {
  font-size: $font-lg;
  font-weight: 700;
  color: $text-primary-light;
  line-height: 1.4;
}

.post-content {
  font-size: $font-default;
  color: $text-secondary-light;
  line-height: 1.5;
  margin-bottom: 16rpx;
}

.post-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.meta-left {
  display: flex;
  align-items: center;
  gap: 12rpx;
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

.post-time {
  font-size: $font-xs;
  color: $text-tertiary-light;
}

.meta-right {
  display: flex;
  gap: 24rpx;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4rpx;
  font-size: $font-xs;
  color: $text-tertiary-light;
}

.empty-state {
  padding: 120rpx 0;
  text-align: center;
}

.empty-text {
  display: block;
  font-size: $font-default;
  color: $text-secondary-light;
  margin-bottom: 12rpx;
}

.empty-hint {
  display: block;
  font-size: $font-sm;
  color: $text-tertiary-light;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .search-header {
    background-color: $background-dark;
    border-bottom-color: rgba(255, 255, 255, 0.05);
  }

  .search-bar {
    background-color: $card-dark;
  }

  .search-input {
    color: $text-primary-dark;
  }

  .cancel-btn {
    color: $text-secondary-dark;
  }

  .history-item,
  .post-item {
    background-color: $card-dark;
  }

  .section-title {
    color: $text-primary-dark;
  }

  .history-text,
  .post-content,
  .author-name {
    color: $text-secondary-dark;
  }

  .post-title {
    color: $text-primary-dark;
  }
}
</style>
