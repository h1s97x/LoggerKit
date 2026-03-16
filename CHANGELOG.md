# Changelog | 更新日志

## Table of Contents | 目录

- [English](#english)
- [中文](#中文)

---

## English

### [1.0.2] - 2026-03-16

#### Added
- Comprehensive dartdoc comments for all public APIs
- Detailed documentation for all classes, methods, and parameters
- Usage examples in dartdoc comments
- Better IDE support with improved documentation

#### Improved
- Enhanced code documentation for better developer experience
- Added parameter descriptions for all public methods
- Included return value documentation

---

### [1.0.1] - 2026-03-16

#### Added
- Bilingual changelog with index
- Automated pub.dev publishing workflow via GitHub Actions
- Version bump to 1.0.1

#### Changed
- Enhanced documentation structure with dual language support

#### Fixed
- Documentation improvements

---

### [1.0.0] - 2026-03-08

#### Added
- 📝 Multi-level logging system (Debug, Info, Warning, Error, Fatal)
- 🖥️ Colored console output
- 💾 File logging support with auto-rotation and cleanup
- 📤 Remote log upload with batch processing
- 🎨 Multiple log formatters (Simple, JSON, Colored)
- 🔍 Log filtering system (level and tag filtering)
- 📊 Event tracking functionality
- ⚡ Asynchronous log writing
- 🛠️ Flexible configuration system

#### Core Components
- LogLevel - Log level enumeration
- LogRecord - Log record model
- LogConfig - Log configuration class
- LogFormatter - Log formatter interface
- LogWriter - Log writer interface
- LogFilter - Log filter interface
- Logger - Logger class
- LoggerKit - Global logger manager

#### Documentation
- Complete usage guide (README.md)
- Getting started guide
- API reference
- Architecture documentation
- Code style guide
- Quick reference guide
- Usage guide with best practices
- Contributing guidelines

#### Testing & Quality
- 29 comprehensive unit tests with 100% pass rate
- Performance benchmarks
- CI/CD with GitHub Actions
- Code coverage tracking with Codecov

#### Infrastructure
- GitHub Actions CI/CD workflow for testing and analysis
- Automated pub.dev publishing workflow
- Code formatting and linting checks
- Example application

---

## 中文

### [1.0.2] - 2026-03-16

#### 新增
- 为所有公开API添加完整的dartdoc注释
- 为所有类、方法和参数添加详细文档
- 在dartdoc注释中包含使用示例
- 改进IDE支持，提供更好的文档

#### 改进
- 增强代码文档，改善开发者体验
- 为所有公开方法添加参数描述
- 包含返回值文档

---

### [1.0.1] - 2026-03-16

#### 新增
- 中英双文CHANGELOG及索引
- 通过GitHub Actions自动发布到pub.dev的工作流
- 版本号更新至1.0.1

#### 变更
- 增强文档结构，支持双语显示

#### 修复
- 文档改进

---

### [1.0.0] - 2026-03-08

#### 新增
- 📝 多级别日志系统（Debug, Info, Warning, Error, Fatal）
- 🖥️ 彩色控制台输出
- 💾 文件日志支持（自动轮转和清理）
- 📤 远程日志上传（批量上传）
- 🎨 多种日志格式化器（Simple, JSON, Colored）
- 🔍 日志过滤系统（级别过滤、标签过滤）
- 📊 事件追踪功能
- ⚡ 异步日志写入
- 🛠️ 灵活的配置系统

#### 核心组件
- LogLevel - 日志级别枚举
- LogRecord - 日志记录模型
- LogConfig - 日志配置类
- LogFormatter - 日志格式化器接口
- LogWriter - 日志写入器接口
- LogFilter - 日志过滤器接口
- Logger - 日志记录器类
- LoggerKit - 全局日志管理器

#### 文档
- 完整使用文档（README.md）
- 快速开始指南
- API参考文档
- 架构设计文档
- 代码风格指南
- 快速参考指南
- 最佳实践使用指南
- 贡献指南

#### 测试与质量
- 29个综合单元测试，通过率100%
- 性能基准测试
- GitHub Actions CI/CD工作流
- Codecov代码覆盖率追踪

#### 基础设施
- GitHub Actions CI/CD工作流（测试和分析）
- 自动发布到pub.dev的工作流
- 代码格式化和Lint检查
- 示例应用程序

---

## Unreleased | 未发布

### Planned | 计划中
- Log query functionality / 日志查询功能
- Log export functionality / 日志导出功能
- More formatters / 更多格式化器
- Performance monitoring integration / 性能监控集成
- Crash log collection / 崩溃日志收集
