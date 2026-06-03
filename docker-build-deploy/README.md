# 🐳 Docker Build & Deploy

一键生成 Docker 构建 + 推送到 GHCR + 部署到服务器的 GitHub Actions 工作流。

## 功能特性

- ✅ 自动检测项目类型，生成优化 Dockerfile（多阶段构建、非 root、健康检查）
- ✅ 推送到 GHCR（GitHub Container Registry）
- ✅ 部署到服务器（SSH 拉取 → 停旧容器 → 启新容器 → 清理）
- ✅ 支持 env 文件注入
- ✅ GHA 缓存加速构建

## 🚀 安装

### 方式一：npx skills（推荐）

```bash
# 安装到 Claude Code
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y -a claude-code

# 安装到 Cursor
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y -a cursor

# 安装到所有已检测的 AI 工具
npx skills add wu529778790/shenzjd-skills -s docker-build-deploy -y
```

### 方式二：手动安装

**Claude Code：**
```bash
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/docker-build-deploy ~/.claude/skills/
# 重启 Claude Code 生效
```

**Cursor：**
将 `SKILL.md` 的内容复制到 `.cursorrules` 或 `.cursor/rules/`。

**GitHub Copilot：**
将 `SKILL.md` 的内容复制到 `.github/copilot-instructions.md`。

**其他工具：**
`SKILL.md` 是通用指令文档，粘贴到你所用工具的 system prompt 或规则文件即可。

## 📖 使用方式

```bash
# 交互式生成（会询问端口、env 文件等）
/docker-build-deploy

# 指定端口
/docker-build-deploy --port 8080

# 指定端口 + env 文件
/docker-build-deploy --port 8080 --env-file /opt/app/.env
```

### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--port` | 容器对外端口 | `3000` |
| `--env-file` | 服务器上的 env 文件路径 | 空（不使用） |

## 生成的文件

### `.github/workflows/docker-deploy.yml`

生成的 GitHub Actions 工作流包含两个 Job：

**Job 1: build-and-push**
- 登录 GHCR（使用 `GITHUB_TOKEN`）
- 用 Docker Buildx 构建镜像
- 推送到 `ghcr.io/{owner}/{repo}`
- 打两个 tag：`latest` + commit SHA
- 使用 GHA 缓存加速后续构建

**Job 2: deploy**（仅 main 分支触发）
- SSH 连接服务器
- 拉取最新镜像
- 停止并移除旧容器
- 用新镜像启动容器（支持 env 文件注入）
- 清理旧镜像

### `Dockerfile`（如需要）

自动检测项目类型并生成优化的 Dockerfile：

| 项目类型 | 检测依据 | Dockerfile 模板 |
|---------|---------|----------------|
| Node.js | `package.json` | 多阶段构建，`node:20-alpine` |
| Go | `go.mod` | 多阶段构建，`golang:alpine` → `alpine` |
| Python | `requirements.txt` / `pyproject.toml` | `python:3.12-slim` |

Dockerfile 特性：
- 多阶段构建（减小最终镜像体积）
- 非 root 用户运行（安全性）
- 健康检查端点

## 🔧 前置条件

### GitHub Secrets

在 repo 的 Settings → Secrets and variables → Actions 中配置：

| Secret | 说明 | 示例 |
|--------|------|------|
| `DEPLOY_HOST` | 服务器 IP 或域名 | `123.45.67.89` |
| `DEPLOY_USER` | SSH 用户名 | `root` |
| `DEPLOY_PASSWORD` | SSH 密码或私钥 | `***` |

### 服务器要求

- 已安装 Docker
- SSH 端口开放
- `GITHUB_TOKEN` 有 `packages:write` 权限（默认已有）

## 📁 模板文件

| 文件 | 说明 |
|------|------|
| `templates/docker-deploy.yml` | GitHub Actions 工作流模板 |
| `templates/Dockerfile.nodejs` | Node.js Dockerfile 模板（多阶段 + 非 root + 健康检查） |

## ⚠️ 注意事项

- deploy job 会自动 `docker stop` + `docker rm` 旧容器，确保没有其他容器占用同一端口
- env 文件路径是服务器上的绝对路径，不是仓库中的路径
- 部署后会自动执行 `docker image prune -f` 清理旧镜像
