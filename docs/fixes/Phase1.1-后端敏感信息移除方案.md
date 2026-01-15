# Phase 1.1: 后端敏感信息移除方案

## 发现的硬编码敏感信息

### 1. 数据库密码（第22行）
```yaml
spring:
  datasource:
    password: xingran8  # ❌ 硬编码
```

### 2. JWT密钥（第60行）
```yaml
token:
  secret: abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz
  # ❌ 硬编码，且密钥强度不足
```

### 3. 微信小程序配置（第106-108行）
```yaml
wechat:
  mini:
    appId: wxc56334f1f425a05f      # ❌ 硬编码
    appSecret: c5e4a048b701be66b35ac4e1e8d4b075  # ❌ 硬编码
```

## 改进方案

### 方案1：使用环境变量（推荐）

创建新的配置文件 `application-prod.yml`，使用环境变量占位符：

```yaml
spring:
  datasource:
    url: ${DB_URL:jdbc:mysql://localhost:3306/jingwen_campus?characterEncoding=utf-8&useSSL=true&serverTimezone=GMT%2B8}
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:}  # 生产环境必须通过环境变量设置

token:
  secret: ${JWT_SECRET:}  # 生产环境必须通过环境变量设置，至少64字符

wechat:
  mini:
    appId: ${WECHAT_MINI_APPID:}
    appSecret: ${WECHAT_MINI_SECRET:}  # 生产环境必须通过环境变量设置
```

### 方案2：使用外部配置文件

创建 `application-local.yml`（不提交到git）：
```yaml
spring:
  datasource:
    password: your-local-password

token:
  secret: your-local-jwt-secret

wechat:
  mini:
    appId: your-local-appid
    appSecret: your-local-secret
```

更新 `.gitignore`：
```gitignore
# 敏感配置文件（本地开发）
application-local.yml
application-local-prod.yml
```

## 推荐步骤

### Step 1: 修改 application.yml

将敏感配置改为环境变量：

```yaml
spring:
  datasource:
    url: ${DB_URL:jdbc:mysql://localhost:3306/jingwen_campus?characterEncoding=utf-8&useSSL=true&serverTimezone=GMT%2B8}
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:xingran8}  # 开发环境默认值

token:
  secret: ${JWT_SECRET:abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz}

wechat:
  mini:
    appId: ${WECHAT_MINI_APPID:wxc56334f1f425a05f}
    appSecret: ${WECHAT_MINI_SECRET:c5e4a048b701be66b35ac4e1e8d4b075}
```

### Step 2: 创建 .gitignore 规则

确保敏感文件不会被提交：

```gitignore
# 本地敏感配置
application-local.yml
application-local-prod.yml
*.env
.env.local
```

### Step 3: 创建配置示例文件

创建 `application-local-example.yml`（提交到git）：

```yaml
# 本地开发配置示例
# 复制此文件为 application-local.yml 并填入实际值

spring:
  datasource:
    password: your-database-password

token:
  secret: your-jwt-secret-at-least-64-characters

wechat:
  mini:
    appId: your-wechat-mini-appid
    appSecret: your-wechat-mini-secret
```

### Step 4: 生产环境部署

使用环境变量或外部配置文件：

**方式1：环境变量**
```bash
export DB_PASSWORD=your-prod-password
export JWT_SECRET=your-prod-jwt-secret
export WECHAT_MINI_APPID=your-prod-appid
export WECHAT_MINI_SECRET=your-prod-secret
java -jar campus-modular.jar
```

**方式2：启动参数**
```bash
java -jar campus-modular.jar \
  --spring.datasource.password=your-prod-password \
  --token.secret=your-prod-jwt-secret \
  --wechat.mini.appId=your-prod-appid \
  --wechat.mini.appSecret=your-prod-secret
```

### Step 5: 生成安全的JWT密钥

使用以下命令生成强密钥：

```bash
# 生成64字符的随机密钥
openssl rand -base64 48
```

## 安全检查清单

- [ ] application.yml 中的敏感信息已替换为环境变量
- [ ] .gitignore 已更新，防止敏感文件泄露
- [ ] application-local-example.yml 已创建
- [ ] 生产环境使用强密钥（至少64字符）
- [ ] 开发团队已更新配置文档
- [ ] CI/CD流程中配置了环境变量

## 预期收益

1. **安全性提升**：敏感信息不再硬编码在代码中
2. **灵活性提升**：不同环境可使用不同配置
3. **合规性提升**：符合安全最佳实践
4. **风险降低**：即使代码泄露也不会暴露生产密钥

## 下一步

完成上述步骤后，继续处理：
- Phase 1.2: 前端小程序敏感信息移除
- Phase 1.3: 管理后台敏感信息移除
