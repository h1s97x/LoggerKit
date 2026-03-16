# LoggerKit 使用指南

本文档提供 LoggerKit 的详细使用指南和最佳实践。

## 目录

- [安装](#安装)
- [基础使用](#基础使用)
- [高级功能](#高级功能)
- [配置选项](#配置选项)
- [最佳实践](#最佳实践)
- [故障排查](#故障排查)

## 安装

### 添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  logger_kit:
    git:
      url: https://github.com/h1s97x/LoggerKit.git
      ref: main
```

### 导入包

```dart
import 'package:logger_kit/logger_kit.dart';
```

## 基础使用

### 1. 初始化

```dart
void main() {
  // 基础初始化
  LoggerKit.init();

  // 或使用自定义配置
  LoggerKit.init(
    minLevel: LogLevel.debug,
    enableConsole: true,
    enableFile: true,
    filePath: 'logs',
  );

  runApp(MyApp());
}
```

### 2. 记录日志

```dart
// Debug 日志
LoggerKit.d('This is a debug message');

// Info 日志
LoggerKit.i('This is an info message');

// Warning 日志
LoggerKit.w('This is a warning message');

// Error 日志
LoggerKit.e('This is an error message');

// Fatal 日志
LoggerKit.f('This is a fatal error');
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

## 高级功能

### 1. 自定义格式化器

```dart
import 'package:logger_kit/logger_kit.dart';

class CustomFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    final timestamp = record.timestamp.toIso8601String();
    final level = record.level.name;
    final message = record.message;
    
    return '[$timestamp] $level: $message';
  }
}

// 使用自定义格式化器
final logger = Logger(
  config: LogConfig(
    minLevel: LogLevel.debug,
    enableConsole: true,
  ),
  formatter: CustomFormatter(),
);
```

### 2. 自定义过滤器

```dart
import 'package:logger_kit/logger_kit.dart';

class CustomFilter implements LogFilter {
  @override
  bool shouldLog(LogRecord record) {
    // 只记录特定标签的日志
    return record.tag == 'IMPORTANT';
  }
}

// 添加过滤器
final logger = Logger(config: config);
logger.addFilter(CustomFilter());
```

### 3. 自定义写入器

```dart
import 'package:logger_kit/logger_kit.dart';

class CustomWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    // 自定义写入逻辑
    print('Custom: $formatted');
  }

  @override
  Future<void> close() async {
    // 清理资源
  }
}
```

### 4. 完整的日志系统示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  // 初始化日志系统
  _initLogging();

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

void _initLogging() {
  if (kDebugMode) {
    // 开发环境配置
    LoggerKit.init(
      minLevel: LogLevel.debug,
      enableConsole: true,
      enableFile: false,
      enableRemote: false,
      includeEmoji: true,
      prettyPrint: true,
    );
  } else {
    // 生产环境配置
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
  }
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
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _fetchData() async {
    LoggerKit.i('Fetching data', tag: 'NETWORK');
    
    try {
      // 模拟网络请求
      await Future.delayed(Duration(seconds: 2));
      
      LoggerKit.i('Data fetched successfully', tag: 'NETWORK', data: {
        'itemCount': 10,
        'duration': 2000,
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

## 配置选项

### LogConfig 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `minLevel` | `LogLevel` | `LogLevel.debug` | 最小日志级别 |
| `enableConsole` | `bool` | `true` | 启用控制台输出 |
| `enableFile` | `bool` | `false` | 启用文件日志 |
| `enableRemote` | `bool` | `false` | 启用远程日志 |
| `filePath` | `String?` | `null` | 文件日志路径 |
| `remoteUrl` | `String?` | `null` | 远程日志 URL |
| `maxFileSize` | `int` | `10 * 1024 * 1024` | 最大文件大小（字节） |
| `maxFileCount` | `int` | `5` | 最大文件数量 |
| `includeTimestamp` | `bool` | `true` | 包含时间戳 |
| `includeTag` | `bool` | `true` | 包含标签 |
| `includeEmoji` | `bool` | `true` | 包含 emoji |
| `prettyPrint` | `bool` | `true` | 美化输出 |

### 环境配置示例

#### 开发环境

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

#### 测试环境

```dart
LoggerKit.init(
  minLevel: LogLevel.info,
  enableConsole: true,
  enableFile: true,
  enableRemote: false,
  filePath: 'logs',
  maxFileSize: 5 * 1024 * 1024,
  maxFileCount: 3,
);
```

#### 生产环境

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
  includeEmoji: false,
);
```

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

// 业务逻辑
LoggerKit.i('Business logic', tag: 'BUSINESS');
```

### 2. 记录关键信息

```dart
// 记录 API 请求
LoggerKit.i('API request', tag: 'API', data: {
  'url': url,
  'method': method,
  'headers': headers,
  'body': body,
});

// 记录 API 响应
LoggerKit.i('API response', tag: 'API', data: {
  'url': url,
  'status': statusCode,
  'duration': duration,
  'size': responseSize,
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
    data: {
      'url': url,
      'retryCount': retryCount,
    },
  );
}
```

### 3. 用户行为追踪

```dart
// 页面访问
@override
void initState() {
  super.initState();
  LoggerKit.event('page_view', data: {
    'page': 'HomePage',
    'timestamp': DateTime.now().toIso8601String(),
  });
}

// 按钮点击
void _onButtonClick() {
  LoggerKit.event('button_clicked', data: {
    'buttonId': 'submit_button',
    'screen': 'home',
    'timestamp': DateTime.now().toIso8601String(),
  });
}

// 用户登录
void _onLogin(String userId) {
  LoggerKit.event('user_login', data: {
    'userId': userId,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

// 用户登出
void _onLogout() {
  LoggerKit.event('user_logout', data: {
    'timestamp': DateTime.now().toIso8601String(),
  });
}
```

### 4. 性能监控

```dart
Future<void> _performOperation() async {
  final stopwatch = Stopwatch()..start();
  
  try {
    await someOperation();
    
    stopwatch.stop();
    LoggerKit.i('Operation completed', tag: 'PERFORMANCE', data: {
      'operation': 'someOperation',
      'duration': stopwatch.elapsedMilliseconds,
    });
  } catch (e, stack) {
    stopwatch.stop();
    LoggerKit.e(
      'Operation failed',
      tag: 'PERFORMANCE',
      error: e,
      stackTrace: stack,
      data: {
        'operation': 'someOperation',
        'duration': stopwatch.elapsedMilliseconds,
      },
    );
  }
}
```

### 5. 资源管理

```dart
class MyService {
  MyService() {
    LoggerKit.i('Service initialized', tag: 'SERVICE');
  }

  Future<void> dispose() async {
    LoggerKit.i('Service disposing', tag: 'SERVICE');
    await LoggerKit.close();
  }
}

// 在应用退出时关闭
@override
void dispose() {
  LoggerKit.close();
  super.dispose();
}
```

## 故障排查

### 问题 1: 日志没有输出

**症状**: 调用日志方法但没有看到输出

**解决方案**:

1. 检查日志级别设置

```dart
// 确保 minLevel 不会过滤掉你的日志
LoggerKit.init(
  minLevel: LogLevel.debug, // 设置为最低级别
);
```

2. 检查是否启用了输出

```dart
LoggerKit.init(
  enableConsole: true, // 确保启用控制台输出
);
```

3. 检查是否初始化

```dart
// 确保在使用前初始化
LoggerKit.init();
```

### 问题 2: 文件日志没有生成

**症状**: 启用了文件日志但没有生成文件

**解决方案**:

1. 检查文件路径

```dart
LoggerKit.init(
  enableFile: true,
  filePath: 'logs', // 确保路径正确
);
```

2. 检查权限

确保应用有文件写入权限。

3. 检查日志是否被过滤

```dart
LoggerKit.init(
  minLevel: LogLevel.debug, // 降低过滤级别
  enableFile: true,
);
```

### 问题 3: 远程日志上传失败

**症状**: 远程日志没有上传到服务器

**解决方案**:

1. 检查网络连接

```dart
// 确保设备有网络连接
```

2. 检查服务器 URL

```dart
LoggerKit.init(
  enableRemote: true,
  remoteUrl: 'https://log.example.com/api/logs', // 确保 URL 正确
);
```

3. 检查服务器日志

查看服务器端是否收到请求。

### 问题 4: 日志文件占用太多空间

**症状**: 日志文件占用磁盘空间过大

**解决方案**:

1. 调整文件大小限制

```dart
LoggerKit.init(
  maxFileSize: 5 * 1024 * 1024, // 减小单个文件大小
  maxFileCount: 3, // 减少保留文件数量
);
```

2. 提高日志级别

```dart
LoggerKit.init(
  minLevel: LogLevel.warning, // 只记录警告及以上
);
```

### 问题 5: 性能问题

**症状**: 日志记录影响应用性能

**解决方案**:

1. 关闭不必要的输出

```dart
LoggerKit.init(
  enableConsole: false, // 生产环境关闭控制台
);
```

2. 提高日志级别

```dart
LoggerKit.init(
  minLevel: LogLevel.warning, // 减少日志数量
);
```

3. 使用异步日志

LoggerKit 默认使用异步写入，不会阻塞主线程。

## 更多资源

- [快速开始](../GETTING_STARTED.md) - 快速入门指南
- [README](../README.md) - 项目概述
- [GitHub 仓库](https://github.com/h1s97x/LoggerKit)
- [问题追踪](https://github.com/h1s97x/LoggerKit/issues)
- [示例应用](https://github.com/h1s97x/LoggerKit/tree/main/example)

---

**文档版本**: 1.0  
**更新日期**: 2026-03-09  
**项目**: LoggerKit  
**项目地址**: https://github.com/h1s97x/LoggerKit
