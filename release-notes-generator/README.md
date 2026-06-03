# 📋 Release Notes Generator

打 tag 时自动对比代码变更，生成标准化的 Release Notes。

## 功能特性

- ✅ 自动检测版本号，智能建议 major/minor/patch
- ✅ 对比 git 历史，分析 commit 和文件变更
- ✅ 按 conventional commit 分类（feat / fix / docs / refactor / chore）
- ✅ 自动检测 breaking changes
- ✅ 标准化输出格式，可直接用于 GitHub Release

## 🚀 安装

### 方式一：npx skills（推荐）

```bash
# 安装到 Claude Code
npx skills add wu529778790/shenzjd-skills -s release-notes-generator -y -a claude-code

# 安装到 Cursor
npx skills add wu529778790/shenzjd-skills -s release-notes-generator -y -a cursor

# 安装到所有已检测的 AI 工具
npx skills add wu529778790/shenzjd-skills -s release-notes-generator -y
```

### 方式二：手动安装

**Claude Code：**
```bash
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/release-notes-generator ~/.claude/skills/
# 重启 Claude Code 生效
```

**Cursor：** 将 `SKILL.md` 内容复制到 `.cursorrules` 或 `.cursor/rules/`。

**GitHub Copilot：** 将 `SKILL.md` 内容复制到 `.github/copilot-instructions.md`。

**其他工具：** `SKILL.md` 是通用指令文档，粘贴到你所用工具的 system prompt 或规则文件即可。

## 📖 使用方式

```bash
# 交互式生成（检测上一个 tag，建议版本号）
/release-notes

# 指定版本号
/release-notes v1.1.0

# 只生成 notes，不创建 tag
/release-notes --dry-run
```

### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `version` | 版本号（如 v1.1.0） | 自动建议 |
| `--dry-run` | 只生成 notes，不创建 tag/release | false |

## 输出格式

```markdown
## v1.1.0 (2026-06-03)

### 🚀 Features
- 新增 docker-build-deploy skill

### 🐛 Bug Fixes
- 修复 GitHub Action YAML 语法错误

### 📝 Documentation
- 重写 README

### 🔧 Chores
- gitignore 添加 .playwright-mcp/

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
```

## 版本号建议逻辑

| 变更类型 | 建议版本 | 示例 |
|---------|---------|------|
| 有 breaking changes | major | v1.0.0 → v2.0.0 |
| 有新功能 | minor | v1.0.0 → v1.1.0 |
| 只有 bugfix | patch | v1.0.0 → v1.0.1 |

## 📁 模板文件

| 文件 | 说明 |
|------|------|
| `templates/release-notes.md` | Release Notes 模板（Handlebars 格式） |
