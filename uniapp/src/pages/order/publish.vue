<template>
  <view class="publish-container">
    <view class="form-container">
      <!-- 描述输入 -->
      <view class="form-group">
        <textarea 
          class="content-input" 
          v-model="formData.content" 
          placeholder="需要帮忙做什么？(例如：取快递、带饭、打印...)" 
          maxlength="200"
          :show-count="true"
        />
      </view>

      <!-- 赏金输入 -->
      <view class="form-item shadow-sm">
        <view class="label">
          <text class="iconfont icon-money"></text>
          <text>赏金 (元)</text>
        </view>
        <input 
          class="input" 
          type="digit" 
          v-model="formData.price" 
          placeholder="0.00"
        />
      </view>

      <!-- 目的地输入 -->
      <view class="form-item shadow-sm">
        <view class="label">
          <text class="iconfont icon-location"></text>
          <text>目的地</text>
        </view>
        <input 
          class="input" 
          type="text" 
          v-model="formData.location" 
          placeholder="送到哪里去？"
        />
        <view class="action-icon" @click="chooseLocation">
          <text class="iconfont icon-map"></text>
        </view>
      </view>

      <!-- 类型标签选择 -->
      <view class="tag-section">
        <view class="section-title">求助类型</view>
        <view class="tag-list">
          <view 
            v-for="(tag, index) in typeTags" 
            :key="index"
            class="tag-item"
            :class="{ active: formData.typeTag === tag }"
            @click="formData.typeTag = tag"
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
import { publishErrand } from '@/api/errand.js';

export default {
  data() {
    return {
      formData: {
        content: '',
        price: '',
        location: '',
        typeTag: '取快递', 
        categoryId: 6, // 假设跑腿属于分类ID 6，需要根据实际后端分类表调整
        isAnonymous: 0,
        type: 0 // 0文字 默认
      },
      typeTags: ['取快递', '带饭', '打印', '借物', '其它'],
      isSubmitting: false
    };
  },
  methods: {
    // 切换匿名
    onAnonymousChange(e) {
      this.formData.isAnonymous = e.detail.value ? 1 : 0;
    },
    
    // 选择位置 (预留)
    chooseLocation() {
      uni.chooseLocation({
        success: (res) => {
          this.formData.location = res.name || res.address;
        }
      });
    },

    // 提交发布
    async handleSubmit() {
      // 校验
      if (!this.formData.content.trim()) {
        uni.showToast({ title: '请输入需求描述', icon: 'none' });
        return;
      }
      if (!this.formData.price) {
        uni.showToast({ title: '请输入赏金', icon: 'none' });
        return;
      }
       if (!this.formData.location) {
        uni.showToast({ title: '请输入目的地', icon: 'none' });
        return;
      }

      this.isSubmitting = true;
      try {
        await publishErrand({
          ...this.formData,
          price: parseFloat(this.formData.price) // 确保是数字
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
  }
  
  .action-icon {
    padding: 10rpx;
    .iconfont {
      font-size: 36rpx;
      color: #007aff;
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
        background-color: rgba(0, 122, 255, 0.1);
        color: #007aff;
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
