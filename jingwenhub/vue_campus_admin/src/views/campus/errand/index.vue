<template>
  <div class="app-container">
    <el-form
      :model="queryParams"
      ref="queryForm"
      size="small"
      :inline="true"
      v-show="showSearch"
      label-width="68px"
    >
      <el-form-item label="订单状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="待接单" :value="0" />
          <el-option label="已接单" :value="1" />
          <el-option label="取件中" :value="2" />
          <el-option label="配送中" :value="3" />
          <el-option label="待确认" :value="4" />
          <el-option label="已完成" :value="5" />
          <el-option label="已取消" :value="6" />
        </el-select>
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

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="center" prop="orderNo" width="180" />
      <el-table-column label="发布者" align="center" prop="publisherName" />
      <el-table-column label="骑手" align="center" prop="runnerName">
        <template slot-scope="scope">
          {{ scope.row.runnerName || '-' }}
        </template>
      </el-table-column>
      <el-table-column label="类型" align="center" prop="typeDesc" />
      <el-table-column label="订单金额" align="center" prop="totalFee">
        <template slot-scope="scope">
          <span style="color: #f56c6c">¥{{ scope.row.totalFee }}</span>
        </template>
      </el-table-column>
      <el-table-column label="支付状态" align="center" prop="payStatusDesc">
        <template slot-scope="scope">
          <el-tag :type="scope.row.payStatus === 1 ? 'success' : 'info'" size="small">
            {{ scope.row.payStatusDesc }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="订单状态" align="center" prop="statusDesc">
        <template slot-scope="scope">
          <el-tag :type="getStatusType(scope.row.status)" size="small">
            {{ scope.row.statusDesc }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleView(scope.row)">详情</el-button>
          <el-button size="mini" type="text" icon="el-icon-close" @click="handleCancel(scope.row)" v-if="scope.row.status < 5">取消</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <!-- 订单详情对话框 -->
    <el-dialog title="订单详情" :visible.sync="viewOpen" width="600px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单号">{{ currentOrder.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">
          <el-tag :type="getStatusType(currentOrder.status)" size="small">{{ currentOrder.statusDesc }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="发布者">{{ currentOrder.publisherName }}</el-descriptions-item>
        <el-descriptions-item label="骑手">{{ currentOrder.runnerName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="订单类型">{{ currentOrder.typeDesc }}</el-descriptions-item>
        <el-descriptions-item label="订单金额">
          <span style="color: #f56c6c; font-weight: bold">¥{{ currentOrder.totalFee }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="取件地址" :span="2">{{ currentOrder.pickupAddr }}</el-descriptions-item>
        <el-descriptions-item label="配送地址" :span="2">{{ currentOrder.deliveryAddr }}</el-descriptions-item>
        <el-descriptions-item label="物品描述" :span="2">{{ currentOrder.goodsDesc }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentOrder.createTime }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ currentOrder.updateTime }}</el-descriptions-item>
        <el-descriptions-item label="取消原因" :span="2" v-if="currentOrder.cancelReason">{{ currentOrder.cancelReason }}</el-descriptions-item>
      </el-descriptions>
      <div slot="footer" class="dialog-footer">
        <el-button @click="viewOpen = false">关 闭</el-button>
      </div>
    </el-dialog>

    <!-- 取消订单对话框 -->
    <el-dialog title="取消订单" :visible.sync="cancelOpen" width="400px" append-to-body>
      <el-form ref="cancelForm" :model="cancelForm" label-width="80px">
        <el-form-item label="取消原因">
          <el-input v-model="cancelForm.reason" type="textarea" placeholder="请输入取消原因"></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitCancel">确 定</el-button>
        <el-button @click="cancelOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listOrder, getOrder, cancelOrder, delOrder } from "@/api/campus/errand";

export default {
  name: "ErrandOrder",
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      orderList: [],
      viewOpen: false,
      cancelOpen: false,
      currentOrder: {},
      cancelForm: {
        orderId: null,
        reason: ''
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        status: null
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    getList() {
      this.loading = true;
      listOrder(this.queryParams).then(response => {
        this.orderList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    getStatusType(status) {
      const typeMap = {
        0: 'warning',
        1: 'primary',
        2: 'primary',
        3: 'primary',
        4: '',
        5: 'success',
        6: 'info'
      };
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
      this.ids = selection.map(item => item.orderId);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    handleView(row) {
      this.currentOrder = row;
      this.viewOpen = true;
    },
    handleCancel(row) {
      this.cancelForm.orderId = row.orderId;
      this.cancelForm.reason = '';
      this.cancelOpen = true;
    },
    submitCancel() {
      cancelOrder(this.cancelForm.orderId, this.cancelForm.reason).then(() => {
        this.$modal.msgSuccess("取消成功");
        this.cancelOpen = false;
        this.getList();
      });
    },
    handleDelete(row) {
      const orderIds = row.orderId || this.ids;
      this.$modal.confirm('是否确认删除订单编号为"' + orderIds + '"的数据项？').then(() => {
        return delOrder(orderIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    }
  }
};
</script>
