# 任务发现指南

本文档定义了 token-burner 如何在任意项目中自动发现可执行任务。

## 项目类型检测

```bash
# Node.js / TypeScript
test -f package.json && echo "node"

# Go
test -f go.mod && echo "go"

# Python
test -f requirements.txt -o -f pyproject.toml -o -f setup.py && echo "python"

# Rust
test -f Cargo.toml && echo "rust"

# Java
test -f pom.xml -o -f build.gradle && echo "java"
```

## 任务发现规则

### P0 - 安全和缺陷（立即执行）

**依赖安全扫描：**
```bash
# Node.js（需要 jq 和 package-lock.json）
if command -v jq >/dev/null 2>&1 && test -f package-lock.json; then
  audit_result=$(npm audit --json 2>/dev/null)
  if [ $? -ne 0 ] && [ -n "$audit_result" ]; then
    echo "$audit_result" | jq '.vulnerabilities | length' 2>/dev/null || echo "audit parse failed"
  fi
elif ! test -f package-lock.json; then
  echo "⚠️ 缺少 package-lock.json，跳过 npm audit"
fi

# Go（需要 govulncheck）
if command -v go >/dev/null 2>&1; then
  $(go env GOPATH)/bin/govulncheck ./... 2>/dev/null || echo "⚠️ govulncheck 未安装或执行失败"
fi

# Python（需要 pip-audit）
if command -v pip-audit >/dev/null 2>&1; then
  pip-audit 2>/dev/null || echo "⚠️ pip-audit 执行失败"
else
  echo "⚠️ pip-audit 未安装，运行: pip install pip-audit"
fi
```

**代码缺陷检测：**
- 检查 `git diff` 中的常见错误模式
- 搜索 `TODO: fix`、`FIXME`、`HACK` 标记
- 检查是否有未处理的错误（空 catch、忽略返回值）

### P1 - 测试覆盖（高优先级）

**无测试文件检测：**
```bash
# Node.js - 找没有对应测试的源文件（需要 shopt -s globstar 递归匹配）
shopt -s globstar
for f in src/**/*.ts; do
  test_file="${f%.ts}.test.ts"
  test -f "$test_file" || echo "Missing test: $f"
done

# Go - 检查测试覆盖率
go test -coverprofile=coverage.out ./... 2>/dev/null
go tool cover -func=coverage.out | grep "total:"
```

**低覆盖率检测：**
- 覆盖率 < 50% 的文件 → 生成测试任务
- 覆盖率 50-80% 的文件 → 补充边界测试

### P2 - 文档和重构（中优先级）

**文档缺失检测：**
```bash
# 检查 README 是否存在
test -f README.md || echo "Missing README.md"

# 检查函数注释（Go）
grep -r "^func " --include="*.go" | head -20

# 检查 API 文档
test -d docs/api || echo "Missing API docs"
```

**代码重复检测：**
```bash
# 简单的重复行检测
sort file.ts | uniq -d | head -10

# 复杂度检测（需要工具）
# npx complexity-report src/ --maxcomplexity 10
```

### P3 - Git 清理（低优先级）

**过时分支检测：**
```bash
git branch --merged main | grep -v "main\|master"
```

**大文件检测：**
```bash
git ls-files | xargs ls -lS 2>/dev/null | sort -rn | head -10
```

**Conflict markers 检测：**
```bash
grep -r "<<<<<<" --include="*.ts" --include="*.js" --include="*.go" .
```

## 任务评分公式

```
score = impact_score × (1 - risk_score)

impact_score:
  security_vulnerability = 3
  bug_fix = 3
  test_coverage = 2
  documentation = 2
  refactoring = 2
  cleanup = 1

risk_score:
  change_business_logic = 0.8
  add_tests = 0.4
  add_docs = 0.4
  read_only_analysis = 0.1
```

## 任务输出格式

每个发现的任务输出为：

```json
{
  "id": "task-001",
  "type": "security|bug|test|docs|refactor|clean",
  "priority": "P0|P1|P2|P3",
  "file": "path/to/file",
  "description": "简短描述",
  "impact": "high|medium|low",
  "risk": "high|medium|low",
  "score": 2.4,
  "prompt": "执行此任务的具体指令"
}
```
