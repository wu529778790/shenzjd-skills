# 🔥 Token Burner

Autonomously discover and execute valuable code improvements before tokens expire. Never waste a token again.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s token-burner -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/token-burner ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

Note: Parameters are natural language hints parsed by the AI. Without parameters, the AI will ask interactively.

```bash
/token-burner                          # Scan and execute all tasks
/token-burner 只跑测试和文档            # Only test and doc tasks
/token-burner 最多跑 10 个任务          # Limit to 10 tasks
/token-burner 只扫描不执行              # Scan only, don't execute
/token-burner 扫描 /path/to/repo       # Target specific project
```

| Hint | Description | Default |
|------|-------------|---------|
| 只跑 `type` | Filter task types (security/bug/test/docs/refactor/clean) | All |
| 最多跑 `N` 个任务 | Maximum tasks to execute | 20 |
| 只扫描不执行 | Scan only, don't execute | false |
| 扫描 `path` | Target project path | Current directory |

## How It Works

```
Project Scan → Task Discovery → Priority Queue → Autonomous Execution → Report
     │              │                │                    │                │
     │              │                │                    │                │
  Detect        Find issues     Sort by impact      Agent executes    Generate
  project       & opportunities  × (1 - risk)       in worktrees      summary
  type                                                        with tests
```

## Task Types

| Type | Discovery Method | Priority |
|------|-----------------|----------|
| 🔒 Security audit | npm audit / govulncheck / pip-audit | P0 |
| 🐛 Bug detection | Analyze git diff for logic issues | P0 |
| 🧪 Test generation | Find untested source files | P1 |
| 📝 Documentation | Check README, comments, API docs | P2 |
| ♻️ Refactoring | Duplicate code, complexity, code smells | P2 |
| 🧹 Git cleanup | Stale branches, conflict markers | P3 |

## Safety

- Each task runs in an isolated git worktree
- Tests run after every change
- Failed tasks auto-rollback
- Checkpoint commits every 5 tasks
- Progress persisted across sessions

## Prerequisites

- Git repository with history
- Project-specific tools (npm, go, pip, cargo) installed
- `jq` installed (for JSON processing)
