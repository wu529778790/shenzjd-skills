# 🛠️ Claude Code Skills

> 我的 Claude Code skills 集合，用于提升开发效率

[![GitHub stars](https://img.shields.io/github/stars/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/wu529778790/shenzjd-skills?style=social)](https://github.com/wu529778790/shenzjd-skills/network/members)

## 📋 Skills 列表

### 🎨 github-profile-beautifier

一键生成漂亮的 GitHub 个人主页 README。自动检测仓库、分析技术栈、智能推荐项目和主题。

**功能特性：**
- ✅ 智能仓库检测 - 自动获取用户所有公开仓库
- ✅ 技术栈分析 - 从 package.json、语言分布自动识别
- ✅ 项目智能推荐 - 根据 star、更新时间、描述筛选最佳项目
- ✅ 主题智能匹配 - 提供 5 种主题选择
- ✅ 多种排序方式 - 按 star、智能、更新时间排序
- ✅ 完整 README 生成 - 直接输出可用的 README.md

**使用方式：**
```bash
# 基本用法
/github-profile-beautifier username

# 指定排序方式和主题
/github-profile-beautifier username --sort stars --theme tokyonight
```

**可用主题：**
- Radical - 活泼、鲜艳风格
- Tokyo Night - 现代、深色风格
- Dracula - 暗黑、紫色风格
- Minimalist - 简洁、专业风格
- Professional - 商务、蓝色风格

**排序方式：**
- `--sort stars` - 按 star 数排序
- `--sort smart` - 智能排序（默认）
- `--sort updated` - 按更新时间排序

---

## 🚀 如何使用

### 安装 Skills

1. 克隆这个仓库
```bash
git clone https://github.com/wu529778790/shenzjd-skills.git
```

2. 复制 skills 到你的 Claude Code 目录
```bash
cp -r github-profile-beautifier ~/.claude/skills/
```

3. 重启 Claude Code

### 使用 Skills

在 Claude Code 中直接使用：
```bash
/github-profile-beautifier username
```

---

## 📁 目录结构

```
shenzjd-skills/
├── README.md                          # 项目说明
├── github-profile-beautifier/         # GitHub Profile 生成器
│   ├── SKILL.md                       # Skill 主文件
│   └── templates/                     # 模板文件
│       ├── radical.md                 # Radical 主题
│       ├── tokyonight.md              # Tokyo Night 主题
│       ├── dracula.md                 # Dracula 主题
│       ├── minimalist.md              # Minimalist 主题
│       ├── professional.md            # Professional 主题
│       ├── themes.json                # 主题配置
│       └── README.md                  # 模板使用说明
```

---

## 🤝 贡献

欢迎提交新的 skills！

### 如何添加新 Skill

1. 在项目根目录创建新文件夹（如 `my-skill/`）
2. 创建 `SKILL.md` 文件（遵循 skill 格式）
3. 添加必要的模板和配置文件
4. 更新 README.md
5. 提交 PR

### Skill 格式要求

```markdown
---
name: skill-name
description: Use when [触发条件]
---

# Skill 名称

## Overview
简要介绍

## When to Use
使用场景

## Core Pattern
核心逻辑

## Quick Reference
快速参考

## Implementation
实现细节

## Common Mistakes
常见错误
```

---

## 📝 更新日志

### v1.0.0 (2026-06-03)
- ✨ 初始版本
- 🎨 添加 github-profile-beautifier skill
- 📦 支持 5 种主题
- 🔄 支持 3 种排序方式

---

## 📄 许可证

MIT License

---

## 👨‍💻 作者

**神族九帝** - [GitHub](https://github.com/wu529778790) - [Website](https://shenzjd.com)

> 一个把 AI 当第二大脑，每天都在 AI Coding 的硬核程序员
