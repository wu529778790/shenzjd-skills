---
name: release-notes-generator
description: Generate release notes and changelogs from git history using conventional commits. Auto-detects breaking changes and creates annotated tags.
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
- User wants to generate a CHANGELOG.md from commit history
- User wants to prepare a release with categorized changes
- User wants to auto-detect breaking changes before release
- User wants to create an annotated git tag with release notes

**When NOT to Use:**
- User only wants to view git log
- User wants to modify existing release notes
- User wants to generate changelogs for multiple repositories (different tooling)
- User wants to automate release notes in CI/CD (consider semantic-release or release-please)

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
| ⚡ Performance | `perf:` | 性能优化 |
| 🧪 Tests | `test:` | 测试 |
| 🔒 Security | `security:` | 安全修复 |
| 💥 Breaking Changes | `BREAKING CHANGE` 或 `!` 后缀 | 破坏性变更 |

**Breaking Changes 检测规则：**
1. commit 消息包含 `BREAKING CHANGE:` 或 `BREAKING CHANGES:`
2. commit 类型后带 `!`（如 `feat!:`、`fix!:`）
3. commit body 中包含破坏性变更说明

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
| 没有前缀的 commit 直接忽略 | 根据文件变更推断类型 | 不是所有团队都严格使用 conventional commits |
| 版本号跳过 semver 规则 | 遵循 major.minor.patch 语义 | 随意编号导致依赖管理混乱 |
| 不检查 breaking changes 的 API 影响 | 标注受影响的接口和迁移方式 | 用户升级后才发现破坏性变更 |
| Release Notes 不包含 diff 链接 | 添加 `${PREV_TAG}...${TAG}` 对比链接 | 方便用户查看具体代码变更 |
