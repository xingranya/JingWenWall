# 环境变量配置说明

本文档说明如何配置生产环境的环境变量，以提高系统安全性。

## 敏感配置清单

以下配置已支持环境变量覆盖，默认值仅用于开发环境：

### 1. 数据库密码
- **环境变量**: `DB_PASSWORD`
- **默认值**: `xingran8`
- **生产环境**: 必须设置为强密码

### 2. JWT令牌密钥
- **环境变量**: `JWT_SECRET`
- **默认值**: `abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz`
- **生产环境**: **必须设置为强随机密钥** (至少64字符)

### 3. 微信小程序AppSecret
- **环境变量**: `WECHAT_APP_SECRET`
- **默认值**: `c5e4a048b701be66b35ac4e1e8d4b075`
- **生产环境**: 必须设置为实际的微信小程序AppSecret

## 配置方式

### Windows (PowerShell)
```powershell
# 临时设置 (当前会话)
$env:DB_PASSWORD = "你的强密码"
$env:JWT_SECRET = "生成的强随机密钥(至少64字符)"
$env:WECHAT_APP_SECRET = "你的微信AppSecret"

# 永久设置 (系统环境变量)
[System.Environment]::SetEnvironmentVariable("DB_PASSWORD", "你的强密码", "Machine")
[System.Environment]::SetEnvironmentVariable("JWT_SECRET", "生成的强随机密钥", "Machine")
[System.Environment]::SetEnvironmentVariable("WECHAT_APP_SECRET", "你的微信AppSecret", "Machine")
```

### Windows (CMD)
```cmd
REM 临时设置 (当前会话)
set DB_PASSWORD=你的强密码
set JWT_SECRET=生成的强随机密钥
set WECHAT_APP_SECRET=你的微信AppSecret

REM 永久设置 (需要管理员权限)
setx DB_PASSWORD "你的强密码" /M
setx JWT_SECRET "生成的强随机密钥" /M
setx WECHAT_APP_SECRET "你的微信AppSecret" /M
```

### Linux/macOS
```bash
# 临时设置 (当前会话)
export DB_PASSWORD="你的强密码"
export JWT_SECRET="生成的强随机密钥"
export WECHAT_APP_SECRET="你的微信AppSecret"

# 永久设置 (添加到 ~/.bashrc 或 ~/.zshrc)
echo 'export DB_PASSWORD="你的强密码"' >> ~/.bashrc
echo 'export JWT_SECRET="生成的强随机密钥"' >> ~/.bashrc
echo 'export WECHAT_APP_SECRET="你的微信AppSecret"' >> ~/.bashrc

source ~/.bashrc
```

### Docker / Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  campus-backend:
    image: jingwen/campus:latest
    environment:
      - DB_PASSWORD=你的强密码
      - JWT_SECRET=生成的强随机密钥
      - WECHAT_APP_SECRET=你的微信AppSecret
    ports:
      - "8001:8001"
```

### Kubernetes ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: campus-env
data:
  DB_PASSWORD: 你的强密码
  JWT_SECRET: 生成的强随机密钥
  WECHAT_APP_SECRET: 你的微信AppSecret
---
apiVersion: v1
kind: Secret
metadata:
  name: campus-secret
type: Opaque
stringData:
  DB_PASSWORD: 你的强密码
  JWT_SECRET: 生成的强随机密钥
  WECHAT_APP_SECRET: 你的微信AppSecret
```

## 生成强随机密钥

### 使用 OpenSSL (推荐)
```bash
# 生成128字符的强随机密钥
openssl rand -base64 96 | tr -d '\n='
```

### 使用 Python
```python
import secrets
# 生成128字符的强随机密钥
print(secrets.token_urlsafe(96))
```

### 使用 Java
```java
import java.security.SecureRandom;
import java.util.Base64;

// 生成128字符的强随机密钥
SecureRandom random = new SecureRandom();
byte[] key = new byte[96];
random.nextBytes(key);
String secretKey = Base64.getUrlEncoder().withoutPadding().encodeToString(key);
System.out.println(secretKey);
```

### 在线工具
访问: https://www.random.org/strings/

## 安全建议

1. **JWT_SECRET**:
   - 至少64字符 (推荐128字符)
   - 使用强随机生成器
   - 定期轮换 (建议每6个月)
   - 不要在代码中硬编码
   - 不要提交到版本控制系统

2. **DB_PASSWORD**:
   - 至少16字符
   - 包含大小写字母、数字、特殊符号
   - 定期轮换 (建议每3个月)

3. **WECHAT_APP_SECRET**:
   - 直接使用微信官方提供的值
   - 不要泄露给第三方
   - 如果泄露,立即在微信后台重置

## 验证配置

启动应用后，检查日志确认环境变量已生效：

```bash
# 查看启动日志
tail -f logs/campus.log | grep -E "password|secret|appSecret"

# 或在测试接口中验证
curl http://localhost:8001/api/v1/wx/auth/login
```

## 故障排查

### 环境变量未生效
1. 确认环境变量名称拼写正确 (区分大小写)
2. Windows系统需要重启应用才能读取新的系统环境变量
3. 检查 `.env` 文件是否覆盖了环境变量

### JWT验证失败
1. 确认 JWT_SECRET 长度至少64字符
2. 检查是否有多余的空格或换行符
3. 清除客户端缓存的旧Token

### 数据库连接失败
1. 确认 DB_PASSWORD 正确
2. 检查数据库服务是否运行
3. 验证数据库用户权限

## 更多信息

- Spring Boot环境变量文档: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config
- JWT最佳实践: https://tools.ietf.org/html/rfc8725
- 微信小程序安全指南: https://developers.weixin.qq.com/miniprogram/dev/framework/security/

---

**最后更新**: 2026-01-16
**维护者**: JingWenWall Team
