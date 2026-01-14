# JingWenWall (荆文校园枢纽)

<p align="center">
  <img src="https://note.oddfar.com/img/web.png" width="180" alt="Logo">
</p>

<p align="center">
  基于 SpringBoot + Vue + UniApp 的现代化校园综合信息服务平台
</p>

---

## 1. 项目概述

**JingWenWall** (荆文校园枢纽) 是一个专为高校打造的综合性信息服务平台。它旨在连接校园内的每一个角落，为学生提供便捷的信息交流、生活服务和社交互动渠道。

### 核心功能
*   **信息墙**：表白墙、吐槽墙、万能墙，支持匿名发布，满足学生多样化的表达需求。
*   **二手市场**：校园闲置物品交易，支持分类检索、收藏和即时联系。
*   **跑腿服务**：代取快递、代买零食等校园互助服务，实时订单追踪。
*   **校园论坛**：话题讨论、动态分享，构建活跃的校园社区。
*   **综合管理**：强大的后台管理系统，支持内容审核、用户管理、数据统计等。

### 适用场景
*   高校校园社区建设
*   校园创业项目
*   学生社团信息发布平台

### 技术栈概览

| 领域 | 技术框架 | 说明 |
| :--- | :--- | :--- |
| **后端** | Spring Boot 2.5 | 核心业务框架 |
| | MyBatis-Plus 3.5 | ORM 持久层框架 |
| | Redis 6.0+ | 缓存与会话管理 |
| | MySQL 8.0+ | 关系型数据库 |
| | Spring Security | 安全认证与授权 |
| **管理后台 (PC)** | Vue 2.x | 前端核心框架 |
| | Element UI | 桌面端 UI 组件库 |
| **移动端 (小程序)** | UniApp (Vue 3) | 跨平台开发框架 |
| | Vite | 新一代前端构建工具 |
| | Pinia | 状态管理库 |
| | Element Plus | 移动端/Vue3 UI 支持 |

---

## 2. 安装指南

### 环境要求
*   **操作系统**：Windows / macOS / Linux
*   **JDK**：Java 8 (JDK 1.8)
*   **数据库**：MySQL 8.0+
*   **缓存**：Redis 3.0+
*   **Node.js**：建议 v16+ (用于编译 Vue3 移动端项目)
*   **开发工具**：IntelliJ IDEA (后端), VS Code (前端), HBuilderX (移动端推荐), 微信开发者工具

### 安装步骤

#### 1. 克隆项目
```bash
git clone https://github.com/your-repo/JingWenWall.git
cd JingWenWall
```

#### 2. 数据库初始化
1.  创建数据库 `jingwen_campus`，字符集选择 `utf8mb4`。
2.  导入 SQL 脚本：位于 `jingwenhub/sql/jingwen_campus.sql`。

#### 3. 后端配置
1.  打开 `jingwenhub` 目录。
2.  修改配置文件 `jingwenhub/campus-modular/src/main/resources/application.yml` (或 `application-dev.yml`)：
    *   更新 `spring.datasource` 下的 MySQL 地址、账号和密码。
    *   更新 `spring.redis` 下的 Redis 地址和密码。
    *   (可选) 配置微信小程序 `wechat.mini` 的 `appId` 和 `appSecret`。

---

## 3. 使用说明

### 启动后端服务
1.  使用 IDEA 打开 `jingwenhub` 目录。
2.  等待 Maven 依赖下载完成。
3.  运行 `campus-modular` 模块下的 `com.oddfar.campus.CampusApplication` 启动类。
4.  服务默认启动在端口 **8001**。

### 启动管理后台 (PC)
```bash
cd jingwenhub/vue_campus_admin
npm install --registry=https://registry.npmmirror.com
npm run dev
```
*   访问地址：`http://localhost:80` (默认)

### 启动移动端 (微信小程序)
**方式一：命令行启动**
```bash
cd uniapp
npm install --registry=https://registry.npmmirror.com
npm run dev:mp-weixin
```
*   运行后，打开微信开发者工具，导入 `uniapp/dist/dev/mp-weixin` 目录。

**方式二：HBuilderX 启动 (推荐)**
1.  下载并安装 [HBuilderX](https://www.dcloud.io/hbuilderx.html)。
2.  文件 -> 打开目录 -> 选择 `uniapp` 文件夹。
3.  菜单栏 -> 运行 -> 运行到小程序模拟器 -> 微信开发者工具。

---

## 4. 开发指南

### 项目结构
```text
JingWenWall/
├── jingwenhub/               # 后端与管理后台主目录
│   ├── campus-admin/         # 管理后台接口模块
│   ├── campus-common/        # 通用工具与实体模块
│   ├── campus-framework/     # 核心框架配置模块
│   ├── campus-modular/       # 业务功能模块 (启动入口)
│   ├── sql/                  # 数据库脚本
│   └── vue_campus_admin/     # 管理后台前端源码 (Vue 2)
├── uniapp/                   # 移动端源码 (UniApp + Vue 3)
└── README.md                 # 项目说明文档
```

### 代码贡献
1.  Fork 本仓库。
2.  新建 Feat_xxx 分支。
3.  提交代码。
4.  新建 Pull Request。

### 测试
*   后端测试：在 `src/test/java` 下编写 JUnit 测试用例。
*   接口调试：项目集成了 Swagger，启动后访问 `http://localhost:8001/swagger-ui/index.html` (具体路径视配置而定)。

---

## 5. 其他信息

### 许可证
本项目采用 [MIT License](LICENSE) 许可证。

### 联系方式
*   如有问题，请提交 Issue 或联系项目维护者。

### 致谢
*   感谢 [RuoYi-Vue](https://gitee.com/y_project/RuoYi-Vue) 提供优秀的后台管理框架基础。
*   感谢 [Campus](https://github.com/oddfar/campus) 开源项目提供的业务逻辑参考。
