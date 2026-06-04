# Git Hooks Setup

One-click configuration of Git Hooks to standardize team development workflow.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s git-hooks-setup -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/git-hooks-setup ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/git-hooks-setup                    # Interactive setup
/git-hooks-setup --husky            # Use husky
/git-hooks-setup --native           # Use native git hooks
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--husky` | Use husky | Auto-detect |
| `--native` | Use native git hooks | false |
| `--commitlint` | Add commit message validation | true |

## Configured Hooks

| Hook | Purpose |
|------|---------|
| pre-commit | lint + format + sensitive info check |
| commit-msg | conventional commit validation |
| pre-push | Run tests (optional) |

## Supported Solutions

| Solution | Use Case |
|----------|----------|
| husky | Node.js projects (recommended) |
| lefthook | Any project, faster |
| Native git hooks | Non-Node.js projects |
