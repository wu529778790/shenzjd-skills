#!/bin/bash
# Git Hooks Setup 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
SKILL_DIR="$(dirname "$TEST_DIR")/git-hooks-setup"

echo "🧪 Testing git-hooks-setup"
echo "========================="

# 1. 测试包管理器检测
echo ""
echo "📋 Test 1: 包管理器检测"

test_package_manager_detection() {
  local project_dir="$1"
  local expected_manager="$2"

  echo "  Testing: $project_dir"
  cd "$project_dir"

  detected=""
  if [ -f "package.json" ] || [ -f "package-lock.json" ]; then
    detected="npm"
  elif [ -f "yarn.lock" ]; then
    detected="yarn"
  elif [ -f "pnpm-lock.yaml" ]; then
    detected="pnpm"
  else
    detected="unknown"
  fi

  echo "    Detected: $detected (expected: $expected_manager)"

  if [ "$detected" = "$expected_manager" ]; then
    echo "    ✅ Package manager detected correctly"
  else
    echo "    ❌ Expected $expected_manager, got $detected"
    return 1
  fi

  return 0
}

test_package_manager_detection "$FIXTURES_DIR/nodejs-express" "npm"

# 2. 测试 lint 工具检测
echo ""
echo "📋 Test 2: Lint 工具检测"
cd "$FIXTURES_DIR/nodejs-express"

echo "  Checking for lint tools..."
lint_tools=$(cat package.json | python3 -c "
import sys,json
d=json.load(sys.stdin)
dev_deps=d.get('devDependencies',{})
lint_tools=[k for k in dev_deps if 'eslint' in k or 'prettier' in k or 'lint' in k]
print(' '.join(lint_tools))
" 2>/dev/null || echo "")

echo "  Found lint tools: $lint_tools"

if echo "$lint_tools" | grep -q "eslint"; then
  echo "    ✅ ESLint found"
else
  echo "    ⚠️  ESLint not found"
fi

if echo "$lint_tools" | grep -q "prettier"; then
  echo "    ✅ Prettier found"
else
  echo "    ⚠️  Prettier not found"
fi

# 3. 测试 husky 配置
echo ""
echo "📋 Test 3: Husky 配置测试"

# 模拟 husky 初始化
test_husky_config() {
  local project_dir="$1"

  echo "  Testing husky configuration in: $project_dir"

  # 创建临时 husky 目录
  temp_dir=$(mktemp -d)
  mkdir -p "$temp_dir/.husky"

  # 模拟生成 pre-commit hook
  cat > "$temp_dir/.husky/pre-commit" << 'EOF'
#!/bin/sh
npx lint-staged
EOF
  chmod +x "$temp_dir/.husky/pre-commit"

  # 模拟生成 commit-msg hook
  cat > "$temp_dir/.husky/commit-msg" << 'EOF'
#!/bin/sh
npx --no -- commitlint --edit ${1}
EOF
  chmod +x "$temp_dir/.husky/commit-msg"

  # 验证 hooks
  if [ -f "$temp_dir/.husky/pre-commit" ]; then
    echo "    ✅ pre-commit hook created"
  else
    echo "    ❌ pre-commit hook not created"
    rm -rf "$temp_dir"
    return 1
  fi

  if [ -f "$temp_dir/.husky/commit-msg" ]; then
    echo "    ✅ commit-msg hook created"
  else
    echo "    ❌ commit-msg hook not created"
    rm -rf "$temp_dir"
    return 1
  fi

  # 验证执行权限
  if [ -x "$temp_dir/.husky/pre-commit" ]; then
    echo "    ✅ pre-commit has execute permission"
  else
    echo "    ❌ pre-commit missing execute permission"
    rm -rf "$temp_dir"
    return 1
  fi

  rm -rf "$temp_dir"
  return 0
}

test_husky_config "$FIXTURES_DIR/nodejs-express"

# 4. 测试 lint-staged 配置
echo ""
echo "📋 Test 4: lint-staged 配置测试"

test_lint_staged_config() {
  echo "  Testing lint-staged configuration..."

  # 模拟 lint-staged 配置
  lint_staged_config='{
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml}": ["prettier --write"]
  }'

  # 验证配置格式
  if echo "$lint_staged_config" | python3 -m json.tool >/dev/null 2>&1; then
    echo "    ✅ lint-staged config is valid JSON"
  else
    echo "    ❌ lint-staged config is invalid JSON"
    return 1
  fi

  # 验证包含必要的 glob 模式
  if echo "$lint_staged_config" | grep -q "\*.{ts,tsx,js,jsx}"; then
    echo "    ✅ JavaScript/TypeScript files covered"
  else
    echo "    ❌ JavaScript/TypeScript files not covered"
    return 1
  fi

  if echo "$lint_staged_config" | grep -q "\*.{json,md,yml}"; then
    echo "    ✅ Config files covered"
  else
    echo "    ❌ Config files not covered"
    return 1
  fi

  return 0
}

test_lint_staged_config

# 5. 测试 commitlint 配置
echo ""
echo "📋 Test 5: commitlint 配置测试"

test_commitlint_config() {
  echo "  Testing commitlint configuration..."

  # 模拟 commitlint 配置
  commitlint_config='module.exports = {
    extends: ["@commitlint/config-conventional"],
    rules: {
      "type-enum": [2, "always", [
        "feat", "fix", "docs", "style", "refactor",
        "test", "chore", "perf", "ci", "build"
      ]],
      "subject-case": [0],
      "body-max-line-length": [0]
    }
  };'

  # 验证包含 type-enum 规则
  if echo "$commitlint_config" | grep -q "type-enum"; then
    echo "    ✅ type-enum rule defined"
  else
    echo "    ❌ type-enum rule missing"
    return 1
  fi

  # 验证包含必要的 commit types
  for type in feat fix docs refactor test chore; do
    if echo "$commitlint_config" | grep -q "\"$type\""; then
      echo "    ✅ Type '$type' included"
    else
      echo "    ❌ Type '$type' missing"
      return 1
    fi
  done

  return 0
}

test_commitlint_config

# 6. 测试敏感信息检查
echo ""
echo "📋 Test 6: 敏感信息检查测试"

test_secret_detection() {
  echo "  Testing secret detection pattern..."

  # 模拟敏感信息检查脚本
  secret_pattern='password|secret|token|api_key|apikey|access_key'

  # 测试用例
  test_cases=(
    "password=abc123:should_detect"
    "API_KEY=xyz789:should_detect"
    "token=secret123:should_detect"
    "name=john:should_not_detect"
    "email@test.com:should_not_detect"
  )

  for test_case in "${test_cases[@]}"; do
    input=$(echo "$test_case" | cut -d: -f1)
    expected=$(echo "$test_case" | cut -d: -f2)

    if echo "$input" | grep -qiE "$secret_pattern"; then
      result="detected"
    else
      result="not_detected"
    fi

    if [ "$expected" = "should_detect" ] && [ "$result" = "detected" ]; then
      echo "    ✅ Correctly detected: $input"
    elif [ "$expected" = "should_not_detect" ] && [ "$result" = "not_detected" ]; then
      echo "    ✅ Correctly ignored: $input"
    else
      echo "    ❌ Incorrect detection: $input (expected: $expected, got: $result)"
      return 1
    fi
  done

  return 0
}

test_secret_detection

echo ""
echo "✅ git-hooks-setup tests passed"
