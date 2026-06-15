---
name: docker-build-deploy
description: Use when containerizing a Node.js app and setting up GitHub Actions CI/CD to build, push to GHCR, and deploy via SSH. Multi-stage build, non-root user, caching.
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
- User wants to set up continuous deployment pipeline
- User wants to push images to a container registry
- User wants to automate deployment to a remote server via SSH
- User wants to optimize existing Dockerfile with multi-stage builds
- User wants to add health checks to container deployment

**When NOT to Use:**
- User only wants to write a Dockerfile
- User deploys with Kubernetes (different workflow - consider `kubectl` or Helm)
- User doesn't use GitHub Actions (consider GitLab CI, CircleCI, etc.)
- User wants to deploy to AWS ECS/EKS, Google Cloud Run, or Azure Container Instances (different workflows)

## Core Pattern

### Step 1: 收集信息

交互式询问：`port`（容器内端口，默认 3000）、`host_port`（对外暴露端口，默认同 port）、`env_file`（服务器 env 路径，可选）。

智能检测：有 `package.json` → Node.js（当前唯一支持的项目类型）。已有 Dockerfile 则跳过生成。

### Step 2: 生成 Dockerfile（如需要）

生成优化的 Node.js Dockerfile：多阶段构建、非 root 用户、健康检查。模板见 `templates/Dockerfile.nodejs`。

### Step 3: 生成 Workflow

从 `templates/docker-deploy.yml` 生成工作流，替换 `{{PORT}}`（容器端口）、`{{HOST_PORT}}`（对外端口）和 `{{ENV_FILE}}` 变量。

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
| `--port` | 容器内应用端口 | 3000 |
| `--host-port` | 服务器对外暴露端口 | 同 `--port` |
| `--env-file` | 服务器 env 文件路径 | 空 |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 用 `latest` 单 tag | 同时打 `latest` + `${{ github.sha }}` | 方便回滚 |
| 不设置 `packages: write` 权限 | 声明 `permissions: packages: write` | GHCR 推送需要 |
| deploy 不检查容器是否存在 | 先 `docker stop` + `docker rm` | 避免端口冲突 |
| 不清理旧镜像 | 部署后 `docker image prune -f` | 磁盘空间 |
| Dockerfile 用 root 运行 | 添加 `USER node` 或非 root 用户 | 容器安全最佳实践 |
| Secrets 硬编码在 workflow 中 | 使用 `${{ secrets.XXX }}` 引用 | 密钥泄露风险 |
| 不设置 Docker BuildKit 缓存 | 配置 `cache-from` / `cache-to` using GitHub Actions cache | 每次全量构建太慢 |
| 不处理构建失败的回滚 | 部署后验证健康检查 | 失败部署可能上线错误版本 |
| 未指定 `--platform` | 多平台构建时声明 `linux/amd64,linux/arm64` | 目标架构不匹配导致运行失败 |
