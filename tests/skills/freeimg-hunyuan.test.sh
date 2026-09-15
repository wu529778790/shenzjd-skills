#!/bin/bash
# freeimg-hunyuan 静态测试
# 注意: 真实生成依赖腾讯云凭据、资源包和网络, 这里只做静态检查与离线参数校验。

set -e

TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$(dirname "$TEST_DIR")/freeimg-hunyuan"

echo "🧪 Testing freeimg-hunyuan"
echo "=========================="

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
if grep -q "https://freeimg.shenzjd.com/hunyuan" "$SKILL_DIR/SKILL.md"; then
  echo "  ✅ SKILL.md 引用网页版: https://freeimg.shenzjd.com/hunyuan"
else
  echo "  ❌ SKILL.md 缺少网页版链接"
  exit 1
fi
if grep -q "TCB_SECRET_ID" "$SKILL_DIR/SKILL.md"; then
  echo "  ✅ SKILL.md 说明凭据配置: TCB_SECRET_ID"
else
  echo "  ❌ SKILL.md 缺少凭据配置说明"
  exit 1
fi

# 3. 测试安全红线: 仓库内不得出现真实密钥
echo ""
echo "📋 Test 3: 密钥不入库"
# 腾讯云 SecretId 形如 AKID + 32 位字母数字; .env / config 一律不应存在于 skill 目录
if grep -rEq "AKID[A-Za-z0-9]{13,}" "$SKILL_DIR" 2>/dev/null; then
  echo "  ❌ 疑似 SecretId 硬编码在 skill 目录中"
  exit 1
else
  echo "  ✅ 无硬编码密钥"
fi
if find "$SKILL_DIR" -name ".env" -o -name "config.env" | grep -q .; then
  echo "  ❌ skill 目录中不应存在 .env / config.env"
  exit 1
else
  echo "  ✅ 无配置文件残留"
fi

# 4. 离线参数校验: 缺少凭据时引导配置, 缺少 --prompt 时打印用法, 尺寸白名单
echo ""
echo "📋 Test 4: 离线参数校验"
out="$(env -u TCB_ENV_ID -u TCB_SECRET_ID -u TCB_SECRET_KEY -u FREEIMG_HUNYUAN_CONFIG HOME="$TEST_DIR/no-home" node "$SKILL_DIR/scripts/generate.mjs" --prompt x --out /tmp/freeimg-hunyuan-test.png 2>&1 || true)"
if echo "$out" | grep -q "cam/capi"; then
  echo "  ✅ 缺少凭据时输出获取引导"
else
  echo "  ❌ 缺少凭据时应输出获取引导, 实际: $out"
  exit 1
fi
out="$(TCB_ENV_ID=e TCB_SECRET_ID=s TCB_SECRET_KEY=k node "$SKILL_DIR/scripts/generate.mjs" --out /tmp/freeimg-hunyuan-test.png 2>&1 || true)"
if echo "$out" | grep -q "usage:"; then
  echo "  ✅ 缺少 --prompt 时打印用法"
else
  echo "  ❌ 缺少 --prompt 时应打印 usage, 实际: $out"
  exit 1
fi
out="$(TCB_ENV_ID=e TCB_SECRET_ID=s TCB_SECRET_KEY=k node "$SKILL_DIR/scripts/generate.mjs" --prompt x --size 1536x2048 2>&1 || true)"
if echo "$out" | grep -q "只支持"; then
  echo "  ✅ 非法尺寸被拒绝"
else
  echo "  ❌ --size 1536x2048 应被拒绝, 实际: $out"
  exit 1
fi
out="$(TCB_ENV_ID=e TCB_SECRET_ID=s TCB_SECRET_KEY=k node "$SKILL_DIR/scripts/generate.mjs" --prompt "$(head -c 8000 /dev/zero | tr '\0' 'a')" 2>&1 || true)"
if echo "$out" | grep -q "最多 4000 字"; then
  echo "  ✅ 超长提示词被拒绝"
else
  echo "  ❌ 8000 字提示词应被拒绝, 实际: $out"
  exit 1
fi

echo ""
echo "✅ freeimg-hunyuan 全部测试通过"
