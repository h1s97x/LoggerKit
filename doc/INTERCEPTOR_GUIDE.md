# 拦截器使用指南

> LoggerKit 的中间件架构

## 概述

拦截器（Interceptor）是 LoggerKit 的中间件机制，允许你在日志记录的过程中对 `LogRecord` 进行预处理和后处理。通过拦截器，你可以实现日志增强、隐私过滤、上下文注入等功能。

## 拦截器接口

```dart
abstract class LogInterceptor {
  /// 拦截器执行顺序，数字越小越先执行
  int get order => 0;

  /// 拦截并处理日志记录
  /// 返回 null 表示丢弃该日志，返回 LogRecord 表示继续传递
  LogRecord? intercept(LogRecord record);
}
```

## 内置拦截器

LoggerKit 提供了以下内置拦截器：

| 拦截器 | 用途 | 内置顺序 |
|--------|------|---------|
| `ContextInterceptor` | 注入全局上下文 | 100 |
| `PrivacyInterceptor` | 过滤敏感数据 | 200 |
| `PassThroughInterceptor` | 默认拦截器（透传） | 0 |

## ContextInterceptor

### 功能

自动将全局上下文注入到每条日志记录中。

### 基本用法

```dart
LoggerKit.builder()
  ..addInterceptor(ContextInterceptor())
  ..console()
  ..build();

// 创建带上下文的拦截器
final ctxInterceptor = ContextInterceptor(getContext: () => LogContext(
  userId: '12345',
  requestId: 'req-abc',
));

LoggerKit.builder()
  ..addInterceptor(ctxInterceptor)
  ..console()
  ..build();
```

### 全局上下文

```dart
// 设置全局上下文
LogContext.current = LogContext(
  userId: '12345',
  deviceId: 'device-001',
);

// 所有日志都会自动带上这些上下文
LoggerKit.i('用户登录');  // 自动添加 userId, deviceId
```

### 上下文合并

```dart
// 单条日志的 data 会与全局上下文合并
LoggerKit.i('提交订单', data: {'orderId': '12345'});

// 最终记录包含:
// - 全局上下文: userId, deviceId
// - 单条数据: orderId
```

## PrivacyInterceptor

### 功能

自动过滤敏感信息，防止密码、令牌等数据泄露。

### 基本用法

```dart
LoggerKit.builder()
  ..addInterceptor(PrivacyInterceptor())
  ..console()
  ..build();
```

### 默认过滤字段

```dart
// 默认会过滤以下字段
'password', 'passwd', 'secret', 'token', 'api_key',
'access_token', 'auth_token', 'authorization',
'credential', 'private_key', 'credit_card', 'ssn',
'social_security'
```

### 自定义过滤字段

```dart
// 添加额外的敏感字段
final interceptor = PrivacyInterceptor(
  extraSensitiveFields: ['customSecret', 'privateData'],
);

// 过滤特定字段
final interceptor = PrivacyInterceptor(
  sensitiveFields: ['password', 'token', 'customKey'],
);
```

### 自定义掩码

```dart
// 使用自定义掩码
final interceptor = PrivacyInterceptor(
  maskValue: '[REDACTED]',
);

// 输出: data['password'] = '[REDACTED]'
```

### 嵌套数据过滤

```dart
// 自动递归过滤嵌套对象和数组
final record = LogRecord(
  level: LogLevel.info,
  message: '登录信息',
  data: {
    'user': {
      'name': 'john',
      'password': 'secret123',  // ✅ 被过滤
    },
    'tokens': ['abc', 'xyz'],     // ✅ 'abc' 如果匹配也会被过滤
  },
);
```

## 自定义拦截器

### 基础自定义

```dart
class TimestampInterceptor implements LogInterceptor {
  @override
  int get order => -100;  // 在其他拦截器之前执行

  @override
  LogRecord? intercept(LogRecord record) {
    // 添加时间戳到日志
    return LogRecord(
      level: record.level,
      message: record.message,
      timestamp: DateTime.now(),
      data: {
        ...?record.data,
        'processedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}

LoggerKit.builder()
  ..addInterceptor(TimestampInterceptor())
  ..console()
  ..build();
```

### 修改日志级别

```dart
class ProductionLevelInterceptor implements LogInterceptor {
  @override
  int get order => 300;

  @override
  LogRecord? intercept(LogRecord record) {
    // 生产环境：debug → info
    if (record.level == LogLevel.debug) {
      return LogRecord(
        level: LogLevel.info,
        message: '[DEBUG] ${record.message}',
        timestamp: record.timestamp,
        data: record.data,
      );
    }
    return record;
  }
}
```

### 丢弃日志

```dart
class KeywordFilterInterceptor implements LogInterceptor {
  final List<String> _blockedKeywords = ['DEBUG_VERBOSE', 'TEMP_LOG'];

  @override
  int get order => 50;

  @override
  LogRecord? intercept(LogRecord record) {
    // 如果消息包含敏感关键词，丢弃日志
    for (final keyword in _blockedKeywords) {
      if (record.message.contains(keyword)) {
        return null;  // 丢弃日志
      }
    }
    return record;
  }
}
```

### 添加标签

```dart
class TagInterceptor implements LogInterceptor {
  final String tag;

  const TagInterceptor(this.tag);

  @override
  int get order => 10;

  @override
  LogRecord? intercept(LogRecord record) {
    return LogRecord(
      level: record.level,
      message: record.message,
      tag: '${record.tag ?? ''}[$tag]'.trim(),
      timestamp: record.timestamp,
      data: record.data,
    );
  }
}

// 使用
LoggerKit.builder()
  ..addInterceptor(const TagInterceptor('APP'))
  ..addInterceptor(const TagInterceptor('v1.0'))
  ..console()
  ..build();

// 输出: [APP][v1.0] 消息内容
```

## CompositeInterceptor

### 功能

组合多个拦截器，支持动态添加/移除。

### 基本用法

```dart
final composite = CompositeInterceptor(
  interceptors: [
    ContextInterceptor(),
    PrivacyInterceptor(),
  ],
  stopOnNull: true,  // 任一拦截器返回 null 时停止
);

LoggerKit.builder()
  ..addInterceptor(composite)
  ..console()
  ..build();
```

### 动态管理

```dart
final composite = CompositeInterceptor();

// 运行时添加
composite.add(TimestampInterceptor());

// 运行时移除
composite.remove(interceptor);

// 批量操作
composite.addAll([
  ContextInterceptor(),
  PrivacyInterceptor(),
]);

composite.clear();  // 清除所有
```

## 执行顺序

### 顺序规则

1. 拦截器按 `order` 从小到大执行
2. 数字越小越先执行
3. 相同 `order` 的拦截器按添加顺序执行

### 建议顺序

| 顺序 | 拦截器 | 说明 |
|------|--------|------|
| -100 | 标签拦截器 | 添加标签 |
| 0 | PassThroughInterceptor | 默认透传 |
| 100 | ContextInterceptor | 注入上下文 |
| 200 | PrivacyInterceptor | 隐私过滤 |
| 300 | 级别调整拦截器 | 调整日志级别 |
| 1000 | 上报拦截器 | 发送到远程 |

### 执行流程

```
日志记录 → TimestampInterceptor (-100) → TagInterceptor (0)
    → ContextInterceptor (100) → PrivacyInterceptor (200)
    → 自定义拦截器 → 输出
```

## 拦截器与命名空间

### 全局拦截器

```dart
// Builder 配置的拦截器对所有 Logger 生效
LoggerKit.builder()
  ..addInterceptor(PrivacyInterceptor())
  ..console()
  ..build();

// 全局和命名空间都使用同一个拦截器
LoggerKit.i('使用 PrivacyInterceptor');          // ✅
LoggerKit.network.i('使用 PrivacyInterceptor');   // ✅
```

### 命名空间特定拦截器

```dart
// 为特定命名空间创建独立 Logger
final customLogger = LoggerKit.builder()
  ..addInterceptor(MyCustomInterceptor())
  ..console()
  ..build();

// 注册为命名空间
LoggerKit.registerNamespace('custom');
```

## 实际应用场景

### 1. 用户追踪

```dart
class UserTrackingInterceptor implements LogInterceptor {
  @override
  int get order => 100;

  @override
  LogRecord? intercept(LogRecord record) {
    final userId = getCurrentUserId();
    if (userId != null) {
      return LogRecord(
        level: record.level,
        message: record.message,
        data: {
          ...?record.data,
          'userId': userId,
          'sessionId': getSessionId(),
        },
      );
    }
    return record;
  }
}
```

### 2. 性能监控

```dart
class PerformanceInterceptor implements LogInterceptor {
  @override
  int get order => 200;

  @override
  LogRecord? intercept(LogRecord record) {
    // 记录处理耗时
    final stopwatch = Stopwatch()..start();
    final result = record;
    stopwatch.stop();

    if (stopwatch.elapsedMilliseconds > 100) {
      print('慢日志警告: ${record.message} 耗时 ${stopwatch.elapsedMilliseconds}ms');
    }
    return result;
  }
}
```

### 3. 错误聚合

```dart
class ErrorAggregationInterceptor implements LogInterceptor {
  final Map<String, int> _errorCounts = {};

  @override
  int get order => 250;

  @override
  LogRecord? intercept(LogRecord record) {
    if (record.level == LogLevel.error) {
      final key = record.message;
      _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;

      // 错误超过阈值时添加警告
      if (_errorCounts[key]! > 5) {
        print('错误聚合警告: $key 已出现 ${_errorCounts[key]} 次');
      }
    }
    return record;
  }
}
```

## 最佳实践

### 1. 保持拦截器轻量

```dart
// ❌ 不推荐：复杂计算
class HeavyInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) {
    final data = fetchFromDatabase();  // 耗时操作
    // ...
  }
}

// ✅ 推荐：轻量处理
class LightInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) {
    return record;  // 透传或简单处理
  }
}
```

### 2. 正确设置执行顺序

```dart
// ✅ 正确：按功能分层
..addInterceptor(TimestampInterceptor())     // order: -100
..addInterceptor(ContextInterceptor())      // order: 100
..addInterceptor(PrivacyInterceptor())      // order: 200

// ❌ 错误：顺序混乱
..addInterceptor(PrivacyInterceptor())     // order: 200
..addInterceptor(ContextInterceptor())       // order: 100
```

### 3. 处理 null 返回

```dart
class SafeInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) {
    try {
      // 处理逻辑
      return modifyRecord(record);
    } catch (e) {
      // 异常时返回原记录，不要丢弃
      return record;
    }
  }
}
```

### 4. 使用 const 构造

```dart
// ✅ 推荐
..addInterceptor(const PrivacyInterceptor())

// ❌ 不推荐
..addInterceptor(PrivacyInterceptor(maskValue: '***'))
```

## 常见问题

### Q: 如何禁用某个内置拦截器？

```dart
// 使用自定义拦截器覆盖
LoggerKit.builder()
  ..addInterceptor(CustomContextInterceptor())  // 替换默认行为
  ..console()
  ..build();
```

### Q: 拦截器会阻塞日志记录吗？

不会。拦截器是同步执行的，但应该保持轻量。如果拦截器耗时过长，会影响日志记录性能。

### Q: 如何调试拦截器？

```dart
class DebugInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) {
    print('Before: ${record.message}');
    print('Data: ${record.data}');
    final result = record;
    print('After: ${result.message}');
    return result;
  }
}
```

## 相关文档

- [Builder 使用指南](./BUILDER_GUIDE.md)
- [命名空间指南](./NAMESPACE_GUIDE.md)
- [隐私保护指南](./PRIVACY_GUIDE.md)
- [API 文档](./API.md)
