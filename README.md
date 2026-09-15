# 🛠️ AI Coding Skills

> 7 production-ready AI skill modules. One-line install, covering the core DevOps pipeline and AI image generation.

English | [中文](README.zh.md)

[![skills.sh](https://img.shields.io/badge/skills.sh-find%20me-blue)](https://skills.sh/wu529778790/shenzjd-skills)

## ⚡ Quick Install

```bash
# Install all skills
npx skills add wu529778790/shenzjd-skills --all -y

# Install specific skill
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
```

Supports Claude Code, Cursor, Copilot, Windsurf, Gemini CLI, Cline, Aider, and **67+ AI tools**.

## 📦 Skills Overview

| Skill | Description | Usage |
|-------|-------------|-------|
| 🐳 **docker-build-deploy** | Docker CI/CD + GitHub Actions one-click deploy | `/docker-build-deploy` |
| 🗄️ **db-migration-helper** | Model changes → safe migration SQL | `/db-migration-helper` |
| 🪝 **git-hooks-setup** | One-click husky/lefthook + commitlint setup | `/git-hooks-setup` |
| 🔒 **dependency-audit** | CVE vulnerabilities + outdated deps + license compliance | `/dependency-audit` |
| 🖼️ **github-figure-bed** | One-time setup → zero-config GitHub figure bed: upload images, get CDN/Markdown links | `/github-figure-bed setup` |
| 🎨 **freeimg-z-image** | Free AI image generation (z-image-turbo, ~100 free 2K images/day): text prompt → image in any AI chat | `generate an image with freeimg-z-image` |
| ⚡ **freeimg-hunyuan** | Tencent Hunyuan 3.0 — **FREE 100K images** via the WeChat 小程序成长计划 incentive pack: text-to-image + image-to-image | `generate an image with freeimg-hunyuan` |

## 🎯 Coverage

```
Code → Commit → Git Hooks → Commit Conventions
  ↓
Build → Docker CI/CD → Deployment
  ↓
Dependencies → Security Audit → License Compliance
  ↓
Assets → GitHub Figure Bed → CDN Links
  ↓
Inspiration → freeimg-z-image AI Generation → 2K Images
                                                      ↘
                       WeChat ecosystem → freeimg-hunyuan (FREE 100K images, t2i + i2i)
```

## 📂 Install Individual Skills

```bash
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
npx skills add wu529778790/shenzjd-skills -s db-migration-helper -y
npx skills add wu529778790/shenzjd-skills -s git-hooks-setup -y
npx skills add wu529778790/shenzjd-skills -s dependency-audit -y
npx skills add wu529778790/shenzjd-skills -s github-figure-bed -y
npx skills add wu529778790/shenzjd-skills -s freeimg-z-image -y
npx skills add wu529778790/shenzjd-skills -s freeimg-hunyuan -y
```

> 🖼️ **github-figure-bed** companion web app: [img.shenzjd.com](https://img.shenzjd.com) — a visual management dashboard for the same figure-bed repo (drag-and-drop upload / compression & watermark / image management / CDN settings). The skill and the web app share one config file, so use them together for the best experience.

> 🎨 **freeimg-z-image** companion web app: [freeimg.shenzjd.com](https://freeimg.shenzjd.com) — free AI image generator with a 18000+ prompt library and 12 preset styles (WeChat/小红书 covers, posters, 3D cartoon…), history and figure-bed upload built in. The skill and the web app share one free token.

> ⚡ **freeimg-hunyuan** companion web app: [freeimg.shenzjd.com/hunyuan](https://freeimg.shenzjd.com/hunyuan) — visual Hunyuan studio (text-to-image + reference-image i2i) with a **step-by-step illustrated tutorial** for claiming the free WeChat 小程序成长计划 incentive pack (**100,000 free AI images + 1B tokens**, 6-month validity). Same BYOK credentials as the skill.
