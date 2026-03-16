# LoggerKit 架构设计

本文档描述 LoggerKit 项目的架构设计原则和实现方案。

## 目录

- [概述](#概述)
- [架构原则](#架构原则)
- [项目结构](#项目结构)
- [核心组件](#核心组件)
- [数据流](#数据流)
- [性能优化](#性能优化)
- [扩展性设计](#扩展性设计)

---

## 概述

LoggerKit 是一个功能完善的 Flutter 日志工具包，支持控制台、文件和远程日志记录。项目采用分层架构设计，确保代码的可维护性、可测试性和可扩展性。

### 核心功能

- 多级别日志（Debug, Info, Warning, Error, Fatal）
- 控制台彩色输出
- 文件日志（自动轮转和清理）
- 远程日志（批量上传）
- 自定义格式化器
- 日志过滤
- 事件追踪

---

## 架构原则

### 1. 分层架构

```text
┌─────────────────────────────────────┐
│         应用层 (Application)         │
│         Flutter App / User          │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│         API 层 (API Layer)          │
│           LoggerKit Class              │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│       核心层 (Core Layer)            │
│           Logger Class              │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│      组件层 (Component Layer)        │
│  Formatters / Writers / Filters     │
└─────────────────────────────────────┘
```

### 2. 设计原则

- **单一职责**: 每个类只负责一个功能
- **开闭原则**: 对扩展开放，对修改关闭
- **依赖倒置**: 依赖抽象而非具体实现
- **接口隔离**: 使用小而专注的接口
- **异步优先**: 所有 I/O 操作都是异步的

---

## 项目结构

```text
logger_kit/
├── lib/
│   ├── logger_kit.dart                    # 主导出文件
│   └── src/
│       ├── core/                        # 核心类
│       │   ├── logger.dart             # 日志记录器
│       │   └── logger_kit.dart            # 全局管理器
│       ├── models/                      # 数据模型
│       │   ├── log_level.dart          # 日志级别
│       │   ├── log_record.dart         # 日志记录
│       │   ├── log_config.dart         # 日志配置
│       │   └── models.dart             # 模型导出
│       ├── formatters/                  # 格式化器
│       │   └── log_formatter.dart      # 日志格式化
│       ├── writers/                     # 写入器
│       │   ├── log_writer.dart         # 写入器接口
│       │   ├── file_writer.dart        # 文件写入
│       │   └── remote_writer.dart      # 远程写入
│       └── filters/                     # 过滤器
│           └── log_filter.dart         # 日志过滤
│
├── example/                             # 示例应用
│   └── logger_kit_example.dart
├── benchmark/                           # 性能测试
│   └── logger_kit_benchmark.dart
├── test/                                # 单元测试
└── doc/                                 # 文档
    ├── API.md
    ├── ARCHITECTURE.md
    ├── CODE_STYLE.md
    ├── QUICK_REFERENCE.md
    └── USAGE_GUIDE.md
```

---

## 核心组件

### 1. LoggerKit

全局日志管理器，提供便捷的静态方法。

**职责**:

- 提供统一的 API 接口
- 管理 Logger 实例
- 简化日志记录操作

**关键方法**:

```dart
class LoggerKit {
  static void init({...});
  static void d(String message, {...});
  static void i(String message, {...});
  static void w(String message, {...});
  static void e(String message, {...});
  static void f(String message, {...});
  static void event(String name, {...});
  static Future<void> close();
}
```

### 2. Logger

日志记录器，核心实现类。

**职责**:

- 管理日志配置
- 协调格式化器、写入器和过滤器
- 处理日志记录逻辑

**关键方法**:

```dart
class Logger {
  Logger({required LogConfig config, LogFormatter? formatter});
  
  Future<void> log(LogLevel level, String message, {...});
  void addFilter(LogFilter filter);
  void removeFilter(LogFilter filter);
  Future<void> close();
}
```

### 3. LogFormatter

日志格式化器接口。

**职责**:

- 定义格式化接口
- 提供多种格式化实现

**实现类**:

- `ColoredFormatter` - 彩色格式化（默认）
- `SimpleFormatter` - 简单格式化
- `JsonFormatter` - JSON 格式化

```dart
abstract class LogFormatter {
  String format(LogRecord record, LogConfig config);
}
```

### 4. LogWriter

日志写入器接口。

**职责**:

- 定义写入接口
- 提供多种写入实现

**实现类**:

- `ConsoleWriter` - 控制台输出
- `FileWriter` - 文件写入（自动轮转）
- `RemoteWriter` - 远程上传（批量）

```dart
abstract class LogWriter {
  Future<void> write(LogRecord record, String formatted);
  Future<void> close();
}
```

### 5. LogFilter

日志过滤器接口。

**职责**:

- 定义过滤接口
- 提供多种过滤实现

**实现类**:

- `LevelFilter` - 级别过滤
- `TagFilter` - 标签过滤
- `CompositeFilter` - 组合过滤

```dart
abstract class LogFilter {
  bool shouldLog(LogRecord record);
}
```

---

## 数据流

### 1. 日志记录流程

```text
用户调用
    ↓
LoggerKit.i('message')
    ↓
Logger.log(LogLevel.info, 'message')
    ↓
创建 LogRecord
    ↓
应用过滤器 (Filters)
    ↓
格式化 (Formatter)
    ↓
并行写入 (Writers)
  ├─ ConsoleWriter
  ├─ FileWriter
  └─ RemoteWriter
    ↓
完成
```

### 2. 文件写入流程

```text
Logger.log()
    ↓
FileWriter.write()
    ↓
检查文件大小
    ↓
是否需要轮转？
  ├─ 是 → 创建新文件
  │        清理旧文件
  └─ 否 → 继续
    ↓
写入日志
    ↓
更新文件大小
    ↓
完成
```

### 3. 远程上传流程

```text
Logger.log()
    ↓
RemoteWriter.write()
    ↓
添加到缓冲区
    ↓
是否达到上传条件？
  ├─ 缓冲区满（10条）
  └─ 定时器触发（30秒）
    ↓
批量上传
    ↓
清空缓冲区
    ↓
完成
```

---

## 性能优化

### 1. 异步操作

所有 I/O 操作都是异步的，避免阻塞主线程。

```dart
// 异步写入
Future<void> log(LogLevel level, String message) async {
  final record = LogRecord(...);
  
  // 并行写入
  await Future.wait(
    _writers.map((writer) => writer.write(record, formatted)),
  );
}
```

### 2. 批量上传

远程日志采用批量上传策略，减少网络请求。

```dart
class RemoteWriter implements LogWriter {
  final List<LogRecord> _buffer = [];
  Timer? _flushTimer;
  
  static const int _bufferSize = 10;
  static const Duration _flushInterval = Duration(seconds: 30);
  
  @override
  Future<void> write(LogRecord record, String formatted) async {
    _buffer.add(record);
    
    if (_buffer.length >= _bufferSize) {
      await _flush();
    }
  }
}
```

### 3. 文件轮转

自动管理文件大小和数量，避免占用过多磁盘空间。

```dart
class FileWriter implements LogWriter {
  Future<void> _ensureFile() async {
    if (_currentSize >= config.maxFileSize) {
      await _rotateFile();
    }
  }
  
  Future<void> _rotateFile() async {
    // 创建新文件
    // 清理旧文件
  }
}
```

### 4. 过滤优化

在格式化之前应用过滤器，避免不必要的格式化操作。

```dart
Future<void> log(LogLevel level, String message) async {
  final record = LogRecord(...);
  
  // 先过滤
  if (!_shouldLog(record)) return;
  
  // 再格式化
  final formatted = _formatter.format(record, config);
  
  // 最后写入
  await Future.wait(
    _writers.map((writer) => writer.write(record, formatted)),
  );
}
```

---

## 扩展性设计

### 1. 添加新的格式化器

**步骤 1**: 实现 `LogFormatter` 接口

```dart
class XmlFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    return '''
      <log>
        <level>${record.level.name}</level>
        <message>${record.message}</message>
        <timestamp>${record.timestamp.toIso8601String()}</timestamp>
      </log>
    ''';
  }
}
```

**步骤 2**: 使用自定义格式化器

```dart
final logger = Logger(
  config: config,
  formatter: XmlFormatter(),
);
```

### 2. 添加新的写入器

**步骤 1**: 实现 `LogWriter` 接口

```dart
class DatabaseWriter implements LogWriter {
  final Database _db;
  
  DatabaseWriter(this._db);
  
  @override
  Future<void> write(LogRecord record, String formatted) async {
    await _db.insert('logs', record.toJson());
  }
  
  @override
  Future<void> close() async {
    await _db.close();
  }
}
```

**步骤 2**: 添加到 Logger

```dart
class Logger {
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
    
    // 添加自定义写入器
    _writers.add(DatabaseWriter(database));
  }
}
```

### 3. 添加新的过滤器

**步骤 1**: 实现 `LogFilter` 接口

```dart
class TimeRangeFilter implements LogFilter {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  
  TimeRangeFilter(this.startTime, this.endTime);
  
  @override
  bool shouldLog(LogRecord record) {
    final now = TimeOfDay.fromDateTime(record.timestamp);
    return _isInRange(now, startTime, endTime);
  }
  
  bool _isInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    // 实现时间范围判断
  }
}
```

**步骤 2**: 添加到 Logger

```dart
final logger = LoggerKit.instance;
logger.addFilter(TimeRangeFilter(
  TimeOfDay(hour: 9, minute: 0),
  TimeOfDay(hour: 18, minute: 0),
));
```

### 4. 扩展日志级别

虽然不推荐修改现有级别，但可以通过自定义方法实现：

```dart
extension CustomLogLevels on LoggerKit {
  static void trace(String message, {String? tag, Map<String, dynamic>? data}) {
    // 使用 debug 级别，但添加特殊标记
    LoggerKit.d('[TRACE] $message', tag: tag, data: data);
  }
  
  static void verbose(String message, {String? tag, Map<String, dynamic>? data}) {
    LoggerKit.d('[VERBOSE] $message', tag: tag, data: data);
  }
}

// 使用
CustomLogLevels.trace('Detailed trace message');
```

---

## 测试策略

### 1. 单元测试

测试各个组件的独立功能。

```dart
test('LevelFilter should filter logs correctly', () {
  final filter = LevelFilter(LogLevel.warning);
  
  final debugRecord = LogRecord(
    level: LogLevel.debug,
    message: 'Debug',
  );
  
  final errorRecord = LogRecord(
    level: LogLevel.error,
    message: 'Error',
  );
  
  expect(filter.shouldLog(debugRecord), isFalse);
  expect(filter.shouldLog(errorRecord), isTrue);
});
```

### 2. 集成测试

测试组件之间的交互。

```dart
test('Logger should write to all enabled writers', () async {
  final config = LogConfig(
    minLevel: LogLevel.debug,
    enableConsole: true,
    enableFile: true,
  );
  
  final logger = Logger(config: config);
  
  await logger.log(LogLevel.info, 'Test message');
  
  // 验证日志已写入
});
```

### 3. 性能测试

使用基准测试系统测试性能。

```dart
void main() async {
  final stopwatch = Stopwatch()..start();
  
  for (var i = 0; i < 10000; i++) {
    LoggerKit.i('Test message $i');
  }
  
  stopwatch.stop();
  print('10000 logs in ${stopwatch.elapsedMilliseconds}ms');
}
```

---

## 安全考虑

### 1. 数据验证

验证所有输入参数。

```dart
static void init({
  LogLevel minLevel = LogLevel.debug,
  int maxFileSize = 10 * 1024 * 1024,
  int maxFileCount = 5,
}) {
  if (maxFileSize <= 0) {
    throw ArgumentError('maxFileSize must be positive');
  }
  
  if (maxFileCount <= 0) {
    throw ArgumentError('maxFileCount must be positive');
  }
  
  // 初始化
}
```

### 2. 敏感信息过滤

避免记录敏感信息。

```dart
class SensitiveDataFilter implements LogFilter {
  final List<String> sensitiveKeys = ['password', 'token', 'secret'];
  
  @override
  bool shouldLog(LogRecord record) {
    if (record.data != null) {
      for (var key in sensitiveKeys) {
        if (record.data!.containsKey(key)) {
          return false;
        }
      }
    }
    return true;
  }
}
```

### 3. 错误处理

提供清晰的错误信息。

```dart
try {
  await _sink?.writeln(formatted);
} catch (e) {
  print('Failed to write log: $e');
  // 不抛出异常，避免影响应用运行
}
```

---

## 总结

LoggerKit 的架构设计遵循以下原则：

1. **简单易用**: 提供直观的 API 接口
2. **高性能**: 异步操作、批量上传、文件轮转
3. **可扩展**: 易于添加新的格式化器、写入器和过滤器
4. **可测试**: 完善的测试策略
5. **安全可靠**: 数据验证、错误处理、敏感信息过滤

这种架构确保了项目的长期可维护性和可扩展性。

---

## 相关文档

- [API 参考](API.md)
- [快速参考](QUICK_REFERENCE.md)
- [使用指南](USAGE_GUIDE.md)
- [代码风格指南](CODE_STYLE.md)
- [贡献指南](../CONTRIBUTING.md)

---

**文档版本**: 1.0  
**创建日期**: 2026-03-09  
**项目**: LoggerKit  
**项目地址**: https://github.com/h1s97x/LoggerKit
