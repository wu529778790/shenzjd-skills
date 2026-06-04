#!/bin/bash
# Performance Profiler 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
SKILL_DIR="$(dirname "$TEST_DIR")/performance-profiler"

echo "🧪 Testing performance-profiler"
echo "==============================="

# 1. 测试项目类型检测
echo ""
echo "📋 Test 1: 项目类型检测"

detect_project_type() {
  local project_dir="$1"

  if [ -f "$project_dir/package.json" ]; then
    echo "nodejs"
  elif [ -f "$project_dir/go.mod" ]; then
    echo "go"
  elif [ -f "$project_dir/requirements.txt" ] || [ -f "$project_dir/pyproject.toml" ]; then
    echo "python"
  elif [ -f "$project_dir/Cargo.toml" ]; then
    echo "rust"
  else
    echo "unknown"
  fi
}

test_project_detection() {
  local project_dir="$1"
  local expected_type="$2"

  echo "  Testing: $project_dir"
  detected=$(detect_project_type "$project_dir")

  echo "    Detected: $detected (expected: $expected_type)"

  if [ "$detected" = "$expected_type" ]; then
    echo "    ✅ Project type detected correctly"
  else
    echo "    ❌ Expected $expected_type, got $detected"
    return 1
  fi

  return 0
}

test_project_detection "$FIXTURES_DIR/nodejs-express" "nodejs"
test_project_detection "$FIXTURES_DIR/go-api" "go"
test_project_detection "$FIXTURES_DIR/python-fastapi" "python"

# 2. 测试依赖分析
echo ""
echo "📋 Test 2: Node.js 依赖分析"
cd "$FIXTURES_DIR/nodejs-express"

echo "  Analyzing dependencies..."
deps=$(cat package.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('dependencies',{})))" 2>/dev/null || echo "0")
dev_deps=$(cat package.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('devDependencies',{})))" 2>/dev/null || echo "0")
total=$((deps + dev_deps))

echo "    Direct dependencies: $deps"
echo "    Dev dependencies: $dev_deps"
echo "    Total: $total"

if [ "$total" -gt 0 ]; then
  echo "    ✅ Dependencies analyzed"
else
  echo "    ❌ No dependencies found"
  return 1
fi

# 3. 测试依赖体积分析
echo ""
echo "📋 Test 3: 依赖体积分析"

echo "  Checking node_modules size..."
if [ -d "node_modules" ]; then
  size=$(du -sh node_modules 2>/dev/null | cut -f1)
  echo "    node_modules size: $size"

  # 检查是否有大型依赖
  large_deps=$(find node_modules -maxdepth 1 -type d -size +10M 2>/dev/null | wc -l | tr -d ' ')
  echo "    Large dependencies (>10MB): $large_deps"

  if [ "$large_deps" -gt 0 ]; then
    echo "    ⚠️  Found large dependencies"
    find node_modules -maxdepth 1 -type d -size +10M -exec du -sh {} \; 2>/dev/null | head -5 | sed 's/^/      /'
  else
    echo "    ✅ No large dependencies"
  fi
else
  echo "    ⚠️  node_modules not found (run npm install first)"
fi

# 4. 测试代码模式检测
echo ""
echo "📋 Test 4: 代码模式检测"

echo "  Checking for common performance issues..."

# 检查 barrel files
barrel_files=$(find . -name "index.ts" -o -name "index.js" | grep -v node_modules | wc -l | tr -d ' ')
echo "    Barrel files (index.ts/js): $barrel_files"

if [ "$barrel_files" -gt 3 ]; then
  echo "    ⚠️  Too many barrel files may impact bundle size"
else
  echo "    ✅ Barrel files count is reasonable"
fi

# 检查大型文件
large_files=$(find . -type f -size +500K -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l | tr -d ' ')
echo "    Large files (>500KB): $large_files"

if [ "$large_files" -gt 0 ]; then
  echo "    ⚠️  Found large files"
  find . -type f -size +500K -not -path "*/node_modules/*" -not -path "*/.git/*" -exec ls -lh {} \; 2>/dev/null | head -5 | sed 's/^/      /'
else
  echo "    ✅ No large files found"
fi

# 检查 import * 语句
wildcard_imports=$(grep -r "import \*" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
echo "    Wildcard imports (import *): $wildcard_imports"

if [ "$wildcard_imports" -gt 0 ]; then
  echo "    ⚠️  Wildcard imports may impact tree-shaking"
else
  echo "    ✅ No wildcard imports"
fi

# 5. 测试配置文件分析
echo ""
echo "📋 Test 5: 配置文件分析"

echo "  Checking build configuration..."

# 检查 webpack/vite 配置
if [ -f "webpack.config.js" ] || [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  echo "    ✅ Build config found"

  # 检查是否有优化配置
  if grep -q "splitChunks\|manualChunks" webpack.config.js vite.config.ts vite.config.js 2>/dev/null; then
    echo "      ✅ Code splitting configured"
  else
    echo "      ⚠️  Code splitting not configured"
  fi

  if grep -q "minify\|terser\|uglify" webpack.config.js vite.config.ts vite.config.js 2>/dev/null; then
    echo "      ✅ Minification configured"
  else
    echo "      ⚠️  Minification not explicitly configured"
  fi
else
  echo "    ⚠️  No build config found"
fi

# 检查 next.config.js
if [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
  echo "    ✅ Next.js config found"

  if grep -q "optimizeCss\|swcMinify" next.config.js next.config.mjs 2>/dev/null; then
    echo "      ✅ Next.js optimizations configured"
  else
    echo "      ⚠️  Next.js optimizations not configured"
  fi
fi

# 6. 测试报告模板
echo ""
echo "📋 Test 6: 报告模板验证"

if [ -f "$SKILL_DIR/templates/report.md" ]; then
  echo "  ✅ Report template exists"

  # 检查模板必需部分
  required_sections=("Overview" "High Priority" "Medium Priority" "Low Priority" "Dependency Breakdown")
  for section in "${required_sections[@]}"; do
    if grep -q "$section" "$SKILL_DIR/templates/report.md"; then
      echo "    ✅ Section: $section"
    else
      echo "    ❌ Missing section: $section"
      exit 1
    fi
  done
else
  echo "  ❌ Report template not found"
  exit 1
fi

echo ""
echo "✅ performance-profiler tests passed"
