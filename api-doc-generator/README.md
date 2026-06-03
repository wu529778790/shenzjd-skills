# API Doc Generator

从代码自动生成 API 文档，支持 OpenAPI/Swagger 规范。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s api-doc-generator -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/api-doc-generator ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/api-doc-generator                    # 扫描项目，生成 openapi.yaml
/api-doc-generator --format json      # 输出 JSON 格式
/api-doc-generator --preview          # 生成并预览交互式文档
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--format` | 输出格式 yaml / json | yaml |
| `--preview` | 生成交互式 HTML 文档 | false |
| `--output` | 输出路径 | `./docs/openapi.yaml` |

## 支持的框架

| 框架 | 语言 |
|------|------|
| Express / Koa / Fastify | Node.js |
| Next.js API Routes | TypeScript |
| Gin | Go |
| Flask / FastAPI | Python |
| Spring Boot | Java |

## 输出

| 文件 | 说明 |
|------|------|
| `openapi.yaml` | OpenAPI 3.0 规范文件 |
| `docs/api.html` | 交互式文档页面（--preview） |
