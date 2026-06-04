---
name: git-hooks-setup
description: Use when user wants to set up git hooks, configure pre-commit checks, enforce commit message conventions, automate linting and formatting on commit, or standardize team development workflow with husky or lefthook
---

# Git Hooks Setup

一键配置 Git Hooks，标准化团队开发流程。

## Overview

自动生成 pre-commit / commit-msg / push hook 配置，包含代码格式化、commit message 校验、敏感信息检查。支持 husky、lefthook、原生 git hooks 三种方案。

## When to Use

- 用户想配置 git hooks
- 用户提到 pre-commit、commit message 规范
- 用户想自动化 lint/format 检查
- 用户输入 `/git-hooks-setup`

**When NOT to Use:**
- 用户只是想看当前的 git hooks 配置
- 用户想用 CI 做检查（不需要本地 hooks）
- 用户的项目已有完整的 hooks 配置

## Core Pattern

### Step 1: 检测项目环境

```bash
# 检测包管理器
ls package-lock.json && echo "npm"
ls yarn.lock && echo "yarn"
ls pnpm-lock.yaml && echo "pnpm"

# 检测是否已有 hooks
ls .husky/ 2>/dev/null && echo "husky 已配置"
cat .git/hooks/pre-commit 2>/dev/null && echo "原生 hooks 已配置"

# 检测 lint 工具
cat package.json | python3 -c "import sys,json; d=json.load(sys.stdin); print([k for k in d.get('devDependencies',{}) if 'eslint' in k or 'prettier' in k or 'lint' in k])"
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
npx husky init
```

生成 `.husky/pre-commit`：
```bash
npx lint-staged
```

生成 `.husky/commit-msg`：
```bash
npx --no -- commitlint --edit ${1}
```

生成 `.huskyrc` 或 `lint-staged` 配置：
```json
{
  "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md,yml}": ["prettier --write"]
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
