# Git Hooks Setup

一键配置 Git Hooks，标准化团队开发流程。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s git-hooks-setup -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/git-hooks-setup ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/git-hooks-setup                    # 交互式配置
/git-hooks-setup --husky            # 用 husky
/git-hooks-setup --native           # 用原生 git hooks
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--husky` | 使用 husky | 自动检测 |
| `--native` | 使用原生 git hooks | false |
| `--commitlint` | 添加 commit message 校验 | true |

## 配置的 Hooks

| Hook | 作用 |
|------|------|
| pre-commit | lint + format + 敏感信息检查 |
| commit-msg | conventional commit 校验 |
| pre-push | 运行测试（可选） |

## 支持的方案

| 方案 | 适用场景 |
|------|---------|
| husky | Node.js 项目（推荐） |
| lefthook | 任何项目，更快 |
| 原生 git hooks | 非 Node.js 项目 |
