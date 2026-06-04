# 🐳 Docker Build & Deploy

One-click generation of Docker build + push to GHCR + deploy to server GitHub Actions workflows.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/docker-build-deploy ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/docker-build-deploy
/docker-build-deploy --port 8080
/docker-build-deploy --port 8080 --env-file /opt/app/.env
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--port` | Container exposed port | 3000 |
| `--env-file` | Server env file path | empty |

## Generated Files

**`.github/workflows/docker-deploy.yml`** — Two jobs:

1. **build-and-push**: Login to GHCR → Buildx build → Push (latest + sha) → GHA cache
2. **deploy** (main only): SSH → Pull image → Stop old container → Start new container → Cleanup

**`Dockerfile`** (if needed) — Auto-detects project type:

| Project Type | Detection | Base Image |
|-------------|-----------|------------|
| Node.js | `package.json` | `node:20-alpine` (multi-stage) |
| Go | `go.mod` | `golang:alpine` → `alpine` |
| Python | `requirements.txt` | `python:3.12-slim` |

## Prerequisites

Configure in GitHub repo Settings → Secrets:

| Secret | Description |
|--------|-------------|
| `DEPLOY_HOST` | Server IP |
| `DEPLOY_USER` | SSH username |
| `DEPLOY_PASSWORD` | SSH password or private key |

Server must have Docker installed and SSH port open.
