#!/bin/bash
# Release Notes Generator 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/release-notes-generator"

echo "🧪 Testing release-notes-generator"
echo "================================="

cd "$TEST_DIR/.."

# 1. 测试 git tag 检测
echo ""
echo "📋 Test 1: Git Tag 检测"

echo "  Checking git tags..."
tags=$(git tag -l 2>/dev/null || true)
tag_count=$(echo "$tags" | grep -c . || echo "0")

echo "  Found $tag_count tags"

if [ "$tag_count" -gt 0 ]; then
  latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
  echo "  Latest tag: $latest_tag"

  # 验证 tag 格式（语义化版本）
  if echo "$latest_tag" | grep -qE '^v?[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "  ✅ Tag format is valid (semver)"
  else
    echo "  ⚠️  Tag format is not standard semver: $latest_tag"
  fi
else
  echo "  No tags found (this is expected for new repos)"
fi

# 2. 测试 commit 分类
echo ""
echo "📋 Test 2: Commit 分类测试"

echo "  Analyzing commit messages..."
commits=$(git log --oneline -20 2>/dev/null || echo "")

if [ -n "$commits" ]; then
  echo "  Recent commits:"
  echo "$commits" | head -5 | sed 's/^/    /'

  # 统计 conventional commits
  feat_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ feat" || echo "0")
  fix_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ fix" || echo "0")
  docs_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ docs" || echo "0")
  refactor_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ refactor" || echo "0")
  chore_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ chore" || echo "0")
  perf_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ perf" || echo "0")
  test_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ test" || echo "0")
  security_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ security" || echo "0")

  echo ""
  echo "  Commit statistics:"
  echo "    feat: $feat_count"
  echo "    fix: $fix_count"
  echo "    docs: $docs_count"
  echo "    refactor: $refactor_count"
  echo "    chore: $chore_count"
  echo "    perf: $perf_count"
  echo "    test: $test_count"
  echo "    security: $security_count"

  # 检测 breaking changes
  breaking_count=$(echo "$commits" | grep -cE "^[a-f0-9]+ [a-z]+!:" || echo "0")
  breaking_body=$(git log --oneline -20 --format="%b" 2>/dev/null | grep -c "BREAKING CHANGE" || echo "0")
  total_breaking=$((breaking_count + breaking_body))

  echo "    breaking changes: $total_breaking"

  if [ "$total_breaking" -gt 0 ]; then
    echo "  ⚠️  Breaking changes detected"
  fi
else
  echo "  No commits found"
fi

# 3. 测试版本号建议
echo ""
echo "📋 Test 3: 版本号建议测试"

# 模拟版本号建议逻辑
suggest_version() {
  local breaking="$1"
  local feat="$2"
  local fix="$3"

  if [ "$breaking" -gt 0 ]; then
    echo "major"
  elif [ "$feat" -gt 0 ]; then
    echo "minor"
  elif [ "$fix" -gt 0 ]; then
    echo "patch"
  else
    echo "patch"
  fi
}

# 测试用例
test_version_suggestion() {
  local breaking="$1"
  local feat="$2"
  local fix="$3"
  local expected="$4"

  result=$(suggest_version "$breaking" "$feat" "$fix")

  echo "  Test: breaking=$breaking, feat=$feat, fix=$fix"
  echo "    Expected: $expected, Got: $result"

  if [ "$result" = "$expected" ]; then
    echo "    ✅ Version suggestion correct"
  else
    echo "    ❌ Version suggestion incorrect"
    return 1
  fi

  return 0
}

test_version_suggestion 0 0 0 "patch"  # 无变更 → patch
test_version_suggestion 0 0 1 "patch"  # 只有 fix → patch
test_version_suggestion 0 1 0 "minor"  # 有 feat → minor
test_version_suggestion 1 0 0 "major"  # 有 breaking → major
test_version_suggestion 1 1 1 "major"  # 都有 → major

# 4. 测试 Release Notes 模板
echo ""
echo "📋 Test 4: Release Notes 模板验证"

if [ -f "$SKILL_DIR/templates/release-notes.md" ]; then
  echo "  ✅ Release notes template exists"

  # 检查模板必需部分
  required_vars=("{{VERSION}}" "{{DATE}}" "features" "fixes" "breaking")
  for var in "${required_vars[@]}"; do
    if grep -q "$var" "$SKILL_DIR/templates/release-notes.md"; then
      echo "    ✅ Variable: $var"
    else
      echo "    ❌ Missing variable: $var"
      exit 1
    fi
  done
else
  echo "  ❌ Release notes template not found"
  exit 1
fi

# 5. 测试 diff 统计
echo ""
echo "📋 Test 5: Diff 统计测试"

if [ "$tag_count" -gt 0 ]; then
  echo "  Testing diff stats from latest tag..."
  diff_stat=$(git diff "${latest_tag}..HEAD" --stat 2>/dev/null || echo "")

  if [ -n "$diff_stat" ]; then
    files_changed=$(echo "$diff_stat" | tail -1 | grep -oE "[0-9]+ files? changed" | grep -oE "[0-9]+" || echo "0")
    echo "  Files changed: $files_changed"

    if [ "$files_changed" -gt 0 ]; then
      echo "  ✅ Diff stats generated"
    else
      echo "  ⚠️  No changes since last tag"
    fi
  else
    echo "  No diff available"
  fi
else
  echo "  Skipping (no tags)"
fi

echo ""
echo "✅ release-notes-generator tests passed"
