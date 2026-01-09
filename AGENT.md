# JingWenHub 项目 - AI Agent 开发手册

> **文档用途**：为 AI Agent 提供项目全景信息，确保高效准确的开发协助  
> **最后更新**：2026-01-09  
> **维护者**：开发团队

---

## 📋 目录

- [1. 项目架构](#1-项目架构)
- [2. 前后端连调规范](#2-前后端连调规范)
- [3. 认证鉴权机制](#3-认证鉴权机制)
- [4. 已知问题与解决方案](#4-已知问题与解决方案)
- [5. 开发环境配置](#5-开发环境配置)
- [6. 项目结构详解](#6-项目结构详解)
- [7. 核心技术栈](#7-核心技术栈)
- [8. TODO 清单](#8-todo-清单)

---

## 1. 项目架构

### 1.1 项目概述

**JingWenHub** 是一个校园信息墙小程序项目，采用前后端分离架构。

### 1.2 整体架构

```
e:\wxxcx\JingWenWall\
│
├── jingwenhub/              # 后端项目（Spring Boot 2.5.14）
│   ├── campus-common/       # 公共模块
│   ├── campus-framework/    # 系统框架（安全、权限、拦截器）
│   ├── campus-admin/        # 管理模块
│   ├── campus-modular/      # 业务模块【主启动入口】
│   │   └── CampusApplication.java  # 启动类
│   └── sql/                 # 数据库脚本
│
├── uniapp/                  # 前端小程序（uni-app + Vue3）
│   ├── src/
│   │   ├── pages/          # 页面组件
│   │   ├── api/            # API 接口封装
│   │   └── utils/          # 工具类
│   └── dist/dev/mp-weixin/ # 编译输出（微信小程序）
│
├── vue_campus_admin/        # 管理后台（Vue3 + Element Plus）
│
├── 启动指南.md             # 详细启动文档（800+行）
└── AGENT.md                # 本文档
```

### 1.3 通信方式

- **协议**：HTTP/HTTPS
- **数据格式**：JSON
- **字符编码**：UTF-8
- **后端端口**：8160
- **开发环境地址**：`http://localhost:8160`

---

## 2. 前后端连调规范

### 2.1 API 接口调用规范

#### 统一请求封装

**文件位置**：`uniapp/src/utils/request.js`

```javascript
export function request({url='', params={}, method='GET'}) {
    const token = uni.getStorageSync('token');
    let header = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : ''
    }
    
    return new Promise((resolve, reject) => {
        uni.request({
            url: baseUrl + url,
            data: params,
            header: header,
            method: method,
            success: (res) => {
                if (res.data.code === 200 || res.data.code === 1) {
                    resolve(res.data)
                } else {
                    reject(res.data)
                }
            },
            fail: (err) => reject(err)
        });
    })
}
```

#### 响应格式规范

**成功响应**：
```json
{
  "code": 200,
  "data": {},
  "msg": "操作成功"
}
```

**失败响应**：
```json
{
  "code": 401,
  "data": null,
  "msg": "认证失败，无法访问系统资源"
}
```

### 2.2 跨域配置

#### 开发环境
在微信开发者工具中关闭域名校验：
- 详情 → 本地设置 → 勾选 **"不校验合法域名、web-view（业务域名）、TLS 版本以及 HTTPS 证书"**

#### 生产环境
在微信公众平台配置服务器域名：
- 登录 [微信公众平台](https://mp.weixin.qq.com)
- 开发管理 → 开发设置 → 服务器域名
- request 合法域名：添加后端生产域名

### 2.3 接口地址配置

**文件位置**：`uniapp/src/utils/env.js`

```javascript
/**
 * 环境配置文件
 */

// 开发环境 - 后端服务地址
const DEV_BASE_URL = 'http://localhost:8160'

// 生产环境 - 后端服务地址
const PROD_BASE_URL = 'https://your-production-domain.com'

// 根据环境自动选择
const baseUrl = process.env.NODE_ENV === 'development' 
    ? DEV_BASE_URL 
    : PROD_BASE_URL

// 腾讯地图 API Key
const mapkey = 'RSNBZ-3ABW4-MF3UK-FMCJP-JC4YT-RUFTR'

export { baseUrl, mapkey }
```

### 2.4 核心接口路径

| 功能 | 方法 | 路径 | 说明 |
|-----|------|------|------|
| 微信登录 | POST | `/api/v1/wx/auth/login` | 需传递微信 code |
| 获取话题列表 | GET | `/student/get/topic?page=1&pageSize=10` | 需认证 |
| 获取用户信息 | GET | `/student/get/info` | 需认证 |
| 获取当前用户信息 | GET | `/student/get/currentUserInfo` | 需认证 |
| 上传文件 | POST | `/student/common/upload` | 需认证 |
| 发布话题 | POST | `/student/post/topic` | 需认证 |

---

## 3. 认证鉴权机制

### 3.1 后端认证配置

**配置文件**：`jingwenhub/campus-modular/src/main/resources/application.yml`

```yaml
# token 配置
token:
  # 令牌自定义标识
  header: Authorization
  # 令牌密钥（至少64字符）
  secret: abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz
  # 令牌有效期（单位分钟）
  expireTime: 1440
```

### 3.2 Token 传递规范

#### ⚠️ 重要：标准格式

**所有 API 请求必须使用以下 header 格式**：

```javascript
header: {
  'Authorization': `Bearer ${uni.getStorageSync('token')}`
}
```

#### ❌ 错误示例

```javascript
// 错误方式1：缺少 Bearer 前缀
'Authorization': uni.getStorageSync('token')

// 错误方式2：使用错误的 header 名称
'token': uni.getStorageSync('token')
```

### 3.3 Token 生命周期

```
1. 用户打开小程序
   ↓
2. 调用 uni.login() 获取微信 code
   ↓
3. 将 code 发送到后端 /api/v1/wx/auth/login
   ↓
4. 后端验证 code，获取 openid
   ↓
5. 后端生成 JWT token 并返回
   ↓
6. 小程序保存 token 到本地存储
   uni.setStorageSync('token', token)
   ↓
7. 后续所有请求携带 Authorization: Bearer <token>
   ↓
8. 后端验证 token 有效性
   ↓
9. Token 过期后自动刷新或重新登录
```

### 3.4 认证相关文件

| 文件 | 说明 |
|-----|------|
| `jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/web/service/TokenService.java` | Token 服务类 |
| `jingwenhub/campus-framework/src/main/java/com/oddfar/campus/framework/security/filter/JwtAuthenticationTokenFilter.java` | JWT 认证过滤器 |
| `uniapp/src/api/login.js` | 前端登录 API |
| `uniapp/src/utils/request.js` | 请求拦截器 |

---

## 4. 已知问题与解决方案

### 4.1 前后端接口架构迁移 ✅ 已完成（2026-01-09）

#### 迁移背景
后端已升级为新的论坛系统架构（`/api/v1/forum/`），但前端仍使用旧的 `/student/` 路径，导致接口调用失败。

#### 迁移范围
**共修复 5 个 API 文件，60+ 处接口路径变更**：

**1. topic.js（话题/帖子）**
| 旧接口路径 | 新接口路径 | 方法 | 说明 |
|-----------|-----------|------|------|
| `/student/get/topic` | `/api/v1/forum/posts/newest` | GET | 获取最新帖子列表 |
| `/student/post/topic` | `/api/v1/forum/posts` | POST | 发布帖子 |
| `/student/topic/{id}` | `/api/v1/forum/posts/{postId}` | GET | 获取帖子详情 |
| `/student/delete/topic/{id}` | `/api/v1/forum/posts/{postId}` | DELETE | 删除帖子 |
| `/student/get/publish` | `/api/v1/forum/posts/mine` | GET | 获取我发布的帖子 |
| `/student/isexist/draft` | `/api/v1/forum/posts/draft` | GET | 检查草稿存在 |
| `/student/get/draft` | `/api/v1/forum/posts/draft` | GET | 获取草稿 |
| `/student/save/draft` | `/api/v1/forum/posts/draft` | POST | 保存草稿 |
| `/student/common/upload` | `/campus/imageUpload` | POST | 上传图片 |

**2. comment.js（评论）**
| 旧接口路径 | 新接口路径 | 方法 | 说明 |
|-----------|-----------|------|------|
| `/student/get/comments/{id}` | `/api/v1/forum/comments/post/{postId}` | GET | 获取评论列表 |
| `/student/comment/topic/{id}` | `/api/v1/forum/comments` | POST | 发布评论 |
| `/student/delete/comment/{id}` | `/api/v1/forum/comments/{commentId}` | DELETE | 删除评论 |
| `/student/like/comment/{id}` | `/api/v1/forum/comments/{commentId}/like` | POST | 点赞评论 |
| `/student/unlike/comment/{id}` | `/api/v1/forum/comments/{commentId}/like` | DELETE | 取消点赞评论 |

**3. collect.js（收藏）**
| 旧接口路径 | 新接口路径 | 方法 | 说明 |
|-----------|-----------|------|------|
| `/student/get/collect` | `/api/v1/forum/posts/collected` | GET | 获取我收藏的帖子 |
| `/student/collect/topic/{id}` | `/api/v1/forum/posts/{postId}/collect` | POST | 收藏帖子 |
| `/student/uncollect/topic/{id}` | `/api/v1/forum/posts/{postId}/collect` | DELETE | 取消收藏 |

**4. like.js（点赞）**
| 旧接口路径 | 新接口路径 | 方法 | 说明 |
|-----------|-----------|------|------|
| `/student/like/topic/{id}` | `/api/v1/forum/posts/{postId}/like` | POST | 点赞帖子 |
| `/student/unlike/topic/{id}` | `/api/v1/forum/posts/{postId}/like` | DELETE | 取消点赞 |

**5. user.js（用户信息）**
| 旧接口路径 | 新接口路径 | 方法 | 说明 |
|-----------|-----------|------|------|
| `/student/get/currentUserInfo` | `/student/get/info` | GET | 获取当前用户信息 |

#### 重要变更
1. **参数名变更**：
   - `topicId` → `postId`（帖子ID）
   - `page` → `pageNum`（页码参数）
   - 统一使用 RESTful 风格路径参数

2. **响应码变更**：
   - 旧版本：`code: 1` 表示成功
   - 新版本：`code: 200` 表示成功

3. **HTTP方法规范化**：
   - 取消操作统一使用 `DELETE` 方法（旧版本多数使用 `POST`）
   - 符合 RESTful API 设计规范

#### 迁移优势
- ✅ 接口路径更清晰，符合 RESTful 规范
- ✅ 后端统一管理，易于维护和扩展
- ✅ 支持更多论坛功能（如草稿、分类浏览等）
- ✅ 响应格式统一，便于前端处理

---

### 4.2 认证失败问题 ✅ 已修复（2026-01-09）

#### 问题现象
- 话题列表加载失败，提示"加载失败"
- 获取用户信息失败，返回 401 认证失败
- 控制台报错：`请求访问：/student/get/info，认证失败，无法访问系统资源`

#### 根本原因
前端多处使用了错误的 token 传递方式，与后端期望的 `Authorization: Bearer <token>` 格式不匹配。

#### 修复范围
**共修复 9 个文件，40+ 处修改**：

**核心工具**：
- `uniapp/src/utils/request.js`

**API 文件**（7个）：
- `uniapp/src/api/topic.js` - 10 处修改
- `uniapp/src/api/user.js` - 1 处修改
- `uniapp/src/api/collect.js` - 3 处修改
- `uniapp/src/api/like.js` - 2 处修改
- `uniapp/src/api/comment.js` - 5 处修改
- `uniapp/src/api/forum.js` - 15 处修改
- `uniapp/src/api/getPhone.js` - 1 处修改

**页面文件**（3个）：
- `uniapp/src/pages/person/person.vue` - 1 处修改
- `uniapp/src/pages/person/editInfo.vue` - 3 处修改
- `uniapp/src/pages/topic/report.vue` - 1 处修改

#### 修复方案
将所有请求头统一修改为标准格式：
```javascript
'Authorization': `Bearer ${uni.getStorageSync('token')}`
```

### 4.2 Lombok 兼容性问题 ✅ 已修复

#### 问题现象
编译时报错：
```
java.lang.NoSuchFieldError: Class com.sun.tools.javac.tree.JCTree$JCImport 
does not have member field 'com.sun.tools.javac.tree.JCTree qualid'
```

#### 根本原因
Lombok 1.18.20 不兼容 JDK 21

#### 解决方案
在 `jingwenhub/pom.xml` 中升级 Lombok 版本：
```xml
<properties>
    <lombok.version>1.18.30</lombok.version>
</properties>
```

### 4.3 Redis 连接失败 ⚠️ 常见问题

#### 问题现象
```
RedisConnectionException: Unable to connect to 127.0.0.1:6379
Caused by: java.net.ConnectException: Connection refused
```

#### 根本原因
Redis 服务未启动

#### 解决方案
```bash
# Windows 启动 Redis
redis-server --service-start

# 验证 Redis 是否运行
redis-cli ping
# 应该返回：PONG
```

### 4.4 微信登录接口路径错误 ✅ 已修复

#### 问题现象
登录时返回 401 认证失败

#### 根本原因
使用了旧的登录接口路径 `/student/login/login`

#### 解决方案
在 `uniapp/src/api/login.js` 中更新接口路径：
```javascript
// ❌ 错误的旧接口
// url: baseUrl + '/student/login/login'

// ✅ 正确的新接口
url: baseUrl + '/api/v1/wx/auth/login'
```

### 4.5 env.js 文件缺失 ✅ 已修复

#### 问题现象
```
Cannot find module 'E:/wxxcx/JingWenWall/uniapp/src/utils/env'
```

#### 解决方案
已创建 `uniapp/src/utils/env.js` 配置文件，包含：
- `baseUrl` - 后端服务地址
- `mapkey` - 腾讯地图 API Key

---

## 5. 开发环境配置

### 5.1 必需环境

| 软件 | 版本要求 | 说明 |
|------|---------|------|
| **JDK** | 21.0.8+ | Java 开发环境 |
| **Maven** | 3.6.0+ | 项目构建工具 |
| **MySQL** | 5.7+ / 8.0+ | 数据库 |
| **Redis** | 5.0+ | 缓存服务 |
| **Node.js** | 16.0+ | 前端运行环境 |
| **pnpm** | 8.0+ | Node 包管理器 |
| **微信开发者工具** | 最新稳定版 | 小程序调试工具 |

### 5.2 后端环境搭建

#### 步骤 1：数据库初始化

```bash
# 创建数据库
mysql -u root -p
CREATE DATABASE jingwen_campus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 导入基础表
mysql -u root -p jingwen_campus < e:\wxxcx\JingWenWall\jingwenhub\sql\campus_example-1.1.7.sql

# 导入业务表
mysql -u root -p jingwen_campus < e:\wxxcx\JingWenWall\jingwenhub\sql\bus_tables_v1.0.sql
```

#### 步骤 2：配置文件修改

编辑 `jingwenhub/campus-modular/src/main/resources/application.yml`：

```yaml
# 数据库配置
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/jingwen_campus?characterEncoding=utf-8&useSSL=true&serverTimezone=GMT%2B8
    username: root
    password: YOUR_PASSWORD  # ⚠️ 修改为你的 MySQL 密码

# Redis 配置
  redis:
    host: 127.0.0.1
    port: 6379
    database: 0

# 微信小程序配置
wechat:
  mini:
    appId: YOUR_APPID      # ⚠️ 替换为你的小程序 AppID
    appSecret: YOUR_SECRET  # ⚠️ 替换为你的小程序 AppSecret
```

#### 步骤 3：Maven 依赖安装

```bash
cd e:\wxxcx\JingWenWall\jingwenhub
mvn clean install -DskipTests
```

#### 步骤 4：启动后端服务

```bash
# 方式 1：Maven 命令
cd e:\wxxcx\JingWenWall\jingwenhub\campus-modular
mvn spring-boot:run

# 方式 2：IDE 启动（推荐）
# 在 IDEA 中找到 CampusApplication.java，右键运行
```

**验证启动成功**：
- 控制台输出：`Started CampusApplication in X.XXX seconds`
- 访问 Swagger：http://localhost:8160/swagger-ui.html

### 5.3 前端环境搭建

#### 步骤 1：安装依赖

```bash
cd e:\wxxcx\JingWenWall\uniapp
pnpm install
```

#### 步骤 2：启动编译

```bash
# 编译为微信小程序（开发模式）
pnpm run dev:mp-weixin
```

**预期输出**：
```
DONE  Build complete. Watching for changes...
运行方式：打开 微信开发者工具, 导入 dist\dev\mp-weixin 运行。
```

#### 步骤 3：微信开发者工具导入

1. 打开微信开发者工具
2. 点击"导入项目"
3. 项目路径：`e:\wxxcx\JingWenWall\uniapp\dist\dev\mp-weixin`
4. AppID：使用你的小程序 AppID（或选择"测试号"）
5. 点击"编译"预览

### 5.4 数据库配置信息

**数据库名称**：`jingwen_campus`

**核心表说明**：
- `sys_user` - 系统用户表
- `sys_role` - 角色表
- `sys_menu` - 菜单权限表
- `bus_student` - 学生信息扩展表
- `bus_forum_post` - 论坛帖子
- `bus_forum_comment` - 帖子评论
- `bus_errand_order` - 跑腿订单
- `bus_market_item` - 二手商品

---

## 6. 项目结构详解

### 6.1 后端模块划分

```
jingwenhub/
├── campus-common/               # 公共模块
│   ├── annotation/             # 自定义注解（@Log, @Anonymous等）
│   ├── config/                 # 公共配置（Redis等）
│   ├── constant/               # 常量定义
│   ├── domain/                 # 公共实体类
│   ├── enums/                  # 枚举类
│   ├── exception/              # 异常处理
│   ├── filter/                 # 过滤器
│   └── utils/                  # 工具类
│
├── campus-framework/            # 框架模块
│   ├── config/                 # 框架配置（安全、Swagger等）
│   ├── security/               # 安全认证
│   │   ├── filter/            # JWT 过滤器
│   │   └── handler/           # 认证处理器
│   ├── web/                    # Web 配置
│   │   └── service/           # TokenService, SysLoginService
│   └── interceptor/            # 拦截器
│
├── campus-admin/                # 管理模块
│   ├── config/                 # Swagger 配置
│   └── controller/             # 管理接口
│       ├── monitor/           # 监控接口
│       └── system/            # 系统管理接口
│
├── campus-modular/              # 业务模块（主启动入口）
│   ├── src/main/
│   │   ├── java/com/oddfar/campus/
│   │   │   ├── CampusApplication.java  # 启动类
│   │   │   ├── business/      # 业务逻辑
│   │   │   │   ├── controller/  # 业务接口
│   │   │   │   ├── service/    # 业务服务
│   │   │   │   ├── mapper/     # 数据访问
│   │   │   │   └── domain/     # 业务实体
│   │   │   └── web/           # Web 配置
│   │   └── resources/
│   │       ├── application.yml  # 主配置文件
│   │       └── mapper/         # MyBatis XML
│   └── pom.xml
│
└── sql/                         # 数据库脚本
    ├── campus_example-1.1.7.sql   # 基础表
    └── bus_tables_v1.0.sql        # 业务表
```

### 6.2 前端模块划分

```
uniapp/
├── src/
│   ├── pages/                  # 页面组件
│   │   ├── index/             # 首页
│   │   │   ├── index.vue      # 话题列表页
│   │   │   └── components/    # 首页子组件
│   │   ├── person/            # 个人中心
│   │   │   ├── person.vue     # 个人主页
│   │   │   └── editInfo.vue   # 编辑信息
│   │   ├── topic/             # 话题相关
│   │   │   ├── create.vue     # 创建话题
│   │   │   ├── detail.vue     # 话题详情
│   │   │   └── report.vue     # 举报
│   │   ├── favorites/         # 收藏
│   │   ├── message/           # 消息
│   │   └── order/             # 订单
│   │
│   ├── api/                    # API 接口封装
│   │   ├── login.js           # 登录相关
│   │   ├── topic.js           # 话题相关
│   │   ├── user.js            # 用户相关
│   │   ├── comment.js         # 评论相关
│   │   ├── like.js            # 点赞相关
│   │   ├── collect.js         # 收藏相关
│   │   ├── forum.js           # 论坛相关
│   │   └── getPhone.js        # 获取手机号
│   │
│   ├── utils/                  # 工具类
│   │   ├── request.js         # 请求封装
│   │   └── env.js             # 环境配置
│   │
│   ├── App.vue                # 应用入口
│   ├── main.js                # 入口文件
│   ├── pages.json             # 页面配置
│   └── manifest.json          # 应用配置
│
├── dist/                       # 编译输出
│   └── dev/mp-weixin/         # 微信小程序
│
└── package.json               # 依赖配置
```

### 6.3 关键配置文件位置

| 类型 | 文件路径 | 说明 |
|-----|---------|------|
| 后端主配置 | `jingwenhub/campus-modular/src/main/resources/application.yml` | 数据库、Redis、微信、Token 配置 |
| 前端环境配置 | `uniapp/src/utils/env.js` | baseUrl、mapkey |
| 前端页面配置 | `uniapp/src/pages.json` | 页面路由、tabBar 配置 |
| 前端应用配置 | `uniapp/src/manifest.json` | 小程序 AppID、权限配置 |
| Maven 配置 | `jingwenhub/pom.xml` | 依赖版本管理 |

---

## 7. 核心技术栈

### 7.1 后端技术

| 技术 | 版本 | 用途 |
|-----|------|------|
| Spring Boot | 2.5.14 | 应用框架 |
| MyBatis-Plus | 3.4.3 | ORM 框架 |
| MySQL | 8.0+ | 数据库 |
| Redis | 5.0+ | 缓存 |
| JWT | - | Token 认证 |
| Lombok | 1.18.30 | 代码简化 |
| Swagger | 3.0.0 | API 文档 |
| Hutool | 5.7.20 | 工具类库 |

### 7.2 前端技术

| 技术 | 版本 | 用途 |
|-----|------|------|
| uni-app | - | 跨平台框架 |
| Vue 3 | 3.x | 前端框架 |
| pnpm | 8.x | 包管理器 |
| Vite | - | 构建工具 |
| uni-ui | - | UI 组件库 |

---

## 8. TODO 清单

### 8.1 高优先级 🔴

- [ ] **完善用户信息编辑功能**
  - 头像上传优化
  - 字段验证加强
  
- [ ] **实现图片压缩上传**
  - 前端压缩图片大小
  - 优化上传速度
  
- [ ] **添加请求失败重试机制**
  - 网络异常自动重试
  - 超时处理优化

### 8.2 中优先级 🟡

- [ ] **优化话题列表加载性能**
  - 实现虚拟列表
  - 图片懒加载
  
- [ ] **实现下拉刷新和上拉加载**
  - 首页下拉刷新
  - 滚动加载更多
  
- [ ] **添加骨架屏 loading 效果**
  - 提升用户体验
  - 减少白屏时间

### 8.3 低优先级 🟢

- [ ] **完善错误提示文案**
  - 统一错误提示
  - 友好的错误信息
  
- [ ] **添加埋点统计**
  - 用户行为分析
  - 性能监控
  
- [ ] **优化代码注释**
  - 补充函数注释
  - 完善文档说明

### 8.4 待讨论功能 💭

- [ ] 论坛帖子功能完整迁移
- [ ] 跑腿服务系统开发
- [ ] 二手市场功能实现
- [ ] 兼职招聘模块开发

---

## 9. 重要提醒

### 9.1 开发前必读

1. ✅ **确保环境准备完整**：JDK 21、Maven、MySQL、Redis、Node.js、pnpm
2. ✅ **数据库初始化**：导入 `campus_example-1.1.7.sql` 和 `bus_tables_v1.0.sql`
3. ✅ **配置文件修改**：更新数据库密码、微信 AppID/AppSecret
4. ✅ **统一认证格式**：所有请求必须使用 `Authorization: Bearer <token>`

### 9.2 调试技巧

#### 后端调试
- 查看控制台日志
- 访问 Swagger：http://localhost:8160/swagger-ui.html
- 使用 Postman 测试接口

#### 前端调试
- 微信开发者工具 - 调试器 - Console（查看日志）
- 微信开发者工具 - 调试器 - Network（查看网络请求）
- 微信开发者工具 - 调试器 - Storage（查看本地存储）

### 9.3 常用命令速查

```bash
# 后端
redis-server --service-start          # 启动 Redis
mvn clean install -DskipTests         # 安装依赖
mvn spring-boot:run                   # 启动后端

# 前端
pnpm install                          # 安装依赖
pnpm run dev:mp-weixin               # 编译微信小程序
```

---

## 10. 参考文档

- **详细启动指南**：`启动指南.md`（800+ 行）
- **API 文档**：http://localhost:8160/swagger-ui.html
- **uni-app 官方文档**：https://uniapp.dcloud.net.cn/
- **Spring Boot 官方文档**：https://spring.io/projects/spring-boot

---

**文档更新记录**：
- 2026-01-09：创建文档，记录认证问题修复方案
- 2026-01-09：补充项目结构和技术栈说明

---

**维护者**：开发团队  
**联系方式**：[GitHub Issues](https://github.com/CompPsyUnion/NottinghamWall/issues)
