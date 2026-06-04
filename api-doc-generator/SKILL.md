---
name: api-doc-generator
description: Generate OpenAPI/Swagger API docs from code. Scans routes, extracts params/responses, outputs YAML/JSON specs.
---

# API Doc Generator

从代码自动生成 API 文档，支持 OpenAPI/Swagger 规范。

## Overview

扫描项目代码中的路由和接口定义，自动提取参数、返回值、注释，生成符合 OpenAPI 3.0 规范的 YAML 文件和可交互的文档页面。

## When to Use

- User wants to generate API documentation
- User mentions OpenAPI, Swagger, or API docs
- User has REST/GraphQL endpoints that need documentation
- User says "生成 API 文档" / "create API docs"
- User inputs `/api-doc-generator`

**When NOT to Use:**
- User only wants to write API descriptions in README
- User wants to test APIs (use testing tools)
- User's project has no HTTP endpoints
- User wants to generate SDK/client code
- User wants to mock APIs (use Mockoon, WireMock)

## Core Pattern

### Step 1: 检测框架和路由

| 框架 | 检测方式 | 路由提取 |
|------|---------|---------|
| Express/Koa/Fastify | `require('express')` / 路由文件 | 扫描 `app.get/post/put/delete` |
| Next.js API Routes | `app/api/` 目录 | 扫描 `route.ts` 文件 |
| Gin (Go) | `r.GET/POST` | 扫描 `router` 注册 |
| Flask/FastAPI (Python) | `@app.route` / `@router` | 扫描装饰器 |
| Spring Boot (Java) | `@GetMapping` / `@RestController` | 扫描注解 |

```bash
# 快速检测
grep -rE "app\.(get|post|put|delete|patch)" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" -l
```

### Step 2: 提取接口信息

对每个路由提取：
- **HTTP Method + Path**
- **请求参数**：query、params、body（从类型定义/JSDoc/注解推断）
- **响应格式**：从 return 语句或类型定义推断
- **注释/描述**：从代码注释提取
- **认证要求**：检查是否有 auth middleware

### Step 3: 生成 OpenAPI YAML

使用 `templates/openapi.yaml` 作为基础结构，填充提取的信息：

```yaml
openapi: 3.0.3
info:
  title: 项目名 API
  version: 1.0.0
paths:
  /api/users:
    get:
      summary: 获取用户列表
      parameters: [...]
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

### Step 4: 生成交互式文档页面（可选）

使用 Swagger UI 或 Redoc 生成可浏览的 HTML 页面：

```bash
# 使用 npx 快速预览
npx @redocly/cli preview-docs openapi.yaml
```

## Quick Reference

```bash
/api-doc-generator                    # 扫描当前项目，生成 openapi.yaml
/api-doc-generator --format yaml      # 输出 YAML（默认）
/api-doc-generator --format json      # 输出 JSON
/api-doc-generator --preview          # 生成并预览交互式文档
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--format` | 输出格式 yaml / json | yaml |
| `--preview` | 生成交互式 HTML 文档 | false |
| `--output` | 输出路径 | `./docs/openapi.yaml` |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 只扫描一个文件 | 递归扫描所有路由文件 | 可能遗漏接口 |
| 硬编码请求体结构 | 从类型定义推断 | 保持文档与代码一致 |
| 不处理嵌套路由 | 分析路由注册的完整路径 | `/api/users/:id` 的 `:id` 需要标注 |
| 忽略错误响应 | 添加 4xx/5xx 响应 | 完整的 API 文档需要错误说明 |
| 忽略认证要求 | 检查 auth middleware | 客户端需要知道哪些接口需要认证 |
