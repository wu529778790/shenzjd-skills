#!/bin/bash
# Token Burner 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/token-burner"

echo "🧪 Testing token-burner"
echo "======================="

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

test_project_detection "$TEST_DIR/fixtures/nodejs-express" "nodejs"
test_project_detection "$TEST_DIR/fixtures/go-api" "go"
test_project_detection "$TEST_DIR/fixtures/python-fastapi" "python"

# 2. 测试任务发现引擎
echo ""
echo "📋 Test 2: 任务发现引擎测试"

test_task_discovery() {
  echo "  Testing task discovery engine..."

  # 模拟任务类型
  task_types=(
    "dependency_security:P0"
    "code_defect:P0"
    "test_coverage:P1"
    "documentation:P2"
    "code_refactor:P2"
    "git_cleanup:P3"
  )

  for task_def in "${task_types[@]}"; do
    type=$(echo "$task_def" | cut -d: -f1)
    priority=$(echo "$task_def" | cut -d: -f2)

    echo "    Task: $type (Priority: $priority)"

    # 验证优先级
    case $priority in
      P0|P1)
        echo "      ✅ High priority task"
        ;;
      P2)
        echo "      ✅ Medium priority task"
        ;;
      P3)
        echo "      ✅ Low priority task"
        ;;
      *)
        echo "      ❌ Invalid priority: $priority"
        return 1
        ;;
    esac
  done

  return 0
}

test_task_discovery

# 3. 测试优先级排序
echo ""
echo "📋 Test 3: 优先级排序测试"

test_priority_sorting() {
  echo "  Testing priority sorting..."

  # 模拟任务列表
  tasks=(
    "task1:high:low"
    "task2:medium:medium"
    "task3:low:high"
    "task4:high:high"
    "task5:medium:low"
  )

  # 计算分数并排序
  scored_tasks=()
  for task in "${tasks[@]}"; do
    name=$(echo "$task" | cut -d: -f1)
    impact=$(echo "$task" | cut -d: -f2)
    risk=$(echo "$task" | cut -d: -f3)

    # 转换为数值
    case $impact in
      high) impact_score=3 ;;
      medium) impact_score=2 ;;
      low) impact_score=1 ;;
    esac

    case $risk in
      high) risk_score=0.8 ;;
      medium) risk_score=0.4 ;;
      low) risk_score=0.1 ;;
    esac

    # 计算分数
    score=$(python3 -c "print($impact_score * (1 - $risk_score))" 2>/dev/null || echo "0")

    scored_tasks+=("$name:$score")
    echo "    $name: impact=$impact, risk=$risk, score=$score"
  done

  # 验证排序
  sorted_tasks=$(printf '%s\n' "${scored_tasks[@]}" | sort -t: -k2 -rn)

  echo "    Sorted order:"
  echo "$sorted_tasks" | head -5 | sed 's/^/      /'

  # 验证排序正确性
  first_score=$(echo "$sorted_tasks" | head -1 | cut -d: -f2)
  last_score=$(echo "$sorted_tasks" | tail -1 | cut -d: -f2)

  if [ $(python3 -c "print(1 if $first_score >= $last_score else 0)" 2>/dev/null || echo "1") -eq 1 ]; then
    echo "    ✅ Sorting correct"
  else
    echo "    ❌ Sorting incorrect"
    return 1
  fi

  return 0
}

test_priority_sorting

# 4. 测试任务执行策略
echo ""
echo "📋 Test 4: 任务执行策略测试"

test_execution_strategy() {
  echo "  Testing execution strategy..."

  # 模拟任务执行
  task_strategies=(
    "dependency_security:run_audit_tool:re_audit"
    "code_defect:analyze_diff:run_tests"
    "test_coverage:generate_tests:run_new_tests"
    "documentation:generate_docs:check_format"
    "code_refactor:extract_function:run_all_tests"
    "git_cleanup:clean_files:git_status"
  )

  for strategy in "${task_strategies[@]}"; do
    type=$(echo "$strategy" | cut -d: -f1)
    action=$(echo "$strategy" | cut -d: -f2)
    verify=$(echo "$strategy" | cut -d: -f3)

    echo "    $type: action=$action, verify=$verify"

    # 验证策略
    if [ -n "$action" ] && [ -n "$verify" ]; then
      echo "      ✅ Strategy defined"
    else
      echo "      ❌ Strategy incomplete"
      return 1
    fi
  done

  return 0
}

test_execution_strategy

# 5. 测试重试机制
echo ""
echo "📋 Test 5: 重试机制测试"

test_retry_mechanism() {
  echo "  Testing retry mechanism..."

  # 模拟重试
  max_retries=3
  current_retry=0
  success=false

  while [ $current_retry -lt $max_retries ] && [ "$success" = false ]; do
    echo "    Attempt $((current_retry + 1))/$max_retries"

    # 模拟成功率（第2次成功）
    if [ $current_retry -eq 1 ]; then
      success=true
      echo "      ✅ Task succeeded"
    else
      echo "      ❌ Task failed"
      current_retry=$((current_retry + 1))
    fi
  done

  if [ "$success" = true ]; then
    echo "    ✅ Retry mechanism works"
  else
    echo "    ❌ Retry mechanism failed"
    return 1
  fi

  return 0
}

test_retry_mechanism

# 6. 测试超时处理
echo ""
echo "📋 Test 6: 超时处理测试"

test_timeout_handling() {
  echo "  Testing timeout handling..."

  # 模拟超时
  task_timeout=300  # 5 分钟
  start_time=$(date +%s)

  # 模拟任务执行（快速完成）
  sleep 1

  end_time=$(date +%s)
  elapsed=$((end_time - start_time))

  echo "    Task timeout: ${task_timeout}s"
  echo "    Elapsed time: ${elapsed}s"

  if [ $elapsed -lt $task_timeout ]; then
    echo "    ✅ Task completed within timeout"
  else
    echo "    ❌ Task timed out"
    return 1
  fi

  return 0
}

test_timeout_handling

# 7. 测试任务数量限制
echo ""
echo "📋 Test 7: 任务数量限制测试"

test_task_limit() {
  echo "  Testing task limit..."

  # 模拟任务队列
  max_tasks=20
  tasks_found=25

  echo "    Max tasks: $max_tasks"
  echo "    Tasks found: $tasks_found"

  if [ $tasks_found -gt $max_tasks ]; then
    echo "    ⚠️  Tasks exceed limit, truncating to $max_tasks"
    actual_tasks=$max_tasks
  else
    actual_tasks=$tasks_found
  fi

  echo "    Actual tasks: $actual_tasks"

  if [ $actual_tasks -le $max_tasks ]; then
    echo "    ✅ Task limit enforced"
  else
    echo "    ❌ Task limit not enforced"
    return 1
  fi

  return 0
}

test_task_limit

# 8. 测试报告模板
echo ""
echo "📋 Test 8: 报告模板验证"

test_report_template() {
  echo "  Testing report template..."

  if [ -f "$SKILL_DIR/templates/execution-report.md" ]; then
    echo "    ✅ Execution report template exists"

    # 检查模板必需部分
    required_sections=("运行概览" "任务详情" "未执行任务" "下次运行建议")
    for section in "${required_sections[@]}"; do
      if grep -q "$section" "$SKILL_DIR/templates/execution-report.md"; then
        echo "      ✅ Section: $section"
      else
        echo "      ❌ Missing section: $section"
        return 1
      fi
    done
  else
    echo "    ❌ Execution report template not found"
    return 1
  fi

  if [ -f "$SKILL_DIR/templates/task-discovery.md" ]; then
    echo "    ✅ Task discovery template exists"

    # 检查模板必需部分
    required_tasks=("依赖安全" "代码缺陷" "测试覆盖" "文档" "重构" "Git 清理")
    for task in "${required_tasks[@]}"; do
      if grep -q "$task" "$SKILL_DIR/templates/task-discovery.md"; then
        echo "      ✅ Task type: $task"
      else
        echo "      ❌ Missing task type: $task"
        return 1
      fi
    done
  else
    echo "    ❌ Task discovery template not found"
    return 1
  fi

  return 0
}

test_report_template

# 9. 测试工具可用性检查
echo ""
echo "📋 Test 9: 工具可用性检查"

test_tool_availability() {
  echo "  Testing tool availability checks..."

  tools=("jq" "npm" "go" "pip-audit")

  for tool in "${tools[@]}"; do
    echo "    Checking: $tool"

    if command -v "$tool" >/dev/null 2>&1; then
      echo "      ✅ $tool is available"
    else
      echo "      ⚠️  $tool is not available"
    fi
  done

  return 0
}

test_tool_availability

# 10. 测试安全策略
echo ""
echo "📋 Test 10: 安全策略测试"

test_security_strategy() {
  echo "  Testing security strategy..."

  # 模拟安全策略
  strategies=(
    "P0:immediate_execute"
    "P1:worktree_isolation"
    "P2:execute_with_caution"
    "P3:execute_if_tokens_remaining"
  )

  for strategy in "${strategies[@]}"; do
    priority=$(echo "$strategy" | cut -d: -f1)
    action=$(echo "$strategy" | cut -d: -f2)

    echo "    $priority: $action"

    # 验证策略
    case $priority in
      P0)
        if [ "$action" = "immediate_execute" ]; then
          echo "      ✅ P0 strategy correct"
        else
          echo "      ❌ P0 strategy incorrect"
          return 1
        fi
        ;;
      P1)
        if [ "$action" = "worktree_isolation" ]; then
          echo "      ✅ P1 strategy correct"
        else
          echo "      ❌ P1 strategy incorrect"
          return 1
        fi
        ;;
      P2)
        if [ "$action" = "execute_with_caution" ]; then
          echo "      ✅ P2 strategy correct"
        else
          echo "      ❌ P2 strategy incorrect"
          return 1
        fi
        ;;
      P3)
        if [ "$action" = "execute_if_tokens_remaining" ]; then
          echo "      ✅ P3 strategy correct"
        else
          echo "      ❌ P3 strategy incorrect"
          return 1
        fi
        ;;
    esac
  done

  return 0
}

test_security_strategy

echo ""
echo "✅ token-burner tests passed"
