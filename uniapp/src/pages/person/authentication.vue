<template>
  <view class="auth-container">
    <!-- 顶部提示 -->
    <view class="header-section">
      <view class="icon-wrapper">
        <uni-icons type="person" size="48" color="#007AFF" />
      </view>
      <text class="title">完善学生信息</text>
      <text class="subtitle">请填写以下信息完成学生认证，认证后可解锁更多功能</text>
    </view>
    
    <!-- 表单区域 -->
    <view class="form-section">
      <!-- 姓名 -->
      <view class="form-item">
        <view class="label">
          <uni-icons type="contact" size="20" color="#64748b" />
          <text>真实姓名</text>
        </view>
        <input class="input" v-model="formData.realName" placeholder="请输入真实姓名" />
      </view>
      
      <!-- 学号 -->
      <view class="form-item">
        <view class="label">
          <uni-icons type="wallet" size="20" color="#64748b" />
          <text>学号</text>
        </view>
        <input class="input" v-model="formData.studentNo" placeholder="请输入学号" />
      </view>
      
      <!-- 学院 -->
      <view class="form-item">
        <view class="label">
          <uni-icons type="home" size="20" color="#64748b" />
          <text>学院</text>
        </view>
        <picker mode="selector" :range="collegeList" @change="onCollegeChange">
          <view class="picker-value">
            <text :class="{ placeholder: !formData.college }">
              {{ formData.college || '请选择学院' }}
            </text>
            <uni-icons type="right" size="16" color="#ccc" />
          </view>
        </picker>
      </view>
    </view>
    
    <!-- 协议提示 -->
    <view class="agreement-tip">
      <checkbox :checked="agreed" @click="agreed = !agreed" color="#007AFF" />
      <text class="tip-text">
        我已阅读并同意
        <text class="link">《用户服务协议》</text>
        和
        <text class="link">《隐私政策》</text>
      </text>
    </view>
    
    <!-- 提交按钮 -->
    <view class="submit-section safe-bottom">
      <button class="submit-btn" :disabled="!canSubmit" :class="{ disabled: !canSubmit }" @click="handleSubmit">
        完成认证
      </button>
      <view class="skip-link" @click="skipAuth">
        <text>暂时跳过，稍后认证</text>
      </view>
    </view>
  </view>
</template>

<script>
import { baseUrl } from '@/utils/env';

export default {
  data() {
    return {
      formData: {
        realName: '',
        studentNo: '',
        college: ''
      },
      collegeList: [
        '计算机与信息学院',
        '机电工程学院',
        '土木工程学院',
        '经济管理学院',
        '艺术与设计学院',
        '教育学院',
        '外国语学院',
        '文学与传媒学院',
        '数学与物理学院',
        '化学与材料学院',
        '其他'
      ],
      agreed: false,
      isSubmitting: false
    };
  },
  computed: {
    canSubmit() {
      return this.formData.realName && 
             this.formData.studentNo && 
             this.formData.college && 
             this.agreed;
    }
  },
  methods: {
    onCollegeChange(e) {
      this.formData.college = this.collegeList[e.detail.value];
    },
    
    async handleSubmit() {
      if (!this.canSubmit || this.isSubmitting) return;
      
      this.isSubmitting = true;
      uni.showLoading({ title: '提交中...' });
      
      try {
        const token = uni.getStorageSync('token');
        const res = await new Promise((resolve, reject) => {
          uni.request({
            url: baseUrl + '/student/update/info',
            method: 'PUT',
            header: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
            data: {
              realName: this.formData.realName,
              studentNo: this.formData.studentNo,
              college: this.formData.college
            },
            success: (res) => resolve(res),
            fail: (err) => reject(err)
          });
        });
        
        uni.hideLoading();
        
        if (res.statusCode === 200 && res.data.code === 200) {
          // 保存用户信息
          uni.setStorageSync('userInfo', JSON.stringify(res.data.data || this.formData));
          uni.setStorageSync('isStudentVerified', true);
          
          uni.showToast({ title: '认证成功', icon: 'success' });
          setTimeout(() => {
            uni.reLaunch({ url: '/pages/index/index' });
          }, 1000);
        } else {
          uni.showToast({ title: res.data.msg || '认证失败', icon: 'none' });
        }
      } catch (error) {
        uni.hideLoading();
        console.error('认证失败:', error);
        uni.showToast({ title: '网络错误', icon: 'none' });
      } finally {
        this.isSubmitting = false;
      }
    },
    
    skipAuth() {
      uni.showModal({
        title: '提示',
        content: '跳过认证后部分功能将受限，确定跳过吗？',
        success: (res) => {
          if (res.confirm) {
            uni.reLaunch({ url: '/pages/index/index' });
          }
        }
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.auth-container {
  min-height: 100vh;
  background-color: $background-dim;
  padding: 40rpx 32rpx;
  box-sizing: border-box;
}

.header-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 0 40rpx;
  
  .icon-wrapper {
    width: 120rpx;
    height: 120rpx;
    background: rgba(0, 122, 255, 0.1);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 32rpx;
  }
  
  .title {
    font-size: $font-2xl;
    font-weight: 700;
    color: $text-primary-light;
    margin-bottom: 16rpx;
  }
  
  .subtitle {
    font-size: $font-sm;
    color: $text-secondary-light;
    text-align: center;
    line-height: 1.5;
  }
}

.form-section {
  background-color: $background-light;
  border-radius: $radius-xl;
  padding: 16rpx 0;
  box-shadow: $shadow-card;
}

.form-item {
  display: flex;
  align-items: center;
  padding: 28rpx 32rpx;
  border-bottom: 2rpx solid $border-light;
  
  &:last-child {
    border-bottom: none;
  }
  
  .label {
    width: 200rpx;
    display: flex;
    align-items: center;
    gap: 12rpx;
    font-size: $font-base;
    color: $text-primary-light;
    flex-shrink: 0;
  }
  
  .input {
    flex: 1;
    font-size: $font-base;
    color: $text-primary-light;
    text-align: right;
  }
  
  .picker-value {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 8rpx;
    font-size: $font-base;
    
    .placeholder {
      color: $text-tertiary-light;
    }
  }
  
  .phone-btn {
    flex: 1;
    background: none;
    border: none;
    font-size: $font-base;
    color: $primary;
    text-align: right;
    padding: 0;
    margin: 0;
    line-height: 1;
    
    &::after {
      border: none;
    }
    
    .placeholder {
      color: $text-tertiary-light;
    }
  }
}

.agreement-tip {
  display: flex;
  align-items: center;
  padding: 32rpx 16rpx;
  gap: 12rpx;
  
  .tip-text {
    font-size: $font-sm;
    color: $text-secondary-light;
    
    .link {
      color: $primary;
    }
  }
}

.submit-section {
  padding-top: 20rpx;
  
  .submit-btn {
    width: 100%;
    height: 96rpx;
    background-color: $primary;
    color: #fff;
    font-size: $font-lg;
    font-weight: 600;
    border-radius: $radius-full;
    display: flex;
    align-items: center;
    justify-content: center;
    
    &::after {
      border: none;
    }
    
    &.disabled {
      background-color: $text-tertiary-light;
      opacity: 0.6;
    }
  }
  
  .skip-link {
    text-align: center;
    padding: 32rpx 0;
    font-size: $font-sm;
    color: $text-tertiary-light;
  }
}

/* 深色模式 */
@media (prefers-color-scheme: dark) {
  .auth-container {
    background-color: $background-dark;
  }
  
  .header-section {
    .title {
      color: $text-primary-dark;
    }
    .subtitle {
      color: $text-secondary-dark;
    }
  }
  
  .form-section {
    background-color: $card-dark;
  }
  
  .form-item {
    border-color: $border-dark;
    
    .label, .input {
      color: $text-primary-dark;
    }
  }
}
</style>
