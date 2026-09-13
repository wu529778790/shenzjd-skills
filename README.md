# 🛠️ AI Coding Skills

> 6 production-ready AI skill modules. One-line install, covering the core DevOps pipeline and AI image generation.

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
| 🎨 **freeimg** | Free AI image generation (z-image-turbo, ~100 free 2K images/day): text prompt → image in any AI chat | `generate an image with freeimg` |

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
Inspiration → freeimg AI Generation → 2K Images
```

## 📂 Install Individual Skills

```bash
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
npx skills add wu529778790/shenzjd-skills -s db-migration-helper -y
npx skills add wu529778790/shenzjd-skills -s git-hooks-setup -y
npx skills add wu529778790/shenzjd-skills -s dependency-audit -y
npx skills add wu529778790/shenzjd-skills -s github-figure-bed -y
npx skills add wu529778790/shenzjd-skills -s freeimg -y
```

> 🖼️ **github-figure-bed** companion web app: [img.shenzjd.com](https://img.shenzjd.com) — a visual management dashboard for the same figure-bed repo (drag-and-drop upload / compression & watermark / image management / CDN settings). The skill and the web app share one config file, so use them together for the best experience.

> 🎨 **freeimg** companion web app: [freeimg.shenzjd.com](https://freeimg.shenzjd.com) — free AI image generator with a 18000+ prompt library and 12 preset styles (WeChat/小红书 covers, posters, 3D cartoon…), history and figure-bed upload built in. The skill and the web app share one free token.
