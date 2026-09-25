#!/bin/bash
# Video Cover Packager 测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/video-cover-packager"
SKILL_MD="$SKILL_DIR/SKILL.md"

echo "🧪 Testing video-cover-packager"
echo "================================"

fail=0

check() {
  local desc="$1"; shift
  if "$@"; then
    echo "  ✅ $desc"
  else
    echo "  ❌ $desc"
    fail=1
  fi
}

# 1. 文件存在
echo ""
echo "📋 Test 1: 文件结构"
check "SKILL.md 存在" test -f "$SKILL_MD"
check "README.md 存在" test -f "$SKILL_DIR/README.md"

# 2. Frontmatter
echo ""
echo "📋 Test 2: Frontmatter"
check "name 字段存在" grep -q '^name: video-cover-packager$' "$SKILL_MD"
check "name 符合命名规范" bash -c "head -5 '$SKILL_MD' | grep -qE '^name: [a-z0-9-]{1,64}$'"
check "description 存在" grep -q '^description: "' "$SKILL_MD"
desc_len=$(grep '^description:' "$SKILL_MD" | wc -c)
check "description 长度 ≥ 50 ($desc_len)" [ "$desc_len" -ge 50 ]

# 3. 必需章节
echo ""
echo "📋 Test 3: 必需章节"
for section in "## Overview" "## When to Use" "## Core Pattern" "## Quick Reference" "## Common Mistakes"; do
  check "章节 $section 存在" grep -qF "$section" "$SKILL_MD"
done

# 4. 内容覆盖
echo ""
echo "📋 Test 4: 关键内容"
for kw in "小红书" "抖音" "视频号" "B站" "YouTube" "封面标题" "平台标签" "封面预审"; do
  check "包含关键词 $kw" grep -q "$kw" "$SKILL_MD"
done
check "包含 8 类标题策略表" [ "$(grep -c '^| ' "$SKILL_MD")" -gt 10 ]
check "包含输出章节顺序" grep -q "包装简报 → 标题策略" "$SKILL_MD"
check "包含确认后生图闸门" grep -q "确认后" "$SKILL_MD"

# 5. 边界规则
echo ""
echo "📋 Test 5: 边界规则"
check "禁止编造数据规则" grep -q "不编造" "$SKILL_MD"
check "单期内容限制" grep -q "一次只处理一期" "$SKILL_MD"
check "When NOT to Use 存在" grep -q "When NOT to Use" "$SKILL_MD"

# 6. 标题合成脚本
echo ""
echo "📋 Test 6: 标题合成脚本"
ADD_TITLE="$SKILL_DIR/scripts/add-title.py"
check "scripts/add-title.py 存在" test -f "$ADD_TITLE"
check "SKILL.md 引用 add-title.py" grep -q "scripts/add-title.py" "$SKILL_MD"
check "脚本声明无文字生图规则" grep -q "无文字" "$SKILL_MD"
if command -v python3 >/dev/null && python3 -c "import PIL" 2>/dev/null; then
  tmp_png=$(mktemp /tmp/vcp-test-XXXX.png)
  out_png=$(mktemp /tmp/vcp-out-XXXX.png)
  python3 - "$tmp_png" <<'PYEOF'
import sys
from PIL import Image
Image.new("RGB", (768, 1024), (200, 220, 240)).save(sys.argv[1])
PYEOF
  if python3 "$ADD_TITLE" --image "$tmp_png" --title "测试标题" --out "$out_png" >/dev/null 2>&1 \
     && python3 -c "from PIL import Image; im=Image.open('$out_png'); assert im.size==(768,1024)"; then
    echo "  ✅ add-title.py 能合成标题并输出同尺寸图片"
  else
    echo "  ❌ add-title.py 执行失败"
    fail=1
  fi
  # 两行模式
  if python3 "$ADD_TITLE" --image "$tmp_png" --title "第一行|第二行标题" --out "$out_png" >/dev/null 2>&1; then
    echo "  ✅ 两行标题模式可用"
  else
    echo "  ❌ 两行标题模式失败"
    fail=1
  fi
  rm -f "$tmp_png" "$out_png"
else
  echo "  ⚠️  缺少 python3/Pillow，跳过运行时测试"
fi

echo ""
if [ "$fail" -eq 0 ]; then
  echo "✅ video-cover-packager tests passed"
else
  echo "❌ video-cover-packager tests failed"
  exit 1
fi
