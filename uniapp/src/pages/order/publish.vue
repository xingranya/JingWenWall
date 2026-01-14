<template>
  <view class="publish-page">
    <!-- 顶部提示 -->
    <view class="tip-banner">
      <uni-icons type="info" size="16" color="#007fff" />
      <text>发布求助后，会有校友帮你完成任务</text>
    </view>
    
    <!-- 需求描述 -->
    <view class="form-section">
      <view class="section-header">
        <text class="section-title">需求描述</text>
        <text class="required-mark">*</text>
      </view>
      <view class="input-card">
        <textarea 
          class="desc-textarea" 
          v-model="formData.goodsDesc" 
          :placeholder="descPlaceholder" 
          maxlength="200"
          :show-count="true"
          placeholder-class="placeholder-text"
        />
      </view>
    </view>

    <!-- 赏金设置 -->
    <view class="form-section">
      <view class="reward-card">
        <view class="reward-header">
          <view class="reward-title">
            <uni-icons type="gift" size="20" color="#ff9500" />
            <text>设置赏金</text>
            <text class="required-mark">*</text>
          </view>
          <text class="reward-tip">合理的赏金更容易获得帮助</text>
        </view>
        <view class="reward-input-wrapper">
          <text class="currency-symbol">¥</text>
          <input 
            class="reward-input" 
            type="digit" 
            v-model="formData.tip" 
            placeholder="0.00"
            placeholder-class="reward-placeholder"
          />
        </view>
        <!-- 快捷金额 -->
        <view class="quick-amounts">
          <view 
            v-for="amount in quickAmounts" 
            :key="amount"
            class="amount-tag"
            :class="{ active: formData.tip === amount.toString() }"
            @click="setQuickAmount(amount)"
          >
            ¥{{ amount }}
          </view>
        </view>
      </view>
    </view>

    <!-- 送达地址 -->
    <view class="form-section">
      <view class="section-header">
        <text class="section-title">送达地点</text>
        <text class="required-mark">*</text>
      </view>
      <view class="location-card" @click="chooseLocation">
        <view class="location-icon">
          <uni-icons type="location" size="22" color="#007fff" />
        </view>
        <view class="location-content">
          <text class="location-text" :class="{ placeholder: !formData.deliveryAddr }">
            {{ formData.deliveryAddr || '点击选择或输入地点' }}
          </text>
        </view>
        <uni-icons type="right" size="16" color="#c8c7cc" />
      </view>
    </view>

    <!-- 求助类型 -->
    <view class="form-section">
      <view class="section-header">
        <text class="section-title">求助类型</text>
      </view>
      <view class="type-tags">
        <view 
          v-for="(tag, index) in typeTags" 
          :key="index"
          class="type-tag"
          :class="{ active: selectedType === tag.type }"
          @click="selectType(tag)"
        >
          <text class="tag-icon">{{ tag.icon }}</text>
          <text class="tag-name">{{ tag.name }}</text>
        </view>
      </view>
    </view>

    <!-- 发布设置 -->
    <view class="form-section">
      <view class="settings-card">
        <view class="setting-item">
          <view class="setting-left">
            <uni-icons type="eye-slash" size="18" color="#64748b" />
            <text class="setting-label">匿名发布</text>
          </view>
          <switch 
            :checked="formData.isAnonymous === 1"
            @change="onAnonymousChange" 
            color="#007fff"
            style="transform: scale(0.85)"
          />
        </view>
      </view>
    </view>

    <!-- 底部发布按钮 -->
    <view class="bottom-bar safe-bottom">
      <button 
        class="publish-btn" 
        :class="{ disabled: !canPublish }"
        :loading="isSubmitting" 
        @click="handleSubmit"
      >
        {{ isSubmitting ? '发布中...' : '立即发布' }}
      </button>
    </view>
  </view>
</template>

<script>
import { createOrder } from '@/api/errand.js';

export default {
  data() {
    return {
      formData: {
        goodsDesc: '',
        tip: '',
        deliveryAddr: '',
        type: 0
      },
      descPlaceholder: '详细描述你需要帮忙做什么~\n例如：取个快递、带份午饭、帮打印资料...',
      isAnonymous: false,
      typeTags: [
        { name: '取快递', icon: '📦', type: 0 },
        { name: '带饭', icon: '🍱', type: 1 },
        { name: '寄快递', icon: '📮', type: 2 },
        { name: '排队', icon: '🧍', type: 3 },
        { name: '跑腿', icon: '🏃', type: 4 },
        { name: '其他', icon: '💡', type: 4 }
      ],
      selectedType: 0,
      quickAmounts: [3, 5, 8, 10, 15, 20],
      isSubmitting: false
    };
  },
  computed: {
    canPublish() {
      return this.formData.goodsDesc.trim() && 
             this.formData.tip && 
             this.formData.deliveryAddr;
    },
    selectedTypeName() {
      const tag = this.typeTags.find(t => t.type === this.selectedType);
      return tag ? tag.name : '取快递';
    }
  },
  methods: {
    onAnonymousChange(e) {
      this.isAnonymous = e.detail.value;
    },
    
    selectType(tag) {
      this.selectedType = tag.type;
      this.formData.type = tag.type;
    },
    
    setQuickAmount(amount) {
      this.formData.tip = amount.toString();
    },
    
    chooseLocation() {
      uni.chooseLocation({
        success: (res) => {
          this.formData.deliveryAddr = res.name || res.address;
        },
        fail: () => {
          uni.showModal({
            title: '输入地点',
            editable: true,
            placeholderText: '请输入送达地点',
            success: (res) => {
              if (res.confirm && res.content) {
                this.formData.deliveryAddr = res.content;
              }
            }
          });
        }
      });
    },

    async handleSubmit() {
      if (!this.canPublish) {
        if (!this.formData.goodsDesc.trim()) {
          uni.showToast({ title: '请描述你的需求', icon: 'none' });
        } else if (!this.formData.tip) {
          uni.showToast({ title: '请设置赏金', icon: 'none' });
        } else if (!this.formData.deliveryAddr) {
          uni.showToast({ title: '请填写送达地点', icon: 'none' });
        }
        return;
      }

      this.isSubmitting = true;
      try {
        const orderData = {
          type: this.formData.type,
          goodsDesc: this.formData.goodsDesc,
          deliveryAddr: this.formData.deliveryAddr,
          tip: parseFloat(this.formData.tip)
        };
        
        await createOrder(orderData);
        
        uni.showToast({ title: '发布成功', icon: 'success' });
        setTimeout(() => uni.navigateBack(), 1500);
      } catch (err) {
        uni.showToast({ title: err || '发布失败', icon: 'none' });
      } finally {
        this.isSubmitting = false;
      }
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.publish-page {
  min-height: 100vh;
  background: $background-dim;
  padding-bottom: calc(140rpx + env(safe-area-inset-bottom));
}

.tip-banner {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 24rpx 32rpx;
  background: linear-gradient(135deg, rgba(0, 127, 255, 0.08) 0%, rgba(0, 127, 255, 0.04) 100%);
  
  text {
    font-size: 26rpx;
    color: $primary;
    font-weight: 500;
  }
}

.form-section {
  padding: 0 24rpx;
  margin-top: 24rpx;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 4rpx;
  padding: 0 8rpx 16rpx;
}

.section-title {
  font-size: 30rpx;
  font-weight: 600;
  color: $text-primary-light;
}

.required-mark {
  color: $accent-red;
  font-size: 28rpx;
  margin-left: 4rpx;
}

.input-card {
  background: #ffffff;
  border-radius: $radius-lg;
  padding: 24rpx;
  box-shadow: $shadow-soft;
}

.desc-textarea {
  width: 100%;
  min-height: 160rpx;
  font-size: 28rpx;
  line-height: 1.6;
  color: $text-primary-light;
}

.placeholder-text {
  color: $text-tertiary-light;
}

.reward-card {
  background: linear-gradient(135deg, #fff9f0 0%, #ffffff 100%);
  border-radius: $radius-lg;
  padding: 28rpx;
  box-shadow: $shadow-soft;
  border: 2rpx solid rgba(255, 149, 0, 0.15);
}

.reward-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.reward-title {
  display: flex;
  align-items: center;
  gap: 8rpx;
  
  text {
    font-size: 28rpx;
    font-weight: 600;
    color: $text-primary-light;
  }
}

.reward-tip {
  font-size: 22rpx;
  color: $text-tertiary-light;
}

.reward-input-wrapper {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
  padding: 16rpx 0;
  border-bottom: 2rpx solid $border-light;
  margin-bottom: 20rpx;
}

.currency-symbol {
  font-size: 36rpx;
  font-weight: 700;
  color: $accent-orange;
}

.reward-input {
  flex: 1;
  font-size: 56rpx;
  font-weight: 700;
  color: $accent-orange;
  letter-spacing: -2rpx;
}

.reward-placeholder {
  color: #fde0b0;
  font-weight: 400;
}

.quick-amounts {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.amount-tag {
  padding: 12rpx 28rpx;
  background: #ffffff;
  border: 2rpx solid $border-light;
  border-radius: $radius-full;
  font-size: 26rpx;
  color: $text-secondary-light;
  transition: all 0.25s ease;
  
  &.active {
    background: $accent-orange;
    border-color: $accent-orange;
    color: #ffffff;
    font-weight: 600;
  }
  
  &:active:not(.active) {
    background: $surface-light;
  }
}

.location-card {
  display: flex;
  align-items: center;
  gap: 16rpx;
  background: #ffffff;
  border-radius: $radius-lg;
  padding: 28rpx;
  box-shadow: $shadow-soft;
}

.location-icon {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: rgba(0, 127, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.location-content {
  flex: 1;
}

.location-text {
  font-size: 28rpx;
  color: $text-primary-light;
  
  &.placeholder {
    color: $text-tertiary-light;
  }
}

.type-tags {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
}

.type-tag {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 24rpx 16rpx;
  background: #ffffff;
  border-radius: $radius-lg;
  box-shadow: $shadow-soft;
  transition: all 0.25s ease;
  
  .tag-icon {
    font-size: 36rpx;
  }
  
  .tag-name {
    font-size: 24rpx;
    color: $text-secondary-light;
  }
  
  &.active {
    background: linear-gradient(135deg, $primary 0%, #0066cc 100%);
    box-shadow: 0 6rpx 20rpx rgba(0, 127, 255, 0.35);
    
    .tag-name {
      color: #ffffff;
      font-weight: 600;
    }
  }
}

.settings-card {
  background: #ffffff;
  border-radius: $radius-lg;
  overflow: hidden;
  box-shadow: $shadow-soft;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx;
}

.setting-left {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.setting-label {
  font-size: 28rpx;
  color: $text-primary-light;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx 32rpx;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20rpx);
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.publish-btn {
  width: 100%;
  height: 96rpx;
  background: linear-gradient(135deg, $primary 0%, #0066cc 100%);
  color: #ffffff;
  border-radius: 48rpx;
  font-size: 32rpx;
  font-weight: 600;
  letter-spacing: 2rpx;
  border: none;
  box-shadow: 0 8rpx 24rpx rgba(0, 127, 255, 0.35);
  
  &.disabled {
    background: $border-light;
    color: $text-tertiary-light;
    box-shadow: none;
  }
  
  &::after { border: none; }
  
  &:active:not(.disabled) {
    transform: scale(0.98);
  }
}

@media (prefers-color-scheme: dark) {
  .publish-page {
    background: $background-dark;
  }
  
  .tip-banner {
    background: linear-gradient(135deg, rgba(0, 127, 255, 0.15) 0%, rgba(0, 127, 255, 0.08) 100%);
  }
  
  .input-card,
  .location-card,
  .settings-card {
    background: $card-dark;
  }
  
  .reward-card {
    background: linear-gradient(135deg, #2a2218 0%, $card-dark 100%);
    border-color: rgba(255, 149, 0, 0.2);
  }
  
  .section-title,
  .setting-label,
  .location-text:not(.placeholder) {
    color: $text-primary-dark;
  }
  
  .desc-textarea {
    color: $text-primary-dark;
  }
  
  .type-tag:not(.active) {
    background: $surface-dark;
  }
  
  .amount-tag:not(.active) {
    background: $surface-dark;
    border-color: $border-dark;
  }
  
  .bottom-bar {
    background: rgba(27, 27, 29, 0.95);
  }
}
</style>
