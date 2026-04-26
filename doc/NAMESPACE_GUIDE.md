# 命名空间使用指南

> LoggerKit 的模块化日志管理

## 概述

命名空间（Namespace）允许你为应用的不同模块创建独立的 Logger 实例，实现模块化的日志管理。每个命名空间可以拥有独立的配置、过滤规则和输出目标。

## 为什么使用命名空间？

| 场景 | 不使用命名空间 | 使用命名空间 |
|------|---------------|-------------|
| **网络日志** | 所有日志混在一起 | `LoggerKit.network.i('API 请求')` |
| **数据库日志** | 难以区分来源 | `LoggerKit.database.d('查询执行')` |
| **UI 日志** | 定位问题困难 | `LoggerKit.ui.d('界面渲染')` |
| **认证日志** | 安全日志混杂 | `LoggerKit.auth.w('登录失败')` |

## 基本用法

### 创建命名空间

```dart
// 创建命名空间
final networkLogger = LoggerKit.namespace('network');
final dbLogger = LoggerKit.namespace('database');

// 使用命名空间
networkLogger.i('发送 API 请求');
dbLogger.d('执行查询');
```

### 快捷方式

LoggerKit 提供了预定义命名空间的快捷方式：

```dart
LoggerKit.network.i('网络日志');
LoggerKit.database.i('数据库日志');
LoggerKit.ui.i('界面日志');
LoggerKit.storage.i('存储日志');
LoggerKit.auth.i('认证日志');
LoggerKit.analytics.i('分析日志');
```

## 预定义命名空间

LoggerKit 默认提供以下预定义命名空间：

| 命名空间 | 用途 | 示例 |
|---------|------|------|
| `network` | 网络请求 | API 调用、HTTP 请求 |
| `database` | 数据库操作 | 查询、事务、连接 |
| `ui` | 用户界面 | 界面渲染、用户交互 |
| `storage` | 本地存储 | 文件操作、缓存 |
| `auth` | 认证授权 | 登录、登出、权限 |
| `analytics` | 数据分析 | 事件追踪、埋点 |

## 注册自定义命名空间

### 基础注册

```dart
// 注册自定义命名空间
LoggerKit.registerNamespace('payment');
LoggerKit.registerNamespace('analytics');

// 使用
LoggerKit.payment.i('支付处理中');
LoggerKit.analytics.e('埋点失败');
```

### 带配置的注册

```dart
// 注册时指定配置
LoggerKit.registerNamespace('network', config: const LogConfig(
  minLevel: LogLevel.warning,  // 网络日志只记录警告及以上
));

LoggerKit.registerNamespace('debug', config: const LogConfig(
  minLevel: LogLevel.debug,    // 调试日志记录所有级别
  enableConsole: true,
));

// 使用
LoggerKit.network.w('API 请求超时');  // ✅ 记录
LoggerKit.network.d('请求头信息');    // ❌ 忽略（低于 warning）
LoggerKit.debug.d('详细调试信息');     // ✅ 记录
```

## 命名空间与拦截器

### 全局拦截器

通过 Builder 配置的拦截器对所有命名空间生效：

```dart
LoggerKit.builder()
  ..minLevel(LogLevel.info)
  ..addInterceptor(PrivacyInterceptor())  // 全局隐私过滤
  ..addInterceptor(ContextInterceptor())    // 全局上下文注入
  ..console()
  ..build();

// 所有命名空间都会经过这些拦截器
LoggerKit.network.i('请求');  // 经过 PrivacyInterceptor + ContextInterceptor
LoggerKit.database.i('查询'); // 经过 PrivacyInterceptor + ContextInterceptor
```

### 命名空间级别拦截器

```dart
// 为特定命名空间创建独立 Logger
final customLogger = LoggerKit.builder()
  ..minLevel(LogLevel.debug)
  ..addInterceptor(MyCustomInterceptor())
  ..console()
  ..build();

// 注册为命名空间
LoggerKit.registerNamespace('custom', config: const LogConfig(
  // 自定义配置
));
```

## 实际应用场景

### 1. 分层架构应用

```dart
// Presentation Layer
LoggerKit.ui.d('渲染用户列表');
LoggerKit.ui.d('点击按钮: submit');

// Business Layer
LoggerKit.namespace('service').i('处理业务逻辑');
LoggerKit.namespace('validation').i('验证表单数据');

// Data Layer
LoggerKit.database.d('执行 SELECT 查询');
LoggerKit.database.i('插入新记录');
LoggerKit.storage.i('读取本地缓存');

// External Services
LoggerKit.network.i('调用用户服务');
LoggerKit.network.w('API 响应慢 (>2s)');
LoggerKit.network.e('请求失败: 500');
```

### 2. 微服务架构

```dart
// 订单服务
final orderLogger = LoggerKit.namespace('order');
orderLogger.i('创建订单 #12345');
orderLogger.i('订单支付成功');
orderLogger.e('库存不足');

// 通知服务
final notifyLogger = LoggerKit.namespace('notify');
notifyLogger.i('发送邮件通知');
notifyLogger.w('邮件发送超时');

// 支付服务
final paymentLogger = LoggerKit.namespace('payment');
paymentLogger.i('处理支付');
paymentLogger.i('支付完成: ¥99.00');
```

### 3. 调试特定模块

```dart
// 调试时启用特定模块的详细日志
LoggerKit.registerNamespace('network', config: const LogConfig(
  minLevel: LogLevel.debug,  // 网络模块详细日志
));

LoggerKit.registerNamespace('database', config: const LogConfig(
  minLevel: LogLevel.warning, // 数据库只记录警告
));

// 其他模块静默
LoggerKit.builder()
  ..minLevel(LogLevel.error)  // 只记录错误
  ..console()
  ..build();
```

## 命名空间管理

### 检查命名空间

```dart
// 检查命名空间是否存在
if (LoggerKit.hasNamespace('network')) {
  // ...
}

// 获取所有命名空间
final names = LoggerKit.namespaceNames;
print('已注册的命名空间: $names');
```

### 清除命名空间

```dart
// 清除特定命名空间
LoggerKit.clearNamespace('network');

// 清除所有命名空间
LoggerKit.clearAll();
```

### 获取命名空间 Logger

```dart
// 获取已存在的命名空间
final logger = LoggerKit.namespace('network');

// 如果已存在，直接返回
final sameLogger = LoggerKit.namespace('network');
// sameLogger === logger
```

## 日志聚合与过滤

### 按命名空间过滤

```dart
// 只查看特定命名空间的日志
LoggerKit.namespace('network')
  ..addInterceptor((record, next) {
    // 只处理 network 命名空间的日志
    return next(record);
  });
```

### 命名空间前缀

所有通过命名空间创建的 Logger 都会自动带上命名空间作为 tag：

```
[network] 发送 API 请求
[database] 执行查询
[ui] 界面渲染完成
```

## 最佳实践

### 1. 统一命名规范

```dart
// 推荐：使用简洁的命名
LoggerKit.network
LoggerKit.database
LoggerKit.auth

// 不推荐：过于详细的命名
LoggerKit.networkApiHttpRequest
LoggerKit.databaseMySQLQuery
```

### 2. 合理的日志级别

```dart
// network - API 调用
LoggerKit.network.d('调试信息');   // 详细的请求/响应
LoggerKit.network.i('正常日志');    // 请求成功
LoggerKit.network.w('警告信息');    // 响应慢、超时
LoggerKit.network.e('错误信息');    // 请求失败

// database - 数据库操作
LoggerKit.database.d('SQL 调试');
LoggerKit.database.i('查询成功');
LoggerKit.database.e('连接失败');

// auth - 安全相关
LoggerKit.auth.w('登录失败');
LoggerKit.auth.e('未授权访问');
```

### 3. 命名空间与模块对应

```dart
// lib/network/api_service.dart
final _logger = LoggerKit.network;

// lib/database/user_repository.dart
final _logger = LoggerKit.database;

// lib/ui/screens/home_screen.dart
final _logger = LoggerKit.ui;
```

## 常见问题

### Q: 命名空间和全局 Logger 有什么区别？

```dart
// 全局 Logger - 单例
LoggerKit.init(config: LogConfig(...));
LoggerKit.i('全局日志');

// 命名空间 Logger - 独立实例
LoggerKit.namespace('network').i('网络日志');
LoggerKit.namespace('database').i('数据库日志');
```

### Q: 如何让所有命名空间共享配置？

```dart
// 全局配置
LoggerKit.builder()
  ..minLevel(LogLevel.info)
  ..addInterceptor(PrivacyInterceptor())
  ..console()
  ..build();

// 命名空间会继承全局配置
LoggerKit.network.i('使用全局配置');
LoggerKit.database.i('使用全局配置');
```

### Q: 命名空间的性能影响？

命名空间是轻量级的，几乎没有性能影响。Logger 实例按需创建，并在内存中缓存。

## 相关文档

- [Builder 使用指南](./BUILDER_GUIDE.md)
- [拦截器指南](./INTERCEPTOR_GUIDE.md)
- [隐私保护指南](./PRIVACY_GUIDE.md)
- [API 文档](./API.md)
