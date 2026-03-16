# Git Hooks

这个目录包含项目的 Git hooks，用于自动化检查和规范化提交流程。

## 安装 Hooks

在项目根目录运行以下命令来安装 hooks。

### Windows (PowerShell)

```powershell
# 复制 hooks 到 .git/hooks 目录
Copy-Item -Path .github/hooks/commit-msg -Destination .git/hooks/commit-msg -Force
Copy-Item -Path .github/hooks/prepare-commit-msg -Destination .git/hooks/prepare-commit-msg -Force

# 如果使用 Git Bash，需要添加执行权限
# chmod +x .git/hooks/commit-msg
# chmod +x .git/hooks/prepare-commit-msg
```

### macOS/Linux

```bash
# 复制 hooks 到 .git/hooks 目录
cp .github/hooks/commit-msg .git/hooks/commit-msg
cp .github/hooks/prepare-commit-msg .git/hooks/prepare-commit-msg

# 添加执行权限
chmod +x .git/hooks/commit-msg
chmod +x .git/hooks/prepare-commit-msg
```

### 使用符号链接（推荐）

```bash
# 创建符号链接（更新 hooks 时自动同步）
ln -sf ../../.github/hooks/commit-msg .git/hooks/commit-msg
ln -sf ../../.github/hooks/prepare-commit-msg .git/hooks/prepare-commit-msg

# 添加执行权限
chmod +x .github/hooks/commit-msg
chmod +x .github/hooks/prepare-commit-msg
```

## 配置提交模板

```bash
# 设置提交信息模板
git config commit.template .gitmessage
```

## Hooks 说明

### commit-msg

检查提交信息是否符合规范格式：

- 验证提交类型（feat, fix, docs 等）
- 检查标题行长度
- 提供友好的错误提示

### prepare-commit-msg

自动在提交信息中添加相关信息：

- 从分支名提取 issue 编号并自动添加引用

## 跳过 Hooks

如果需要临时跳过 hooks 检查：

```bash
git commit --no-verify -m "your message"
```

注意：不建议经常跳过 hooks，这会降低代码质量。

## 卸载 Hooks

```bash
# 删除 hooks
rm .git/hooks/commit-msg
rm .git/hooks/prepare-commit-msg
```
