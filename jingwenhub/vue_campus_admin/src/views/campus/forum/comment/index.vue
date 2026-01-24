<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="帖子ID" prop="postId">
        <el-input
          v-model="queryParams.postId"
          placeholder="请输入帖子ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="用户ID" prop="userId">
        <el-input
          v-model="queryParams.userId"
          placeholder="请输入用户ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="内容" prop="content">
        <el-input
          v-model="queryParams.content"
          placeholder="请输入评论内容"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="正常" :value="0" />
          <el-option label="禁用" :value="1" />
        </el-select>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['campus:forum:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="commentList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="commentId" width="180" />
      <el-table-column label="帖子ID" align="center" prop="postId" width="180" />
      <el-table-column label="评论用户" align="center" prop="nickName" />
      <el-table-column label="回复用户" align="center" prop="toUserNickName">
        <template slot-scope="scope">
          <span>{{ scope.row.toUserNickName || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="内容" align="center" prop="content" :show-overflow-tooltip="true" />
      <el-table-column label="点赞数" align="center" prop="likeCount" width="100" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === 0 ? 'success' : 'danger'">
            {{ scope.row.status === 0 ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160"/>

      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['campus:forum:remove']"
          >删除</el-button>
          <el-button
            size="mini"
            type="text"
            :icon="scope.row.status === 0 ? 'el-icon-close' : 'el-icon-check'"
            @click="handleAudit(scope.row)"
            v-hasPermi="['campus:forum:edit']"
          >{{ scope.row.status === 0 ? '禁用' : '启用' }}</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />
  </div>
</template>

<script>
import { listComment, delComment, auditComment } from "@/api/campus/forum";

export default {
  name: "ForumComment",
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 评论表格数据
      commentList: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        postId: null,
        userId: null,
        status: null,
        content: null
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询评论列表 */
    getList() {
      this.loading = true;
      listComment(this.queryParams).then(response => {
        this.commentList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.commentId)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const commentIds = row.commentId || this.ids;
      this.$modal.confirm('是否确认删除评论编号为"' + commentIds + '"的数据项？').then(function() {
        return delComment(commentIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 审核/状态修改操作 */
    handleAudit(row) {
      const status = row.status === 0 ? 1 : 0;
      const text = row.status === 0 ? "禁用" : "启用";
      this.$modal.confirm('确认要' + text + '该评论吗？').then(function() {
        return auditComment(row.commentId, status);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess(text + "成功");
      }).catch(() => {});
    }
  }
};
</script>
