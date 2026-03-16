# LoggerKit API 参考

本文档提供 LoggerKit 的完整 API 参考。

## 目录

- [LoggerKit](#LoggerKit)
- [Logger](#logger)
- [数据模型](#数据模型)
- [格式化器](#格式化器)
- [写入器](#写入器)
- [过滤器](#过滤器)
- [完整示例](#完整示例)

---

## LoggerKit

全局日志管理器，提供便捷的静态方法。

### init

初始化 LoggerKit。

```dart
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
})
```

**参数**:

- `minLevel` (可选): 最小日志级别，默认 `LogLevel.debug`
- `enableConsole` (可选): 启用控制台输出，默认 `true`
- `enableFile` (可选): 启用文件日志，默认 `false`
- `enableRemote` (可选): 启用远程日志，默认 `false`
- `filePath` (可选): 文件日志路径
- `remoteUrl` (可选): 远程日志 URL
- `maxFileSize` (可选): 最大文件大小（字节），默认 10MB
- `maxFileCount` (可选): 最大文件数量，默认 5
- `includeTimestamp` (可选): 包含时间戳，默认 `true`
- `includeTag` (可选): 包含标签，默认 `true`
- `includeEmoji` (可选): 包含 emoji，默认 `true`
- `prettyPrint` (可选): 美化输出，默认 `true`

**示例**:

```dart
LoggerKit.init(
  minLevel: LogLevel.debug,
  enableConsole: true,
  enableFile: true,
  filePath: 'logs',
);
```

---

### d

记录 Debug 级别日志。

```dart
static void d(String message, {String? tag, Map<String, dynamic>? data})
```

**参数**:

- `message` (必需): 日志消息
- `tag` (可选): 日志标签
- `data` (可选): 附加数据

**示例**:

```dart
LoggerKit.d('Debug message');
LoggerKit.d('User data loaded', tag: 'DATA', data: {'count': 10});
```

---

### i

记录 Info 级别日志。

```dart
static void i(String message, {String? tag, Map<String, dynamic>? data})
```

**参数**:

- `message` (必需): 日志消息
- `tag` (可选): 日志标签
- `data` (可选): 附加数据

**示例**:

```dart
LoggerKit.i('Info message');
LoggerKit.i('User logged in', tag: 'AUTH', data: {'userId': '12345'});
```

---

### w

记录 Warning 级别日志。

```dart
static void w(String message, {String? tag, Map<String, dynamic>? data})
```

**参数**:

- `message` (必需): 日志消息
- `tag` (可选): 日志标签
- `data` (可选): 附加数据

**示例**:

```dart
LoggerKit.w('Warning message');
LoggerKit.w('API rate limit approaching', tag: 'API', data: {'remaining': 10});
```

---

### e

记录 Error 级别日志。

```dart
static void e(
  String message, {
  String? tag,
  Object? error,
  StackTrace? stackTrace,
  Map<String, dynamic>? data,
})
```

**参数**:

- `message` (必需): 日志消息
- `tag` (可选): 日志标签
- `error` (可选): 错误对象
- `stackTrace` (可选): 堆栈跟踪
- `data` (可选): 附加数据

**示例**:

```dart
try {
  throw Exception('Something went wrong');
} catch (e, stack) {
  LoggerKit.e(
    'Failed to process data',
    tag: 'ERROR',
    error: e,
    stackTrace: stack,
  );
}
```

---

### f

记录 Fatal 级别日志。

```dart
static void f(
  String message, {
  String? tag,
  Object? error,
  StackTrace? stackTrace,
  Map<String, dynamic>? data,
})
```

**参数**:

- `message` (必需): 日志消息
- `tag` (可选): 日志标签
- `error` (可选): 错误对象
- `stackTrace` (可选): 堆栈跟踪
- `data` (可选): 附加数据

**示例**:

```dart
LoggerKit.f(
  'Critical system failure',
  tag: 'SYSTEM',
  error: error,
  stackTrace: stackTrace,
);
```

---

### event

记录事件。

```dart
static void event(String name, {Map<String, dynamic>? data})
```

**参数**:

- `name` (必需): 事件名称
- `data` (可选): 事件数据

**示例**:

```dart
LoggerKit.event('user_login', data: {
  'userId': '12345',
  'timestamp': DateTime.now().toIso8601String(),
});

LoggerKit.event('button_clicked', data: {
  'buttonId': 'submit_button',
  'screen': 'home',
});
```

---

### close

关闭 LoggerKit，释放资源。

```dart
static Future<void> close()
```

**示例**:

```dart
@override
void dispose() {
  LoggerKit.close();
  super.dispose();
}
```

---

### instance

获取 Logger 实例。

```dart
static Logger get instance
```

**返回值**: `Logger` - Logger 实例

**示例**:

```dart
final logger = LoggerKit.instance;
logger.addFilter(MyCustomFilter());
```

---

## Logger

日志记录器类，提供更灵活的日志记录功能。

### 构造函数

```dart
Logger({
  required LogConfig config,
  LogFormatter? formatter,
})
```

**参数**:

- `config` (必需): 日志配置
- `formatter` (可选): 日志格式化器，默认使用 `ColoredFormatter`

**示例**:

```dart
final logger = Logger(
  config: LogConfig(
    minLevel: LogLevel.debug,
    enableConsole: true,
  ),
  formatter: JsonFormatter(),
);
```

---

### log

记录日志。

```dart
Future<void> log(
  LogLevel level,
  String message, {
  String? tag,
  Object? error,
  StackTrace? stackTrace,
  Map<String, dynamic>? data,
})
```

**参数**:

- `level` (必需): 日志级别
- `message` (必需): 日志消息
- `tag` (可选): 日志标签
- `error` (可选): 错误对象
- `stackTrace` (可选): 堆栈跟踪
- `data` (可选): 附加数据

**示例**:

```dart
await logger.log(
  LogLevel.info,
  'User action',
  tag: 'USER',
  data: {'action': 'click'},
);
```

---

### addFilter

添加日志过滤器。

```dart
void addFilter(LogFilter filter)
```

**参数**:

- `filter` (必需): 日志过滤器

**示例**:

```dart
logger.addFilter(TagFilter(['IMPORTANT', 'CRITICAL']));
```

---

### removeFilter

移除日志过滤器。

```dart
void removeFilter(LogFilter filter)
```

**参数**:

- `filter` (必需): 要移除的日志过滤器

**示例**:

```dart
final filter = TagFilter(['IMPORTANT']);
logger.addFilter(filter);
// 稍后移除
logger.removeFilter(filter);
```

---

### close

关闭日志记录器。

```dart
Future<void> close()
```

**示例**:

```dart
await logger.close();
```

---

## 数据模型

### LogLevel

日志级别枚举。

```dart
enum LogLevel {
  debug(0, 'DEBUG', '🔍'),
  info(1, 'INFO', 'ℹ️'),
  warning(2, 'WARNING', '⚠️'),
  error(3, 'ERROR', '❌'),
  fatal(4, 'FATAL', '💀');

  final int value;
  final String name;
  final String emoji;
}
```

**方法**:

- `shouldLog(LogLevel minLevel)` - 判断是否应该记录此级别的日志

**示例**:

```dart
if (LogLevel.info.shouldLog(LogLevel.debug)) {
  // 记录日志
}
```

---

### LogRecord

日志记录类。

```dart
class LogRecord {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? data;
}
```

**方法**:

- `toJson()` - 转换为 JSON 格式

**示例**:

```dart
final record = LogRecord(
  level: LogLevel.info,
  message: 'Test message',
  tag: 'TEST',
);

final json = record.toJson();
```

---

### LogConfig

日志配置类。

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
}
```

**示例**:

```dart
final config = LogConfig(
  minLevel: LogLevel.debug,
  enableConsole: true,
  enableFile: true,
  filePath: 'logs',
  maxFileSize: 10 * 1024 * 1024,
  maxFileCount: 5,
);
```

---

## 格式化器

### LogFormatter

日志格式化器接口。

```dart
abstract class LogFormatter {
  String format(LogRecord record, LogConfig config);
}
```

---

### ColoredFormatter

彩色格式化器（默认）。

```dart
class ColoredFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    // 返回彩色格式化的日志
  }
}
```

**输出格式**:

```text
[2026-03-09 10:30:45] 🔍 [DEBUG] [TAG] Message
```

---

### SimpleFormatter

简单格式化器。

```dart
class SimpleFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    return '${record.level.name}: ${record.message}';
  }
}
```

**输出格式**:

```text
INFO: Message
```

---

### JsonFormatter

JSON 格式化器。

```dart
class JsonFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    return jsonEncode(record.toJson());
  }
}
```

**输出格式**:

```json
{"level":"INFO","message":"Message","timestamp":"2026-03-09T10:30:45.000Z"}
```

---

## 写入器

### LogWriter

日志写入器接口。

```dart
abstract class LogWriter {
  Future<void> write(LogRecord record, String formatted);
  Future<void> close();
}
```

---

### ConsoleWriter

控制台写入器。

```dart
class ConsoleWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    print(formatted);
  }

  @override
  Future<void> close() async {}
}
```

---

### FileWriter

文件写入器，支持自动轮转。

```dart
class FileWriter implements LogWriter {
  FileWriter(LogConfig config);

  @override
  Future<void> write(LogRecord record, String formatted) async {
    // 写入文件，自动轮转
  }

  @override
  Future<void> close() async {
    // 关闭文件
  }
}
```

**特性**:

- 自动文件轮转（超过 maxFileSize）
- 自动清理旧文件（保留 maxFileCount 个）
- 异步写入

---

### RemoteWriter

远程写入器，批量上传日志。

```dart
class RemoteWriter implements LogWriter {
  RemoteWriter(LogConfig config);

  @override
  Future<void> write(LogRecord record, String formatted) async {
    // 缓冲日志，批量上传
  }

  @override
  Future<void> close() async {
    // 上传剩余日志
  }
}
```

**特性**:

- 批量上传（每 10 条或 30 秒）
- 自动重试
- 失败静默处理

---

## 过滤器

### LogFilter

日志过滤器接口。

```dart
abstract class LogFilter {
  bool shouldLog(LogRecord record);
}
```

---

### LevelFilter

级别过滤器。

```dart
class LevelFilter implements LogFilter {
  final LogLevel minLevel;

  LevelFilter(this.minLevel);

  @override
  bool shouldLog(LogRecord record) {
    return record.level.shouldLog(minLevel);
  }
}
```

**示例**:

```dart
final filter = LevelFilter(LogLevel.warning);
logger.addFilter(filter);
```

---

### TagFilter

标签过滤器。

```dart
class TagFilter implements LogFilter {
  final List<String> allowedTags;

  TagFilter(this.allowedTags);

  @override
  bool shouldLog(LogRecord record) {
    return record.tag != null && allowedTags.contains(record.tag);
  }
}
```

**示例**:

```dart
final filter = TagFilter(['IMPORTANT', 'CRITICAL']);
logger.addFilter(filter);
```

---

### CompositeFilter

组合过滤器。

```dart
class CompositeFilter implements LogFilter {
  final List<LogFilter> filters;

  CompositeFilter(this.filters);

  @override
  bool shouldLog(LogRecord record) {
    return filters.every((filter) => filter.shouldLog(record));
  }
}
```

**示例**:

```dart
final filter = CompositeFilter([
  LevelFilter(LogLevel.info),
  TagFilter(['IMPORTANT']),
]);
logger.addFilter(filter);
```

---

## 完整示例

### 基础使用

```dart
import 'package:logger_kit/logger_kit.dart';

void main() {
  // 初始化
  LoggerKit.init(
    minLevel: LogLevel.debug,
    enableConsole: true,
  );

  // 记录日志
  LoggerKit.d('Debug message');
  LoggerKit.i('Info message');
  LoggerKit.w('Warning message');
  LoggerKit.e('Error message');

  // 关闭
  LoggerKit.close();
}
```

### 高级使用

```dart
import 'package:logger_kit/logger_kit.dart';

void main() async {
  // 自定义配置
  final config = LogConfig(
    minLevel: LogLevel.debug,
    enableConsole: true,
    enableFile: true,
    filePath: 'logs',
  );

  // 创建自定义 Logger
  final logger = Logger(
    config: config,
    formatter: JsonFormatter(),
  );

  // 添加过滤器
  logger.addFilter(TagFilter(['IMPORTANT']));

  // 记录日志
  await logger.log(
    LogLevel.info,
    'Important message',
    tag: 'IMPORTANT',
    data: {'key': 'value'},
  );

  // 关闭
  await logger.close();
}
```

### Flutter 应用示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  // 初始化日志
  LoggerKit.init(
    minLevel: kDebugMode ? LogLevel.debug : LogLevel.warning,
    enableConsole: kDebugMode,
    enableFile: true,
    enableRemote: !kDebugMode,
    filePath: 'logs',
    remoteUrl: 'https://log.example.com/api/logs',
  );

  // 捕获全局错误
  FlutterError.onError = (details) {
    LoggerKit.e(
      'Flutter error',
      tag: 'FLUTTER',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoggerKit Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    LoggerKit.event('page_view', data: {
      'page': 'HomePage',
    });
  }

  Future<void> _fetchData() async {
    LoggerKit.i('Fetching data', tag: 'NETWORK');

    try {
      // 模拟网络请求
      await Future.delayed(Duration(seconds: 2));

      LoggerKit.i('Data fetched', tag: 'NETWORK', data: {
        'itemCount': 10,
      });
    } catch (e, stack) {
      LoggerKit.e(
        'Failed to fetch data',
        tag: 'NETWORK',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LoggerKit Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: _fetchData,
          child: Text('Fetch Data'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    LoggerKit.close();
    super.dispose();
  }
}
```

---

## 相关文档

- [快速参考](QUICK_REFERENCE.md)
- [使用指南](USAGE_GUIDE.md)
- [架构设计](ARCHITECTURE.md)
- [代码风格指南](CODE_STYLE.md)
- [贡献指南](../CONTRIBUTING.md)

---

**文档版本**: 1.0  
**更新日期**: 2026-03-09  
**项目**: LoggerKit  
**项目地址**: https://github.com/h1s97x/LoggerKit
