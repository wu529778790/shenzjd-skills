---
name: git-hooks-setup
description: Use when setting up git hooks (pre-commit, commit-msg, pre-push) with husky or native hooks for linting, formatting, commit conventions, and secret scanning.
---

# Git Hooks Setup

一键配置 Git Hooks，标准化团队开发流程。

## Overview

自动生成 pre-commit / commit-msg / pre-push hook 配置，包含代码格式化、commit message 校验、敏感信息检查。支持 husky 和原生 git hooks 两种方案。

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
# 检测包管理器（按 lock 文件判断）
if [ -f "package-lock.json" ]; then PACKAGE_MANAGER="npm"
elif [ -f "yarn.lock" ]; then PACKAGE_MANAGER="yarn"
elif [ -f "pnpm-lock.yaml" ]; then PACKAGE_MANAGER="pnpm"

# 检测已有 hooks 配置
test -d ".husky" && echo "husky 已配置"
test -f ".git/hooks/pre-commit" && echo "原生 hooks 已配置"

# 从 package.json 检测已安装的 lint 工具（eslint/prettier/lint 相关）
```

### Step 2: 选择方案

| 方案 | 适用场景 | 优点 |
|------|---------|------|
| husky | Node.js 项目 | 团队协作友好，配置即代码 |
| 原生 git hooks | 非 Node.js 项目 | 无依赖 |

### Step 3: 生成配置

**方案 A: Husky**

```bash
# 根据 $PACKAGE_MANAGER 选择: pnpm dlx / yarn dlx / npx
husky init    # 初始化 husky
```

生成 `.husky/pre-commit`（执行 `lint-staged`）和 `.husky/commit-msg`（执行 `commitlint`），注意 commitlint 需加 `--no` 前缀避免交互式安装。

生成 `lint-staged` 配置（写入 `package.json`）：
```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml}": ["prettier --write"]
  }
}
```

生成 `.husky/pre-push`（可选，push 前跑测试）：
```bash
# 根据包管理器选择命令
if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  pnpm test
elif [ "$PACKAGE_MANAGER" = "yarn" ]; then
  yarn test
else
  npm test
fi
```

**方案 B: 原生 git hooks**

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# 自动 lint + format（按项目实际替换命令；示例为 Node 项目）
if [ -f "package.json" ] && [ -x "$(command -v npm)" ]; then
  npm run lint -- --fix 2>/dev/null || true
  npm run format 2>/dev/null || true
fi
# 注意：不要执行 git add -u —— 那会把用户未暂存的改动也一并提交。
# 若需把 lint 修复的结果纳入提交，请使用 lint-staged（只处理暂存文件）。
EOF
chmod +x .git/hooks/pre-commit

# pre-push hook（可选，push 前跑测试；按项目实际替换）
cat > .git/hooks/pre-push << 'EOF'
#!/bin/sh
if [ -f "package.json" ] && [ -x "$(command -v npm)" ]; then
  npm test || exit 1
fi
EOF
chmod +x .git/hooks/pre-push
```

### Step 4: 配置 Commit Message 规范

将 `templates/commitlint.config.js` 复制到项目根目录（`commitlint.config.js`）。该配置基于 `@commitlint/config-conventional`，校验 commit message 格式：

```
type(scope): subject

# type: feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert
# scope: 可选，影响范围
# subject: 简短描述（header-max-length 限制 100 字符）
```

同步安装 commitlint 依赖：

```bash
npm install -D @commitlint/cli @commitlint/config-conventional
```

### Step 5: 添加敏感信息检查

> ⚠️ 不要用 `grep "password|secret|token"` 这种关键字扫描 —— 业务代码里出现 "token"/"secret" 字样是常态，会大面积误报导致提交被频繁拦截。

推荐使用 **gitleaks**（专门做密钥扫描，内置熵检测 + 允许列表，误报率低）：

```bash
# 生成 gitleaks pre-commit hook
npx gitleaks git-config 2>/dev/null || brew install gitleaks && gitleaks git-config
# 或手动在 .git/hooks/pre-commit 中加入：
# gitleaks protect --staged --verbose 2>&1
# 若 gitleaks 不可用，宁可跳过也不要退化成关键字 grep
```

如果确实无法安装 gitleaks，退而求其次也要避免整词误报 —— 只匹配**高置信度模式**（如私钥块、AWS 密钥格式），不要匹配 `token`/`secret`/`password` 这类业务常用词：

```bash
# 低误报替代方案：只扫私钥和云厂商密钥格式（示例）
if git diff --cached --diff-filter=ACM --name-only -z | xargs -0 grep -IlE "BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}" 2>/dev/null | grep -q .; then
  echo "警告: 检测到可能的密钥泄露，请检查后重新提交"
  exit 1
fi
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
| 跳过 prepare 脚本 | 确保 package.json 的 `prepare` 运行 `husky`（v9+） | CI 环境 hook 不生效 |
| commitlint 规则与团队不一致 | 使用 `commitlint.config.js` 统一配置 | 口头约定容易被违反 |
| 不配置 --no-verify 白名单 | 允许 `--no-verify` 但记录日志 | 紧急修复时不能被完全阻断 |
