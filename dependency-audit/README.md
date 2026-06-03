# Dependency Audit

扫描项目依赖，检测安全漏洞、过时包和 license 合规问题。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s dependency-audit -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/dependency-audit ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/dependency-audit                    # 完整审计
/dependency-audit --security         # 只检查安全漏洞
/dependency-audit --licenses         # 只检查 license
/dependency-audit --fix              # 自动修复
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--security` | 只检查安全漏洞 | false |
| `--licenses` | 只检查 license 合规 | false |
| `--fix` | 自动修复可安全升级的依赖 | false |

## 审计维度

| 维度 | 检测内容 |
|------|---------|
| 安全漏洞 | CVE 扫描、严重程度分级 |
| 过时依赖 | major/minor/patch 升级检测 |
| License 合规 | GPL/AGPL/自定义许可证检测 |
| 重复依赖 | 不同版本的同一依赖 |

## 支持的生态

| 生态 | 检测工具 |
|------|---------|
| npm / yarn / pnpm | npm audit |
| Go | govulncheck |
| Python | pip-audit |
| Rust | cargo audit |
