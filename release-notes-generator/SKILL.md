---
name: release-notes-generator
description: Use when creating git tags, releases, or version bumps, or when user wants to generate changelogs, release notes, or version documentation from git history with conventional commits
---

# Release Notes Generator

打 tag 时自动对比代码变更，生成标准化的 Release Notes。

## Overview

对比上一个 tag 到当前 HEAD 的 git 历史，按 conventional commit 分类（feat/fix/docs/refactor/chore），自动检测 breaking changes，生成标准化的 Release Notes。可选创建 git tag 和 GitHub Release。

## When to Use

- User wants to create a tag or release
- User wants to summarize version changes
- User mentions changelog, release notes, or version documentation
- User inputs `/release-notes`

**When NOT to Use:**
- User only wants to view git log
- User wants to modify existing release notes

## Core Pattern

### Step 1: 检测版本号

获取最新 tag（`git describe --tags --abbrev=0`），用户指定版本号或根据变更类型建议：有 breaking changes → major，有新功能 → minor，只有 bugfix → patch。

### Step 2: 对比变更

```bash
PREV_TAG=$(git describe --tags --abbrev=0)
git log ${PREV_TAG}..HEAD --oneline
git diff ${PREV_TAG}..HEAD --stat
```

### Step 3: 分类变更

| 类别 | 前缀 | 说明 |
|------|------|------|
| 🚀 Features | `feat:` | 新功能 |
| 🐛 Bug Fixes | `fix:` | 修复 |
| 📝 Documentation | `docs:` | 文档 |
| ♻️ Refactor | `refactor:` | 重构 |
| 🔧 Chores | `chore:` | 构建/工具/配置 |
| 💥 Breaking Changes | `BREAKING CHANGE` | 破坏性变更 |

读取 commit 消息中的 conventional commit 前缀，没有前缀的根据文件变更推断。

### Step 4: 生成 Notes

使用 `templates/release-notes.md` 模板生成，包含版本号、日期、分类变更列表、diff 链接。

### Step 5: 创建 Tag/Release（可选）

询问用户是否创建 annotated tag 和 GitHub Release（`gh release create`）。

## Quick Reference

```bash
/release-notes              # 交互式，自动建议版本号
/release-notes v1.1.0       # 指定版本号
/release-notes --dry-run    # 只生成不创建 tag
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `version` | 版本号 | 自动建议 |
| `--dry-run` | 只生成不创建 | false |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 只看 commit 数量 | 分析实际代码变更 | commit 数量不代表变更规模 |
| 忽略 breaking changes | 重点标注 💥 | 用户需要知道不兼容变更 |
| 不分类，全部列在一起 | 按 feat/fix/docs 分组 | 可读性差 |
| notes 太长 | 精简为关键变更 + diff 链接 | 用户不需要看每个细节 |
