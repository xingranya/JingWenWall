<template>
  <view class="agreement-container">
    <view class="modal-card glass-effect">
      <view class="modal-header">
        <text class="title">服务与隐私协议</text>
      </view>
      
      <scroll-view scroll-y class="content-scroll">
        <view class="text-content">
          <text class="paragraph">
            欢迎使用 荆文Wall！在您使用本服务之前，请仔细阅读
            <text class="link" @click="openLink('service')">《用户服务协议》</text>
            和
            <text class="link" @click="openLink('privacy')">《隐私政策》</text>
            。
          </text>
          <text class="paragraph">
            我们要特别向您说明：
          </text>
          <text class="paragraph">
            1. 为了向您提供更优质的服务，我们需要收集您的部分个人信息。
            2. 我们承诺严格按照法律法规要求，采取相应的安全保护措施，保护您的个人信息安全。
          </text>
          <text class="paragraph">
            如您同意以上协议内容，请点击“我已阅读并同意”开始使用我们的服务。
          </text>
        </view>
      </scroll-view>
      
      <view class="footer-actions">
        <button class="btn-secondary cancel-btn" @click="handleDisagree">不同意</button>
        <button class="btn-primary confirm-btn" @click="handleAgree">我已阅读并同意</button>
      </view>
    </view>
  </view>
</template>

<script>
import { baseUrl } from '@/utils/env';

export default {
  methods: {
    handleDisagree() {
      // 退出小程序
      uni.exitMiniProgram({
        success: () => console.log('退出成功'),
        fail: (err) => console.error('退出失败', err)
      });
    },
    
    handleAgree() {
      // 存储同意状态
      uni.setStorageSync('hasAgreedPrivacy', true);
      
      // 执行微信登录
      uni.showLoading({ title: '登录中...' });
      uni.login({
        provider: 'weixin',
        success: (loginRes) => {
          console.log('获取到微信 code:', loginRes.code);
          
          // 调用后端登录接口
          uni.request({
            url: baseUrl + '/api/v1/wx/auth/login',
            method: 'POST',
            header: { 'Content-Type': 'application/json' },
            data: { code: loginRes.code },
            success: (res) => {
              uni.hideLoading();
              console.log('登录响应:', res);
              
              if (res.statusCode === 200 && res.data.code === 200) {
                const token = res.data.data?.token;
                const studentInfo = res.data.data?.studentInfo;
                
                if (token) {
                  console.log('登录成功，token:', token);
                  uni.setStorageSync('token', token);
                  
                  // 保存用户信息
                  if (studentInfo) {
                    uni.setStorageSync('userInfo', JSON.stringify(studentInfo));
                    uni.setStorageSync('isStudentVerified', true);
                  }
                  
                  uni.showToast({ title: '登录成功', icon: 'success' });
                  
                  // 根据是否有学生信息决定跳转
                  setTimeout(() => {
                    if (studentInfo && studentInfo.studentNo) {
                      // 老用户，已有学生信息，跳转首页
                      console.log('已认证用户，跳转首页');
                      uni.reLaunch({ url: '/pages/index/index' });
                    } else {
                      // 新用户，需要完成学生认证
                      console.log('新用户，跳转认证页面');
                      uni.reLaunch({ url: '/pages/person/authentication' });
                    }
                  }, 500);
                } else {
                  uni.showToast({ title: '获取token失败', icon: 'none' });
                  uni.reLaunch({ url: '/pages/index/index' });
                }
              } else {
                uni.showToast({ title: res.data.msg || '登录失败', icon: 'none' });
                uni.reLaunch({ url: '/pages/index/index' });
              }
            },
            fail: (error) => {
              uni.hideLoading();
              console.error('登录请求失败:', error);
              uni.showToast({ title: '网络错误', icon: 'none' });
              uni.reLaunch({ url: '/pages/index/index' });
            }
          });
        },
        fail: (error) => {
          uni.hideLoading();
          console.error('微信登录失败:', error);
          uni.showToast({ title: '微信登录失败', icon: 'none' });
          uni.reLaunch({ url: '/pages/index/index' });
        }
      });
    },
    
    openLink(type) {
      // 打开 Webview 或 弹窗显示详情
      const url = type === 'service' 
        ? 'https://blog.yiming1234.cn' 
        : 'https://blog.yiming1234.cn';
        
      // 简单处理：复制链接或提示
      uni.setClipboardData({
        data: url,
        success: () => {
          uni.showToast({ title: '链接已复制', icon: 'none' });
        }
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.agreement-container {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(0, 0, 0, 0.5); // 遮罩层背景
  padding: 40rpx;
}

.modal-card {
  width: 100%;
  max-width: 600rpx;
  background-color: $background-light;
  border-radius: $radius-xl;
  padding: 40rpx;
  display: flex;
  flex-direction: column;
  box-shadow: $shadow-card;
}

.modal-header {
  margin-bottom: 32rpx;
  text-align: center;
  
  .title {
    font-size: 36rpx;
    font-weight: 700;
    color: $text-primary-light;
  }
}

.content-scroll {
  max-height: 600rpx;
  margin-bottom: 40rpx;
}

.text-content {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.paragraph {
  font-size: $font-base;
  color: $text-secondary-light;
  line-height: 1.6;
}

.link {
  color: $primary;
  font-weight: 500;
  display: inline;
}

.footer-actions {
  display: flex;
  gap: 24rpx;
}

.cancel-btn {
  flex: 1;
  background-color: $surface-light;
  color: $text-secondary-light;
  border: none;
}

.confirm-btn {
  flex: 1.5;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .modal-card {
    background-color: $card-dark;
  }
  
  .title {
    color: $text-primary-dark;
  }
  
  .paragraph {
    color: $text-secondary-dark;
  }
  
  .cancel-btn {
    background-color: rgba(255, 255, 255, 0.1);
    color: $text-primary-dark;
  }
}
</style>
