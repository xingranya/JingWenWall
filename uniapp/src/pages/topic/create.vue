<template>
  <view class="container">
    <view class="content-wrapper">
      <!-- 文本输入区域 -->
      <view class="input-area">
        <input 
          class="title-input" 
          placeholder="填写标题会有更多人看哦~" 
          placeholder-style="font-weight: bold; color: #999;" 
          v-model="title"
          maxlength="30"
        />
        <view class="divider-line"></view>
        <textarea 
          class="post-textarea" 
          placeholder="分享你的新鲜事..." 
          placeholder-style="color: #999;"
          v-model="content" 
          maxlength="2000"
          :auto-height="true"
        ></textarea>
      </view>

      <!-- 图片上传区域 -->
      <view class="media-area">
        <view class="image-grid">
          <view class="image-item" v-for="(img, index) in imgUrls" :key="index">
            <image :src="img" mode="aspectFill" class="preview-image" @click="previewImage(index)"></image>
            <view class="delete-btn" @click.stop="deleteImage(index)">
              <uni-icons type="closeempty" size="12" color="#fff"></uni-icons>
            </view>
          </view>
          
          <view class="image-item add-btn" v-if="imgUrls.length < 9" @click="chooseImages">
            <uni-icons type="plusempty" size="30" color="#ccc"></uni-icons>
          </view>
        </view>
        <view class="image-counter" v-if="imgUrls.length > 0">
          <text>{{ imgUrls.length }}/9</text>
        </view>
      </view>

      <!-- 选项栏 -->
      <view class="options-bar">
        <view class="option-item" hover-class="option-hover" @click="chooseTopic">
          <uni-icons type="tag" size="18" color="#666"></uni-icons>
          <text class="option-text">{{ selectedTopicName || '选择话题' }}</text>
          <uni-icons type="right" size="14" color="#ccc" class="arrow-right"></uni-icons>
        </view>
        
        <view class="divider"></view>
        
        <view class="option-item" @click="toggleAnonymous">
          <view class="left">
            <uni-icons type="eye-slash" size="18" color="#666"></uni-icons>
            <text class="option-text">匿名发布</text>
          </view>
          <switch :checked="isAnonymous" color="#000" style="transform:scale(0.7)" @change="toggleAnonymous" @click.stop />
        </view>
      </view>
    </view>

    <!-- 底部操作栏 -->
    <view class="bottom-bar">
      <view class="draft-tip">
        <text v-if="isDraft">已保存草稿</text>
        <text v-else></text>
      </view>
      <button 
        class="submit-btn" 
        :class="{ 'btn-disabled': !canSubmit }"
        @click="onSubmit"
        :disabled="!canSubmit"
      >
        发布
      </button>
    </view>
  </view>
</template>

<script>
import { toRaw } from 'vue';
import {
  uploadSingleFile,
  deleteSingleFile,
  uploadTopic,
  getDraft,
  saveDraft,
  checkDraftExistence,
} from '@/api/topic';
import { baseUrl } from '@/utils/env';
import uniSection from '@dcloudio/uni-ui/lib/uni-section/uni-section.vue';
import View from '@/pages/topic/create.vue';

export default {
  components: {
    View,
    uniSection
  },
  data() {
    return {
      id: null,
      title: '',
      content: '',
      categoryId: 1001, // 默认: 校园生活
      imgUrls: [],
      submitted: false,
      isDraft: 0,
      isAnonymous: false,
      topics: [
        { id: 1001, name: '校园生活' },
        { id: 1002, name: '学习交流' },
        { id: 1003, name: '失物招领' },
        { id: 1004, name: '二手交易' },
        { id: 1005, name: '社团活动' },
        { id: 1006, name: '其他' }
      ],
      selectedTopicName: ''
    };
  },
  mounted() {
    this.checkDraft();
  },
  beforeUnmount() {
    this.saveDraft();
  },
  methods: {

    /**
     * 检查是否存在草稿，并直接加载草稿内容
     */
    checkDraft() {
      checkDraftExistence()
          .then(response => {
            if (response) {
              this.loadDraft();
            }
          })
          .catch(error => {
            console.error('检查草稿失败:', error);
          });
    },

    /**
     * 加载草稿
     */
    loadDraft() {
      getDraft()
          .then(response => {
            const draft = response;
            console.log('加载草稿:', draft);
            if (draft) {
              this.id = draft.id || null;
              this.title = draft.title || '';
              this.content = draft.content || '';
              this.categoryId = draft.categoryId || 1001;
              this.imgUrls = draft.imgURLs || [];
              this.isDraft = true;
            }
          })
          .catch(error => {
            console.error('加载草稿失败:', error);
          });
    },

    /**
     * 保存草稿
     */
    saveDraft() {
      if (this.submitted) {
        return;
      }
      if (this.content.trim() !== '' || this.imgUrls.length > 0) {
        console.log('保存草稿:', this.id);
        const draftData = {
          id: this.id,
          title: this.title,
          content: this.content,
          categoryId: this.categoryId,
          imgURLs: toRaw(this.imgUrls),
          isDraft: 1
        };
        saveDraft(draftData);
      }
    },

    /**
     * 提交帖子
     */
    onSubmit() {
      if (this.content.trim() === '') {
        uni.showToast({
          icon: 'none',
          title: '请输入话题内容',
          duration: 2000
        });
        return;
      }
      this.uploadTopic();
      console.log('提交帖子:', this.content, toRaw(this.imgUrls));
    },

    /**
     * 上传帖子
     */
    uploadTopic() {
      const data = {
        title: this.title,
        content: this.content,
        categoryId: this.categoryId,
        imgURLs: toRaw(this.imgUrls),
        isDraft: 0
      };

      uploadTopic(data)
          .then(() => {
            this.submitted = true;
            uni.showToast({
              title: '发布成功',
              icon: 'success',
              duration: 2000,
              complete: () => {
                setTimeout(() => {
                  uni.reLaunch({
                    url: '/pages/index/index'
                  });
                }, 1000);
              }
            });
          })
          .catch((err) => {
            console.error('发布失败:', err);
            uni.showToast({
              title: err,
              icon: 'none',
              duration: 2000
            });
          });
    },

    /**
     * 选择图片
     */
    chooseImages() {
      const maxSelect = 9 - this.imgUrls.length;
      if (maxSelect <= 0) {
        uni.showToast({
          title: '最多只能上传9张图片',
          icon: 'none',
          duration: 2000
        });
        return;
      }

      uni.chooseImage({
        count: maxSelect,
        sizeType: ['original', 'compressed'],
        sourceType: ['album', 'camera'],
        success: res => {
          const tempFiles = res.tempFilePaths;
          this.uploadToServer(tempFiles);
        },
        fail: err => {
          console.error('选择图片失败:', err);
        }
      });
    },

    /**
     * 上传图片到服务器
     */
    uploadToServer(filePaths) {
      const uploadPromises = filePaths.map(filePath => uploadSingleFile(filePath));
      Promise.all(uploadPromises)
          .then(results => {
             // results contain objects with url, fileId etc. We only need the url for display
            const urls = results.map(res => {
              let url = res.url;
              if (url && !url.startsWith('http') && !url.startsWith('wxfile')) {
                url = baseUrl + url;
              }
              return url;
            });
            this.imgUrls.push(...urls);
            console.log('所有图片上传成功:', this.imgUrls);
            uni.showToast({
              title: '上传成功',
              icon: 'success',
              duration: 2000
            });
          })
          .catch(error => {
            console.error('图片上传失败:', error);
            uni.showToast({
              title: '上传失败,请分开上传或重新选择图片',
              icon: 'none',
              duration: 2000
            });
          });
    },

    /**
     * 删除图片
     */
    deleteImage(index) {
      const urlToDelete = this.imgUrls[index];
      deleteSingleFile(urlToDelete)
          .then(() => {
            this.imgUrls.splice(index, 1);
            console.log('图片删除成功，当前图片列表:', this.imgUrls);
          })
          .catch(error => {
            console.error('删除文件失败:', error);
            uni.showToast({
              title: '删除失败',
              icon: 'none',
              duration: 2000
            });
          });
    },

    /**
     * 预览图片
     */
    previewImage(index) {
      uni.previewImage({
        current: this.imgUrls[index],
        urls: this.imgUrls
      });
    },
    previewImage(index) {
      uni.previewImage({
        current: this.imgUrls[index],
        urls: this.imgUrls
      });
    },
    toggleAnonymous(e) {
      // 如果通过点击 switch 触发
      if (e && e.detail && typeof e.detail.value !== 'undefined') {
        this.isAnonymous = e.detail.value;
      } else {
        // 点击整行触发
        this.isAnonymous = !this.isAnonymous;
      }
    },
    chooseTopic() {
      const itemList = this.topics.map(t => t.name);
      uni.showActionSheet({
        itemList: itemList,
        success: (res) => {
          const index = res.tapIndex;
          const topic = this.topics[index];
          this.categoryId = topic.id;
          this.selectedTopicName = topic.name;
        }
      });
    }
  },
  computed: {
    canSubmit() {
      return (this.title.trim().length > 0 || this.content.trim().length > 0) || this.imgUrls.length > 0;
    }
  }
};
</script>

<style scoped>
.container {
  min-height: 100vh;
  background-color: #fff;
  display: flex;
  flex-direction: column;
}

.content-wrapper {
  flex: 1;
  padding: 20rpx 30rpx;
  padding-bottom: 120rpx; /* Space for bottom bar */
}

.input-area {
  margin-bottom: 30rpx;
}

.post-textarea {
  width: 100%;
  min-height: 200rpx;
  font-size: 30rpx;
  line-height: 1.5;
  color: #333;
}

.media-area {
  margin-bottom: 40rpx;
}

.image-grid {
  display: flex;
  flex-wrap: wrap;
  margin: 0 -10rpx;
}

.image-item {
  width: calc(33.33% - 20rpx);
  height: 0;
  padding-bottom: calc(33.33% - 20rpx);
  margin: 10rpx;
  position: relative;
  border-radius: 12rpx;
  overflow: hidden;
}

.title-input {
  width: 100%;
  height: 80rpx;
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 20rpx;
}

.divider-line {
  height: 1rpx;
  background-color: #f5f5f5;
  margin-bottom: 20rpx;
}

.preview-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.delete-btn {
  position: absolute;
  top: 8rpx;
  right: 8rpx;
  background-color: rgba(0, 0, 0, 0.5);
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10;
}

.add-btn {
  background-color: #f7f7f7;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* Fix for icons inside absolute centered container */
.add-btn uni-icons {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.image-counter {
  text-align: right;
  font-size: 24rpx;
  color: #999;
  margin-top: 10rpx;
  margin-right: 10rpx;
}

.options-bar {
  margin-top: 20rpx;
  border-top: 1rpx solid #f5f5f5;
  border-bottom: 1rpx solid #f5f5f5;
}

.option-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx 0;
}

.option-item .left {
  display: flex;
  align-items: center;
}

.option-hover {
  opacity: 0.7;
}

.option-text {
  font-size: 28rpx;
  color: #333;
  margin-left: 20rpx;
}

.arrow-right {
  margin-left: auto;
}

.divider {
  height: 1rpx;
  background-color: #f5f5f5;
  margin-left: 50rpx; 
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + constant(safe-area-inset-bottom));
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background-color: #fff;
  box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.05);
  z-index: 100;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.draft-tip {
  font-size: 24rpx;
  color: #999;
  margin-right: auto;
}

.submit-btn {
  background-color: #000;
  color: #fff;
  font-size: 28rpx;
  border-radius: 40rpx;
  padding: 0 60rpx;
  height: 72rpx;
  line-height: 72rpx;
  margin: 0;
  border: none;
}

.submit-btn::after {
  border: none;
}

.btn-disabled {
  background-color: #ccc;
  color: #fff;
}
</style>
