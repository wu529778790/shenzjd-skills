# 🎨 GitHub Profile Beautifier

一键生成漂亮的 GitHub 个人主页 README。自动检测仓库、分析技术栈、智能推荐项目和主题。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/github-profile-beautifier ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/github-profile-beautifier username
/github-profile-beautifier username --sort stars --theme tokyonight
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `username` | GitHub 用户名 | 交互式询问 |
| `--sort` | `stars` / `smart` / `updated` | `smart` |
| `--theme` | `radical` / `tokyonight` / `dracula` / `minimalist` / `professional` | `radical` |

## 主题

| 主题 | 风格 | 适合场景 |
|------|------|----------|
| radical | 活泼、鲜艳 | 个人项目、创意开发（默认） |
| tokyonight | 现代、深色 | 技术展示 |
| dracula | 暗黑、紫色 | 深色主题、护眼 |
| minimalist | 简洁、专业 | 企业用户、正式场合 |
| professional | 商务、蓝色 | 求职者、企业展示 |

## 前置条件

- **`gh` CLI** — 需要已安装并登录（`gh auth login`）
- **Snake 贡献图**（可选）— 深色主题包含蛇形贡献图，需先 fork [platane/snk](https://github.com/platane/snk) 并配置 GitHub Actions
