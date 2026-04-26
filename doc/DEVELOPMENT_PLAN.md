# LoggerKit 开发计划

> 文档版本：v1.2
> 更新日期：2025年1月
> 核心原则：轻量化 + 零依赖 + 插件化

---

# v1.1.0 版本 ✅ 已完成

## 完成时间
2025年1月

## 功能列表

| 功能 | 说明 | 状态 |
|------|------|------|
| LoggerBuilder | 链式配置构建器 | ✅ |
| LoggerManager | 命名空间管理 | ✅ |
| LogInterceptor | 拦截器接口 | ✅ |
| LogContext | 结构化上下文 | ✅ |
| PrivacyInterceptor | 隐私过滤 | ✅ |
| ContextInterceptor | 上下文注入 | ✅ |
| ConsoleWriter | 控制台输出 | ✅ |
| 向后兼容 | init() API 保持兼容 | ✅ |

## 文档

| 文档 | 状态 |
|------|------|
| doc/BUILDER_GUIDE.md | ✅ |
| doc/NAMESPACE_GUIDE.md | ✅ |
| doc/INTERCEPTOR_GUIDE.md | ✅ |
| doc/PRIVACY_GUIDE.md | ✅ |
| doc/ARCHITECTURE.md | ✅ |
| doc/API.md | ✅ |

---

# v1.2.0 版本计划

> 目标：Pretty Print + 基础错误处理
> 预估工作量：3-4 天

## 一、设计原则

1. **核心零依赖** - 不引入任何外部包
2. **渐进增强** - 用户可选开启 Pretty Print
3. **向后兼容** - 默认行为不变

## 二、功能列表

### 2.1 PrettyPrinter 抽象

```dart
abstract class PrettyPrinter {
  String prettyPrint(dynamic data);
  String prettyJson(Map<String, dynamic> json);
  String prettyList(List<dynamic> list);
  String prettyStackTrace(StackTrace trace);
  String prettyError(Object error, StackTrace? stackTrace);
}
```

### 2.2 DefaultPrettyPrinter 实现

| 功能 | 说明 |
|------|------|
| 多行折叠 | 超过指定行数自动折叠 |
| 堆栈美化 | 路径裁剪 + 相对路径 |
| 对象格式化 | JSON/Map 缩进美化 |
| ANSI 颜色 | 级别/标签颜色（可选）|

### 2.3 ConsoleWriter 增强

```dart
ConsoleWriter({
  bool prettyPrint = false,
  PrettyPrinter? printer,
  bool useColors = true,
  int maxLineLength = 120,
  int maxExpandLines = 10,
})
```

### 2.4 Builder API

```dart
LoggerKit.builder()
  ..console(prettyPrint: true, useColors: true)
  ..build();
```

### 2.5 基础错误处理

| 策略 | 说明 | 使用场景 |
|------|------|----------|
| `ignore` | 静默忽略错误 | 生产环境默认 |
| `logToFallback` | 记录到 fallback writer | 调试时 |
| `throwException` | 抛出异常 | 开发时 |

```dart
ConsoleWriter(
  errorStrategy: ErrorStrategy.logToFallback,
  fallbackWriter: FileWriter(path: './errors.log'),
)
```

## 三、技术方案

### 3.1 目录结构

```
lib/
├── src/
│   ├── pretty/
│   │   ├── pretty_printer.dart      # 抽象类
│   │   ├── default_pretty_printer.dart  # 默认实现
│   │   └── ansi_colors.dart         # ANSI 颜色工具
│   └── writers/
│       └── console_writer.dart       # 更新
```

### 3.2 错误处理接口

```dart
enum ErrorStrategy {
  ignore,           // 静默忽略
  logToFallback,   // 记录到 fallback
  throwException,  // 抛出异常
}

abstract class LogWriter {
  Future<void> write(LogRecord record, String formatted);
  Future<void> flush();
  
  ErrorStrategy get errorStrategy;
  LogWriter? get fallbackWriter;
}
```

### 3.3 背压控制

```dart
// Writer 队列溢出策略
enum OverflowStrategy {
  dropOldest,   // 丢弃最旧的
  dropNewest,   // 丢弃最新的
  block,        // 阻塞等待
}

ConsoleWriter(
  maxQueueSize: 1000,
  overflowStrategy: OverflowStrategy.dropOldest,
)
```

## 四、里程碑

| Milestone | 任务 | 预估 |
|-----------|------|------|
| M1: PrettyPrinter | 抽象类 + 默认实现 | 1天 |
| M2: StackTrace 美化 | 堆栈解析 + 路径裁剪 | 0.5天 |
| M3: ANSI 颜色 | 颜色检测 + 主题 | 0.5天 |
| M4: 错误处理 | 错误策略 + Fallback | 0.5天 |
| M5: 测试文档 | 单元测试 + 文档 | 1天 |

---

# v1.3.0 版本计划

> 目标：模块拆分，Monorepo 结构
> 预估工作量：4-5 天

## 一、设计原则

1. **零依赖核心** - `logger_kit_core` 不依赖任何外部包
2. **按需引入** - 用户只引入需要的模块
3. **聚合包** - `logger_kit` 聚合所有模块

## 二、模块结构

```
packages/
├── logger_kit/                    # 聚合包（默认）
│   ├── pubspec.yaml               # 依赖所有子包
│   └── lib/
│       └── logger_kit.dart        # 导出所有
│
├── logger_kit_core/               # 核心（零依赖）
│   ├── pubspec.yaml               # 无外部依赖
│   └── lib/
│       ├── models/                # LogRecord, LogLevel, LogConfig, LogContext
│       ├── core/                  # Logger, LoggerKit, LoggerBuilder, LoggerManager
│       ├── filters/               # LogFilter 接口
│       ├── formatters/            # LogFormatter 接口
│       └── interceptors/          # LogInterceptor, PrivacyInterceptor, ContextInterceptor
│
├── logger_kit_console/            # 控制台输出
│   ├── pubspec.yaml               # 无外部依赖
│   └── lib/
│       └── writers/
│           └── console_writer.dart
│
├── logger_kit_file/               # 文件输出
│   ├── pubspec.yaml               # 依赖: path
│   └── lib/
│       └── writers/
│           └── file_writer.dart
│
├── logger_kit_remote/             # 远程上报
│   ├── pubspec.yaml               # 依赖: http
│   └── lib/
│       └── writers/
│           └── remote_writer.dart
│
└── logger_kit_pretty/            # Pretty Print（可选）
    ├── pubspec.yaml               # 无外部依赖
    └── lib/
        └── pretty/
            ├── pretty_printer.dart
            └── default_pretty_printer.dart
```

## 三、依赖关系图

```
┌─────────────────────────────────────────────────────────────┐
│                      logger_kit                              │
│                   (聚合包，默认)                              │
└─────────────────────┬───────────────────────────────────────┘
                      │ depends on
        ┌─────────────┼─────────────┬─────────────┬─────────────┐
        ▼             ▼             ▼             ▼             ▼
┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐
│   core     │ │  console  │ │   file    │ │  remote   │ │  pretty   │
│ (零依赖)   │ │ (零依赖)   │ │ (需要path) │ │ (需要http) │ │ (零依赖)   │
└───────────┘ └───────────┘ └───────────┘ └───────────┘ └───────────┘
```

## 四、用户使用方式

### 方式 1：使用聚合包（推荐）

```yaml
dependencies:
  logger_kit: ^1.3.0
```

```dart
import 'package:logger_kit/logger_kit.dart';
// 包含所有功能
```

### 方式 2：按需引入

```yaml
dependencies:
  logger_kit_core: ^1.3.0
  logger_kit_console: ^1.3.0
  logger_kit_file: ^1.3.0
```

```dart
import 'package:logger_kit_core/logger_kit_core.dart';
import 'package:logger_kit_console/writers/console_writer.dart';
```

### 方式 3：仅核心

```yaml
dependencies:
  logger_kit_core: ^1.3.0
```

```dart
import 'package:logger_kit_core/logger_kit_core.dart';
// 无任何输出 Writer，用户自己实现
```

## 五、技术细节

### 5.1 Core 包导出

```dart
// logger_kit_core/lib/logger_kit_core.dart
library;

export 'models/models.dart';
export 'core/core.dart';
export 'filters/log_filter.dart';
export 'formatters/log_formatter.dart';
export 'interceptors/interceptors.dart';
```

### 5.2 聚合包

```dart
// logger_kit/lib/logger_kit.dart
library logger_kit;

export 'package:logger_kit_core/logger_kit_core.dart';
export 'package:logger_kit_console/console_writer.dart';
export 'package:logger_kit_file/file_writer.dart';
export 'package:logger_kit_remote/remote_writer.dart';
export 'package:logger_kit_pretty/pretty_printer.dart';
```

## 六、里程碑

| Milestone | 任务 | 预估 |
|-----------|------|------|
| M1: 结构搭建 | Monorepo 目录结构 | 0.5天 |
| M2: Core 拆分 | 提取核心代码 | 1天 |
| M3: Writer 拆分 | console/file/remote 分离 | 1天 |
| M4: Pretty 拆分 | 提取 pretty 模块 | 0.5天 |
| M5: 聚合包 | logger_kit 聚合 | 0.5天 |
| M6: 测试 | 迁移测试 | 1天 |
| M7: 文档 | 更新文档 | 0.5天 |

---

# v2.0.0 版本计划

> 目标：破坏性变更 + 企业级插件
> 预估工作量：待定

## 一、设计原则

1. **清理废弃 API** - 删除 v1.x 的 deprecated 接口
2. **不可变设计** - LogRecord 改为不可变
3. **异步优先** - 所有操作异步化

## 二、破坏性变更

### 2.1 移除的 API

| API | 替代 | 废弃版本 |
|-----|------|----------|
| `init()` | `LoggerBuilder` | v1.1 |
| `LogConfig()` | `LoggerBuilder` | v1.1 |
| `LogWriter.write()` | `LogWriter.writeAsync()` | v1.2 |

### 2.2 类型变更

```dart
// LogRecord 不可变设计
@immutable
class LogRecord {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? data;
  final LogContext? context;
}

// LogLevel 增加 trace
enum LogLevel {
  trace,   // 比 debug 更细粒度
  debug,
  info,
  warn,
  error,
  fatal,
}
```

### 2.3 异步优先

```dart
// 所有操作异步化
abstract class Logger {
  Future<void> log(LogRecord record);
  Future<void> debug(String message, {String? tag, Map<String, dynamic>? data});
  Future<void> info(String message, {String? tag, Map<String, dynamic>? data});
  Future<void> close();
}
```

## 三、插件生态（可选）

### 3.1 logger_kit_compliance

企业级合规插件

```dart
// GDPR 合规
class ComplianceInterceptor extends LogInterceptor {
  final RetentionPolicy retention;
  final List<String> piiFields;
  final bool enableAuditLog;
}

// 日志留存策略
enum RetentionPolicy {
  days7,
  days30,
  days90,
  forever,
}
```

### 3.2 logger_kit_i18n

国际化支持

```dart
class I18nInterceptor extends LogInterceptor {
  final Map<String, String> translations;
  final String locale;
}
```

## 四、里程碑

| Milestone | 任务 | 预估 |
|-----------|------|------|
| M1 | API 重构 | 2天 |
| M2 | 不可变设计 | 1天 |
| M3 | 异步化 | 1天 |
| M4 | 迁移指南 | 1天 |
| M5 | 测试更新 | 2天 |

---

# 附录

## 版本依赖关系

| 版本 | 核心依赖 | 可选依赖 |
|------|----------|----------|
| v1.1 | path, http | - |
| v1.2 | path, http | - |
| v1.3 | path, http | - |
| v2.0 | 无 | logger_kit_compliance, logger_kit_i18n |

## 文档更新记录

| 版本 | 更新内容 |
|------|----------|
| v1.0 | 初始计划 |
| v1.1 | 添加 v1.2.0+ 计划 |
| v1.2 | 采纳优化方案，重构计划结构 |

---

*最后更新：2025年1月*
