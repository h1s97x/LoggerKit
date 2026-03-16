# 贡献指南

感谢您对 LoggerKit 项目的关注！本指南将帮助您为项目做出贡献。

## 项目概览

LoggerKit 是一个功能完善的 Flutter 日志工具包，支持控制台、文件和远程日志记录。

## 架构概览

```text
logger_kit/
├── lib/
│   ├── logger_kit.dart                 # 主导出文件
│   └── src/
│       ├── core/                        # 核心类
│       │   ├── logger.dart             # 日志记录器
│       │   └── logger_kit.dart         # 全局管理器
│       ├── models/                      # 数据模型
│       │   ├── log_level.dart          # 日志级别
│       │   ├── log_record.dart         # 日志记录
│       │   ├── log_config.dart         # 日志配置
│       │   └── models.dart             # 模型导出
│       ├── formatters/                  # 格式化器
│       │   └── log_formatter.dart      # 日志格式化
│       ├── writers/                     # 写入器
│       │   ├── log_writer.dart         # 写入器接口
│       │   ├── file_writer.dart        # 文件写入
│       │   └── remote_writer.dart      # 远程写入
│       └── filters/                     # 过滤器
│           └── log_filter.dart         # 日志过滤
│
├── example/                             # 示例应用
│   └── logger_kit_example.dart
├── benchmark/                           # 性能测试
│   └── logger_kit_benchmark.dart
├── test/                                # 单元测试
└── doc/                                 # 文档
    └── USAGE_GUIDE.md
```

## 如何贡献

### 添加新的格式化器

在 `lib/src/formatters/log_formatter.dart` 中添加新的格式化器类：

```dart
class MyCustomFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    // 实现自定义格式化逻辑
    return '${record.level}: ${record.message}';
  }
}
```

### 添加新的写入器

在 `lib/src/writers/` 目录下创建新的写入器：

```dart
// lib/src/writers/my_writer.dart
class MyWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    // 实现写入逻辑
  }

  @override
  Future<void> close() async {
    // 清理资源
  }
}
```

### 添加新的过滤器

在 `lib/src/filters/log_filter.dart` 中添加新的过滤器：

```dart
class MyFilter implements LogFilter {
  @override
  bool shouldLog(LogRecord record) {
    // 实现过滤逻辑
    return true;
  }
}
```

## 代码风格指南

### Dart 代码

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- 使用 `dart format` 格式化代码
- 运行 `flutter analyze` 检查问题
- 为公共 API 添加文档注释

示例：

```dart
/// 记录日志
///
/// [level] 日志级别
/// [message] 日志消息
/// [tag] 可选的标签
/// [data] 可选的附加数据
Future<void> log(
  LogLevel level,
  String message, {
  String? tag,
  Map<String, dynamic>? data,
}) async {
  // 实现
}
```

## 测试

### 运行单元测试

```bash
flutter test
```

### 运行基准测试

```bash
dart benchmark/logger_kit_benchmark.dart
```

### 运行示例

```bash
dart example/logger_kit_example.dart
```

## Pull Request 流程

1. Fork 仓库
2. 创建功能分支：`git checkout -b feature/my-new-feature`
3. 进行修改
4. 为新功能添加测试
5. 确保所有测试通过：`flutter test`
6. 确保代码分析通过：`flutter analyze`
7. 格式化代码：`dart format .`
8. 提交并附上描述性消息：`git commit -m "feat: 添加新功能"`
9. 推送到您的 fork：`git push origin feature/my-new-feature`
10. 创建 Pull Request

### 提交消息格式

遵循 [Conventional Commits](https://www.conventionalcommits.org/)：

```text
<类型>(<范围>): <主题>

<正文>

<页脚>
```

类型：

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档变更
- `style`: 代码格式变更
- `refactor`: 代码重构
- `test`: 添加或更新测试
- `chore`: 维护任务

示例：

```text
feat(formatter): 添加 JSON 格式化器
fix(writer): 修正文件轮转逻辑
docs: 更新使用指南
```

## 获取帮助

- 查看现有 [issues](https://github.com/h1s97x/LoggerKit/issues)
- 阅读 [文档](https://github.com/h1s97x/LoggerKit/blob/main/README.md)
- 在 [discussions](https://github.com/h1s97x/LoggerKit/discussions) 提问

## 行为准则

- 尊重和包容
- 提供建设性反馈
- 关注对社区最有利的事情
- 对其他社区成员表现出同理心

## 许可证

通过贡献，您同意您的贡献将在 MIT 许可证下授权。

## 致谢

贡献者将在以下位置获得认可：

- `AUTHORS` 文件
- 发布说明
- 项目 README

感谢您为 LoggerKit 做出贡献！

---

**项目地址**: https://github.com/h1s97x/LoggerKit  
**许可证**: MIT
