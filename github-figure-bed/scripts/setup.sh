#!/bin/bash
# github-figure-bed: 一键初始化 — 登录引导 + 自动配置 + 仓库就绪
# 依赖: gh CLI (未登录时自动引导登录)
#
# 用法:
#   setup.sh [--repo <仓库名>] [--cdn <cdn>] [--dir <目录>] [--no-test] [--force-readme]
#
# 流程:
#   1. 检查 gh 是否安装; 未登录 → 引导 gh auth login (输出 code + 打开浏览器)
#   2. 获取当前登录用户 (自动成为 Owner, 无需手填)
#   3. 检查目标仓库 (默认 img.shenzjd.com):
#      - 不存在 → gh repo create 创建 (public + README), 并写入宣传/使用说明 README
#      - 已存在 → 直接使用 (不覆盖原 README)
#   4. 探测图片目录实际所在分支 (避免 default_branch 与图片分支不一致的坑)
#   5. 写入配置文件 ~/.config/github-figure-bed/config.env (upload/delete/list 自动读取)
#   6. 默认生成 1x1 测试图 上传→删除 验证全链路 (--no-test 跳过)
#   7. 输出最终配置与 CDN 示例

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/github-figure-bed"
CONFIG_FILE="$CONFIG_DIR/config.env"

DEFAULT_REPO_NAME="img.shenzjd.com"
DEFAULT_CDN="jsdelivr"
DEFAULT_DIR="blog"

REPO="$DEFAULT_REPO_NAME"
CDN="$DEFAULT_CDN"
RUN_TEST=1
FORCE_README=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --cdn) CDN="$2"; shift 2 ;;
    --dir) DEFAULT_DIR="$2"; shift 2 ;;
    --no-test) RUN_TEST=0; shift ;;
    --force-readme) FORCE_README=1; shift ;;
    -h|--help) grep '^#' "$0" | head -25; exit 0 ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

# ---- 1. gh 安装检查 ----
if ! command -v gh &>/dev/null; then
  echo "❌ 未安装 gh CLI。请先安装:"
  echo "   macOS:  brew install gh"
  echo "   Linux:  sudo apt install gh  或参考 https://cli.github.com"
  exit 1
fi

# ---- 2. 登录引导 ----
if ! gh auth status &>/dev/null; then
  echo ""
  echo "🔑 需要先登录 GitHub 账号 (只需一次)。"
  echo "   即将打开浏览器完成授权 — 如果浏览器没有自动打开,"
  echo "   请复制下面输出的链接手动打开, 并在页面中输入 one-time code 完成登录。"
  echo ""
  gh auth login --web --hostname github.com --git-protocol https --skip-ssh-key || true
  if ! gh auth status &>/dev/null; then
    echo "❌ 登录未完成, 请重试 setup.sh" >&2
    exit 1
  fi
  echo "✅ 登录成功!"
else
  echo "✅ 已登录 GitHub"
fi

# ---- 3. 获取当前用户 (自动成为 Owner) ----
OWNER=$(gh api user --jq .login)
echo "   Owner: ${OWNER}"

# ---- 4. 仓库检测/创建 ----
CREATED=0
if gh api "repos/${OWNER}/${REPO}" >/dev/null 2>&1; then
  echo "✓ 仓库 ${OWNER}/${REPO} 已存在, 直接使用"
else
  echo "🚀 创建图床仓库 ${OWNER}/${REPO} ..."
  gh repo create "$REPO" --public --add-readme \
    --description "GitHub figure bed — images hosted with CDN links (managed by github-figure-bed skill)" \
    || { echo "❌ 创建仓库失败 (检查仓库名是否已被占用)" >&2; exit 1; }
  CREATED=1
  echo "✅ 仓库已创建"
fi

# ---- 5. 分支探测: 找图片目录实际所在分支 ----
# (网络异常时降级到 default_branch/main, 上传时 upload.sh 还会自行检测)
DEFAULT_BRANCH=$(gh api "repos/${OWNER}/${REPO}" --jq .default_branch 2>/dev/null || echo "main")
BRANCH="$DEFAULT_BRANCH"
for b in "$DEFAULT_BRANCH" master main; do
  if gh api "repos/${OWNER}/${REPO}/contents/${DEFAULT_DIR}?ref=$b" >/dev/null 2>&1; then
    BRANCH="$b"; break
  fi
done
echo "✓ 分支: ${BRANCH} (图片目录 ${DEFAULT_DIR}/)"

# ---- 6. 宣传 README (仅新建仓库时, 或 --force-readme) ----
if [[ "$CREATED" -eq 1 || "$FORCE_README" -eq 1 ]]; then
  echo "✍️  写入宣传 README ..."

  README_MD=$(cat <<'EOF'
# 🖼️ GitHub Figure Bed

> 由 **github-figure-bed** AI 技能自动创建的图床仓库 — 上传图片，秒得 CDN 加速链接。

## 这是什么

把 GitHub 当图床：图片存放在本仓库的 `blog/` 目录，通过全球 CDN（jsdelivr / jsdmirror）加速访问。
不需要自己搭建服务器，容量=仓库容量，速度=CDN 速度，零成本。

## 怎么用（交给 AI 就行）

所有操作对 AI 说一句话即可，**无需手动配置**：

| 你想做的事 | 直接说 |
|-----------|--------|
| 上传图片 | 「上传 xxx.png 到图床」→ 得到 CDN/Markdown 链接 |
| 查看图片 | 「图床里有哪些图」 |
| 删除图片 | 「删掉 xxx.png」 |

底层由开源技能 [github-figure-bed](https://github.com/wu529778790/shenzjd-skills) 驱动：

```bash
npx skills add wu529778790/shenzjd-skills -s github-figure-bed -y
```

首次使用运行 `setup.sh` 一键初始化（自动登录引导 + 配置），之后零配置直接上传。

## 链接格式

```
https://cdn.jsdelivr.net/gh/<owner>/<repo>@<branch>/blog/<文件名>
```

Markdown 引用：

```markdown
![文件名](https://cdn.jsdelivr.net/gh/<owner>/<repo>@<branch>/blog/<文件名>)
```

> 提示: 大陆用户可将 CDN 换成 jsdmirror（`IMGX_CDN=jsdmirror`）。
EOF
)

  # base64 编码 (兼容 macOS / Linux)
  if [[ "$(uname -s)" == "Darwin" ]]; then
    README_B64=$(printf '%s' "$README_MD" | base64 | tr -d '\n')
  else
    README_B64=$(printf '%s' "$README_MD" | base64 -w0)
  fi

  TMP_JSON=$(mktemp)
  trap 'rm -f "$TMP_JSON"' EXIT
  {
    printf '{"message":"docs: init figure bed README","content":"%s","branch":"%s"}' "$README_B64" "$BRANCH"
  } > "$TMP_JSON"

  gh api --method PUT "repos/${OWNER}/${REPO}/contents/README.md" --input "$TMP_JSON" >/dev/null 2>&1 \
    && echo "✅ 宣传 README 已写入" || echo "⚠️  README 写入失败 (不影响上传功能)"
fi

# ---- 7. 写入配置文件 (upload/delete/list 自动读取) ----
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_FILE" <<EOF
# 由 github-figure-bed setup.sh 自动生成, 无需手动编辑
IMGX_OWNER=${OWNER}
IMGX_REPO=${REPO}
IMGX_BRANCH=${BRANCH}
IMGX_CDN=${CDN}
IMGX_DIR=${DEFAULT_DIR}
EOF
echo "✅ 配置已写入 ${CONFIG_FILE}"

# ---- 8. 测试上传 (默认开启, 验证全链路) ----
if [[ "$RUN_TEST" -eq 1 ]]; then
  echo ""
  echo "🧪 测试上传一张 1x1 图片验证全链路 ..."
  TEST_PNG="$(mktemp -t gfb-setup).png"
  if [[ "$(uname -s)" == "Darwin" ]]; then B64DEC="base64 -D"; else B64DEC="base64 -d"; fi
  echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==" | $B64DEC > "$TEST_PNG" 2>/dev/null

  if "$SCRIPT_DIR/upload.sh" "$TEST_PNG" --silent >/tmp/gfb-setup-upload.json 2>&1; then
    CDN_URL=$(jq -r '.[0].cdn_url // empty' /tmp/gfb-setup-upload.json 2>/dev/null || true)
    FNAME=$(basename "$TEST_PNG")
    "$SCRIPT_DIR/delete.sh" "$FNAME" --silent >/dev/null 2>&1 || true
    if [[ -n "$CDN_URL" ]]; then
      echo "✅ 测试通过! 已成功上传并删除, CDN 链接示例:"
      echo "   $CDN_URL"
    else
      echo "⚠️  上传成功但解析失败, 请手动确认"
    fi
  else
    echo "⚠️  测试上传失败 (不影响配置, 可稍后重试):"
    cat /tmp/gfb-setup-upload.json >&2
  fi
  rm -f "$TEST_PNG" /tmp/gfb-setup-upload.json
fi

# ---- 9. 输出总结 ----
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 初始化完成! 现在可以直接对 AI 说:"
echo "   「上传 xxx.png 到图床」"
echo ""
echo "配置汇总:"
echo "   Owner : ${OWNER}"
echo "   仓库  : ${OWNER}/${REPO} (分支 ${BRANCH})"
echo "   目录  : ${DEFAULT_DIR}/  CDN: ${CDN}"
case "$CDN" in
  jsdelivr)        CDN_EXAMPLE="https://cdn.jsdelivr.net/gh/${OWNER}/${REPO}@${BRANCH}/${DEFAULT_DIR}/xxx.png" ;;
  jsdmirror)       CDN_EXAMPLE="https://cdn.jsdmirror.com/gh/${OWNER}/${REPO}@${BRANCH}/${DEFAULT_DIR}/xxx.png" ;;
  jsd-onmicrosoft) CDN_EXAMPLE="https://jsd.onmicrosoft.cn/gh/${OWNER}/${REPO}@${BRANCH}/${DEFAULT_DIR}/xxx.png" ;;
  statically)      CDN_EXAMPLE="https://cdn.statically.io/gh/${OWNER}/${REPO}/${BRANCH}/${DEFAULT_DIR}/xxx.png" ;;
  raw)             CDN_EXAMPLE="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${DEFAULT_DIR}/xxx.png" ;;
  *)               CDN_EXAMPLE="https://cdn.jsdelivr.net/gh/${OWNER}/${REPO}@${BRANCH}/${DEFAULT_DIR}/xxx.png" ;;
esac
echo "   CDN示例: ${CDN_EXAMPLE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
