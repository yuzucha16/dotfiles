#!/usr/bin/env bash
# stow everyday driver
set -Eeuo pipefail
IFS=$'\n\t'

# ===== Settings (edit if needed) =====
# 既定の場所（スクリプトの配置に依存しないように手動指定も可）
SRC_DIR_DEFAULT="/mnt/c/Users/ck/vault/repos/github.com/yuzucha16/dotfiles"
DST_DIR_DEFAULT="$HOME"

# ===== CLI Options =====
DRY_RUN=0          # --dry-run (-n): 実行内容だけ表示
MODE="restow"      # restow | reset | unlink
SRC_DIR="$SRC_DIR_DEFAULT"
DST_DIR="$DST_DIR_DEFAULT"

usage() {
  cat <<'USAGE'
Usage: stow_apply.sh [options]

Options:
  --dry-run, -n     実行せずにプランだけ表示 (stow -n)
  --restow          既定。日常運用: 変更を再適用 (stow -R)
  --reset           一度すべてunlink後に再リンク (-D → stow)
  --unlink          リンク削除のみ (stow -D)
  --src DIR         dotfilesリポジトリのルート
  --dst DIR         展開先（ホームなど）
  -h, --help        このヘルプ

Examples:
  # 日常運用（既定）
  ./stow_apply.sh

  # 掃除してから再適用
  ./stow_apply.sh --reset

  # 影響を確認（ドライラン）
  ./stow_apply.sh -n
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1; shift ;;
    --restow)     MODE="restow"; shift ;;
    --reset)      MODE="reset"; shift ;;
    --unlink)     MODE="unlink"; shift ;;
    --src)        SRC_DIR="${2:-}"; shift 2 ;;
    --dst)        DST_DIR="${2:-}"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "[ERROR] Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

# ===== Pre-check =====
if ! command -v stow >/dev/null 2>&1; then
  echo "[ERROR] GNU Stow not found. Please install stow." >&2
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "[ERROR] SRC_DIR not found: $SRC_DIR" >&2
  exit 1
fi

echo "[INFO] Using SRC_DIR=$SRC_DIR"
echo "[INFO] Using DST_DIR=$DST_DIR"
echo "[INFO] Mode=$MODE  DryRun=$DRY_RUN"

# ===== Prepare dirs =====
mkdir -p "$DST_DIR/.config"
mkdir -p "$DST_DIR/.config/git"
mkdir -p "$DST_DIR/.config/nvim"
mkdir -p "$DST_DIR/.config/broot"
mkdir -p "$DST_DIR/.config/bat"
mkdir -p "$DST_DIR/.config/pet"
mkdir -p "$DST_DIR/.vscode-server/extensions"
mkdir -p "$DST_DIR/.local/share/navi/cheats/denisidoro__cheats"

# ===== Helper =====
STOW_COMMON_FLAGS=(-v)
(( DRY_RUN == 1 )) && STOW_COMMON_FLAGS+=(-n)
# stowは相対パス前提で動くことが多いので、都度cdして実行

do_stow() {
  local src_subdir="$1"   # cd先（例: "$SRC_DIR" or "$SRC_DIR/config"）
  local target_dir="$2"   # -t の展開先
  local package="$3"      # パッケージ名（ディレクトリ名）

  pushd "$src_subdir" >/dev/null

  case "$MODE" in
    restow)
      echo "[TASK] stow -R ${package}  -> ${target_dir}"
      stow "${STOW_COMMON_FLAGS[@]}" -R -t "$target_dir" "$package"
      ;;
    unlink)
      echo "[TASK] stow -D ${package}  -> ${target_dir}"
      stow "${STOW_COMMON_FLAGS[@]}" -D -t "$target_dir" "$package"
      ;;
    reset)
      echo "[TASK] stow -D ${package}  -> ${target_dir}"
      stow "${STOW_COMMON_FLAGS[@]}" -D -t "$target_dir" "$package"
      echo "[TASK] stow    ${package}  -> ${target_dir}"
      stow "${STOW_COMMON_FLAGS[@]}"    -t "$target_dir" "$package"
      ;;
    *)
      echo "[ERROR] Unknown MODE: $MODE" >&2
      popd >/dev/null
      exit 1
      ;;
  esac

  popd >/dev/null
}

# ===== Apply =====
# ルート直下の home パッケージ（~ 配下）
do_stow "$SRC_DIR" "$DST_DIR" "home"

# XDG_CONFIG_HOME
CONFIG_DIR="$SRC_DIR/config"
do_stow "$CONFIG_DIR" "$DST_DIR/.config/broot"               "broot"
do_stow "$CONFIG_DIR" "$DST_DIR/.config/bat"                 "bat"
do_stow "$CONFIG_DIR" "$DST_DIR/.config/git"                 "git"
do_stow "$CONFIG_DIR" "$DST_DIR/.config/nvim"                "nvim"
do_stow "$CONFIG_DIR" "$DST_DIR/.config/pet"                 "pet"
do_stow "$CONFIG_DIR" "$DST_DIR/.config"                     "starship"

# vscode
CONFIG_DIR="$SRC_DIR/vscode"
do_stow "$CONFIG_DIR" "$DST_DIR/.vscode-server/extensions"   "wsl"

# XDG_LOCAL_HOME
CONFIG_DIR="$SRC_DIR/share"
do_stow "$CONFIG_DIR" "$DST_DIR/.local/share/navi/cheats/denisidoro__cheats" "denisidoro__cheats"

echo "[DONE] stow ${MODE} completed."
