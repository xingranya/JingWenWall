<template>
  <view class="publish-container">
    <view class="form-container">
      <!-- 图片上传 -->
      <view class="image-section shadow-sm">
        <view class="image-list">
          <view 
            v-for="(img, index) in displayImages" 
            :key="index"
            class="image-item"
          >
            <image :src="img" mode="aspectFill"></image>
            <view class="delete-btn" @click="deleteImage(index)">
              <text class="iconfont icon-close"></text>
            </view>
          </view>
          
          <view 
            v-if="displayImages.length < 9" 
            class="add-image"
            @click="chooseImage"
          >
            <text class="iconfont icon-camera"></text>
            <text class="tip">添加图片</text>
          </view>
        </view>
      </view>

      <!-- 描述输入 -->
      <view class="form-group">
        <textarea 
          class="content-input" 
          v-model="formData.content" 
          placeholder="描述你的宝贝：品牌型号、入手渠道、转手原因..." 
          maxlength="500"
          :show-count="true"
        />
      </view>

      <!-- 价格输入 -->
      <view class="form-item shadow-sm">
        <view class="label">
          <text class="iconfont icon-money"></text>
          <text>价格 (元)</text>
        </view>
        <input 
          class="input price-input" 
          type="digit" 
          v-model="formData.price" 
          placeholder="0.00"
        />
      </view>

      <!-- 成色标签选择 -->
      <view class="tag-section">
        <view class="section-title">成色</view>
        <view class="tag-list">
          <view 
            v-for="(tag, index) in statusTags" 
            :key="index"
            class="tag-item"
            :class="{ active: formData.statusTag === tag }"
            @click="formData.statusTag = tag"
          >
            {{ tag }}
          </view>
        </view>
      </view>

      <!-- 匿名选项 -->
      <view class="switch-item">
        <text>匿名发布</text>
        <switch 
          :checked="formData.isAnonymous === 1"
          @change="onAnonymousChange" 
          color="#007aff"
          style="transform:scale(0.8)"
        />
      </view>
    </view>

    <!-- 底部按钮 -->
    <view class="bottom-action safe-bottom">
      <button class="submit-btn" :loading="isSubmitting" @click="handleSubmit">立即发布</button>
    </view>
  </view>
</template>

<script>
import { publishMarketItem } from '@/api/market.js';
import { uploadSingleFile } from '@/api/topic.js'; // 假设图片上传API在这里

export default {
  data() {
    return {
      formData: {
        content: '',
        price: '',
        statusTag: '全新',
        fileList: [], // 存储文件ID提交给后端
        categoryId: 5, // 假设二手市场属于分类ID 5
        isAnonymous: 0,
        type: 1 // 1图片
      },
      displayImages: [], // 用于前端显示
      statusTags: ['全新', '99新', '95新', '9成新', '85新', '8成新', '功能正常'],
      isSubmitting: false,
      uploadingImage: false
    };
  },
  methods: {
    // 切换匿名
    onAnonymousChange(e) {
      this.formData.isAnonymous = e.detail.value ? 1 : 0;
    },
    
    // 选择图片
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

    // 上传图片
    async uploadImages(filePaths) {
      this.uploadingImage = true;
      uni.showLoading({ title: '上传中...' });
      
      try {
        for (const filePath of filePaths) {
          const res = await uploadSingleFile(filePath);
          // res 是 CampusFileEntity 对象: { fileId, url, ... }
          if (res && res.url && res.fileId) {
             this.displayImages.push(res.url);
             this.formData.fileList.push(res.fileId);
          }
        }
      } catch (err) {
        uni.showToast({ title: '图片上传失败', icon: 'none' });
        console.error(err);
      } finally {
        this.uploadingImage = false;
        uni.hideLoading();
      }
    },

    // 删除图片
    deleteImage(index) {
      this.displayImages.splice(index, 1);
      this.formData.fileList.splice(index, 1);
    },

    // 提交发布
    async handleSubmit() {
      // 校验
      if (!this.formData.content.trim()) {
        uni.showToast({ title: '请输入商品描述', icon: 'none' });
        return;
      }
      if (!this.formData.price) {
        uni.showToast({ title: '请输入售价', icon: 'none' });
        return;
      }
      if (this.formData.fileList.length === 0) {
        uni.showToast({ title: '请至少上传一张图片', icon: 'none' });
        return;
      }

      this.isSubmitting = true;
      try {
        await publishMarketItem({
          ...this.formData,
          price: parseFloat(this.formData.price),
        });
        
        uni.showToast({ title: '发布成功', icon: 'success' });
        setTimeout(() => {
          uni.navigateBack();
        }, 1500);
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
.publish-container {
  min-height: 100vh;
  background-color: #f8f9fa;
  padding: 20rpx;
  box-sizing: border-box;
}

.form-container {
  padding-bottom: 120rpx;
}

.form-group {
  background-color: #fff;
  border-radius: 16rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  
  .content-input {
    width: 100%;
    height: 200rpx;
    font-size: 28rpx;
    line-height: 1.5;
  }
}

.image-section {
  background-color: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
  
  &.shadow-sm {
    box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.02);
  }

  .image-list {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16rpx;
  }

  .image-item {
    position: relative;
    width: 100%;
    padding-bottom: 100%;
    
    image {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border-radius: 12rpx;
    }
    
    .delete-btn {
      position: absolute;
      top: -12rpx;
      right: -12rpx;
      width: 40rpx;
      height: 40rpx;
      background: rgba(0,0,0,0.5);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 10;
      
      .iconfont {
        color: #fff;
        font-size: 24rpx;
      }
    }
  }
  
  .add-image {
    background-color: #f5f5f5;
    border-radius: 12rpx;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    aspect-ratio: 1;
    
    .iconfont {
      font-size: 48rpx;
      color: #999;
      margin-bottom: 8rpx;
    }
    
    .tip {
      font-size: 24rpx;
      color: #999;
    }
  }
}

.form-item {
  background-color: #fff;
  border-radius: 16rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  display: flex;
  align-items: center;
  
  &.shadow-sm {
    box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.02);
  }

  .label {
    width: 180rpx;
    display: flex;
    align-items: center;
    font-size: 28rpx;
    color: #333;
    font-weight: 500;
    
    .iconfont {
      margin-right: 10rpx;
      font-size: 32rpx;
      color: #666;
    }
  }
  
  .input {
    flex: 1;
    font-size: 28rpx;
    color: #333;
    
    &.price-input {
      color: #ff4d4f;
      font-weight: 500;
      font-size: 32rpx;
    }
  }
}

.tag-section {
  background-color: #fff;
  border-radius: 16rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  
  .section-title {
    font-size: 28rpx;
    font-weight: 500;
    margin-bottom: 20rpx;
    color: #333;
  }
  
  .tag-list {
    display: flex;
    flex-wrap: wrap;
    gap: 20rpx;
    
    .tag-item {
      padding: 12rpx 30rpx;
      background-color: #f5f5f5;
      border-radius: 100rpx;
      font-size: 26rpx;
      color: #666;
      transition: all 0.3s;
      
      &.active {
        background-color: rgba(255, 170, 0, 0.1);
        color: #ffaa00;
        font-weight: 500;
      }
    }
  }
}

.switch-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 10rpx;
  font-size: 28rpx;
  color: #666;
}

.bottom-action {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx 30rpx;
  background-color: #fff;
  box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.05);
  
  .submit-btn {
    background-color: #007aff;
    color: #fff;
    border-radius: 50rpx;
    font-size: 32rpx;
    font-weight: 500;
    height: 88rpx;
    line-height: 88rpx;
    
    &::after {
      border: none;
    }
  }
}
</style>
