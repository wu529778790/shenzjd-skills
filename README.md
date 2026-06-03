# 🛠️ AI Coding Skills

> 一套通用的 AI 编程助手 Skills，适配 Claude Code、Cursor、Copilot、Windsurf 等主流 AI 编程工具。

[![GitHub stars](https://img.shields.io/github/stars/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/network/members)

## 📋 Skills

| Skill | 说明 | 用法 |
|-------|------|------|
| 🎨 [github-profile-beautifier](./github-profile-beautifier/) | 一键生成 GitHub 个人主页 README，5 种主题 + 3 种排序 | `/github-profile-beautifier username` |
| 🐳 [docker-build-deploy](./docker-build-deploy/) | 一键生成 Docker 构建 + 推送 + 部署的 GitHub Actions 工作流 | `/docker-build-deploy` |

## 🚀 安装

```bash
# 安装全部 skills（推荐）
npx skills add wu529778790/shenzjd-skills -y

# 只安装指定 skill
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
```

支持：Claude Code、Cursor、Copilot、Windsurf、Gemini CLI、Cline、Aider 等 67+ 种 AI 工具。

## 📁 目录结构

```
shenzjd-skills/
├── README.md
├── github-profile-beautifier/     # GitHub Profile 生成器
│   ├── SKILL.md
│   ├── README.md                  # 详细介绍
│   └── templates/
├── docker-build-deploy/           # Docker 构建部署
│   ├── SKILL.md
│   ├── README.md                  # 详细介绍
│   └── templates/
```

## 📄 许可证

MIT License

---

**神族九帝** - [GitHub](https://github.com/wu529778790) - [Website](https://shenzjd.com)
