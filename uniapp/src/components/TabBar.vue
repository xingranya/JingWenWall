<!--
  统一底部导航栏组件
  参考 HTML 模板样式：毛玻璃效果 + Material Icons
-->
<template>
  <view class="tab-bar">
    <view class="tab-bar-inner">
      <view
        v-for="(item, index) in tabList"
        :key="index"
        class="tab-item"
        :class="{ active: currentIndex === index }"
        @click="switchTab(index)"
      >
        <view class="tab-icon-wrapper">
          <!-- 使用 uni-icons 替代 Material Icons -->
          <uni-icons
            :type="currentIndex === index ? item.selectedIcon : item.icon"
            :size="26"
            :color="currentIndex === index ? '#007fff' : '#94a3b8'"
          />
          <!-- 红点角标 -->
          <view v-if="item.badge" class="badge-dot"></view>
        </view>
        <text class="tab-label">{{ item.label }}</text>
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'TabBar',
  components: {
    uniIcons
  },
  props: {
    // 当前选中的索引
    current: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      currentIndex: this.current,
      tabList: [
        {
          label: '首页',
          icon: 'home',
          selectedIcon: 'home-filled',
          path: '/pages/index/index'
        },
        {
          label: '广场',
          icon: 'shop',
          selectedIcon: 'shop-filled',
          path: '/pages/order/order'
        },
        {
          label: '发现',
          icon: 'navigate',
          selectedIcon: 'navigate-filled',
          path: '/pages/forum/index',
          badge: true
        },
        {
          label: '我的',
          icon: 'person',
          selectedIcon: 'person-filled',
          path: '/pages/person/person'
        }
      ]
    };
  },
  watch: {
    current(val) {
      this.currentIndex = val;
    }
  },
  methods: {
    /**
     * 切换标签页
     * @param {number} index - 目标索引
     */
    switchTab(index) {
      if (this.currentIndex === index) return;
      
      this.currentIndex = index;
      const targetPath = this.tabList[index].path;
      
      uni.switchTab({
        url: targetPath,
        fail: () => {
          // 如果不是 tabBar 页面，使用 navigateTo
          uni.navigateTo({
            url: targetPath
          });
        }
      });
    }
  }
};
</script>

<style lang="scss" scoped>
// 引入主题变量
@import '@/static/css/theme.scss';

.tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  z-index: 9999;
  background-color: #ffffff; // 暂时移除透明度，确保可见
  border-top: 1rpx solid #e2e8f0;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.05);
  padding-bottom: env(safe-area-inset-bottom); // 确保安全区域
}

.tab-bar-inner {
  display: flex;
  justify-content: space-around;
  align-items: center;
  height: 120rpx;
  max-width: 750rpx;
  margin: 0 auto;
  padding: 0 24rpx;
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  height: 100%;
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.95);
  }
}

.tab-icon-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8rpx;
  transition: transform 0.2s ease;
}

.tab-item:not(.active) .tab-icon-wrapper:hover {
  transform: translateY(-4rpx);
}

.badge-dot {
  position: absolute;
  top: -4rpx;
  right: -8rpx;
  width: 16rpx;
  height: 16rpx;
  background-color: #ef4444;
  border-radius: 50%;
  border: 4rpx solid #ffffff;
}

.tab-label {
  font-size: 20rpx;
  font-weight: 500;
  color: $text-tertiary-light;
  transition: color 0.2s ease;
}

.tab-item.active {
  .tab-label {
    color: $primary;
    font-weight: 700;
  }
  
  .tab-icon-wrapper {
    position: relative;
    
    &::after {
      content: '';
      position: absolute;
      bottom: -12rpx;
      left: 50%;
      transform: translateX(-50%);
      width: 8rpx;
      height: 8rpx;
      background-color: $primary;
      border-radius: 50%;
    }
  }
}

// 深色模式适配
@media (prefers-color-scheme: dark) {
  .tab-bar {
    background-color: rgba(38, 38, 41, 0.9);
    border-top-color: rgba(51, 65, 85, 0.6);
  }
  
  .badge-dot {
    border-color: #262629;
  }
  
  .tab-label {
    color: $text-tertiary-dark;
  }
  
  .tab-item.active .tab-label {
    color: $primary;
  }
}
</style>
