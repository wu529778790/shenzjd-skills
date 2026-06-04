# DB Migration Helper

Analyze model changes and generate safe database migration SQL.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s db-migration-helper -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/db-migration-helper ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/db-migration-helper                    # Detect changes, generate migration
/db-migration-helper --dry-run          # Preview SQL only
/db-migration-helper --name add_user    # Specify migration name
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--dry-run` | Preview only, don't execute | false |
| `--name` | Migration file name | Auto-generated |
| `--output` | Output directory | `./migrations/` |

## Supported Databases

| Database | Support Level |
|----------|--------------|
| PostgreSQL | Full |
| MySQL | Full |
| SQLite | Basic |

## Output

Each migration includes:
- **Up SQL** — Forward changes
- **Down SQL** — Rollback statements
- **Risk Assessment** — Flags high-risk operations (drop column, type change)
