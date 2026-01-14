<template>
  <div class="app-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="mb20">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.totalCount || 0 }}</div>
            <div class="stat-label">举报总数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value" style="color: #e6a23c">{{ stats.pendingCount || 0 }}</div>
            <div class="stat-label">待处理</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value" style="color: #67c23a">{{ stats.handledCount || 0 }}</div>
            <div class="stat-label">已处理</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value" style="color: #909399">{{ stats.ignoredCount || 0 }}</div>
            <div class="stat-label">已忽略</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="处理状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="待处理" :value="0" />
          <el-option label="已处理" :value="1" />
          <el-option label="已忽略" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item label="举报类型" prop="targetType">
        <el-select v-model="queryParams.targetType" placeholder="请选择类型" clearable>
          <el-option label="帖子" :value="0" />
          <el-option label="评论" :value="1" />
          <el-option label="用户" :value="2" />
          <el-option label="商品" :value="3" />
          <el-option label="兼职" :value="4" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-check" size="mini" :disabled="multiple" @click="handleBatchHandle(true)">批量通过</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-close" size="mini" :disabled="multiple" @click="handleBatchHandle(false)">批量忽略</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="reportList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="举报人" align="center" prop="reporterName" />
      <el-table-column label="举报类型" align="center" prop="targetTypeDesc" />
      <el-table-column label="举报原因" align="center" prop="reasonType" />
      <el-table-column label="详细描述" align="center" prop="reasonDetail" :show-overflow-tooltip="true" />
      <el-table-column label="状态" align="center" prop="statusDesc">
        <template slot-scope="scope">
          <el-tag :type="getStatusType(scope.row.status)" size="small">{{ scope.row.statusDesc }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="举报时间" align="center" prop="createTime" width="160" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleView(scope.row)">详情</el-button>
          <el-button size="mini" type="text" icon="el-icon-check" @click="handleReport(scope.row, true)" v-if="scope.row.status === 0">通过</el-button>
          <el-button size="mini" type="text" icon="el-icon-close" @click="handleReport(scope.row, false)" v-if="scope.row.status === 0">忽略</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <!-- 举报详情对话框 -->
    <el-dialog title="举报详情" :visible.sync="viewOpen" width="600px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="举报人">{{ currentReport.reporterName }}</el-descriptions-item>
        <el-descriptions-item label="处理状态">
          <el-tag :type="getStatusType(currentReport.status)" size="small">{{ currentReport.statusDesc }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="举报类型">{{ currentReport.targetTypeDesc }}</el-descriptions-item>
        <el-descriptions-item label="目标ID">{{ currentReport.targetId }}</el-descriptions-item>
        <el-descriptions-item label="举报原因" :span="2">{{ currentReport.reasonType }}</el-descriptions-item>
        <el-descriptions-item label="详细描述" :span="2">{{ currentReport.reasonDetail }}</el-descriptions-item>
        <el-descriptions-item label="举报时间">{{ currentReport.createTime }}</el-descriptions-item>
        <el-descriptions-item label="处理时间">{{ currentReport.handleTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="处理备注" :span="2">{{ currentReport.handleRemark || '-' }}</el-descriptions-item>
      </el-descriptions>
      <div v-if="currentReport.images && currentReport.images.length > 0" style="margin-top: 20px">
        <div style="margin-bottom: 10px; font-weight: bold">举报截图</div>
        <el-image v-for="(img, idx) in currentReport.images" :key="idx"
          style="width: 100px; height: 100px; margin-right: 10px; border-radius: 4px"
          :src="img" :preview-src-list="currentReport.images" fit="cover" />
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button type="success" @click="handleReport(currentReport, true)" v-if="currentReport.status === 0">通过处理</el-button>
        <el-button type="warning" @click="handleReport(currentReport, false)" v-if="currentReport.status === 0">忽略</el-button>
        <el-button @click="viewOpen = false">关 闭</el-button>
      </div>
    </el-dialog>

    <!-- 处理备注对话框 -->
    <el-dialog :title="handleForm.handled ? '处理举报' : '忽略举报'" :visible.sync="handleOpen" width="400px" append-to-body>
      <el-form ref="handleForm" :model="handleForm" label-width="80px">
        <el-form-item label="处理备注">
          <el-input v-model="handleForm.remark" type="textarea" placeholder="请输入处理备注"></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitHandle">确 定</el-button>
        <el-button @click="handleOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listReport, getReport, handleReport, batchHandleReport, delReport, getReportStats } from "@/api/campus/report";

export default {
  name: "Report",
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      reportList: [],
      viewOpen: false,
      handleOpen: false,
      currentReport: {},
      stats: {},
      handleForm: {
        reportId: null,
        handled: false,
        remark: ''
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        status: null,
        targetType: null
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
      listReport(this.queryParams).then(response => {
        this.reportList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    getStats() {
      getReportStats().then(response => {
        this.stats = response;
      });
    },
    getStatusType(status) {
      const typeMap = { 0: 'warning', 1: 'success', 2: 'info' };
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
      this.ids = selection.map(item => item.reportId);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    handleView(row) {
      this.currentReport = row;
      this.viewOpen = true;
    },
    handleReport(row, handled) {
      this.handleForm.reportId = row.reportId;
      this.handleForm.handled = handled;
      this.handleForm.remark = '';
      this.handleOpen = true;
    },
    submitHandle() {
      handleReport(this.handleForm.reportId, this.handleForm.handled, this.handleForm.remark).then(() => {
        this.$modal.msgSuccess(this.handleForm.handled ? "处理成功" : "已忽略");
        this.handleOpen = false;
        this.viewOpen = false;
        this.getList();
        this.getStats();
      });
    },
    handleBatchHandle(handled) {
      if (this.ids.length === 0) {
        this.$modal.msgWarning("请选择要处理的举报");
        return;
      }
      this.$modal.confirm('是否确认' + (handled ? '通过处理' : '忽略') + '选中的举报？').then(() => {
        return batchHandleReport(this.ids, handled, '');
      }).then(() => {
        this.$modal.msgSuccess("操作成功");
        this.getList();
        this.getStats();
      }).catch(() => {});
    },
    handleDelete(row) {
      const reportIds = row.reportId || this.ids;
      this.$modal.confirm('是否确认删除该举报记录？').then(() => {
        return delReport(reportIds);
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
