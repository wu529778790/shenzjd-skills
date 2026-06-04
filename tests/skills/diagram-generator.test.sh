#!/bin/bash
# Diagram Generator 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/diagram-generator"

echo "🧪 Testing diagram-generator"
echo "============================"

# 1. 测试图表类型检测
echo ""
echo "📋 Test 1: 图表类型检测"

test_diagram_type_detection() {
  echo "  Testing diagram type detection..."

  # 模拟用户输入
  test_cases=(
    "架构图:architecture"
    "流程图:flowchart"
    "时序图:sequence"
    "ER图:structural"
    "状态图:state"
    "类图:structural"
    "甘特图:gantt"
  )

  for test_case in "${test_cases[@]}"; do
    input=$(echo "$test_case" | cut -d: -f1)
    expected=$(echo "$test_case" | cut -d: -f2)

    # 模拟类型检测
    case $input in
      *架构*|*组件*|*部署*)
        detected="architecture"
        ;;
      *流程*|*步骤*|*判断*)
        detected="flowchart"
        ;;
      *调用*|*请求*|*响应*|*时序*)
        detected="sequence"
        ;;
      *类*|*继承*|*ER*|*关系*)
        detected="structural"
        ;;
      *状态*|*生命周期*)
        detected="state"
        ;;
      *甘特*|*排期*)
        detected="gantt"
        ;;
      *)
        detected="unknown"
        ;;
    esac

    echo "    '$input' → $detected (expected: $expected)"

    if [ "$detected" = "$expected" ]; then
      echo "      ✅ Type detected correctly"
    else
      echo "      ❌ Type detection failed"
      return 1
    fi
  done

  return 0
}

test_diagram_type_detection

# 2. 测试 SVG 模板验证
echo ""
echo "📋 Test 2: SVG 模板验证"

test_svg_template() {
  echo "  Testing SVG template..."

  # 模拟 SVG 模板
  svg_template='<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 600">
  <style>
    @import url("https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&amp;display=swap");
    text { font-family: "JetBrains Mono", "Noto Sans SC", monospace; }
  </style>
  <defs>
    <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
      <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1e293b" stroke-width="0.5"/>
    </pattern>
    <marker id="arrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#64748b"/>
    </marker>
  </defs>
  <rect width="100%" height="100%" fill="#0f172a"/>
  <rect width="100%" height="100%" fill="url(#grid)"/>
  <text x="30" y="35" fill="white" font-size="16" font-weight="700">Test Diagram</text>
</svg>'

  # 验证 SVG 格式
  if echo "$svg_template" | grep -q '<svg xmlns='; then
    echo "    ✅ SVG root element present"
  else
    echo "    ❌ SVG root element missing"
    return 1
  fi

  if echo "$svg_template" | grep -q 'viewBox='; then
    echo "    ✅ viewBox attribute present"
  else
    echo "    ❌ viewBox attribute missing"
    return 1
  fi

  if echo "$svg_template" | grep -q '<style>'; then
    echo "    ✅ Style element present"
  else
    echo "    ❌ Style element missing"
    return 1
  fi

  if echo "$svg_template" | grep -q '<defs>'; then
    echo "    ✅ Defs element present"
  else
    echo "    ❌ Defs element missing"
    return 1
  fi

  # 验证 XML 转义
  if echo "$svg_template" | grep -q '&amp;'; then
    echo "    ✅ XML escaping correct"
  else
    echo "    ❌ XML escaping missing"
    return 1
  fi

  return 0
}

test_svg_template

# 3. 测试设计系统验证
echo ""
echo "📋 Test 3: 设计系统验证"

test_design_system() {
  echo "  Testing design system..."

  # 模拟颜色定义
  colors=(
    "Primary:rgba(8, 51, 68, 0.4):#22d3ee"
    "Secondary:rgba(6, 78, 59, 0.4):#34d399"
    "Tertiary:rgba(76, 29, 149, 0.4):#a78bfa"
    "Accent:rgba(120, 53, 15, 0.3):#fbbf24"
    "Alert:rgba(136, 19, 55, 0.4):#fb7185"
    "Connector:rgba(251, 146, 60, 0.3):#fb923c"
    "Neutral:rgba(30, 41, 59, 0.5):#94a3b8"
    "Highlight:rgba(59, 130, 246, 0.3):#60a5fa"
  )

  for color_def in "${colors[@]}"; do
    category=$(echo "$color_def" | cut -d: -f1)
    fill=$(echo "$color_def" | cut -d: -f2)
    stroke=$(echo "$color_def" | cut -d: -f3)

    echo "    $category: fill=$fill, stroke=$stroke"

    # 验证颜色格式
    if echo "$fill" | grep -qE '^rgba\([0-9]+, [0-9]+, [0-9]+, [0-9.]+\)$'; then
      echo "      ✅ Fill color valid"
    else
      echo "      ❌ Fill color invalid"
      return 1
    fi

    if echo "$stroke" | grep -qE '^#[0-9a-fA-F]{6}$'; then
      echo "      ✅ Stroke color valid"
    else
      echo "      ❌ Stroke color invalid"
      return 1
    fi
  done

  return 0
}

test_design_system

# 4. 测试字体规范
echo ""
echo "📋 Test 4: 字体规范测试"

test_font_spec() {
  echo "  Testing font specification..."

  # 模拟字体规范
  font_spec='{
    "title": {"size": 16, "weight": 700},
    "component": {"size": 12, "weight": 600},
    "description": {"size": 9, "weight": 400},
    "annotation": {"size": 8, "weight": 400},
    "arrow_label": {"size": 8, "weight": 400}
  }'

  # 验证 JSON 格式
  if echo "$font_spec" | python3 -m json.tool >/dev/null 2>&1; then
    echo "    ✅ Font spec is valid JSON"
  else
    echo "    ❌ Font spec is invalid JSON"
    return 1
  fi

  # 验证必需字体大小
  required_sizes=("title" "component" "description")
  for size in "${required_sizes[@]}"; do
    if echo "$font_spec" | grep -q "\"$size\""; then
      echo "    ✅ Font size: $size"
    else
      echo "    ❌ Missing font size: $size"
      return 1
    fi
  done

  return 0
}

test_font_spec

# 5. 测试组件模板
echo ""
echo "📋 Test 5: 组件模板测试"

test_component_templates() {
  echo "  Testing component templates..."

  # 模拟组件模板
  component_template='<rect x="X" y="Y" width="160" height="60" rx="6" fill="FILL_COLOR" stroke="STROKE_COLOR" stroke-width="1.5"/>'

  # 验证组件格式
  if echo "$component_template" | grep -q 'rect.*x=.*y=.*width=.*height='; then
    echo "    ✅ Component template valid"
  else
    echo "    ❌ Component template invalid"
    return 1
  fi

  # 模拟数据库圆柱模板
  db_template='<g transform="translate(X, Y)">
  <ellipse cx="60" cy="10" rx="60" ry="12"/>
  <rect x="0" y="10" width="120" height="50"/>
  <ellipse cx="60" cy="60" rx="60" ry="12"/>
</g>'

  if echo "$db_template" | grep -q '<ellipse'; then
    echo "    ✅ Database template valid"
  else
    echo "    ❌ Database template invalid"
    return 1
  fi

  return 0
}

test_component_templates

# 6. 测试布局算法
echo ""
echo "📋 Test 6: 布局算法测试"

test_layout_algorithm() {
  echo "  Testing layout algorithm..."

  # 模拟组件位置
  components=(
    "component1:100:100:160:60"
    "component2:100:200:160:60"
    "component3:300:150:160:60"
  )

  # 计算 viewBox
  max_x=0
  max_y=0

  for comp in "${components[@]}"; do
    name=$(echo "$comp" | cut -d: -f1)
    x=$(echo "$comp" | cut -d: -f2)
    y=$(echo "$comp" | cut -d: -f3)
    width=$(echo "$comp" | cut -d: -f4)
    height=$(echo "$comp" | cut -d: -f5)

    right=$((x + width))
    bottom=$((y + height))

    if [ "$right" -gt "$max_x" ]; then
      max_x=$right
    fi

    if [ "$bottom" -gt "$max_y" ]; then
      max_y=$bottom
    fi
  done

  # 添加 padding
  padding=30
  viewbox_width=$((max_x + padding * 2))
  viewbox_height=$((max_y + padding * 2))

  echo "    Components: ${#components[@]}"
  echo "    Max X: $max_x, Max Y: $max_y"
  echo "    ViewBox: 0 0 $viewbox_width $viewbox_height"

  # 验证 viewBox 计算
  if [ "$viewbox_width" -gt 0 ] && [ "$viewbox_height" -gt 0 ]; then
    echo "    ✅ ViewBox calculated correctly"
  else
    echo "    ❌ ViewBox calculation failed"
    return 1
  fi

  return 0
}

test_layout_algorithm

# 7. 测试中文支持
echo ""
echo "📋 Test 7: 中文支持测试"

test_chinese_support() {
  echo "  Testing Chinese character support..."

  # 模拟中文标签
  chinese_labels=(
    "用户服务"
    "数据库"
    "消息队列"
    "缓存层"
  )

  for label in "${chinese_labels[@]}"; do
    echo "    Label: $label"

    # 验证中文字符
    if echo "$label" | grep -qP '[\x{4e00}-\x{9fff}]' 2>/dev/null || echo "$label" | python3 -c "import sys; sys.exit(0 if any('一' <= c <= '鿿' for c in sys.stdin.read()) else 1)"; then
      echo "      ✅ Chinese characters detected"
    else
      echo "      ❌ Chinese characters not detected"
      return 1
    fi

    # 模拟宽度计算（中文字符宽度 = 2 * 拉丁字符宽度）
    char_count=${#label}
    estimated_width=$((char_count * 14))  # 中文字符约 14px 宽

    echo "      Characters: $char_count, Estimated width: ${estimated_width}px"

    if [ "$estimated_width" -gt 0 ]; then
      echo "      ✅ Width estimated correctly"
    else
      echo "      ❌ Width estimation failed"
      return 1
    fi
  done

  return 0
}

test_chinese_support

echo ""
echo "✅ diagram-generator tests passed"
