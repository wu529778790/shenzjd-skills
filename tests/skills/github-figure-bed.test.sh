#!/bin/bash
# GitHub Figure Bed 静态测试
# 注意: 脚本依赖 gh CLI 和真实 GitHub 仓库, 这里只做静态检查(文件存在性/关键逻辑),
# 不做真实上传/删除, 避免网络依赖。

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/github-figure-bed"

echo "🧪 Testing github-figure-bed"
echo "============================"

# 1. 测试脚本文件存在且可执行
echo ""
echo "📋 Test 1: 脚本文件存在性"
for script in setup.sh upload.sh delete.sh list.sh; do
  if [ -f "$SKILL_DIR/scripts/$script" ]; then
    echo "  ✅ 脚本存在: $script"
  else
    echo "  ❌ 缺少脚本: $script"
    exit 1
  fi
  if [ -x "$SKILL_DIR/scripts/$script" ]; then
    echo "    ✅ 可执行权限: $script"
  else
    echo "    ⚠️  缺少可执行权限: $script (需要 chmod +x)"
  fi
done

# 2. 测试 SKILL.md 引用完整性
echo ""
echo "📋 Test 2: SKILL.md 引用完整性"
for script in setup.sh upload.sh delete.sh list.sh; do
  if grep -q "scripts/$script" "$SKILL_DIR/SKILL.md"; then
    echo "  ✅ SKILL.md 引用: scripts/$script"
  else
    echo "  ❌ SKILL.md 未引用: scripts/$script"
    exit 1
  fi
done
if grep -q "references/cdn-links.md" "$SKILL_DIR/SKILL.md"; then
  echo "  ✅ SKILL.md 引用: references/cdn-links.md"
else
  echo "  ❌ SKILL.md 未引用: references/cdn-links.md"
  exit 1
fi

# 3. 测试 CDN 链接格式(检查脚本中 jsdelivr 系 @分支 语法)
echo ""
echo "📋 Test 3: CDN 链接格式"
if grep -q "cdn.jsdelivr.net/gh/\${OWNER}/\${REPO}@\${BRANCH}" "$SKILL_DIR/scripts/upload.sh"; then
  echo "  ✅ jsdelivr 链接含 @branch"
else
  echo "  ❌ jsdelivr 链接缺少 @branch (jsdelivr 默认找 main, 不带 @branch 必 404)"
  exit 1
fi
if grep -q "cdn.jsdmirror.com/gh/\${OWNER}/\${REPO}@\${BRANCH}" "$SKILL_DIR/scripts/upload.sh"; then
  echo "  ✅ jsdmirror 链接含 @branch"
else
  echo "  ❌ jsdmirror 链接缺少 @branch"
  exit 1
fi

# 4. 测试配置联动逻辑(setup.sh 与项目配置共用 .imgx-config/config.json)
echo ""
echo "📋 Test 4: 配置联动"
if grep -q "REMOTE_CONFIG_PATH=" "$SKILL_DIR/scripts/setup.sh"; then
  echo "  ✅ setup.sh 定义远程配置路径"
else
  echo "  ❌ setup.sh 缺少 REMOTE_CONFIG_PATH"
  exit 1
fi
if grep -q "\.imgx-config/config\.json" "$SKILL_DIR/scripts/setup.sh"; then
  echo "  ✅ 与项目网页端共用 .imgx-config/config.json"
else
  echo "  ❌ setup.sh 未引用 .imgx-config/config.json"
  exit 1
fi
if grep -q "config.env" "$SKILL_DIR/scripts/setup.sh"; then
  echo "  ✅ 本地缓存 config.env"
else
  echo "  ❌ setup.sh 未写本地缓存 config.env"
  exit 1
fi

# 5. 测试重名保护(默认换名, --force 覆盖)
echo ""
echo "📋 Test 5: 重名保护"
if grep -q 'timestamp.*BASENAME\|timestamp.*原文件' "$SKILL_DIR/scripts/upload.sh"; then
  echo "  ✅ 重名自动换名保护"
else
  echo "  ❌ upload.sh 缺少重名保护逻辑"
  exit 1
fi
if grep -q '\-\-force' "$SKILL_DIR/scripts/upload.sh"; then
  echo "  ✅ --force 覆盖选项"
else
  echo "  ❌ upload.sh 缺少 --force 选项"
  exit 1
fi

# 6. 测试安全要点(不在脚本中硬编码 token/密码)
echo ""
echo "📋 Test 6: 安全要点"
for script in setup.sh upload.sh delete.sh list.sh; do
  if grep -qE 'ghp_[A-Za-z0-9]{20,}|password\s*=|secret\s*=|token\s*=' "$SKILL_DIR/scripts/$script" 2>/dev/null; then
    echo "  ❌ $script 疑似硬编码凭据"
    exit 1
  fi
done
echo "  ✅ 无硬编码凭据"

echo ""
echo "✅ github-figure-bed tests passed"
