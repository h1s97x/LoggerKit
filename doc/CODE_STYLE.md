# LoggerKit 代码风格指南

本文档定义了 LoggerKit 项目的代码风格规范。

## 基本原则

1. **一致性**: 保持代码风格一致
2. **可读性**: 代码应该易于理解
3. **简洁性**: 避免不必要的复杂性
4. **文档化**: 为公共 API 提供文档注释

---

## Dart 代码风格

### 1. 命名规范

#### 类名 - UpperCamelCase

```dart
✅ 好的示例
class LoggerKit {}
class Logger {}
class LogFormatter {}
class FileWriter {}

❌ 不好的示例
class logger_kit {}
class logger {}
class logFormatter {}
class file_writer {}
```

#### 变量和方法名 - lowerCamelCase

```dart
✅ 好的示例
String message;
int maxFileSize;
Future<void> writeLog();

❌ 不好的示例
String Message;
int max_file_size;
Future<void> write_log();
```

#### 常量 - lowerCamelCase

```dart
✅ 好的示例
const defaultTimeout = Duration(seconds: 30);
const maxRetries = 3;
const bufferSize = 10;

❌ 不好的示例
const DEFAULT_TIMEOUT = Duration(seconds: 30);
const MAX_RETRIES = 3;
const BUFFER_SIZE = 10;
```

#### 私有成员 - 以下划线开头

```dart
✅ 好的示例
String _privateField;
void _privateMethod() {}
Logger? _instance;

❌ 不好的示例
String privateField;
void privateMethod() {}
Logger? instance;
```

#### 文件名 - snake_case

```dart
✅ 好的示例
logger_kit.dart
logger.dart
log_formatter.dart
file_writer.dart

❌ 不好的示例
LoggerKit.dart
Logger.dart
logFormatter.dart
FileWriter.dart
```

### 2. 代码格式

#### 缩进 - 2 个空格

```dart
✅ 好的示例
class Logger {
  Future<void> log(LogLevel level, String message) async {
    final record = LogRecord(level: level, message: message);
    await _writeLog(record);
  }
}

❌ 不好的示例
class Logger {
    Future<void> log(LogLevel level, String message) async {
        final record = LogRecord(level: level, message: message);
        await _writeLog(record);
    }
}
```

#### 行长度 - 最多 80 字符

```dart
✅ 好的示例
LoggerKit.init(
  minLevel: LogLevel.debug,
  enableConsole: true,
  enableFile: true,
);

❌ 不好的示例
LoggerKit.init(minLevel: LogLevel.debug, enableConsole: true, enableFile: true, filePath: 'logs');
```

#### 导入顺序

1. Dart SDK 导入
2. Flutter 导入
3. 第三方包导入
4. 项目内部导入

```dart
✅ 好的示例
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'models/log_record.dart';
import 'models/log_level.dart';

❌ 不好的示例
import 'models/log_record.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';
```

### 3. 文档注释

#### 公共 API - 使用 /// 注释

```dart
✅ 好的示例
/// 记录 Info 级别日志。
///
/// [message] 日志消息。
/// [tag] 可选的日志标签。
/// [data] 可选的附加数据。
///
/// 示例:
/// ```dart
/// LoggerKit.i('User logged in', tag: 'AUTH');
/// ```
static void i(String message, {String? tag, Map<String, dynamic>? data}) {
  // 实现
}

❌ 不好的示例
// 记录 Info 日志
static void i(String message, {String? tag, Map<String, dynamic>? data}) {
  // 实现
}
```

#### 参数文档

```dart
✅ 好的示例
/// 初始化 LoggerKit。
///
/// [minLevel] 最小日志级别，默认 [LogLevel.debug]。
/// [enableConsole] 启用控制台输出，默认 `true`。
/// [enableFile] 启用文件日志，默认 `false`。
/// [filePath] 文件日志路径。
///
/// 示例:
/// ```dart
/// LoggerKit.init(
///   minLevel: LogLevel.debug,
///   enableConsole: true,
/// );
/// ```
static void init({
  LogLevel minLevel = LogLevel.debug,
  bool enableConsole = true,
  bool enableFile = false,
  String? filePath,
}) {
  // 实现
}
```

### 4. 类型注解

#### 始终指定类型

```dart
✅ 好的示例
final String message = 'Hello';
final int maxSize = 1024;
final List<String> tags = ['AUTH', 'USER'];

❌ 不好的示例
final message = 'Hello';
final maxSize = 1024;
final tags = ['AUTH', 'USER'];
```

#### 方法返回类型

```dart
✅ 好的示例
Future<void> writeLog(LogRecord record) async {
  // 实现
}

String formatLog(LogRecord record) {
  // 实现
}

❌ 不好的示例
writeLog(record) async {
  // 实现
}

formatLog(record) {
  // 实现
}
```

### 5. 异步编程

#### 使用 async/await

```dart
✅ 好的示例
Future<void> log(LogLevel level, String message) async {
  final record = LogRecord(level: level, message: message);
  await _writeLog(record);
}

❌ 不好的示例
Future<void> log(LogLevel level, String message) {
  final record = LogRecord(level: level, message: message);
  return _writeLog(record);
}
```

#### 错误处理

```dart
✅ 好的示例
try {
  await _sink?.writeln(formatted);
} catch (e) {
  print('Failed to write log: $e');
  // 不抛出异常，避免影响应用运行
}

❌ 不好的示例
try {
  await _sink?.writeln(formatted);
} catch (e) {
  // 忽略错误
}
```

### 6. 空安全

#### 使用空安全特性

```dart
✅ 好的示例
String? tag;  // 可空类型
String message = '';  // 非空类型

if (tag != null) {
  print(tag.length);  // 安全访问
}

print(tag?.length ?? 0);  // 空安全操作符

❌ 不好的示例
String tag;  // 未初始化

if (tag != null) {
  print(tag.length);
}
```

### 7. 常量和枚举

#### 使用 const 构造函数

```dart
✅ 好的示例
const defaultTimeout = Duration(seconds: 30);
const emptyList = <String>[];
const defaultConfig = LogConfig(minLevel: LogLevel.debug);

❌ 不好的示例
final defaultTimeout = Duration(seconds: 30);
final emptyList = <String>[];
final defaultConfig = LogConfig(minLevel: LogLevel.debug);
```

#### 枚举命名

```dart
✅ 好的示例
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

❌ 不好的示例
enum LogLevel {
  DEBUG,
  INFO,
  WARNING,
  ERROR,
  FATAL,
}
```

### 8. 类设计

#### 单一职责原则

```dart
✅ 好的示例
// 每个类只负责一个功能
class ConsoleWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    print(formatted);
  }
}

class FileWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    await _sink?.writeln(formatted);
  }
}

❌ 不好的示例
// 一个类负责多个功能
class LogWriter {
  Future<void> writeToConsole(String message) async {}
  Future<void> writeToFile(String message) async {}
  Future<void> writeToRemote(String message) async {}
}
```

#### 接口隔离原则

```dart
✅ 好的示例
// 小而专注的接口
abstract class LogFormatter {
  String format(LogRecord record, LogConfig config);
}

abstract class LogWriter {
  Future<void> write(LogRecord record, String formatted);
  Future<void> close();
}

abstract class LogFilter {
  bool shouldLog(LogRecord record);
}

❌ 不好的示例
// 大而全的接口
abstract class LogHandler {
  String format(LogRecord record);
  Future<void> write(String formatted);
  bool shouldLog(LogRecord record);
  Future<void> close();
}
```

---

## 测试代码风格

### 1. 测试命名

```dart
✅ 好的示例
test('should record debug log', () {
  LoggerKit.d('Debug message');
  // 验证
});

test('should filter logs by level', () {
  final filter = LevelFilter(LogLevel.warning);
  // 测试
});

❌ 不好的示例
test('test1', () {
  // 测试代码
});

test('debug', () {
  // 测试代码
});
```

### 2. 测试结构

```dart
✅ 好的示例
group('LoggerKit', () {
  group('init', () {
    test('should initialize with default config', () {
      // Arrange
      // Act
      LoggerKit.init();
      // Assert
      expect(LoggerKit.instance, isNotNull);
    });
    
    test('should initialize with custom config', () {
      // 测试代码
    });
  });
  
  group('log methods', () {
    test('should record debug log', () {
      // 测试代码
    });
  });
});

❌ 不好的示例
test('test LoggerKit', () {
  LoggerKit.init();
  LoggerKit.d('Debug');
  LoggerKit.i('Info');
  // 多个测试混在一起
});
```

### 3. 测试断言

```dart
✅ 好的示例
test('should format log correctly', () {
  final formatter = ColoredFormatter();
  final record = LogRecord(
    level: LogLevel.info,
    message: 'Test',
  );
  
  final formatted = formatter.format(record, config);
  
  expect(formatted, contains('INFO'));
  expect(formatted, contains('Test'));
});

❌ 不好的示例
test('formatter test', () {
  final formatter = ColoredFormatter();
  final formatted = formatter.format(record, config);
  // 没有断言
});
```

---

## 代码审查清单

### 提交前检查

- [ ] 代码符合命名规范
- [ ] 添加了必要的文档注释
- [ ] 所有公共 API 都有文档
- [ ] 代码格式正确（运行 `dart format`）
- [ ] 没有编译警告（运行 `flutter analyze`）
- [ ] 通过所有测试（运行 `flutter test`）
- [ ] 添加了新功能的测试
- [ ] 更新了相关文档

### 代码审查要点

- [ ] 代码逻辑清晰
- [ ] 错误处理完善
- [ ] 没有内存泄漏
- [ ] 性能考虑合理
- [ ] 安全性考虑充分
- [ ] 可测试性良好

---

## 工具配置

### analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_print
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - unawaited_futures
    - use_key_in_widget_constructors
```

### 格式化命令

```bash
# 格式化所有 Dart 代码
dart format .

# 检查代码风格
flutter analyze

# 运行测试
flutter test

# 运行示例
dart example/logger_kit_example.dart

# 运行基准测试
dart benchmark/logger_kit_benchmark.dart
```

---

## 最佳实践

### 1. 使用有意义的变量名

```dart
✅ 好的示例
final maxFileSize = 10 * 1024 * 1024;
final currentFileSize = 0;
final logMessage = 'User logged in';

❌ 不好的示例
final max = 10 * 1024 * 1024;
final size = 0;
final msg = 'User logged in';
```

### 2. 避免魔法数字

```dart
✅ 好的示例
const maxFileSize = 10 * 1024 * 1024;  // 10MB
const maxFileCount = 5;
const bufferSize = 10;

if (fileSize > maxFileSize) {
  rotateFile();
}

❌ 不好的示例
if (fileSize > 10485760) {
  rotateFile();
}
```

### 3. 使用早期返回

```dart
✅ 好的示例
bool shouldLog(LogRecord record) {
  if (record.level.value < minLevel.value) {
    return false;
  }
  
  if (record.tag == null) {
    return false;
  }
  
  return true;
}

❌ 不好的示例
bool shouldLog(LogRecord record) {
  if (record.level.value >= minLevel.value) {
    if (record.tag != null) {
      return true;
    }
  }
  return false;
}
```

### 4. 使用命名参数

```dart
✅ 好的示例
LoggerKit.init(
  minLevel: LogLevel.debug,
  enableConsole: true,
  enableFile: true,
);

❌ 不好的示例
LoggerKit.init(LogLevel.debug, true, true);
```

### 5. 避免过长的方法

```dart
✅ 好的示例
Future<void> log(LogLevel level, String message) async {
  final record = _createRecord(level, message);
  
  if (!_shouldLog(record)) return;
  
  final formatted = _formatRecord(record);
  await _writeRecord(record, formatted);
}

LogRecord _createRecord(LogLevel level, String message) {
  return LogRecord(level: level, message: message);
}

bool _shouldLog(LogRecord record) {
  return _filters.every((filter) => filter.shouldLog(record));
}

❌ 不好的示例
Future<void> log(LogLevel level, String message) async {
  // 100+ 行代码
}
```

---

## 示例代码

### 好的示例

```dart
/// 日志记录器。
///
/// 提供日志记录功能，支持多种输出方式。
class Logger {
  /// 日志配置。
  final LogConfig config;
  
  /// 日志格式化器。
  final LogFormatter _formatter;
  
  /// 日志写入器列表。
  final List<LogWriter> _writers = [];
  
  /// 日志过滤器列表。
  final List<LogFilter> _filters = [];

  /// 创建日志记录器。
  ///
  /// [config] 日志配置。
  /// [formatter] 日志格式化器，默认使用 [ColoredFormatter]。
  Logger({
    required this.config,
    LogFormatter? formatter,
  }) : _formatter = formatter ?? ColoredFormatter() {
    _initWriters();
    _initFilters();
  }

  /// 记录日志。
  ///
  /// [level] 日志级别。
  /// [message] 日志消息。
  /// [tag] 可选的日志标签。
  /// [error] 可选的错误对象。
  /// [stackTrace] 可选的堆栈跟踪。
  /// [data] 可选的附加数据。
  Future<void> log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) async {
    final record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );

    if (!_shouldLog(record)) return;

    final formatted = _formatter.format(record, config);

    await Future.wait(
      _writers.map((writer) => writer.write(record, formatted)),
    );
  }

  /// 初始化写入器。
  void _initWriters() {
    if (config.enableConsole) {
      _writers.add(ConsoleWriter());
    }
    
    if (config.enableFile && config.filePath != null) {
      _writers.add(FileWriter(config));
    }
    
    if (config.enableRemote && config.remoteUrl != null) {
      _writers.add(RemoteWriter(config));
    }
  }

  /// 初始化过滤器。
  void _initFilters() {
    _filters.add(LevelFilter(config.minLevel));
  }

  /// 判断是否应该记录日志。
  bool _shouldLog(LogRecord record) {
    return _filters.every((filter) => filter.shouldLog(record));
  }

  /// 关闭日志记录器。
  Future<void> close() async {
    await Future.wait(_writers.map((writer) => writer.close()));
    _writers.clear();
  }
}
```

---

## 相关文档

- [API 参考](API.md)
- [架构设计](ARCHITECTURE.md)
- [快速参考](QUICK_REFERENCE.md)
- [使用指南](USAGE_GUIDE.md)
- [贡献指南](../CONTRIBUTING.md)

---

**文档版本**: 1.0  
**创建日期**: 2026-03-09  
**项目**: LoggerKit  
**项目地址**: https://github.com/h1s97x/LoggerKit
