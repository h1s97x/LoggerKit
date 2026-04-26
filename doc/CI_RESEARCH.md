# Flutter 仓库 CI/CD 调研报告

> 调研时间: 2025-04
> 仓库: flutter/samples, getx, rive-flutter, flame-engine/flame, bitwarden/mobile

---

## 一、各仓库 CI 概览

| 仓库 | 特点 | Workflow 数量 |
|------|------|---------------|
| **flutter/samples** | 官方标准、简洁直接 | 8 个 |
| **getx** | 基础实用 | 1 个 |
| **rive-flutter** | 极简测试 | 2 个 |
| **flame-engine/flame** | 最完善、monorepo | 9 个 |
| **bitwarden/mobile** | 企业级规范 | 11 个 |

---

## 二、最佳实践汇总

### 1. Flutter 官方 (flutter/samples) - ⭐⭐⭐⭐⭐

**核心特点**: 简洁、标准、权限最小化

```yaml
# 权限控制
permissions: read-all

# 触发条件
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
  schedule:
    - cron: "0 0 * * *" # 每日凌晨检查

# 矩阵策略
strategy:
  fail-fast: false
  matrix:
    flutter_version: [stable]
    os: [ubuntu-latest, macos-latest]
```

**优点**:
- ✅ 权限最小化原则 (`permissions: read-all`)
- ✅ 使用精确的 commit SHA (`@de0fac2e4500dabe0009e67214ff5f5447ce83dd`)
- ✅ 多平台测试 (ubuntu + macos)
- ✅ 定时检查

### 2. Flame Engine (flame-engine/flame) - ⭐⭐⭐⭐⭐

**核心特点**: Monorepo 支持、多阶段流水线、最完善

```yaml
# 环境变量统一管理
env:
  FLUTTER_MIN_VERSION: '3.41.0'

jobs:
  # LINTING STAGE
  format:
  analyze:
  analyze-latest:      # 测试最新版本
  markdown-lint:
  dcm:                 # Dart Code Metrics

  # TESTING STAGE
  test:

  # 发布分离
  release-tag:         # 自动打 tag
  release-publish:     # 发布到 pub.dev
```

**优点**:
- ✅ 阶段分离 (lint → analyze → test → release)
- ✅ 使用 `bluefireteam/melos-action` 管理 monorepo
- ✅ 多版本分析 (最低支持版本 + 最新稳定版)
- ✅ DCM (Dart Code Metrics) 代码质量检查
- ✅ markdownlint 文档检查
- ✅ 自动生成 GitHub Release 和 CHANGELOG
- ✅ melos-action 自动 tag 管理

### 3. GetX (getx) - ⭐⭐⭐

**核心特点**: 基础实用、Coverage 上报

```yaml
- uses: codecov/codecov-action@v4
- run: flutter test --coverage
```

**优点**:
- ✅ 简单的 Coverage 上报
- ❌ 缺少 format 检查
- ❌ 缺少 analyze 步骤

### 4. Rive Flutter (rive-app/rive-flutter) - ⭐⭐⭐

**核心特点**: 极简、LFS 支持

```yaml
- name: Configure git-lfs to ignore most files
  run: |
    git config --global lfs.fetchinclude 'test/**'
- uses: actions/checkout@v3
  with:
    lfs: true
```

**优点**:
- ✅ Git LFS 配置优化
- ❌ 过于简单，缺少必要检查

### 5. Bitwarden Mobile (bitwarden/mobile) - ⭐⭐⭐⭐

**核心特点**: 企业级、PR 规范、Issue 自动处理

```yaml
# PR 标签强制
- name: Enforce Label
  uses: yogevbd/enforce-label-action@...
  with:
    BANNED_LABELS: "hold,needs-qa"

# PR 自动标签
- name: Label PR
  uses: actions/labeler@...

# Issue 自动响应
- if: github.event.label.name == 'feature-request'
  name: Feature request
  uses: peter-evans/close-issue@...
```

**优点**:
- ✅ PR 标签强制检查
- ✅ 自动 PR 标签 (根据路径)
- ✅ Issue 自动回复/关闭
- ✅ 版本自动 bump

---

## 三、推荐 CI 配置 (LoggerKit)

基于调研，为 LoggerKit 推荐以下 CI 配置：

### 1. Dart CI (dart.yml)

```yaml
name: Dart CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]
  workflow_dispatch:

# 权限最小化
permissions:
  contents: read
  pull-requests: write

env:
  FLUTTER_VERSION: '3.24.0'

jobs:
  # 1. 格式检查
  format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      - name: Format check
        run: dart format --set-exit-if-changed .

  # 2. 静态分析
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      - run: flutter pub get
      - run: flutter analyze

  # 3. 测试
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter test --reporter compact

  # 4. 代码质量 (pana)
  pana:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      - run: flutter pub get
      - name: Run pana
        run: |
          flutter pub global activate pana
          flutter pub global run pana --no-terminal

  # 5. 自动修复格式问题
  format-fix:
    needs: format
    if: failure()
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      - name: Format and create PR
        run: |
          dart format -o=changeset .
      - uses: peter-evans/create-pull-request@v5
        with:
          title: 'style: dart format fixes'
          branch: chore/dart-format
```

### 2. PR 规范 (pr-check.yml)

```yaml
name: PR Checks

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  # PR Title 规范检查
  title-check:
    runs-on: ubuntu-latest
    steps:
      - uses: amannn/action-semantic-pull-request@v6
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            build
            chore
            ci
            docs
            feat
            fix
            perf
            refactor
            style

  # PR 标签检查
  label-check:
    runs-on: ubuntu-latest
    steps:
      - name: Check for labels
        run: |
          if [ -z "${{ github.event.pull_request.labels }}" ]; then
            echo "No labels found. Please add at least one label."
            exit 1
          fi
```

### 3. 发布配置 (publish.yml)

```yaml
name: Publish to pub.dev

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+'
  workflow_dispatch:

jobs:
  publish:
    permissions:
      contents: read
      id-token: write
    uses: dart-lang/setup-dart/.github/workflows/publish.yml@v1
```

---

## 四、CI 最佳实践总结

### 必做项 ⭐⭐⭐⭐⭐

| 项目 | 说明 |
|------|------|
| Format Check | `dart format --set-exit-if-changed .` |
| Static Analyze | `flutter analyze` |
| Unit Tests | `flutter test` |
| 最小权限 | `permissions: read-all` |
| 自动修复 | format-fix 自动创建 PR |

### 推荐项 ⭐⭐⭐⭐

| 项目 | 说明 |
|------|------|
| Pana | 代码质量分析 |
| Coverage | 测试覆盖率上报 |
| 多平台 | ubuntu + macos |
| 定时检查 | 每日凌晨运行 |

### 可选项 ⭐⭐⭐

| 项目 | 说明 |
|------|------|
| DCM | Dart Code Metrics |
| Markdownlint | 文档格式检查 |
| PR Title 检查 | 强制 conventional commits |
| 自动标签 | PR 按路径自动打标签 |

---

## 五、参考链接

- [Flutter CI 模板](https://github.com/flutter/samples/blob/main/.github/workflows/main.yml)
- [Flame Engine CI](https://github.com/flame-engine/flame/blob/main/.github/workflows/)
- [conventional-commits](https://www.conventionalcommits.org/)
- [amannn/action-semantic-pull-request](https://github.com/amannn/action-semantic-pull-request)
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request)
