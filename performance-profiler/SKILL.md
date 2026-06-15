---
name: performance-profiler
description: Use when profiling a Node/Go/Python project for performance bottlenecks — bundle size, dependency bloat, large files, unused code — and outputting prioritized optimization recommendations.
---

# Performance Profiler

一键分析项目性能瓶颈，输出优先级排序的优化建议。

## Overview

扫描项目代码和配置，检测性能问题：bundle 体积、依赖膨胀、大文件、未优化的资源。输出按影响程度排序的可执行优化建议报告。

## When to Use

- User wants to analyze project performance
- User mentions bundle size, slow loading, or performance optimization
- User wants to know which dependencies are slowing down the project
- User inputs `/performance-profiler`
- User wants to reduce bundle size for faster page loads
- User wants to find and remove unused dependencies
- User wants to check for barrel file impact on tree-shaking
- User wants performance optimization recommendations

**When NOT to Use:**
- User wants runtime profiling (requires dedicated APM tools like New Relic, Datadog)
- User wants load testing (use k6, Locust, or Apache Bench)
- User only wants to view code coverage (use coverage tools like Istanbul, coverage.py)
- User wants to optimize database queries (use EXPLAIN plans, slow query logs)
- User wants to check Core Web Vitals (use Lighthouse, PageSpeed Insights)

## Core Pattern

### Step 1: 检测项目类型

| 检测文件 | 项目类型 | 分析重点 |
|---------|---------|---------|
| `package.json` | Node.js / 前端 | bundle size、依赖数量、tree-shaking |
| `go.mod` | Go | 二进制大小、依赖数量 |
| `requirements.txt` / `pyproject.toml` | Python | 依赖数量、重复依赖 |

### Step 2: 分析依赖

```bash
# Node.js
if command -v node >/dev/null 2>&1; then
  # 尝试 cost-of-modules，如果失败则使用替代方案
  if npx --yes cost-of-modules 2>/dev/null; then
    echo "使用 cost-of-modules 分析完成"
  else
    echo "⚠️ cost-of-modules 不可用，使用替代方案"
    cat package.json | python3 -c "
import sys,json
d=json.load(sys.stdin)
deps=d.get('dependencies',{})
dev_deps=d.get('devDependencies',{})
print(f'Direct Dependencies: {len(deps)}')
print(f'Dev Dependencies: {len(dev_deps)}')
print(f'Total: {len(deps) + len(dev_deps)}')
# 列出前 10 个依赖
print('Top dependencies:')
for i, (name, ver) in enumerate(list(deps.items())[:10]):
    print(f'  {name}: {ver}')
"
  fi
else
  echo "⚠️ Node.js 未安装，跳过 Node.js 依赖分析"
fi

# Go
if command -v go >/dev/null 2>&1; then
  echo "Go dependencies:"
  go list -m all 2>/dev/null | tail -n +2 | wc -l || echo "0"
else
  echo "⚠️ go 未安装，跳过 Go 依赖分析"
fi

# Python
if command -v python3 >/dev/null 2>&1; then
  echo "Python dependencies:"
  grep -cvE '^\s*(#|$)' requirements.txt 2>/dev/null || echo "0"
else
  echo "⚠️ python3 未安装，跳过 Python 依赖分析"
fi
```

统计（对应 `templates/report.md` 的变量）：
- `dep_count`：直接依赖数量（Node `len(dependencies)` / Go `go list -m all` 计数 / Python requirements 行数）
- `total_dep_count`：含间接依赖的总数（解析 `package-lock.json` / `go list -m all` / `pip list`）
- `outdated_count`：过时依赖数量（`npm outdated --json` / `go list -m -u all` / `pip list --outdated`）
- `health_score`：综合评分（依赖规模、过时比例、冗余情况，0-100）
- `deps[].size`：包大小（来自 cost-of-modules 或 bundlephobia；无则留空）
- 重复依赖（不同包引入同一依赖的不同版本）
- 可能的冗余依赖

### Step 3: 扫描代码模式

**前端/Node.js 重点：**
- 检查 `import`/`require` 是否有 barrel file（`index.ts` re-export 所有模块）
- 检查是否有大型静态文件（>500KB 的图片/字体）
- 检查是否有未使用的 CSS/JS 文件
- 检查 `next.config.js` / `vite.config.ts` 的优化配置

**Go 重点：**
- 检查是否有不必要的 `init()` 函数
- 检查大 struct 的值传递（应改指针）

**Python 重点：**
- 检查是否有 `import *`
- 检查是否有同步 I/O 在异步上下文中

### Step 4: 生成报告

使用 `templates/report.md` 模板，输出：

1. **总览** — 依赖数量、项目健康度评分
2. **高优先级** — 影响最大的问题（bundle 膨胀、冗余依赖）
3. **中优先级** — 代码层面的优化点
4. **低优先级** — 建议性改进
5. **具体修复命令** — 每个问题附带可执行的修复命令

## Quick Reference

```bash
/performance-profiler              # 分析当前项目，输出优化建议报告
```

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 只看依赖数量不看体积 | 同时分析包体积 | 10 个小包可能比 1 个大包更好 |
| 建议删除所有 devDependencies | devDependencies 不进生产 | 它们不影响线上性能 |
| 忽略 lock 文件 | 分析 lock 文件中的实际依赖树 | package.json 声明 ≠ 实际安装 |
| 不区分生产/开发依赖 | 重点分析 dependencies | devDependencies 不影响 bundle |
| 忽略 barrel file 影响 | 检查 index.ts 重新导出模式 | barrel file 阻止 tree-shaking，大幅增加 bundle |
| 不考虑代码分割 | 检查动态 import 使用情况 | 单 chunk 加载所有代码影响首屏 |
| 建议删除所有重复依赖 | 分析实际使用再决定 | 有些是 peer dependency 必须保留 |
| 只分析前端不分析后端 | 全栈项目前后端都分析 | Go/Python 也有性能问题 |
| 跳过 lock 文件分析 | 解析 lock 文件获取完整依赖树 | 直接依赖少不代表间接依赖少 |
