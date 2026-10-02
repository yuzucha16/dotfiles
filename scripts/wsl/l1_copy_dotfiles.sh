#!/usr/bin/env bash
# stow everyday driver
# home/ (~ を鏡写しにしたツリー) を stow で ~ に展開する
set -Eeuo pipefail
IFS=$'\n\t'

# ===== Settings (edit if needed) =====
# 既定の場所（スクリプトの配置に依存しないように手動指定も可）
SRC_DIR_DEFAULT="/mnt/c/vault/repos/github.com/yuzucha16/dotfiles"
DST_DIR_DEFAULT="$HOME"

# ===== CLI Options =====
DRY_RUN=0          # --dry-run (-n): 実行内容だけ表示
MODE="restow"      # restow | reset | unlink
SRC_DIR="$SRC_DIR_DEFAULT"
DST_DIR="$DST_DIR_DEFAULT"

usage() {
  cat <<'USAGE'
Usage: l1_copy_dotfiles.sh [options]

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
  ./l1_copy_dotfiles.sh

  # 掃除してから再適用
  ./l1_copy_dotfiles.sh --reset

  # 影響を確認（ドライラン）
  ./l1_copy_dotfiles.sh -n
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

# ===== Package =====
# home/ は ~ を鏡写しにした stow パッケージ（.config/ や .claude/ も含む）。
# --no-folding: ~/.config や ~/.claude をディレクトリごとリンクにせず、ファイル単位でリンクする
# （アプリが書き込む状態ファイルをリポジトリに混ぜないため）
PACKAGE="home"
HOME_TREE="$SRC_DIR/$PACKAGE"

if [[ ! -d "$HOME_TREE" ]]; then
  echo "[ERROR] package not found: $HOME_TREE" >&2
  exit 1
fi

echo "[INFO] Using SRC_DIR=$SRC_DIR"
echo "[INFO] Using DST_DIR=$DST_DIR"
echo "[INFO] Mode=$MODE  DryRun=$DRY_RUN"

# home/ 配下の全ファイル（相対パス）
mapfile -t rel_files < <(cd "$HOME_TREE" && find . -type f -printf '%P\n')

# ===== Backup existing dotfiles =====
# stow の衝突回避。実ファイルのみ退避し、symlink(=適用済み)・dry-run・unlink では何もしない
if (( DRY_RUN == 0 )) && [[ "$MODE" != "unlink" ]]; then
  BAK_DIR="$DST_DIR/.bak/$(date +%Y%m%d-%H%M%S)"
  for rel in "${rel_files[@]}"; do
    file="$DST_DIR/$rel"
    if [[ -e "$file" && ! -L "$file" ]]; then
      mkdir -p "$BAK_DIR/$(dirname "$rel")"
      mv "$file" "$BAK_DIR/$rel"
      echo "[BACKUP] $file -> $BAK_DIR/$rel"
    fi
  done
fi

# ===== Prune dangling symlinks =====
# リポジトリの構成変更・移動でリンク切れになった旧 symlink は stow が「自分のものではない」と
# 判断して競合 → set -e で中断するため、リンク切れのものだけ削除する（実体があるものは触らない）
if [[ "$MODE" != "unlink" ]]; then
  prune_targets=()
  for rel in "${rel_files[@]}"; do
    prune_targets+=("$DST_DIR/$rel")
  done
  # 旧構成（vscode/wsl/extensions.txt を stow していた）で張っていたもの
  prune_targets+=("$DST_DIR/.vscode-server/extensions/extensions.txt")
  for link in "${prune_targets[@]}"; do
    if [[ -L "$link" && ! -e "$link" ]]; then
      if (( DRY_RUN == 1 )); then
        echo "[PRUNE] (dry-run) would remove dangling symlink: $link -> $(readlink "$link")"
      else
        unlink "$link"
        echo "[PRUNE] removed dangling symlink: $link"
      fi
    fi
  done
fi

# ===== Apply =====
STOW_COMMON_FLAGS=(-v --no-folding -d "$SRC_DIR" -t "$DST_DIR")
(( DRY_RUN == 1 )) && STOW_COMMON_FLAGS+=(-n)

case "$MODE" in
  restow)
    echo "[TASK] stow -R ${PACKAGE}  -> ${DST_DIR}"
    stow "${STOW_COMMON_FLAGS[@]}" -R "$PACKAGE"
    ;;
  unlink)
    echo "[TASK] stow -D ${PACKAGE}  -> ${DST_DIR}"
    stow "${STOW_COMMON_FLAGS[@]}" -D "$PACKAGE"
    ;;
  reset)
    echo "[TASK] stow -D ${PACKAGE}  -> ${DST_DIR}"
    stow "${STOW_COMMON_FLAGS[@]}" -D "$PACKAGE"
    echo "[TASK] stow    ${PACKAGE}  -> ${DST_DIR}"
    stow "${STOW_COMMON_FLAGS[@]}" "$PACKAGE"
    ;;
  *)
    echo "[ERROR] Unknown MODE: $MODE" >&2
    exit 1
    ;;
esac

echo "[DONE] stow ${MODE} completed."
echo "Enter chsh -s /usr/bin/zsh"
