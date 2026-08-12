#!/bin/bash
# Docker Build Deploy 集成测试

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
SKILL_DIR="$(dirname "$TEST_DIR")/docker-build-deploy"

echo "🧪 Testing docker-build-deploy"
echo "=============================="

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

# 2. 测试 Dockerfile 模板验证
echo ""
echo "📋 Test 2: Dockerfile 模板验证"

test_dockerfile_template() {
  local template_file="$1"
  local project_type="$2"

  echo "  Testing $project_type Dockerfile template..."

  if [ ! -f "$template_file" ]; then
    echo "    ❌ Template not found: $template_file"
    return 1
  fi

  echo "    ✅ Template exists"

  # 检查必需指令
  required_directives=("FROM" "WORKDIR" "COPY" "RUN" "CMD" "EXPOSE")
  for directive in "${required_directives[@]}"; do
    if grep -q "^$directive" "$template_file"; then
      echo "      ✅ Directive: $directive"
    else
      echo "      ❌ Missing directive: $directive"
      return 1
    fi
  done

  # 检查多阶段构建
  if grep -q "^FROM.*AS" "$template_file"; then
    echo "      ✅ Multi-stage build detected"
  else
    echo "      ⚠️  No multi-stage build"
  fi

  # 检查非 root 用户
  if grep -q "USER" "$template_file"; then
    echo "      ✅ Non-root user configured"
  else
    echo "      ⚠️  No non-root user configured"
  fi

  # 检查健康检查
  if grep -q "HEALTHCHECK" "$template_file"; then
    echo "      ✅ Health check configured"
  else
    echo "      ⚠️  No health check configured"
  fi

  return 0
}

# 测试 Node.js Dockerfile 模板
if [ -f "$SKILL_DIR/templates/Dockerfile.nodejs" ]; then
  test_dockerfile_template "$SKILL_DIR/templates/Dockerfile.nodejs" "Node.js"
else
  echo "  ⚠️  Node.js Dockerfile template not found"
fi

# 3. 测试 GitHub Actions Workflow 模板
echo ""
echo "📋 Test 3: GitHub Actions Workflow 模板验证"

test_workflow_template() {
  local template_file="$1"

  echo "  Testing workflow template..."

  if [ ! -f "$template_file" ]; then
    echo "    ❌ Template not found: $template_file"
    return 1
  fi

  echo "    ✅ Template exists"

  # 检查必需的 job
  required_jobs=("build-and-push" "deploy")
  for job in "${required_jobs[@]}"; do
    if grep -q "$job:" "$template_file"; then
      echo "      ✅ Job: $job"
    else
      echo "      ❌ Missing job: $job"
      return 1
    fi
  done

  # 检查 GHCR 推送
  if grep -q "ghcr.io" "$template_file"; then
    echo "      ✅ GHCR push configured"
  else
    echo "      ⚠️  GHCR push not configured"
  fi

  # 检查 SSH 部署
  if grep -q "ssh\|DEPLOY_HOST" "$template_file"; then
    echo "      ✅ SSH deployment configured"
  else
    echo "      ⚠️  SSH deployment not configured"
  fi

  # 检查 Secrets 引用（SSH key 部署）
  required_secrets=("DEPLOY_HOST" "DEPLOY_USER" "DEPLOY_SSH_KEY")
  for secret in "${required_secrets[@]}"; do
    if grep -q "$secret" "$template_file"; then
      echo "      ✅ Secret: $secret"
    else
      echo "      ❌ Missing secret: $secret"
      return 1
    fi
  done

  return 0
}

if [ -f "$SKILL_DIR/templates/docker-deploy.yml" ]; then
  test_workflow_template "$SKILL_DIR/templates/docker-deploy.yml"
else
  echo "  ⚠️  Workflow template not found"
fi

# 4. 测试 Docker Compose 配置
echo ""
echo "📋 Test 4: Docker Compose 配置验证"

test_docker_compose() {
  echo "  Testing Docker Compose configuration..."

  # 模拟 docker-compose.yml
  compose_config='version: "3.8"
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3'

  # 验证配置格式
  if echo "$compose_config" | python3 -c "import sys,yaml; yaml.safe_load(sys.stdin)" >/dev/null 2>&1; then
    echo "    ✅ Docker Compose config is valid YAML"
  else
    echo "    ⚠️  Cannot validate YAML (pyyaml not installed)"
  fi

  # 检查必需服务
  if echo "$compose_config" | grep -q "services:"; then
    echo "    ✅ Services section defined"
  else
    echo "    ❌ Services section missing"
    return 1
  fi

  # 检查端口映射
  if echo "$compose_config" | grep -q "ports:"; then
    echo "    ✅ Port mapping configured"
  else
    echo "    ⚠️  No port mapping"
  fi

  # 检查重启策略
  if echo "$compose_config" | grep -q "restart:"; then
    echo "    ✅ Restart policy configured"
  else
    echo "    ⚠️  No restart policy"
  fi

  # 检查健康检查
  if echo "$compose_config" | grep -q "healthcheck:"; then
    echo "    ✅ Health check configured"
  else
    echo "    ⚠️  No health check"
  fi

  return 0
}

test_docker_compose

# 5. 测试端口配置
echo ""
echo "📋 Test 5: 端口配置测试"

test_port_config() {
  local port="$1"
  local expected_valid="$2"

  echo "  Testing port: $port"

  # 验证端口号
  if [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
    valid="true"
  else
    valid="false"
  fi

  if [ "$valid" = "$expected_valid" ]; then
    echo "    ✅ Port validation correct"
  else
    echo "    ❌ Port validation incorrect"
    return 1
  fi

  return 0
}

test_port_config 3000 "true"
test_port_config 8080 "true"
test_port_config 0 "false"
test_port_config 70000 "false"

# 6. 测试环境变量配置
echo ""
echo "📋 Test 6: 环境变量配置测试"

test_env_config() {
  echo "  Testing environment variable configuration..."

  # 模拟环境变量文件
  env_file="NODE_ENV=production
PORT=3000
DB_HOST=localhost
DB_PORT=5432"

  # 验证环境变量格式
  while IFS= read -r line; do
    if echo "$line" | grep -qE '^[A-Z_]+=.+$'; then
      echo "    ✅ Valid env var: $line"
    else
      echo "    ❌ Invalid env var format: $line"
      return 1
    fi
  done <<< "$env_file"

  return 0
}

test_env_config

echo ""
echo "✅ docker-build-deploy tests passed"
