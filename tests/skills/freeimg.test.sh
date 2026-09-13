#!/bin/bash
# freeimg 静态测试
# 注意: 真实生成依赖 Gitee AI 令牌和网络, 这里只做静态检查与离线参数校验。

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/freeimg"

echo "🧪 Testing freeimg"
echo "=================="

# 1. 测试脚本文件存在且语法正确
echo ""
echo "📋 Test 1: 脚本文件存在性"
if [ -f "$SKILL_DIR/scripts/generate.mjs" ]; then
  echo "  ✅ 脚本存在: scripts/generate.mjs"
else
  echo "  ❌ 缺少脚本: scripts/generate.mjs"
  exit 1
fi
if node --check "$SKILL_DIR/scripts/generate.mjs" 2>/dev/null; then
  echo "  ✅ 语法检查通过: node --check"
else
  echo "  ❌ 语法错误: node --check generate.mjs"
  exit 1
fi

# 2. 测试 SKILL.md 引用完整性
echo ""
echo "📋 Test 2: SKILL.md 引用完整性"
if grep -q "scripts/generate.mjs" "$SKILL_DIR/SKILL.md"; then
  echo "  ✅ SKILL.md 引用: scripts/generate.mjs"
else
  echo "  ❌ SKILL.md 未引用: scripts/generate.mjs"
  exit 1
fi
if grep -q "https://freeimg.shenzjd.com" "$SKILL_DIR/SKILL.md"; then
  echo "  ✅ SKILL.md 引用网页版: https://freeimg.shenzjd.com"
else
  echo "  ❌ SKILL.md 缺少网页版链接"
  exit 1
fi

# 3. 测试安全红线: 仓库内不得出现真实令牌
echo ""
echo "📋 Test 3: 令牌不入库"
# Gitee AI 令牌为 40 位大写字母数字; .env / config 一律不应存在于 skill 目录
if grep -rEq "[A-Z0-9]{40}" "$SKILL_DIR" 2>/dev/null; then
  echo "  ❌ 疑似令牌硬编码在 skill 目录中"
  exit 1
else
  echo "  ✅ 无硬编码令牌"
fi
if find "$SKILL_DIR" -name ".env" -o -name "config.env" | grep -q .; then
  echo "  ❌ skill 目录中不应存在 .env / config.env"
  exit 1
else
  echo "  ✅ 无配置文件残留"
fi

# 4. 离线参数校验: 缺少令牌时引导配置, 缺少 --prompt 时打印用法
echo ""
echo "📋 Test 4: 离线参数校验"
# HOME 指向空目录, 防止读到本机 ~/.freeimg/config.env 真实令牌而真实调用 API
out="$(GITEE_AI_API_KEY= FREEIMG_CONFIG="$TEST_DIR/no-config.env" HOME="$TEST_DIR/no-home" node "$SKILL_DIR/scripts/generate.mjs" --prompt x --out /tmp/freeimg-test.png 2>&1 || true)"
if echo "$out" | grep -q "ai.gitee.com/serverless-api"; then
  echo "  ✅ 缺少令牌时输出获取引导"
else
  echo "  ❌ 缺少令牌时应输出获取引导, 实际: $out"
  exit 1
fi
out="$(GITEE_AI_API_KEY=fake node "$SKILL_DIR/scripts/generate.mjs" --out /tmp/freeimg-test.png 2>&1 || true)"
if echo "$out" | grep -q "usage:"; then
  echo "  ✅ 缺少 --prompt 时打印用法"
else
  echo "  ❌ 缺少 --prompt 时应打印 usage, 实际: $out"
  exit 1
fi
out="$(GITEE_AI_API_KEY=fake node "$SKILL_DIR/scripts/generate.mjs" --prompt x --width 500 2>&1 || true)"
if echo "$out" | grep -q "8 的倍数"; then
  echo "  ✅ 尺寸非 8 倍数时拒绝"
else
  echo "  ❌ --width 500 应被拒绝(8 的倍数), 实际: $out"
  exit 1
fi

echo ""
echo "✅ freeimg 全部测试通过"
