# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-03-08

### Added
- 📝 多级别日志系统（Debug, Info, Warning, Error, Fatal）
- 🖥️ 彩色控制台输出
- 💾 文件日志支持（自动轮转和清理）
- 📤 远程日志上传（批量上传）
- 🎨 多种日志格式化器（Simple, JSON, Colored）
- 🔍 日志过滤系统（级别过滤、标签过滤）
- 📊 事件追踪功能
- ⚡ 异步日志写入
- 🛠️ 灵活的配置系统

### Features
- LogLevel - 日志级别枚举
- LogRecord - 日志记录模型
- LogConfig - 日志配置类
- LogFormatter - 日志格式化器接口
- LogWriter - 日志写入器接口
- LogFilter - 日志过滤器接口
- Logger - 日志记录器类
- LoggerKit - 全局日志管理器

### Documentation
- README.md - 完整使用文档
- 示例代码
- API参考

## [Unreleased]

### Planned
- 日志查询功能
- 日志导出功能
- 更多格式化器
- 性能监控集成
- 崩溃日志收集
