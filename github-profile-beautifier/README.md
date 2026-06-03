# 🎨 GitHub Profile Beautifier

一键生成漂亮的 GitHub 个人主页 README。自动检测仓库、分析技术栈、智能推荐项目和主题。

## 功能特性

- ✅ 智能仓库检测 - 自动获取用户所有公开仓库
- ✅ 技术栈分析 - 从语言分布自动识别
- ✅ 项目智能推荐 - 根据 star、更新时间、描述质量筛选 Top 5
- ✅ 5 种主题 - Radical / Tokyo Night / Dracula / Minimalist / Professional
- ✅ 3 种排序 - 按 star / 智能 / 更新时间

## 🚀 安装

### 方式一：npx skills（推荐）

```bash
# 安装到 Claude Code
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y -a claude-code

# 安装到 Cursor
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y -a cursor

# 安装到所有已检测的 AI 工具
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y
```

安装后，skill 会出现在你的 AI 工具的 skills 目录中。

### 方式二：手动安装

**Claude Code：**
```bash
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/github-profile-beautifier ~/.claude/skills/
# 重启 Claude Code 生效
```

**Cursor：**
将 `SKILL.md` 的内容复制到项目根目录的 `.cursorrules` 文件，或 `.cursor/rules/` 目录。

**GitHub Copilot：**
将 `SKILL.md` 的内容复制到 `.github/copilot-instructions.md`。

**其他工具：**
`SKILL.md` 是通用指令文档，粘贴到你所用工具的 system prompt 或规则文件即可。

## 📖 使用方式

```bash
# 交互式生成（会询问用户名、排序方式、主题）
/github-profile-beautifier

# 指定用户名
/github-profile-beautifier wu529778790

# 完整参数
/github-profile-beautifier username --sort stars --theme tokyonight
```

### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `username` | GitHub 用户名 | 交互式询问 |
| `--sort` | 排序方式 | `smart` |
| `--theme` | 主题风格 | `radical` |

### 排序方式

| 值 | 说明 |
|----|------|
| `stars` | 按 star 数排序，展示最受欢迎的项目 |
| `smart` | 智能排序，综合 star、更新时间、描述质量 |
| `updated` | 按更新时间排序，展示最近活跃的项目 |

### 主题

| 主题 | 风格 | 适合场景 |
|------|------|----------|
| `radical` | 活泼、鲜艳 | 个人项目、创意开发（默认） |
| `tokyonight` | 现代、深色 | 技术展示 |
| `dracula` | 暗黑、紫色 | 深色主题、护眼 |
| `minimalist` | 简洁、专业 | 企业用户、正式场合 |
| `professional` | 商务、蓝色 | 求职者、企业展示 |

## 📁 模板文件

| 文件 | 说明 |
|------|------|
| `templates/radical.md` | Radical 主题模板 |
| `templates/tokyonight.md` | Tokyo Night 主题模板 |
| `templates/dracula.md` | Dracula 主题模板 |
| `templates/minimalist.md` | Minimalist 主题模板 |
| `templates/professional.md` | Professional 主题模板 |
| `templates/themes.json` | 主题颜色、badge 样式配置 |
| `templates/README.md` | 模板变量和自定义说明 |

## 🔧 前置条件

- **`gh` CLI** — 需要已安装并登录（`gh auth login`）
- **Snake 贡献图**（可选）— 深色主题包含蛇形贡献图，需先 fork [platane/snk](https://github.com/platane/snk) 并配置 GitHub Actions

## ⚙️ Claude Code 配置

如果使用 Claude Code，以下权限已在 `.claude/settings.local.json` 中预授权：
- `gh auth *` / `gh repo *` — GitHub API 访问
- `WebSearch` — 网络搜索
