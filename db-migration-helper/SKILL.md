---
name: db-migration-helper
description: Generate database migration SQL from model changes. Compares schema, detects diffs, outputs safe migrations.
---

# DB Migration Helper

分析 model 变更，生成安全的数据库迁移 SQL。

## Overview

对比代码中的实体/模型定义与当前数据库 schema，检测结构变更（新增表、增删列、改类型），生成向前兼容的迁移 SQL。支持 MySQL、PostgreSQL、SQLite。

## When to Use

- User wants to create database migrations
- User modified model/entity definitions
- User mentions migration, schema change, or sync
- User says "生成迁移" / "create migration"
- User inputs `/db-migration-helper`

**When NOT to Use:**
- User only wants to view database structure
- User wants data migration (not schema)
- User uses ORM auto-migration
- User wants to generate seed data
- User wants to backup/restore database

## Core Pattern

### Step 1: 检测项目类型和 ORM

| 检测文件 | ORM/框架 | 迁移方式 |
|---------|---------|---------|
| `prisma/schema.prisma` | Prisma | 生成 SQL diff |
| `alembic/` | SQLAlchemy + Alembic | 生成 Alembic migration |
| `migrations/` | 通用 | 扫描已有迁移推断 |
| `*.entity.ts` / `*.model.ts` | TypeORM / Sequelize | 从装饰器提取 |
| `schema.rb` / `db/migrate/` | Rails | Rails migration |

### Step 2: 提取当前 Schema

```bash
# Prisma (v5+)
npx prisma db pull 2>/dev/null

# Prisma (v4 及更早)
npx prisma introspect 2>/dev/null

# 通用 — 从代码提取
grep -r "CREATE TABLE\|@Entity\|@Table\|model " --include="*.ts" --include="*.py" --include="*.go" -l
```

提取：
- 表名和列定义
- 列类型、约束（NOT NULL、DEFAULT、UNIQUE）
- 索引和外键

### Step 3: 对比变更

对比代码中的 model 定义与已有 schema（或上一次迁移），检测：

| 变更类型 | 风险等级 | 说明 |
|---------|---------|------|
| 新增表 | 低 | 直接 CREATE TABLE |
| 新增列（有 DEFAULT） | 低 | ALTER TABLE ADD COLUMN |
| 新增列（无 DEFAULT） | 中 | 需要处理已有数据 |
| 删除列 | 高 | 可能丢失数据，需要确认 |
| 修改列类型 | 高 | 可能不兼容 |
| 新增索引 | 低 | CREATE INDEX |
| 删除索引 | 低 | DROP INDEX |

### Step 4: 生成迁移文件

使用 `templates/migration.sql` 模板，生成：

1. **Up 迁移** — 正向变更 SQL
2. **Down 回滚** — 反向回滚 SQL
3. **风险评估** — 标注高风险操作

```sql
-- Migration: 20260603_add_user_avatar
-- Risk: LOW

-- Up
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);
CREATE INDEX idx_users_email ON users(email);

-- Down
DROP INDEX idx_users_email;
ALTER TABLE users DROP COLUMN avatar_url;
```

## Quick Reference

```bash
/db-migration-helper                    # 检测变更，生成迁移
/db-migration-helper --dry-run          # 只预览 SQL 不执行
/db-migration-helper --name add_user    # 指定迁移名称
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--dry-run` | 只预览不执行 | false |
| `--name` | 迁移文件名 | 自动生成 |
| `--output` | 输出目录 | `./migrations/` |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 不生成 down 回滚 | 始终生成回滚 SQL | 出问题需要回退 |
| 删除列不备份 | 先备份数据再删列 | 数据丢失不可恢复 |
| 改类型用 ALTER COLUMN | 创建新列 → 迁移数据 → 删旧列 | 直接改类型可能丢数据 |
| 不加索引 | 为查询字段加索引 | 影响查询性能 |
| 迁移文件没有名字 | 用描述性命名 | 方便团队协作和回溯 |
| 不检查外键依赖 | 先检查表间关系 | 删除被引用的列会失败 |
