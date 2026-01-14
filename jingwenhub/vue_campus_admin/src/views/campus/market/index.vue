<template>
  <div class="app-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.totalCount || 0 }}</div>
            <div class="stat-label">商品总数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value" style="color: #67c23a">{{ stats.onSaleCount || 0 }}</div>
            <div class="stat-label">在售商品</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value" style="color: #909399">{{ stats.soldCount || 0 }}</div>
            <div class="stat-label">已售商品</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value" style="color: #f56c6c">{{ stats.offShelfCount || 0 }}</div>
            <div class="stat-label">已下架</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="商品状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="在售" :value="0" />
          <el-option label="已售" :value="1" />
          <el-option label="下架" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item label="关键词" prop="keyword">
        <el-input v-model="queryParams.keyword" placeholder="标题/描述" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="itemList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="商品图片" align="center" width="100">
        <template slot-scope="scope">
          <el-image v-if="scope.row.images && scope.row.images.length > 0" 
            style="width: 60px; height: 60px; border-radius: 4px" 
            :src="scope.row.images[0]" 
            :preview-src-list="scope.row.images"
            fit="cover" />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="标题" align="center" prop="title" :show-overflow-tooltip="true" />
      <el-table-column label="价格" align="center" prop="price">
        <template slot-scope="scope">
          <span style="color: #f56c6c; font-weight: bold">¥{{ scope.row.price }}</span>
        </template>
      </el-table-column>
      <el-table-column label="成色" align="center" prop="conditionDesc" />
      <el-table-column label="卖家" align="center" prop="nickName" />
      <el-table-column label="浏览" align="center" prop="viewCount" />
      <el-table-column label="收藏" align="center" prop="collectCount" />
      <el-table-column label="状态" align="center" prop="statusDesc">
        <template slot-scope="scope">
          <el-tag :type="getStatusType(scope.row.status)" size="small">{{ scope.row.statusDesc }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发布时间" align="center" prop="createTime" width="160" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleView(scope.row)">详情</el-button>
          <el-button size="mini" type="text" icon="el-icon-bottom" @click="handleOffShelf(scope.row)" v-if="scope.row.status === 0">下架</el-button>
          <el-button size="mini" type="text" icon="el-icon-top" @click="handleOnShelf(scope.row)" v-if="scope.row.status === 2">上架</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <!-- 商品详情对话框 -->
    <el-dialog title="商品详情" :visible.sync="viewOpen" width="700px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="商品标题" :span="2">{{ currentItem.title }}</el-descriptions-item>
        <el-descriptions-item label="商品价格">
          <span style="color: #f56c6c; font-weight: bold">¥{{ currentItem.price }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="原价">
          <span v-if="currentItem.originalPrice">¥{{ currentItem.originalPrice }}</span>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="成色">{{ currentItem.conditionDesc }}</el-descriptions-item>
        <el-descriptions-item label="交易方式">{{ currentItem.tradeMethodDesc }}</el-descriptions-item>
        <el-descriptions-item label="卖家">{{ currentItem.nickName }}</el-descriptions-item>
        <el-descriptions-item label="商品状态">
          <el-tag :type="getStatusType(currentItem.status)" size="small">{{ currentItem.statusDesc }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="商品描述" :span="2">{{ currentItem.description }}</el-descriptions-item>
        <el-descriptions-item label="交易地点" :span="2">{{ currentItem.tradeLocation || '-' }}</el-descriptions-item>
        <el-descriptions-item label="浏览次数">{{ currentItem.viewCount }}</el-descriptions-item>
        <el-descriptions-item label="收藏次数">{{ currentItem.collectCount }}</el-descriptions-item>
        <el-descriptions-item label="发布时间">{{ currentItem.createTime }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ currentItem.updateTime }}</el-descriptions-item>
      </el-descriptions>
      <div v-if="currentItem.images && currentItem.images.length > 0" style="margin-top: 20px">
        <div style="margin-bottom: 10px; font-weight: bold">商品图片</div>
        <el-image v-for="(img, idx) in currentItem.images" :key="idx"
          style="width: 100px; height: 100px; margin-right: 10px; border-radius: 4px"
          :src="img" :preview-src-list="currentItem.images" fit="cover" />
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="viewOpen = false">关 闭</el-button>
      </div>
    </el-dialog>

    <!-- 下架原因对话框 -->
    <el-dialog title="下架商品" :visible.sync="offShelfOpen" width="400px" append-to-body>
      <el-form ref="offShelfForm" :model="offShelfForm" label-width="80px">
        <el-form-item label="下架原因">
          <el-input v-model="offShelfForm.reason" type="textarea" placeholder="请输入下架原因"></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitOffShelf">确 定</el-button>
        <el-button @click="offShelfOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listMarketItem, getMarketItem, offShelfItem, onShelfItem, delMarketItem, getMarketStats } from "@/api/campus/market";

export default {
  name: "MarketItem",
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      itemList: [],
      viewOpen: false,
      offShelfOpen: false,
      currentItem: {},
      stats: {},
      offShelfForm: {
        itemId: null,
        reason: ''
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        status: null,
        keyword: null
      }
    };
  },
  created() {
    this.getList();
    this.getStats();
  },
  methods: {
    getList() {
      this.loading = true;
      listMarketItem(this.queryParams).then(response => {
        this.itemList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    getStats() {
      getMarketStats().then(response => {
        this.stats = response;
      });
    },
    getStatusType(status) {
      const typeMap = { 0: 'success', 1: 'info', 2: 'danger' };
      return typeMap[status] || '';
    },
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.itemId);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    handleView(row) {
      this.currentItem = row;
      this.viewOpen = true;
    },
    handleOffShelf(row) {
      this.offShelfForm.itemId = row.itemId;
      this.offShelfForm.reason = '';
      this.offShelfOpen = true;
    },
    submitOffShelf() {
      offShelfItem(this.offShelfForm.itemId, this.offShelfForm.reason).then(() => {
        this.$modal.msgSuccess("下架成功");
        this.offShelfOpen = false;
        this.getList();
        this.getStats();
      });
    },
    handleOnShelf(row) {
      this.$modal.confirm('是否确认上架该商品？').then(() => {
        return onShelfItem(row.itemId);
      }).then(() => {
        this.$modal.msgSuccess("上架成功");
        this.getList();
        this.getStats();
      }).catch(() => {});
    },
    handleDelete(row) {
      const itemIds = row.itemId || this.ids;
      this.$modal.confirm('是否确认删除该商品？').then(() => {
        return delMarketItem(itemIds);
      }).then(() => {
        this.getList();
        this.getStats();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    }
  }
};
</script>

<style scoped>
.mb20 {
  margin-bottom: 20px;
}
.stat-item {
  text-align: center;
}
.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #409eff;
}
.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 5px;
}
</style>
