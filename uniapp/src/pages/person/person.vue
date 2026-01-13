<template>
  <view class="person-container">
    <scroll-view scroll-y class="person-scroll">
      <!-- 1. 头部资料 -->
      <ProfileHeader 
        :user-info="userInfo" 
        :is-logged-in="isLoggedIn"
        @edit="handleEdit" 
        @login="handleLogin"
      />
      
      <!-- 2. 统计数据 -->
      <StatsCard 
        :stats="userStats" 
        @click="handleStatClick" 
      />
      
      <!-- 3. 我的服务 -->
      <ServiceList 
        title="我的服务" 
        :list="serviceList" 
        @click="handleServiceClick" 
      />
      
      <!-- 4. 通用设置 -->
      <ServiceList 
        title="更多" 
        :list="generalList" 
        @click="handleGeneralClick" 
      />
      
      <!-- 5. 退出登录按钮 -->
      <view v-if="isLoggedIn" class="logout-wrapper safe-padding">
        <button class="logout-btn" @click="handleLogout">退出登录</button>
      </view>
      
      <!-- 版本信息 -->
      <view class="version-info">
        <text>Version 1.0.0</text>
      </view>
      
      <!-- 底部安全距离 -->
      <view class="safe-bottom-spacer"></view>
    </scroll-view>
    
    <!-- 自定义底部导航栏 -->
    <TabBar :current="3" />
  </view>
</template>

<script>
import ProfileHeader from './components/ProfileHeader.vue';
import StatsCard from './components/StatsCard.vue';
import ServiceList from './components/ServiceList.vue';
import TabBar from '@/components/TabBar.vue';
import { baseUrl } from '@/utils/env';

// import { useUserStore } from '@/stores/user'; // 假设已迁移或直接使用 storage

export default {
  components: {
    ProfileHeader,
    StatsCard,
    ServiceList,
    TabBar
  },
  data() {
    return {
      userInfo: {
        nickName: '未登录',
        avatar: '',
        deptName: '请先登录'
      },
      userStats: {
        posts: 0,
        following: 0,
        followers: 0,
        balance: '0.00'
      },
      isLoggedIn: false,
      
      serviceList: [
        { label: '我的发布', icon: 'paperplane', bg: 'rgba(0,127,255,0.1)', color: '#007fff', path: '/pages/favorites/post' },
        { label: '我的收藏', icon: 'star', bg: 'rgba(255,149,0,0.1)', color: '#ff9500', path: '/pages/favorites/index' },
        { label: '身份认证', icon: 'checkbox', bg: 'rgba(52,199,89,0.1)', color: '#34c759', path: '/pages/person/authentication' },
        { label: '地址管理', icon: 'location', bg: 'rgba(255,45,85,0.1)', color: '#ff2d55', path: '/pages/order/address' }
      ],
      
      generalList: [
        { label: '信息修改', icon: 'compose', bg: '#f1f5f9', color: '#64748b', path: '/pages/person/editInfo' },
        { label: '关于我们', icon: 'info', bg: '#f1f5f9', color: '#64748b', path: '/pages/index/about' },
        { label: '帮助反馈', icon: 'help', bg: '#f1f5f9', color: '#64748b', path: '' }
      ]
    };
  },
  onShow() {
    this.checkLoginStatus();
  },
  methods: {
    checkLoginStatus() {
      const token = uni.getStorageSync('token');
      console.log('检查登录状态 - token:', token ? '存在' : '不存在');
      this.isLoggedIn = !!token;
      
      if (this.isLoggedIn) {
        const info = uni.getStorageSync('userInfo');
        console.log('读取用户信息:', info);
        
        if (info) {
          try {
            // 尝试解析 JSON，如果已经是对象则直接使用
            const parsed = typeof info === 'string' ? JSON.parse(info) : info;
            console.log('解析后的用户信息:', parsed);
            
            this.userInfo = {
                nickName: parsed.nickName || parsed.username || parsed.studentNo || '同学',
                avatar: parsed.avatar || '/static/default_avatar.jpg',
                deptName: parsed.deptName || parsed.college || '已认证用户'
            };
            // 模拟数据
            this.userStats = {
                posts: 12,
                following: 58,
                followers: 246,
                balance: '128.50'
            };
          } catch (e) {
            console.error('解析用户信息失败:', e);
            // 即使解析失败也显示已登录状态
            this.userInfo = { nickName: '同学', avatar: '/static/default_avatar.jpg', deptName: '已认证用户' };
          }
        } else {
          // 没有用户信息但有 token，显示默认信息
          console.log('没有 userInfo 但有 token，显示默认信息');
          this.userInfo = { nickName: '同学', avatar: '/static/default_avatar.jpg', deptName: '已认证用户' };
          this.userStats = { posts: 0, following: 0, followers: 0, balance: '0.00' };
        }
      } else {
        this.userInfo = { nickName: '未登录', avatar: '', deptName: '点击登录解锁功能' };
        this.userStats = { posts: '-', following: '-', followers: '-', balance: '-' };
      }
    },
    
    handleLogin() {
      // 原有逻辑是用微信登录，或跳转 Login 页
      // 这里简易跳转
      // uni.navigateTo({ url: '/pages/login/login' });
      // 如果是用微信一键登录
      this.doWechatLogin();
    },
    
    doWechatLogin() {
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
                 if (token) {
                   console.log('登录成功，token:', token);
                   uni.setStorageSync('token', token);
                   
                   // 保存用户信息
                   if (res.data.data?.studentInfo) {
                     uni.setStorageSync('userInfo', JSON.stringify(res.data.data.studentInfo));
                   }
                   
                   uni.showToast({ title: '登录成功', icon: 'success' });
                   
                   // 延迟刷新页面以确保状态更新
                   setTimeout(() => {
                     this.checkLoginStatus();
                     // 强制刷新当前页面
                     this.$forceUpdate && this.$forceUpdate();
                   }, 300);
                 } else {
                   console.error('后端未返回token');
                   uni.showToast({ title: '获取token失败', icon: 'none' });
                 }
               } else {
                 uni.showToast({ title: res.data.msg || '登录失败', icon: 'none' });
               }
             },
             fail: (error) => {
               uni.hideLoading();
               console.error('登录请求失败:', error);
               uni.showToast({ title: '网络错误', icon: 'none' });
             }
           });
         },
         fail: (error) => {
           uni.hideLoading();
           console.error('微信登录失败:', error);
           uni.showToast({ title: '微信登录失败', icon: 'none' });
         }
       });
    },
    
    handleEdit() {
      uni.navigateTo({ url: '/pages/person/editInfo' });
    },
    
    handleStatClick(type) {
      uni.showToast({ title: `点击了${type}`, icon: 'none' });
    },
    
    handleServiceClick(item) {
      if (item.path) {
        uni.navigateTo({ url: item.path });
      } else {
        uni.showToast({ title: '功能开发中', icon: 'none' });
      }
    },
    
    handleGeneralClick(item) {
      if (item.path) {
        uni.navigateTo({ url: item.path });
      } else {
        uni.showToast({ title: '功能开发中', icon: 'none' });
      }
    },
    
    handleLogout() {
      uni.showModal({
        title: '提示',
        content: '确定要退出登录吗？',
        success: (res) => {
          if (res.confirm) {
            uni.clearStorageSync();
            this.checkLoginStatus();
            uni.showToast({ title: '已退出', icon: 'success' });
          }
        }
      });
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.person-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: $background-dim;
}

.person-scroll {
  flex: 1;
  height: 0;
}

.safe-padding {
  padding-left: 40rpx;
  padding-right: 40rpx;
}

.logout-wrapper {
  margin-top: 40rpx;
  margin-bottom: 40rpx;
}

.logout-btn {
  background-color: #ffffff;
  color: #ef4444;
  font-weight: 600;
  border-radius: $radius-full;
  border: 1rpx solid #ef4444;
  
  &::after { border: none; }
  &:active { background-color: #fef2f2; }
}

.version-info {
  display: flex;
  justify-content: center;
  padding-bottom: 40rpx;
  
  text {
    font-size: $font-xs;
    color: $text-tertiary-light;
  }
}

.safe-bottom-spacer {
  height: 120rpx; // TabBar height
  padding-bottom: env(safe-area-inset-bottom);
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .person-container {
    background-color: $background-dark;
  }
  
  .logout-btn {
    background-color: $card-dark;
    border-color: #ef4444;
    color: #ef4444;
    
    &:active { background-color: rgba(239, 68, 68, 0.1); }
  }
}
</style>
