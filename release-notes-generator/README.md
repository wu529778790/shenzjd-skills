# 📋 Release Notes Generator

Auto-generate standardized Release Notes by comparing code changes when tagging.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s release-notes-generator -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/release-notes-generator ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/release-notes              # Auto-suggest version number
/release-notes v1.1.0       # Specify version number
/release-notes --dry-run    # Generate only, don't create tag
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `version` | Version number (e.g., v1.1.0) | Auto-suggest |
| `--dry-run` | Generate only, don't create tag/release | false |

## Output Format

```markdown
## v1.1.0 (2026-06-03)

### 🚀 Features
- Add docker-build-deploy skill

### 🐛 Bug Fixes
- Fix GitHub Action YAML syntax error

### 📝 Documentation
- Rewrite README

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
```

## Version Suggestion

| Change Type | Suggested Version | Example |
|-------------|------------------|---------|
| Breaking changes | major | v1.0.0 → v2.0.0 |
| New features | minor | v1.0.0 → v1.1.0 |
| Bug fixes only | patch | v1.0.0 → v1.0.1 |
