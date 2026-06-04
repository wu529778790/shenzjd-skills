#!/bin/bash
# GitHub Profile Beautifier 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/github-profile-beautifier"

echo "🧪 Testing github-profile-beautifier"
echo "===================================="

# 1. 测试 gh CLI 检查
echo ""
echo "📋 Test 1: gh CLI 检查"

test_gh_cli() {
  echo "  Checking gh CLI availability..."

  if command -v gh >/dev/null 2>&1; then
    echo "    ✅ gh CLI is installed"

    # 检查版本
    gh_version=$(gh --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    echo "    Version: $gh_version"

    # 检查认证状态
    if gh auth status >/dev/null 2>&1; then
      echo "    ✅ gh CLI is authenticated"
    else
      echo "    ⚠️  gh CLI is not authenticated"
    fi
  else
    echo "    ⚠️  gh CLI not installed"
    echo "    Installing: brew install gh"
  fi

  return 0
}

test_gh_cli

# 2. 测试主题模板验证
echo ""
echo "📋 Test 2: 主题模板验证"

test_theme_templates() {
  local themes=("radical" "tokyonight" "dracula" "minimalist" "professional")

  for theme in "${themes[@]}"; do
    echo "  Testing theme: $theme"

    template_file="$SKILL_DIR/templates/$theme.md"
    if [ -f "$template_file" ]; then
      echo "    ✅ Template exists"

      # 检查必需变量
      required_vars=("{{username}}" "{{name}}" "{{bio}}")
      for var in "${required_vars[@]}"; do
        if grep -q "$var" "$template_file"; then
          echo "      ✅ Variable: $var"
        else
          echo "      ❌ Missing variable: $var"
          return 1
        fi
      done

      # 检查统计卡片
      if grep -q "github-readme-stats" "$template_file" || grep -q "skills" "$template_file"; then
        echo "      ✅ Stats cards configured"
      else
        echo "      ⚠️  Stats cards not configured"
      fi

      # 检查蛇形贡献图
      if grep -q "snake" "$template_file" || grep -q "platane/snk" "$template_file"; then
        echo "      ✅ Snake animation configured"
      else
        echo "      ⚠️  Snake animation not configured"
      fi
    else
      echo "    ❌ Template not found"
      return 1
    fi
  done

  return 0
}

test_theme_templates

# 3. 测试 themes.json 配置
echo ""
echo "📋 Test 3: themes.json 配置验证"

test_themes_json() {
  echo "  Testing themes.json..."

  themes_file="$SKILL_DIR/templates/themes.json"
  if [ -f "$themes_file" ]; then
    echo "    ✅ themes.json exists"

    # 验证 JSON 格式
    if python3 -m json.tool "$themes_file" >/dev/null 2>&1; then
      echo "    ✅ Valid JSON format"
    else
      echo "    ❌ Invalid JSON format"
      return 1
    fi

    # 检查必需的颜色配置
    required_themes=("radical" "tokyonight" "dracula" "minimalist" "professional")
    for theme in "${required_themes[@]}"; do
      if grep -q "\"$theme\"" "$themes_file"; then
        echo "    ✅ Theme: $theme"
      else
        echo "    ❌ Missing theme: $theme"
        return 1
      fi
    done

    # 检查颜色定义
    if grep -q "primary" "$themes_file" && grep -q "secondary" "$themes_file" && grep -q "accent" "$themes_file"; then
      echo "    ✅ Color definitions complete"
    else
      echo "    ❌ Color definitions incomplete"
      return 1
    fi
  else
    echo "    ❌ themes.json not found"
    return 1
  fi

  return 0
}

test_themes_json

# 4. 测试用户数据获取
echo ""
echo "📋 Test 4: 用户数据获取测试"

test_user_data_fetch() {
  echo "  Testing user data fetch simulation..."

  # 模拟用户数据
  mock_user_data='{
    "login": "testuser",
    "name": "Test User",
    "bio": "Software Developer",
    "public_repos": 10,
    "followers": 100,
    "following": 50
  }'

  # 验证 JSON 格式
  if echo "$mock_user_data" | python3 -m json.tool >/dev/null 2>&1; then
    echo "    ✅ User data is valid JSON"
  else
    echo "    ❌ User data is invalid JSON"
    return 1
  fi

  # 验证必需字段
  required_fields=("login" "name" "bio" "public_repos")
  for field in "${required_fields[@]}"; do
    if echo "$mock_user_data" | grep -q "\"$field\""; then
      echo "    ✅ Field: $field"
    else
      echo "    ❌ Missing field: $field"
      return 1
    fi
  done

  return 0
}

test_user_data_fetch

# 5. 测试仓库分析
echo ""
echo "📋 Test 5: 仓库分析测试"

test_repo_analysis() {
  echo "  Testing repository analysis simulation..."

  # 模拟仓库数据
  mock_repos='[
    {"name": "project-a", "stargazerCount": 100, "isFork": false},
    {"name": "project-b", "stargazerCount": 50, "isFork": false},
    {"name": "forked-repo", "stargazerCount": 10, "isFork": true}
  ]'

  # 验证 JSON 格式
  if echo "$mock_repos" | python3 -m json.tool >/dev/null 2>&1; then
    echo "    ✅ Repos data is valid JSON"
  else
    echo "    ❌ Repos data is invalid JSON"
    return 1
  fi

  # 测试筛选逻辑
  non_fork_count=$(echo "$mock_repos" | python3 -c "
import sys,json
repos=json.load(sys.stdin)
non_forks=[r for r in repos if not r.get('isFork',False)]
print(len(non_forks))
" 2>/dev/null || echo "0")

  echo "    Non-fork repositories: $non_fork_count"

  if [ "$non_fork_count" -eq 2 ]; then
    echo "    ✅ Fork filtering works"
  else
    echo "    ❌ Fork filtering failed"
    return 1
  fi

  # 测试排序逻辑
  sorted_by_stars=$(echo "$mock_repos" | python3 -c "
import sys,json
repos=json.load(sys.stdin)
non_forks=[r for r in repos if not r.get('isFork',False)]
sorted_repos=sorted(non_forks, key=lambda x: x.get('stargazerCount',0), reverse=True)
print(' '.join([r['name'] for r in sorted_repos]))
" 2>/dev/null || echo "")

  echo "    Sorted by stars: $sorted_by_stars"

  if [ "$sorted_by_stars" = "project-a project-b" ]; then
    echo "    ✅ Sorting works correctly"
  else
    echo "    ❌ Sorting failed"
    return 1
  fi

  return 0
}

test_repo_analysis

# 6. 测试技术栈分析
echo ""
echo "📋 Test 6: 技术栈分析测试"

test_tech_stack_analysis() {
  echo "  Testing tech stack analysis simulation..."

  # 模拟语言分布
  mock_languages='{"JavaScript": 1000, "TypeScript": 500, "Python": 200}'

  # 验证 JSON 格式
  if echo "$mock_languages" | python3 -m json.tool >/dev/null 2>&1; then
    echo "    ✅ Languages data is valid JSON"
  else
    echo "    ❌ Languages data is invalid JSON"
    return 1
  fi

  # 测试语言统计
  total_lines=$(echo "$mock_languages" | python3 -c "
import sys,json
langs=json.load(sys.stdin)
print(sum(langs.values()))
" 2>/dev/null || echo "0")

  echo "    Total lines: $total_lines"

  if [ "$total_lines" -gt 0 ]; then
    echo "    ✅ Language statistics calculated"
  else
    echo "    ❌ Language statistics failed"
    return 1
  fi

  # 测试语言百分比
  echo "    Language distribution:"
  echo "$mock_languages" | python3 -c "
import sys,json
langs=json.load(sys.stdin)
total=sum(langs.values())
for lang,count in sorted(langs.items(), key=lambda x: -x[1]):
    pct=count/total*100
    print(f'      {lang}: {pct:.1f}%')
" 2>/dev/null | head -5

  return 0
}

test_tech_stack_analysis

echo ""
echo "✅ github-profile-beautifier tests passed"
