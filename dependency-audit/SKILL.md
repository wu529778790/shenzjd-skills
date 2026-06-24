---
name: dependency-audit
description: Use when auditing project dependencies for security vulnerabilities, outdated packages, or license compliance across npm/yarn/pnpm, pip, go, and cargo.
---

# Dependency Audit

扫描项目依赖，检测安全漏洞、过时包和 license 合规问题。

## Overview

全面审计项目依赖：CVE 漏洞扫描、过时依赖检测、license 合规检查、重复依赖分析。输出按严重程度排序的安全报告和可执行的修复命令。

## When to Use

- User wants to check dependency security
- User mentions CVE, vulnerability, or audit
- User wants to know outdated dependencies
- User says "审计依赖" / "check dependencies"
- User inputs `/dependency-audit`

**When NOT to Use:**
- User only wants to update versions
- User wants code-level security review
- User wants to analyze runtime dependencies
- User wants deep license analysis
- User wants to scan Docker images

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
# 工具可用性检查（所有步骤共用）
check_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "⚠️ $1 未安装，跳过 $2 审计"; return 1; }
}
```

核心命令（按包管理器分别执行，缺失工具自动跳过）：

| 包管理器 | 审计命令 |
|---------|---------|
| npm | `npm audit --json` → 解析 vulnerabilities 数量 + 严重程度 |
| Go | `govulncheck ./...` → 安装 golang.org/x/vuln/cmd/govulncheck@latest |
| Python | `pip-audit` → 安装: `pip install pip-audit` |

输出：漏洞总数 + 按严重程度（critical/high/medium/low）分类的 CVE 列表。

### Step 3: 过时依赖检测

核心命令（按包管理器分别执行，缺失工具自动跳过）：

| 包管理器 | 检测命令 |
|---------|---------|
| npm | `npx npm-check-updates --format table` |
| Go | `go list -m -u all \| grep "\["` |
| Python | `pip list --outdated` |

统计：过时依赖数量、major/minor/patch 升级分布、是否有安全相关更新。

### Step 4: License 合规检查

核心命令（按包管理器分别执行）：

| 包管理器 | 检测命令 |
|---------|---------|
| npm | `npx license-checker --json` → 按许可证类型统计数量 |
| Go | `go-licenses csv ./...` → 安装: `go install github.com/google/go-licenses@latest` |

检测重点：GPL/AGPL 等 copyleft 许可证、未知/自定义许可证、许可证兼容性。

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
| 忽略已弃用的依赖 | 检查弃用警告 | 弃用包可能有安全风险 |
