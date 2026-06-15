# 🛠️ AI Coding Skills

> 9 个生产级 AI 编程技能模块，一行命令安装，覆盖 DevOps 全链路。

[![skills.sh](https://img.shields.io/badge/skills.sh-查找我-blue)](https://skills.sh/wu529778790/shenzjd-skills)

[English](README.md) | 中文

## ⚡ 快速安装

```bash
# 安装所有 skill
npx skills add wu529778790/shenzjd-skills --all -y

# 安装指定 skill
npx skills add wu529778790/shenzjd-skills -s token-burner -y
```

支持 Claude Code、Cursor、Copilot、Windsurf、Gemini CLI、Cline、Aider 等 **67+ 种 AI 工具**。

## 📦 技能一览

| 技能 | 说明 | 使用方式 |
|------|------|----------|
| 🎨 **github-profile-beautifier** | 自动生成 GitHub 个人主页 README | `/github-profile-beautifier username` |
| 🐳 **docker-build-deploy** | Docker CI/CD + GitHub Actions 一键部署 | `/docker-build-deploy` |
| 📋 **release-notes-generator** | 打 tag 自动生成标准化 Release Notes | `/release-notes v1.1.0` |
| ⚡ **performance-profiler** | 扫描性能瓶颈，输出优化建议 | `/performance-profiler` |
| 📖 **api-doc-generator** | 从代码生成 OpenAPI/Swagger 文档 | `/api-doc-generator` |
| 🗄️ **db-migration-helper** | Model 变更 → 安全迁移 SQL | `/db-migration-helper` |
| 🪝 **git-hooks-setup** | 一键配置 husky/lefthook + commitlint | `/git-hooks-setup` |
| 🔒 **dependency-audit** | CVE 漏洞 + 过时依赖 + License 合规 | `/dependency-audit` |
| 🔥 **token-burner** | 自主消耗 token — 扫描、排序、执行任务 | `/token-burner` |

## 🎯 覆盖场景

```
代码 → 性能分析 → API 文档 → 测试
  ↓
提交 → Git Hooks → Commit 规范
  ↓
构建 → Docker CI/CD → 部署
  ↓
依赖 → 安全审计 → License 合规
  ↓
发布 → Release Notes → 版本管理
```

## 📂 单独安装某个 Skill

```bash
npx skills add wu529778790/shenzjd-skills -s performance-profiler -y
npx skills add wu529778790/shenzjd-skills -s api-doc-generator -y
npx skills add wu529778790/shenzjd-skills -s db-migration-helper -y
npx skills add wu529778790/shenzjd-skills -s git-hooks-setup -y
npx skills add wu529778790/shenzjd-skills -s dependency-audit -y
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
npx skills add wu529778790/shenzjd-skills -s release-notes-generator -y
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y
npx skills add wu529778790/shenzjd-skills -s token-burner -y
```

## 📄 License

MIT
