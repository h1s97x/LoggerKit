#!/bin/bash
# Git Hooks 安装脚本 (Bash)
# 用于在 macOS/Linux 系统上安装 Git hooks

echo "正在安装 Git Hooks..."

# 检查是否在 Git 仓库中
if [ ! -d ".git" ]; then
    echo "错误：当前目录不是 Git 仓库根目录"
    exit 1
fi

# 创建 .git/hooks 目录（如果不存在）
mkdir -p .git/hooks

# 复制 hooks
hooks=("commit-msg" "prepare-commit-msg")

for hook in "${hooks[@]}"; do
    source=".github/hooks/$hook"
    dest=".git/hooks/$hook"
    
    if [ -f "$source" ]; then
        cp "$source" "$dest"
        chmod +x "$dest"
        echo "✓ 已安装: $hook"
    else
        echo "✗ 未找到: $hook"
    fi
done

# 配置提交模板
if [ -f ".gitmessage" ]; then
    git config commit.template .gitmessage
    echo "✓ 已配置提交模板"
else
    echo "✗ 未找到提交模板文件 .gitmessage"
fi

echo ""
echo "Git Hooks 安装完成！"
echo ""
echo "提示："
echo "  - 提交时会自动检查提交信息格式"
echo "  - 使用 'git commit --no-verify' 可以跳过检查"
echo "  - 查看规范：.github/COMMIT_CONVENTION.md"
