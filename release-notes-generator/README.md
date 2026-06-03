# 📋 Release Notes Generator

打 tag 时自动对比代码变更，生成标准化的 Release Notes。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s release-notes-generator -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/release-notes-generator ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/release-notes              # 自动建议版本号
/release-notes v1.1.0       # 指定版本号
/release-notes --dry-run    # 只生成不创建 tag
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `version` | 版本号（如 v1.1.0） | 自动建议 |
| `--dry-run` | 只生成不创建 tag/release | false |

## 输出格式

```markdown
## v1.1.0 (2026-06-03)

### 🚀 Features
- 新增 docker-build-deploy skill

### 🐛 Bug Fixes
- 修复 GitHub Action YAML 语法错误

### 📝 Documentation
- 重写 README

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
```

## 版本号建议

| 变更类型 | 建议版本 | 示例 |
|---------|---------|------|
| 有 breaking changes | major | v1.0.0 → v2.0.0 |
| 有新功能 | minor | v1.0.0 → v1.1.0 |
| 只有 bugfix | patch | v1.0.0 → v1.0.1 |
