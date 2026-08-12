# imgx-figure-bed

通用 GitHub 图床上传 skill：把本地图片上传到任意 GitHub 仓库，生成 CDN 链接（Markdown / 纯 URL），支持删除与列表管理。

## 快速开始

```bash
# 上传单张图（jsdelivr, 自动检测仓库默认分支）
./scripts/upload.sh photo.png --owner alice --repo my-figure-bed

# 上传多张 + 指定子目录 + 国内 CDN
./scripts/upload.sh a.png b.png --owner alice --repo my-figure-bed --cdn jsdmirror --dir 2026/08

# 删除
./scripts/delete.sh photo.png --owner alice --repo my-figure-bed

# 列表 / 搜索
./scripts/list.sh --owner alice --repo my-figure-bed
./scripts/list.sh 关键词 --owner alice --repo my-figure-bed --full
```

## 配置

优先级（高→低）：命令行参数 > 环境变量 `IMGX_*` > 脚本内 `DEFAULT_*` 默认区。

| 环境变量 | 作用 | 默认 |
|----------|------|------|
| `IMGX_OWNER` | GitHub 用户名 | 无（必填） |
| `IMGX_REPO` | 图床仓库名 | 无（必填） |
| `IMGX_BRANCH` | 分支 | 自动检测 `default_branch` |
| `IMGX_CDN` | CDN | `jsdelivr` |
| `IMGX_DIR` | 基础目录 | `blog` |

常用做法：在 shell profile 里 `export IMGX_OWNER=alice IMGX_REPO=my-figure-bed`，
日常使用即可免传 `--owner/--repo`。个人固定配置也可直接改脚本顶部 `DEFAULT_*` 区。

## CDN 支持

`jsdelivr`（默认）/ `jsdmirror` / `jsd-onmicrosoft` / `statically` / `raw`。
大陆用户推荐 `jsdmirror`。详见 `references/cdn-links.md`。

## 要求

- `gh` CLI 已安装并登录（`gh auth login`），token 需 `repo` 权限
- 目标仓库存在且有写权限

## 安装为 WorkBuddy/Claude 技能

```bash
# 方式一: 从 shenzjd-skills 一键安装
npx skills add wu529778790/shenzjd-skills -s imgx-figure-bed -y

# 方式二: 直接复制本目录到技能目录
cp -r imgx-figure-bed ~/.workbuddy/skills/
```

安装后，直接说「上传 xxx.png 到图床」「图床里有哪些图」即可触发。
