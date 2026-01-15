# Phase 1.4 & 1.5: Spring Boot 和 Fastjson2 升级方案

## 一、当前版本分析

### 当前依赖版本

```xml
<!-- Spring Boot -->
<spring.boot.version>2.5.14</spring.boot.version>  <!-- ❌ 2022年1月发布，已过时 -->

<!-- Fastjson2 -->
<fastjson.version>2.0.14</fastjson.version>  <!-- ⚠️ 2022年版本，建议升级 -->

<!-- JWT -->
<jwt.version>0.11.5</jwt.version>  <!-- ✅ 当前较新 -->

<!-- MyBatis-Plus -->
<mybatis.plus.boot.version>3.5.2</mybatis.plus.boot.version>  <!-- ✅ 可用 -->

<!-- PageHelper -->
<pagehelper.boot.version>1.4.3</pagehelper.boot.version>  <!-- ⚠️ 需检查兼容性 -->
```

### 安全风险分析

#### Spring Boot 2.5.14 已知漏洞

| CVE ID | 严重程度 | 描述 |
|--------|---------|------|
| CVE-2022-22965 | 🔴 高 | Spring Framework 远程代码执行漏洞（Spring4Shell） |
| CVE-2022-22976 | 🟡 中 | JWT 认证绕过漏洞 |
| 多个DoS漏洞 | 🟡 中 | 拒绝服务漏洞 |

**影响**：攻击者可能远程执行代码，完全控制服务器

#### Fastjson2 2.0.14

Fastjson2 已修复早期版本的多数反序列化漏洞，但仍有更新版本提供更好的性能和安全性。

---

## 二、升级方案

### 方案A：保守升级（推荐）

**目标版本**：
- Spring Boot: `2.5.14` → `2.7.18`（LTS版本，支持到2025年8月）
- Fastjson2: `2.0.14` → `2.0.43`（最新2.0.x稳定版）

**理由**：
- 同属2.x系列，升级风险低
- 修复了所有已知安全漏洞
- 兼容性好，无需修改代码
- 2.7.18是长期支持版本

### 方案B：激进升级

**目标版本**：
- Spring Boot: `2.5.14` → `3.2.0`（最新3.x版本）

**不推荐理由**：
- 跨越大版本，需要修改大量代码
- Jakarta EE命名空间变更（javax.* → jakarta.*）
- Java版本要求：JDK 17+
- 升级成本高，风险大

---

## 三、详细升级步骤（方案A）

### Step 1: 备份当前代码

```bash
# 创建备份分支
git checkout -b backup/before-upgrade
git push origin backup/before-upgrade

# 创建升级分支
git checkout main
git checkout -b upgrade/dependencies-2.7.18
```

### Step 2: 修改 pom.xml

**文件**：`jingwenhub/pom.xml`

```xml
<properties>
    <campus.version>1.1.5</campus.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <java.version>1.8</java.version>

    <!-- 升级 Spring Boot -->
    <spring.boot.version>2.7.18</spring.boot.version>  <!-- 2.5.14 → 2.7.18 -->

    <!-- 升级 Fastjson2 -->
    <fastjson.version>2.0.43</fastjson.version>  <!-- 2.0.14 → 2.0.43 -->

    <!-- 升级其他依赖 -->
    <bitwalker.version>1.21</bitwalker.version>
    <mybatis.plus.boot.version>3.5.5</mybatis.plus.boot.version>  <!-- 3.5.2 → 3.5.5 -->
    <swagger.version>3.0.0</swagger.version>
    <hutool.version>5.8.25</hutool.version>  <!-- 5.8.8 → 5.8.25 -->
    <commons.fileupload.version>1.5</commons.fileupload.version>  <!-- 1.4 → 1.5 -->
    <mapstruct.version>1.5.5.Final</mapstruct.version>  <!-- 1.5.3 → 1.5.5 -->
    <kaptcha.version>2.3.3</kaptcha.version>  <!-- 2.3.2 → 2.3.3 -->
    <jwt.version>0.12.3</jwt.version>  <!-- 0.11.5 → 0.12.3 -->
    <poi.version>5.2.5</poi.version>  <!-- 4.1.2 → 5.2.5 -->
    <pagehelper.boot.version>1.4.7</pagehelper.boot.version>  <!-- 1.4.3 → 1.4.7 -->
    <sunmail.version>2.0.1</sunmail.version>  <!-- 1.6.2 → 2.0.1 -->
    <lombok.version>1.18.30</lombok.version>
    <jaxb.version>2.3.1</jaxb.version>
</properties>
```

### Step 3: 更新 Spring Boot 依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>${spring.boot.version}</version>  <!-- 使用变量 -->
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

### Step 4: 清理并重新构建

```bash
cd jingwenhub

# 清理旧的构建产物
mvn clean

# 下载新依赖
mvn dependency:resolve

# 构建项目
mvn clean package -DskipTests
```

### Step 5: 解决兼容性问题（如果出现）

#### 可能的问题1：PageHelper不兼容

**错误**：
```
java.lang.ClassNotFoundException: com.github.pagehelper.PageHelper
```

**解决**：已通过升级到1.4.7解决

#### 可能的问题2：MyBatis-Plus兼容性

**错误**：
```
java.lang.NoSuchMethodError: com.baomidou.mybatisplus...
```

**解决**：已通过升级到3.5.5解决

#### 可能的问题3：Swagger路径变更

**变化**：Spring Boot 2.6+ 默认路径匹配策略变更

**解决**：在 `application.yml` 中添加：

```yaml
spring:
  mvc:
    pathmatch:
      matching-strategy: ant_path_matcher
```

#### 可能的问题4：循环依赖检测

**错误**：
```
┌─────┐
|  A
|     ^
└─────┘
```

**解决**：
```yaml
spring:
  main:
    allow-circular-references: true  # 临时允许
```

**长期方案**：重构代码消除循环依赖

### Step 6: 运行测试

```bash
# 运行单元测试
mvn test

# 运行集成测试（如果有）
mvn verify
```

### Step 7: 启动验证

```bash
# 启动后端服务
java -jar campus-modular/target/campus-modular-1.1.5.jar

# 检查启动日志
# - 确认没有ERROR
# - 确认Spring Boot版本显示为2.7.18
# - 确认所有Bean成功加载

# 访问Swagger
# http://localhost:8001/swagger-ui/index.html
```

### Step 8: 功能测试清单

- [ ] 用户登录/登出
- [ ] JWT Token验证
- [ ] 论坛帖子CRUD
- [ ] 文件上传/下载
- [ ] 二手市场功能
- [ ] 跑腿服务功能
- [ ] 举报功能
- [ ] 管理后台功能

### Step 9: 性能测试

```bash
# 使用JMeter或wrk进行压力测试
wrk -t12 -c400 -d30s http://localhost:8001/api/v1/forum/posts
```

对比升级前后的性能指标

---

## 四、升级检查清单

### 升级前

- [ ] 代码已备份
- [ ] 当前功能测试通过
- [ ] 数据库已备份
- [ ] 记录当前性能指标

### 升级中

- [ ] 修改pom.xml版本号
- [ ] 执行 `mvn clean package` 成功
- [ ] 解决所有编译错误
- [ ] 运行测试通过

### 升级后

- [ ] 应用启动成功
- [ ] Swagger可访问
- [ ] 所有功能测试通过
- [ ] 性能测试通过
- [ ] 日志中无ERROR
- [ ] 监控指标正常

---

## 五、回滚方案

### 如果升级失败

**回滚步骤**：

```bash
# 切换回备份分支
git checkout backup/before-upgrade

# 或者恢复主分支
git reset --hard HEAD~1  # 撤销最后一次提交

# 重新构建
mvn clean package -DskipTests

# 重新部署
# ... 执行你的部署流程
```

### 快速回滚命令

```bash
# 修改pom.xml回到原版本
git checkout jingwenhub/pom.xml

# 重新构建
mvn clean package -DskipTests
```

---

## 六、预期收益

### 安全性提升

- ✅ 修复Spring4Shell漏洞（CVE-2022-22965）
- ✅ 修复JWT认证绕过漏洞（CVE-2022-22976）
- ✅ 修复多个DoS漏洞
- ✅ Fastjson2性能和安全性提升

### 功能改进

- ✅ Spring Boot 2.7.18的性能优化
- ✅ 更好的可观测性（Micrometer支持）
- ✅ 依赖库bug修复

### 长期支持

- ✅ 2.7.18是LTS版本，支持到2025年8月
- ✅ 有充足的时间规划迁移到Spring Boot 3.x

---

## 七、升级时间估算

| 任务 | 预计时间 | 风险 |
|------|---------|------|
| 修改pom.xml | 30分钟 | 低 |
| 构建项目 | 15分钟 | 低 |
| 解决编译问题 | 1-2小时 | 中 |
| 运行测试 | 1小时 | 低 |
| 功能测试 | 2-4小时 | 中 |
| **总计** | **5-8小时** | **中** |

---

## 八、升级后待办事项

1. ✅ 更新 `README.md` 中的Spring Boot版本说明
2. ✅ 更新 `CLAUDE.md` 中的依赖版本
3. ✅ 通知团队升级信息
4. ✅ 规划下一次升级（Spring Boot 3.x）
5. ⚠️ 监控生产环境1周，关注性能和稳定性

---

## 九、参考文档

- [Spring Boot 2.7.18 Release Notes](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.7-Release-Notes)
- [Spring Boot 2.7 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.5-Release-Notes)
- [Fastjson2 GitHub](https://github.com/alibaba/fastjson2)
- [MyBatis-Plus兼容性说明](https://baomidou.com/pages/6c601f/)

---

**准备就绪后，请告知，我将帮你执行升级操作。**
