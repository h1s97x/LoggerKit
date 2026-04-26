# LoggerKit

> 一个功能完善的 Flutter 日志工具包，v2.0 全面升级

## 功能特性

- 📝 **多级别日志** - Debug, Info, Warning, Error, Fatal
- 🖥️ **控制台输出** - 彩色格式化输出
- 💾 **文件日志** - 自动轮转和清理
- 📤 **远程日志** - 批量上传到服务器
- 🏷️ **命名空间** - 模块化日志管理
- 🔒 **隐私过滤** - 自动过滤敏感数据
- 🔄 **拦截器** - 灵活扩展日志处理链
- 📎 **上下文注入** - 结构化日志数据
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

### 7. Builder 模式 (v2.0 推荐)

```dart
// 使用 Builder 模式进行链式配置
LoggerKit.builder()
  ..minLevel(LogLevel.debug)
  ..console(prettyPrint: true)
  ..file(path: './logs', maxSize: 10 * 1024 * 1024)
  ..privacyFields(['password', 'token'])
  ..addInterceptor(ContextInterceptor())
  ..addInterceptor(PrivacyInterceptor())
  ..build();
```

### 8. 命名空间 (v2.0)

```dart
// 创建命名空间 logger
final networkLogger = LoggerKit.namespace('network');
networkLogger.i('API request sent');

// 使用预设快捷方式
LoggerKit.network.i('Network activity');
LoggerKit.database.d('Query executed');
LoggerKit.ui.d('Screen rendered');
```

### 9. 全局上下文 (v2.0)

```dart
// 设置全局上下文，所有日志都会包含
LoggerKit.setContext(LogContext(
  userId: 'user_123',
  sessionId: 'session_abc',
  traceId: 'trace_xyz',
));

// 添加自定义字段
LoggerKit.context.set('requestId', 'req_456');

// 所有日志都会自动包含这些上下文
LoggerKit.i('User action');  // 自动包含 userId, sessionId, traceId, requestId
```

### 10. 自定义拦截器 (v2.0)

```dart
// 创建自定义拦截器
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

// 添加到 Logger
LoggerKit.builder()
  ..addInterceptor(UserInterceptor())
  ..build();
```

### 11. 隐私数据过滤 (v2.0)

```dart
// 默认过滤敏感字段：password, token, apiKey, secret 等
LoggerKit.builder()
  ..console()
  ..privacyFields(['customSecret'])  // 添加自定义敏感字段
  ..build();

// 记录日志时自动过滤
LoggerKit.i('User logged in', data: {
  'username': 'john',
  'password': 'secret123',  // 自动被过滤为 ***
  'token': 'abc123',        // 自动被过滤为 ***
});

// 输出: User logged in | {username: john, password: ***, token: ***}

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
**版本**: 1.1.0
