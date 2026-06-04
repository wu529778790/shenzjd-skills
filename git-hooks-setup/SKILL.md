---
name: git-hooks-setup
description: Configure git hooks (pre-commit, commit-msg, pre-push) with husky or lefthook for linting, formatting, commit conventions, and pre-push validation.
---

# Git Hooks Setup

一键配置 Git Hooks，标准化团队开发流程。

## Overview

自动生成 pre-commit / commit-msg / push hook 配置，包含代码格式化、commit message 校验、敏感信息检查。支持 husky、lefthook、原生 git hooks 三种方案。

## When to Use

- User wants to set up git hooks
- User mentions pre-commit or commit message conventions
- User wants to automate lint/format checks
- User inputs `/git-hooks-setup`
- User wants to enforce pre-push checks (tests, lint)
- User wants to prevent pushing broken code
- User wants to standardize team commit message format
- User wants to add secret scanning before commit
- User wants to auto-format code on every commit

**When NOT to Use:**
- User only wants to view current git hooks configuration
- User wants CI-based checks (no local hooks needed)
- User's project already has a complete hooks setup
- User wants to run hooks on specific files only (use lint-staged directly)
- User wants to hook into Git events other than pre-commit/commit-msg/push

## Core Pattern

### Step 1: 检测项目环境

```bash
# 检测包管理器
if [ -f "package-lock.json" ]; then
  echo "npm"
  PACKAGE_MANAGER="npm"
elif [ -f "yarn.lock" ]; then
  echo "yarn"
  PACKAGE_MANAGER="yarn"
elif [ -f "pnpm-lock.yaml" ]; then
  echo "pnpm"
  PACKAGE_MANAGER="pnpm"
else
  echo "未检测到包管理器"
  PACKAGE_MANAGER="unknown"
fi

# 检测是否已有 hooks
if [ -d ".husky" ]; then
  echo "husky 已配置"
elif [ -f ".git/hooks/pre-commit" ]; then
  echo "原生 hooks 已配置"
fi

# 检测 lint 工具
if [ -f "package.json" ]; then
  echo "已安装的 lint 工具:"
  cat package.json | python3 -c "
import sys,json
d=json.load(sys.stdin)
dev_deps=d.get('devDependencies',{})
lint_tools=[k for k in dev_deps if 'eslint' in k or 'prettier' in k or 'lint' in k]
if lint_tools:
    for tool in lint_tools:
        print(f'  - {tool}')
else:
    print('  未检测到 lint 工具')
"
fi
```

### Step 2: 选择方案

| 方案 | 适用场景 | 优点 |
|------|---------|------|
| husky | Node.js 项目 | 团队协作友好，配置即代码 |
| lefthook | 任何项目 | 更快，Go 编写 |
| 原生 git hooks | 非 Node.js 项目 | 无依赖 |

### Step 3: 生成配置

**方案 A: Husky**

```bash
# 根据包管理器选择命令
if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  pnpm dlx husky init
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
  yarn dlx husky init
else
  npx husky init
fi
```

生成 `.husky/pre-commit`：
```bash
# 根据包管理器选择命令
if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  pnpm dlx lint-staged
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
  yarn dlx lint-staged
else
  npx lint-staged
fi
```

生成 `.husky/commit-msg`：
```bash
# 根据包管理器选择命令
if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  pnpm dlx --no -- commitlint --edit ${1}
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
  yarn dlx --no -- commitlint --edit ${1}
else
  npx --no -- commitlint --edit ${1}
fi
```

生成 `lint-staged` 配置（在 `package.json` 中）：
```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml}": ["prettier --write"]
  }
}
```

**方案 B: 原生 git hooks**

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# 自动 lint + format
npm run lint -- --fix
npm run format
git add -u
EOF
chmod +x .git/hooks/pre-commit
```

### Step 4: 配置 Commit Message 规范

使用 `templates/commitlint.config.js`：

```
type(scope): subject

# type: feat|fix|docs|style|refactor|test|chore|perf|ci|build
# scope: 可选，影响范围
# subject: 简短描述，不超过 50 字符
```

### Step 5: 添加敏感信息检查

生成 pre-commit hook 中加入：
```bash
# 检查是否有密钥泄露
git diff --cached --name-only | xargs grep -l "password\|secret\|token\|api_key" 2>/dev/null && {
  echo "⚠️ 检测到可能的敏感信息，请检查后重新提交"
  exit 1
}
```

## Quick Reference

```bash
/git-hooks-setup                    # 交互式选择方案和 hooks
/git-hooks-setup --husky            # 直接用 husky
/git-hooks-setup --native           # 直接用原生 git hooks
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--husky` | 使用 husky | 自动检测 |
| `--native` | 使用原生 git hooks | false |
| `--commitlint` | 添加 commit message 校验 | true |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| hook 脚本没有执行权限 | `chmod +x .git/hooks/*` | hook 不会运行 |
| lint-staged 配置太多规则 | 只检查暂存文件 | 减少提交等待时间 |
| commit message 校验太严格 | 先宽松后收紧 | 避免团队抵触 |
| 不检查敏感信息 | 加入密钥扫描 | 防止泄露 |
| .git/hooks 不提交 | 用 husky/lefthook 管理 | 团队需要共享配置 |
| pre-push hook 跑太久 | 只跑快速检查，完整测试放 CI | push 被阻塞影响效率 |
| hook 中使用相对路径 | 使用绝对路径或项目根目录 | 不同目录执行时路径解析失败 |
| 跳过 husky install | 在 CI 中运行 `husky install` | CI 环境 hook 不生效 |
| commitlint 规则与团队不一致 | 使用 `commitlint.config.js` 统一配置 | 口头约定容易被违反 |
| 不配置 --no-verify 白名单 | 允许 `--no-verify` 但记录日志 | 紧急修复时不能被完全阻断 |
