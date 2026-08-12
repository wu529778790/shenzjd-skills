# github-figure-bed

通用 GitHub 图床上传 skill：把本地图片上传到任意 GitHub 仓库，生成 CDN 链接（Markdown / 纯 URL），支持删除与列表管理。**登录即用、零手动配置**。

## 🚀 一键初始化（首次使用）

```bash
./scripts/setup.sh
```

自动完成：登录引导（未登录时打开浏览器授权，只需一次）→ 获取你的 GitHub 用户名 →
检测/创建图床仓库（默认 `img.shenzjd.com`，不存在自动创建并写入宣传 README）→
探测正确分支 → 写入配置文件 `~/.config/github-figure-bed/config.env` →
上传 1x1 测试图验证全链路。

之后上传**不需要任何参数**：

```bash
./scripts/upload.sh photo.png
```

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

优先级（高→低）：命令行参数 > 环境变量 `IMGX_*` > 配置文件 `~/.config/github-figure-bed/config.env`（setup.sh 生成）> 脚本内 `DEFAULT_*` 默认区。

| 环境变量 | 作用 | 默认 |
|----------|------|------|
| `IMGX_OWNER` | GitHub 用户名 | setup.sh 自动获取 |
| `IMGX_REPO` | 图床仓库名 | `img.shenzjd.com`（setup 自动创建） |
| `IMGX_BRANCH` | 分支 | 自动检测/探测 |
| `IMGX_CDN` | CDN | `jsdelivr` |
| `IMGX_DIR` | 基础目录 | `blog` |

绝大多数情况跑一次 `setup.sh` 就全部配置好了；也可在 shell profile 里
`export IMGX_OWNER=alice IMGX_REPO=my-figure-bed`，或直接改脚本顶部 `DEFAULT_*` 区。

## CDN 支持

`jsdelivr`（默认）/ `jsdmirror` / `jsd-onmicrosoft` / `statically` / `raw`。
大陆用户推荐 `jsdmirror`。详见 `references/cdn-links.md`。

## 要求

- `gh` CLI 已安装并登录（`gh auth login`），token 需 `repo` 权限
- 目标仓库存在且有写权限

## 安装为 WorkBuddy/Claude 技能

```bash
# 方式一: 从 shenzjd-skills 一键安装
npx skills add wu529778790/shenzjd-skills -s github-figure-bed -y

# 方式二: 直接复制本目录到技能目录
cp -r github-figure-bed ~/.workbuddy/skills/
```

安装后，直接说「上传 xxx.png 到图床」「图床里有哪些图」即可触发。
