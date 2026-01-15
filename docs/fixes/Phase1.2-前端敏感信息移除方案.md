# Phase 1.2 & 1.3: 前端敏感信息移除方案

## 一、小程序端（uni-app）

### 发现的硬编码敏感信息

**文件**：`uniapp/src/utils/env.js`

```javascript
// 问题1：硬编码的局域网IP
const DEV_BASE_URL = 'http://192.168.0.101:8001'

// 问题2：硬编码的腾讯地图Key
const mapkey = 'RSNBZ-3ABW4-MF3UK-FMCJP-JC4YT-RUFTR'

// 问题3：生产环境域名未配置
const PROD_BASE_URL = 'https://your-production-domain.com'
```

### 安全风险

1. **内网IP泄露**：暴露了开发者内网结构
2. **腾讯地图Key泄露**：可能被滥用产生费用
3. **配置不灵活**：每个开发者需要修改源码

### 改进方案

#### 方案1：使用环境变量文件（推荐）

创建 `uniapp/.env.development`：
```ini
# 开发环境配置
# 后端服务地址（每个开发者用自己的局域网IP）
VUE_APP_BASE_URL=http://192.168.0.101:8001

# 腾讯地图Key
VUE_APP_TENCENT_MAP_KEY=RSNBZ-3ABW4-MF3UK-FMCJP-JC4YT-RUFTR
```

创建 `uniapp/.env.production`：
```ini
# 生产环境配置
VUE_APP_BASE_URL=https://your-production-domain.com
VUE_APP_TENCENT_MAP_KEY=your-production-map-key
```

创建 `uniapp/.env.local.example`（示例文件）：
```ini
# 本地开发配置示例
# 复制此文件为 .env.local 并填入实际值

VUE_APP_BASE_URL=http://192.168.x.x:8001
VUE_APP_TENCENT_MAP_KEY=your-tencent-map-key
```

修改 `uniapp/src/utils/env.js`：
```javascript
/**
 * 环境配置文件
 * 从环境变量读取配置
 */

const baseUrl = process.env.VUE_APP_BASE_URL || 'http://localhost:8001'
const mapkey = process.env.VUE_APP_TENCENT_MAP_KEY || ''

export { baseUrl, mapkey }
```

更新 `uniapp/.gitignore`：
```gitignore
# 本地环境配置
.env.local
.env.local.*.local
```

#### 方案2：使用配置文件

创建 `uniapp/src/config/index.js`：
```javascript
/**
 * 配置文件
 * 从不同环境的配置文件读取
 */

let config = {}

if (process.env.NODE_ENV === 'development') {
  config = require('./config.development')
} else if (process.env.NODE_ENV === 'production') {
  config = require('./config.production')
}

export default config
```

创建 `uniapp/src/config.development.js`：
```javascript
module.exports = {
  baseUrl: 'http://192.168.0.101:8001',
  mapkey: 'RSNBZ-3ABW4-MF3UK-FMCJP-JC4YT-RUFTR'
}
```

创建 `uniapp/src/config.production.js`：
```javascript
module.exports = {
  baseUrl: 'https://your-production-domain.com',
  mapkey: 'your-production-map-key'
}
```

创建 `uniapp/src/config.example.js`（示例）：
```javascript
module.exports = {
  baseUrl: 'http://192.168.x.x:8001',  // 修改为你的局域网IP
  mapkey: 'your-tencent-map-key'       // 修改为你的地图Key
}
```

### 使用说明

#### 开发者配置步骤

1. 复制配置示例：
```bash
cp uniapp/.env.local.example uniapp/.env.local
# 或
cp uniapp/src/config.example.js uniapp/src/config.development.js
```

2. 修改为自己的配置：
```bash
# .env.local
VUE_APP_BASE_URL=http://192.168.1.100:8001
VUE_APP_TENCENT_MAP_KEY=your-own-map-key
```

3. 启动开发服务器：
```bash
pnpm dev:mp-weixin
```

---

## 二、管理后台（Vue2）

### 当前配置检查

**文件**：`jingwenhub/vue_campus_admin/.env.development`
```ini
VUE_APP_TITLE = campus
VUE_APP_BASE_API = '/dev-api'
```

**文件**：`jingwenhub/vue_campus_admin/.env.production`
```ini
VUE_APP_TITLE = campus
VUE_APP_BASE_API = '/prod-api'
```

### 评估结论

✅ **管理后台配置较安全**

- 没有硬编码敏感信息
- 使用了环境变量文件
- 通过代理转发API请求（见 vue.config.js）

### 小建议

可以在 `vue_campus_admin/.env.development` 中添加更多配置：

```ini
# 页面标题
VUE_APP_TITLE = 荆文校园枢纽管理系统

# 开发环境配置
ENV = 'development'

# 后端API地址（通过vue.config.js代理）
VUE_APP_BASE_API = '/dev-api'

# 其他配置
VUE_APP_UPLOAD_URL = '/profile/upload'
VUE_APP_EXPORT_URL = '/system/export'
```

---

## 三、安全最佳实践

### 1. 敏感Key管理建议

**腾讯地图Key**：
- 创建项目专用Key
- 设置IP白名单/域名白名单
- 设置每日调用限额
- 定期检查使用量

**微信小程序密钥**：
- 后端配置已通过环境变量管理
- 定期更换密钥

### 2. .gitignore 更新

确保以下文件不会被提交：

```gitignore
# 环境变量文件
.env.local
.env.local.*.local
*.local

# 配置文件
config.local.js
config.development.local.js
```

### 3. 团队协作

**方案A：配置文档**（推荐小型团队）

创建 `docs/配置指南.md`：
```markdown
# 环境配置指南

## 开发环境配置

1. 复制 `uniapp/.env.local.example` 为 `uniapp/.env.local`
2. 修改以下配置：
   - `VUE_APP_BASE_URL`: 你的局域网IP
   - `VUE_APP_TENCENT_MAP_KEY`: 你的地图Key

3. 复制 `jingwenhub/application-local-example.yml` 为 `jingwenhub/application-local.yml`
4. 修改数据库密码等敏感信息
```

**方案B：配置中心**（推荐中大型团队）

- 使用 Nacos 配置中心
- 不同环境自动加载配置
- 支持配置热更新

### 4. CI/CD 配置

在 CI/CD 流程中注入环境变量：

**GitLab CI 示例**：
```yaml
deploy:prod:
  script:
    - export VUE_APP_BASE_URL=$PROD_API_URL
    - export VUE_APP_TENCENT_MAP_KEY=$PROD_MAP_KEY
    - pnpm build:mp-weixin
  variables:
    PROD_API_URL: https://api.example.com
    PROD_MAP_KEY: $PROD_MAP_KEY  # 从CI/CD变量中读取
```

---

## 四、执行步骤

### Step 1: 更新小程序配置（立即执行）

1. 创建 `uniapp/.env.development`
2. 创建 `uniapp/.env.production`
3. 创建 `uniapp/.env.local.example`
4. 修改 `uniapp/src/utils/env.js`
5. 更新 `uniapp/.gitignore`

### Step 2: 验证管理后台配置（检查）

✅ 已验证，配置安全，无需修改

### Step 3: 团队通知

通知开发团队配置变更：
- 新的配置方式
- 本地开发配置步骤
- 提交代码前检查清单

### Step 4: 安全检查

- [ ] 所有敏感信息已从代码中移除
- [ ] .gitignore 已更新
- [ ] 配置示例文件已创建
- [ ] 团队已收到通知
- [ ] CI/CD 已配置环境变量

---

## 五、预期收益

1. **安全性**：敏感信息不再硬编码
2. **灵活性**：不同环境使用不同配置
3. **协作性**：团队成员可以独立配置本地环境
4. **专业性**：符合前端工程化最佳实践

## 六、下一步

完成前端配置后，继续：
- Phase 1.4: 升级Spring Boot版本
- Phase 1.5: 升级Fastjson2版本
