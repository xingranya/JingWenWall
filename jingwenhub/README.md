<p align="center"><a href="https://oddfar.com/" target="_blank" rel="noopener noreferrer"><img width="180" src="https://note.oddfar.com/img/web.png" alt="logo"></a></p>

<p align="center">
  <a href="https://github.com/oddfar/campus-example/stargazers"><img src="https://img.shields.io/github/stars/oddfar/campus-example.svg"></a>
	<a href="https://github.com/oddfar/campus/blob/master/LICENSE"><img src="https://img.shields.io/github/license/mashape/apistatus.svg"></a>
</p>

<h1 align="center">Jingwen Hub (荆文校园枢纽)</h1>

<p align="center">基于 SpringBoot + Vue 的校园综合信息门户系统</p>

## 📖 项目介绍

**Jingwen Hub** 是一个为高校学生打造的实时信息交流平台，涵盖了校园圈、信息墙、表白墙、万能墙等核心功能。本项目基于 [Campus](https://github.com/oddfar/campus) 快速开发框架进行构建，旨在提供一个现代化、全响应式的校园信息枢纽。

- **PC 网页端**：采用 Vue2 + ElementUI，仿微博流式布局，支持全响应式设计（适配手机、平板、电脑）。
- **移动端**：适配微信小程序、H5、Android 及 iOS（基于 uni-app + uview）。
- **后端**：基于 SpringBoot 2.5 + MyBatis-Plus，提供稳定、高效的接口支撑。

## 🛠️ 技术栈

| 领域          | 技术方案                      |
| ------------- | ----------------------------- |
| **基础框架**  | Spring Boot 2.5.14            |
| **持久层**    | MyBatis-Plus 3.5.2            |
| **数据库**    | MySQL 8.0+                    |
| **缓存**      | Redis 6.0+                    |
| **安全/校验** | Spring Security, JWT, Kaptcha |
| **工具库**    | Hutool, Fastjson2, MapStruct  |
| **前端(Web)** | Vue 2.x, ElementUI            |
| **前端(App)** | uni-app, uview-ui             |

## 📂 项目结构

```text
jingwenhub
├── campus-admin       # 后端管理模块（Controller 层）
├── campus-common      # 通用工具类与常量定义
├── campus-framework   # 核心框架配置（安全、异常处理等）
├── campus-modular     # 业务模块逻辑（Service、Mapper、Entity、入口类）
├── vue_campus_admin   # PC 管理端前端源码
├── sql                # 数据库初始化脚本
└── pom.xml            # Maven 父工程定义
```

## 🚀 快速开始

### 1. 环境准备

- JDK 1.8
- MySQL 5.7+ (推荐 8.0)
- Redis 3.0+
- Maven 3.6+
- Node.js 14+ (仅前端开发)

### 2. 后端启动

1. **导入数据库**：运行 `sql/campus_example-1.1.7.sql` 脚本。
2. **修改配置**：在 `campus-modular/src/main/resources/application-dev.yml` 中修改 MySQL 和 Redis 连接信息。
3. **运行项目**：启动 `campus-modular` 下的 `com.oddfar.campus.CampusApplication` 类。

### 3. 前端启动 (PC 端)

```bash
cd vue_campus_admin
npm install
npm run dev
```

### 4. 前端启动 (移动端/微信小程序)

1. **安装环境**：下载并安装 [HBuilderX](https://www.dcloud.io/hbuilderx.html) 和 [微信开发者工具](https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html)。
2. **导入项目**：在 HBuilderX 中选择 `文件` -> `导入` -> `从本地目录导入`，选择移动端源码文件夹。
3. **配置接口**：修改移动端源码中的配置文件（通常为 `utils/config.js` 或 `common/config.js`），将 `baseUrl` 指向你的后端接口地址（如 `http://localhost:8001`）。
4. **开启服务端口**：在**微信开发者工具**中，进入 `设置` -> `安全设置`，将 `服务端口` 开启。
5. **运行项目**：在 HBuilderX 中，点击上方菜单栏的 `运行` -> `运行到小程序模拟器` -> `微信开发者工具`。

## 📸 演示图

|                                          PC 后端管理                                          |                                           详情展示                                            |
| :-------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------: |
| ![admin1](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221090307473.png) | ![admin2](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221091209986.png) |
| ![admin3](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221091408302.png) | ![admin4](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221091331128.png) |

|                                          Web 门户                                           |                                          动态列表                                           |
| :-----------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------: |
| ![web1](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221091804015.png) | ![web2](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221091942563.png) |
| ![web3](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221092022247.png) | ![web4](https://gcore.jsdelivr.net/gh/oddfar/static/campus/doc/image-20230221092059047.png) |

## 🙏 鸣谢
