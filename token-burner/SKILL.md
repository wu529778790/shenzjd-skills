---
name: token-burner
description: Autonomously scan and improve a project — code review, tests, docs, dependency audit, refactoring. Each task isolated in a worktree with verification.
---

# Token Burner

在 token 过期前自动执行有价值的项目改进任务，不浪费任何额度。

## Overview

自动扫描项目，发现代码审查、测试生成、文档完善、依赖审计、重构等任务，按优先级排序后自主执行。使用 worktree 隔离每个任务，执行后自动验证，确保每次修改都是安全的。

## When to Use

- User wants to use tokens productively before they expire
- User wants to run an autonomous code improvement session
- User says "burn tokens" / "token burner" / "用掉 token"
- User wants to auto-discover and fix issues across a project
- User inputs `/token-burner`
- User wants automated code review across the project
- User wants to find and fix code smells automatically
- User wants to improve test coverage without manual effort
- User wants to do a full project health check and cleanup

**When NOT to Use:**
- User wants to work on a specific, well-defined task (use normal workflow)
- User wants to chat or brainstorm (no token waste concern)
- User's project has no code to improve
- User wants to run automated tests only (use test runner directly)
- User wants to generate documentation only (use doc generation tools)
- User wants to refactor specific files (do it manually for better control)

## Core Pattern

### Step 1: 项目扫描

检测项目类型和结构，发现可执行任务：

```bash
# 检测项目类型
test -f package.json && echo "Node.js"
test -f go.mod && echo "Go"
test -f requirements.txt && echo "Python"
test -f Cargo.toml && echo "Rust"

# 检测 git 状态
git log --oneline -5          # 最近变更
git diff --stat HEAD~3        # 变更范围
git status --porcelain        # 未提交变更
```

**任务发现引擎：**（详见 `templates/task-discovery.md`）

| 任务类型 | 发现方式 | 优先级 |
|---------|---------|--------|
| 🔒 依赖安全 | 如果 `dependency-audit` skill 可用则委派，否则直接运行审计工具 | P0 - 立即执行 |
| 🐛 代码缺陷 | 分析 `git diff` 中的逻辑问题 | P0 - 立即执行 |
| 🧪 测试覆盖 | 找无测试的源文件，检查覆盖率 | P1 - 高优先级 |
| 📝 文档缺失 | 检查 README、函数注释、API 文档 | P2 - 中优先级 |
| ♻️ 代码重构 | 重复代码、复杂函数、code smell | P2 - 中优先级 |
| 🧹 Git 清理 | 过时分支、conflict markers、大文件 | P3 - 低优先级 |

生成任务列表，每个任务包含：`type`、`file`、`description`、`impact`（high/medium/low）、`risk`（high/medium/low）。

### Step 2: 优先级排序

按 `score = impact_score × (1 - risk_score)` 排序：

| 因子 | high | medium | low |
|------|------|--------|-----|
| impact | 3 | 2 | 1 |
| risk | 0.8 | 0.4 | 0.1 |

**安全策略：**
- P0 任务（安全漏洞、缺陷）→ 立即执行
- P1 任务（测试）→ 可以执行，但每个任务在 worktree 中隔离
- P2 任务（文档、重构）→ 可以执行
- P3 任务（清理）→ 只在有剩余 token 时执行

**前置依赖检查：**

执行前先检查所需工具是否可用，缺失时跳过对应任务类型而非静默失败：

```bash
# 检查工具可用性
command -v jq >/dev/null 2>&1 || echo "⚠️ jq 未安装，安全审计任务将跳过"
command -v npm >/dev/null 2>&1 || echo "⚠️ npm 未安装，Node.js 审计将跳过"
command -v go >/dev/null 2>&1 || echo "⚠️ go 未安装，Go 审计将跳过"
command -v pip-audit >/dev/null 2>&1 || echo "⚠️ pip-audit 未安装，Python 审计将跳过"
```

**过滤规则：**
- 跳过 `node_modules/`、`vendor/`、`.git/` 等目录
- 跳过已由其他 skill 覆盖的任务（如 git-hooks-setup 已配置的）
- 跳过超过 500 行变更的大任务（拆分为子任务）

### Step 3: 自主执行

使用 Agent tool 逐个执行任务，每个任务在独立 worktree 中：

```
对每个 task in 队列:
  retries = 0
  max_retries = 3
  while retries < max_retries:
    1. Agent(task.prompt, {
         isolation: "worktree",
         label: "token-burner:" + task.type
       })
    2. 在 worktree 中跑测试验证
    3. 如果测试通过 → 合并到主分支，break
    4. 如果测试失败 → retries++
       - 如果 retries < max_retries → 回滚 worktree，重试
       - 如果 retries >= max_retries → 记录失败原因，跳过此任务
    5. 更新任务状态
```

**每种任务的执行策略：**

| 任务类型 | 执行方式 | 验证方式 |
|---------|---------|---------|
| 🔒 依赖安全 | 运行审计工具，生成修复命令 | 重新审计确认 |
| 🐛 代码缺陷 | 分析 diff，定位问题，修复 | 跑相关测试 |
| 🧪 测试覆盖 | 为源文件生成单元测试 | 跑新测试确认通过 |
| 📝 文档缺失 | 生成 README/注释/API docs | 检查文档格式 |
| ♻️ 代码重构 | 提取函数、消除重复、简化逻辑 | 跑全量测试 |
| 🧹 Git 清理 | 清理无用文件、格式化 | git status 确认 |

**执行限制：**
- 每个任务最多 3 次重试
- 单个任务超时 5 分钟则跳过
- 总任务数默认最多 20 个（可通过 `--max-tasks` 调整）

### Step 4: 记录和报告

每个任务完成后记录到 memory：

```markdown
## Token Burner 执行记录

### 最近一次运行
- 时间：YYYY-MM-DD HH:MM
- 项目：project-name
- 执行任务数：N
- 成功：N / 失败：N / 跳过：N

### 任务详情
| # | 类型 | 文件 | 状态 | 说明 |
|---|------|------|------|------|
| 1 | 🧪 测试 | src/utils.ts | ✅ 成功 | 生成 5 个测试用例 |
| 2 | 📝 文档 | README.md | ✅ 成功 | 补充 API 文档 |
| 3 | ♻️ 重构 | src/helper.ts | ❌ 失败 | 测试未通过，已回滚 |
```

### Step 5: 收尾

生成最终报告 `templates/execution-report.md`，包含：
- 执行统计（成功率、耗时、token 消耗估算）
- 每个任务的详细结果
- 未执行任务的原因
- 下次运行建议

## Quick Reference

Note: Parameters below are natural language hints parsed by the AI. Without parameters, the AI will ask interactively.

```bash
/token-burner                          # Scan and execute all tasks
/token-burner 只跑测试和文档            # Only test and doc tasks
/token-burner 最多跑 10 个任务          # Limit to 10 tasks
/token-burner 只扫描不执行              # Scan only, don't execute
/token-burner 扫描 /path/to/repo       # Target specific project
```

| Hint | Description | Default |
|------|-------------|---------|
| 只跑 `type` | Task type filter (security/bug/test/docs/refactor/clean) | All |
| 最多跑 `N` 个任务 | Maximum tasks to execute | 20 |
| 只扫描不执行 | Scan only, don't execute | false |
| 扫描 `path` | Target project path | Current directory |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 不跑测试就合并 | 每个任务执行后必须验证 | 避免引入新 bug |
| 一次执行太多任务 | 控制在 20 个以内 | 避免 token 耗尽时半途而废 |
| 跳过 worktree 隔离 | 始终用 isolation: "worktree" | 避免任务间互相干扰 |
| 不记录执行结果 | 写入 memory 文件 | 下次运行需要知道哪些做过 |
| 对生产代码不做验证 | 改完必须跑测试 | 确保不破坏现有功能 |
| 不检查工具可用性 | 执行前验证工具是否存在 | 缺失工具的任务应跳过而非报错 |
| 在大项目上不限制任务数 | 设置 `--max-tasks` 限制 | 避免 token 耗尽后任务中断 |
| 跳过风险评估 | 按 impact × (1 - risk) 排序 | 高风险任务应谨慎处理 |
| 不区分 node_modules 等目录 | 跳过 vendor/node_modules/.git | 扫描第三方代码浪费 token |
| 重构时不做 diff 检查 | 限制单任务变更 < 500 行 | 过大变更难以验证安全性 |
