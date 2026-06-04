# Performance Profiler

One-click analysis of project performance bottlenecks with prioritized optimization recommendations.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s performance-profiler -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/performance-profiler ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/performance-profiler              # Analyze current project
/performance-profiler --fix        # Analyze and auto-fix
/performance-profiler --json       # JSON format output
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--fix` | Auto-fix safe issues | false |
| `--json` | Output JSON format report | false |

## Analysis Dimensions

| Dimension | What It Checks |
|-----------|---------------|
| Dependency Health | Redundant deps, duplicate deps, outdated deps |
| Bundle Size | Large files, un-tree-shaken imports |
| Code Patterns | barrel file, import *, sync I/O |
| Config Optimization | Build tool config, caching strategy |

## Supported Project Types

| Type | Detection |
|------|-----------|
| Node.js / Frontend | `package.json` |
| Go | `go.mod` |
| Python | `requirements.txt` / `pyproject.toml` |
| Rust | `Cargo.toml` |
