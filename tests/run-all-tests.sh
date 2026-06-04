#!/bin/bash
# Skills 完整测试套件
# 运行所有测试并生成报告

set -e

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(dirname "$TEST_DIR")"

echo "🧪 Skills 完整测试套件"
echo "======================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 计数器
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# 测试结果数组
declare -a TEST_RESULTS=()

run_test() {
  local test_name="$1"
  local test_script="$2"

  TOTAL=$((TOTAL + 1))

  echo -e "${BLUE}▶ Running: $test_name${NC}"

  if [ ! -f "$test_script" ]; then
    echo -e "${YELLOW}  ⏭️  Skipped (test not found)${NC}"
    SKIPPED=$((SKIPPED + 1))
    TEST_RESULTS+=("$test_name:SKIP")
    return 0
  fi

  if [ ! -x "$test_script" ]; then
    chmod +x "$test_script"
  fi

  if "$test_script" 2>&1; then
    echo -e "${GREEN}  ✅ Passed${NC}"
    PASSED=$((PASSED + 1))
    TEST_RESULTS+=("$test_name:PASS")
  else
    echo -e "${RED}  ❌ Failed${NC}"
    FAILED=$((FAILED + 1))
    TEST_RESULTS+=("$test_name:FAIL")
  fi

  echo ""
}

# 1. 结构验证
echo "📋 Phase 1: 结构验证"
echo "===================="
run_test "Structure Validation" "$TEST_DIR/validate-skills.sh"

# 2. 单元测试
echo ""
echo "📋 Phase 2: 单元测试"
echo "==================="
for test_script in "$TEST_DIR"/skills/*.test.sh; do
  if [ -f "$test_script" ]; then
    test_name=$(basename "$test_script" .test.sh)
    run_test "$test_name" "$test_script"
  fi
done

# 3. 生成报告
echo ""
echo "📊 测试报告"
echo "=========="
echo ""

# 创建报告文件
REPORT_FILE="$TEST_DIR/TEST-REPORT-$(date +%Y%m%d-%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# Skills 测试报告

生成时间: $(date '+%Y-%m-%d %H:%M:%S')

## 测试概览

- 总测试数: $TOTAL
- 通过: $PASSED
- 失败: $FAILED
- 跳过: $SKIPPED

## 测试结果

| 测试名称 | 状态 |
|----------|------|
EOF

# 添加每个测试的结果
for result in "${TEST_RESULTS[@]}"; do
  test_name=$(echo "$result" | cut -d: -f1)
  status=$(echo "$result" | cut -d: -f2)

  case $status in
    PASS)
      status_icon="✅ 通过"
      ;;
    FAIL)
      status_icon="❌ 失败"
      ;;
    SKIP)
      status_icon="⏭️  跳过"
      ;;
  esac

  echo "| $test_name | $status_icon |" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

## 失败详情

EOF

# 添加失败详情
if [ $FAILED -gt 0 ]; then
  for result in "${TEST_RESULTS[@]}"; do
    test_name=$(echo "$result" | cut -d: -f1)
    status=$(echo "$result" | cut -d: -f2)

    if [ "$status" = "FAIL" ]; then
      echo "### $test_name" >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
      echo "请查看详细输出了解失败原因。" >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
    fi
  done
else
  echo "所有测试通过！" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

## 测试覆盖

| Skill | 结构验证 | 单元测试 |
|-------|----------|----------|
EOF

# 添加覆盖情况
for skill_dir in "$SKILLS_DIR"/*/; do
  if [ -d "$skill_dir" ]; then
    skill_name=$(basename "$skill_dir")
    skill_test="$TEST_DIR/skills/$skill_name.test.sh"

    if [ -f "$TEST_DIR/skills/$skill_name.test.sh" ]; then
      echo "| $skill_name | ✅ | ✅ |" >> "$REPORT_FILE"
    else
      echo "| $skill_name | ✅ | ⏭️ |" >> "$REPORT_FILE"
    fi
  fi
done

echo ""
echo "📄 报告已生成: $REPORT_FILE"
echo ""

# 输出汇总
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 测试汇总${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  总测试数: ${BLUE}$TOTAL${NC}"
echo -e "  通过:     ${GREEN}$PASSED${NC}"
echo -e "  失败:     ${RED}$FAILED${NC}"
echo -e "  跳过:     ${YELLOW}$SKIPPED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ 所有测试通过！${NC}"
  exit 0
else
  echo -e "${RED}❌ 有 $FAILED 个测试失败${NC}"
  exit 1
fi
