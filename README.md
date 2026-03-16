# LoggerKit

一个功能完善的Flutter日志工具包，支持控制台、文件和远程日志记录。

## 功能特性

- 📝 **多级别日志** - Debug, Info, Warning, Error, Fatal
- 🖥️ **控制台输出** - 彩色格式化输出
- 💾 **文件日志** - 自动轮转和清理
- 📤 **远程日志** - 批量上传到服务器
- 🎨 **自定义格式** - 支持多种格式化器
- 🔍 **日志过滤** - 按级别、标签过滤
- 📊 **事件追踪** - 记录用户行为事件
- ⚡ **高性能** - 异步写入，不阻塞主线程

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  logger_kit:
    path: ../logger_kit  # 本地路径
```

或使用Git依赖：

```yaml
dependencies:
  logger_kit:
    git:
      url: https://github.com/h1s97x/LoggerKit.git
      ref: main
```

## 使用方法

### 1. 初始化

```dart
import 'package:logger_kit/logger_kit.dart';

void main() {
  // 初始化LoggerKit
  LoggerKit.init(
    minLevel: LogLevel.debug,
    enableConsole: true,
    enableFile: true,
    filePath: 'logs',
    enableRemote: false,
    includeEmoji: true,
  );

  runApp(MyApp());
}
```

### 2. 基本日志

```dart
// Debug日志
LoggerKit.d('This is a debug message');

// Info日志
LoggerKit.i('This is an info message');

// Warning日志
LoggerKit.w('This is a warning message');

// Error日志
LoggerKit.e('This is an error message');

// Fatal日志
LoggerKit.f('This is a fatal error');
```

### 3. 带标签的日志

```dart
LoggerKit.i('User logged in', tag: 'AUTH');
LoggerKit.i('Data loaded', tag: 'DATA');
LoggerKit.e('Network error', tag: 'NETWORK');
```

### 4. 带额外数据的日志

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
  // 可能抛出异常的代码
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
// 记录用户行为事件
LoggerKit.event('user_login', data: {
  'userId': '12345',
  'timestamp': DateTime.now().toIso8601String(),
});

LoggerKit.event('button_clicked', data: {
  'buttonId': 'submit_button',
  'screen': 'home',
});
```

### 7. 高级配置

```dart
LoggerKit.init(
  minLevel: LogLevel.info,           // 最小日志级别
  enableConsole: true,                // 启用控制台输出
  enableFile: true,                   // 启用文件日志
  enableRemote: true,                 // 启用远程日志
  filePath: 'logs',                   // 文件日志路径
  remoteUrl: 'https://log.example.com/api/logs',  // 远程日志URL
  maxFileSize: 10 * 1024 * 1024,     // 最大文件大小 (10MB)
  maxFileCount: 5,                    // 最大文件数量
  includeTimestamp: true,             // 包含时间戳
  includeTag: true,                   // 包含标签
  includeEmoji: true,                 // 包含emoji
  prettyPrint: true,                  // 美化输出
);
```

## API参考

### LoggerKit

全局日志管理器。

#### 方法

- `static void init({...})` - 初始化LoggerKit
- `static void d(String message, {...})` - Debug日志
- `static void i(String message, {...})` - Info日志
- `static void w(String message, {...})` - Warning日志
- `static void e(String message, {...})` - Error日志
- `static void f(String message, {...})` - Fatal日志
- `static void event(String name, {...})` - 事件日志
- `static Future<void> close()` - 关闭LoggerKit

### LogLevel

日志级别枚举。

```dart
enum LogLevel {
  debug,    // 调试信息
  info,     // 一般信息
  warning,  // 警告信息
  error,    // 错误信息
  fatal,    // 致命错误
}
```

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

## 日志格式

### 控制台输出

```
[2026-03-08 22:45:30] 🔍 [DEBUG] [TAG] This is a debug message
[2026-03-08 22:45:31] ℹ️ [INFO] [TAG] This is an info message
[2026-03-08 22:45:32] ⚠️ [WARNING] [TAG] This is a warning message
[2026-03-08 22:45:33] ❌ [ERROR] [TAG] This is an error message
  Error: Exception: Something went wrong!
  StackTrace:
    #0      main (file:///path/to/file.dart:10:5)
    #1      _startIsolate.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:301:19)
```

### 文件日志

日志文件自动按大小轮转，保留最近的N个文件。

```
logs/
├── log_1709913930000.txt
├── log_1709913940000.txt
└── log_1709913950000.txt
```

### 远程日志

批量上传到服务器，JSON格式：

```json
{
  "logs": [
    {
      "level": "INFO",
      "message": "User logged in",
      "timestamp": "2026-03-08T22:45:30.000Z",
      "tag": "AUTH",
      "data": {
        "userId": "12345"
      }
    }
  ]
}
```

## 性能优化

- ✅ 异步写入，不阻塞主线程
- ✅ 批量上传远程日志
- ✅ 自动文件轮转和清理
- ✅ 可配置的日志级别过滤

## 最佳实践

### 1. 使用标签分类

```dart
LoggerKit.i('User action', tag: 'USER');
LoggerKit.i('Network request', tag: 'NETWORK');
LoggerKit.i('Database operation', tag: 'DB');
```

### 2. 生产环境配置

```dart
LoggerKit.init(
  minLevel: LogLevel.warning,  // 只记录警告及以上
  enableConsole: false,         // 关闭控制台输出
  enableFile: true,             // 启用文件日志
  enableRemote: true,           // 启用远程日志
);
```

### 3. 开发环境配置

```dart
LoggerKit.init(
  minLevel: LogLevel.debug,     // 记录所有日志
  enableConsole: true,          // 启用控制台输出
  enableFile: false,            // 关闭文件日志
  enableRemote: false,          // 关闭远程日志
  includeEmoji: true,           // 显示emoji
);
```

### 4. 应用退出时关闭

```dart
@override
void dispose() {
  LoggerKit.close();
  super.dispose();
}
```

## 示例应用

查看 [example](example) 目录获取完整示例。

运行示例：

```bash
dart example/logger_kit_example.dart
```

## 常见问题

### Q: 如何查看文件日志？

A: 日志文件保存在指定的 `filePath` 目录下，可以直接打开查看。

### Q: 远程日志上传失败怎么办？

A: 远程日志上传失败会静默处理，不会影响应用运行。可以检查网络连接和服务器配置。

### Q: 如何自定义日志格式？

A: 可以实现 `LogFormatter` 接口创建自定义格式化器：

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

## 贡献

欢迎贡献代码和提出建议！

## 许可证

MIT License

---

**项目地址**: https://github.com/h1s97x/LoggerKit  
**版本**: 1.0.0
