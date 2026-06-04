#!/bin/bash
# Dependency Audit 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
SKILL_DIR="$(dirname "$TEST_DIR")/dependency-audit"

echo "🧪 Testing dependency-audit"
echo "=========================="

# 1. 测试包管理器检测
echo ""
echo "📋 Test 1: 包管理器检测"

test_package_manager() {
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
  elif [ -f "go.sum" ] || [ -f "go.mod" ]; then
    detected="go"
  elif [ -f "requirements.txt" ] || [ -f "Pipfile.lock" ] || [ -f "pyproject.toml" ]; then
    detected="python"
  elif [ -f "Cargo.lock" ] || [ -f "Cargo.toml" ]; then
    detected="rust"
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

test_package_manager "$FIXTURES_DIR/nodejs-express" "npm"
test_package_manager "$FIXTURES_DIR/go-api" "go"
test_package_manager "$FIXTURES_DIR/python-fastapi" "python"

# 2. 测试漏洞扫描
echo ""
echo "📋 Test 2: npm audit 测试"
cd "$FIXTURES_DIR/nodejs-express"

echo "  Running npm audit..."
audit_output=$(npm audit --json 2>/dev/null || true)
vuln_count=$(echo "$audit_output" | python3 -c "
import sys,json
try:
    data=json.load(sys.stdin)
    vulns=data.get('vulnerabilities',{})
    print(len(vulns))
except:
    print(0)
" 2>/dev/null || echo "0")

echo "  Found $vuln_count vulnerabilities"

# 漏洞数量应该是数字
if ! [[ "$vuln_count" =~ ^[0-9]+$ ]]; then
  echo "  ❌ Invalid vulnerability count: $vuln_count"
  exit 1
fi

echo "  ✅ Vulnerability scan completed"

# 3. 测试过时依赖检测
echo ""
echo "📋 Test 3: 过时依赖检测"

echo "  Running npm outdated..."
outdated_output=$(npm outdated --json 2>/dev/null || true)

if [ -n "$outdated_output" ] && [ "$outdated_output" != "{}" ]; then
  outdated_count=$(echo "$outdated_output" | python3 -c "
import sys,json
try:
    data=json.load(sys.stdin)
    print(len(data))
except:
    print(0)
" 2>/dev/null || echo "0")

  echo "  Found $outdated_count outdated packages"

  if ! [[ "$outdated_count" =~ ^[0-9]+$ ]]; then
    echo "  ❌ Invalid outdated count: $outdated_count"
    exit 1
  fi
else
  echo "  No outdated packages found"
fi

echo "  ✅ Outdated detection completed"

# 4. 测试 License 检查
echo ""
echo "📋 Test 4: License 检查"

echo "  Running license-checker..."
if command -v npx >/dev/null 2>&1; then
  license_output=$(npx license-checker --json 2>/dev/null || true)

  if [ -n "$license_output" ] && [ "$license_output" != "{}" ]; then
    license_count=$(echo "$license_output" | python3 -c "
import sys,json
try:
    data=json.load(sys.stdin)
    licenses={}
    for k,v in data.items():
        lic=v.get('licenses','UNKNOWN')
        licenses[lic]=licenses.get(lic,0)+1
    print(len(licenses))
except:
    print(0)
" 2>/dev/null || echo "0")

    echo "  Found $license_count different licenses"

    # 检查是否有 GPL/AGPL
    gpl_count=$(echo "$license_output" | python3 -c "
import sys,json
try:
    data=json.load(sys.stdin)
    gpl=0
    for k,v in data.items():
        lic=str(v.get('licenses','')).upper()
        if 'GPL' in lic or 'AGPL' in lic:
            gpl+=1
    print(gpl)
except:
    print(0)
" 2>/dev/null || echo "0")

    if [ "$gpl_count" -gt 0 ]; then
      echo "  ⚠️  Found $gpl_count GPL/AGPL licensed packages"
    else
      echo "  ✅ No GPL/AGPL licenses found"
    fi
  else
    echo "  No license data found"
  fi
else
  echo "  ⚠️  npx not available, skipping license check"
fi

echo "  ✅ License check completed"

# 5. 测试报告生成
echo ""
echo "📋 Test 5: 报告模板验证"

if [ -f "$SKILL_DIR/templates/audit-report.md" ]; then
  echo "  ✅ Audit report template exists"

  # 检查模板必需部分
  required_sections=("Summary" "Security Vulnerabilities" "Outdated Dependencies" "License Compliance" "Recommended Actions")
  for section in "${required_sections[@]}"; do
    if grep -q "$section" "$SKILL_DIR/templates/audit-report.md"; then
      echo "    ✅ Section: $section"
    else
      echo "    ❌ Missing section: $section"
      exit 1
    fi
  done
else
  echo "  ❌ Audit report template not found"
  exit 1
fi

echo ""
echo "✅ dependency-audit tests passed"
