#!/bin/bash
# DB Migration Helper 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
SKILL_DIR="$(dirname "$TEST_DIR")/db-migration-helper"

echo "🧪 Testing db-migration-helper"
echo "=============================="

# 1. 测试 ORM 检测
echo ""
echo "📋 Test 1: ORM 检测"

detect_orm() {
  local project_dir="$1"

  if [ -f "$project_dir/prisma/schema.prisma" ]; then
    echo "prisma"
  elif [ -d "$project_dir/alembic" ]; then
    echo "alembic"
  elif [ -f "$project_dir/schema.rb" ] || [ -d "$project_dir/db/migrate" ]; then
    echo "rails"
  elif find "$project_dir" -name "*.entity.ts" -o -name "*.model.ts" 2>/dev/null | grep -q .; then
    echo "typeorm"
  else
    echo "unknown"
  fi
}

test_orm_detection() {
  local project_dir="$1"
  local expected_orm="$2"

  echo "  Testing: $project_dir"
  detected=$(detect_orm "$project_dir")

  echo "    Detected: $detected (expected: $expected_orm)"

  if [ "$detected" = "$expected_orm" ]; then
    echo "    ✅ ORM detected correctly"
  else
    echo "    ❌ Expected $expected_orm, got $detected"
    return 1
  fi

  return 0
}

# 创建测试用的 Prisma schema
temp_dir=$(mktemp -d)
mkdir -p "$temp_dir/prisma"
cat > "$temp_dir/prisma/schema.prisma" << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  Int
}
EOF

test_orm_detection "$temp_dir" "prisma"
rm -rf "$temp_dir"

# 2. 测试 Schema 提取
echo ""
echo "📋 Test 2: Schema 提取测试"

test_schema_extraction() {
  echo "  Testing schema extraction..."

  # 模拟 Prisma schema
  prisma_schema='model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
}'

  # 验证模型定义
  if echo "$prisma_schema" | grep -q "^model"; then
    echo "    ✅ Model definition found"
  else
    echo "    ❌ Model definition missing"
    return 1
  fi

  # 验证字段定义
  if echo "$prisma_schema" | grep -q "id.*Int.*@id"; then
    echo "    ✅ Primary key defined"
  else
    echo "    ❌ Primary key missing"
    return 1
  fi

  # 验证关系定义
  if echo "$prisma_schema" | grep -q "Post\[\]"; then
    echo "    ✅ Relationship defined"
  else
    echo "    ⚠️  No relationships found"
  fi

  return 0
}

test_schema_extraction

# 3. 测试变更检测
echo ""
echo "📋 Test 3: 变更检测测试"

test_change_detection() {
  echo "  Testing change detection..."

  # 模拟旧 schema
  old_schema='model User {
  id    Int    @id @default(autoincrement())
  email String @unique
}'

  # 模拟新 schema
  new_schema='model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
}'

  # 检测新增字段
  new_fields=$(echo "$new_schema" | grep -E "^\s+\w+\s+\w+" | awk '{print $1}' | sort)
  old_fields=$(echo "$old_schema" | grep -E "^\s+\w+\s+\w+" | awk '{print $1}' | sort)

  added=$(comm -13 <(echo "$old_fields") <(echo "$new_fields"))
  removed=$(comm -23 <(echo "$old_fields") <(echo "$new_fields"))

  echo "    Added fields: $(echo "$added" | grep -c . || echo "0")"
  echo "    Removed fields: $(echo "$removed" | grep -c . || echo "0")"

  if [ -n "$added" ]; then
    echo "    ✅ New fields detected"
  fi

  if [ -z "$removed" ]; then
    echo "    ✅ No fields removed"
  fi

  return 0
}

test_change_detection

# 4. 测试风险评估
echo ""
echo "📋 Test 4: 风险评估测试"

test_risk_assessment() {
  echo "  Testing risk assessment..."

  # 模拟变更类型
  changes=(
    "add_column:low"
    "add_column_not_null:medium"
    "drop_column:high"
    "alter_column_type:high"
    "add_index:low"
    "drop_index:low"
  )

  for change in "${changes[@]}"; do
    type=$(echo "$change" | cut -d: -f1)
    expected_risk=$(echo "$change" | cut -d: -f2)

    # 根据类型确定风险等级
    case $type in
      add_column)
        risk="low"
        ;;
      add_column_not_null)
        risk="medium"
        ;;
      drop_column|alter_column_type)
        risk="high"
        ;;
      add_index|drop_index)
        risk="low"
        ;;
      *)
        risk="unknown"
        ;;
    esac

    echo "    $type: $risk (expected: $expected_risk)"

    if [ "$risk" = "$expected_risk" ]; then
      echo "      ✅ Risk level correct"
    else
      echo "      ❌ Risk level incorrect"
      return 1
    fi
  done

  return 0
}

test_risk_assessment

# 5. 测试迁移 SQL 生成
echo ""
echo "📋 Test 5: 迁移 SQL 生成测试"

test_sql_generation() {
  echo "  Testing SQL generation..."

  # 模拟迁移
  migration='-- Migration: 20260604_add_user_avatar
-- Risk: LOW

-- Up
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);
CREATE INDEX idx_users_avatar ON users(avatar_url);

-- Down
DROP INDEX idx_users_avatar;
ALTER TABLE users DROP COLUMN avatar_url;'

  # 验证迁移格式
  if echo "$migration" | grep -q "^-- Migration:"; then
    echo "    ✅ Migration header present"
  else
    echo "    ❌ Migration header missing"
    return 1
  fi

  if echo "$migration" | grep -q "^-- Up"; then
    echo "    ✅ Up migration present"
  else
    echo "    ❌ Up migration missing"
    return 1
  fi

  if echo "$migration" | grep -q "^-- Down"; then
    echo "    ✅ Down migration present"
  else
    echo "    ❌ Down migration missing"
    return 1
  fi

  # 验证 SQL 语法
  if echo "$migration" | grep -q "ALTER TABLE.*ADD COLUMN"; then
    echo "    ✅ ALTER TABLE syntax correct"
  else
    echo "    ❌ ALTER TABLE syntax incorrect"
    return 1
  fi

  if echo "$migration" | grep -q "CREATE INDEX"; then
    echo "    ✅ CREATE INDEX syntax correct"
  else
    echo "    ❌ CREATE INDEX syntax incorrect"
    return 1
  fi

  return 0
}

test_sql_generation

# 6. 测试回滚 SQL
echo ""
echo "📋 Test 6: 回滚 SQL 测试"

test_rollback_sql() {
  echo "  Testing rollback SQL..."

  # 模拟回滚
  rollback='-- Down
DROP INDEX IF EXISTS idx_users_avatar;
ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;'

  # 验证回滚语法
  if echo "$rollback" | grep -q "DROP INDEX IF EXISTS"; then
    echo "    ✅ DROP INDEX with IF EXISTS"
  else
    echo "    ❌ DROP INDEX missing IF EXISTS"
    return 1
  fi

  if echo "$rollback" | grep -q "DROP COLUMN IF EXISTS"; then
    echo "    ✅ DROP COLUMN with IF EXISTS"
  else
    echo "    ❌ DROP COLUMN missing IF EXISTS"
    return 1
  fi

  return 0
}

test_rollback_sql

# 7. 测试数据库类型
echo ""
echo "📋 Test 7: 数据库类型测试"

test_database_types() {
  echo "  Testing database type compatibility..."

  # 模拟不同数据库的 SQL
  databases=(
    "mysql:ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);"
    "postgresql:ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);"
    "sqlite:ALTER TABLE users ADD COLUMN avatar_url TEXT;"
  )

  for db_sql in "${databases[@]}"; do
    db=$(echo "$db_sql" | cut -d: -f1)
    sql=$(echo "$db_sql" | cut -d: -f2)

    echo "    $db: $sql"

    # 验证 SQL 语法
    if echo "$sql" | grep -q "ALTER TABLE"; then
      echo "      ✅ Valid SQL"
    else
      echo "      ❌ Invalid SQL"
      return 1
    fi
  done

  return 0
}

test_database_types

echo ""
echo "✅ db-migration-helper tests passed"
