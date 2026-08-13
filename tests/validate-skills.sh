#!/bin/bash
# Skills 结构验证脚本
# 检查所有 SKILL.md 文件的格式、命令语法和模板文件

set -e

# 获取脚本所在目录，然后向上一级到项目根目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")"
ERRORS=0
WARNINGS=0

echo "🔍 Skills 结构验证"
echo "=================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
  echo -e "${RED}❌ $1${NC}"
  ERRORS=$((ERRORS + 1))
}

warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
  WARNINGS=$((WARNINGS + 1))
}

success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# 1. 查找所有 SKILL.md 文件
echo "📋 Step 1: 查找 SKILL.md 文件"
SKILL_FILES=$(find "$SKILLS_DIR" -name "SKILL.md" -not -path "*/.git/*" -not -path "*/.well-known/*" -not -path "*/tests/*")
SKILL_COUNT=$(echo "$SKILL_FILES" | wc -l | tr -d ' ')

if [ "$SKILL_COUNT" -eq 0 ]; then
  error "未找到任何 SKILL.md 文件"
  exit 1
fi
echo "  找到 $SKILL_COUNT 个 skills"
echo ""

# 2. 验证每个 SKILL.md
echo "📋 Step 2: 验证 SKILL.md 结构"
echo ""

for skill_file in $SKILL_FILES; do
  skill_name=$(basename "$(dirname "$skill_file")")
  echo "🔍 验证: $skill_name"

  # 2.1 检查 YAML frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed '1d;$d')

  if [ -z "$frontmatter" ]; then
    error "  缺少 YAML frontmatter"
    continue
  fi

  # 2.2 检查 name 字段
  name=$(echo "$frontmatter" | grep -E "^name:" | sed 's/^name: *//' | tr -d '"' | tr -d "'")
  if [ -z "$name" ]; then
    error "  缺少 'name' 字段"
  elif ! echo "$name" | grep -qE '^[a-z0-9-]{1,64}$'; then
    error "  name 格式无效: $name"
  else
    success "  name: $name"
  fi

  # 2.3 检查 description 字段
  desc=$(echo "$frontmatter" | grep -E "^description:" | sed 's/^description: *//' | tr -d '"' | tr -d "'")
  if [ -z "$desc" ]; then
    error "  缺少 'description' 字段"
  elif [ ${#desc} -lt 20 ]; then
    warn "  description 太短 (${#desc} 字符，建议 50+)"
  else
    success "  description: ${#desc} 字符"
  fi

  # 2.4 检查必需章节
  echo "  📖 检查章节结构..."
  for section in "Overview" "When to Use" "Core Pattern" "Quick Reference" "Common Mistakes"; do
    if grep -q "## $section" "$skill_file"; then
      success "  章节: $section"
    else
      warn "  缺少章节: $section"
    fi
  done

  # 2.5 检查模板目录
  skill_dir=$(dirname "$skill_file")
  if [ -d "$skill_dir/templates" ]; then
    template_count=$(find "$skill_dir/templates" -type f | wc -l | tr -d ' ')
    echo "  📁 模板目录: $template_count 个文件"

    # 检查模板文件是否被引用（覆盖所有扩展名：.md/.sql/.js/.nodejs/.yml 等）
    for template in $(find "$skill_dir/templates" -type f); do
      template_name=$(basename "$template")
      if grep -q "$template_name" "$skill_file"; then
        success "    模板已引用: $template_name"
      else
        warn "    模板未引用: $template_name"
      fi
    done
  fi

  echo ""
done

# 3. 验证 bash 命令语法
echo "📋 Step 3: 验证 bash 命令语法"
echo ""

for skill_file in $SKILL_FILES; do
  skill_name=$(basename "$(dirname "$skill_file")")
  echo "🔍 检查命令: $skill_name"

  # 提取 bash 代码块
  bash_blocks=$(sed -n '/^```bash$/,/^```$/p' "$skill_file" | sed '1d;$d')

  if [ -z "$bash_blocks" ]; then
    warn "  未找到 bash 代码块"
    continue
  fi

  # 检查常见错误
  line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))

    # 检查未闭合的引号
    if echo "$line" | grep -qE '^\s*(if|elif|else|while|for)\b.*[^"]*"[^"]*$'; then
      if ! echo "$line" | grep -qE '"$'; then
        warn "  可能未闭合的引号 (行 $line_num)"
      fi
    fi

    # 检查未闭合的方括号
    open_brackets=$(echo "$line" | grep -o '\[' | wc -l | tr -d ' ')
    close_brackets=$(echo "$line" | grep -o '\]' | wc -l | tr -d ' ')
    if [ "$open_brackets" -ne "$close_brackets" ]; then
      if [ "$open_brackets" -gt "$close_brackets" ]; then
        warn "  可能未闭合的方括号 (行 $line_num)"
      fi
    fi

    # 检查常见命令错误
    if echo "$line" | grep -qE '^\s*cd\s+[^|;]+&&'; then
      warn "  cd 后直接 && 可能有问题 (行 $line_num)"
    fi

  done <<< "$bash_blocks"

  success "  命令检查完成"
  echo ""
done

# 4. 验证跨 skill 引用
echo "📋 Step 4: 验证跨 skill 引用"
echo ""

for skill_file in $SKILL_FILES; do
  skill_name=$(basename "$(dirname "$skill_file")")

  # 检查是否引用其他 skills
  refs=$(grep -oE '\b[a-z-]+\b(?=/SKILL\.md)' "$skill_file" 2>/dev/null || true)

  if [ -n "$refs" ]; then
    echo "🔍 $skill_name 引用其他 skills:"
    for ref in $refs; do
      ref_file="$SKILLS_DIR/$ref/SKILL.md"
      if [ -f "$ref_file" ]; then
        success "  引用存在: $ref"
      else
        warn "  引用不存在: $ref"
      fi
    done
  fi
done

# 5. 汇总
echo ""
echo "=================="
echo "📊 验证结果"
echo "=================="

if [ $ERRORS -gt 0 ]; then
  echo -e "${RED}❌ 失败: $ERRORS 个错误${NC}"
  echo -e "${YELLOW}⚠️  警告: $WARNINGS 个警告${NC}"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo -e "${YELLOW}⚠️  通过（有警告）: $WARNINGS 个警告${NC}"
  exit 0
else
  echo -e "${GREEN}✅ 全部通过${NC}"
  exit 0
fi
