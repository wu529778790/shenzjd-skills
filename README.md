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

---

## 🚀 如何使用

### 1. 克隆仓库

```bash
git clone https://github.com/wu529778790/shenzjd-skills.git
```

### 2. 根据你的 AI 工具配置

**Claude Code：**
```bash
cp -r github-profile-beautifier ~/.claude/skills/
# 重启 Claude Code 后生效
```

**Cursor：**
将 `github-profile-beautifier/SKILL.md` 的内容复制到 `.cursorrules` 或 `.cursor/rules/` 中。

**GitHub Copilot：**
将 `github-profile-beautifier/SKILL.md` 的内容复制到 `.github/copilot-instructions.md`。

**其他工具：**
每个 Skill 的 `SKILL.md` 是一份完整的指令文档，包含执行流程、参数说明和边界情况处理。将其内容粘贴到你所用工具的 system prompt 或规则文件中即可。

---

## 📁 目录结构

```
shenzjd-skills/
├── README.md
├── github-profile-beautifier/
│   ├── SKILL.md                   # Skill 主文件（执行流程 + 指令）
│   └── templates/                 # 模板文件
│       ├── radical.md
│       ├── tokyonight.md
│       ├── dracula.md
│       ├── minimalist.md
│       ├── professional.md
│       ├── themes.json            # 主题配置
│       └── README.md              # 模板使用说明
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
