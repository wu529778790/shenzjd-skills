# Dependency Audit

Scan project dependencies for security vulnerabilities, outdated packages, and license compliance issues.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s dependency-audit -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/dependency-audit ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/dependency-audit                    # Full audit
/dependency-audit --security         # Security vulnerabilities only
/dependency-audit --licenses         # License compliance only
/dependency-audit --fix              # Auto-fix safe upgrades
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--security` | Security vulnerabilities only | false |
| `--licenses` | License compliance only | false |
| `--fix` | Auto-fix safe upgrades | false |

## Audit Dimensions

| Dimension | What It Checks |
|-----------|---------------|
| Security Vulnerabilities | CVE scanning, severity classification |
| Outdated Dependencies | major/minor/patch upgrade detection |
| License Compliance | GPL/AGPL/custom license detection |
| Duplicate Dependencies | Same dependency at different versions |

## Supported Ecosystems

| Ecosystem | Detection Tool |
|-----------|---------------|
| npm / yarn / pnpm | npm audit |
| Go | govulncheck |
| Python | pip-audit |
| Rust | cargo audit |
