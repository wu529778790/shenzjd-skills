#!/bin/bash
# imgx-figure-bed: 通用 GitHub 图床删除脚本
#
# 配置优先级 (高→低): 命令行参数 > 环境变量 IMGX_* > 脚本内 DEFAULT_* 默认区
#   环境变量: IMGX_OWNER / IMGX_REPO / IMGX_BRANCH / IMGX_DIR
#   命令行:   --owner / --repo / --branch / --dir / --silent
#
# 用法:
#   delete.sh <文件名1> [文件名2 ...] [--owner O] [--repo R] [--branch B] [--dir 子目录] [--silent]
#
# 文件名指基础目录 (默认 blog/) 下的文件名, 不含目录前缀
# 输出 JSON 数组: {file, path, deleted, error?}

set -euo pipefail

# ===== 个人默认配置区 (按需修改, 与 upload.sh 保持一致) =====
DEFAULT_OWNER=""
DEFAULT_REPO=""
DEFAULT_BRANCH=""
DEFAULT_DIR="blog"
# ============================================================

[[ -n "${IMGX_OWNER:-}" ]] && DEFAULT_OWNER="$IMGX_OWNER"
[[ -n "${IMGX_REPO:-}" ]] && DEFAULT_REPO="$IMGX_REPO"
[[ -n "${IMGX_BRANCH:-}" ]] && DEFAULT_BRANCH="$IMGX_BRANCH"
[[ -n "${IMGX_DIR:-}" ]] && DEFAULT_DIR="$IMGX_DIR"

OWNER="$DEFAULT_OWNER"
REPO="$DEFAULT_REPO"
BRANCH="$DEFAULT_BRANCH"
SILENT=0
SUB_DIR=""
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --dir) SUB_DIR="$2"; shift 2 ;;
    --silent) SILENT=1; shift ;;
    -h|--help)
      grep '^#' "$0" | head -20; exit 0 ;;
    --) shift; while [[ $# -gt 0 ]]; do FILES+=("$1"); shift; done ;;
    -*)
      echo "未知参数: $1 (查看用法: $0 --help)" >&2; exit 2 ;;
    *) FILES+=("$1"); shift ;;
  esac
done

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "用法: delete.sh <文件名...> [--owner O] [--repo R] [--branch B] [--dir 子目录] [--silent]" >&2
  exit 2
fi

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

RESULTS="["
FIRST=1

for NAME in "${FILES[@]}"; do
  PATH_PREFIX="${DEFAULT_DIR}"
  [[ -n "$SUB_DIR" ]] && PATH_PREFIX="${PATH_PREFIX}/${SUB_DIR}"
  FULL_PATH="${PATH_PREFIX}/${NAME}"

  # 获取 sha
  SHA=$(gh api "repos/${OWNER}/${REPO}/contents/${FULL_PATH}?ref=${BRANCH}" --jq .sha 2>/tmp/imgx_gh_err.txt) \
    || { echo "{\"file\":\"$NAME\",\"path\":\"$FULL_PATH\",\"deleted\":false,\"error\":\"文件不存在或无法访问: $(cat /tmp/imgx_gh_err.txt)\"}" >&2; continue; }

  gh api --method DELETE "repos/${OWNER}/${REPO}/contents/${FULL_PATH}" \
    -f message="[skip ci] delete via imgx-figure-bed" \
    -f sha="$SHA" \
    -f branch="$BRANCH" >/dev/null 2>/tmp/imgx_gh_err.txt \
    || { echo "{\"file\":\"$NAME\",\"path\":\"$FULL_PATH\",\"deleted\":false,\"error\":\"$(cat /tmp/imgx_gh_err.txt)\"}" >&2; continue; }

  [[ "$SILENT" -eq 0 ]] && echo "✓ 已删除 ${FULL_PATH}" >&2

  if [[ "$FIRST" -eq 1 ]]; then FIRST=0; else RESULTS+=","; fi
  RESULTS+=$(jq -nc --arg file "$NAME" --arg path "$FULL_PATH" \
    '{file:$file, path:$path, deleted:true}')
done

RESULTS+="]"
echo "$RESULTS" | jq .
