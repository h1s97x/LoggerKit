# LoggerKit - Code Wiki

> 一个功能完善的 Flutter/Dart 日志工具包
> 
> 版本: 1.2.0 | 语言: Dart | 框架: Flutter

---

## 目录

1. [项目概述](#1-项目概述)
2. [架构设计](#2-架构设计)
3. [模块详解](#3-模块详解)
4. [核心类与接口](#4-核心类与接口)
5. [依赖关系](#5-依赖关系)
6. [使用指南](#6-使用指南)
7. [测试覆盖](#7-测试覆盖)
8. [项目配置](#8-项目配置)

---

## 1. 项目概述

### 1.1 项目简介

LoggerKit 是一个为 Flutter/Dart 应用设计的综合日志工具包，提供多级别日志记录、多种输出方式（控制台、文件、远程）、拦截器机制、隐私过滤等高级功能。

### 1.2 主要特性

| 特性 | 描述 |
|------|------|
| 📝 多级别日志 | Debug, Info, Warning, Error, Fatal |
| 🖥️ 控制台输出 | 彩色格式化输出，支持 ANSI 颜色 |
| 💾 文件日志 | 自动轮转和清理，可配置大小限制 |
| 📤 远程日志 | 批量上传到服务器，支持 JSON 格式 |
| 🏷️ 命名空间 | 模块化日志管理，支持预设命名空间 |
| 🔒 隐私过滤 | 自动过滤敏感数据（密码、Token 等） |
| 🔄 拦截器 | 灵活扩展日志处理链 |
| 📎 上下文注入 | 结构化日志数据，支持全局上下文 |
| 🎨 自定义格式 | 支持多种格式化器 |
| 🔍 日志过滤 | 按级别、标签过滤 |
| 📊 事件追踪 | 记录用户行为事件 |
| ⚡ 高性能 | 异步写入，不阻塞主线程 |

### 1.3 项目结构

```
logger_kit/
├── lib/
│   ├── src/
│   │   ├── core/           # 核心模块
│   │   ├── models/         # 数据模型
│   │   ├── writers/        # 日志写入器
│   │   ├── interceptors/   # 拦截器
│   │   ├── formatters/     # 格式化器
│   │   ├── filters/        # 过滤器
│   │   ├── pretty/         # 美化打印
│   │   └── strategy/       # 策略模式
│   ├── logger_kit.dart     # 主入口
│   ├── models.dart         # 模型导出
│   ├── pretty.dart         # 美化打印导出
│   └── strategy.dart       # 策略导出
├── test/                   # 单元测试
├── example/                # 示例代码
├── doc/                    # 文档
├── benchmark/              # 性能测试
└── .github/                # CI/CD 配置
```

---

## 2. 架构设计

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        Application                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                        LoggerKit                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   init()    │  │  builder()  │  │   namespace()       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                         Logger                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  log()      │  │  d/i/w/e/f  │  │  event()            │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌─────────────┐
│ Interceptors │ │ Filters  │ │  Formatters │
└──────────────┘ └──────────┘ └─────────────┘
        │             │             │
        └─────────────┼─────────────┘
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                         Writers                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Console   │  │    File     │  │       Remote        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 设计模式

| 模式 | 应用位置 | 说明 |
|------|----------|------|
| **单例模式** | LoggerKit, LoggerManager | 全局唯一实例管理 |
| **建造者模式** | LoggerBuilder | 流式配置构建 |
| **策略模式** | ErrorStrategy, OverflowStrategy | 可插拔的错误和溢出处理 |
| **责任链模式** | LogInterceptor | 拦截器链式处理 |
| **工厂模式** | LogWriter 创建 | 根据配置创建不同写入器 |

### 2.3 数据流

```
Log Message → Logger.log() → Interceptors → Filters → Formatter → Writers
                                                                  │
                              ┌───────────────────────────────────┼───┐
                              ▼                                   ▼   ▼
                         ConsoleWriter                     FileWriter  RemoteWriter
                              │                                   │       │
                              ▼                                   ▼       ▼
                          stdout/stderr                      本地文件   HTTP API
```

---

## 3. 模块详解

### 3.1 Core 模块 (`lib/src/core/`)

#### 3.1.1 LoggerKit

全局日志管理器，提供静态方法供应用调用。

**文件**: `lib/src/core/logger_kit.dart`

**主要职责**:
- 管理全局 Logger 实例
- 提供初始化方法
- 提供快捷日志方法 (d, i, w, e, f, v)
- 管理全局上下文
- 提供命名空间访问

**关键方法**:

```dart
// 初始化
static void init({...})           // 传统初始化方式
static LoggerBuilder builder()    // Builder 模式初始化

// 日志方法
static void d(String message, ...)  // Debug
static void i(String message, ...)  // Info
static void w(String message, ...)  // Warning
static void e(String message, ...)  // Error
static void f(String message, ...)  // Fatal
static void v(String message, ...)  // Verbose

// 命名空间
static Logger namespace(String name)  // 获取命名空间 Logger
static Logger get network            // 网络命名空间
static Logger get database           // 数据库命名空间
static Logger get ui                 // UI 命名空间

// 上下文管理
static LogContext get context        // 获取全局上下文
static void setContext(LogContext)   // 设置全局上下文
static void clearContext()           // 清空上下文

// 事件追踪
static void event(String name, ...)  // 记录事件

// 清理
static Future<void> close()          // 关闭并释放资源
```

#### 3.1.2 Logger

核心日志类，负责日志的记录、格式化、过滤和写入。

**文件**: `lib/src/core/logger.dart`

**主要职责**:
- 接收日志消息
- 应用拦截器链
- 执行过滤器
- 格式化日志
- 分发到写入器

**关键方法**:

```dart
// 构造函数
Logger({
  required LogConfig config,
  LogFormatter? formatter,
  String? namespace,
  ErrorStrategy errorStrategy,
  OverflowStrategy overflowStrategy,
  PrettyPrinter? prettyPrinter,
})

// 核心日志方法
Future<void> log(LogLevel level, String message, {...})

// 快捷方法
void d(String message, ...)  // Debug
void i(String message, ...)  // Info
void w(String message, ...)  // Warning
void e(String message, ...)  // Error
void f(String message, ...)  // Fatal
void v(String message, ...)  // Verbose

// 拦截器管理
void addInterceptor(LogInterceptor interceptor)
void removeInterceptor(LogInterceptor interceptor)
List<LogInterceptor> get interceptors

// 过滤器管理
void addFilter(LogFilter filter)
void removeFilter(LogFilter filter)
List<LogFilter> get filters

// 配置更新
void updateConfig(LogConfig newConfig)

// 资源管理
Future<void> close()
Future<void> flush()
```

#### 3.1.3 LoggerManager

命名空间 Logger 管理器，负责创建和管理多个 Logger 实例。

**文件**: `lib/src/core/logger_manager.dart`

**主要职责**:
- 管理命名空间 Logger 的生命周期
- 提供预设命名空间快捷访问
- 支持命名空间配置注册

**关键方法**:

```dart
// 单例访问
static LoggerManager get instance

// 命名空间管理
Logger namespace(String name, {LogConfig? config})
void registerNamespace(String name, {LogConfig? config})
bool hasNamespace(String name)
List<String> get namespaceNames
Future<void> removeNamespace(String name)
Future<void> clearAll()

// 预设命名空间（通过扩展）
Logger get network    // 网络日志
Logger get database   // 数据库日志
Logger get ui         // UI 日志
Logger get storage    // 存储日志
Logger get auth       // 认证日志
Logger get analytics  // 分析日志
```

#### 3.1.4 LoggerBuilder

Builder 模式实现，用于流式配置 Logger。

**文件**: `lib/src/core/logger_builder.dart`

**主要职责**:
- 提供流式 API 配置日志选项
- 构建 Logger 实例
- 设置全局 Logger

**关键方法**:

```dart
// 配置方法（返回 this 支持链式调用）
LoggerBuilder minLevel(LogLevel level)
LoggerBuilder console({bool? prettyPrint})
LoggerBuilder noConsole()
LoggerBuilder file({String? path, int? maxSize, int? maxCount})
LoggerBuilder noFile()
LoggerBuilder remote({String? url, int? batchSize, int? flushInterval})
LoggerBuilder noRemote()
LoggerBuilder timestamp(bool include)
LoggerBuilder tag(bool include)
LoggerBuilder emoji(bool include)
LoggerBuilder prettyPrint(bool enable)
LoggerBuilder privacyFields(List<String> fields)
LoggerBuilder context(LogContext context)
LoggerBuilder addInterceptor(LogInterceptor interceptor)
LoggerBuilder addInterceptors(List<LogInterceptor> interceptors)
LoggerBuilder prettyPrinter(PrettyPrinter printer)
LoggerBuilder errorStrategy(ErrorStrategy strategy)
LoggerBuilder overflowStrategy(OverflowStrategy strategy)

// 构建方法
Logger build()
Logger buildAndSetGlobal()
```

### 3.2 Models 模块 (`lib/src/models/`)

#### 3.2.1 LogLevel

日志级别枚举。

**文件**: `lib/src/models/log_level.dart`

```dart
enum LogLevel {
  debug(0, 'DEBUG', '🔍'),      // 调试信息
  info(1, 'INFO', 'ℹ️'),        // 一般信息
  warning(2, 'WARNING', '⚠️'),  // 警告信息
  error(3, 'ERROR', '❌'),      // 错误信息
  fatal(4, 'FATAL', '💀'),      // 致命错误
}

// 属性
final int value;      // 数值用于比较
final String name;    // 级别名称
final String emoji;   // Emoji 表示

// 方法
bool shouldLog(LogLevel minLevel)  // 检查是否应该记录
```

#### 3.2.2 LogRecord

单条日志记录。

**文件**: `lib/src/models/log_record.dart`

```dart
class LogRecord {
  final LogLevel level;           // 日志级别
  final String message;           // 日志消息
  final DateTime timestamp;       // 时间戳
  final String? tag;              // 标签
  final Object? error;            // 错误对象
  final StackTrace? stackTrace;   // 堆栈跟踪
  final Map<String, dynamic>? data;      // 额外数据
  final Map<String, dynamic>? context;   // 上下文
  
  // 构造函数
  LogRecord({...})
  
  // 工厂方法
  factory LogRecord.fromJson(Map<String, dynamic> json)
  
  // 方法
  LogRecord copyWith({...})       // 创建副本
  Map<String, dynamic> toJson()   // 序列化为 JSON
}
```

#### 3.2.3 LogConfig

日志配置类。

**文件**: `lib/src/models/log_config.dart`

```dart
class LogConfig {
  final LogLevel minLevel;        // 最小日志级别
  final bool enableConsole;       // 启用控制台输出
  final bool enableFile;          // 启用文件日志
  final bool enableRemote;        // 启用远程日志
  final String? filePath;         // 文件路径
  final String? remoteUrl;        // 远程 URL
  final int maxFileSize;          // 最大文件大小（字节）
  final int maxFileCount;         // 最大文件数量
  final bool includeTimestamp;    // 包含时间戳
  final bool includeTag;          // 包含标签
  final bool includeEmoji;        // 包含 Emoji
  final bool prettyPrint;         // 美化打印
  final ErrorStrategy errorStrategy;      // 错误处理策略
  final OverflowStrategy overflowStrategy; // 溢出处理策略
  
  // 方法
  LogConfig copyWith({...})       // 创建副本
}
```

#### 3.2.4 LogContext

日志上下文，用于结构化日志。

**文件**: `lib/src/models/log_context.dart`

```dart
class LogContext {
  static LogContext? current;     // 全局当前上下文
  
  String? userId;                 // 用户 ID
  String? sessionId;              // 会话 ID
  String? traceId;                // 追踪 ID
  String? deviceId;               // 设备 ID
  final Map<String, dynamic> custom;  // 自定义字段
  
  // 方法
  void set(String key, dynamic value)    // 设置自定义字段
  dynamic get(String key)                // 获取字段值
  dynamic remove(String key)             // 删除字段
  bool containsKey(String key)           // 检查字段存在
  void clear()                           // 清空自定义字段
  void clearAll()                        // 清空所有字段
  bool get isEmpty                       // 是否为空
  bool get isNotEmpty                    // 是否有数据
  Map<String, dynamic> toMap()           // 转换为 Map
  LogContext copyWith({...})             // 创建副本
}
```

#### 3.2.5 LogException

日志异常。

**文件**: `lib/src/models/log_exception.dart`

```dart
class LoggerException implements Exception {
  final String message;
  final List<Object> errors;
  
  const LoggerException(this.message, {this.errors = const []});
}
```

### 3.3 Writers 模块 (`lib/src/writers/`)

#### 3.3.1 LogWriter (接口)

日志写入器接口。

**文件**: `lib/src/writers/log_writer.dart`

```dart
abstract class LogWriter {
  Future<void> write(LogRecord record, String formatted);
  Future<void> close();
  Future<void> flush();
}
```

#### 3.3.2 ConsoleWriter

控制台写入器。

**文件**: `lib/src/writers/console_writer.dart`

```dart
class ConsoleWriter implements LogWriter {
  ConsoleWriter({
    PrettyPrinter? prettyPrinter,
    ErrorStrategy errorStrategy = ErrorStrategy.ignore,
    String output = 'stdout',  // 'stdout' 或 'stderr'
    bool? useColor,
  });
}
```

#### 3.3.3 FileWriter

文件写入器，支持自动轮转。

**文件**: `lib/src/writers/file_writer.dart`

```dart
class FileWriter implements LogWriter {
  FileWriter(LogConfig config);
  
  // 功能特性
  // - 自动文件轮转（基于大小）
  // - 自动清理旧文件
  // - 异步写入
}
```

**轮转逻辑**:
- 当文件大小超过 `maxFileSize` 时创建新文件
- 文件名格式: `log_<timestamp>.txt`
- 保留最多 `maxFileCount` 个文件
- 删除最旧的文件

#### 3.3.4 RemoteWriter

远程写入器，批量上传日志。

**文件**: `lib/src/writers/remote_writer.dart`

```dart
class RemoteWriter implements LogWriter {
  RemoteWriter(LogConfig config);
  
  // 功能特性
  // - 缓冲区大小: 10 条日志
  // - 自动刷新间隔: 30 秒
  // - JSON 格式上传
  // - 失败静默处理
}
```

### 3.4 Interceptors 模块 (`lib/src/interceptors/`)

#### 3.4.1 LogInterceptor (接口)

拦截器接口。

**文件**: `lib/src/interceptors/log_interceptor.dart`

```dart
abstract class LogInterceptor {
  LogRecord? intercept(LogRecord record);
  int get order => 0;  // 执行顺序，越小越早
}

// 实现类
class PassThroughInterceptor implements LogInterceptor
class CompositeInterceptor implements LogInterceptor
```

#### 3.4.2 PrivacyInterceptor

隐私拦截器，过滤敏感数据。

**文件**: `lib/src/interceptors/privacy_interceptor.dart`

```dart
class PrivacyInterceptor implements LogInterceptor {
  PrivacyInterceptor({
    List<String>? extraSensitiveFields,
    this.maskValue = '***',
    this.recursive = true,
  });
  
  // 默认敏感字段
  // password, passwd, pwd, token, accessToken, refreshToken,
  // apiKey, secret, auth, authorization, credential, creditCard,
  // cardNumber, cvv, ssn, privateKey, ...
}
```

#### 3.4.3 ContextInterceptor

上下文拦截器，注入上下文数据。

**文件**: `lib/src/interceptors/context_interceptor.dart`

```dart
class ContextInterceptor implements LogInterceptor {
  ContextInterceptor({
    LogContext Function()? getContext,
  });
}

class ScopedContextInterceptor implements LogInterceptor {
  // 支持临时上下文范围
  T runWithContext<T>(LogContext context, T Function() callback);
}
```

### 3.5 Formatters 模块 (`lib/src/formatters/`)

#### 3.5.1 LogFormatter (接口)

格式化器接口。

**文件**: `lib/src/formatters/log_formatter.dart`

```dart
abstract class LogFormatter {
  String format(LogRecord record, LogConfig config);
}
```

#### 3.5.2 内置格式化器

| 格式化器 | 描述 |
|----------|------|
| `SimpleFormatter` | 简单格式化，包含时间戳、级别、标签、消息 |
| `JsonFormatter` | JSON 格式，适合远程传输 |
| `ColoredFormatter` | 带 ANSI 颜色的格式化 |

### 3.6 Filters 模块 (`lib/src/filters/`)

#### 3.6.1 LogFilter (接口)

过滤器接口。

**文件**: `lib/src/filters/log_filter.dart`

```dart
abstract class LogFilter {
  bool shouldLog(LogRecord record);
}
```

#### 3.6.2 内置过滤器

| 过滤器 | 描述 |
|--------|------|
| `LevelFilter` | 按日志级别过滤 |
| `TagFilter` | 按标签过滤 |
| `CompositeFilter` | 组合多个过滤器（AND/OR 逻辑） |

### 3.7 Pretty 模块 (`lib/src/pretty/`)

美化打印模块，提供彩色输出和格式化。

#### 3.7.1 PrettyPrinter (接口)

**文件**: `lib/src/pretty/pretty_printer.dart`

```dart
abstract class PrettyPrinter {
  String format(LogRecord record);
  String formatColored(LogRecord record);
  String formatStackTrace(StackTrace stackTrace);
  bool get useColors;
  set useColors(bool value);
  int get maxLineWidth;
  set maxLineWidth(int value);
}

class PrettyPrinterConfig {
  final bool useColors;
  final int maxLineWidth;
  final int maxStackTraceLines;
  final int stackTraceIndent;
  final int messageIndent;
  final bool collapseMultiLine;
  final int collapseThreshold;
  final String errorPrefix;
  final String stackTracePrefix;
  final String timestampFormat;
}
```

#### 3.7.2 DefaultPrettyPrinter

**文件**: `lib/src/pretty/default_pretty_printer.dart`

功能特性:
- ANSI 彩色输出
- 堆栈跟踪格式化
- 多行消息折叠
- Map/List 数据格式化

#### 3.7.3 AnsiColor

**文件**: `lib/src/pretty/ansi_color.dart`

提供 ANSI 颜色代码常量:
- 基本颜色: black, red, green, yellow, blue, magenta, cyan, white
- 亮色: brightBlack ~ brightWhite
- 样式: bold, dim, italic, underline
- 背景色: bgRed, bgGreen, bgYellow, bgBlue

### 3.8 Strategy 模块 (`lib/src/strategy/`)

#### 3.8.1 ErrorStrategy

错误处理策略。

**文件**: `lib/src/strategy/error_strategy.dart`

```dart
enum ErrorStrategy {
  ignore,        // 静默忽略错误
  logToFallback, // 记录到备用输出
  throwException, // 抛出异常
}
```

#### 3.8.2 OverflowStrategy

队列溢出处理策略。

**文件**: `lib/src/strategy/overflow_strategy.dart`

```dart
enum OverflowStrategy {
  dropOldest,  // 丢弃最旧的日志
  dropNewest,  // 丢弃最新的日志
  block,       // 阻塞直到有空间
}
```

---

## 4. 核心类与接口

### 4.1 类图

```
┌─────────────────────────────────────────────────────────────────────┐
│                           LogRecord                                  │
├─────────────────────────────────────────────────────────────────────┤
│ + level: LogLevel                                                   │
│ + message: String                                                   │
│ + timestamp: DateTime                                               │
│ + tag: String?                                                      │
│ + error: Object?                                                    │
│ + stackTrace: StackTrace?                                           │
│ + data: Map<String, dynamic>?                                       │
├─────────────────────────────────────────────────────────────────────┤
│ + copyWith(): LogRecord                                             │
│ + toJson(): Map<String, dynamic>                                    │
│ + fromJson(): LogRecord                                             │
└─────────────────────────────────────────────────────────────────────┘
                                    ▲
                                    │ uses
┌─────────────────────────────────────────────────────────────────────┐
│                            Logger                                    │
├─────────────────────────────────────────────────────────────────────┤
│ - _writers: List<LogWriter>                                         │
│ - _filters: List<LogFilter>                                         │
│ - _interceptors: List<LogInterceptor>                               │
│ - _formatter: LogFormatter                                          │
│ + config: LogConfig                                                 │
├─────────────────────────────────────────────────────────────────────┤
│ + log(level, message, ...)                                          │
│ + d/i/w/e/f/v(message, ...)                                         │
│ + addInterceptor(interceptor)                                       │
│ + addFilter(filter)                                                 │
│ + close()                                                           │
└─────────────────────────────────────────────────────────────────────┘
        ▲                                    ▲
        │                                    │
        │ uses                               │ manages
        │                                    │
┌───────┴──────────┐              ┌─────────┴──────────┐
│    LoggerKit      │              │   LoggerManager    │
├───────────────────┤              ├────────────────────┤
│ - _instance       │              │ - _namespaces      │
│ - _config         │              │ - _presetConfigs   │
│ - _globalContext  │              ├────────────────────┤
├───────────────────┤              │ + namespace()      │
│ + init()          │              │ + registerNamespace│
│ + builder()       │              │ + network          │
│ + d/i/w/e/f/v()   │              │ + database         │
│ + namespace()     │              │ + ui               │
│ + context         │              └────────────────────┘
└───────────────────┘
```

### 4.2 接口定义

#### LogWriter

```dart
abstract class LogWriter {
  /// 写入日志
  Future<void> write(LogRecord record, String formatted);
  
  /// 关闭写入器
  Future<void> close();
  
  /// 刷新缓冲区
  Future<void> flush();
}
```

#### LogInterceptor

```dart
abstract class LogInterceptor {
  /// 拦截并可能修改日志记录
  /// 返回 null 表示丢弃该日志
  LogRecord? intercept(LogRecord record);
  
  /// 执行顺序（越小越早执行）
  int get order => 0;
}
```

#### LogFilter

```dart
abstract class LogFilter {
  /// 判断是否记录该日志
  bool shouldLog(LogRecord record);
}
```

#### LogFormatter

```dart
abstract class LogFormatter {
  /// 格式化日志记录
  String format(LogRecord record, LogConfig config);
}
```

---

## 5. 依赖关系

### 5.1 外部依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0        # 远程日志 HTTP 请求
  path: ^1.8.3        # 文件路径处理

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### 5.2 内部依赖图

```
logger_kit.dart
├── src/core/logger_kit.dart
│   ├── models/log_level.dart
│   ├── models/log_config.dart
│   ├── models/log_context.dart
│   ├── core/logger.dart
│   ├── core/logger_builder.dart
│   └── core/logger_manager.dart
├── src/core/logger.dart
│   ├── models/log_record.dart
│   ├── models/log_level.dart
│   ├── models/log_config.dart
│   ├── models/log_exception.dart
│   ├── formatters/log_formatter.dart
│   ├── writers/log_writer.dart
│   ├── writers/file_writer.dart
│   ├── writers/remote_writer.dart
│   ├── writers/console_writer.dart
│   ├── filters/log_filter.dart
│   ├── interceptors/log_interceptor.dart
│   ├── pretty/pretty_printer.dart
│   ├── strategy/error_strategy.dart
│   └── strategy/overflow_strategy.dart
└── ... (其他导出)
```

### 5.3 模块依赖矩阵

| 模块 | 依赖模块 |
|------|----------|
| core | models, formatters, writers, filters, interceptors, pretty, strategy |
| models | strategy |
| writers | models, pretty, strategy |
| interceptors | models |
| formatters | models |
| filters | models |
| pretty | models |

---

## 6. 使用指南

### 6.1 快速开始

```dart
import 'package:logger_kit/logger_kit.dart';

void main() {
  // 初始化
  LoggerKit.init();
  
  // 记录日志
  LoggerKit.d('Debug message');
  LoggerKit.i('Info message');
  LoggerKit.w('Warning message');
  LoggerKit.e('Error message');
  LoggerKit.f('Fatal message');
  
  // 关闭
  LoggerKit.close();
}
```

### 6.2 Builder 模式配置

```dart
LoggerKit.builder()
  ..minLevel(LogLevel.info)
  ..console(prettyPrint: true)
  ..file(path: './logs', maxSize: 10 * 1024 * 1024, maxCount: 5)
  ..remote(url: 'https://api.example.com/logs')
  ..privacyFields(['customSecret'])
  ..addInterceptor(ContextInterceptor())
  ..addInterceptor(PrivacyInterceptor())
  ..build();
```

### 6.3 命名空间使用

```dart
// 创建命名空间 Logger
final networkLogger = LoggerKit.namespace('network');
networkLogger.i('API request sent');

// 使用预设命名空间
LoggerKit.network.d('Network debug');
LoggerKit.database.i('Query executed');
LoggerKit.ui.w('UI warning');
```

### 6.4 上下文使用

```dart
// 设置全局上下文
LoggerKit.setContext(LogContext(
  userId: 'user_123',
  sessionId: 'session_abc',
  traceId: 'trace_xyz',
));

// 添加自定义字段
LoggerKit.context.set('requestId', 'req_456');

// 所有日志自动包含上下文
LoggerKit.i('User action');
```

### 6.5 自定义拦截器

```dart
class UserInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) {
    return record.copyWith(
      data: {
        ...?record.data,
        'userId': getCurrentUserId(),
      },
    );
  }
  
  @override
  int get order => 10;
}

LoggerKit.builder()
  ..addInterceptor(UserInterceptor())
  ..build();
```

---

## 7. 测试覆盖

### 7.1 测试文件结构

```
test/
├── console_writer_test.dart
├── log_context_test.dart
├── log_filter_test.dart
├── log_formatter_test.dart
├── log_interceptor_test.dart
├── log_level_test.dart
├── log_record_test.dart
├── logger_builder_test.dart
├── logger_kit_test.dart
├── logger_manager_test.dart
├── pretty_printer_test.dart
└── strategy_test.dart
```

### 7.2 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/logger_kit_test.dart

# 带覆盖率
flutter test --coverage
```

---

## 8. 项目配置

### 8.1 pubspec.yaml

```yaml
name: logger_kit
description: A comprehensive Flutter logging toolkit
version: 1.2.0
homepage: https://github.com/h1s97x/LoggerKit

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.3.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  path: ^1.8.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### 8.2 analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml
```

### 8.3 CI/CD 配置

GitHub Actions 工作流:
- `.github/workflows/dart.yml` - Dart 测试和构建
- `.github/workflows/pr-check.yml` - PR 检查
- `.github/workflows/publish.yml` - 发布到 pub.dev

---

## 附录

### A. 日志级别对应表

| 级别 | 数值 | 名称 | Emoji | 颜色 | 用途 |
|------|------|------|-------|------|------|
| debug | 0 | DEBUG | 🔍 | Gray | 调试信息 |
| info | 1 | INFO | ℹ️ | Blue | 一般信息 |
| warning | 2 | WARNING | ⚠️ | Yellow | 警告信息 |
| error | 3 | ERROR | ❌ | Red | 错误信息 |
| fatal | 4 | FATAL | 💀 | Bright Red | 致命错误 |

### B. 预设命名空间

| 命名空间 | 用途 | 访问方式 |
|----------|------|----------|
| network | 网络/HTTP 日志 | `LoggerKit.network` |
| database | 数据库操作日志 | `LoggerKit.database` |
| ui | UI/组件日志 | `LoggerKit.ui` |
| storage | 文件/缓存日志 | `LoggerKit.storage` |
| auth | 认证日志 | `LoggerKit.auth` |
| analytics | 分析/事件日志 | `LoggerKit.analytics` |

### C. 默认敏感字段

```dart
const defaultSensitiveFields = {
  'password', 'passwd', 'pwd',
  'token', 'accessToken', 'access_token',
  'refreshToken', 'refresh_token',
  'apiKey', 'api_key', 'secret',
  'auth', 'authorization', 'bearer',
  'credential', 'credentials',
  'creditCard', 'cardNumber', 'card_number',
  'cvv', 'ssn', 'socialSecurityNumber',
  'private', 'privateKey', 'private_key',
};
```

---

*文档生成时间: 2026-05-07*  
*LoggerKit 版本: 1.2.0*
