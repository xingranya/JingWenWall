<template>
	<view class="publish-container">
		<scroll-view scroll-y class="content-area">
			<!-- 标题输入 -->
			<view class="form-item">
				<textarea 
					class="title-input"
					v-model="formData.title"
					placeholder="请输入标题..."
					maxlength="100"
					:show-count="true"
				></textarea>
			</view>

			<!-- 内容输入 -->
			<view class="form-item">
				<textarea 
					class="content-input"
					v-model="formData.content"
					placeholder="分享你的想法..."
					maxlength="5000"
					:show-count="true"
					auto-height
				></textarea>
			</view>

			<!-- 图片上传 -->
			<view class="image-section">
				<view class="image-list">
					<view 
						v-for="(img, index) in formData.images" 
						:key="index"
						class="image-item"
					>
						<image :src="img" mode="aspectFill"></image>
						<view class="delete-btn" @click="deleteImage(index)">
							<text class="iconfont icon-close"></text>
						</view>
					</view>
					
					<view 
						v-if="formData.images.length < 9" 
						class="add-image"
						@click="chooseImage"
					>
						<text class="iconfont icon-add"></text>
						<text class="tip">添加图片</text>
					</view>
				</view>
			</view>

			<!-- 分类选择 -->
			<view class="form-item">
				<view class="label">选择分类</view>
				<picker 
					mode="selector" 
					:range="categories" 
					range-key="name"
					@change="onCategoryChange"
				>
					<view class="picker">
						{{ selectedCategory ? selectedCategory.name : '请选择分类' }}
					</view>
				</picker>
			</view>

			<!-- 匿名发帖 -->
			<view class="form-item">
				<view class="label">匿名发帖</view>
				<switch 
					:checked="formData.isAnonymous === 1" 
					@change="onAnonymousChange"
					color="#007aff"
				/>
			</view>
		</scroll-view>

		<!-- 底部操作栏 -->
		<view class="bottom-bar">
			<button class="draft-btn" @click="saveDraft">保存草稿</button>
			<button class="publish-btn" type="primary" @click="publish">发布</button>
		</view>
	</view>
</template>

<script>
import { publishPost, savePostDraft, getPostDraft } from '@/api/forum';
import { uploadSingleFile } from '@/api/topic';

export default {
	data() {
		return {
			formData: {
				title: '',
				content: '',
				images: [],
				categoryId: null,
				isAnonymous: 0
			},
			categories: [
				{ id: 1, name: '校园生活' },
				{ id: 2, name: '学习交流' },
				{ id: 3, name: '社团活动' },
				{ id: 4, name: '美食分享' },
				{ id: 5, name: '二手市场' },
				{ id: 6, name: '其他' }
			],
			selectedCategory: null,
			uploadingImage: false
		};
	},
	onLoad() {
		this.loadDraft();
	},
	methods: {
		// 加载草稿
		async loadDraft() {
			try {
				const draft = await getPostDraft();
				if (draft) {
					this.formData = {
						title: draft.title || '',
						content: draft.content || '',
						images: draft.images || [],
						categoryId: draft.categoryId || null,
						isAnonymous: draft.isAnonymous || 0
					};
					
					if (draft.categoryId) {
						this.selectedCategory = this.categories.find(c => c.id === draft.categoryId);
					}
					
					uni.showToast({
						title: '已加载草稿',
						icon: 'none'
					});
				}
			} catch (err) {
				console.log('没有草稿');
			}
		},
		
		// 选择图片
		chooseImage() {
			if (this.uploadingImage) {
				uni.showToast({
					title: '正在上传中...',
					icon: 'none'
				});
				return;
			}
			
			uni.chooseImage({
				count: 9 - this.formData.images.length,
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
			uni.showLoading({
				title: '上传中...'
			});
			
			try {
				for (const filePath of filePaths) {
					const url = await uploadSingleFile(filePath);
					this.formData.images.push(url);
				}
			} catch (err) {
				uni.showToast({
					title: err.message || '上传失败',
					icon: 'none'
				});
			} finally {
				this.uploadingImage = false;
				uni.hideLoading();
			}
		},
		
		// 删除图片
		deleteImage(index) {
			uni.showModal({
				title: '提示',
				content: '确定删除这张图片吗？',
				success: (res) => {
					if (res.confirm) {
						this.formData.images.splice(index, 1);
					}
				}
			});
		},
		
		// 分类选择
		onCategoryChange(e) {
			const index = e.detail.value;
			this.selectedCategory = this.categories[index];
			this.formData.categoryId = this.selectedCategory.id;
		},
		
		// 匿名切换
		onAnonymousChange(e) {
			this.formData.isAnonymous = e.detail.value ? 1 : 0;
		},
		
		// 保存草稿
		async saveDraft() {
			if (!this.formData.title && !this.formData.content) {
				uni.showToast({
					title: '请输入内容',
					icon: 'none'
				});
				return;
			}
			
			try {
				await savePostDraft(this.formData);
				uni.showToast({
					title: '草稿已保存',
					icon: 'success'
				});
			} catch (err) {
				uni.showToast({
					title: err.message || '保存失败',
					icon: 'none'
				});
			}
		},
		
		// 发布
		async publish() {
			// 验证
			if (!this.formData.title.trim()) {
				uni.showToast({
					title: '请输入标题',
					icon: 'none'
				});
				return;
			}
			
			if (!this.formData.content.trim()) {
				uni.showToast({
					title: '请输入内容',
					icon: 'none'
				});
				return;
			}
			
			if (!this.formData.categoryId) {
				uni.showToast({
					title: '请选择分类',
					icon: 'none'
				});
				return;
			}
			
			uni.showLoading({
				title: '发布中...'
			});
			
			try {
				await publishPost(this.formData);
				
				uni.showToast({
					title: '发布成功',
					icon: 'success'
				});
				
				setTimeout(() => {
					uni.navigateBack();
				}, 1500);
			} catch (err) {
				uni.showToast({
					title: err.message || '发布失败',
					icon: 'none'
				});
			} finally {
				uni.hideLoading();
			}
		}
	}
};
</script>

<style scoped>
.publish-container {
	display: flex;
	flex-direction: column;
	height: 100vh;
	background-color: #f5f5f5;
}

.content-area {
	flex: 1;
	padding: 24rpx;
	padding-bottom: 120rpx;
}

.form-item {
	background-color: #fff;
	border-radius: 16rpx;
	padding: 24rpx;
	margin-bottom: 20rpx;
}

.title-input {
	width: 100%;
	font-size: 32rpx;
	font-weight: bold;
	min-height: 80rpx;
}

.content-input {
	width: 100%;
	font-size: 28rpx;
	min-height: 300rpx;
	line-height: 1.8;
}

.image-section {
	background-color: #fff;
	border-radius: 16rpx;
	padding: 24rpx;
	margin-bottom: 20rpx;
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
}

.image-item image {
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
	width: 48rpx;
	height: 48rpx;
	background-color: rgba(0, 0, 0, 0.6);
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
}

.delete-btn .iconfont {
	color: #fff;
	font-size: 24rpx;
}

.add-image {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	background-color: #f5f5f5;
	border-radius: 12rpx;
	aspect-ratio: 1;
}

.add-image .iconfont {
	font-size: 48rpx;
	color: #999;
	margin-bottom: 8rpx;
}

.add-image .tip {
	font-size: 24rpx;
	color: #999;
}

.label {
	font-size: 28rpx;
	color: #333;
	margin-bottom: 16rpx;
}

.picker {
	font-size: 28rpx;
	color: #666;
	padding: 16rpx;
	background-color: #f5f5f5;
	border-radius: 8rpx;
}

.bottom-bar {
	position: fixed;
	bottom: 0;
	left: 0;
	right: 0;
	background-color: #fff;
	padding: 16rpx 24rpx;
	border-top: 1rpx solid #f0f0f0;
	display: flex;
	gap: 20rpx;
}

.draft-btn {
	flex: 1;
	border: 1rpx solid #007aff;
	color: #007aff;
	background-color: #fff;
}

.publish-btn {
	flex: 2;
}
</style>
