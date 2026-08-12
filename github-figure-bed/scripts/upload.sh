#!/bin/bash
# github-figure-bed: 通用 GitHub 图床上传脚本
# 依赖: gh CLI (已登录, 需 repo 权限), base64, jq
#
# 配置优先级 (高→低): 命令行参数 > 环境变量 IMGX_* > 脚本内 DEFAULT_* 默认区
#   环境变量: IMGX_OWNER / IMGX_REPO / IMGX_BRANCH / IMGX_CDN / IMGX_DIR
#   命令行:   --owner / --repo / --branch / --cdn / --dir / --force / --silent
#
# 分支说明: 不指定 --branch / IMGX_BRANCH / DEFAULT_BRANCH 时,
#   自动检测仓库 default_branch (一般就是 main, 零配置可用)
#
# CDN 可选: jsdelivr(默认) / jsdmirror / jsd-onmicrosoft / statically / raw
#
# 用法:
#   upload.sh <文件1> [文件2 ...] [--owner O] [--repo R] [--branch B] [--cdn C] [--dir 子目录] [--force] [--silent]
#
# 行为:
#   - 默认上传到 blog/ 目录 (可用 IMGX_DIR 或 --dir 改基础目录)
#   - 目标文件已存在时: 默认生成 <时间戳>_<原文件名> 避免覆盖已发布引用;
#     传 --force 则覆盖
#   - 输出 JSON 数组: {file, path, cdn_url, markdown, html_url, action}

set -euo pipefail

# ===== 个人默认配置区 (按需修改) =====
DEFAULT_OWNER=""        # 例: "wu529778790"
DEFAULT_REPO=""         # 例: "img.shenzjd.com"
DEFAULT_BRANCH=""       # 留空 = 自动检测仓库 default_branch
DEFAULT_CDN="jsdelivr"  # jsdelivr / jsdmirror / jsd-onmicrosoft / statically / raw
DEFAULT_DIR="blog"      # 图床基础目录
# ====================================

# 读取配置文件 (setup.sh 生成; 优先级: 命令行参数 > 环境变量 > 配置文件 > 默认区)
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/github-figure-bed/config.env"
if [[ -f "$CONFIG_FILE" ]]; then
  while IFS='=' read -r _KEY _VAL; do
    case "$_KEY" in
      IMGX_OWNER)  [[ -n "$_VAL" ]] && DEFAULT_OWNER="$_VAL" ;;
      IMGX_REPO)   [[ -n "$_VAL" ]] && DEFAULT_REPO="$_VAL" ;;
      IMGX_BRANCH) [[ -n "$_VAL" ]] && DEFAULT_BRANCH="$_VAL" ;;
      IMGX_CDN)    [[ -n "$_VAL" ]] && DEFAULT_CDN="$_VAL" ;;
      IMGX_DIR)    [[ -n "$_VAL" ]] && DEFAULT_DIR="$_VAL" ;;
    esac
  done < "$CONFIG_FILE"
fi

# 从环境变量覆盖默认值
[[ -n "${IMGX_OWNER:-}" ]] && DEFAULT_OWNER="$IMGX_OWNER"
[[ -n "${IMGX_REPO:-}" ]] && DEFAULT_REPO="$IMGX_REPO"
[[ -n "${IMGX_BRANCH:-}" ]] && DEFAULT_BRANCH="$IMGX_BRANCH"
[[ -n "${IMGX_CDN:-}" ]] && DEFAULT_CDN="$IMGX_CDN"
[[ -n "${IMGX_DIR:-}" ]] && DEFAULT_DIR="$IMGX_DIR"

OWNER="$DEFAULT_OWNER"
REPO="$DEFAULT_REPO"
BRANCH="$DEFAULT_BRANCH"
CDN="$DEFAULT_CDN"
FORCE=0
SILENT=0
SUB_DIR=""
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --cdn) CDN="$2"; shift 2 ;;
    --dir) SUB_DIR="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --silent) SILENT=1; shift ;;
    -h|--help)
      grep '^#' "$0" | head -30; exit 0 ;;
    --) shift; while [[ $# -gt 0 ]]; do FILES+=("$1"); shift; done ;;
    -*)
      echo "未知参数: $1 (查看用法: $0 --help)" >&2; exit 2 ;;
    *) FILES+=("$1"); shift ;;
  esac
done

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "用法: upload.sh <文件...> [--owner O] [--repo R] [--branch B] [--cdn C] [--dir 子目录] [--force] [--silent]" >&2
  exit 2
fi

# 校验目标仓库
if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "错误: 未指定目标仓库。请用 --owner/--repo, 或设置 IMGX_OWNER/IMGX_REPO 环境变量" >&2
  exit 2
fi

if ! gh auth status &>/dev/null; then
  echo "错误: gh 未登录, 请先运行 gh auth login" >&2
  exit 1
fi

# 分支自动检测 (未显式指定时)
if [[ -z "$BRANCH" ]]; then
  echo "提示: 未指定分支, 自动检测 ${OWNER}/${REPO} 默认分支..." >&2
  BRANCH=$(gh api "repos/${OWNER}/${REPO}" --jq .default_branch 2>/dev/null) \
    || { echo "错误: 无法获取仓库默认分支 (仓库存在吗?)" >&2; exit 1; }
  echo "   → 使用分支: ${BRANCH}" >&2
fi

# CDN 前缀
case "$CDN" in
  jsdelivr)        CDN_BASE="https://cdn.jsdelivr.net/gh/${OWNER}/${REPO}@${BRANCH}" ;;
  jsdmirror)       CDN_BASE="https://cdn.jsdmirror.com/gh/${OWNER}/${REPO}@${BRANCH}" ;;
  jsd-onmicrosoft) CDN_BASE="https://jsd.onmicrosoft.cn/gh/${OWNER}/${REPO}@${BRANCH}" ;;
  statically)      CDN_BASE="https://cdn.statically.io/gh/${OWNER}/${REPO}/${BRANCH}" ;;
  raw)             CDN_BASE="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}" ;;
  *) echo "未知 CDN: $CDN (可选: jsdelivr/jsdmirror/jsd-onmicrosoft/statically/raw)" >&2; exit 2 ;;
esac

# base64 编码 (兼容 macOS / Linux)
b64encode() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    base64 -i "$1" | tr -d '\n'
  else
    base64 -w0 "$1"
  fi
}

# 检查文件是否已存在 (0=存在, 1=不存在)
file_exists() {
  local path="$1"
  gh api "repos/${OWNER}/${REPO}/contents/${path}?ref=${BRANCH}" >/dev/null 2>&1
}

# 时间戳 + 随机数, 避免同秒批量传同名文件互相覆盖
timestamp() { date +%Y%m%d-%H%M%S_$RANDOM; }

RESULTS="["
FIRST=1

for LOCAL_FILE in "${FILES[@]}"; do
  if [[ ! -f "$LOCAL_FILE" ]]; then
    echo "{\"file\":\"$LOCAL_FILE\",\"error\":\"文件不存在\"}" >&2
    continue
  fi

  BASENAME=$(basename "$LOCAL_FILE")
  TARGET_PATH="${DEFAULT_DIR}"
  [[ -n "$SUB_DIR" ]] && TARGET_PATH="${TARGET_PATH}/${SUB_DIR}"
  TARGET_PATH="${TARGET_PATH}/${BASENAME}"

  ACTION="created"
  REMOTE_PATH="$TARGET_PATH"

  # 重名保护: 已存在且未 --force 时自动加时间戳前缀
  if file_exists "$REMOTE_PATH"; then
    if [[ "$FORCE" -eq 1 ]]; then
      ACTION="replaced"
    else
      PREFIX_PATH="${DEFAULT_DIR}"
      [[ -n "$SUB_DIR" ]] && PREFIX_PATH="${PREFIX_PATH}/${SUB_DIR}"
      REMOTE_PATH="${PREFIX_PATH}/$(timestamp)_${BASENAME}"
      ACTION="renamed"
    fi
  fi

  # 编码到临时文件 (避免命令行参数长度限制, 支持大图)
  TMP_B64=$(mktemp)
  TMP_JSON=$(mktemp)
  trap 'rm -f "$TMP_B64" "$TMP_JSON"' EXIT

  b64encode "$LOCAL_FILE" > "$TMP_B64"

  # 用文件流拼 JSON payload (base64 字符集无需转义)
  {
    printf '{"message":"[skip ci] upload via github-figure-bed","content":"'
    cat "$TMP_B64"
    printf '","branch":"%s"}' "$BRANCH"
  } > "$TMP_JSON"

  if RESP=$(gh api --method PUT "repos/${OWNER}/${REPO}/contents/${REMOTE_PATH}" \
    --input "$TMP_JSON" --jq '{sha: .content.sha, html_url: .content.html_url}' 2>/tmp/gfb_gh_err.txt); then
    HTML_URL=$(echo "$RESP" | jq -r .html_url)
    CDN_URL="${CDN_BASE}/${REMOTE_PATH}"
    MD="![${BASENAME}](${CDN_URL})"

    [[ "$SILENT" -eq 0 ]] && echo "✓ ${BASENAME} -> ${CDN_URL}" >&2

    if [[ "$FIRST" -eq 1 ]]; then FIRST=0; else RESULTS+=","; fi
    RESULTS+=$(jq -nc \
      --arg file "$LOCAL_FILE" \
      --arg path "$REMOTE_PATH" \
      --arg cdn_url "$CDN_URL" \
      --arg markdown "$MD" \
      --arg html_url "$HTML_URL" \
      --arg action "$ACTION" \
      '{file:$file, path:$path, cdn_url:$cdn_url, markdown:$markdown, html_url:$html_url, action:$action}')
  else
    echo "上传失败 ${LOCAL_FILE}: $(cat /tmp/gfb_gh_err.txt)" >&2
  fi

  # 每次迭代结束都清理临时文件 (成功与失败路径一致)
  rm -f "$TMP_B64" "$TMP_JSON"
  trap - EXIT
done

RESULTS+="]"
echo "$RESULTS" | jq .
