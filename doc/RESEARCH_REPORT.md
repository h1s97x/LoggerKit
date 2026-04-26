# LoggerKit 成熟化调研报告

> 日期：2025年1月
> 目标：保持轻量化、减少依赖，将 LoggerKit 打造成成熟的 Flutter 日志工具

## 目录

- [一、项目现状分析](#一项目现状分析)
- [二、Flutter 生态日志库对比](#二flutter-生态日志库对比)
- [三、成熟项目借鉴点](#三成熟项目借鉴点)
- [四、成熟化建议](#四成熟化建议)
- [五、轻量化策略](#五轻量化策略)
- [六、参考项目](#六参考项目)

---

## 一、项目现状分析

### 1.1 当前架构

```
lib/
├── models/           # 数据模型
│   ├── log_record.dart    ✅ 完整字段：message, level, timestamp, tag, error, stackTrace, data
│   ├── log_level.dart     ✅ 5级日志 + emoji
│   └── log_config.dart    ✅ 配置项
├── writers/          # 输出层（接口可扩展）
│   ├── log_writer.dart    ✅ 接口定义
│   ├── file_writer.dart   ✅ 文件日志 + 轮转
│   └── remote_writer.dart ✅ 远程上报 + 缓冲
├── formatters/       # 格式化层
│   └── log_formatter.dart ✅ simple/json/colored 三种
├── filters/          # 过滤层
│   └── log_filter.dart    ✅ level/tag/composite 过滤
└── core/
    ├── logger.dart         ✅ 核心 Logger
    └── logger_kit.dart     ✅ 全局单例入口
```

### 1.2 当前依赖

| 包名 | 版本 | 用途 | 是否核心 |
|------|------|------|----------|
| http | ^1.1.0 | 远程日志上报 | ❌ 可选 |
| path | ^1.8.3 | 文件路径处理 | ❌ 可选 |
| flutter | SDK | Flutter 框架 | ✅ 必需 |

**结论：核心依赖为 0，可选依赖 2 个，符合轻量化要求。**

### 1.3 优势

1. **架构分层清晰** - Model → Filter → Logger → Formatter → Writer
2. **扩展性强** - Writer/Formatter/Filter 都是接口，便于扩展
3. **依赖极少** - 仅 2 个可选外部依赖
4. **功能完整** - 本地、文件、远程三种输出
5. **文档完善** - 有架构文档、API 文档、使用指南

### 1.4 待改进点

| 优先级 | 问题 | 影响 |
|--------|------|------|
| 🔴 P0 | 缺少日志命名空间/隔离 | 企业级多模块日志管理困难 |
| 🔴 P0 | 配置 API 不够灵活 | 链式配置体验不佳 |
| 🟡 P1 | 缺少隐私过滤 | 生产环境可能泄露敏感信息 |
| 🟡 P1 | 缺少 release 模式降级 | 生产环境日志难以控制 |
| 🟢 P2 | 缺少中间件/拦截器 | 难以统一增强日志 |
| 🟢 P2 | 缺少结构化上下文 | 日志关联信息不足 |

---

## 二、Flutter 生态日志库对比

### 2.1 功能矩阵

| 库名称 | 定位 | 控制台 | 文件存储 | 远程上报 | 中间件 | 数据库 | 依赖数 |
|--------|------|--------|----------|----------|--------|--------|--------|
| **LoggerKit** | 综合日志 | ✅ | ✅ | ✅ | ❌ | ❌ | 2 |
| **logger** | 轻量控制台 | ✅ | ❌ | ❌ | ❌ | ❌ | 0 |
| **flutter_logger_easier** | 企业级 | ✅ | ✅ | ✅ | ✅ | ❌ | 5+ |
| **FLogs** | 数据库存储 | ✅ | ✅ SQLite | ✅ | ❌ | ✅ | 3+ |
| **minlog** | 极简 | ✅ | ❌ | ❌ | ❌ | ❌ | 1 |
| **talker** | 调试神器 | ✅ | ✅ | ✅ | ✅ | ❌ | 3+ |

### 2.2 详细对比

#### logger (~5000 赞)

```
优点：
✅ 零依赖，纯 Dart 实现
✅ Printer 抽象灵活
✅ 彩色输出 + 美化打印
✅ API 简洁

缺点：
❌ 仅支持控制台
❌ 无文件/远程输出
```

#### flutter_logger_easier

```
优点：
✅ 中间件架构（拦截器链）
✅ 错误报告器可插拔
✅ 日志轮转内置
✅ 异步批处理

缺点：
❌ 依赖较多
❌ 文档为中文
❌ 社区活跃度一般
```

#### FLogs

```
优点：
✅ SQLite 持久化
✅ 导出 ZIP 分析
✅ 多日志器分离
✅ 功能最全

缺点：
❌ 依赖较重（sqflite）
❌ 偏向离线日志分析
❌ 性能开销较大
```

#### talker (推荐参考)

```
优点：
✅ 命名空间隔离
✅ Flutter UI 集成
✅ 过滤器链
✅ 生产/调试模式

缺点：
❌ 依赖较多
❌ 偏向调试工具
```

---

## 三、成熟项目借鉴点

### 3.1 logger 的设计

```dart
// 借鉴点：Printer 抽象
abstract class LogPrinter {
  String log(LogOutput output);
}

// 多种 Printer 实现
class PrettyPrinter extends LogPrinter { ... }
class SimplePrinter extends LogPrinter { ... }
class JSONPrinter extends LogPrinter { ... }
```

**借鉴点：**
1. Printer 命名更简洁
2. 零依赖设计理念
3. 输出与格式化分离

### 3.2 flutter_logger_easier 的中间件

```dart
// 借鉴点：拦截器链
LoggerBuilder()
  ..addInterceptor((record) {
    record.context['userId'] = getUserId();
    return record;
  })
  ..addInterceptor((record) {
    record.context['timestamp'] = DateTime.now();
    return record;
  })
  ..build();
```

**借鉴点：**
1. 链式 Builder 模式
2. 统一的日志上下文注入
3. 可插拔的拦截器

### 3.3 talker 的命名空间

```dart
// 借鉴点：独立日志器
final networkLogger = Talker(title: 'Network');
final dbLogger = Talker(title: 'Database');

networkLogger.info('Request sent');
dbLogger.debug('Query executed');
```

**借鉴点：**
1. 按模块隔离日志
2. 独立配置每个日志器
3. 命名空间过滤

### 3.4 结构化日志最佳实践

```dart
// Google 结构化日志论文建议
LogRecord {
  timestamp: ISO8601,
  level: string,
  message: string,
  context: {
    userId: string,
    sessionId: string,
    traceId: string,  // 链路追踪
  },
  error?: {
    message: string,
    stackTrace: string,
  }
}
```

**借鉴点：**
1. 统一的 context 上下文
2. 结构化字段优于字符串拼接
3. 链路追踪 ID

---

## 四、成熟化建议

### 4.1 核心功能增强（P0）

#### 4.1.1 日志命名空间/隔离

```dart
// 新增：命名空间支持
class LoggerKit {
  // 获取带命名空间的 logger
  static Logger namespace(String name, {LogConfig? config});
  
  // 预设命名空间
  static Logger get network => namespace('network');
  static Logger get database => namespace('database');
  static Logger get ui => namespace('ui');
}

// 使用示例
LoggerKit.network.i('API request sent');
LoggerKit.database.d('Query executed', tag: 'SQL');
```

**实现要点：**
- LoggerManager 管理多个 Logger 实例
- 命名空间自动添加 tag
- 支持独立配置每个命名空间

#### 4.1.2 Builder 链式配置

```dart
// 新增：Builder 模式
LoggerKit.init(
  minLevel: LogLevel.info,
  enableConsole: true,
  enableFile: true,
  filePath: './logs',
);

// 改进为链式
LoggerKit.builder()
  ..minLevel(LogLevel.info)
  ..console()
  ..file(path: './logs', maxSize: 10 * 1024 * 1024)
  ..remote(url: 'https://api.example.com/logs')
  ..privacyFields(['password', 'token'])
  ..build();
```

**实现要点：**
- LoggerBuilder 类
- 必选参数强制，可选参数链式
- 向后兼容 init() 方法

### 4.2 生产环境优化（P1）

#### 4.2.1 隐私自动过滤

```dart
// 新增：隐私字段过滤
class PrivacyFilter implements LogInterceptor {
  final List<String> privacyFields = [
    'password',
    'token',
    'secret',
    'apiKey',
    'authorization',
    'creditCard',
  ];
  
  LogRecord intercept(LogRecord record) {
    if (record.data != null) {
      record.data = _filterSensitiveData(record.data!);
    }
    return record;
  }
}

// 使用
LoggerKit.builder()
  ..addInterceptor(PrivacyFilter())
  ..build();
```

**实现要点：**
- 递归过滤 Map 中的敏感字段
- 支持自定义隐私字段列表
- 日志脱敏（替换为 ***）

#### 4.2.2 Release 模式自动降级

```dart
// 新增：环境感知
class EnvironmentConfig {
  static bool get isRelease => kReleaseMode;
}

// 自动降级
LoggerKit.builder()
  ..console()  // 调试模式显示
  ..minLevel(kReleaseMode ? LogLevel.warning : LogLevel.debug)
  ..privacyFields(['password'])  // 生产模式强制
  ..build();
```

**实现要点：**
- 使用 Flutter 的 kReleaseMode
- Release 模式默认只记录 warning+
- 可手动覆盖

### 4.3 扩展功能（P2）

#### 4.3.1 中间件/拦截器

```dart
// 新增：LogInterceptor 接口
abstract class LogInterceptor {
  LogRecord intercept(LogRecord record);
  int get order;  // 执行顺序
}

// 使用示例
LoggerKit.builder()
  ..addInterceptor(UserContextInterceptor())
  ..addInterceptor(DeviceInfoInterceptor())
  ..addInterceptor(PrivacyFilter())
  ..build();
```

#### 4.3.2 结构化上下文

```dart
// 新增：LogContext
class LogContext {
  String? userId;
  String? sessionId;
  String? traceId;
  String? deviceId;
  Map<String, dynamic> custom;
}

// 设置全局上下文
LoggerKit.setContext(LogContext(
  userId: '12345',
  sessionId: 'abc123',
));
```

---

## 五、轻量化策略

### 5.1 核心 + 扩展分离

```
logger_kit/
├── logger_kit.dart           # 核心，零外部依赖
├── logger_kit_file.dart      # 文件输出（需 path 包）
├── logger_kit_remote.dart     # 远程上报（需 http 包）
└── logger_kit_flutter.dart   # Flutter 特有功能
```

### 5.2 依赖分层

```yaml
# 核心 - 零依赖
name: logger_kit
dependencies:
  flutter:
    sdk: flutter

# 文件扩展 - 1 依赖
name: logger_kit_file
dependencies:
  logger_kit:
    path: ../logger_kit
  path: ^1.8.3

# 远程扩展 - 1 依赖
name: logger_kit_remote
dependencies:
  logger_kit:
    path: ../logger_kit
  http: ^1.1.0
```

### 5.3 条件导出

```dart
// logger_kit.dart
export 'src/core/logger_kit.dart';

// 扩展功能条件导出
export 'src/extensions/file_logger.dart' if (dart.library.path) 'src/extensions/file_logger_stub.dart';
```

---

## 六、参考项目

| 项目 | 地址 | 借鉴点 |
|------|------|--------|
| logger | https://pub.dev/packages/logger | 轻量化设计、Printer 抽象 |
| flutter_logger_easier | https://github.com/jacklee1995/flutter_logger_easier | 中间件架构 |
| talker | https://github.com/jbkc85/talker | 命名空间隔离、UI 集成 |
| FLogs | https://pub.dev/packages/flogs | 数据库存储、导出机制 |
| zap (Go) | https://github.com/uber-go/zap | 结构化日志、性能设计 |
| Python logging | 标准库 | 成熟的日志框架设计 |

---

## 附录：版本规划建议

| 版本 | 目标 | 主要特性 |
|------|------|----------|
| 1.1.0 | 架构升级 | Builder 模式、命名空间、中间件 |
| 2.1.0 | 生产就绪 | 隐私过滤、环境感知 |
| 2.2.0 | 扩展完善 | 文件压缩、远程优化 |
| 3.0.0 | 模块拆分 | 核心/文件/远程分离 |

---

*文档生成时间：2025年1月*
