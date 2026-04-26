# Builder 使用指南

> LoggerKit 的链式配置 API

## 概述

`LoggerBuilder` 提供了一种流畅（Fluent）的方式来配置和创建 Logger 实例。通过链式调用，你可以轻松地组合各种配置选项。

## 基本用法

```dart
import 'package:logger_kit/logger_kit.dart';

// 创建并配置 Logger
final logger = LoggerKit.builder()
  ..minLevel(LogLevel.info)
  ..console()
  ..build();

// 使用 Logger
logger.i('Hello, LoggerKit!');
```

## 完整配置示例

```dart
final logger = LoggerKit.builder()
  // 日志级别
  ..minLevel(LogLevel.debug)
  
  // 控制台输出
  ..console(prettyPrint: true)
  
  // 文件输出
  ..file(
    path: './logs',
    maxSize: 10 * 1024 * 1024,  // 10MB
    maxCount: 5,                 // 保留 5 个文件
  )
  
  // 上下文
  ..context(LogContext(
    userId: 'user_123',
    deviceId: 'device_abc',
  ))
  
  // 隐私字段
  ..privacyFields(['password', 'token', 'secret'])
  
  // 自定义拦截器
  ..addInterceptor(ContextInterceptor())
  ..addInterceptor(PrivacyInterceptor())
  
  // 创建 Logger
  ..build();

// 链式调用使用
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', error: exception);
```

## 配置选项详解

### 日志级别

```dart
..minLevel(LogLevel.debug)   // 记录所有日志
..minLevel(LogLevel.info)    // 忽略 debug
..minLevel(LogLevel.warning) // 只记录 warning 及以上
..minLevel(LogLevel.error)   // 只记录 error 和 fatal
..minLevel(LogLevel.fatal)   // 只记录 fatal
```

### 控制台输出

```dart
// 启用控制台输出（默认启用）
..console()

// 美化打印（带颜色）
..console(prettyPrint: true)

// 禁用控制台输出
..noConsole()
```

### 文件输出

```dart
// 启用文件日志
..file(path: './logs')

// 自定义参数
..file(
  path: './logs',
  maxSize: 5 * 1024 * 1024,  // 单文件最大 5MB
  maxCount: 10,              // 保留 10 个文件
)
```

### 上下文注入

```dart
// 设置全局上下文
..context(LogContext(
  userId: 'user_123',
  sessionId: 'session_abc',
))

// 运行时更新上下文
logger.context.userId = 'user_456';
logger.context['customField'] = 'customValue';
```

### 隐私字段过滤

```dart
// 添加额外的隐私字段
..privacyFields(['password', 'token', 'apiKey', 'creditCard'])
```

### 拦截器

```dart
// 添加拦截器（按添加顺序执行）
..addInterceptor(ContextInterceptor())
..addInterceptor(PrivacyInterceptor())
..addInterceptor(MyCustomInterceptor())

// 拦截器按 order 属性排序执行
```

## 使用 Logger

```dart
// 基本日志
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
logger.f('Fatal error');

// 带标签
logger.d('Message', tag: 'Network');

// 带数据
logger.i('User logged in', data: {'userId': '123', 'method': 'google'});

// 带错误
try {
  // some code
} catch (e, stack) {
  logger.e('Operation failed', error: e, stackTrace: stack);
}

// 带事件
logger.event('purchase', data: {'item': 'book', 'price': 29.99});
```

## 上下文使用

```dart
// 创建带上下文的 Logger
final logger = LoggerKit.builder()
  ..context(LogContext(userId: 'user_123'))
  ..console()
  ..build();

// 运行时更新
logger.context.userId = 'user_456';
logger.context['requestId'] = 'req_789';

// 获取当前上下文
final currentUserId = logger.context.userId;
final allData = logger.context.toMap();

// 清空自定义数据（保留 userId 等）
logger.context.clearCustom();

// 清空所有上下文
logger.context.clearAll();
```

## 多环境配置

```dart
// 开发环境
LoggerKit.builder()
  ..minLevel(LogLevel.debug)
  ..console(prettyPrint: true)
  ..build();

// 生产环境
LoggerKit.builder()
  ..minLevel(LogLevel.warning)
  ..file(path: '/var/log/app.log')
  ..privacyFields(['password', 'token', 'secret', 'creditCard'])
  ..build();
```

## 常见问题

### Q: 如何创建不自动设置为全局实例的 Logger？

```dart
final logger = LoggerKit.builder()
  ..console()
  ..build();  // 默认设置为全局实例

// 或者显式控制
final logger = LoggerKit.builder()
  ..console()
  ..buildAndSetGlobal();
```

### Q: 如何在构建后修改配置？

```dart
final logger = LoggerKit.builder()
  ..console()
  ..build();

// 修改上下文
logger.context['requestId'] = 'new_request_id';

// 更新日志级别
logger.updateConfig(const LogConfig(minLevel: LogLevel.info));
```

### Q: 如何禁用所有输出？

```dart
// 静默模式 - 不输出到任何地方
final logger = LoggerKit.builder()
  ..noConsole()
  ..noFile()
  ..build();
```

## 相关文档

- [命名空间指南](./NAMESPACE_GUIDE.md)
- [拦截器指南](./INTERCEPTOR_GUIDE.md)
- [隐私保护指南](./PRIVACY_GUIDE.md)
- [API 文档](./API.md)
