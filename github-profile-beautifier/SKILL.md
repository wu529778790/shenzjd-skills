---
name: github-profile-beautifier
description: Use when user wants to create or improve their GitHub profile README, generate a new profile page, beautify their existing GitHub homepage, or add stats cards, project showcase, and tech stack badges
---

# GitHub Profile Beautifier

一键生成漂亮的 GitHub 个人主页 README。自动检测仓库、分析技术栈、智能推荐项目和主题。

## Overview

根据用户的 GitHub 数据（仓库、语言、star），自动生成带统计卡片、项目展示、技术栈徽章的个人主页 README。依赖 `gh` CLI 获取数据，输出完整的 `README.md` 文件。提供 5 种主题和 3 种排序方式。

## When to Use

- User wants to create a GitHub profile page (with or without existing README)
- User wants to generate a new GitHub profile README
- User wants to beautify an existing README
- User wants to showcase projects and tech stack
- User inputs `/github-profile-beautifier [username]`

**When NOT to Use:**
- User only wants to make small edits to an existing README
- User already has a perfect README and just wants minor tweaks
- User wants to create a personal page on a non-GitHub platform (e.g., personal website, blog)

## Core Pattern

### Step 0: 解析参数

从用户输入中提取 `username`、`--sort`（默认 smart）、`--theme`（默认 radical）。缺少参数时交互式询问。

### Step 1: 获取用户信息

```bash
# 检查 gh CLI
command -v gh || { echo "请先安装 gh CLI: brew install gh"; exit 1; }

# 验证用户存在
gh api users/$USERNAME > /dev/null 2>&1 || { echo "用户不存在"; exit 1; }

# 获取用户信息和仓库
gh api users/$USERNAME --jq '.login,.name,.bio'
gh repo list $USERNAME --limit 50 --json name,description,primaryLanguage,url,updatedAt,stargazerCount,isFork
```

### Step 2: 分析仓库

- 筛选非 fork 仓库（全部是 fork 则用所有仓库）
- 排序方式：`stars`（按 star）、`updated`（按更新时间）、`smart`（综合 star + 更新时间 + 描述质量）
- 统计语言分布

### Step 3: 准备模板数据

所有模板共享：`username`, `name`, `bio`, `typing_lines`, `website`, `blog`, `email`, `linkedin`

项目变量：`projects`（name, description, url, stars, tech）

技术栈变量区分：
- radical / tokyonight / dracula / minimalist → `languages` + `tools`
- professional → `frontend` + `backend` + `tools`（需按语言分类前后端）

语言/工具颜色从 `templates/themes.json` 获取。联系方式字段可选，模板用 `{{#if}}` 处理空值。

### Step 4: 生成 README

读取对应主题模板，填充变量，输出完整 README.md。

**Snake 贡献图：** 深色主题包含蛇形贡献图，需用户先 fork [platane/snk](https://github.com/platane/snk) 并配置 GitHub Actions，否则显示 404。

## Quick Reference

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `username` | GitHub 用户名 | 交互式询问 |
| `--sort` | stars / smart / updated | smart |
| `--theme` | radical / tokyonight / dracula / minimalist / professional | radical |

```bash
/github-profile-beautifier username
/github-profile-beautifier username --sort stars --theme tokyonight
```

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 使用外部 API 获取统计数据 | 使用 `gh` 命令本地获取 | API 可能不稳定 |
| 硬编码主题颜色 | 从 themes.json 读取 | 方便用户自定义 |
| 展示所有仓库 | 智能推荐 Top 5 | 避免信息过载 |
| 不检查 gh CLI 是否安装 | 先检查再执行 | 避免运行时错误 |
| 不处理用户不存在的情况 | 先验证用户存在性 | 避免无效操作 |
