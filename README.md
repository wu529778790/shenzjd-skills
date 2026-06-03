# 🛠️ AI Coding Skills

> 一套通用的 AI 编程助手 Skills，适配 Claude Code、Cursor、Copilot、Windsurf 等主流 AI 编程工具。

[![GitHub stars](https://img.shields.io/github/stars/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/network/members)

## 📋 Skills

### 🎨 github-profile-beautifier

一键生成漂亮的 GitHub 个人主页 README。自动检测仓库、分析技术栈、智能推荐项目和主题。

**功能特性：**
- ✅ 智能仓库检测 - 自动获取用户所有公开仓库
- ✅ 技术栈分析 - 从语言分布自动识别
- ✅ 项目智能推荐 - 根据 star、更新时间、描述质量筛选 Top 5
- ✅ 5 种主题 - Radical / Tokyo Night / Dracula / Minimalist / Professional
- ✅ 3 种排序 - 按 star / 智能 / 更新时间

**用法：**
```
/github-profile-beautifier username
/github-profile-beautifier username --sort stars --theme tokyonight
```

### 🐳 docker-build-deploy

一键生成 Docker 构建 + 推送 + 部署的 GitHub Actions 工作流。

**功能特性：**
- ✅ 自动检测项目类型，生成优化 Dockerfile（多阶段构建、非 root、健康检查）
- ✅ 推送到 GHCR（GitHub Container Registry）
- ✅ 部署到服务器（SSH 拉取 → 停旧容器 → 启新容器 → 清理）
- ✅ 支持 env 文件注入
- ✅ GHA 缓存加速构建

**用法：**
```
/docker-build-deploy
/docker-build-deploy --port 8080
/docker-build-deploy --port 8080 --env-file /opt/app/.env
```

---

## 🚀 如何使用

### 方式一：npx skills（推荐，适配所有 AI 工具）

```bash
# 安装全部 skills
npx skills add wu529778790/shenzjd-skills -y

# 只安装指定 skill
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y

# 指定 AI 工具
npx skills add wu529778790/shenzjd-skills -y -a claude-code
npx skills add wu529778790/shenzjd-skills -y -a cursor
```

支持的 AI 工具：Claude Code、Cursor、Copilot、Windsurf、Gemini CLI、Cline、Aider 等 67+ 种。

### 方式二：手动安装

**Claude Code：**
```bash
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/github-profile-beautifier ~/.claude/skills/
```

**Cursor：** 将 SKILL.md 内容复制到 `.cursorrules` 或 `.cursor/rules/`。

**GitHub Copilot：** 将 SKILL.md 内容复制到 `.github/copilot-instructions.md`。

**其他工具：** `SKILL.md` 是通用指令文档，粘贴到你所用工具的 system prompt 或规则文件即可。

---

## 📁 目录结构

```
shenzjd-skills/
├── README.md
├── github-profile-beautifier/     # GitHub Profile 生成器
│   ├── SKILL.md
│   └── templates/
├── docker-build-deploy/           # Docker 构建部署
│   ├── SKILL.md
│   └── templates/
│       ├── docker-deploy.yml      # GitHub Actions 工作流模板
│       └── Dockerfile.nodejs      # Node.js Dockerfile 模板
```

---

## 🤝 贡献

欢迎提交新的 Skills！

### 添加新 Skill

1. 在项目根目录创建新文件夹（如 `my-skill/`）
2. 创建 `SKILL.md`（包含触发条件、执行流程、边界处理）
3. 添加必要的模板和配置文件
4. 更新 README.md
5. 提交 PR

### SKILL.md 格式

```markdown
---
name: skill-name
description: 触发条件描述
---

# Skill 名称

## When to Use
使用场景

## Core Pattern
核心逻辑与执行流程

## Quick Reference
参数与命令参考

## Edge Cases
边界情况处理
```

---

## 📝 更新日志

### v1.0.0 (2026-06-03)
- ✨ 初始版本
- 🎨 github-profile-beautifier：5 种主题 + 3 种排序

---

## 📄 许可证

MIT License

---

## 👨‍💻 作者

**神族九帝** - [GitHub](https://github.com/wu529778790) - [Website](https://shenzjd.com)

> 一个把 AI 当第二大脑，每天都在 AI Coding 的硬核程序员
