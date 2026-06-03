# Performance Profiler

一键分析项目性能瓶颈，输出优先级排序的优化建议。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s performance-profiler -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/performance-profiler ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/performance-profiler              # 分析当前项目
/performance-profiler --fix        # 分析并自动修复
/performance-profiler --json       # JSON 格式输出
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--fix` | 自动修复可安全修复的问题 | false |
| `--json` | 输出 JSON 格式报告 | false |

## 分析维度

| 维度 | 检测内容 |
|------|---------|
| 依赖健康 | 冗余依赖、重复依赖、过时依赖 |
| Bundle 体积 | 大文件、未 tree-shake 的导入 |
| 代码模式 | barrel file、import *、同步 I/O |
| 配置优化 | 构建工具配置、缓存策略 |

## 支持的项目类型

| 类型 | 检测依据 |
|------|---------|
| Node.js / 前端 | `package.json` |
| Go | `go.mod` |
| Python | `requirements.txt` / `pyproject.toml` |
| Rust | `Cargo.toml` |
