<template>
  <view class="login-container">
    <view class="logo-section">
      <image src="/static/logo.png" class="logo" mode="aspectFit" />
      <text class="app-name">荆文Wall</text>
      <text class="slogan">连接校园每一刻</text>
    </view>
    
    <view class="action-section safe-bottom">
      <button 
        class="btn-primary w-full mb-4" 
        open-type="getPhoneNumber" 
        @getphonenumber="getPhoneNumber"
      >
        <uni-icons type="weixin" size="24" color="#ffffff" class="mr-2" />
        <text>微信一键登录</text>
      </button>
      
      <button class="btn-text w-full" @click="skip">
        暂不登录，先逛逛
      </button>
      
      <view class="agreement-row">
        <text class="agreement-text">登录即代表您同意</text>
        <text class="link" @click="openLink('service')">《用户协议》</text>
        <text class="agreement-text">和</text>
        <text class="link" @click="openLink('privacy')">《隐私协议》</text>
      </view>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';
import { userGetPhoneService } from "@/api/getPhone";

export default {
  components: {
    uniIcons
  },
  methods: {
    async getPhoneNumber(e) {
      if (e.detail.errMsg === 'getPhoneNumber:ok') {
        uni.showLoading({ title: '登录中...' });
        try {
          const code = e.detail.code;
          // 调用后端接口
          const res = await userGetPhoneService({ code });
          // 假设 res 包含 Token
          uni.setStorageSync('token', res.token || 'mock-token');
          uni.showToast({ title: '登录成功', icon: 'success' });
          
          setTimeout(() => {
            uni.switchTab({ url: '/pages/index/index' });
          }, 1000);
        } catch (error) {
          console.error(error);
          uni.showToast({ title: '登录失败，请重试', icon: 'none' });
        } finally {
          uni.hideLoading();
        }
      } else {
        uni.showToast({ title: '您取消了授权', icon: 'none' });
      }
    },
    
    skip() {
      uni.switchTab({
        url: '/pages/index/index'
      });
    },
    
    openLink(type) {
       uni.showToast({ title: '打开协议...', icon: 'none' });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.login-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 80rpx 60rpx;
  background-color: $background-light;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 160rpx;
  
  .logo {
    width: 160rpx;
    height: 160rpx;
    margin-bottom: 40rpx;
    border-radius: $radius-xl;
    box-shadow: $shadow-subtle;
  }
  
  .app-name {
    font-size: 48rpx;
    font-weight: 800;
    color: $text-primary-light;
    margin-bottom: 16rpx;
  }
  
  .slogan {
    font-size: 32rpx;
    color: $text-secondary-light;
    letter-spacing: 2rpx;
  }
}

.action-section {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.w-full {
  width: 100%;
}

.mb-4 {
  margin-bottom: 32rpx;
}

.mr-2 {
  margin-right: 16rpx;
}

.btn-primary {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 96rpx;
  background-color: #07c160; // 微信绿
  color: #ffffff;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: $radius-full;
  border: none;
  
  &::after { border: none; }
  &:active { opacity: 0.9; }
}

.btn-text {
  background-color: transparent;
  color: $text-secondary-light;
  font-size: 28rpx;
  margin-bottom: 40rpx;
  
  &::after { border: none; }
}

.agreement-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  justify-content: center;
  
  .agreement-text {
    font-size: 24rpx;
    color: $text-tertiary-light;
  }
  
  .link {
    font-size: 24rpx;
    color: $primary;
    margin: 0 4rpx;
    text-decoration: underline;
  }
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .login-container {
    background-color: $background-dark;
  }
  
  .app-name {
    color: $text-primary-dark;
  }
  
  .slogan, .btn-text {
    color: $text-secondary-dark;
  }
}
</style>
