---
name: docker-build-deploy
description: Use when user wants to containerize a project, set up Docker CI/CD with GitHub Actions, push images to GHCR or Docker Hub, deploy containers to a remote server, or generate optimized Dockerfiles
---

# Docker Build & Deploy

一键生成 Docker 构建 + 推送到 GHCR + 部署到服务器的 GitHub Actions 工作流。

## Overview

自动生成完整的 Docker CI/CD 工作流：构建镜像 → 推送到 GHCR → SSH 部署到服务器。包含优化的 Dockerfile（多阶段构建、非 root、健康检查）和 GitHub Actions 工作流模板。

## When to Use

- User wants to containerize a project and deploy it
- User needs GitHub Actions to automatically build Docker images
- User mentions Docker, GHCR, container deployment, or CI/CD
- User inputs `/docker-build-deploy`

**When NOT to Use:**
- User only wants to write a Dockerfile
- User deploys with Kubernetes (different workflow)
- User doesn't use GitHub Actions

## Core Pattern

### Step 1: 收集信息

交互式询问：`port`（默认 3000）、`env_file`（服务器 env 路径，可选）、项目类型。

智能检测：有 `package.json` → Node.js，有 `go.mod` → Go，有 `requirements.txt` → Python。已有 Dockerfile 则跳过生成。

### Step 2: 生成 Dockerfile（如需要）

根据项目类型生成优化的 Dockerfile：多阶段构建、非 root 用户、健康检查。模板见 `templates/Dockerfile.nodejs`。

### Step 3: 生成 Workflow

从 `templates/docker-deploy.yml` 生成工作流，替换 `{{PORT}}` 和 `{{ENV_FILE}}` 变量。

**build-and-push job：** 登录 GHCR → Buildx 构建 → 推送（tag: latest + sha）→ GHA 缓存

**deploy job：** SSH 连接 → 拉取镜像 → 停旧容器 → 启新容器（支持 env 文件）→ 清理旧镜像

### Step 4: 提示配置 Secrets

告知用户需在 GitHub Settings → Secrets 配置：`DEPLOY_HOST`、`DEPLOY_USER`、`DEPLOY_PASSWORD`。

## Quick Reference

```bash
/docker-build-deploy
/docker-build-deploy --port 8080
/docker-build-deploy --port 8080 --env-file /opt/app/.env
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--port` | 容器对外端口 | 3000 |
| `--env-file` | 服务器 env 文件路径 | 空 |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 用 `latest` 单 tag | 同时打 `latest` + `${{ github.sha }}` | 方便回滚 |
| 不设置 `packages: write` 权限 | 声明 `permissions: packages: write` | GHCR 推送需要 |
| deploy 不检查容器是否存在 | 先 `docker stop` + `docker rm` | 避免端口冲突 |
| 不清理旧镜像 | 部署后 `docker image prune -f` | 磁盘空间 |
