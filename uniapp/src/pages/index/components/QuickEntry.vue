<!--
  快捷入口网格组件
  参考 campus_home_dashboard 模板样式
  功能入口：跑腿、二手、图书馆、社团等
-->
<template>
  <view class="quick-entry-section">
    <scroll-view scroll-x class="entry-scroll no-scrollbar">
      <view class="entry-grid">
        <view 
          v-for="(item, index) in entryList" 
          :key="index"
          class="entry-item"
          @click="handleClick(item)"
        >
          <view class="entry-icon-wrapper">
            <uni-icons 
              :type="item.icon" 
              :size="32" 
              :color="item.color || '#007fff'"
            />
          </view>
          <text class="entry-label">{{ item.label }}</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'QuickEntry',
  components: {
    uniIcons
  },
  data() {
    return {
      entryList: [
        {
          label: '跑腿',
          icon: 'checkbox',
          color: '#007fff',
          path: '/pages/order/order'
        },
        {
          label: '二手',
          icon: 'shop',
          color: '#007fff',
          path: '/pages/topic/type?type=secondhand'
        },
        {
          label: '图书馆',
          icon: 'book',
          color: '#007fff',
          path: '/pages/topic/type?type=library'
        },
        {
          label: '社团',
          icon: 'contact',
          color: '#007fff',
          path: '/pages/topic/type?type=club'
        },
        {
          label: '更多',
          icon: 'more',
          color: '#94a3b8',
          path: ''
        }
      ]
    };
  },
  methods: {
    /**
     * 处理入口点击
     * @param {Object} item - 入口项
     */
    handleClick(item) {
      if (!item.path) {
        uni.showToast({
          title: '功能开发中',
          icon: 'none'
        });
        return;
      }
      
      uni.navigateTo({
        url: item.path,
        fail: () => {
          uni.switchTab({
            url: item.path
          });
        }
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.quick-entry-section {
  margin-bottom: 40rpx;
  padding-left: 40rpx;
}

.entry-scroll {
  white-space: nowrap;
}

.no-scrollbar {
  &::-webkit-scrollbar {
    display: none;
  }
}

.entry-grid {
  display: inline-flex;
  gap: 32rpx;
  padding-right: 40rpx;
  padding-bottom: 16rpx;
}

.entry-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  min-width: 120rpx;
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.95);
  }
}

.entry-icon-wrapper {
  width: 120rpx;
  height: 120rpx;
  border-radius: 40rpx;
  background: linear-gradient(135deg, rgba(0, 127, 255, 0.08) 0%, rgba(0, 127, 255, 0.04) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2rpx solid transparent;
  transition: all 0.3s ease;
  
  &:hover {
    border-color: rgba(0, 127, 255, 0.2);
    background: linear-gradient(135deg, rgba(0, 127, 255, 0.12) 0%, rgba(0, 127, 255, 0.06) 100%);
  }
}

// 最后一个"更多"按钮样式
.entry-item:last-child {
  opacity: 0.5;
  
  .entry-icon-wrapper {
    background: $surface-light;
  }
}

.entry-label {
  font-size: 24rpx;
  font-weight: 600;
  color: $text-secondary-light;
  letter-spacing: 1rpx;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .entry-icon-wrapper {
    background: linear-gradient(135deg, rgba(0, 127, 255, 0.15) 0%, rgba(0, 127, 255, 0.08) 100%);
  }
  
  .entry-item:last-child .entry-icon-wrapper {
    background: $card-dark;
  }
  
  .entry-label {
    color: $text-secondary-dark;
  }
}
</style>
