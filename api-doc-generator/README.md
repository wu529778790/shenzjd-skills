# API Doc Generator

Auto-generate API documentation from code, supporting OpenAPI/Swagger specs.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s api-doc-generator -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/api-doc-generator ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/api-doc-generator                    # Scan project, generate openapi.yaml
/api-doc-generator --format json      # Output JSON format
/api-doc-generator --preview          # Generate and preview interactive docs
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--format` | Output format yaml / json | yaml |
| `--preview` | Generate interactive HTML docs | false |
| `--output` | Output path | `./docs/openapi.yaml` |

## Supported Frameworks

| Framework | Language |
|-----------|----------|
| Express / Koa / Fastify | Node.js |
| Next.js API Routes | TypeScript |
| Gin | Go |
| Flask / FastAPI | Python |
| Spring Boot | Java |

## Output

| File | Description |
|------|-------------|
| `openapi.yaml` | OpenAPI 3.0 spec file |
| `docs/api.html` | Interactive doc page (--preview) |
