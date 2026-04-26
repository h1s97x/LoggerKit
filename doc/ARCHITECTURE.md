# LoggerKit 架构设计 v2.0

> 本文档描述 LoggerKit v2.0 的架构设计原则和实现方案。

## 目录

- [概述](#概述)
- [架构原则](#架构原则)
- [项目结构](#项目结构)
- [核心组件](#核心组件)
- [数据流](#数据流)
- [拦截器架构](#拦截器架构)
- [命名空间设计](#命名空间设计)
- [性能优化](#性能优化)
- [扩展性设计](#扩展性设计)

---

## 概述

LoggerKit 是一个功能完善的 Flutter 日志工具包，支持控制台、文件和远程日志记录。v2.0 版本在保持轻量化的基础上，引入了现代化的架构设计。

### 核心功能

- 多级别日志（Debug, Info, Warning, Error, Fatal）
- 控制台彩色输出
- 文件日志（自动轮转和清理）
- 远程日志（批量上传）
- **日志拦截器/中间件**
- **命名空间隔离**
- **结构化上下文**
- **隐私数据过滤**
- 自定义格式化器
- 日志过滤
- 事件追踪
- 异步日志写入

---

## 架构原则

### 1. 分层架构

```
┌─────────────────────────────────────┐
│         应用层 (Application)         │
│         Flutter App / User          │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│         API 层 (API Layer)          │
│           LoggerKit Class            │
│    (静态方法、全局管理、命名空间)       │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│       核心层 (Core Layer)            │
│   Logger / LoggerBuilder / Manager   │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      拦截器层 (Interceptor Layer)    │
│   ContextInterceptor / PrivacyInterceptor │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│       过滤器层 (Filter Layer)         │
│         LevelFilter / TagFilter      │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      格式化层 (Formatter Layer)      │
│   Simple / JSON / Colored Formatter  │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│       输出层 (Writer Layer)          │
│   Console / File / Remote Writer     │
└─────────────────────────────────────┘
```

### 2. 核心设计原则

1. **单一职责**: 每个组件只负责一个功能
2. **依赖倒置**: 通过接口而非实现依赖
3. **开闭原则**: 对扩展开放，对修改关闭
4. **轻量化**: 核心零依赖，可选功能模块化
5. **向后兼容**: v1.x API 继续支持

---

## 项目结构

```
lib/
├── logger_kit.dart              # 主入口
└── src/
    ├── core/                    # 核心组件
    │   ├── logger.dart          # Logger 类
    │   ├── logger_kit.dart      # LoggerKit 全局管理
    │   ├── logger_builder.dart  # Builder 模式
    │   └── logger_manager.dart  # 命名空间管理
    │
    ├── models/                  # 数据模型
    │   ├── log_level.dart       # 日志级别
    │   ├── log_record.dart      # 日志记录
    │   ├── log_config.dart      # 配置
    │   └── log_context.dart     # 上下文 (v2.0)
    │
    ├── interceptors/            # 拦截器 (v2.0)
    │   ├── log_interceptor.dart # 拦截器接口
    │   ├── privacy_interceptor.dart
    │   └── context_interceptor.dart
    │
    ├── filters/                 # 过滤器
    │   └── log_filter.dart
    │
    ├── formatters/              # 格式化器
    │   └── log_formatter.dart
    │
    └── writers/                 # 输出器
        ├── log_writer.dart
        ├── file_writer.dart
        └── remote_writer.dart
```

---

## 核心组件

### LoggerKit

全局日志管理器，提供静态 API。

```dart
class LoggerKit {
  // 初始化
  static void init({...});           // 向后兼容
  static LoggerBuilder builder();     // Builder 模式

  // 命名空间
  static Logger namespace(String name);
  static Logger get network;          // 预设命名空间
  static Logger get database;
  static Logger get ui;

  // 全局上下文
  static LogContext get context;
  static void setContext(LogContext);

  // 日志方法
  static void d(String msg, {...});
  static void i(String msg, {...});
  static void w(String msg, {...});
  static void e(String msg, {...});
  static void f(String msg, {...});
}
```

### LoggerBuilder

链式配置构建器。

```dart
class LoggerBuilder {
  LoggerBuilder minLevel(LogLevel level);
  LoggerBuilder console({bool prettyPrint});
  LoggerBuilder file({String path, int maxSize, int maxCount});
  LoggerBuilder remote({String url, int batchSize});
  LoggerBuilder addInterceptor(LogInterceptor interceptor);
  LoggerBuilder context(LogContext context);
  LoggerBuilder privacyFields(List<String> fields);
  
  Logger build();
  Logger buildAndSetGlobal();
}
```

### Logger

日志记录器实例。

```dart
class Logger {
  final LogConfig config;
  final String? namespace;
  
  // 日志方法
  void d(String msg, {String? tag, Map<String, dynamic>? data});
  void i(String msg, {String? tag, Map<String, dynamic>? data});
  void w(String msg, {String? tag, Map<String, dynamic>? data});
  void e(String msg, {...});
  void f(String msg, {...});
  
  // 拦截器
  void addInterceptor(LogInterceptor interceptor);
  List<LogInterceptor> get interceptors;
  
  // 生命周期
  Future<void> close();
  Future<void> flush();
}
```

---

## 数据流

### 日志记录流程

```
用户调用
    ↓
LoggerKit.d('message') / logger.d('message')
    ↓
创建 LogRecord
    ↓
执行拦截器链 (Interceptor Chain)
    ↓
执行过滤器链 (Filter Chain)
    ↓
格式化 (Formatter)
    ↓
写入输出器 (Writer)
    ↓
ConsoleWriter → print()
FileWriter → 文件
RemoteWriter → HTTP
```

### 代码流程

```dart
Future<void> log(LogLevel level, String message, {...}) async {
  // 1. 创建记录
  var record = LogRecord(
    level: level,
    message: message,
    tag: tag ?? _namespace,
    data: data,
  );

  // 2. 拦截器处理
  for (final interceptor in _interceptors) {
    record = interceptor.intercept(record);
    if (record == null) return;  // 被拦截丢弃
  }

  // 3. 过滤器检查
  if (!_shouldLog(record)) return;

  // 4. 格式化
  final formatted = _formatter.format(record, config);

  // 5. 输出
  await Future.wait(
    _writers.map((writer) => writer.write(record, formatted)),
  );
}
```

---

## 拦截器架构

### 拦截器接口

```dart
abstract class LogInterceptor {
  /// 拦截并可选修改记录
  LogRecord? intercept(LogRecord record);
  
  /// 执行顺序（低值先执行）
  int get order => 0;
}
```

### 内置拦截器

| 拦截器 | Order | 功能 |
|--------|-------|------|
| ContextInterceptor | 0 | 注入全局上下文 |
| PrivacyInterceptor | 50 | 过滤敏感数据 |

### 自定义拦截器示例

```dart
class TimingInterceptor implements LogInterceptor {
  final Stopwatch _stopwatch = Stopwatch();
  
  @override
  int get order => 100;  // 最后执行
  
  @override
  LogRecord? intercept(LogRecord record) {
    _stopwatch.stop();
    return record.copyWith(
      data: {
        ...?record.data,
        'elapsedMs': _stopwatch.elapsedMilliseconds,
      },
    );
  }
}
```

### 拦截器链

```
┌──────────────────────────────────────────┐
│              LogRecord                    │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│          ContextInterceptor (order: 0)    │
│     注入 userId, sessionId, traceId      │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│         CustomInterceptor (order: 10)     │
│         用户自定义拦截器                   │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│        PrivacyInterceptor (order: 50)     │
│     过滤 password, token, apiKey 等      │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│              Filter Chain                │
└──────────────────────────────────────────┘
```

---

## 命名空间设计

### 概念

命名空间允许你为应用的不同模块创建独立的 logger 实例，每个实例可以有独立的配置。

### 使用方式

```dart
// 1. 创建命名空间
final networkLogger = LoggerKit.namespace('network');
networkLogger.i('API request sent');

// 2. 使用预设快捷方式
LoggerKit.network.i('Network activity');
LoggerKit.database.d('Query executed');
LoggerKit.ui.d('Screen rendered');

// 3. 注册预设配置
LoggerKit.registerNamespace('network', config: LogConfig(
  minLevel: LogLevel.warning,  // 只记录警告及以上
));
```

### 内部实现

```dart
class LoggerManager {
  final Map<String, Logger> _namespaces = {};
  final Map<String, LogConfig> _presetConfigs = {};
  
  Logger namespace(String name, {LogConfig? config}) {
    if (_namespaces.containsKey(name)) {
      return _namespaces[name]!;
    }
    
    final namespaceConfig = _presetConfigs[name] ?? config ?? LogConfig();
    final logger = Logger(config: namespaceConfig, namespace: name);
    _namespaces[name] = logger;
    
    return logger;
  }
}
```

---

## 性能优化

### 1. 异步写入

所有 writer 操作都是异步的，不会阻塞主线程：

```dart
await Future.wait(
  _writers.map((writer) => writer.write(record, formatted)),
);
```

### 2. 批量处理

RemoteWriter 支持批量上传，减少网络请求：

```dart
class RemoteWriter {
  final List<LogRecord> _buffer = [];
  static const int _bufferSize = 10;
  
  Future<void> write(LogRecord record, String formatted) async {
    _buffer.add(record);
    if (_buffer.length >= _bufferSize) {
      await _flush();
    }
  }
}
```

### 3. 文件轮转

FileWriter 支持自动轮转，避免单文件过大：

```dart
// maxFileSize: 单文件最大大小
// maxFileCount: 保留的最大文件数
```

---

## 扩展性设计

### 1. 自定义 Formatter

```dart
class CustomFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    // 自定义格式
    return '[${record.level.name}] ${record.message}';
  }
}
```

### 2. 自定义 Filter

```dart
class CustomFilter implements LogFilter {
  @override
  bool shouldLog(LogRecord record) {
    // 自定义过滤逻辑
    return record.message.contains('important');
  }
}
```

### 3. 自定义 Writer

```dart
class CustomWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    // 写入自定义目标
    await myBackend.send(formatted);
  }
  
  @override
  Future<void> close() async {}
}
```

### 4. 自定义 Interceptor

```dart
class CustomInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) {
    // 修改或增强记录
    return record.copyWith(
      data: {
        ...?record.data,
        'customField': 'value',
      },
    );
  }
  
  @override
  int get order => 20;  // 控制执行顺序
}
```

---

## 版本演进

| 版本 | 主要变更 |
|------|----------|
| v1.0 | 基础功能：控制台、文件、远程日志 |
| v1.1 | 格式化器、过滤器增强 |
| v2.0 | Builder 模式、命名空间、拦截器、上下文 |

---

## 附录

### 配置默认值

| 配置项 | 默认值 |
|--------|--------|
| minLevel | LogLevel.debug |
| enableConsole | true |
| enableFile | false |
| enableRemote | false |
| maxFileSize | 10MB |
| maxFileCount | 5 |
| includeTimestamp | true |
| includeTag | true |
| includeEmoji | true |
| prettyPrint | true |

### 隐私字段默认值

```
password, passwd, pwd,
token, accessToken, access_token, refreshToken, refresh_token,
apiKey, api_key,
secret, auth, authorization, bearer, credential, credentials,
creditCard, cardNumber, card_number, cvv,
ssn, socialSecurityNumber,
private, privateKey, private_key
```
