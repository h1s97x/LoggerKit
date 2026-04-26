# LoggerKit API Reference

> v1.1.0 API 文档

## 目录

- [Core Classes](#core-classes)
- [Models](#models)
- [Interceptors](#interceptors)
- [Formatters](#formatters)
- [Filters](#filters)
- [Writers](#writers)

---

## Core Classes

### LoggerKit

全局日志管理器。

```dart
class LoggerKit {
  // 初始化
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
  });

  // Builder 模式 (推荐)
  static LoggerBuilder builder();

  // 获取全局 logger
  static Logger get instance;

  // 命名空间
  static Logger namespace(String name, {LogConfig? config});
  static Logger get network;
  static Logger get database;
  static Logger get ui;
  static Logger get storage;
  static Logger get auth;
  static Logger get analytics;

  // 全局上下文
  static LogContext get context;
  static void setContext(LogContext context);
  static void clearContext();

  // 日志方法
  static void d(String message, {String? tag, Map<String, dynamic>? data});
  static void i(String message, {String? tag, Map<String, dynamic>? data});
  static void w(String message, {String? tag, Map<String, dynamic>? data});
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? data});
  static void f(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? data});
  static void v(String message, {String? tag, Map<String, dynamic>? data});
  static void event(String name, {Map<String, dynamic>? data});

  // 生命周期
  static Future<void> close();
}
```

### LoggerBuilder

链式配置构建器。

```dart
class LoggerBuilder {
  // 配置方法
  LoggerBuilder minLevel(LogLevel level);
  LoggerBuilder console({bool? prettyPrint});
  LoggerBuilder noConsole();
  LoggerBuilder file({String? path, int? maxSize, int? maxCount});
  LoggerBuilder noFile();
  LoggerBuilder remote({String? url, int? batchSize, int? flushInterval});
  LoggerBuilder noRemote();
  LoggerBuilder timestamp(bool include);
  LoggerBuilder tag(bool include);
  LoggerBuilder emoji(bool include);
  LoggerBuilder prettyPrint(bool enable);
  LoggerBuilder privacyFields(List<String> fields);
  LoggerBuilder context(LogContext context);
  
  // 拦截器
  LoggerBuilder addInterceptor(LogInterceptor interceptor);
  LoggerBuilder addInterceptors(List<LogInterceptor> interceptors);

  // 构建
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
  void d(String message, {String? tag, Map<String, dynamic>? data});
  void i(String message, {String? tag, Map<String, dynamic>? data});
  void w(String message, {String? tag, Map<String, dynamic>? data});
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? data});
  void f(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? data});
  void v(String message, {String? tag, Map<String, dynamic>? data});

  // 拦截器和过滤器
  void addInterceptor(LogInterceptor interceptor);
  void removeInterceptor(LogInterceptor interceptor);
  void addFilter(LogFilter filter);
  void removeFilter(LogFilter filter);
  List<LogInterceptor> get interceptors;
  List<LogFilter> get filters;
  List<LogWriter> get writers;

  // 生命周期
  void updateConfig(LogConfig config);
  Future<void> close();
  Future<void> flush();
}
```

### LoggerManager

命名空间管理器。

```dart
class LoggerManager {
  static final LoggerManager instance;

  // 命名空间操作
  Logger namespace(String name, {LogConfig? config});
  void registerNamespace(String name, {LogConfig? config});
  bool hasNamespace(String name);
  List<String> get namespaceNames;
  Future<void> removeNamespace(String name);
  Future<void> clearAll();

  // 创建独立 logger
  Logger createLogger({LogConfig? config, String? namespace});

  // 预设命名空间
  Logger get network;
  Logger get database;
  Logger get ui;
  Logger get storage;
  Logger get auth;
  Logger get analytics;
}
```

---

## Models

### LogLevel

日志级别枚举。

```dart
enum LogLevel {
  debug(0, 'DEBUG', '🔍');
  info(1, 'INFO', 'ℹ️');
  warning(2, 'WARNING', '⚠️');
  error(3, 'ERROR', '❌');
  fatal(4, 'FATAL', '💀');

  bool shouldLog(LogLevel minLevel);
}
```

### LogRecord

单条日志记录。

```dart
class LogRecord {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? data;

  LogRecord copyWith({
    LogLevel? level,
    String? message,
    DateTime? timestamp,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    bool clearTag = false,
    bool clearError = false,
    bool clearStackTrace = false,
    bool clearData = false,
  });

  Map<String, dynamic> toJson();
  factory LogRecord.fromJson(Map<String, dynamic> json);
}
```

### LogConfig

日志配置。

```dart
class LogConfig {
  final LogLevel minLevel;
  final bool enableConsole;
  final bool enableFile;
  final bool enableRemote;
  final String? filePath;
  final String? remoteUrl;
  final int maxFileSize;
  final int maxFileCount;
  final bool includeTimestamp;
  final bool includeTag;
  final bool includeEmoji;
  final bool prettyPrint;

  LogConfig copyWith({...});
}
```

### LogContext

结构化日志上下文。

```dart
class LogContext {
  String? userId;
  String? sessionId;
  String? traceId;
  String? deviceId;
  final Map<String, dynamic> custom;

  // 方法
  void set(String key, dynamic value);
  dynamic get(String key);
  dynamic remove(String key);
  bool containsKey(String key);
  void clear();
  void clearAll();
  Map<String, dynamic> toMap();
  LogContext copyWith({...});

  bool get isEmpty;
  bool get isNotEmpty;

  // 全局上下文
  static LogContext current = LogContext();
}
```

---

## Interceptors

### LogInterceptor

拦截器接口。

```dart
abstract class LogInterceptor {
  LogRecord? intercept(LogRecord record);
  int get order => 0;
}
```

### PassThroughInterceptor

透传拦截器（不做任何修改）。

```dart
class PassThroughInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) => record;
}
```

### CompositeInterceptor

组合拦截器。

```dart
class CompositeInterceptor implements LogInterceptor {
  CompositeInterceptor(List<LogInterceptor> interceptors, {bool stopOnNull = true});

  void add(LogInterceptor interceptor);
  void remove(LogInterceptor interceptor);
  int get length;
  bool get isEmpty;
  bool get isNotEmpty;
}
```

### PrivacyInterceptor

隐私数据过滤拦截器。

```dart
class PrivacyInterceptor implements LogInterceptor {
  PrivacyInterceptor({
    List<String>? sensitiveFields,
    String maskValue = '***',
    bool recursive = true,
  });

  // 默认过滤的字段:
  // password, passwd, pwd, token, accessToken, apiKey,
  // secret, auth, authorization, creditCard, cvv, ssn, ...
}
```

### ContextInterceptor

上下文注入拦截器。

```dart
class ContextInterceptor implements LogInterceptor {
  ContextInterceptor({LogContext Function()? getContext});

  @override
  int get order => 0;
}
```

### ScopedContextInterceptor

作用域上下文拦截器。

```dart
class ScopedContextInterceptor implements LogInterceptor {
  T runWithContext<T>(LogContext context, T Function() callback);
}
```

---

## Formatters

### LogFormatter

格式化器接口。

```dart
abstract class LogFormatter {
  String format(LogRecord record, LogConfig config);
}
```

### SimpleFormatter

简单格式化器。

### JsonFormatter

JSON 格式化器。

### ColoredFormatter

彩色格式化器（控制台输出）。

---

## Filters

### LogFilter

过滤器接口。

```dart
abstract class LogFilter {
  bool shouldLog(LogRecord record);
}
```

### LevelFilter

级别过滤器。

```dart
class LevelFilter implements LogFilter {
  LevelFilter(LogLevel minLevel);
}
```

### TagFilter

标签过滤器。

```dart
class TagFilter implements LogFilter {
  TagFilter(List<String> allowedTags);
}
```

### CompositeFilter

组合过滤器。

```dart
class CompositeFilter implements LogFilter {
  CompositeFilter(List<LogFilter> filters, {bool requireAll = true});
}
```

---

## Writers

### LogWriter

写入器接口。

```dart
abstract class LogWriter {
  Future<void> write(LogRecord record, String formatted);
  Future<void> close();
  Future<void> flush() async {} // 可选实现
}
```

### ConsoleWriter

控制台写入器。

### FileWriter

文件写入器（支持日志轮转）。

### RemoteWriter

远程日志写入器（HTTP 上报，带缓冲）。

---

## Usage Examples

### 基本使用

```dart
import 'package:logger_kit/logger_kit.dart';

void main() {
  LoggerKit.init();
  
  LoggerKit.d('Debug message');
  LoggerKit.i('Info message');
  LoggerKit.w('Warning message');
  LoggerKit.e('Error occurred', error: Exception('test'));
  LoggerKit.f('Fatal error');
}
```

### Builder 模式

```dart
LoggerKit.builder()
  ..minLevel(LogLevel.info)
  ..console(prettyPrint: true)
  ..file(path: './logs', maxSize: 10 * 1024 * 1024)
  ..privacyFields(['password', 'token'])
  ..build();
```

### 命名空间

```dart
// 创建命名空间 logger
final networkLogger = LoggerKit.namespace('network');
networkLogger.i('API request sent');

// 使用预设命名空间
LoggerKit.network.i('Network activity');
LoggerKit.database.d('Query executed');
LoggerKit.ui.d('Screen rendered');

// 注册预设命名空间
LoggerKit.registerNamespace('custom', config: LogConfig(
  minLevel: LogLevel.warning,
));
```

### 拦截器

```dart
LoggerKit.builder()
  ..minLevel(LogLevel.debug)
  ..console()
  ..addInterceptor(ContextInterceptor())
  ..addInterceptor(PrivacyInterceptor())
  ..build();

// 自定义拦截器
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
```

### 全局上下文

```dart
// 设置全局上下文
LoggerKit.setContext(LogContext(
  userId: 'user_123',
  sessionId: 'session_abc',
  traceId: 'trace_xyz',
));

// 添加自定义字段
LoggerKit.context.set('requestId', 'req_456');

// 所有日志都会包含这些上下文
LoggerKit.i('User action');  // 自动包含 userId, sessionId, traceId, requestId
```
