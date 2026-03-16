# LoggerKit 提交方案

本文档描述 LoggerKit 项目的 Git 提交计划，遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范。

## 提交规范

### 提交消息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型 (Type)

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档变更
- `style`: 代码格式变更（不影响代码运行）
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 添加或更新测试
- `build`: 构建系统或外部依赖变更
- `ci`: CI 配置文件和脚本变更
- `chore`: 其他不修改 src 或 test 文件的变更
- `revert`: 回滚之前的提交

### 范围 (Scope)

- `core`: 核心功能（Logger, LoggerKit）
- `models`: 数据模型（LogLevel, LogRecord, LogConfig）
- `formatters`: 格式化器
- `writers`: 写入器
- `filters`: 过滤器
- `example`: 示例代码
- `benchmark`: 性能测试
- `test`: 测试代码
- `docs`: 文档
- `ci`: CI/CD 配置

---

## 提交计划

### 第一阶段：项目初始化

#### Commit 1: 项目基础结构
```
chore: initialize project structure

- Add pubspec.yaml with dependencies
- Add analysis_options.yaml
- Add .gitignore
- Add LICENSE (MIT)
- Add basic README.md
```

**文件**:
- `pubspec.yaml`
- `analysis_options.yaml`
- `.gitignore`
- `LICENSE`
- `README.md`

---

### 第二阶段：核心功能实现

#### Commit 2: 添加数据模型
```
feat(models): add core data models

- Add LogLevel enum with 5 levels (debug, info, warning, error, fatal)
- Add LogRecord class for log entries
- Add LogConfig class for configuration
- Add models.dart for exports

BREAKING CHANGE: Initial implementation
```

**文件**:
- `lib/src/models/log_level.dart`
- `lib/src/models/log_record.dart`
- `lib/src/models/log_config.dart`
- `lib/src/models/models.dart`

#### Commit 3: 实现日志格式化器
```
feat(formatters): implement log formatters

- Add LogFormatter interface
- Add SimpleFormatter for basic formatting
- Add JsonFormatter for JSON output
- Add ColoredFormatter for console with colors
- Support timestamp, tag, emoji, and pretty print options
```

**文件**:
- `lib/src/formatters/log_formatter.dart`

#### Commit 4: 实现日志写入器
```
feat(writers): implement log writers

- Add LogWriter interface
- Add ConsoleWriter for console output
- Add FileWriter with automatic rotation and cleanup
- Add RemoteWriter with batch upload (10 logs or 30s interval)
- Support async write operations
```

**文件**:
- `lib/src/writers/log_writer.dart`
- `lib/src/writers/file_writer.dart`
- `lib/src/writers/remote_writer.dart`

#### Commit 5: 实现日志过滤器
```
feat(filters): implement log filters

- Add LogFilter interface
- Add LevelFilter for level-based filtering
- Add TagFilter for tag-based filtering
- Add CompositeFilter for combining multiple filters
```

**文件**:
- `lib/src/filters/log_filter.dart`

#### Commit 6: 实现核心日志功能
```
feat(core): implement Logger and LoggerKit classes

- Add Logger class with formatter, writer, and filter support
- Add LoggerKit global manager with static methods
- Support d(), i(), w(), e(), f() log methods
- Support event tracking
- Support custom tags and data
```

**文件**:
- `lib/src/core/logger.dart`
- `lib/src/core/log_kit.dart`
- `lib/log_kit.dart`

---

### 第三阶段：示例和文档

#### Commit 7: 添加示例代码
```
docs(example): add example application

- Add comprehensive example demonstrating all features
- Show basic logging, tagged logging, data logging
- Show error logging with stack traces
- Show event tracking
- Add file logging example
```

**文件**:
- `example/log_kit_example.dart`

#### Commit 8: 添加基础文档
```
docs: add comprehensive documentation

- Add detailed README with features and usage
- Add GETTING_STARTED guide
- Add CHANGELOG
- Add CONTRIBUTING guidelines
```

**文件**:
- `README.md` (更新)
- `GETTING_STARTED.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`

#### Commit 9: 添加高级文档
```
docs: add advanced documentation

- Add API reference documentation
- Add architecture design document
- Add code style guide
- Add quick reference guide
- Add usage guide with best practices
```

**文件**:
- `doc/API.md`
- `doc/ARCHITECTURE.md`
- `doc/CODE_STYLE.md`
- `doc/QUICK_REFERENCE.md`
- `doc/USAGE_GUIDE.md`

---

### 第四阶段：测试和质量保证

#### Commit 10: 添加单元测试
```
test: add comprehensive unit tests

- Add LogLevel tests (7 tests)
- Add LogFilter tests (6 tests)
- Add LogRecord tests (6 tests)
- Add LogFormatter tests (4 tests)
- Add LoggerKit tests (6 tests)
- Total: 29 tests with 100% pass rate
```

**文件**:
- `test/log_level_test.dart`
- `test/log_filter_test.dart`
- `test/log_record_test.dart`
- `test/log_formatter_test.dart`
- `test/log_kit_test.dart`

#### Commit 11: 添加性能基准测试
```
perf(benchmark): add performance benchmarks

- Add basic logging benchmark (10,000 iterations)
- Add log levels benchmark (5,000 iterations each)
- Add logging with data benchmark
- Add file logging benchmark
- Add concurrent logging benchmark (10 threads)
- Add benchmark README with results
```

**文件**:
- `benchmark/log_kit_benchmark.dart`
- `benchmark/README.md`

#### Commit 12: 配置 CI/CD
```
ci: setup GitHub Actions workflow

- Add Dart CI workflow
- Configure Flutter 3.41.0
- Add dependency installation
- Add code formatting check
- Add code analysis
- Add test execution with coverage
- Add example execution
- Add Codecov integration
```

**文件**:
- `.github/workflows/dart.yml`
- `.github/README_BADGES.md`

---

### 第五阶段：优化和完善

#### Commit 13: 代码格式化和 lint 修复
```
style: format code and fix lint issues

- Run dart format on all files
- Fix constructor ordering issues
- Add ignore comments for necessary print statements
- Ensure all files follow style guide
- Zero lint issues remaining
```

**文件**: 所有源代码文件

#### Commit 14: 优化文件写入器
```
fix(writers): improve file writer cleanup on Windows

- Add delay before directory deletion
- Improve error handling for file cleanup
- Fix temporary directory cleanup issues
- Ensure proper file handle release
```

**文件**:
- `lib/src/writers/file_writer.dart`
- `benchmark/log_kit_benchmark.dart`

#### Commit 15: 添加项目元数据
```
chore: add project metadata and configuration

- Add .pubignore for pub.dev publishing
- Add commit convention documentation
- Add commit plan documentation
- Update pubspec.yaml with correct repository URL
```

**文件**:
- `.pubignore`
- `.github/COMMIT_CONVENTION.md`
- `COMMIT_PLAN.md`
- `pubspec.yaml` (更新)

#### Commit 16: 项目重命名 log_kit → logger_kit
```
refactor: rename project from log_kit to logger_kit

- Rename package from log_kit to logger_kit
- Rename class from LogKit to LoggerKit
- Update all file names to use logger_kit
- Update all imports and references
- Update documentation with new package name
- Update GitHub URL to https://github.com/h1s97x/LoggerKit
- Update pub.dev package references

Files renamed:
- lib/log_kit.dart → lib/logger_kit.dart
- lib/src/core/log_kit.dart → lib/src/core/logger_kit.dart
- example/log_kit_example.dart → example/logger_kit_example.dart
- benchmark/log_kit_benchmark.dart → benchmark/logger_kit_benchmark.dart
- test/log_kit_test.dart → test/logger_kit_test.dart

Files updated:
- pubspec.yaml
- README.md
- CONTRIBUTING.md
- doc/GETTING_STARTED.md
- doc/USAGE_GUIDE.md
- doc/ARCHITECTURE.md
- doc/API.md
- doc/QUICK_REFERENCE.md
- doc/CODE_STYLE.md
- CHANGELOG.md
- .github/README_BADGES.md
- All test files
- All example and benchmark files
```

**文件**:
- `lib/logger_kit.dart` (新)
- `lib/src/core/logger_kit.dart` (新)
- `example/logger_kit_example.dart` (新)
- `benchmark/logger_kit_benchmark.dart` (新)
- `test/logger_kit_test.dart` (新)
- `pubspec.yaml` (更新)
- `README.md` (更新)
- `CONTRIBUTING.md` (更新)
- `doc/GETTING_STARTED.md` (更新)
- `doc/USAGE_GUIDE.md` (更新)
- `doc/ARCHITECTURE.md` (更新)
- `doc/API.md` (更新)
- `doc/QUICK_REFERENCE.md` (更新)
- `doc/CODE_STYLE.md` (更新)
- `CHANGELOG.md` (更新)
- `.github/README_BADGES.md` (更新)
- `test/log_filter_test.dart` (更新)
- `test/log_formatter_test.dart` (更新)
- `test/log_level_test.dart` (更新)
- `test/log_record_test.dart` (更新)

---

## 提交顺序总结

1. ✅ `chore: initialize project structure`
2. ✅ `feat(models): add core data models`
3. ✅ `feat(formatters): implement log formatters`
4. ✅ `feat(writers): implement log writers`
5. ✅ `feat(filters): implement log filters`
6. ✅ `feat(core): implement Logger and LoggerKit classes`
7. ✅ `docs(example): add example application`
8. ✅ `docs: add comprehensive documentation`
9. ✅ `docs: add advanced documentation`
10. ✅ `test: add comprehensive unit tests`
11. ✅ `perf(benchmark): add performance benchmarks`
12. ✅ `ci: setup GitHub Actions workflow`
13. ✅ `style: format code and fix lint issues`
14. ✅ `fix(writers): improve file writer cleanup on Windows`
15. ✅ `chore: add project metadata and configuration`
16. ⏳ `refactor: rename project from log_kit to logger_kit`

---

## 执行提交

### 方式 1: 逐个提交（推荐）

```bash
# Commit 1
git add pubspec.yaml analysis_options.yaml .gitignore LICENSE README.md
git commit -m "chore: initialize project structure

- Add pubspec.yaml with dependencies
- Add analysis_options.yaml
- Add .gitignore
- Add LICENSE (MIT)
- Add basic README.md"

# Commit 2
git add lib/src/models/
git commit -m "feat(models): add core data models

- Add LogLevel enum with 5 levels (debug, info, warning, error, fatal)
- Add LogRecord class for log entries
- Add LogConfig class for configuration
- Add models.dart for exports

BREAKING CHANGE: Initial implementation"

# ... 继续其他提交 ...

# Commit 16: 项目重命名
git add -A
git commit -m "refactor: rename project from log_kit to logger_kit

- Rename package from log_kit to logger_kit
- Rename class from LogKit to LoggerKit
- Update all file names to use logger_kit
- Update all imports and references
- Update documentation with new package name
- Update GitHub URL to https://github.com/h1s97x/LoggerKit
- Update pub.dev package references"
```

### 方式 2: 批量提交

```bash
# 添加所有文件
git add .

# 创建初始提交
git commit -m "feat: initial LoggerKit implementation

Complete logging toolkit for Flutter with:
- Multi-level logging (debug, info, warning, error, fatal)
- Console, file, and remote logging support
- Customizable formatters, writers, and filters
- Event tracking
- Comprehensive documentation
- Unit tests (29 tests, 100% pass)
- Performance benchmarks
- CI/CD with GitHub Actions

BREAKING CHANGE: Initial release"
```

### 方式 3: 交互式提交

```bash
# 使用交互式添加
git add -p

# 分批提交不同的功能
git commit -m "feat(core): implement core logging functionality"
git add -p
git commit -m "test: add unit tests"
# ...
```

---

## 推送到远程仓库

```bash
# 添加远程仓库
git remote add origin https://github.com/h1s97x/LoggerKit.git

# 推送到 main 分支
git push -u origin main

# 或推送到 develop 分支
git checkout -b develop
git push -u origin develop
```

---

## 版本标签

### 创建版本标签

```bash
# 创建 v1.0.0 标签
git tag -a v1.0.0 -m "Release version 1.0.0

Features:
- Multi-level logging (debug, info, warning, error, fatal)
- Console, file, and remote logging
- Customizable formatters, writers, and filters
- Event tracking
- Comprehensive documentation
- 29 unit tests with 100% pass rate
- Performance benchmarks
- CI/CD with GitHub Actions"

# 推送标签
git push origin v1.0.0

# 推送所有标签
git push origin --tags
```

---

## 分支策略

### 主要分支

- `main`: 稳定的生产版本
- `develop`: 开发分支

### 功能分支

- `feature/*`: 新功能开发
- `fix/*`: Bug 修复
- `docs/*`: 文档更新
- `test/*`: 测试相关

### 示例工作流

```bash
# 创建功能分支
git checkout -b feature/add-custom-formatter

# 开发和提交
git add .
git commit -m "feat(formatters): add custom formatter support"

# 推送到远程
git push origin feature/add-custom-formatter

# 创建 Pull Request
# 合并后删除分支
git branch -d feature/add-custom-formatter
```

---

## 发布检查清单

在发布新版本前，确保：

- [ ] 所有测试通过 (`flutter test`)
- [ ] 代码分析无问题 (`flutter analyze`)
- [ ] 代码已格式化 (`dart format .`)
- [ ] 文档已更新
- [ ] CHANGELOG.md 已更新
- [ ] 版本号已更新 (`pubspec.yaml`)
- [ ] 示例代码可运行
- [ ] CI/CD 通过
- [ ] 创建了版本标签

---

## 相关文档

- [Conventional Commits](https://www.conventionalcommits.org/)
- [提交规范](.github/COMMIT_CONVENTION.md)
- [贡献指南](CONTRIBUTING.md)
- [变更日志](CHANGELOG.md)

---

**项目**: LoggerKit  
**版本**: 1.0.0  
**日期**: 2026-03-09  
**项目地址**: https://github.com/h1s97x/LoggerKit
