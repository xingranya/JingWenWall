<template>
  <view class="publish-page">
    <!-- 顶部图片区域 -->
    <view class="image-section">
      <view class="section-header">
        <text class="section-title">商品图片</text>
        <text class="section-tip">最多9张，第一张为封面</text>
      </view>
      <view class="image-grid">
        <view 
          v-for="(img, index) in displayImages" 
          :key="index"
          class="image-item"
        >
          <image :src="img" mode="aspectFill" class="preview-img" />
          <view class="delete-btn" @click.stop="deleteImage(index)">
            <uni-icons type="closeempty" size="14" color="#fff" />
          </view>
          <view class="cover-badge" v-if="index === 0">封面</view>
        </view>
        
        <view 
          v-if="displayImages.length < 9" 
          class="add-image-btn"
          @click="chooseImage"
        >
          <view class="add-icon">
            <uni-icons type="camera" size="32" color="#94a3b8" />
          </view>
          <text class="add-text">添加图片</text>
          <text class="add-count">{{ displayImages.length }}/9</text>
        </view>
      </view>
    </view>

    <!-- 商品描述 -->
    <view class="form-section">
      <view class="input-card">
        <textarea 
          class="desc-textarea" 
          v-model="formData.title" 
          :placeholder="placeholderText" 
          maxlength="500"
          :show-count="true"
          placeholder-class="placeholder-text"
        />
      </view>
    </view>

    <!-- 价格设置 -->
    <view class="form-section">
      <view class="price-card">
        <view class="price-header">
          <text class="price-label">出售价格</text>
          <text class="price-required">*</text>
        </view>
        <view class="price-input-wrapper">
          <text class="currency-symbol">¥</text>
          <input 
            class="price-input" 
            type="digit" 
            v-model="formData.price" 
            placeholder="0.00"
            placeholder-class="price-placeholder"
          />
        </view>
      </view>
    </view>

    <!-- 成色选择 -->
    <view class="form-section">
      <view class="section-header">
        <text class="section-title">商品成色</text>
      </view>
      <view class="condition-tags">
        <view 
          v-for="(option, index) in conditionOptions" 
          :key="index"
          class="condition-tag"
          :class="{ active: formData.conditionLevel === option.value }"
          @click="selectCondition(option)"
        >
          <text>{{ option.label }}</text>
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
import { publishItem } from '@/api/market.js';
import { uploadSingleFile } from '@/api/topic.js';

export default {
  data() {
    return {
      formData: {
        title: '',
        description: '',
        price: '',
        conditionLevel: 7,
        categoryId: null,
        images: []
      },
      placeholderText: "描述一下你的宝贝吧~ 品牌型号、新旧程度、入手渠道、转让原因...",
      displayImages: [],
      conditionOptions: [
        { label: '全新', value: 10 },
        { label: '99新', value: 9 },
        { label: '95新', value: 8 },
        { label: '9成新', value: 7 },
        { label: '8成新', value: 6 },
        { label: '有瑕疵', value: 5 }
      ],
      isSubmitting: false,
      uploadingImage: false
    };
  },
  computed: {
    canPublish() {
      return this.formData.title.trim() && 
             this.formData.price && 
             this.displayImages.length > 0;
    },
    selectedConditionLabel() {
      const opt = this.conditionOptions.find(o => o.value === this.formData.conditionLevel);
      return opt ? opt.label : '9成新';
    }
  },
  methods: {
    selectCondition(option) {
      this.formData.conditionLevel = option.value;
    },
    
    chooseImage() {
      if (this.uploadingImage) return;
      
      uni.chooseImage({
        count: 9 - this.displayImages.length,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera'],
        success: (res) => {
          this.uploadImages(res.tempFilePaths);
        }
      });
    },

    async uploadImages(filePaths) {
      this.uploadingImage = true;
      uni.showLoading({ title: '上传中...', mask: true });
      
      try {
        for (const filePath of filePaths) {
          const res = await uploadSingleFile(filePath);
          if (res && res.url) {
            this.displayImages.push(res.url);
            this.formData.images.push(res.url);
          }
        }
      } catch (err) {
        uni.showToast({ title: '图片上传失败', icon: 'none' });
      } finally {
        this.uploadingImage = false;
        uni.hideLoading();
      }
    },

    deleteImage(index) {
      this.displayImages.splice(index, 1);
      this.formData.images.splice(index, 1);
    },

    async handleSubmit() {
      if (!this.canPublish) {
        if (!this.formData.title.trim()) {
          uni.showToast({ title: '请输入商品描述', icon: 'none' });
        } else if (!this.formData.price) {
          uni.showToast({ title: '请输入售价', icon: 'none' });
        } else if (this.displayImages.length === 0) {
          uni.showToast({ title: '请至少上传一张图片', icon: 'none' });
        }
        return;
      }

      this.isSubmitting = true;
      try {
        const itemData = {
          title: this.formData.title,
          description: this.formData.description || this.formData.title,
          price: parseFloat(this.formData.price),
          conditionLevel: this.formData.conditionLevel,
          categoryId: this.formData.categoryId,
          images: this.formData.images
        };
        
        await publishItem(itemData);
        
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

.form-section {
  padding: 0 24rpx;
  margin-bottom: 24rpx;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 24rpx 24rpx 16rpx;
}

.section-title {
  font-size: 30rpx;
  font-weight: 600;
  color: $text-primary-light;
}

.section-tip {
  font-size: 24rpx;
  color: $text-tertiary-light;
}

.image-section {
  background: #ffffff;
  margin-bottom: 24rpx;
  padding-bottom: 24rpx;
}

.image-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
  padding: 0 24rpx;
}

.image-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: $radius-md;
  overflow: hidden;
  
  .preview-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  
  .delete-btn {
    position: absolute;
    top: 8rpx;
    right: 8rpx;
    width: 40rpx;
    height: 40rpx;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .cover-badge {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: linear-gradient(to top, rgba(0,0,0,0.6), transparent);
    padding: 16rpx 12rpx 8rpx;
    font-size: 20rpx;
    color: #ffffff;
    text-align: center;
  }
}

.add-image-btn {
  aspect-ratio: 1;
  background: $surface-light;
  border: 2rpx dashed $border-light;
  border-radius: $radius-md;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  transition: all 0.2s;
  
  &:active {
    background: darken($surface-light, 3%);
  }
  
  .add-icon {
    width: 64rpx;
    height: 64rpx;
    border-radius: 50%;
    background: rgba(148, 163, 184, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .add-text {
    font-size: 24rpx;
    color: $text-secondary-light;
  }
  
  .add-count {
    font-size: 20rpx;
    color: $text-tertiary-light;
  }
}

.input-card {
  background: #ffffff;
  border-radius: $radius-lg;
  padding: 24rpx;
  box-shadow: $shadow-soft;
}

.desc-textarea {
  width: 100%;
  min-height: 200rpx;
  font-size: 28rpx;
  line-height: 1.6;
  color: $text-primary-light;
}

.placeholder-text {
  color: $text-tertiary-light;
}

.price-card {
  background: #ffffff;
  border-radius: $radius-lg;
  padding: 24rpx 28rpx;
  box-shadow: $shadow-soft;
}

.price-header {
  display: flex;
  align-items: center;
  gap: 4rpx;
  margin-bottom: 16rpx;
}

.price-label {
  font-size: 26rpx;
  color: $text-secondary-light;
}

.price-required {
  color: $accent-red;
  font-size: 28rpx;
}

.price-input-wrapper {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
}

.currency-symbol {
  font-size: 36rpx;
  font-weight: 700;
  color: $accent-red;
}

.price-input {
  flex: 1;
  font-size: 56rpx;
  font-weight: 700;
  color: $accent-red;
  letter-spacing: -2rpx;
}

.price-placeholder {
  color: #fecaca;
  font-weight: 400;
}

.condition-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  padding: 0 24rpx;
}

.condition-tag {
  padding: 16rpx 32rpx;
  background: #ffffff;
  border-radius: $radius-full;
  font-size: 26rpx;
  color: $text-secondary-light;
  box-shadow: $shadow-soft;
  transition: all 0.25s ease;
  
  &.active {
    background: linear-gradient(135deg, $accent-orange 0%, #ff7b00 100%);
    color: #ffffff;
    font-weight: 600;
    box-shadow: 0 6rpx 20rpx rgba(255, 149, 0, 0.35);
  }
  
  &:active:not(.active) {
    background: $surface-light;
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
  background: linear-gradient(135deg, $accent-orange 0%, #ff7b00 100%);
  color: #ffffff;
  border-radius: 48rpx;
  font-size: 32rpx;
  font-weight: 600;
  letter-spacing: 2rpx;
  border: none;
  box-shadow: 0 8rpx 24rpx rgba(255, 123, 0, 0.35);
  
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
  
  .image-section,
  .input-card,
  .price-card,
  .settings-card {
    background: $card-dark;
  }
  
  .section-title,
  .setting-label {
    color: $text-primary-dark;
  }
  
  .desc-textarea {
    color: $text-primary-dark;
  }
  
  .add-image-btn {
    background: $surface-dark;
    border-color: $border-dark;
  }
  
  .condition-tag:not(.active) {
    background: $surface-dark;
  }
  
  .bottom-bar {
    background: rgba(27, 27, 29, 0.95);
  }
}
</style>
