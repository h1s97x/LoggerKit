# 隐私保护指南

> 保护敏感数据，防止日志泄露

## 概述

在应用日志中记录敏感信息（如密码、令牌、身份证号等）是常见的安全风险。LoggerKit 提供了 `PrivacyInterceptor` 来自动识别和过滤敏感数据，确保敏感信息不会被记录到日志中。

## 快速开始

```dart
LoggerKit.builder()
  ..addInterceptor(PrivacyInterceptor())
  ..console()
  ..build();

// 敏感数据自动被过滤
LoggerKit.i('登录信息', data: {
  'username': 'john',
  'password': 'secret123',  // 输出: password: '***'
});
```

## 默认过滤字段

LoggerKit 默认会过滤以下敏感字段：

### 认证凭据

| 字段名 | 说明 |
|--------|------|
| `password` | 密码 |
| `passwd` | 密码（缩写） |
| `secret` | 密钥 |
| `token` | 令牌 |
| `api_key` | API 密钥 |
| `access_token` | 访问令牌 |
| `auth_token` | 认证令牌 |
| `authorization` | 授权信息 |

### 安全相关

| 字段名 | 说明 |
|--------|------|
| `credential` | 凭据 |
| `private_key` | 私钥 |
| `credit_card` | 信用卡号 |
| `ssn` | 社会安全号 |
| `social_security` | 社保号 |

### 示例

```dart
final record = LogRecord(
  level: LogLevel.info,
  message: '登录信息',
  data: {
    'username': 'john',
    'password': 'secret123',           // ✅ 被过滤
    'access_token': 'eyJhbGci...',    // ✅ 被过滤
  },
);

// 输出:
// username: john
// password: ***
// access_token: ***
```

## 自定义敏感字段

### 添加额外字段

```dart
// 添加常见的敏感字段
final interceptor = PrivacyInterceptor(
  extraSensitiveFields: [
    'apiKey',
    'clientSecret',
    'sessionId',
    'refreshToken',
  ],
);

LoggerKit.builder()
  ..addInterceptor(interceptor)
  ..console()
  ..build();
```

### 完全自定义

```dart
// 完全自定义敏感字段列表
final interceptor = PrivacyInterceptor(
  sensitiveFields: [
    'password',
    'token',
    'myCustomSecret',
  ],
);
```

### 字段匹配规则

匹配使用**不区分大小写**的 `contains` 匹配：

```dart
// 如果敏感字段列表包含 'token'
// 以下字段都会被匹配：
// - token
// - Token
// - TOKEN
// - access_token
// - auth_token
// - refreshToken

// 如果敏感字段列表包含 'password'
// 以下字段都会被匹配：
// - password
// - Password
// - PASSWORD
// - userPassword
// - login_password
```

## 自定义掩码

### 使用自定义掩码值

```dart
final interceptor = PrivacyInterceptor(
  maskValue: '[HIDDEN]',
);

LoggerKit.builder()
  ..addInterceptor(interceptor)
  ..console()
  ..build();

// 输出: password: [HIDDEN]
```

### 常用掩码格式

```dart
// 简洁
maskValue: '***'

// 明确
maskValue: '[REDACTED]'
maskValue: '[FILTERED]'

// 符合规范
maskValue: '******'           // 6位星号
maskValue: '████████'         // 方块字符

// 符合日志规范
maskValue: '<SENSITIVE>'
maskValue: '{{PLACEHOLDER}}'
```

## 嵌套数据过滤

### 嵌套对象

```dart
final record = LogRecord(
  level: LogLevel.info,
  message: '用户信息',
  data: {
    'user': {
      'name': 'john',
      'password': 'secret123',  // ✅ 被过滤
      'profile': {
        'email': 'john@example.com',
        'api_token': 'abc123',  // ✅ 被过滤
      },
    },
  },
);

// 输出:
// user.name: john
// user.password: ***
// user.profile.email: john@example.com
// user.profile.api_token: ***
```

### 数组

```dart
final record = LogRecord(
  level: LogLevel.info,
  message: '认证信息',
  data: {
    'tokens': ['abc123', 'xyz789'],  // 如果包含敏感内容会被过滤
    'users': [
      {'name': 'john', 'token': 'token1'},
      {'name': 'jane', 'token': 'token2'},
    ],
  },
);
```

### Map 嵌套

```dart
final record = LogRecord(
  level: LogLevel.info,
  message: '配置信息',
  data: {
    'config': {
      'database': {
        'host': 'localhost',
        'password': 'db_secret',  // ✅ 被过滤
      },
      'cache': {
        'redis': {
          'auth': 'redis_password',  // ✅ 被过滤
        },
      },
    },
  },
);
```

## 实际应用场景

### 1. 用户登录

```dart
// 记录登录信息时过滤敏感数据
LoggerKit.i('用户登录', data: {
  'userId': user.id,
  'email': user.email,
  'password': user.password,  // ✅ 自动过滤
  'ip': request.ip,
  'userAgent': request.userAgent,
});

// 输出:
// userId: 123
// email: john@example.com
// password: ***
// ip: 192.168.1.1
// userAgent: Mozilla/5.0...
```

### 2. API 请求/响应

```dart
// 记录 API 请求时过滤敏感数据
LoggerKit.network.i('API 请求', data: {
  'url': '/api/users/123',
  'method': 'GET',
  'headers': {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer eyJhbGci...',  // ✅ 自动过滤
  },
  'body': {
    'username': 'john',
    'password': 'secret',  // ✅ 自动过滤
  },
});
```

### 3. 数据库操作

```dart
// 记录数据库操作
LoggerKit.database.i('执行查询', data: {
  'sql': 'SELECT * FROM users WHERE id = ?',
  'params': [123],
  'connection': {
    'host': 'localhost',
    'password': 'db_password',  // ✅ 自动过滤
  },
});
```

### 4. 表单提交

```dart
// 记录表单提交
LoggerKit.i('表单提交', data: {
  'formName': 'registration',
  'fields': {
    'email': 'john@example.com',
    'password': 'user_password',  // ✅ 自动过滤
    'confirmPassword': 'user_password',  // ✅ 自动过滤
    'phone': '+1234567890',
  },
});
```

### 5. 错误报告

```dart
// 记录错误时保留上下文，过滤敏感数据
try {
  await userService.updatePassword(oldPassword, newPassword);
} catch (e) {
  LoggerKit.e('修改密码失败', data: {
    'userId': currentUser.id,
    'error': e.toString(),
  });
  // oldPassword 和 newPassword 不会被记录
}
```

## 最佳实践

### 1. 始终使用 PrivacyInterceptor

```dart
// ✅ 推荐：始终启用隐私保护
LoggerKit.builder()
  ..addInterceptor(PrivacyInterceptor())
  ..console()
  ..build();

// ❌ 不推荐：禁用隐私保护
LoggerKit.builder()
  ..console()
  ..build();
```

### 2. 尽早添加

```dart
// ✅ 推荐：拦截器尽早添加
LoggerKit.builder()
  ..addInterceptor(PrivacyInterceptor())  // order: 200
  ..addInterceptor(ContextInterceptor())   // order: 100
  ..console()
  ..build();

// 这样 ContextInterceptor 注入的敏感数据也会被过滤
```

### 3. 自定义敏感字段

```dart
// 根据你的应用添加额外的敏感字段
final interceptor = PrivacyInterceptor(
  extraSensitiveFields: [
    // 常见
    'apiKey',
    'clientSecret',
    'sessionId',
    
    // 应用特定
    'bankAccount',
    'idNumber',
    'phoneNumber',
    
    // 自定义
    'myAppSecret',
    'customToken',
  ],
);
```

### 4. 使用有意义的掩码

```dart
// ✅ 推荐：明确的掩码
maskValue: '[SENSITIVE]'
maskValue: '[REDACTED]'

// ❌ 不推荐：过于简洁的掩码
maskValue: '*'       // 可能被误认为有效数据
maskValue: 'xxx'     // 不够明确
```

### 5. 日志审查

```dart
// 定期审查日志，确保敏感数据被正确过滤
test('隐私保护测试', () {
  final interceptor = PrivacyInterceptor(
    extraSensitiveFields: ['customSecret'],
  );
  
  final record = LogRecord(
    level: LogLevel.info,
    message: '测试',
    data: {
      'password': 'secret',
      'customSecret': 'my_secret',
      'username': 'john',  // 不是敏感字段，不被过滤
    },
  );
  
  final result = interceptor.intercept(record);
  
  expect(result.data!['password'], equals('***'));
  expect(result.data!['customSecret'], equals('***'));
  expect(result.data!['username'], equals('john'));  // 保留原值
});
```

## 常见问题

### Q: 如何查看所有被过滤的字段？

```dart
final interceptor = PrivacyInterceptor(
  maskValue: '[FILTERED:${DateTime.now()}]',  // 包含时间戳
);

// 日志中会显示: password: [FILTERED:2024-01-01 12:00:00]
```

### Q: 如何临时禁用过滤？

```dart
// 方式1：创建不带 PrivacyInterceptor 的 Logger
final noPrivacyLogger = LoggerKit.builder()
  ..console()
  ..build();

// 方式2：在特定位置不使用隐私过滤
LoggerKit.i('调试信息', data: {'debug': 'value'});  // 不在 PrivacyInterceptor 下
```

### Q: 如何处理多层嵌套的数据？

```dart
// PrivacyInterceptor 自动处理任意深度的嵌套
final record = LogRecord(
  level: LogLevel.info,
  message: '测试',
  data: {
    'level1': {
      'level2': {
        'level3': {
          'password': 'deep_secret',  // ✅ 仍然被过滤
        },
      },
    },
  },
);
```

### Q: 如何处理动态字段名？

```dart
// PrivacyInterceptor 支持动态字段名
final interceptor = PrivacyInterceptor(
  sensitiveFields: [
    'password',
    'token',
    // 通配符（未来版本可能支持）
    // 'user_*_secret',
  ],
);
```

### Q: 过滤会影响日志格式吗？

```dart
// 不影响，掩码直接替换值
// JSON 格式输出：
// {"password": "***", "username": "john"}

// 普通格式输出：
// password: ***, username: john
```

## 安全建议

### 1. 最小化原则

```dart
// ✅ 只记录必要的信息
LoggerKit.i('用户登录', data: {
  'userId': user.id,
  'ip': request.ip,
});

// ❌ 记录过多信息
LoggerKit.i('用户登录', data: {
  'user': user.toJson(),  // 可能包含敏感字段
  'request': request.toJson(),
  'headers': request.headers,  // 可能包含 Authorization
});
```

### 2. 分离敏感操作日志

```dart
// 敏感操作使用独立的日志器
final auditLogger = LoggerKit.builder()
  ..addInterceptor(AuditInterceptor())
  ..addInterceptor(PrivacyInterceptor())
  ..console()
  ..build();

// 非敏感操作使用普通日志器
LoggerKit.i('普通日志');
```

### 3. 定期审计

```dart
// 创建日志审查工具
class LogAuditor {
  static const _sensitivePatterns = [
    'password',
    'token',
    'secret',
    'key',
  ];
  
  static bool containsSensitiveData(Map<String, dynamic> data) {
    // 检查日志数据中是否包含敏感信息
    // ...
  }
}
```

## 相关文档

- [拦截器指南](./INTERCEPTOR_GUIDE.md)
- [Builder 使用指南](./BUILDER_GUIDE.md)
- [API 文档](./API.md)
