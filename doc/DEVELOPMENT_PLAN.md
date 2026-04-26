# LoggerKit 成熟化开发计划

> 版本目标：v1.1.0
> 主题：架构升级、命名空间隔离、Builder 模式
> 原则：保持轻量化、向后兼容

## 目录

- [一、版本目标](#一版本目标)
- [二、任务分解](#二任务分解)
- [三、技术方案](#三技术方案)
- [四、里程碑](#四里程碑)
- [五、测试计划](#五测试计划)
- [六、文档更新](#六文档更新)

---

## 一、版本目标

### 1.1 核心目标

| 目标 | 描述 | 优先级 |
|------|------|--------|
| Builder 模式 | 链式 API 配置 | P0 |
| 命名空间隔离 | 按模块管理日志 | P0 |
| 中间件/拦截器 | 统一日志增强 | P1 |
| 结构化上下文 | context 字段支持 | P1 |

### 1.2 约束条件

- **向后兼容**：v1.x API 继续支持
- **依赖不增**：核心仍为 0 依赖
- **性能无损**：日志写入延迟 < 1ms
- **Flutter 3.3+**：继续兼容

---

## 二、任务分解

### Phase 1: 核心架构重构

#### Task 1.1: LoggerBuilder 实现

```
文件：lib/src/core/logger_builder.dart（新增）

内容：
- LoggerBuilder 类
- 链式配置方法
- build() 工厂方法

方法：
LoggerBuilder()
  ..minLevel(LogLevel)
  ..console(bool)
  ..file({path, maxSize, maxCount})
  ..remote({url, batchSize, interval})
  ..context(LogContext)
  ..privacyFields(List<String>)
  ..build()
```

#### Task 1.2: LoggerManager 实现

```
文件：lib/src/core/logger_manager.dart（新增）

内容：
- 命名空间注册表
- getNamespace(name) 方法
- presetNamespaces 预设

API：
LoggerKit.namespace('network')  // 获取命名空间 logger
LoggerKit.network               // 预设快捷方式
```

#### Task 1.3: LogInterceptor 接口

```
文件：lib/src/interceptors/log_interceptor.dart（新增）

内容：
- LogInterceptor 抽象类
- intercept(record) 方法
- order 属性（执行顺序）

内置拦截器：
- ContextInterceptor：注入上下文
- PrivacyInterceptor：隐私过滤
- TimingInterceptor：性能监控
```

#### Task 1.4: LogContext 结构

```
文件：lib/src/models/log_context.dart（新增）

字段：
- String? userId
- String? sessionId  
- String? traceId
- String? deviceId
- Map<String, dynamic> custom

方法：
- set(key, value)
- get(key)
- clear()
- toMap()
```

### Phase 2: 功能增强

#### Task 2.1: ConsoleWriter 完善

```
文件：lib/src/writers/console_writer.dart（新增）

功能：
- 重构 ConsoleWriter
- 支持多级颜色
- 支持输出流选择（stdout/stderr）
```

#### Task 2.2: PrivacyInterceptor 实现

```
文件：lib/src/interceptors/privacy_interceptor.dart（新增）

功能：
- 默认隐私字段列表
- 递归过滤 Map
- 自定义字段扩展

默认过滤：
['password', 'token', 'secret', 'apiKey', 'authorization', 'creditCard', 'ssn']
```

#### Task 2.3: ContextInterceptor 实现

```
文件：lib/src/interceptors/context_interceptor.dart（新增）

功能：
- 自动注入 LogContext
- 支持运行时更新
- 线程/isolate 安全
```

### Phase 3: API 演进

#### Task 3.1: LoggerKit.init() 兼容

```
保持现有 API：
LoggerKit.init(
  minLevel: LogLevel.debug,
  enableConsole: true,
  filePath: './logs',
);

内部转换为 Builder 模式
```

#### Task 3.2: LoggerKit.builder() 新 API

```
新 API：
LoggerKit.builder()
  ..minLevel(LogLevel.info)
  ..console()
  ..file(path: './logs')
  ..context(LogContext(userId: '123'))
  ..build()
```

#### Task 3.3: 命名空间 API

```
// 获取命名空间
final networkLogger = LoggerKit.namespace('network');

// 预设命名空间
LoggerKit.network.i('API called');
LoggerKit.database.d('Query executed');
LoggerKit.ui.d('Screen rendered');

// 注册预设
LoggerKit.registerNamespace('network', config: LogConfig(...));
```

### Phase 4: 测试覆盖

#### Task 4.1: 单元测试

```
test/
├── logger_builder_test.dart      # Builder 测试
├── logger_manager_test.dart       # 命名空间测试
├── log_context_test.dart          # 上下文测试
├── privacy_interceptor_test.dart  # 隐私过滤测试
└── context_interceptor_test.dart  # 上下文注入测试
```

#### Task 4.2: 集成测试

```
test/
├── integration/
│   ├── namespace_isolation_test.dart
│   ├── interceptor_chain_test.dart
│   └── backward_compat_test.dart  # 向后兼容
```

#### Task 4.3: 性能测试

```
benchmark/
├── logger_kit_benchmark.dart      # 现有
├── builder_benchmark.dart         # 新增
└── interceptor_benchmark.dart     # 新增
```

### Phase 5: 文档更新

#### Task 5.1: API 文档更新

```
doc/
├── API.md              # 更新
├── ARCHITECTURE.md      # 更新
└── USAGE_GUIDE.md       # 更新
```

#### Task 5.2: 新功能文档

```
doc/
├── BUILDER_GUIDE.md     # 新增
├── NAMESPACE_GUIDE.md   # 新增
├── INTERCEPTOR_GUIDE.md # 新增
└── PRIVACY_GUIDE.md     # 新增
```

---

## 三、技术方案

### 3.1 目录结构

```
lib/
├── logger_kit.dart              # 主入口
└── src/
    ├── core/
    │   ├── logger.dart           # 现有
    │   ├── logger_kit.dart       # 现有
    │   ├── logger_builder.dart   # 新增
    │   └── logger_manager.dart   # 新增
    ├── models/
    │   ├── log_record.dart       # 现有
    │   ├── log_level.dart        # 现有
    │   ├── log_config.dart        # 现有
    │   └── log_context.dart       # 新增
    ├── interceptors/              # 新增目录
    │   ├── log_interceptor.dart   # 新增
    │   ├── privacy_interceptor.dart
    │   └── context_interceptor.dart
    ├── filters/
    │   └── log_filter.dart        # 现有
    ├── formatters/
    │   └── log_formatter.dart     # 现有
    └── writers/
        ├── log_writer.dart        # 现有
        ├── console_writer.dart    # 新增
        ├── file_writer.dart       # 现有
        └── remote_writer.dart     # 现有
```

### 3.2 核心类图

```dart
// LoggerBuilder
class LoggerBuilder {
  LoggerBuilder minLevel(LogLevel level);
  LoggerBuilder console({bool enabled = true});
  LoggerBuilder file({String? path, int? maxSize, int? maxCount});
  LoggerBuilder remote({String? url, int? batchSize, Duration? interval});
  LoggerBuilder context(LogContext context);
  LoggerBuilder privacyFields(List<String> fields);
  LoggerBuilder addInterceptor(LogInterceptor interceptor);
  Logger build();
}

// LoggerManager
class LoggerManager {
  static final LoggerManager _instance = LoggerManager._();
  factory LoggerManager() => _instance;
  
  Logger namespace(String name, {LogConfig? config});
  Logger get network;
  Logger get database;
  Logger get ui;
  void registerNamespace(String name, {LogConfig? config});
}

// LogInterceptor
abstract class LogInterceptor {
  LogRecord intercept(LogRecord record);
  int get order => 0;
}

// LogContext
class LogContext {
  String? userId;
  String? sessionId;
  String? traceId;
  String? deviceId;
  Map<String, dynamic> custom = {};
}
```

### 3.3 向后兼容

```dart
// 保留现有 init() 方法
class LoggerKit {
  static void init({
    LogLevel minLevel = LogLevel.debug,
    bool enableConsole = true,
    bool enableFile = false,
    bool enableRemote = false,
    String? filePath,
    String? remoteUrl,
    int maxFileSize = 10 * 1024 * 1024,
    int maxFileCount = 5,
    bool includeTimestamp = true,
    bool includeTag = true,
    bool includeEmoji = true,
    bool prettyPrint = true,
  }) {
    // 内部转换为 builder 模式
    builder()
      ..minLevel(minLevel)
      ..console(enableConsole)
      ..file(path: filePath, maxSize: maxFileSize, maxCount: maxFileCount)
      ..remote(url: remoteUrl)
      ..build();
  }
}
```

---

## 四、里程碑

### Milestone 1: 核心框架 ✅ 2天

- [ ] LoggerBuilder 实现
- [ ] LoggerManager 实现
- [ ] LogInterceptor 接口
- [ ] LogContext 模型
- [ ] 基础单元测试

### Milestone 2: 功能实现 ✅ 2天

- [ ] ConsoleWriter 重构
- [ ] PrivacyInterceptor
- [ ] ContextInterceptor
- [ ] 集成测试
- [ ] 性能测试

### Milestone 3: API 完善 ✅ 1天

- [ ] 向后兼容适配
- [ ] 命名空间 API
- [ ] 示例代码更新
- [ ] Example 目录更新

### Milestone 4: 文档与发布 ✅ 1天

- [ ] API 文档更新
- [ ] 新功能文档
- [ ] CHANGELOG 更新
- [ ] 版本发布准备

---

## 五、测试计划

### 5.1 单元测试

| 测试文件 | 覆盖内容 | 目标覆盖率 |
|----------|----------|-----------|
| logger_builder_test.dart | Builder 链式调用、默认值、边界 | 90%+ |
| logger_manager_test.dart | 命名空间注册、获取、隔离 | 90%+ |
| log_context_test.dart | 字段操作、序列化 | 90%+ |
| privacy_interceptor_test.dart | 字段过滤、递归过滤 | 95%+ |
| context_interceptor_test.dart | 上下文注入、覆盖 | 90%+ |

### 5.2 集成测试

| 测试场景 | 测试内容 |
|----------|----------|
| namespace_isolation_test | 不同命名空间日志隔离 |
| interceptor_chain_test | 拦截器链执行顺序 |
| backward_compat_test | v1.x API 兼容 |

### 5.3 性能基准

```
benchmark/
├── baseline_v1.txt      # v1.x 性能数据
├── baseline_v2.txt      # v2.x 性能数据
└── comparison.py        # 对比脚本
```

---

## 六、文档更新

### 6.1 需要更新的文件

| 文件 | 更新内容 |
|------|----------|
| README.md | 新功能介绍、徽章更新 |
| CHANGELOG.md | v1.1.0 变更记录 |
| doc/API.md | 新增 API 文档 |
| doc/ARCHITECTURE.md | 架构图更新 |
| doc/USAGE_GUIDE.md | 新用法示例 |

### 6.2 需要新增的文件

| 文件 | 内容 |
|------|------|
| doc/BUILDER_GUIDE.md | Builder 模式指南 |
| doc/NAMESPACE_GUIDE.md | 命名空间使用指南 |
| doc/INTERCEPTOR_GUIDE.md | 拦截器开发指南 |
| doc/PRIVACY_GUIDE.md | 隐私保护指南 |

---

## 附录：预估工作量

| Phase | 任务数 | 预估时间 | 负责人 |
|-------|--------|----------|--------|
| Phase 1 | 4 | 2 天 | - |
| Phase 2 | 3 | 2 天 | - |
| Phase 3 | 3 | 1 天 | - |
| Phase 4 | 3 | 1 天 | - |
| Phase 5 | 2 | 1 天 | - |
| **总计** | **15** | **7 天** | - |

---

*计划制定时间：2025年1月*
*计划版本：v1.0*
