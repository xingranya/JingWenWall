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
      <el-form-item label="用户ID" prop="userId">
        <el-input
          v-model="queryParams.userId"
          placeholder="请输入用户ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="分类" prop="categoryId">
        <treeselect
          v-model="queryParams.categoryId"
          :options="categoryOptions"
          :normalizer="normalizer"
          :show-count="true"
          placeholder="选择分类"
          style="width: 150px"
        />
      </el-form-item>
      <el-form-item label="标题" prop="title">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入标题关键词"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select
          v-model="queryParams.status"
          placeholder="请选择状态"
          clearable
          style="width: 120px"
        >
          <el-option label="正常" :value="0" />
          <el-option label="禁用" :value="1" />
        </el-select>
      </el-form-item>

      <el-form-item>
        <el-button
          type="primary"
          icon="el-icon-search"
          size="mini"
          @click="handleQuery"
          >搜索</el-button
        >
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery"
          >重置</el-button
        >
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
          >删除</el-button
        >
      </el-col>
      <right-toolbar
        :showSearch.sync="showSearch"
        @queryTable="getList"
      ></right-toolbar>
    </el-row>

    <el-table
      v-loading="loading"
      :data="postList"
      @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="postId" width="180" />
      <el-table-column label="用户" align="center" prop="nickName" :show-overflow-tooltip="true">
        <template slot-scope="scope">
          <span>{{ scope.row.nickName }}</span>
          <span v-if="scope.row.isAnonymous == 1" style="color: #909399; margin-left: 5px;">(匿名)</span>
        </template>
      </el-table-column>
      <el-table-column label="分类" align="center" prop="categoryName" />
      <el-table-column
        label="标题"
        align="center"
        prop="title"
        :show-overflow-tooltip="true"
      />
      <el-table-column label="数据统计" align="center" width="200">
        <template slot-scope="scope">
          <el-tag size="mini" type="info" title="浏览"><i class="el-icon-view"></i> {{ scope.row.viewCount || 0 }}</el-tag>
          <el-tag size="mini" type="success" title="点赞"><i class="el-icon-thumb"></i> {{ scope.row.likeCount || 0 }}</el-tag>
          <el-tag size="mini" type="warning" title="评论"><i class="el-icon-chat-dot-round"></i> {{ scope.row.commentCount || 0 }}</el-tag>
          <el-tag size="mini" title="收藏"><i class="el-icon-star-off"></i> {{ scope.row.collectCount || 0 }}</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === 0 ? 'success' : 'danger'">
            {{ scope.row.status === 0 ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>

      <el-table-column label="创建时间" align="center" prop="createTime" width="160" />

      <el-table-column
        label="操作"
        align="center"
        class-name="small-padding fixed-width"
        width="180"
      >
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleView(scope.row)"
            >详情</el-button
          >
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['campus:forum:edit']"
            >编辑</el-button
          >
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['campus:forum:remove']"
            >删除</el-button
          >
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 修改帖子对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" label-width="80px">
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="0">正常</el-radio>
            <el-radio :label="1">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="浏览量">
          <el-input-number v-model="form.viewCount" :min="0" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!-- 帖子详情 -->
    <el-dialog
      title="帖子详情"
      :visible.sync="viewOpen"
      width="700px"
      append-to-body
    >
      <el-form ref="viewForm" :model="form" label-width="100px" size="mini">
        <el-row>
          <el-col :span="12">
            <el-form-item label="用户昵称：">{{ form.nickName }}</el-form-item>
            <el-form-item label="分类：">{{ form.categoryName }}</el-form-item>
          </el-col>
          <el-col :span="12">
             <el-form-item label="发布时间：">{{ form.createTime }}</el-form-item>
             <el-form-item label="状态：">
               <el-tag size="mini" :type="form.status === 0 ? 'success' : 'danger'">
                 {{ form.status === 0 ? '正常' : '禁用' }}
               </el-tag>
             </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="标题：">{{ form.title || '无标题' }}</el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="内容：" style="white-space: pre-wrap">{{ form.content }}</el-form-item>
          </el-col>
          <el-col :span="24" v-if="form.images && form.images.length > 0">
            <el-form-item label="图片：">
              <div class="picture_item" v-for="(item, index) in form.images" :key="index">
                <image-preview :src="item" style="border-radius: 5px; width: 100px; height: 100px; margin-right: 10px;" />
              </div>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="viewOpen = false">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listPost, getPost, delPost, updatePost } from "@/api/campus/forum";
import { listSelectCategory } from "@/api/campus/category";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";
import Treeselect from "@riophae/vue-treeselect";

export default {
  name: "ForumPost",
  components: { Treeselect },
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
      // 帖子表格数据
      postList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 是否显示详情弹出层
      viewOpen: false,
      // 分类选项
      categoryOptions: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userId: null,
        categoryId: null,
        title: null,
        status: null,
      },
      // 表单参数
      form: {},
    };
  },
  created() {
    this.getList();
    this.getCategoryTree();
  },
  methods: {
    /** 查询帖子列表 */
    getList() {
      this.loading = true;
      listPost(this.queryParams).then((response) => {
        this.postList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 查询分类树 */
    getCategoryTree() {
      listSelectCategory().then((response) => {
        this.categoryOptions = this.handleTree(response.data, "categoryId");
      });
    },
    /** 转换菜单数据结构 */
    normalizer(node) {
      if (node.children && !node.children.length) {
        delete node.children;
      }
      return {
        id: node.categoryId,
        label: node.categoryName,
        children: node.children,
      };
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        postId: null,
        status: 0,
        viewCount: 0
      };
      this.resetForm("form");
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
      this.ids = selection.map((item) => item.postId);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const postId = row.postId || this.ids;
      getPost(postId).then((response) => {
        this.form = response.data;
        this.open = true;
        this.title = "修改帖子";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          if (this.form.postId != null) {
            updatePost(this.form).then((response) => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 详情按钮操作 */
    handleView(row) {
      this.viewOpen = true;
      this.form = row;
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const postIds = row.postId || this.ids;
      this.$modal
        .confirm('是否确认删除帖子编号为"' + postIds + '"的数据项？')
        .then(function () {
          return delPost(postIds);
        })
        .then(() => {
          this.getList();
          this.$modal.msgSuccess("删除成功");
        })
        .catch(() => {});
    },
  },
};
</script>

<style scoped>
.picture_item {
  display: inline-block;
  vertical-align: top;
}
</style>
