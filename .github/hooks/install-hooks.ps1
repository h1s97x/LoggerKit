# Git Hooks 安装脚本 (PowerShell)
# 用于在 Windows 系统上安装 Git hooks

Write-Host "正在安装 Git Hooks..." -ForegroundColor Green

# 检查是否在 Git 仓库中
if (-not (Test-Path ".git")) {
    Write-Host "错误：当前目录不是 Git 仓库根目录" -ForegroundColor Red
    exit 1
}

# 创建 .git/hooks 目录（如果不存在）
if (-not (Test-Path ".git/hooks")) {
    New-Item -ItemType Directory -Path ".git/hooks" | Out-Null
}

# 复制 hooks
$hooks = @("commit-msg", "prepare-commit-msg")

foreach ($hook in $hooks) {
    $source = ".github/hooks/$hook"
    $dest = ".git/hooks/$hook"
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "✓ 已安装: $hook" -ForegroundColor Green
    } else {
        Write-Host "✗ 未找到: $hook" -ForegroundColor Yellow
    }
}

# 配置提交模板
if (Test-Path ".gitmessage") {
    git config commit.template .gitmessage
    Write-Host "✓ 已配置提交模板" -ForegroundColor Green
} else {
    Write-Host "✗ 未找到提交模板文件 .gitmessage" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Git Hooks 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "提示：" -ForegroundColor Cyan
Write-Host "  - 提交时会自动检查提交信息格式"
Write-Host "  - 使用 'git commit --no-verify' 可以跳过检查"
Write-Host "  - 查看规范：.github/COMMIT_CONVENTION.md"
