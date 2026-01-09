<template>
	<view class="detail-container">
		<scroll-view scroll-y class="content-area" v-if="post">
			<!-- 帖子内容 -->
			<view class="post-detail">
				<!-- 用户信息 -->
				<view class="post-header">
					<image 
						class="avatar" 
						:src="post.avatar || '/static/default_avatar.jpg'" 
						mode="aspectFill"
					></image>
					<view class="user-info">
						<text class="nickname">{{ post.nickName || '匿名用户' }}</text>
						<text class="time">{{ formatTime(post.createTime) }}</text>
					</view>
				</view>

				<!-- 标题 -->
				<view class="title">{{ post.title }}</view>

				<!-- 内容 -->
				<view class="content">{{ post.content }}</view>

				<!-- 图片 -->
				<view v-if="post.images && post.images.length > 0" class="images">
					<image 
						v-for="(img, idx) in post.images" 
						:key="idx"
						:src="img" 
						mode="aspectFill"
						class="post-image"
						@click="previewImage(post.images, idx)"
					></image>
				</view>

				<!-- 统计信息 -->
				<view class="stats">
					<text class="stat-item">浏览 {{ post.viewCount }}</text>
					<text class="stat-item">点赞 {{ post.likeCount }}</text>
					<text class="stat-item">评论 {{ post.commentCount }}</text>
					<text class="stat-item">收藏 {{ post.collectCount }}</text>
				</view>
			</view>

			<!-- 评论列表 -->
			<view class="comment-section">
				<view class="section-title">全部评论 ({{ post.commentCount }})</view>
				
				<view v-if="commentList.length > 0">
					<view 
						v-for="comment in commentList" 
						:key="comment.commentId"
						class="comment-item"
					>
						<image 
							class="avatar" 
							:src="comment.avatar || '/static/default_avatar.jpg'" 
							mode="aspectFill"
						></image>
						<view class="comment-content">
							<view class="comment-header">
								<text class="nickname">{{ comment.nickName }}</text>
								<text class="time">{{ formatTime(comment.createTime) }}</text>
							</view>
							<text class="text">{{ comment.content }}</text>
							
							<!-- 二级评论 -->
							<view 
								v-if="comment.children && comment.children.length > 0" 
								class="reply-list"
							>
								<view 
									v-for="reply in comment.children" 
									:key="reply.commentId"
									class="reply-item"
								>
									<text class="reply-user">{{ reply.nickName }}</text>
									<text v-if="reply.toUserNickName"> 回复 {{ reply.toUserNickName }}</text>
									<text>: {{ reply.content }}</text>
								</view>
							</view>

							<view class="comment-actions">
								<text @click="replyComment(comment)">回复</text>
							</view>
						</view>
					</view>
				</view>

				<view v-else class="empty-comment">
					<text>暂无评论，快来发表第一条评论吧~</text>
				</view>
			</view>
		</scroll-view>

		<!-- 底部操作栏 -->
		<view class="bottom-bar">
			<input 
				class="comment-input" 
				placeholder="说点什么..." 
				v-model="commentText"
				@focus="onInputFocus"
			/>
			<view class="action-buttons">
				<view class="action-btn" @click="toggleLike">
					<text class="iconfont" :class="post.isLiked ? 'icon-liked' : 'icon-like'"></text>
					<text>{{ post.isLiked ? '已赞' : '点赞' }}</text>
				</view>
				<view class="action-btn" @click="toggleCollect">
					<text class="iconfont" :class="post.isCollected ? 'icon-collected' : 'icon-collect'"></text>
					<text>{{ post.isCollected ? '已藏' : '收藏' }}</text>
				</view>
			</view>
		</view>

		<!-- 评论输入弹窗 -->
		<view v-if="showCommentDialog" class="comment-dialog">
			<view class="dialog-mask" @click="closeCommentDialog"></view>
			<view class="dialog-content">
				<textarea 
					class="comment-textarea"
					v-model="commentText"
					:placeholder="replyTo ? `回复 ${replyTo.nickName}` : '发表评论...'"
					:focus="true"
					auto-height
				></textarea>
				<view class="dialog-actions">
					<button @click="closeCommentDialog">取消</button>
					<button type="primary" @click="submitComment">发送</button>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
import { 
	getPostDetail, 
	likePost, 
	unlikePost, 
	collectPost, 
	uncollectPost,
	getPostComments,
	publishComment 
} from '@/api/forum';

export default {
	data() {
		return {
			postId: null,
			post: null,
			commentList: [],
			commentText: '',
			showCommentDialog: false,
			replyTo: null
		};
	},
	onLoad(options) {
		this.postId = options.postId;
		if (this.postId) {
			this.loadDetail();
			this.loadComments();
		}
	},
	methods: {
		// 加载帖子详情
		async loadDetail() {
			try {
				this.post = await getPostDetail(this.postId);
			} catch (err) {
				uni.showToast({
					title: err.message || '加载失败',
					icon: 'none'
				});
			}
		},
		
		// 加载评论列表
		async loadComments() {
			try {
				const res = await getPostComments(this.postId, 1, 100);
				this.commentList = res.rows || [];
			} catch (err) {
				console.error('加载评论失败:', err);
			}
		},
		
		// 点赞/取消点赞
		async toggleLike() {
			try {
				if (this.post.isLiked) {
					await unlikePost(this.postId);
					this.post.likeCount--;
				} else {
					await likePost(this.postId);
					this.post.likeCount++;
				}
				this.post.isLiked = !this.post.isLiked;
			} catch (err) {
				uni.showToast({
					title: err.message || '操作失败',
					icon: 'none'
				});
			}
		},
		
		// 收藏/取消收藏
		async toggleCollect() {
			try {
				if (this.post.isCollected) {
					await uncollectPost(this.postId);
					this.post.collectCount--;
				} else {
					await collectPost(this.postId);
					this.post.collectCount++;
				}
				this.post.isCollected = !this.post.isCollected;
			} catch (err) {
				uni.showToast({
					title: err.message || '操作失败',
					icon: 'none'
				});
			}
		},
		
		// 输入框获得焦点
		onInputFocus() {
			this.showCommentDialog = true;
		},
		
		// 回复评论
		replyComment(comment) {
			this.replyTo = comment;
			this.showCommentDialog = true;
		},
		
		// 关闭评论弹窗
		closeCommentDialog() {
			this.showCommentDialog = false;
			this.replyTo = null;
			this.commentText = '';
		},
		
		// 提交评论
		async submitComment() {
			if (!this.commentText.trim()) {
				uni.showToast({
					title: '请输入评论内容',
					icon: 'none'
				});
				return;
			}
			
			try {
				const data = {
					postId: this.postId,
					content: this.commentText,
					parentId: this.replyTo ? this.replyTo.commentId : 0,
					toUserId: this.replyTo ? this.replyTo.userId : null
				};
				
				await publishComment(data);
				
				uni.showToast({
					title: '评论成功',
					icon: 'success'
				});
				
				this.closeCommentDialog();
				this.loadComments();
				this.loadDetail();
			} catch (err) {
				uni.showToast({
					title: err.message || '评论失败',
					icon: 'none'
				});
			}
		},
		
		// 预览图片
		previewImage(images, current) {
			uni.previewImage({
				urls: images,
				current: current
			});
		},
		
		// 格式化时间
		formatTime(time) {
			if (!time) return '';
			const date = new Date(time);
			return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
		}
	}
};
</script>

<style scoped>
.detail-container {
	display: flex;
	flex-direction: column;
	height: 100vh;
	background-color: #f5f5f5;
}

.content-area {
	flex: 1;
	padding-bottom: 120rpx;
}

.post-detail {
	background-color: #fff;
	padding: 24rpx;
	margin-bottom: 20rpx;
}

.post-header {
	display: flex;
	align-items: center;
	margin-bottom: 24rpx;
}

.avatar {
	width: 72rpx;
	height: 72rpx;
	border-radius: 50%;
	margin-right: 20rpx;
}

.user-info {
	display: flex;
	flex-direction: column;
}

.nickname {
	font-size: 28rpx;
	color: #333;
	font-weight: 500;
}

.time {
	font-size: 24rpx;
	color: #999;
	margin-top: 8rpx;
}

.title {
	font-size: 36rpx;
	font-weight: bold;
	color: #333;
	margin-bottom: 24rpx;
	line-height: 1.6;
}

.content {
	font-size: 28rpx;
	color: #666;
	line-height: 1.8;
	margin-bottom: 24rpx;
}

.images {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 16rpx;
	margin-bottom: 24rpx;
}

.post-image {
	width: 100%;
	height: 200rpx;
	border-radius: 12rpx;
}

.stats {
	padding-top: 24rpx;
	border-top: 1rpx solid #f0f0f0;
	font-size: 24rpx;
	color: #999;
}

.stat-item {
	margin-right: 40rpx;
}

.comment-section {
	background-color: #fff;
	padding: 24rpx;
}

.section-title {
	font-size: 30rpx;
	font-weight: bold;
	color: #333;
	margin-bottom: 24rpx;
}

.comment-item {
	display: flex;
	margin-bottom: 32rpx;
}

.comment-content {
	flex: 1;
	margin-left: 20rpx;
}

.comment-header {
	display: flex;
	justify-content: space-between;
	margin-bottom: 12rpx;
}

.text {
	font-size: 28rpx;
	color: #333;
	line-height: 1.6;
}

.reply-list {
	background-color: #f5f5f5;
	padding: 16rpx;
	border-radius: 8rpx;
	margin-top: 16rpx;
}

.reply-item {
	font-size: 26rpx;
	color: #666;
	line-height: 1.6;
	margin-bottom: 12rpx;
}

.reply-item:last-child {
	margin-bottom: 0;
}

.reply-user {
	color: #007aff;
}

.comment-actions {
	margin-top: 16rpx;
	font-size: 24rpx;
	color: #999;
}

.empty-comment {
	text-align: center;
	padding: 80rpx 0;
	color: #999;
	font-size: 28rpx;
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
	align-items: center;
	gap: 20rpx;
}

.comment-input {
	flex: 1;
	background-color: #f5f5f5;
	padding: 16rpx 24rpx;
	border-radius: 48rpx;
	font-size: 28rpx;
}

.action-buttons {
	display: flex;
	gap: 32rpx;
}

.action-btn {
	display: flex;
	flex-direction: column;
	align-items: center;
	font-size: 20rpx;
	color: #666;
}

.action-btn .iconfont {
	font-size: 40rpx;
	margin-bottom: 4rpx;
}

.icon-liked,
.icon-collected {
	color: #ff4d4f;
}

.comment-dialog {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	z-index: 999;
}

.dialog-mask {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.5);
}

.dialog-content {
	position: absolute;
	bottom: 0;
	left: 0;
	right: 0;
	background-color: #fff;
	padding: 24rpx;
	border-radius: 24rpx 24rpx 0 0;
}

.comment-textarea {
	width: 100%;
	min-height: 200rpx;
	padding: 16rpx;
	background-color: #f5f5f5;
	border-radius: 12rpx;
	font-size: 28rpx;
	margin-bottom: 24rpx;
}

.dialog-actions {
	display: flex;
	gap: 20rpx;
}

.dialog-actions button {
	flex: 1;
}
</style>
