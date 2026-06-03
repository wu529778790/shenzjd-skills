# DB Migration Helper

分析 model 变更，生成安全的数据库迁移 SQL。

## 安装

```bash
# npx skills（推荐）
npx skills add wu529778790/shenzjd-skills -s db-migration-helper -y

# 手动（Claude Code）
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/db-migration-helper ~/.claude/skills/

# 手动（Cursor）
# 将 SKILL.md 内容复制到 .cursorrules 或 .cursor/rules/
```

## 使用

```bash
/db-migration-helper                    # 检测变更，生成迁移
/db-migration-helper --dry-run          # 只预览 SQL
/db-migration-helper --name add_user    # 指定迁移名称
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--dry-run` | 只预览不执行 | false |
| `--name` | 迁移文件名 | 自动生成 |
| `--output` | 输出目录 | `./migrations/` |

## 支持的数据库

| 数据库 | 支持程度 |
|--------|---------|
| PostgreSQL | 完整支持 |
| MySQL | 完整支持 |
| SQLite | 基础支持 |

## 输出

每个迁移包含：
- **Up SQL** — 正向变更
- **Down SQL** — 回滚语句
- **风险评估** — 标注高风险操作（删列、改类型）
