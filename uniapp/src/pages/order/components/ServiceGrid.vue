<!--
  服务类型网格组件
  参考 campus_marketplace 模板样式
-->
<template>
  <view class="service-grid">
    <view 
      v-for="(item, index) in services" 
      :key="index"
      class="service-item"
      @click="handleClick(item)"
    >
      <view class="icon-wrapper">
        <uni-icons :type="item.icon" size="32" color="#007fff" />
      </view>
      <text class="service-label">{{ item.label }}</text>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'ServiceGrid',
  components: {
    uniIcons
  },
  data() {
    return {
      services: [
        { label: '代取快递', icon: 'flag', type: 'express' }, // package_2 -> flag
        { label: '食堂带饭', icon: 'cart', type: 'food' }, // lunch_dining -> cart
        { label: '打印服务', icon: 'paperclip', type: 'print' }, // print -> paperclip
        { label: '代送物品', icon: 'bag', type: 'delivery' } // local_mall -> bag
      ]
    };
  },
  methods: {
    handleClick(item) {
      this.$emit('click', item);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.service-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24rpx;
  padding: 0 40rpx;
  margin-bottom: $spacing-lg;
}

.service-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40rpx;
  background-color: $background-light;
  border-radius: $radius-lg;
  box-shadow: $shadow-soft;
  transition: all 0.2s ease;
  
  &:active {
    transform: scale(0.95);
  }
}

.icon-wrapper {
  width: 112rpx;
  height: 112rpx;
  border-radius: 50%;
  background-color: rgba(0, 127, 255, 0.08);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16rpx;
}

.service-label {
  font-size: 30rpx;
  font-weight: 600;
  color: $text-primary-light;
  letter-spacing: 1rpx;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .service-item {
    background-color: $card-dark;
  }
  
  .icon-wrapper {
    background-color: rgba(0, 127, 255, 0.15);
  }
  
  .service-label {
    color: $text-primary-dark;
  }
}
</style>
