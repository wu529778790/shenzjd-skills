---
name: dependency-audit
description: Use when user wants to audit dependencies for security vulnerabilities, CVE scanning, check for outdated packages, verify license compliance, or get upgrade recommendations for npm, pip, or go modules
---

# Dependency Audit

扫描项目依赖，检测安全漏洞、过时包和 license 合规问题。

## Overview

全面审计项目依赖：CVE 漏洞扫描、过时依赖检测、license 合规检查、重复依赖分析。输出按严重程度排序的安全报告和可执行的修复命令。

## When to Use

- 用户想检查项目依赖安全
- 用户提到 CVE、漏洞、安全审计
- 用户想知道哪些依赖过时了
- 用户输入 `/dependency-audit`

**When NOT to Use:**
- 用户只是想更新依赖版本
- 用户想做代码级别的安全审查（那是 security-review）
- 用户想分析运行时依赖（需要 APM 工具）

## Core Pattern

### Step 1: 检测包管理器

| 检测文件 | 包管理器 | 审计命令 |
|---------|---------|---------|
| `package-lock.json` | npm | `npm audit` |
| `yarn.lock` | yarn | `yarn audit` |
| `pnpm-lock.yaml` | pnpm | `pnpm audit` |
| `go.sum` | Go | `govulncheck ./...` |
| `requirements.txt` / `Pipfile.lock` | Python | `pip-audit` |
| `Cargo.lock` | Rust | `cargo audit` |

### Step 2: 漏洞扫描

```bash
# npm
npm audit --json 2>/dev/null | python3 -c "
import sys,json
data=json.load(sys.stdin)
vulns=data.get('vulnerabilities',{})
print(f'Total: {len(vulns)} vulnerabilities')
for name,v in vulns.items():
    print(f'  {name}: {v.get(\"severity\",\"unknown\")} - {v.get(\"title\",\"\")}')
"

# Go
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./... 2>/dev/null

# Python
pip-audit 2>/dev/null || echo "pip-audit 未安装，运行: pip install pip-audit"
```

### Step 3: 过时依赖检测

```bash
# npm
npx npm-check-updates --format table 2>/dev/null

# Go
go list -m -u all 2>/dev/null | grep "\[" 

# Python
pip list --outdated 2>/dev/null
```

统计：
- 过时依赖数量
- major / minor / patch 升级分布
- 是否有安全相关的更新

### Step 4: License 合规检查

```bash
# npm
npx license-checker --json 2>/dev/null | python3 -c "
import sys,json
data=json.load(sys.stdin)
licenses={}
for k,v in data.items():
    lic=v.get('licenses','UNKNOWN')
    licenses[lic]=licenses.get(lic,0)+1
for l,c in sorted(licenses.items(),key=lambda x:-x[1]):
    print(f'  {l}: {c}')
"

# Go
go-licenses csv ./... 2>/dev/null
```

检测：
- 是否有 GPL/AGPL 等 copyleft 许可证
- 是否有未知/自定义许可证
- 许可证兼容性

### Step 5: 生成报告

使用 `templates/audit-report.md` 模板，输出：

1. **安全概览** — 漏洞数量和严重程度分布
2. **高危漏洞** — 需要立即修复的 CVE
3. **过时依赖** — 按升级难度排序
4. **License 合规** — 风险许可证列表
5. **修复命令** — 每个问题附带可执行命令

## Quick Reference

```bash
/dependency-audit                    # 完整审计
/dependency-audit --security         # 只检查安全漏洞
/dependency-audit --licenses         # 只检查 license
/dependency-audit --fix              # 自动修复可安全升级的依赖
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--security` | 只检查安全漏洞 | false |
| `--licenses` | 只检查 license 合规 | false |
| `--fix` | 自动修复 | false |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 只看 high/critical | medium 也需要关注 | 很多攻击链从 medium 升级而来 |
| 盲目升级所有依赖 | 逐个升级并测试 | major 升级可能有 breaking changes |
| 不检查 transitive 依赖 | 分析完整依赖树 | 漏洞常出在间接依赖中 |
| 忽略 license 合规 | 定期检查 license | GPL 传染性风险 |
| audit 后不更新 lock 文件 | 重新生成 lock 文件 | 确保修复生效 |
