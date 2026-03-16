# LoggerKit 快速参考

本文档提供 LoggerKit 的快速参考指南。

## 快速开始

### 安装

```yaml
dependencies:
  logger_kit:
    git:
      url: https://github.com/h1s97x/LoggerKit.git
      ref: main
```

### 导入

```dart
import 'package:logger_kit/logger_kit.dart';
```

---

## 核心功能

### 1. 初始化

```dart
// 基础初始化
LoggerKit.init();

// 自定义配置
LoggerKit.init(
  minLevel: LogLevel.debug,
  enableConsole: true,
  enableFile: true,
  filePath: 'logs',
);
```

### 2. 基本日志

```dart
// Debug 日志
LoggerKit.d('Debug message');

// Info 日志
LoggerKit.i('Info message');

// Warning 日志
LoggerKit.w('Warning message');

// Error 日志
LoggerKit.e('Error message');

// Fatal 日志
LoggerKit.f('Fatal error');
```

### 3. 带标签的日志

```dart
LoggerKit.i('User logged in', tag: 'AUTH');
LoggerKit.i('Data loaded', tag: 'DATA');
LoggerKit.e('Network error', tag: 'NETWORK');
```

### 4. 带数据的日志

```dart
LoggerKit.i(
  'API request completed',
  tag: 'API',
  data: {
    'url': 'https://api.example.com/users',
    'method': 'GET',
    'status': 200,
    'duration': 150,
  },
);
```

### 5. 错误日志

```dart
try {
  throw Exception('Something went wrong!');
} catch (e, stack) {
  LoggerKit.e(
    'Failed to process data',
    tag: 'ERROR',
    error: e,
    stackTrace: stack,
  );
}
```

### 6. 事件追踪

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

### 7. 关闭日志

```dart
// 应用退出时关闭
await LoggerKit.close();
```

---

## 配置选项

### 开发环境

```dart
LoggerKit.init(
  minLevel: LogLevel.debug,
  enableConsole: true,
  enableFile: false,
  enableRemote: false,
  includeEmoji: true,
  prettyPrint: true,
);
```

### 生产环境

```dart
LoggerKit.init(
  minLevel: LogLevel.warning,
  enableConsole: false,
  enableFile: true,
  enableRemote: true,
  filePath: 'logs',
  remoteUrl: 'https://log.example.com/api/logs',
  maxFileSize: 10 * 1024 * 1024,
  maxFileCount: 5,
);
```

### 完整配置

```dart
LoggerKit.init(
  minLevel: LogLevel.info,           // 最小日志级别
  enableConsole: true,                // 启用控制台输出
  enableFile: true,                   // 启用文件日志
  enableRemote: true,                 // 启用远程日志
  filePath: 'logs',                   // 文件日志路径
  remoteUrl: 'https://log.example.com/api/logs',  // 远程日志 URL
  maxFileSize: 10 * 1024 * 1024,     // 最大文件大小 (10MB)
  maxFileCount: 5,                    // 最大文件数量
  includeTimestamp: true,             // 包含时间戳
  includeTag: true,                   // 包含标签
  includeEmoji: true,                 // 包含 emoji
  prettyPrint: true,                  // 美化输出
);
```

---

## 数据模型

### LogLevel

```dart
enum LogLevel {
  debug,    // 调试信息 🔍
  info,     // 一般信息 ℹ️
  warning,  // 警告信息 ⚠️
  error,    // 错误信息 ❌
  fatal,    // 致命错误 💀
}
```

### LogRecord

```dart
class LogRecord {
  LogLevel level;              // 日志级别
  String message;              // 日志消息
  DateTime timestamp;          // 时间戳
  String? tag;                 // 标签
  Object? error;               // 错误对象
  StackTrace? stackTrace;      // 堆栈跟踪
  Map<String, dynamic>? data;  // 附加数据
}
```

### LogConfig

```dart
class LogConfig {
  LogLevel minLevel;           // 最小日志级别
  bool enableConsole;          // 启用控制台输出
  bool enableFile;             // 启用文件日志
  bool enableRemote;           // 启用远程日志
  String? filePath;            // 文件日志路径
  String? remoteUrl;           // 远程日志 URL
  int maxFileSize;             // 最大文件大小
  int maxFileCount;            // 最大文件数量
  bool includeTimestamp;       // 包含时间戳
  bool includeTag;             // 包含标签
  bool includeEmoji;           // 包含 emoji
  bool prettyPrint;            // 美化输出
}
```

---

## 格式化器

### ColoredFormatter (默认)

```dart
// 彩色格式化输出
[2026-03-09 10:30:45] 🔍 [DEBUG] [TAG] Message
```

### SimpleFormatter

```dart
// 简单格式化输出
class SimpleFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    return '${record.level}: ${record.message}';
  }
}
```

### JsonFormatter

```dart
// JSON 格式化输出
class JsonFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    return jsonEncode(record.toJson());
  }
}
```

---

## 写入器

### ConsoleWriter

```dart
// 控制台输出
class ConsoleWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    print(formatted);
  }
}
```

### FileWriter

```dart
// 文件写入（自动轮转）
class FileWriter implements LogWriter {
  // 自动管理文件大小和数量
}
```

### RemoteWriter

```dart
// 远程上传（批量）
class RemoteWriter implements LogWriter {
  // 每 10 条或 30 秒上传一次
}
```

---

## 过滤器

### LevelFilter

```dart
// 按级别过滤
class LevelFilter implements LogFilter {
  final LogLevel minLevel;
  
  @override
  bool shouldLog(LogRecord record) {
    return record.level.shouldLog(minLevel);
  }
}
```

### TagFilter

```dart
// 按标签过滤
class TagFilter implements LogFilter {
  final List<String> allowedTags;
  
  @override
  bool shouldLog(LogRecord record) {
    return allowedTags.contains(record.tag);
  }
}
```

### CompositeFilter

```dart
// 组合过滤器
class CompositeFilter implements LogFilter {
  final List<LogFilter> filters;
  
  @override
  bool shouldLog(LogRecord record) {
    return filters.every((f) => f.shouldLog(record));
  }
}
```

---

## 高级用法

### 自定义格式化器

```dart
class MyFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    return '${record.level}: ${record.message}';
  }
}

final logger = Logger(
  config: config,
  formatter: MyFormatter(),
);
```

### 自定义过滤器

```dart
class MyFilter implements LogFilter {
  @override
  bool shouldLog(LogRecord record) {
    return record.tag == 'IMPORTANT';
  }
}

logger.addFilter(MyFilter());
```

### 自定义写入器

```dart
class MyWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    // 自定义写入逻辑
  }

  @override
  Future<void> close() async {
    // 清理资源
  }
}
```

---

## 最佳实践

### 1. 使用标签分类

```dart
// 网络请求
LoggerKit.i('API request', tag: 'NETWORK');

// 数据库操作
LoggerKit.i('Database query', tag: 'DB');

// 用户行为
LoggerKit.i('User action', tag: 'USER');

// 认证相关
LoggerKit.i('Login attempt', tag: 'AUTH');
```

### 2. 记录关键信息

```dart
// 记录 API 请求
LoggerKit.i('API request', tag: 'API', data: {
  'url': url,
  'method': method,
  'status': statusCode,
  'duration': duration,
});

// 记录错误
try {
  await fetchData();
} catch (e, stack) {
  LoggerKit.e(
    'Failed to fetch data',
    tag: 'NETWORK',
    error: e,
    stackTrace: stack,
  );
}
```

### 3. 环境区分

```dart
import 'package:flutter/foundation.dart';

void initLogging() {
  if (kDebugMode) {
    // 开发环境
    LoggerKit.init(
      minLevel: LogLevel.debug,
      enableConsole: true,
      enableFile: false,
    );
  } else {
    // 生产环境
    LoggerKit.init(
      minLevel: LogLevel.warning,
      enableConsole: false,
      enableFile: true,
      enableRemote: true,
    );
  }
}
```

### 4. 资源管理

```dart
@override
void dispose() {
  LoggerKit.close();
  super.dispose();
}
```

---

## 常用标签

```dart
// 系统标签
'SYSTEM'    // 系统相关
'APP'       // 应用相关
'FLUTTER'   // Flutter 框架

// 功能标签
'AUTH'      // 认证授权
'NETWORK'   // 网络请求
'DB'        // 数据库
'CACHE'     // 缓存
'STORAGE'   // 存储

// 业务标签
'USER'      // 用户相关
'ORDER'     // 订单相关
'PAYMENT'   // 支付相关
'EVENT'     // 事件追踪

// 性能标签
'PERFORMANCE'  // 性能监控
'MEMORY'       // 内存使用
'TIMING'       // 时间统计
```

---

## 日志输出格式

### 控制台输出

```text
[2026-03-09 10:30:45] 🔍 [DEBUG] [TAG] This is a debug message
[2026-03-09 10:30:46] ℹ️ [INFO] [TAG] This is an info message
[2026-03-09 10:30:47] ⚠️ [WARNING] [TAG] This is a warning message
[2026-03-09 10:30:48] ❌ [ERROR] [TAG] This is an error message
  Error: Exception: Something went wrong!
  StackTrace:
    #0      main (file:///path/to/file.dart:10:5)
```

### 文件日志

```text
logs/
├── log_1709913930000.txt
├── log_1709913940000.txt
└── log_1709913950000.txt
```

### 远程日志 (JSON)

```json
{
  "logs": [
    {
      "level": "INFO",
      "message": "User logged in",
      "timestamp": "2026-03-09T10:30:45.000Z",
      "tag": "AUTH",
      "data": {
        "userId": "12345"
      }
    }
  ]
}
```

---

## 常见问题

### Q: 日志没有输出？

A: 检查日志级别设置和输出是否启用。

```dart
LoggerKit.init(
  minLevel: LogLevel.debug,  // 设置为最低级别
  enableConsole: true,       // 确保启用输出
);
```

### Q: 文件日志没有生成？

A: 检查文件路径和权限。

```dart
LoggerKit.init(
  enableFile: true,
  filePath: 'logs',  // 确保路径正确
);
```

### Q: 远程日志上传失败？

A: 检查网络连接和服务器 URL。

```dart
LoggerKit.init(
  enableRemote: true,
  remoteUrl: 'https://log.example.com/api/logs',  // 确保 URL 正确
);
```

---

## 相关资源

- [完整文档](../README.md)
- [使用指南](USAGE_GUIDE.md)
- [API 参考](API.md)
- [架构设计](ARCHITECTURE.md)
- [代码风格指南](CODE_STYLE.md)
- [贡献指南](../CONTRIBUTING.md)
- [GitHub 仓库](https://github.com/h1s97x/LoggerKit)

---

**文档版本**: 1.0  
**创建日期**: 2026-03-09  
**项目**: LoggerKit  
**项目地址**: https://github.com/h1s97x/LoggerKit
