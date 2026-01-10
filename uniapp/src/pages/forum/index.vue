<template>
	<view class="forum-container">
		<!-- 顶部tab切换 -->
		<view class="tab-bar">
			<view 
				v-for="(tab, index) in tabs" 
				:key="index"
				class="tab-item"
				:class="{ active: currentTab === index }"
				@click="switchTab(index)"
			>
				{{ tab.name }}
			</view>
		</view>

		<!-- 帖子列表 -->
		<scroll-view 
			scroll-y 
			class="post-list"
			@scrolltolower="loadMore"
			:refresher-enabled="true"
			:refresher-triggered="refreshing"
			@refresherrefresh="onRefresh"
		>
			<view v-if="postList.length > 0">
				<view 
					v-for="post in postList" 
					:key="post.postId"
					class="post-item"
					@click="goToDetail(post.postId)"
				>
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

					<!-- 帖子内容 -->
					<view class="post-content">
						<text class="title">{{ post.title }}</text>
						<text class="content">{{ post.content }}</text>
						
						<!-- 图片展示 -->
						<view v-if="post.images && post.images.length > 0" class="images">
							<image 
								v-for="(img, idx) in post.images.slice(0, 3)" 
								:key="idx"
								:src="img" 
								mode="aspectFill"
								class="post-image"
								@click.stop="previewImage(post.images, idx)"
							></image>
						</view>
					</view>

					<!-- 帖子统计 -->
					<view class="post-stats">
						<view class="stat-item">
							<text class="iconfont icon-view"></text>
							<text>{{ post.viewCount }}</text>
						</view>
						<view class="stat-item">
							<text class="iconfont" :class="post.isLiked ? 'icon-liked' : 'icon-like'"></text>
							<text>{{ post.likeCount }}</text>
						</view>
						<view class="stat-item">
							<text class="iconfont icon-comment"></text>
							<text>{{ post.commentCount }}</text>
						</view>
						<view class="stat-item">
							<text class="iconfont" :class="post.isCollected ? 'icon-collected' : 'icon-collect'"></text>
							<text>{{ post.collectCount }}</text>
						</view>
					</view>
				</view>
			</view>

			<!-- 空状态 -->
			<view v-else-if="!loading" class="empty-state">
				<text>暂无帖子</text>
			</view>

			<!-- 加载提示 -->
			<view class="loading-tip" v-if="loading">
				<text>加载中...</text>
			</view>
			<view class="loading-tip" v-if="!hasMore && postList.length > 0">
				<text>没有更多了</text>
			</view>
		</scroll-view>

		<!-- 发布按钮 -->
		<view class="fab-button" @click="goToPublish">
			<text class="iconfont icon-add"></text>
		</view>
	</view>
</template>

<script>
import { getNewestPosts, getHotPosts } from '@/api/forum';

export default {
	data() {
		return {
			tabs: [
				{ name: '最新', type: 'newest' },
				{ name: '热门', type: 'hot' }
			],
			currentTab: 0,
			postList: [],
			pageNum: 1,
			pageSize: 10,
			hasMore: true,
			loading: false,
			refreshing: false
		};
	},
	onLoad() {
		this.loadPosts();
	},
	methods: {
		// 切换tab
		switchTab(index) {
			if (this.currentTab === index) return;
			this.currentTab = index;
			this.resetList();
			this.loadPosts();
		},
		
		// 加载帖子
		async loadPosts() {
			if (this.loading || !this.hasMore) return;
			
			this.loading = true;
			try {
				const apiMethod = this.tabs[this.currentTab].type === 'newest' 
					? getNewestPosts 
					: getHotPosts;
				
				const res = await apiMethod(this.pageNum, this.pageSize);
				
				if (res.rows && res.rows.length > 0) {
					this.postList = this.postList.concat(res.rows);
					this.hasMore = res.rows.length >= this.pageSize;
				} else {
					this.hasMore = false;
				}
			} catch (err) {
				uni.showToast({
					title: err.message || '加载失败',
					icon: 'none'
				});
			} finally {
				this.loading = false;
				this.refreshing = false;
			}
		},
		
		// 下拉刷新
		onRefresh() {
			this.refreshing = true;
			this.resetList();
			this.loadPosts();
		},
		
		// 加载更多
		loadMore() {
			if (!this.hasMore || this.loading) return;
			this.pageNum++;
			this.loadPosts();
		},
		
		// 重置列表
		resetList() {
			this.postList = [];
			this.pageNum = 1;
			this.hasMore = true;
		},
		
		// 跳转到详情
		goToDetail(postId) {
			uni.navigateTo({
				url: `/pages/forum/detail?postId=${postId}`
			});
		},
		
		// 跳转到发布
		goToPublish() {
			uni.navigateTo({
				url: '/pages/forum/publish'
			});
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
			// iOS 兼容性处理：将 YYYY-MM-DD 替换为 YYYY/MM/DD
			const safeTime = typeof time === 'string' ? time.replace(/-/g, '/') : time;
			const date = new Date(safeTime);
			const now = new Date();
			const diff = now - date;
			
			if (diff < 60000) return '刚刚';
			if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前';
			if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前';
			if (diff < 604800000) return Math.floor(diff / 86400000) + '天前';
			
			return `${date.getMonth() + 1}-${date.getDate()}`;
		}
	}
};
</script>

<style scoped>
.forum-container {
	display: flex;
	flex-direction: column;
	height: 100vh;
	background-color: #f5f5f5;
}

.tab-bar {
	display: flex;
	background-color: #fff;
	padding: 20rpx 0;
	box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.05);
}

.tab-item {
	flex: 1;
	text-align: center;
	font-size: 30rpx;
	color: #666;
	padding: 20rpx 0;
	position: relative;
}

.tab-item.active {
	color: #007aff;
	font-weight: bold;
}

.tab-item.active::after {
	content: '';
	position: absolute;
	bottom: 0;
	left: 50%;
	transform: translateX(-50%);
	width: 60rpx;
	height: 4rpx;
	background-color: #007aff;
	border-radius: 2rpx;
}

.post-list {
	flex: 1;
	padding: 20rpx;
}

.post-item {
	background-color: #fff;
	border-radius: 16rpx;
	padding: 24rpx;
	margin-bottom: 20rpx;
}

.post-header {
	display: flex;
	align-items: center;
	margin-bottom: 20rpx;
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

.post-content {
	margin-bottom: 20rpx;
}

.title {
	display: block;
	font-size: 32rpx;
	font-weight: bold;
	color: #333;
	margin-bottom: 16rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
}

.content {
	display: block;
	font-size: 28rpx;
	color: #666;
	line-height: 1.6;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 3;
	-webkit-box-orient: vertical;
}

.images {
	display: flex;
	gap: 16rpx;
	margin-top: 20rpx;
}

.post-image {
	width: 200rpx;
	height: 200rpx;
	border-radius: 12rpx;
}

.post-stats {
	display: flex;
	align-items: center;
	padding-top: 20rpx;
	border-top: 1rpx solid #f0f0f0;
}

.stat-item {
	display: flex;
	align-items: center;
	margin-right: 40rpx;
	font-size: 24rpx;
	color: #999;
}

.stat-item .iconfont {
	font-size: 32rpx;
	margin-right: 8rpx;
}

.icon-liked,
.icon-collected {
	color: #ff4d4f;
}

.empty-state {
	text-align: center;
	padding: 200rpx 0;
	color: #999;
	font-size: 28rpx;
}

.loading-tip {
	text-align: center;
	padding: 40rpx 0;
	color: #999;
	font-size: 24rpx;
}

.fab-button {
	position: fixed;
	right: 40rpx;
	bottom: 120rpx;
	width: 100rpx;
	height: 100rpx;
	background-color: #007aff;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 4rpx 12rpx rgba(0,122,255,0.3);
}

.fab-button .iconfont {
	color: #fff;
	font-size: 48rpx;
}
</style>
