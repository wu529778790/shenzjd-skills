# 🛠️ AI Coding Skills

> 7 个生产级 AI 技能模块，一行命令安装，覆盖 DevOps 核心链路与 AI 图片生成。

[![skills.sh](https://img.shields.io/badge/skills.sh-查找我-blue)](https://skills.sh/wu529778790/shenzjd-skills)

[English](README.md) | 中文

## ⚡ 快速安装

```bash
# 安装所有 skill
npx skills add wu529778790/shenzjd-skills --all -y

# 安装指定 skill
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
```

支持 Claude Code、Cursor、Copilot、Windsurf、Gemini CLI、Cline、Aider 等 **67+ 种 AI 工具**。

## 📦 技能一览

| 技能 | 说明 | 使用方式 |
|------|------|----------|
| 🐳 **docker-build-deploy** | Docker CI/CD + GitHub Actions 一键部署 | `/docker-build-deploy` |
| 🗄️ **db-migration-helper** | Model 变更 → 安全迁移 SQL | `/db-migration-helper` |
| 🪝 **git-hooks-setup** | 一键配置 husky/lefthook + commitlint | `/git-hooks-setup` |
| 🔒 **dependency-audit** | CVE 漏洞 + 过时依赖 + License 合规 | `/dependency-audit` |
| 🖼️ **github-figure-bed** | 一键初始化 GitHub 图床，登录即用、上传秒得 CDN 链接 | `/github-figure-bed setup` |
| 🎨 **freeimg-z-image** | 免费 AI 图片生成（z-image-turbo，每天约 100 张 2K 免费额度）：对话里一句话直接出图 | 「用 freeimg-z-image 生成一张××图」 |
| ⚡ **freeimg-hunyuan** | 腾讯混元 3.0 生图，**免费 10 万张额度**（微信「小程序成长计划」激励资源包）：文生图 + 垫图 | 「用混元生成一张××图」 |

## 🎯 覆盖场景

```
代码 → 提交 → Git Hooks → Commit 规范
  ↓
构建 → Docker CI/CD → 部署
  ↓
依赖 → 安全审计 → License 合规
  ↓
素材 → GitHub 图床 → CDN 链接
  ↓
灵感 → freeimg-z-image AI 生成 → 2K 图片
                                      ↘
        微信生态 → freeimg-hunyuan 混元生图（免费 10 万张，文生图 + 垫图）
```

## 📂 单独安装某个 Skill

```bash
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
npx skills add wu529778790/shenzjd-skills -s db-migration-helper -y
npx skills add wu529778790/shenzjd-skills -s git-hooks-setup -y
npx skills add wu529778790/shenzjd-skills -s dependency-audit -y
npx skills add wu529778790/shenzjd-skills -s github-figure-bed -y
npx skills add wu529778790/shenzjd-skills -s freeimg-z-image -y
npx skills add wu529778790/shenzjd-skills -s freeimg-hunyuan -y
```

> 🖼️ **github-figure-bed** 配套网页端：[img.shenzjd.com](https://img.shenzjd.com) —— 同一个图床仓库的可视化管理后台（拖拽上传 / 压缩水印 / 图片管理 / CDN 设置），AI 技能与网页端共用一份配置，搭配使用体验最佳。

> 🎨 **freeimg-z-image** 配套网页端：[freeimg.shenzjd.com](https://freeimg.shenzjd.com) —— 免费 AI 图片生成站，内置 18000+ 提示词库与 12 种预设风格（公众号/小红书封面、海报、3D 卡通等），支持历史记录与图床上传。AI 技能与网页端共用同一枚免费令牌。

> ⚡ **freeimg-hunyuan** 配套网页端：[freeimg.shenzjd.com/hunyuan](https://freeimg.shenzjd.com/hunyuan) —— 混元可视化工作台（文生图 + 垫图），页面内置**领取免费资源包到出图的完整图文教程**：微信「小程序成长计划」激励资源包 **10 万张 AI 生图 + 10 亿 Token** 免费领（6 个月有效），与 AI 技能共用同一套凭据。

## 📄 License

MIT
