# JingWenWall 项目检查与测试清单

**生成时间**: 2026-01-16
**项目版本**: 1.1.5
**检查人员**: Claude Code

---

## 📋 快速概览

| 类别 | 状态 | 说明 |
|------|------|------|
| **后端编译** | ✅ 通过 | 313个源文件编译成功 |
| **后端测试** | ⚠️ 部分失败 | OrderStatusTest: 36个测试，10个失败 |
| **前端代码** | ✅ 良好 | 依赖正常，无语法错误 |
| **数据库脚本** | ✅ 完整 | 10个SQL脚本 |
| **配置文件** | ⚠️ 需调整 | 版本号不一致 |

**总体评估**: 🟢 **良好** - 可以运行，但建议修复列出的问题

---

## 🔴 Part 1: 编译测试 (必做)

### 1.1 后端编译测试

```bash
# 进入项目目录
cd E:\wxxcx\JingWenWall\jingwenhub

# 清理并编译
mvn clean compile

# 预期结果
✅ BUILD SUCCESS
✅ Total time: ~8s
✅ 313个源文件编译通过
```

**检查项**:
- [ ] campus-common 编译通过
- [ ] campus-framework 编译通过
- [ ] campus-admin 编译通过
- [ ] campus-modular 编译通过

**如果失败**:
- 检查 JDK 版本（需要 JDK 8+）
- 检查 Maven 配置
- 查看错误日志定位问题

---

### 1.2 后端打包测试

```bash
# 打包（跳过测试）
mvn clean package -DskipTests

# 预期结果
✅ BUILD SUCCESS
✅ 生成 jar 文件：
   - campus-common/target/campus-common-1.1.5.jar
   - campus-framework/target/campus-framework-1.1.5.jar
   - campus-admin/target/campus-admin-1.1.5.jar
   - campus-modular/target/campus-modular-1.1.5.jar
```

**检查项**:
- [ ] 所有模块打包成功
- [ ] jar 文件大小合理（通常 10-50MB）

---

### 1.3 前端编译测试

```bash
# 进入小程序目录
cd E:\wxxcx\JingWenWall\uniapp

# 安装依赖（如果需要）
pnpm install

# 编译微信小程序
pnpm build:mp-weixin

# 预期结果
✅ 编译成功，无错误
✅ 生成目录：dist/dev/mp-weixin/
```

**检查项**:
- [ ] 无编译错误
- [ ] 无 import 路径错误
- [ ] dist 目录生成成功

---

## 🟡 Part 2: 单元测试 (建议做)

### 2.1 后端单元测试

```bash
cd E:\wxxcx\JingWenWall\jingwenhub

# 运行所有测试
mvn test

# 当前状态：⚠️ 有失败
# OrderStatusTest: 36个测试，10个失败，2个错误
```

**⚠️ 需修复**: OrderStatus 状态机测试

```bash
# 单独运行 OrderStatus 测试
cd jingwenhub/campus-modular
mvn test -Dtest=OrderStatusTest

# 预期失败：
# testWaitingToAccepted - expected: <true> but was: <false>
# testAcceptedToPicking - expected: <true> but was: <false>
# ... (共10个失败)
```

**修复步骤**:

1. **检查状态机定义**:
   ```bash
   code jingwenhub/campus-modular/src/main/java/com/oddfar/campus/business/errand/domain/enums/OrderStatus.java
   ```

2. **定位问题** (第 128-141 行):
   ```java
   private enum Transition {
       ACCEPT(WAITING, ACCEPTED),     // ✅ 检查这个映射
       PICK_UP(ACCEPTED, PICKING),     // ✅ 检查这个映射
       DELIVER(PICKING, DELIVERING),   // ✅ 检查这个映射
       CONFIRM(DELIVERING, CONFIRMING), // ✅ 检查这个映射
       COMPLETE(CONFIRMING, COMPLETED), // ✅ 检查这个映射
       CANCEL(WAITING, CANCELLED);      // ✅ 检查这个映射
   ```

3. **确认 Transition 枚举定义**:
   - 每个 Transition 应该是 `(from, to)` 格式
   - 确保状态转换逻辑正确

4. **重新运行测试**:
   ```bash
   mvn test -Dtest=OrderStatusTest
   ```

**检查项**:
- [ ] 所有 36 个测试通过
- [ ] 无失败，无错误

---

## 🟢 Part 3: 功能测试 (必做)

### 3.1 后端启动测试

```bash
# 启动后端服务
cd E:\wxxcx\JingWenWall\jingwenhub\campus-modular

# 方式1: IDEA 运行
# 右键 CampusApplication.java -> Run

# 方式2: Maven 启动
mvn spring-boot:run

# 方式3: jar 启动
java -jar target/campus-modular-1.1.5.jar

# 预期结果
✅ Tomcat started on port(s): 8001 (http)
✅ Started CampusApplication in 10.5 seconds
```

**检查项**:
- [ ] 服务启动成功
- [ ] 监听端口 8001
- [ ] 无异常日志

**访问测试**:
```bash
# 测试健康检查
curl http://localhost:8001/actuator/health

# 测试 Swagger UI
浏览器访问: http://localhost:8001/swagger-ui/index.html

# 预期结果
✅ {"status":"UP"}
✅ Swagger UI 正常显示
```

---

### 3.2 数据库连接测试

**检查 application.yml 配置**:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/jingwen_campus?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: root
    password: xingran8
```

**检查项**:
- [ ] 数据库服务运行中
- [ ] 数据库 jingwen_campus 存在
- [ ] 用户名密码正确
- [ ] 后端日志无连接错误

**手动测试数据库连接**:
```bash
mysql -u root -p
use jingwen_campus;
show tables;
-- 预期：显示所有表（bus_*, sys_* 等）
```

---

### 3.3 小程序运行测试

```bash
# 1. 编译小程序
cd E:\wxxcx\JingWenWall\uniapp
pnpm dev:mp-weixin

# 2. 打开微信开发者工具
# 导入项目目录: E:\wxxcx\JingWenWall\uniapp\dist\dev\mp-weixin

# 3. 配置（如果需要）
# - 开启"不校验合法域名"
# - 设置本地设置：localhost:8001
```

**检查项**:
- [ ] 小程序编译成功
- [ ] 微信开发者工具打开项目
- [ ] 首页正常显示
- [ ] 底部导航栏显示正常

---

### 3.4 API 联调测试

**测试登录功能**:
```bash
# 1. 打开小程序登录页
路径: pages/person/getPhone

# 2. 点击"微信一键登录"
# 预期：跳转到首页

# 3. 检查本地存储
Storage: token, userInfo

# 4. 预期结果
✅ 登录成功
✅ Token 已保存
✅ 用户信息已保存
```

**测试论坛功能**:
```bash
# 1. 查看帖子列表
路径: pages/index/index

# 2. 点击帖子进入详情
路径: pages/topic/view?topicId=1

# 3. 测试点赞
预期: 点赞数 +1，图标变化

# 4. 测试收藏
预期: 收藏数 +1，图标变化

# 5. 测试评论
预期: 评论列表显示，可以发布评论
```

**测试跑腿功能**:
```bash
# 1. 查看跑腿订单
路径: pages/order/order

# 2. 发布跑腿订单
路径: pages/order/publish
填写: 标题、描述、地址、费用
预期: 订单发布成功

# 3. 测试接单
预期: 骑手可以接单
```

**测试二手市场**:
```bash
# 1. 查看商品列表
路径: pages/market/index

# 2. 发布商品
路径: pages/market/publish
填写: 标题、描述、价格、图片
预期: 商品发布成功

# 3. 测试收藏
预期: 收藏功能正常
```

---

## 🔧 Part 4: 代码质量检查 (建议做)

### 4.1 前端代码检查

**检查项**: API 调用统一性

**问题**: 发现 11 处直接使用 `uni.request`，未使用统一的 `request.js`

**影响**:
- ❌ 错误处理不统一
- ❌ Token 过期无法自动跳转
- ❌ 无法统一拦截和重试

**修复清单**:
- [ ] `api/comment.js` - 6处 (优先级最高)
- [ ] `pages/transition/agreement.vue` - 1处
- [ ] `pages/topic/view.vue` - 1处
- [ ] `pages/person/person.vue` - 1处
- [ ] `pages/topic/report.vue` - 1处
- [ ] `pages/person/authentication.vue` - 1处

**修复示例**:
```javascript
// ❌ 错误 - 直接使用 uni.request
export const fetchComments = (postId) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: `${baseUrl}/api/v1/forum/comments/post/${postId}`,
            success: (res) => resolve(res.data)
        });
    });
};

// ✅ 正确 - 使用统一封装
import { get } from '@/utils/request';
export const getPostComments = (postId, pageNum, pageSize) => {
    return get(`/api/v1/forum/comments/post/${postId}`, { pageNum, pageSize });
};
```

---

### 4.2 Console 日志清理

**问题**: 发现 31 处 console 日志残留

**保留** (合理使用):
- ✅ `utils/request.js` - 错误日志
- ✅ 测试文件中的日志

**清理清单** (调试日志):
- [ ] `pages/transition/agreement.vue` - 10处
- [ ] `pages/topic/view.vue` - 8处
- [ ] `pages/person/person.vue` - 4处
- [ ] `pages/topic/create.vue` - 5处
- [ ] `pages/person/getPhone.vue` - 1处
- [ ] 其他页面 - 3处

**清理原则**:
```javascript
// ❌ 删除 - 调试日志
console.log('请求结果:', data);
console.log('登录成功');
console.log(this.userId);

// ✅ 保留 - 错误日志
console.error('请求失败:', error);

// ✅ 保留 - 重要状态
logger.info('应用启动');
logger.warn('配置缺失');
```

---

### 4.3 版本号统一

**问题**: 版本号不一致

```
pom.xml:                 1.1.5
application.yml:         1.1.7  ⚠️ 不一致
```

**修复步骤**:
```bash
# 1. 编辑 application.yml
cd E:\wxxcx\JingWenWall\jingwenhub\campus-modular\src\main\resources
code application.yml

# 2. 修改第 6 行
campus:
  version: 1.1.5  # 从 1.1.7 改为 1.1.5

# 3. 重新编译
mvn clean compile
```

**检查项**:
- [ ] application.yml 版本改为 1.1.5
- [ ] 重新编译成功

---

## 📊 Part 5: 性能与安全检查

### 5.1 安全检查

**检查项**:
- [ ] SQL 注入防护 - 使用 MyBatis-Plus 参数绑定
- [ ] XSS 防护 - 前端输入验证
- [ ] CSRF 防护 - Token 验证
- [ ] 密码加密 - BCrypt 加密
- [ ] JWT Token - 12小时有效期
- [ ] 敏感配置 - 环境变量支持 (已实现 ✅)

**快速验证**:
```bash
# 检查 JWT 配置
grep -n "jwt" application.yml

# 检查环境变量支持
grep -n "\${DB_PASSWORD" application.yml
grep -n "\${JWT_SECRET" application.yml

# 预期结果
✅ token有效期: 720分钟 (12小时)
✅ 环境变量: DB_PASSWORD, JWT_SECRET 已配置
```

---

### 5.2 性能检查

**检查项**:
- [ ] 数据库索引 - 已执行 Phase1 & Phase2 索引
- [ ] 唯一约束 - 已执行
- [ ] 分页查询 - 已实现
- [ ] 并发安全 - 已实现分布式锁和乐观锁
- [ ] 缓存 - Redis 配置正常

**索引验证**:
```sql
-- 连接数据库
mysql -u root -p jingwen_campus

-- 检查索引
SHOW INDEX FROM bus_forum_post;
SHOW INDEX FROM bus_market_item;
SHOW INDEX FROM bus_errand_order;

-- 预期结果
✅ 有 PRIMARY KEY
✅ 有 user_id 索引
✅ 有 create_time 索引
✅ 有唯一索引（如 collect_count）
```

---

## 🚨 Part 6: 常见问题排查

### 问题1: 后端启动失败

**症状**:
```
Error creating bean with name 'dataSource'
```

**排查**:
```bash
# 1. 检查数据库是否运行
mysql -u root -p -e "SELECT 1"

# 2. 检查数据库是否存在
mysql -u root -p -e "SHOW DATABASES LIKE 'jingwen_campus'"

# 3. 检查用户权限
mysql -u root -p -e "SHOW GRANTS FOR 'root'@'localhost'"

# 4. 检查配置文件
cat application.yml | grep -A 5 "datasource"
```

---

### 问题2: 小程序请求失败

**症状**:
```
request:fail
```

**排查**:
```bash
# 1. 检查后端是否运行
curl http://localhost:8001/actuator/health

# 2. 检查配置
cat uniapp/src/utils/env.js

# 3. 确认 IP 地址
# 开发环境应该使用局域网 IP，不是 localhost
# 例如: http://192.168.0.101:8001

# 4. 微信开发者工具
# - 开启"不校验合法域名"
# - 检查网络请求是否允许
```

---

### 问题3: Token 过期问题

**症状**:
```
登录已过期，请重新登录
```

**已实现功能**:
- ✅ 自动检测 Token 过期 (401错误)
- ✅ 自动跳转登录页 (`/pages/person/getPhone`)
- ✅ 显示友好提示

**验证**:
```javascript
// 1. 手动删除 Token
uni.removeStorageSync('token')

// 2. 尝试访问需要登录的 API

// 3. 预期结果
✅ 自动跳转到登录页
✅ 显示"登录已过期"提示
```

---

## ✅ Part 7: 上线前检查清单

### 7.1 配置检查

**生产环境配置**:
- [ ] 修改 `PROD_BASE_URL` 为生产域名
  ```javascript
  // uniapp/src/utils/env.js
  export const PROD_BASE_URL = 'https://your-domain.com';
  ```

- [ ] 配置微信小程序 AppID 和 AppSecret
  ```yaml
  # application.yml
  wechat:
    mini:
      appId: your-appid        # 改为真实的 AppID
      appSecret: your-secret    # 改为真实的 AppSecret
  ```

- [ ] 设置环境变量
  ```bash
  export DB_PASSWORD=your-production-password
  export JWT_SECRET=your-production-secret
  export WECHAT_APP_SECRET=your-production-secret
  ```

---

### 7.2 数据库检查

**生产数据库**:
- [ ] 创建生产数据库
- [ ] 执行初始化脚本 `jingwen_campus.sql`
- [ ] 执行优化脚本
  - [ ] `add_indexes_phase1.sql`
  - [ ] `add_indexes_phase2.sql`
  - [ ] `add_unique_constraints.sql`
- [ ] 创建数据库备份
- [ ] 配置数据库用户权限

---

### 7.3 日志配置

**生产环境日志**:
```yaml
# application.yml
logging:
  level:
    com.oddfar.campus: info      # 生产环境设置为 info
    org.springframework: warn
  file:
    name: /var/log/campus/application.log
    max-size: 100MB
    max-history: 30
```

**检查项**:
- [ ] 日志路径可写
- [ ] 日志级别合适
- [ ] 日志轮转配置正确

---

### 7.4 安全检查

**生产环境安全**:
- [ ] 修改默认密码
- [ ] 配置防火墙
- [ ] 启用 HTTPS
- [ ] 配置 CORS 白名单
- [ ] 关闭 Swagger UI (生产环境)
  ```yaml
  # application.yml
  swagger:
    enabled: false  # 生产环境设置为 false
  ```

---

## 📝 Part 8: 测试报告模板

### 测试记录表

| 测试项 | 测试时间 | 测试人 | 结果 | 备注 |
|--------|---------|--------|------|------|
| 后端编译 | 2026-01-16 | | ✅ 通过 | |
| 后端单元测试 | 2026-01-16 | | ⚠️ 失败 | OrderStatusTest: 10个失败 |
| 前端编译 | 2026-01-16 | | ✅ 通过 | |
| 后端启动 | 2026-01-16 | | | 待测试 |
| 小程序运行 | 2026-01-16 | | | 待测试 |
| API 联调 | 2026-01-16 | | | 待测试 |
| 登录功能 | 2026-01-16 | | | 待测试 |
| 论坛功能 | 2026-01-16 | | | 待测试 |
| 跑腿功能 | 2026-01-16 | | | 待测试 |
| 二手市场 | 2026-01-16 | | | 待测试 |

---

## 🎯 Part 9: 快速测试命令

### 后端快速测试

```bash
# 1. 编译
mvn clean compile

# 2. 运行测试
mvn test

# 3. 启动服务
mvn spring-boot:run

# 4. 健康检查
curl http://localhost:8001/actuator/health
```

### 前端快速测试

```bash
# 1. 安装依赖
pnpm install

# 2. 编译
pnpm dev:mp-weixin

# 3. 打开微信开发者工具
# 导入: E:\wxxcx\JingWenWall\uniapp\dist\dev\mp-weixin
```

### 数据库快速测试

```bash
# 连接数据库
mysql -u root -p jingwen_campus

# 检查表
SHOW TABLES;

# 检查数据
SELECT COUNT(*) FROM bus_forum_post;
SELECT COUNT(*) FROM bus_market_item;
SELECT COUNT(*) FROM bus_errand_order;
```

---

## 📚 Part 10: 参考文档

### 项目文档

- [修复完成记录](./FIXES_COMPLETED.md) - 所有已完成的修复
- [Phase 2 进度报告](./phase2-progress-report.md) - 并发安全与数据修复
- [API 文档](http://localhost:8001/swagger-ui/index.html) - Swagger UI
- [数据库脚本](../jingwenhub/sql/) - SQL 脚本目录

### 快速链接

- **后端端口**: http://localhost:8001
- **Swagger UI**: http://localhost:8001/swagger-ui/index.html
- **健康检查**: http://localhost:8001/actuator/health
- **小程序目录**: `E:\wxxcx\JingWenWall\uniapp\dist\dev\mp-weixin`

---

## 🏁 总结

### 必做测试 (5分钟)
1. ✅ 后端编译 - `mvn clean compile`
2. ✅ 前端编译 - `pnpm dev:mp-weixin`
3. ✅ 后端启动 - `mvn spring-boot:run`
4. ✅ 小程序运行 - 微信开发者工具
5. ✅ API 联调 - 登录 + 查看 + 发布

### 建议修复 (3小时)
1. ⚠️ OrderStatus 测试修复 (30分钟)
2. ⚠️ 前端 API 统一化 (2小时)
3. ⚠️ 版本号统一 (5分钟)
4. ⚠️ Console 日志清理 (1小时)

### 上线前检查 (1小时)
1. 🔴 生产配置修改
2. 🔴 数据库初始化
3. 🔴 安全检查
4. 🔴 日志配置

---

**清单版本**: v1.0
**最后更新**: 2026-01-16
**下次检查**: 上线前
