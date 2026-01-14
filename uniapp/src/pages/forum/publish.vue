<template>
  <view class="publish-page">
    <scroll-view scroll-y class="content-scroll">
      <!-- 标题输入 -->
      <view class="form-section">
        <view class="title-card">
          <textarea 
            class="title-input"
            v-model="formData.title"
            placeholder="输入标题，让更多人看到你..."
            maxlength="100"
            auto-height
            placeholder-class="title-placeholder"
          />
        </view>
      </view>

      <!-- 内容输入 -->
      <view class="form-section">
        <view class="content-card">
          <textarea 
            class="content-input"
            v-model="formData.content"
            placeholder="分享你的想法、经历或者发现..."
            maxlength="5000"
            :show-count="true"
            auto-height
            placeholder-class="content-placeholder"
          />
        </view>
      </view>

      <!-- 图片上传 -->
      <view class="form-section">
        <view class="section-header">
          <text class="section-title">添加图片</text>
          <text class="section-tip">最多9张</text>
        </view>
        <view class="image-grid">
          <view 
            v-for="(img, index) in formData.images" 
            :key="index"
            class="image-item"
          >
            <image :src="img" mode="aspectFill" class="preview-img" />
            <view class="delete-btn" @click.stop="deleteImage(index)">
              <uni-icons type="closeempty" size="14" color="#fff" />
            </view>
          </view>
          
          <view 
            v-if="formData.images.length < 9" 
            class="add-image-btn"
            @click="chooseImage"
          >
            <view class="add-icon">
              <uni-icons type="camera" size="28" color="#94a3b8" />
            </view>
            <text class="add-count">{{ formData.images.length }}/9</text>
          </view>
        </view>
      </view>

      <!-- 分类选择 -->
      <view class="form-section">
        <view class="section-header">
          <text class="section-title">选择分类</text>
          <text class="required-mark">*</text>
        </view>
        <view class="category-grid">
          <view 
            v-for="cat in categories" 
            :key="cat.id"
            class="category-item"
            :class="{ active: formData.categoryId === cat.id }"
            @click="selectCategory(cat)"
          >
            <text class="cat-icon">{{ cat.icon }}</text>
            <text class="cat-name">{{ cat.name }}</text>
          </view>
        </view>
      </view>

      <!-- 发布设置 -->
      <view class="form-section">
        <view class="settings-card">
          <view class="setting-item">
            <view class="setting-left">
              <uni-icons type="eye-slash" size="18" color="#64748b" />
              <text class="setting-label">匿名发帖</text>
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
      
      <!-- 底部占位 -->
      <view class="bottom-space"></view>
    </scroll-view>

    <!-- 底部操作栏 -->
    <view class="bottom-bar safe-bottom">
      <button class="draft-btn" @click="saveDraft">
        <uni-icons type="compose" size="18" color="#007fff" />
        <text>存草稿</text>
      </button>
      <button 
        class="publish-btn" 
        :class="{ disabled: !canPublish }"
        :loading="isSubmitting"
        @click="publish"
      >
        {{ isSubmitting ? '发布中...' : '发布' }}
      </button>
    </view>
  </view>
</template>

<script>
import { publishPost, savePostDraft, getPostDraft } from '@/api/forum';
import { uploadSingleFile } from '@/api/topic';

export default {
  data() {
    return {
      formData: {
        title: '',
        content: '',
        images: [],
        categoryId: null,
        isAnonymous: 0
      },
      categories: [
        { id: 1, name: '校园生活', icon: '🏫' },
        { id: 2, name: '学习交流', icon: '📚' },
        { id: 3, name: '社团活动', icon: '🎭' },
        { id: 4, name: '美食分享', icon: '🍜' },
        { id: 5, name: '情感树洞', icon: '💭' },
        { id: 6, name: '其他', icon: '💡' }
      ],
      selectedCategory: null,
      uploadingImage: false,
      isSubmitting: false
    };
  },
  computed: {
    canPublish() {
      return this.formData.title.trim() && 
             this.formData.content.trim() && 
             this.formData.categoryId;
    }
  },
  onLoad() {
    this.loadDraft();
  },
  methods: {
    async loadDraft() {
      try {
        const draft = await getPostDraft();
        if (draft) {
          this.formData = {
            title: draft.title || '',
            content: draft.content || '',
            images: draft.images || [],
            categoryId: draft.categoryId || null,
            isAnonymous: draft.isAnonymous || 0
          };
          
          if (draft.categoryId) {
            this.selectedCategory = this.categories.find(c => c.id === draft.categoryId);
          }
          
          uni.showToast({ title: '已加载草稿', icon: 'none' });
        }
      } catch (err) {
        console.log('没有草稿');
      }
    },
    
    selectCategory(cat) {
      this.selectedCategory = cat;
      this.formData.categoryId = cat.id;
    },
    
    chooseImage() {
      if (this.uploadingImage) {
        uni.showToast({ title: '正在上传中...', icon: 'none' });
        return;
      }
      
      uni.chooseImage({
        count: 9 - this.formData.images.length,
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
          const url = await uploadSingleFile(filePath);
          this.formData.images.push(url);
        }
      } catch (err) {
        uni.showToast({ title: err.message || '上传失败', icon: 'none' });
      } finally {
        this.uploadingImage = false;
        uni.hideLoading();
      }
    },
    
    deleteImage(index) {
      uni.showModal({
        title: '提示',
        content: '确定删除这张图片吗？',
        success: (res) => {
          if (res.confirm) {
            this.formData.images.splice(index, 1);
          }
        }
      });
    },
    
    onAnonymousChange(e) {
      this.formData.isAnonymous = e.detail.value ? 1 : 0;
    },
    
    async saveDraft() {
      if (!this.formData.title && !this.formData.content) {
        uni.showToast({ title: '请输入内容', icon: 'none' });
        return;
      }
      
      try {
        await savePostDraft(this.formData);
        uni.showToast({ title: '草稿已保存', icon: 'success' });
      } catch (err) {
        uni.showToast({ title: err.message || '保存失败', icon: 'none' });
      }
    },
    
    async publish() {
      if (!this.canPublish) {
        if (!this.formData.title.trim()) {
          uni.showToast({ title: '请输入标题', icon: 'none' });
        } else if (!this.formData.content.trim()) {
          uni.showToast({ title: '请输入内容', icon: 'none' });
        } else if (!this.formData.categoryId) {
          uni.showToast({ title: '请选择分类', icon: 'none' });
        }
        return;
      }
      
      this.isSubmitting = true;
      
      try {
        await publishPost(this.formData);
        uni.showToast({ title: '发布成功', icon: 'success' });
        setTimeout(() => uni.navigateBack(), 1500);
      } catch (err) {
        uni.showToast({ title: err.message || '发布失败', icon: 'none' });
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
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $background-dim;
}

.content-scroll {
  flex: 1;
  height: 0;
}

.form-section {
  padding: 0 24rpx;
  margin-top: 24rpx;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 0 8rpx 16rpx;
}

.section-title {
  font-size: 28rpx;
  font-weight: 600;
  color: $text-primary-light;
}

.section-tip {
  font-size: 24rpx;
  color: $text-tertiary-light;
}

.required-mark {
  color: $accent-red;
  font-size: 26rpx;
}

.title-card {
  background: #ffffff;
  border-radius: $radius-lg;
  padding: 24rpx 28rpx;
  box-shadow: $shadow-soft;
}

.title-input {
  width: 100%;
  font-size: 34rpx;
  font-weight: 600;
  line-height: 1.5;
  color: $text-primary-light;
  min-height: 60rpx;
}

.title-placeholder {
  color: $text-tertiary-light;
  font-weight: 400;
}

.content-card {
  background: #ffffff;
  border-radius: $radius-lg;
  padding: 24rpx 28rpx;
  box-shadow: $shadow-soft;
}

.content-input {
  width: 100%;
  font-size: 28rpx;
  line-height: 1.8;
  color: $text-primary-light;
  min-height: 240rpx;
}

.content-placeholder {
  color: $text-tertiary-light;
}

.image-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
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
}

.add-image-btn {
  aspect-ratio: 1;
  background: #ffffff;
  border: 2rpx dashed $border-light;
  border-radius: $radius-md;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  box-shadow: $shadow-soft;
  transition: all 0.2s;
  
  &:active {
    background: $surface-light;
  }
  
  .add-icon {
    width: 56rpx;
    height: 56rpx;
    border-radius: 50%;
    background: $surface-light;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .add-count {
    font-size: 22rpx;
    color: $text-tertiary-light;
  }
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
}

.category-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 24rpx 16rpx;
  background: #ffffff;
  border-radius: $radius-lg;
  box-shadow: $shadow-soft;
  transition: all 0.25s ease;
  
  .cat-icon {
    font-size: 32rpx;
  }
  
  .cat-name {
    font-size: 24rpx;
    color: $text-secondary-light;
  }
  
  &.active {
    background: linear-gradient(135deg, $primary 0%, #0066cc 100%);
    box-shadow: 0 6rpx 20rpx rgba(0, 127, 255, 0.35);
    
    .cat-name {
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

.bottom-space {
  height: 180rpx;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  gap: 20rpx;
  padding: 20rpx 32rpx;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20rpx);
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.05);
}

.draft-btn {
  flex: 1;
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  background: #ffffff;
  border: 2rpx solid $primary;
  border-radius: 44rpx;
  font-size: 28rpx;
  color: $primary;
  font-weight: 500;
  
  &::after { border: none; }
  
  &:active {
    background: rgba(0, 127, 255, 0.05);
  }
}

.publish-btn {
  flex: 2;
  height: 88rpx;
  background: linear-gradient(135deg, $primary 0%, #0066cc 100%);
  color: #ffffff;
  border-radius: 44rpx;
  font-size: 30rpx;
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
  
  .title-card,
  .content-card,
  .add-image-btn,
  .settings-card {
    background: $card-dark;
  }
  
  .section-title,
  .setting-label {
    color: $text-primary-dark;
  }
  
  .title-input,
  .content-input {
    color: $text-primary-dark;
  }
  
  .category-item:not(.active) {
    background: $surface-dark;
  }
  
  .add-image-btn {
    border-color: $border-dark;
    
    .add-icon {
      background: $surface-dark;
    }
  }
  
  .bottom-bar {
    background: rgba(27, 27, 29, 0.95);
  }
  
  .draft-btn {
    background: $card-dark;
    border-color: $primary;
  }
}
</style>
