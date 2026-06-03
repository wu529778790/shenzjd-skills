# 🐳 Docker Build & Deploy

一键生成 Docker 构建 + 推送到 GHCR + 部署到服务器的 GitHub Actions 工作流。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/docker-build-deploy ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/docker-build-deploy
/docker-build-deploy --port 8080
/docker-build-deploy --port 8080 --env-file /opt/app/.env
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--port` | 容器对外端口 | 3000 |
| `--env-file` | 服务器 env 文件路径 | 空 |

## 生成的文件

**`.github/workflows/docker-deploy.yml`** — 两个 Job：

1. **build-and-push**：登录 GHCR → Buildx 构建 → 推送（latest + sha）→ GHA 缓存
2. **deploy**（仅 main）：SSH → 拉取镜像 → 停旧容器 → 启新容器 → 清理

**`Dockerfile`**（如需要）— 自动检测项目类型：

| 项目类型 | 检测依据 | 基础镜像 |
|---------|---------|---------|
| Node.js | `package.json` | `node:20-alpine`（多阶段） |
| Go | `go.mod` | `golang:alpine` → `alpine` |
| Python | `requirements.txt` | `python:3.12-slim` |

## 前置条件

在 GitHub repo Settings → Secrets 中配置：

| Secret | 说明 |
|--------|------|
| `DEPLOY_HOST` | 服务器 IP |
| `DEPLOY_USER` | SSH 用户名 |
| `DEPLOY_PASSWORD` | SSH 密码或私钥 |

服务器需要已安装 Docker 且 SSH 端口开放。
