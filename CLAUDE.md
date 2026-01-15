# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

JingWenWall(荆文校园枢纽)是一个基于 Spring Boot + Vue2(管理后台) + uni-app(微信小程序)的校园综合信息服务平台，包含论坛/信息墙、二手市场、跑腿服务、举报治理等核心功能。

## 项目结构

```
JingWenWall/
├── jingwenhub/                    # 后端 + 管理后台
│   ├── campus-common/             # 通用模块：工具类、常量、统一返回体、异常处理
│   ├── campus-framework/          # 框架层：安全配置、拦截器、配置读取、文件操作、邮件服务
│   ├── campus-admin/              # 管理后台接口：用户/角色/菜单/字典/参数配置等系统模块
│   ├── campus-modular/            # 业务模块
│   │   ├── business/              # 核心业务
│   │   │   ├── forum/             # 论坛/信息墙模块
│   │   │   ├── market/            # 二手市场模块
│   │   │   ├── errand/            # 跑腿服务模块
│   │   │   ├── report/            # 举报治理模块
│   │   │   └── controller/        # 业务控制器
│   │   └── resources/
│   │       └── application.yml    # 后端主配置文件
│   ├── sql/                       # 数据库脚本
│   └── vue_campus_admin/          # PC管理后台前端(Vue2 + Element UI)
├── uniapp/                        # 微信小程序端(uni-app + Vue3)
│   ├── src/
│   │   ├── pages/                 # 小程序页面
│   │   ├── components/            # 公共组件
│   │   └── utils/
│   │       ├── env.js             # 环境配置(后端地址)
│   │       └── request.js         # 网络请求封装
│   └── package.json
└── README.md
```

## 常用命令

### 后端 (Spring Boot)
```bash
# 进入后端目录
cd jingwenhub

# 构建项目(跳过测试)
mvn clean package -DskipTests

# 运行测试
mvn test

# 启动后端服务 (主类: CampusApplication.java)
# 默认监听: http://localhost:8001
# Swagger UI: http://localhost:8001/swagger-ui/index.html
```

### 管理后台 (Vue2)
```bash
# 进入管理后台目录
cd jingwenhub/vue_campus_admin

# 安装依赖
npm install

# 启动开发服务器 (默认 http://localhost:80)
npm run dev

# 构建生产环境
npm run build:prod

# 代码检查
npm run lint
```

### 小程序 (uni-app)
```bash
# 进入小程序目录
cd uniapp

# 安装依赖 (推荐使用 pnpm)
pnpm install
# 或 npm install

# 启动微信小程序开发模式
pnpm dev:mp-weixin

# 构建微信小程序生产版本
pnpm build:mp-weixin

# 用微信开发者工具导入目录: uniapp/dist/dev/mp-weixin
```

## 核心架构

### 后端架构

1. **模块分层**
   - `campus-common`: 通用工具、注解、常量、异常、统一返回体 `R<T>`
   - `campus-framework`: 框架配置(Spring Security、JWT、文件操作、邮件、系统配置)
   - `campus-admin`: 管理后台控制器(用户、角色、菜单、字典、配置等)
   - `campus-modular`: 业务模块(论坛、市场、跑腿、举报)

2. **认证与鉴权**
   - Spring Security + JWT
   - 请求头: `Authorization: Bearer <token>`
   - 匿名接口通过 `@Anonymous` 注解标记
   - 配置文件: `campus-framework/src/main/java/com/oddfar/campus/framework/config/SecurityConfig.java`

3. **业务模块设计**
   - 每个业务模块包含: controller、service、mapper、domain(entity/dto/vo)、enums
   - API路径规范:
     - 小程序端: `/api/v1/{模块}/{资源}`
     - 管理后台: `/admin/{模块}/{资源}`
     - 认证相关: `/api/v1/wx/auth/*`

4. **配置管理**
   - 基础配置: `application.yml`
   - 动态配置: 数据库表 `sys_config`，通过 `ConfigExpander` 读取并缓存到 Redis
   - 关键配置:
     - `sys.local.profile.*`: 文件存储路径(按操作系统区分)
     - `sys.user.default.avatar`: 默认头像
     - `campus.wxmp.appid/secret`: 微信小程序配置

5. **文件上传**
   - 上传接口: `POST /campus/imageUpload`
   - 删除接口: `POST /campus/file/delete`
   - 静态资源访问前缀: `/profile`
   - 存储路径根据 `sys.local.profile.*` 配置自动选择

### 前端架构

1. **管理后台 (Vue2)**
   - 技术栈: Vue 2.6 + Element UI + Vuex + Vue Router
   - 代理配置: `/dev-api` -> `http://localhost:8001`
   - 环境变量: `.env.development`、`.env.production`
   - 组件位置: `src/views/`、`src/components/`

2. **小程序 (uni-app + Vue3)**
   - 技术栈: Vue 3 + Vite + Pinia
   - 环境配置: `src/utils/env.js` (DEV_BASE_URL、PROD_BASE_URL)
   - 网络请求: `src/utils/request.js` (基于 axios)
   - 页面结构: `src/pages/{模块}/index.vue`
   - 真机调试必须使用局域网 IP，不能用 `localhost`

## 开发注意事项

### 后端开发

1. **统一返回体**
   ```java
   R<T> // 单个对象
   R<PageResult<T>> // 分页数据
   // 管理后台分页常用
   R.success(rows, total) // 实际返回 TableDataInfo
   ```

2. **权限控制**
   - 使用 `@PreAuthorize("@ss.hasPermi('system:user:list')")` 控制权限
   - 匿名访问使用 `@Anonymous` 注解

3. **参数配置读取**
   ```java
   // 方式1: 通过 ConfigExpander
   String value = ConfigExpander.getValByKey("sys.local.profile.win");

   // 方式2: 通过 SysConfigService
   @Autowired
   private SysConfigService configService;
   String value = configService.selectConfigByKey("configKey");
   ```

4. **微信小程序登录**
   - 接口: `POST /api/v1/wx/auth/login`
   - 配置: `application.yml` 中的 `wechat.mini.appId/appSecret`

### 前端开发

1. **管理后台**
   - 遵循 RuoYi-Vue 风格的代码结构
   - 使用 `src/api/` 目录管理 API 请求
   - 遵循 Element UI 组件规范

2. **小程序开发**
   - 修改后端地址: 编辑 `src/utils/env.js` 中的 `DEV_BASE_URL`
   - 真机调试必须使用电脑局域网 IP
   - 使用 Pinia 进行状态管理
   - 遵循 uni-app 官方文档规范

### 常见问题

1. **管理后台启动报 OpenSSL 错误**
   - 项目已内置 `NODE_OPTIONS=--openssl-legacy-provider`
   - 建议使用 Node.js 14/16

2. **小程序请求后端失败**
   - 真机调试: 使用局域网 IP (如 `http://192.168.x.x:8001`)
   - 微信开发者工具: 开启"不校验合法域名"
   - 检查 `src/utils/env.js` 中的 `baseUrl`

3. **文件上传后访问404**
   - 检查 `sys.local.profile.*` 配置的路径是否正确
   - 确保静态资源映射前缀为 `/profile`
   - 验证文件系统权限

4. **Swagger 访问不到**
   - 确认 `application.yml` 中 `swagger.enabled=true`
   - 访问 `http://localhost:8001/swagger-ui/index.html`

## 数据库

- 数据库名: `jingwen_campus`
- 字符集: `utf8mb4`
- 初始化脚本: `jingwenhub/sql/jingwen_campus.sql`
- 核心表:
  - `sys_*`: 系统管理相关(用户、角色、菜单、字典、配置等)
  - `bus_forum_post`: 论坛帖子
  - `bus_forum_comment`: 论坛评论
  - `bus_market_item`: 二手市场商品
  - `bus_errand_order`: 跑腿订单
  - `bus_errand_runner`: 跑腿骑手
  - `bus_report`: 举报记录

## 关键文件位置

- 后端启动类: `jingwenhub/campus-modular/src/main/java/com/oddfar/campus/CampusApplication.java`
- 后端配置: `jingwenhub/campus-modular/src/main/resources/application.yml`
- 安全配置: `jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/config/SecurityConfig.java`
- 管理后台配置: `jingwenhub/vue_campus_admin/vue.config.js`
- 小程序环境配置: `uniapp/src/utils/env.js`
- 小程序请求封装: `uniapp/src/utils/request.js`
