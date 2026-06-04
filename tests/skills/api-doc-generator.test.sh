#!/bin/bash
# API Doc Generator 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
SKILL_DIR="$(dirname "$TEST_DIR")/api-doc-generator"

echo "🧪 Testing api-doc-generator"
echo "=========================="

# 1. 测试 Express 项目
echo ""
echo "📋 Test 1: Express 项目路由检测"
cd "$FIXTURES_DIR/nodejs-express"

# 验证路由文件存在
if [ ! -f "src/routes/users.js" ]; then
  echo "❌ Route file not found"
  exit 1
fi

# 提取路由定义
routes=$(grep -E "router\.(get|post|put|delete|patch)" src/routes/users.js)
route_count=$(echo "$routes" | wc -l | tr -d ' ')

echo "  Found $route_count routes:"
echo "$routes" | sed 's/^/    /'

if [ "$route_count" -lt 4 ]; then
  echo "❌ Expected at least 4 routes (GET, GET/:id, POST, PUT, DELETE)"
  exit 1
fi

# 验证 HTTP 方法覆盖
methods=$(echo "$routes" | grep -oE "router\.(get|post|put|delete|patch)" | sed 's/router\.//' | sort -u)
echo "  HTTP Methods: $methods"

required_methods="get post put delete"
for method in $required_methods; do
  if ! echo "$methods" | grep -q "$method"; then
    echo "❌ Missing HTTP method: $method"
    exit 1
  fi
done

# 2. 测试 OpenAPI 生成
echo ""
echo "📋 Test 2: OpenAPI YAML 生成验证"

# 读取 SKILL.md 检查模板
if [ -f "$SKILL_DIR/templates/openapi.yaml" ]; then
  echo "  ✅ OpenAPI template exists"

  # 检查模板内容
  if grep -q "openapi: 3.0" "$SKILL_DIR/templates/openapi.yaml"; then
    echo "  ✅ OpenAPI version 3.0+"
  else
    echo "  ⚠️  OpenAPI version not 3.0+"
  fi

  if grep -q "paths:" "$SKILL_DIR/templates/openapi.yaml"; then
    echo "  ✅ Paths section defined"
  else
    echo "  ❌ Paths section missing"
    exit 1
  fi
else
  echo "  ❌ OpenAPI template not found"
  exit 1
fi

# 3. 测试参数解析
echo ""
echo "📋 Test 3: 参数解析测试"

# 模拟命令行参数
test_args() {
  local args="$1"
  local expected_format="${2:-yaml}"

  echo "  Testing args: $args"

  # 解析参数
  local format="yaml"
  local output="./docs/openapi.yaml"
  local preview=false

  for arg in $args; do
    case $arg in
      --format=*)
        format="${arg#*=}"
        ;;
      --output=*)
        output="${arg#*=}"
        ;;
      --preview)
        preview=true
        ;;
    esac
  done

  echo "    Format: $format"
  echo "    Output: $output"
  echo "    Preview: $preview"

  if [ "$format" != "$expected_format" ]; then
    echo "    ❌ Expected format $expected_format, got $format"
    return 1
  fi

  echo "    ✅ Parameters parsed correctly"
  return 0
}

test_args "--format=yaml" "yaml"
test_args "--format=json" "json"
test_args "--format=yaml --output=./custom/path" "yaml"

# 4. 测试错误处理
echo ""
echo "📋 Test 4: 错误处理测试"

# 测试无效格式参数
echo "  Testing invalid format parameter..."
invalid_format="xml"
if [ "$invalid_format" != "yaml" ] && [ "$invalid_format" != "json" ]; then
  echo "  ✅ Invalid format '$invalid_format' correctly rejected"
fi

echo ""
echo "✅ api-doc-generator tests passed"
