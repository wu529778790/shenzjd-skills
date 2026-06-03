# 🛠️ AI Coding Skills

> 一套通用的 AI 编程助手 Skills，适配 Claude Code、Cursor、Copilot、Windsurf 等主流 AI 编程工具。

[![GitHub stars](https://img.shields.io/github/stars/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/network/members)

## 📋 Skills

| Skill | 说明 | 用法 |
|-------|------|------|
| 🎨 [github-profile-beautifier](./github-profile-beautifier/) | 一键生成 GitHub 个人主页 README | `/github-profile-beautifier username` |
| 🐳 [docker-build-deploy](./docker-build-deploy/) | 一键生成 Docker CI/CD GitHub Actions 工作流 | `/docker-build-deploy` |
| 📋 [release-notes-generator](./release-notes-generator/) | 打 tag 时自动生成标准化 Release Notes | `/release-notes v1.1.0` |
| ⚡ [performance-profiler](./performance-profiler/) | 一键分析项目性能瓶颈，输出优化建议 | `/performance-profiler` |
| 📖 [api-doc-generator](./api-doc-generator/) | 从代码自动生成 OpenAPI/Swagger 文档 | `/api-doc-generator` |
| 🗄️ [db-migration-helper](./db-migration-helper/) | 分析 model 变更，生成安全的迁移 SQL | `/db-migration-helper` |
| 🪝 [git-hooks-setup](./git-hooks-setup/) | 一键配置 Git Hooks，标准化开发流程 | `/git-hooks-setup` |
| 🔒 [dependency-audit](./dependency-audit/) | 扫描依赖安全漏洞、过时包和 license 合规 | `/dependency-audit` |

## 🚀 安装

```bash
# 安装全部
npx skills add wu529778790/shenzjd-skills -y

# 安装指定 skill
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
npx skills add wu529778790/shenzjd-skills -s release-notes-generator -y
npx skills add wu529778790/shenzjd-skills -s performance-profiler -y
npx skills add wu529778790/shenzjd-skills -s api-doc-generator -y
npx skills add wu529778790/shenzjd-skills -s db-migration-helper -y
npx skills add wu529778790/shenzjd-skills -s git-hooks-setup -y
npx skills add wu529778790/shenzjd-skills -s dependency-audit -y
```

支持：Claude Code、Cursor、Copilot、Windsurf、Gemini CLI、Cline、Aider 等 67+ 种 AI 工具。

## 📄 许可证

MIT License

---

**神族九帝** - [GitHub](https://github.com/wu529778790) - [Website](https://shenzjd.com)
