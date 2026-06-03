# Diagram Generator

从自然语言描述生成架构图、流程图、时序图，支持 Mermaid 和 Excalidraw 格式。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s diagram-generator -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/diagram-generator ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/diagram-generator                         # 交互式
/diagram-generator --type flowchart        # 指定类型
/diagram-generator --format excalidraw     # Excalidraw 格式
/diagram-generator --render                # 自动渲染 PNG
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--type` | flowchart / sequence / er / state / class / gantt | 自动检测 |
| `--format` | mermaid / excalidraw | mermaid |
| `--output` | 输出目录 | `./` |
| `--render` | 渲染为 PNG | false |

## 支持的图表类型

| 类型 | 用途 | 关键词 |
|------|------|--------|
| flowchart | 流程图 | 流程、步骤、判断、条件 |
| sequence | 时序图 | 调用、请求、响应、交互 |
| er | ER 图 | 表、关系、外键、数据库 |
| state | 状态图 | 状态、生命周期、转换 |
| class | 类图 | 类、继承、接口、实现 |
| gantt | 甘特图 | 排期、计划、里程碑 |

## 输出格式

| 格式 | 扩展名 | 渲染方式 |
|------|--------|---------|
| Mermaid | `.mmd` | GitHub / Notion / Typora / VS Code |
| Excalidraw | `.excalidraw` | excalidraw.com |
