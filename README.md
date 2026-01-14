# JingWenWall（荆文校园枢纽）

<p align="center">
  <img src="https://note.oddfar.com/img/web.png" width="180" alt="Logo">
</p>

<p align="center">
  基于 Spring Boot + Vue（管理后台）+ uni-app（小程序）的现代化校园综合信息服务平台
</p>

---

## 目录

- [1. 项目概述](#1-项目概述)
- [2. 安装指南](#2-安装指南)
- [3. 使用说明](#3-使用说明)
- [4. 配置选项](#4-配置选项)
- [5. API 文档](#5-api-文档)
- [6. 开发指南](#6-开发指南)
- [7. 常见问题](#7-常见问题)
- [8. 版本历史](#8-版本历史)
- [9. 许可证与致谢](#9-许可证与致谢)

---

## 1. 项目概述

**JingWenWall（荆文校园枢纽）**面向高校校园场景，提供“内容发布 + 社交互动 + 校园服务 + 后台治理”的一体化平台，包含后端服务、PC 管理后台与微信小程序（uni-app）三部分。

### 1.1 目标与特点

- **统一身份与权限**：后端基于 Spring Security + JWT，统一鉴权方式，前端通过 `Authorization: Bearer <token>` 调用受保护接口。
- **模块化业务能力**：论坛/信息墙、二手市场、跑腿服务、举报治理等按领域拆分，便于演进与维护。
- **可配置化**：基础配置通过 `application.yml` 管理；业务/系统参数通过数据库 `sys_config` 动态配置并支持缓存刷新。
- **开发体验**：管理后台开发模式内置代理转发；Swagger（Springfox OAS3）提供接口调试入口。

### 1.2 核心功能

- **信息墙 / 论坛**：发布帖子、草稿、评论、点赞、收藏、分类浏览。
- **二手市场**：商品发布、更新、下架/已售、收藏、搜索、我的发布/收藏。
- **跑腿服务**：发布订单、抢单/接单、订单状态流转、确认完成、骑手申请与管理。
- **举报治理**：面向帖子/评论/用户/商品等目标提交举报；管理侧处理与统计。
- **管理后台**：用户/角色/菜单/字典/参数配置等系统能力 + 业务运营模块（跑腿/市场/举报等）。

### 1.3 技术栈概览

| 领域 | 技术/框架 | 说明 |
| :--- | :--- | :--- |
| 后端 | Spring Boot 2.5.14 | 业务与基础能力 |
|  | Spring Security + JWT | 认证与授权 |
|  | MyBatis-Plus 3.5.x + PageHelper | ORM 与分页 |
|  | Redis | 缓存与会话/令牌相关能力 |
|  | Springfox（OAS 3.0） | Swagger UI 文档 |
| 管理后台（PC） | Vue 2 + Element UI | 管理端 UI |
| 小程序（uni-app） | Vue 3 + Vite | 微信小程序端 |

### 1.4 项目结构

```text
JingWenWall/
├── jingwenhub/                 # 后端 + 管理后台（Vue2）
│   ├── campus-admin/           # 管理后台接口（系统模块 Controller 等）
│   ├── campus-common/          # 通用工具、常量、统一返回体等
│   ├── campus-framework/       # 框架层（安全、拦截器、配置读取等）
│   ├── campus-modular/         # 业务模块（论坛/市场/跑腿/举报等）
│   ├── sql/                    # 数据库脚本
│   └── vue_campus_admin/       # PC 管理后台前端（Vue2）
├── uniapp/                     # 微信小程序端（uni-app + Vue3）
└── README.md                   # 本说明文档
```

---

## 2. 安装指南

### 2.1 系统要求

| 组件 | 版本建议 | 说明 |
| :--- | :--- | :--- |
| JDK | 1.8 | 后端编译/运行 |
| Maven | 3.6+ | 后端构建 |
| MySQL | 8.0+ | 业务数据存储 |
| Redis | 3.0+ | 缓存/参数/令牌相关 |
| Node.js | 14/16（推荐） | 管理后台构建；脚本已内置 `--openssl-legacy-provider` 兼容 |
| pnpm（可选） | 任意稳定版 | 小程序端/文档站点依赖安装更快（可用 npm 替代） |

### 2.2 获取源码

```bash
git clone <YOUR_REPO_URL>
cd JingWenWall
```

### 2.3 初始化数据库

1. 创建数据库：`jingwen_campus`（建议字符集 `utf8mb4`）
2. 导入脚本：[jingwen_campus.sql](file:///e:/wxxcx/JingWenWall/jingwenhub/sql/jingwen_campus.sql)

### 2.4 后端配置与启动

#### 2.4.1 配置

编辑后端配置：[application.yml](file:///e:/wxxcx/JingWenWall/jingwenhub/campus-modular/src/main/resources/application.yml)

必须修改的典型项：

- `spring.datasource.url/username/password`
- `spring.redis.host/port`（如 Redis 有密码，请按环境补充）
- `token.secret`（生产环境必须替换为自有强密钥）
- `wechat.mini.appId/appSecret`（如启用小程序登录）

#### 2.4.2 启动

方式一：IDE 启动  
- 运行启动类：[CampusApplication.java](file:///e:/wxxcx/JingWenWall/jingwenhub/campus-modular/src/main/java/com/oddfar/campus/CampusApplication.java)

方式二：命令行构建后运行（示例）

```bash
cd jingwenhub
mvn clean package -DskipTests
```

后端默认监听：

- `http://localhost:8001`
- Swagger UI：`http://localhost:8001/swagger-ui/index.html`

### 2.5 管理后台（PC）安装与启动

进入目录：

```bash
cd jingwenhub/vue_campus_admin
```

安装依赖并启动：

```bash
npm install
npm run dev
```

默认访问：

- `http://localhost:80`

开发环境代理（`/dev-api` -> `http://localhost:8001`）配置位于：[vue.config.js](file:///e:/wxxcx/JingWenWall/jingwenhub/vue_campus_admin/vue.config.js)

### 2.6 小程序（uni-app）安装与启动

进入目录：

```bash
cd uniapp
```

安装依赖：

```bash
pnpm install
# 或 npm install
```

启动微信小程序开发：

```bash
pnpm dev:mp-weixin
# 或 npm run dev:mp-weixin
```

运行后，用微信开发者工具导入：

- `uniapp/dist/dev/mp-weixin`

小程序后端地址配置位于：[env.js](file:///e:/wxxcx/JingWenWall/uniapp/src/utils/env.js)（开发环境通常需要填电脑局域网 IP + `:8001`，真机调试必需）

---

## 3. 使用说明

本节以“后端 + 管理后台 + 小程序”完整链路为主，提供典型用例与示例调用。

### 3.1 运行检查清单

- MySQL 已导入 `jingwen_campus.sql`
- Redis 可连接
- 后端 `8001` 启动成功
- 管理后台可打开 `http://localhost:80`
- 小程序端 `baseUrl` 指向可访问的后端地址

### 3.2 管理后台典型使用

1. 获取验证码（如启用验证码）
2. 登录获取 token
3. 拉取用户信息与路由

示例（curl）：

```bash
curl -X POST "http://localhost:8001/login" ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"<USERNAME>\",\"password\":\"<PASSWORD>\",\"code\":\"<CODE>\",\"uuid\":\"<UUID>\"}"
```

成功响应（示例）：

```json
{
  "code": 200,
  "msg": "success",
  "token": "<JWT_TOKEN>"
}
```

### 3.3 小程序端典型使用

#### 3.3.1 微信登录（获取 token）

接口：`POST /api/v1/wx/auth/login`

示例（curl）：

```bash
curl -X POST "http://localhost:8001/api/v1/wx/auth/login" ^
  -H "Content-Type: application/json" ^
  -d "{\"code\":\"<WECHAT_LOGIN_CODE>\"}"
```

#### 3.3.2 拉取最新帖子列表

接口：`GET /api/v1/forum/posts/newest?pageNum=1&pageSize=10`

示例（curl）：

```bash
curl "http://localhost:8001/api/v1/forum/posts/newest?pageNum=1&pageSize=10" ^
  -H "Authorization: Bearer <JWT_TOKEN>"
```

分页响应（示例，字段以统一返回体为准）：

```json
{
  "code": 200,
  "msg": "success",
  "rows": [],
  "total": 0
}
```

#### 3.3.3 发布带图片的帖子（典型流程）

1. 上传图片：`POST /campus/imageUpload`（multipart/form-data，字段名 `file`）
2. 拿到图片 URL 后发布帖子：`POST /api/v1/forum/posts`

---

## 4. 配置选项

配置分为 4 类：后端 `application.yml`、后端“参数配置（sys_config）”、管理后台环境变量、小程序环境配置。

### 4.1 后端 application.yml

配置文件：[application.yml](file:///e:/wxxcx/JingWenWall/jingwenhub/campus-modular/src/main/resources/application.yml)

| 配置项 | 默认值/示例 | 说明 |
| :--- | :--- | :--- |
| `server.port` | `8001` | 服务端口 |
| `server.address` | `0.0.0.0` | 监听地址 |
| `spring.datasource.url` | `jdbc:mysql://.../jingwen_campus...` | MySQL 连接串 |
| `spring.datasource.username/password` | `root/...` | 数据库账号密码（请替换为你的环境） |
| `spring.redis.host/port/database` | `127.0.0.1/6379/0` | Redis 连接 |
| `spring.servlet.multipart.max-file-size` | `20MB` | 单文件大小 |
| `spring.servlet.multipart.max-request-size` | `20MB` | 请求总大小 |
| `token.header` | `Authorization` | Token 传递请求头 |
| `token.secret` | `...` | JWT 签名密钥（生产环境必须替换） |
| `token.expireTime` | `1440` | token 有效期（分钟） |
| `swagger.enabled` | `true` | 是否开启 Swagger |
| `wechat.mini.appId/appSecret` | `<YOUR_APPID>/<YOUR_SECRET>` | 微信小程序登录配置 |

### 4.2 后端参数配置（sys_config）

系统参数存储于数据库 `sys_config` 表，项目启动时会加载到 Redis 缓存（并提供刷新能力）。典型用途：文件存储路径、验证码类型、默认头像、邮件服务、校园业务参数等。

参数来源：数据库脚本 [jingwen_campus.sql](file:///e:/wxxcx/JingWenWall/jingwenhub/sql/jingwen_campus.sql)（`INSERT INTO sys_config ...`）

常用参数键示例（节选）：

| configKey | 默认值（脚本） | 说明 |
| :--- | :--- | :--- |
| `sys.local.profile.win` | `D:\uploadPath` | Windows 本地文件存储根目录 |
| `sys.local.profile.linux` | `/data/uploadPath` | Linux 本地文件存储根目录 |
| `sys.local.profile.mac` | `~/uploadPath` | macOS 本地文件存储根目录 |
| `sys.server.deploy.host` | `http://localhost:8160` | 文件部署/访问域名（按业务实现使用） |
| `sys.file.visit.nginx` | `false` | 文件访问是否走 Nginx 映射 |
| `sys.file.is.delete` | `false` | 删除内容时是否同时删除文件 |
| `sys.file.move.default.bucket` | `moveBucket` | 文件转移默认 bucket（按业务实现使用） |
| `sys.user.default.avatar` | `https://...png` | 用户默认头像 |
| `sys.login.captchaType` | `math` | 验证码类型：`math`/`char` |
| `sys.log.global.flag` | `true` | 全局接口日志记录开关 |
| `sys.email.smtp.host` | `smtp.qq.com` | SMTP 地址 |
| `sys.email.smtp.port` | `465` | SMTP 端口 |
| `sys.email.send.account` | `...@qq.com` | 发件邮箱 |
| `sys.email.password` | `xxxxx` | 发件邮箱密码/授权码 |
| `campus.user.anonymous.image` | `https://...jpeg` | 匿名头像 |
| `campus.wxmp.appid` | `<YOUR_APPID>` | 微信小程序 APPID（业务侧读取） |
| `campus.wxmp.secret` | `<YOUR_SECRET>` | 微信小程序 SECRET（业务侧读取） |

读取方式（服务端）示例：通过 `SysConfigService.selectConfigByKey()` 或 `ConfigExpander`/`SysConfigExpander` 读取。

接口侧查询（管理后台已对接）：

- `GET /system/config/configKey/{configKey}`

### 4.3 管理后台（Vue2）环境变量

配置文件：

- 开发环境：[.env.development](file:///e:/wxxcx/JingWenWall/jingwenhub/vue_campus_admin/.env.development)
- 生产环境：[.env.production](file:///e:/wxxcx/JingWenWall/jingwenhub/vue_campus_admin/.env.production)

| 变量 | 示例 | 说明 |
| :--- | :--- | :--- |
| `VUE_APP_TITLE` | `campus` | 页面标题 |
| `VUE_APP_BASE_API` | `/dev-api`、`/prod-api` | API 前缀（配合代理/网关） |

开发代理位于：[vue.config.js](file:///e:/wxxcx/JingWenWall/jingwenhub/vue_campus_admin/vue.config.js)

### 4.4 小程序（uni-app）环境配置

配置文件：[env.js](file:///e:/wxxcx/JingWenWall/uniapp/src/utils/env.js)

| 配置项 | 示例 | 说明 |
| :--- | :--- | :--- |
| `DEV_BASE_URL` | `http://192.168.x.x:8001` | 开发环境后端地址（真机调试必需局域网 IP） |
| `PROD_BASE_URL` | `https://your-domain.com` | 生产环境后端地址 |
| `mapkey` | `<TENCENT_MAP_KEY>` | 腾讯地图 Key（如使用定位/地图功能） |

---

## 5. API 文档

### 5.1 基本约定

#### 5.1.1 Base URL

- 本地默认：`http://localhost:8001`

#### 5.1.2 认证方式

除标注“匿名”的接口外，均需携带：

```http
Authorization: Bearer <JWT_TOKEN>
```

#### 5.1.3 统一响应体

后端统一返回体为 `R`，典型字段：

```json
{
  "code": 200,
  "msg": "success",
  "data": {}
}
```

分页接口常见字段为：

```json
{
  "code": 200,
  "msg": "success",
  "rows": [],
  "total": 0
}
```

### 5.2 Swagger UI

当 `swagger.enabled=true` 时可访问：

- `http://localhost:8001/swagger-ui/index.html`

### 5.3 管理后台（系统）接口

| 功能 | 方法 | 路径 | 说明 |
| :--- | :--- | :--- | :--- |
| 登录 | POST | `/login` | 获取 token |
| 获取验证码 | GET | `/captchaImage` | 登录验证码 |
| 获取用户信息 | GET | `/getInfo` | 用户、角色、权限 |
| 获取路由 | GET | `/getRouters` | 菜单路由 |
| 退出 | POST | `/logout` | 退出登录 |
| 参数分页 | GET | `/system/config/page` | 参数配置分页 |
| 查询参数值 | GET | `/system/config/configKey/{configKey}` | 根据键读取参数 |
| 刷新参数缓存 | DELETE | `/system/config/refreshCache` | 重新加载缓存 |

### 5.4 小程序（业务）接口

#### 5.4.1 微信认证

| 功能 | 方法 | 路径 | Body |
| :--- | :--- | :--- | :--- |
| 微信小程序登录（匿名） | POST | `/api/v1/wx/auth/login` | `{ "code": "<wx-code>" }` |

#### 5.4.2 论坛/信息墙

| 功能 | 方法 | 路径 | 查询参数/Body |
| :--- | :--- | :--- | :--- |
| 最新帖子列表 | GET | `/api/v1/forum/posts/newest` | `pageNum,pageSize` |
| 热门帖子列表 | GET | `/api/v1/forum/posts/hot` | `pageNum,pageSize` |
| 分类帖子列表 | GET | `/api/v1/forum/posts/category/{categoryId}` | `pageNum,pageSize` |
| 帖子详情 | GET | `/api/v1/forum/posts/{postId}` | - |
| 发布帖子 | POST | `/api/v1/forum/posts` | JSON |
| 删除帖子 | DELETE | `/api/v1/forum/posts/{postId}` | - |
| 保存草稿 | POST | `/api/v1/forum/posts/draft` | JSON |
| 获取草稿 | GET | `/api/v1/forum/posts/draft` | - |
| 点赞/取消点赞 | POST/DELETE | `/api/v1/forum/posts/{postId}/like` | - |
| 收藏/取消收藏 | POST/DELETE | `/api/v1/forum/posts/{postId}/collect` | - |
| 我的帖子 | GET | `/api/v1/forum/posts/mine` | `pageNum,pageSize` |
| 我的收藏（帖子） | GET | `/api/v1/forum/posts/collected` | `pageNum,pageSize` |

评论相关：

| 功能 | 方法 | 路径 | 说明 |
| :--- | :--- | :--- | :--- |
| 评论列表 | GET | `/api/v1/forum/comments/post/{postId}` | `pageNum,pageSize` |
| 发布评论 | POST | `/api/v1/forum/comments` | JSON |
| 删除评论 | DELETE | `/api/v1/forum/comments/{commentId}` | - |
| 点赞/取消点赞（评论） | POST/DELETE | `/api/v1/forum/comments/{commentId}/like` | - |

#### 5.4.3 二手市场

| 功能 | 方法 | 路径 | 查询参数/Body |
| :--- | :--- | :--- | :--- |
| 商品列表 | GET | `/api/v1/market/items` | `pageNum,pageSize,categoryId?` |
| 商品详情 | GET | `/api/v1/market/items/{itemId}` | - |
| 发布商品 | POST | `/api/v1/market/items` | JSON |
| 更新商品 | PUT | `/api/v1/market/items/{itemId}` | JSON |
| 删除商品 | DELETE | `/api/v1/market/items/{itemId}` | - |
| 标记已售 | POST | `/api/v1/market/items/{itemId}/sold` | - |
| 下架商品 | POST | `/api/v1/market/items/{itemId}/off-shelf` | - |
| 收藏/取消收藏 | POST/DELETE | `/api/v1/market/items/{itemId}/collect` | - |
| 我的商品 | GET | `/api/v1/market/items/mine` | `pageNum,pageSize` |
| 我的收藏（商品） | GET | `/api/v1/market/items/collected` | `pageNum,pageSize` |
| 搜索商品 | GET | `/api/v1/market/items/search` | `keyword,pageNum,pageSize` |

#### 5.4.4 跑腿服务

| 功能 | 方法 | 路径 | 查询参数/Body |
| :--- | :--- | :--- | :--- |
| 待接单列表 | GET | `/api/v1/errand/orders/waiting` | `pageNum,pageSize` |
| 订单详情 | GET | `/api/v1/errand/orders/{orderId}` | - |
| 创建订单 | POST | `/api/v1/errand/orders` | JSON |
| 接单 | POST | `/api/v1/errand/orders/{orderId}/accept` | - |
| 更新状态 | PUT | `/api/v1/errand/orders/{orderId}/status` | `status` |
| 取消订单 | POST | `/api/v1/errand/orders/{orderId}/cancel` | `reason?` |
| 确认完成 | POST | `/api/v1/errand/orders/{orderId}/confirm` | - |
| 我发布的订单 | GET | `/api/v1/errand/orders/published` | `pageNum,pageSize` |
| 我接的订单 | GET | `/api/v1/errand/orders/accepted` | `pageNum,pageSize` |
| 模拟支付（测试） | POST | `/api/v1/errand/orders/{orderId}/mock-pay` | - |
| 申请骑手 | POST | `/api/v1/errand/runner/apply` | JSON |
| 我的骑手信息 | GET | `/api/v1/errand/runner/mine` | - |
| 是否骑手 | GET | `/api/v1/errand/runner/check` | - |

#### 5.4.5 举报

| 功能 | 方法 | 路径 | Body |
| :--- | :--- | :--- | :--- |
| 提交举报 | POST | `/api/v1/report` | `{ targetType, targetId, reasonType, reasonDetail, images }` |

#### 5.4.6 文件与静态资源

| 功能 | 方法 | 路径 | 说明 |
| :--- | :--- | :--- | :--- |
| 上传图片 | POST | `/campus/imageUpload` | `multipart/form-data`，字段名 `file` |
| 删除文件 | POST | `/campus/file/delete` | 表单参数 `fileUrl` |
| 静态资源访问 | GET | `/profile/**` | 对应本地文件目录映射（见 `sys.local.profile.*`） |

### 5.5 管理后台（业务运营）接口

跑腿管理（后台）：

| 功能 | 方法 | 路径 |
| :--- | :--- | :--- |
| 订单列表 | GET | `/admin/errand/order/list` |
| 订单详情 | GET | `/admin/errand/order/{orderId}` |
| 管理员取消订单 | POST | `/admin/errand/order/{orderId}/cancel` |
| 删除订单 | DELETE | `/admin/errand/order/{orderIds}` |
| 骑手列表 | GET | `/admin/errand/runner/list` |
| 审核骑手 | POST | `/admin/errand/runner/audit/{runnerId}` |
| 禁用骑手 | POST | `/admin/errand/runner/disable/{runnerId}` |
| 启用骑手 | POST | `/admin/errand/runner/enable/{runnerId}` |

二手市场管理（后台）与举报管理（后台）接口详见 Swagger 或变更记录：[CHANGELOG_20260114.md](file:///e:/wxxcx/JingWenWall/CHANGELOG_20260114.md)

---

## 6. 开发指南

### 6.1 代码贡献

1. Fork 仓库并新建分支（建议：`feat/xxx`、`fix/xxx`）
2. 保持一次提交只做一类改动（便于 review）
3. 提交 PR 前自测通过并补充必要说明

### 6.2 构建与发布

后端（示例）：

```bash
cd jingwenhub
mvn clean package -DskipTests
```

管理后台：

```bash
cd jingwenhub/vue_campus_admin
npm run build:prod
```

小程序：

```bash
cd uniapp
pnpm build:mp-weixin
```

### 6.3 测试与质量

后端测试（JUnit）：

```bash
cd jingwenhub
mvn test
```

管理后台 lint：

```bash
cd jingwenhub/vue_campus_admin
npm run lint
```

---

## 7. 常见问题

### 7.1 管理后台启动报 OpenSSL/加密相关错误

项目脚本已内置 `NODE_OPTIONS=--openssl-legacy-provider`（见 `vue_campus_admin/package.json`），建议使用 Node 14/16。

### 7.2 小程序请求后端失败/超时

- 真机调试必须使用电脑局域网 IP（不要用 `localhost`），并在 [env.js](file:///e:/wxxcx/JingWenWall/uniapp/src/utils/env.js) 配置 `DEV_BASE_URL`
- 微信开发者工具需开启“**不校验合法域名**”或配置合法域名

### 7.3 Swagger 访问不到

- 确认 `swagger.enabled=true`
- 访问 `http://localhost:8001/swagger-ui/index.html`

### 7.4 上传后图片打不开/404

- 静态资源映射前缀为 `/profile`，并映射到 `sys.local.profile.*` 指定的本地目录
- 检查本地目录权限、文件是否存在、以及 URL 是否以 `/profile/...` 返回

### 7.5 频繁 401/403

- 检查请求头是否为 `Authorization: Bearer <token>`
- token 过期可通过重新登录刷新（`token.expireTime` 为分钟）

---

## 8. 版本历史

| 时间 | 版本/标识 | 变更摘要 |
| :--- | :--- | :--- |
| 2026-01-14 | 联调修复 + 管理后台新增模块 | 新增跑腿/二手/举报管理模块；补充文件删除接口；修复小程序 API 调用问题（详见 [CHANGELOG_20260114.md](file:///e:/wxxcx/JingWenWall/CHANGELOG_20260114.md)） |
| - | `campus.version=1.1.7` | 后端配置文件标记版本（见 `application.yml`） |

---

## 9. 许可证与致谢

### 9.1 许可证

本项目采用 [MIT License](LICENSE)。

### 9.2 致谢

- 感谢 [RuoYi-Vue](https://gitee.com/y_project/RuoYi-Vue) 提供管理后台基础能力参考
- 感谢 [Campus](https://github.com/oddfar/campus) 提供业务逻辑参考
