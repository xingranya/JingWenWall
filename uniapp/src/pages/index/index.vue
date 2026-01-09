<template>
  <view>
    <CustomSwiper :imgList="imgList" :indicator-dots="true" :autoplay="true" :interval="4000" :duration="500"/>
    <uni-notice-bar show-icon scrollable text="CPU Wall 当前还处于开发阶段！" />
    <TopicComponent :records="records" :loadMoreStatus="loadMoreStatus"/>
    <FabComponent />
  </view>
</template>

<script>
import uniNoticeBar from '@dcloudio/uni-ui/lib/uni-notice-bar/uni-notice-bar.vue';
import CustomSwiper from './components/swipper.vue';
import FabComponent from './components/fab.vue';
import TopicComponent from './components/topic.vue';
import View from "@/pages/index/index.vue";
import { getRecords } from "@/api/topic";
import {userLoginService} from "@/api/login";

export default {
  components: {
    View,
    CustomSwiper,
    FabComponent,
    TopicComponent,
    uniNoticeBar
  },
  data() {
    return {
      imgList: [
        { img: '/static/carousel/image1.jpg' },
        { img: '/static/carousel/image2.jpg' },
        { img: '/static/carousel/image3.jpg' },
        { img: '/static/carousel/image4.jpg' },
        { img: '/static/carousel/image5.jpg' },
        { img: '/static/carousel/image6.jpg' }
      ],
      page: 1,
      records: [],
      loadMoreStatus: 'more',
      total: 0,
      shareTopicId: null,
      shareImageUrl: '',
    };
  },
  onLoad() {
    this.init();
  },
  onShow() {
    this.page = 1;
    this.records = [];
    this.loadMoreStatus = 'more';
    this.fetchRecords();
  },
  onReachBottom() {
    console.log("触底")
    if (this.loadMoreStatus === 'more') {
      this.fetchRecords();
    }
  },

  methods: {
    /**
     * 初始化
     */
    async init() {
      // 检查是否已有token
      const existingToken = uni.getStorageSync('token');
      if (existingToken) {
        console.log('已存在token,跳过登录');
        return;
      }
      
      // 生产模式:使用微信登录
      console.log('进行微信登录...');
      uni.login({
        provider: 'weixin',
        success: async (loginRes) => {
          console.log('微信登录成功，获取 code:', loginRes.code);
          const params = {
            code: loginRes.code
          };
          try {
            await userLoginService(params);
            console.log('后端登录成功');
            // 登录成功后，主动调用 fetchRecords 加载话题
            console.log('开始加载话题列表...');
            // 使用setTimeout确保上this上下文正确，并await程序完成
            setTimeout(() => {
              this.fetchRecords();
            }, 100);
          } catch (error) {
            console.error('用户登录失败:', error);
            uni.showToast({
              title: '登录失败,请重试',
              icon: 'none'
            });
          }
        },
        fail: (err) => {
          console.error('微信登录失败:', err);
          uni.navigateTo({
            url: '/pages/transition/agreement'
          });
        }
      });
    },

    /**
     * 获取话题列表
     */
    async fetchRecords() {
      const token = uni.getStorageSync('token');
      if(!token) {
        await uni.navigateTo({
          url: '/pages/transition/agreement'
        });
        return;
      }
      if (this.loadMoreStatus === 'noMore') {
        return;
      }
      this.loadMoreStatus = 'loading';
      try {
        const res = await getRecords(this.page, 10);
        console.log('话题列表响应:', res);
        
        // 检查响应是否有效
        if (!res) {
          console.error('话题列表响应为undefined');
          this.loadMoreStatus = 'more';
          await uni.showToast({title: '加载失败', icon: 'none'});
          return;
        }
        
        // 后端返回的是 { rows: [...], total: 4, ...}
        // 需要从 rows 中提取数据
        const records = res.rows || res.records || [];
        let total = res.total || 0;
        
        // 确保 total 是数字
        if (typeof total === 'string') {
          total = parseInt(total, 10);
        }
        
        console.log('提取的records:', records, '总数:', total);
        
        if (records && Array.isArray(records)) {
          const newRecords = records.filter(record => !record.isDraft);
          if (newRecords.length === 0) {
            if (records.length === 0) {
              this.loadMoreStatus = 'noMore';
            } else {
              this.loadMoreStatus = 'more';
              this.page++;
            }
          } else {
            this.records = this.records.concat(newRecords);
            this.page++;
            if (this.records.length >= total) {
              this.loadMoreStatus = 'noMore';
            } else {
              this.loadMoreStatus = 'more';
            }
          }
        } else {
          console.error('records 不是数组:', records);
          this.loadMoreStatus = 'more';
          await uni.showToast({title: '加载失败', icon: 'none'});
        }
      } catch (err) {
        console.error('话题列表加载失败:', err);
        console.error('错误类型:', typeof err);
        console.error('错误信息:', err.message || err);
        console.error('完整错误:', err);
        this.loadMoreStatus = 'more';
        const errorMsg = err && err.message ? err.message : String(err);
        await uni.showToast({title: '加载失败: ' + errorMsg, icon: 'none'});
      }
    },
  }
};
</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  height: 100%;
  justify-content: space-between;
  background-color: #ffffff;
}

.textarea {
  padding: 10px;
  font-size: 14px;
  border: 1px solid #e5e5e5;
  border-radius: 5px;
  margin: 10px 10px;
  width: calc(100% - 20px);
  box-sizing: border-box;
}

.image-count {
  padding: 0 10px;
  font-size: 14px;
  color: #666;
  margin-bottom: 10px;
}

.image-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  padding: 0 10px;
}

.image-item {
  position: relative;
  width: calc(30% - 10px);
  padding-top: calc(30% - 10px);
  background-color: #f0f0f0;
  border-radius: 5px;
  overflow: hidden;
}

.preview-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.delete-button {
  position: absolute;
  top: 5px;
  right: 5px;
  background-color: rgba(0, 0, 0, 0.7);
  color: #fff;
  border: none;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  text-align: center;
  line-height: 24px;
  font-size: 16px;
  cursor: pointer;
  display: flex;
  justify-content: center;
  align-items: center;
}

.add-button {
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  width: calc(30% - 10px);
  padding-top: calc(30% - 10px);
  background-color: #f5f5f5;
  border-radius: 5px;
  border: 1px dashed #ccc;
}

.add-icon {
  position: absolute;
  font-size: 36px;
  color: #aaa;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.options {
  margin-top: 15px;
  display: flex;
  justify-content: flex-start;
}

.small-button {
  background-color: #f5f5f5;
  color: #333;
  width: auto;
  padding: 5px 10px;
  border-radius: 14px;
  font-size: 10px;
  margin-left: 10px;
  margin-right: 10px;
}

.small-button.selected {
  background-color: #007bff;
  color: #fff;
}

.footer {
  position: fixed;
  bottom: 0;
  width: calc(100% - 30px);
  padding: 10px 15px;
  background-color: #f5f5f5;
  border-top: 1px solid #e5e5e5;
}

.publish-button {
  background-color: #000;
  color: #fff;
  padding: 0 20px;
  border-radius: 30px;
  font-size: 18px;
  width: 90%;
  height: 40px;
  text-align: center;
}
</style>
