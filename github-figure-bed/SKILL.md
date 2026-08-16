---
name: github-figure-bed
description: "Upload images to any GitHub repo as a figure bed and get CDN/markdown links (jsdelivr/jsdmirror/raw). One-time setup.sh guides gh login, auto-detects the owner, creates the default repo (img.shenzjd.com) if missing, and syncs config with the img.shenzjd.com web app via the repo's .imgx-config/config.json — upload with zero manual configuration. Use for uploading images to GitHub, generating CDN links, deleting/listing hosted images, or setting up a figure bed. Keywords: github figure bed, image host, CDN link, jsdelivr, jsdmirror, upload image to GitHub, 图床, 上传图片, CDN 链接, 初始化图床."
---

# GitHub Figure Bed

把本地图片上传到任意 GitHub 仓库（图床），生成可直接粘贴的 CDN 链接
（Markdown / 纯 URL），并支持删除、列表管理。不依赖前端，任何环境（含整理素材时）都能用。

## Overview

图床 = 任意 GitHub 仓库 + 一个图片目录（默认 `blog/`）。本 skill 通过
`gh api` 调用 GitHub Contents API（与网页版图床同一接口），把图片上传到目标仓库，
并返回 CDN 加速链接。支持多 CDN、多文件、子目录、重名保护。

**零配置体验**：首次使用运行 `scripts/setup.sh` 一键初始化 —— 自动引导登录、
检测/创建仓库、**读取仓库配置并与 img.shenzjd.com 项目网页端联动**、探测分支、
生成本地缓存。之后用户只需对 AI 说「上传 xxx.png 到图床」，无需手动配置任何东西。

## When to Use

- User wants to upload local images to a GitHub-hosted figure bed and get CDN links
- User wants a markdown image link like `![name](https://cdn.jsdelivr.net/gh/...@main/...)` for blog/docs
- User wants to delete an image from the figure bed repo
- User wants to list/search images already in the figure bed repo
- User mentions 图床 / 上传图片 / CDN 链接 / jsdelivr / jsdmirror / 图片托管
- User asks to organize assets and host them (AI cannot use the web UI, this skill covers that gap)

**When NOT to Use:**
- User has a figure bed web app with its own upload flow and can use it directly
- Target repo is not a GitHub repo (e.g. local-only or other platforms)
- `gh` CLI is not installed or not authenticated (install and `gh auth login` first)

## Core Pattern

### Step 0: 首次使用 — 一键初始化 (setup.sh)

新用户首次使用（或不确定配置是否就绪时），先运行：

```bash
scripts/setup.sh
```

它会自动完成，**全程不需要用户手动配置**：

1. **登录引导**：检测到未登录时运行 `gh auth login`，把输出的授权链接和
   one-time code 展示给用户，引导在浏览器完成授权（只需一次）
2. **自动获取 Owner**：取当前登录的 GitHub 用户名，无需手填
3. **仓库就绪**：检测默认仓库 `img.shenzjd.com`；不存在则自动创建（public），
   并写入宣传/使用说明 README
4. **配置联动（核心）**：读取仓库的 `.imgx-config/config.json`（与 img.shenzjd.com
   项目网页端**共用同一份配置**），自动继承 branch/directory/cdn；
   仓库没有配置时，初始化一份项目格式配置写回仓库（网页端即可直接使用）
5. **分支探测**：自动找出图片目录实际所在分支（规避 default_branch 与图片分支不一致的坑）
6. **配置落盘**：写入本地缓存 `~/.config/github-figure-bed/config.env`，
   三个操作脚本自动读取，之后**零参数直接使用**
7. **自测**：上传一张 1x1 测试图并删除，验证全链路

可选参数：`--repo <仓库名>` 换仓库名；`--cdn <cdn>` 换默认 CDN；
`--no-test` 跳过自测；`--force-readme` 强制重写宣传 README。

### Step 1: 确定目标仓库与配置

优先级（高→低）：**命令行参数 > 环境变量 `IMGX_*` > 本地缓存 `~/.config/github-figure-bed/config.env`（setup.sh 从远程同步） > 脚本内 `DEFAULT_*` 默认区**。

**配置联动**：远程配置源为仓库 `.imgx-config/config.json`（与 img.shenzjd.com
项目网页端共用），setup.sh 自动读取并同步到本地缓存；项目网页端修改配置后，
重跑 `setup.sh` 即可刷新本地。

- 仓库：setup.sh 已自动配置（默认 `img.shenzjd.com`）；上传到其他仓库时再传 `--owner/--repo`
- 分支：不指定时自动检测仓库 `default_branch`（一般就是 `main`，零配置）
- CDN：默认 `jsdelivr`；大陆用户推荐 `jsdmirror`；本地调试可用 `raw`
- 基础目录：默认 `blog/`，可用 `--dir` 或环境变量 `IMGX_DIR` 改

若用户没给仓库且未运行过 setup，先跑 `scripts/setup.sh`（或让用户设置
`IMGX_OWNER` / `IMGX_REPO`）。

### Step 2: 上传图片

```bash
scripts/upload.sh <文件1> [文件2 ...] \
  [--owner O] [--repo R] [--branch B] [--cdn jsdelivr|jsdmirror|jsd-onmicrosoft|statically|raw] \
  [--dir 子目录] [--force] [--silent]
```

- 支持多文件一次上传；`--dir` 追加子目录（如 `--dir 2026/08` → `blog/2026/08/`）
- **重名保护（默认）**：目标文件已存在时自动改为 `<时间戳>_<原文件名>`，
  不覆盖已有文件 —— 图床场景覆盖会破坏线上已发布的引用；`--force` 才覆盖
- 输出 JSON 数组，每项含 `{file, path, cdn_url, markdown, html_url, action}`：
  - `cdn_url`：CDN 链接（含正确分支）
  - `markdown`：可直接粘贴的 `![文件名](链接)`
  - `action`：`created` / `renamed`（自动换名）/ `replaced`

**上传后向用户展示**：Markdown 格式 + 纯 URL，例如：

```markdown
![photo.png](https://cdn.jsdelivr.net/gh/alice/my-figure-bed@main/blog/photo.png)
```
纯 URL：`https://cdn.jsdelivr.net/gh/alice/my-figure-bed@main/blog/photo.png`

### Step 3: 删除图片

```bash
scripts/delete.sh <文件名1> [文件名2 ...] [--owner O] [--repo R] [--branch B] [--dir 子目录] [--silent]
```

- 文件名指基础目录下的文件名（不含 `blog/` 前缀）
- 不确定是否存在时，先 `scripts/list.sh <关键词>` 确认

### Step 4: 列出图片

```bash
scripts/list.sh [关键词] [--owner O] [--repo R] [--branch B] [--dir 子目录] [--limit N] [--full]
```

- 无参数列出文件（默认 50 条）；传关键词做文件名模糊过滤（如 `list.sh 响应性`）
- `--full` 输出完整 JSON（含 size）；默认只输出文件名列表

## Quick Reference

| 操作 | 命令 | 说明 |
|------|------|------|
| 首次初始化 | `setup.sh` | 登录引导 + 自动配置 + 仓库就绪（零手动配置） |
| 上传 | `upload.sh img.png` | 返回 CDN + Markdown 链接（setup 后无需参数） |
| 上传(多) | `upload.sh a.png b.png c.png --dir 2026/08` | 批量 + 子目录 |
| 删除 | `delete.sh a.png` | 按文件名删除 |
| 列表 | `list.sh` / `list.sh 关键词 --full` | 列出/搜索图床文件 |
| 覆盖 | `upload.sh img.png --force` | 已存在时覆盖更新 |
| 环境变量 | `IMGX_OWNER IMGX_REPO IMGX_BRANCH IMGX_CDN IMGX_DIR` | 免重复传参 |

## Common Mistakes

- **分支错误导致 404**：jsDelivr 系默认找 `main`。脚本会自动检测默认分支，但若图片实际在
  非默认分支（如 `master`），必须 `--branch master` 显式指定。
- **给 jsdmirror/jsdelivr 链接加 `?format=webp`**：这两个 CDN 无动态转换，加参数必 404。
- **覆盖已有文件**：默认重名会自动换名保护；确认要更新同一链接内容才用 `--force`。
- **忘记指定仓库**：`owner/repo` 由 setup.sh 自动写入配置文件，无需手填；
  未 setup 时需传参或设 `IMGX_OWNER`/`IMGX_REPO`，脚本无法凭空推断目标仓库。
- **从未运行 setup 就上传**：会因 owner/repo 为空而报错，先跑 `setup.sh`。
- **网页端改配置后本地未同步**：远程配置（`.imgx-config/config.json`）变化后，
  重跑 `setup.sh` 刷新本地缓存。
- **大图失败**：脚本已用临时文件拼 JSON payload 规避命令行长度限制，若仍失败检查
  GitHub 仓库 100MB 单文件限制与网络。
- **上传后立即访问 404**：CDN 有缓存，通常数秒~数分钟生效，稍后重试。
- **文件名带空格/特殊字符**：会破坏链接，上传前重命名（中文可用）。

## References

- `references/cdn-links.md`：CDN 链接格式、全部踩坑清单、仓库 API 参考
- 脚本内部：`scripts/setup.sh`（一键初始化）/ `scripts/upload.sh` / `scripts/delete.sh` / `scripts/list.sh`
