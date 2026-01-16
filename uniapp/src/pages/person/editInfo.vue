<template>
  <view class="containar">
    <view class="avatarUrl">
      <button type="balanced" open-type="chooseAvatar" @chooseavatar="onChooseAvatar">
        <image :src="avatarUrl" class="refreshIcon"></image>
      </button>
    </view>
    <view class="formItem">
      <text class="label">昵称：</text>
      <input type="nickname" class="weui-input" :value="nickName" @blur="bindblur" placeholder="请输入昵称"
             @input="bindinput"/>
    </view>
    <view class="formItem">
      <text class="label">性别：</text>
      <radio-group @change="onSexChange">
        <label class="radio-item">
          <radio value="Male" :checked="selectedSex === 'Male'">男性</radio>
        </label>
        <label class="radio-item">
          <radio value="Female" :checked="selectedSex === 'Female'">女性</radio>
        </label>
      </radio-group>
    </view>
    <view class="formItem">
      <text class="label">学生号：</text>
      <input type="number" class="webui-input" :value="studentid" placeholder="请输入学生号"
             @input="bindStudentIdInput"/>
    </view>
    <view class="btn">
      <view class="btn-sub" @click="onSubmit">保存</view>
    </view>
  </view>
</template>

<script>
import { getCurrentUserInfo, updateUserInfo, uploadAvatar } from "@/api/user";

export default {
  components: {
  },
  data() {
    return {
      avatarUrl: '',
      originalAvatarUrl: '',
      nickName: '',
      studentid: '',
      selectedSex: 'Male',
      sexValueMap: {
        'Male': 1,
        'Female': 2,
      },
    };
  },

  /**
   * 生命周期函数--监听页面加载
   */
  async onLoad() {
    try {
      const data = await getCurrentUserInfo();
      this.nickName = data.username;
      this.avatarUrl = data.avatar;
      this.originalAvatarUrl = data.avatar;
      this.studentid = data.studentid;
      this.selectedSex = data.sex === "1" ? 'Male' : 'Female';
    } catch (error) {
      console.error('获取用户信息失败:', error);
      uni.showToast({
        title: '获取用户信息失败',
        icon: 'none'
      });
    }
  },
  /**
   * 页面的方法
   */
  methods: {
    bindblur(e) {
      this.nickName = e.detail.value;
    },
    bindinput(e) {
      this.nickName = e.detail.value;
    },
    bindStudentIdInput(e) {
      this.studentid = e.detail.value;
    },
    onChooseAvatar(e) {
      this.avatarUrl = e.detail.avatarUrl;

    },
    onSexChange(e) {
      this.selectedSex = e.detail.value;
    },

    /**
     * 提交表单
     */
    async onSubmit() {
      if (this.nickName === '') {
        uni.showToast({
          icon: 'none',
          title: '请输入昵称'
        });
        return;
      }

      try {
        let avatarUrl = this.originalAvatarUrl;

        // 如果头像有变化，先上传新头像
        if (this.avatarUrl !== this.originalAvatarUrl) {
          const uploadRes = await uploadAvatar(this.avatarUrl);
          if (uploadRes.data && uploadRes.data[0]) {
            avatarUrl = uploadRes.data[0];
          }
        }

        // 更新用户信息
        await updateUserInfo({
          username: this.nickName,
          avatar: avatarUrl,
          sex: this.sexValueMap[this.selectedSex],
          studentid: this.studentid
        });

        uni.showToast({
          title: '更新成功',
          icon: 'success',
          duration: 1000,
          complete: () => {
            setTimeout(() => {
              uni.reLaunch({
                url: '/pages/person/person'
              });
            }, 1000);
          }
        });
      } catch (error) {
        console.error('更新用户信息失败:', error);
        uni.showToast({
          title: '更新失败',
          icon: 'none',
          duration: 2000
        });
      }
    }
  }
};
</script>

<style lang="scss">
.containar {
  .avatarUrl {
    padding: 80rpx 0 40rpx;
    background: #fff;

    button {
      background: #fff;
      line-height: 80rpx;
      height: auto;
      width: auto;
      padding: 20rpx 30rpx;
      margin: 0;
      display: flex;
      justify-content: center;
      align-items: center;

      .refreshIcon {
        width: 160rpx;
        height: 160rpx;
        border-radius: 50%;
      }
    }
  }

  .formItem {
    background: #fff;
    padding: 20rpx 30rpx;
    display: flex;
    align-items: center;
    margin-bottom: 20rpx; // 添加底部间距

    .label {
      width: 140rpx; // 设置标签宽度以确保对齐
      text-align: left; // 标签文本左对齐
    }

    .weui-input {
      flex: 1; // 输入框占用剩余空间
      margin-left: 20rpx; // 标签和输入框之间的间距
    }

    .radio-item {
      margin-right: 30rpx; // 单选框之间的间距
    }
  }

  .btn {
    width: 100%;

    .btn-sub {
      width: 670rpx;
      margin: 80rpx auto 0;
      height: 90rpx;
      background: #4a90e2;
      border-radius: 45rpx;
      line-height: 90rpx;
      text-align: center;
      font-size: 36rpx;
      color: #fff;
    }
  }
}
</style>
