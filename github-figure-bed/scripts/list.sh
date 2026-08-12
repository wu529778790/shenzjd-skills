#!/bin/bash
# github-figure-bed: 通用 GitHub 图床列表脚本
#
# 配置优先级 (高→低): 命令行参数 > 环境变量 IMGX_* > 脚本内 DEFAULT_* 默认区
#   环境变量: IMGX_OWNER / IMGX_REPO / IMGX_BRANCH / IMGX_DIR
#   命令行:   --owner / --repo / --branch / --dir / --limit / --full
#
# 用法:
#   list.sh [关键词] [--owner O] [--repo R] [--branch B] [--dir 子目录] [--limit N] [--full]
#
# 说明:
#   - 使用 Git Trees API 一次拉取全量文件树, 过滤基础目录 (默认 blog/) 下的文件
#   - 传关键词则按文件名模糊过滤
#   - --limit N 限制条数 (默认 50)
#   - --full 输出完整 JSON (含 size)

set -euo pipefail

# ===== 个人默认配置区 (按需修改, 与 upload.sh 保持一致) =====
DEFAULT_OWNER=""
DEFAULT_REPO=""
DEFAULT_BRANCH=""
DEFAULT_DIR="blog"
# ============================================================

# 读取配置文件 (setup.sh 生成; 优先级: 命令行参数 > 环境变量 > 配置文件 > 默认区)
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/github-figure-bed/config.env"
if [[ -f "$CONFIG_FILE" ]]; then
  while IFS='=' read -r _KEY _VAL; do
    case "$_KEY" in
      IMGX_OWNER)  [[ -n "$_VAL" ]] && DEFAULT_OWNER="$_VAL" ;;
      IMGX_REPO)   [[ -n "$_VAL" ]] && DEFAULT_REPO="$_VAL" ;;
      IMGX_BRANCH) [[ -n "$_VAL" ]] && DEFAULT_BRANCH="$_VAL" ;;
      IMGX_DIR)    [[ -n "$_VAL" ]] && DEFAULT_DIR="$_VAL" ;;
    esac
  done < "$CONFIG_FILE"
fi

[[ -n "${IMGX_OWNER:-}" ]] && DEFAULT_OWNER="$IMGX_OWNER"
[[ -n "${IMGX_REPO:-}" ]] && DEFAULT_REPO="$IMGX_REPO"
[[ -n "${IMGX_BRANCH:-}" ]] && DEFAULT_BRANCH="$IMGX_BRANCH"
[[ -n "${IMGX_DIR:-}" ]] && DEFAULT_DIR="$IMGX_DIR"

OWNER="$DEFAULT_OWNER"
REPO="$DEFAULT_REPO"
BRANCH="$DEFAULT_BRANCH"
LIMIT=50
KEYWORD=""
FULL=0
SUB_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --dir) SUB_DIR="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --full) FULL=1; shift ;;
    -h|--help)
      grep '^#' "$0" | head -20; exit 0 ;;
    --) shift; KEYWORD="${1:-}"; break ;;
    -*)
      echo "未知参数: $1" >&2; exit 2 ;;
    *) KEYWORD="$1"; shift ;;
  esac
done

if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "错误: 未指定目标仓库。请用 --owner/--repo, 或设置 IMGX_OWNER/IMGX_REPO 环境变量" >&2
  exit 2
fi

if ! gh auth status &>/dev/null; then
  echo "错误: gh 未登录" >&2
  exit 1
fi

if [[ -z "$BRANCH" ]]; then
  BRANCH=$(gh api "repos/${OWNER}/${REPO}" --jq .default_branch 2>/dev/null) \
    || { echo "错误: 无法获取仓库默认分支" >&2; exit 1; }
  echo "提示: 自动检测分支 → ${BRANCH}" >&2
fi

PREFIX="${DEFAULT_DIR}"
[[ -n "$SUB_DIR" ]] && PREFIX="${DEFAULT_DIR}/${SUB_DIR}"

if [[ "$FULL" -eq 1 ]]; then
  gh api "repos/${OWNER}/${REPO}/git/trees/${BRANCH}?recursive=1" \
    | jq --arg p "$PREFIX/" --arg kw "$KEYWORD" --argjson n "$LIMIT" \
    '[.tree[] | select(.type=="blob" and (.path | startswith($p))) |
      {name: (.path | split("/")[-1]), path: .path, size: .size} |
      select(($kw == "") or (.name | contains($kw)))] | .[0:$n]'
else
  gh api "repos/${OWNER}/${REPO}/git/trees/${BRANCH}?recursive=1" \
    | jq --arg p "$PREFIX/" --arg kw "$KEYWORD" --argjson n "$LIMIT" \
    '[.tree[] | select(.type=="blob" and (.path | startswith($p))) |
      .path | split("/")[-1] |
      select(($kw == "") or (. | contains($kw)))] | .[0:$n]'
fi
