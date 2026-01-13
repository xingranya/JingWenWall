<!--
  个人资料头部组件
  包含头像、昵称、身份标签和编辑按钮
  参考 user_profile_settings 模板样式
-->
<template>
  <view class="profile-header safe-padding">
    <view class="user-info-row">
      <view class="avatar-group" @click="handleAvatarClick">
        <image 
          class="avatar-xl" 
          :src="userInfo.avatar || '/static/default_avatar.jpg'" 
          mode="aspectFill"
        />
        <view v-if="isLoggedIn" class="verified-badge">
          <uni-icons type="checkmarkempty" size="12" color="#ffffff" />
        </view>
      </view>
      
      <view class="user-details" v-if="isLoggedIn">
        <view class="name-row">
          <text class="user-name">{{ userInfo.nickName }}</text>
        </view>
        <text class="user-identity">{{ userInfo.deptName || '未认证用户' }}</text>
      </view>
      
      <view class="user-details" v-else @click="handleLogin">
        <text class="user-name">点击登录</text>
        <text class="user-identity">登录后体验更多功能</text>
      </view>
    </view>
    
    <view class="edit-btn" v-if="isLoggedIn" @click="handleEdit">
      <uni-icons type="gear" size="18" color="#64748b" />
      <text class="edit-text">编辑资料</text>
    </view>
  </view>
</template>

<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue';

export default {
  name: 'ProfileHeader',
  components: {
    uniIcons
  },
  props: {
    userInfo: {
      type: Object,
      default: () => ({})
    },
    isLoggedIn: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    handleEdit() {
      this.$emit('edit');
    },
    handleLogin() {
      this.$emit('login');
    },
    handleAvatarClick() {
      if(!this.isLoggedIn) {
        this.$emit('login');
      }
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/static/css/theme.scss';

.profile-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 40rpx;
  padding-bottom: 40rpx;
}

.safe-padding {
  padding-left: 40rpx;
  padding-right: 40rpx;
}

.user-info-row {
  display: flex;
  align-items: center;
  gap: 32rpx;
}

.avatar-group {
  position: relative;
}

.verified-badge {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  background-color: $primary;
  border: 4rpx solid $background-dim;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.name-row {
  display: flex;
  align-items: center;
}

.user-name {
  font-size: 40rpx;
  font-weight: 800;
  color: $text-primary-light;
}

.user-identity {
  font-size: $font-sm;
  color: $text-secondary-light;
}

.edit-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 24rpx;
  background-color: $surface-light;
  border-radius: $radius-full;
  border: 1rpx solid $border-light;
  transition: all 0.2s ease;
  
  &:active {
    background-color: darken($surface-light, 5%);
  }
}

.edit-text {
  font-size: $font-sm;
  font-weight: 600;
  color: $text-secondary-light;
}

// 深色模式
@media (prefers-color-scheme: dark) {
  .verified-badge {
    border-color: $background-dark;
  }
  
  .user-name {
    color: $text-primary-dark;
  }
  
  .user-identity {
    color: $text-secondary-dark;
  }
  
  .edit-btn {
    background-color: $card-dark;
    border-color: rgba(255, 255, 255, 0.1);
  }
  
  .edit-text {
    color: $text-secondary-dark;
  }
}
</style>
