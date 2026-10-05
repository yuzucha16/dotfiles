#!/usr/bin/env bash
# Link dotfiles (symmetric with scripts/windows/30_link.bat)
# home/ (~ を鏡写しにしたツリー) を stow で ~ に展開する
set -Eeuo pipefail
IFS=$'\n\t'

# ===== Settings (edit if needed) =====
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
SRC_DIR_DEFAULT="$(dots_dir)"   # このスクリプトのあるリポジトリ（WSL でもネイティブでも同じ）
DST_DIR_DEFAULT="$HOME"

# ===== CLI Options =====
DRY_RUN=0          # --dry-run (-n): 実行内容だけ表示
MODE="link"        # link | unlink
SRC_DIR="$SRC_DIR_DEFAULT"
DST_DIR="$DST_DIR_DEFAULT"

usage() {
  cat <<'USAGE'
Usage: 30_link.sh [link|unlink] [options]

  link              既定。リンクを張る（既存リンクは張り直す）
  unlink            リンクだけ削除する（実ファイルは触らない）

Options:
  --dry-run, -n     実行せずにプランだけ表示
  --src DIR         dotfilesリポジトリのルート
  --dst DIR         展開先（ホームなど）
  -h, --help        このヘルプ

展開先に実ファイルがある場合は [ERR] を出して止まる。中身を確認し、手で退避/削除してから再実行する。
ネイティブ Linux では、windows/obsidian/.obsidian を $NOTES_DIR/.obsidian へ symlink する（WSL は Windows 側が張る）。
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    link)         MODE="link"; shift ;;
    unlink)       MODE="unlink"; shift ;;
    --dry-run|-n) DRY_RUN=1; shift ;;
    --src)        SRC_DIR="${2:-}"; shift 2 ;;
    --dst)        DST_DIR="${2:-}"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "[ERR] Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

# ===== Pre-check =====
if ! command -v stow >/dev/null 2>&1; then
  echo "[ERR] GNU Stow not found. Please install stow." >&2
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "[ERR] SRC_DIR not found: $SRC_DIR" >&2
  exit 1
fi

# ===== Package =====
# home/ は ~ を鏡写しにした stow パッケージ（.config/ や .claude/ も含む）。
# --no-folding: ~/.config や ~/.claude をディレクトリごとリンクにせず、ファイル単位でリンクする
# （アプリが書き込む状態ファイルをリポジトリに混ぜないため）
PACKAGE="home"
HOME_TREE="$SRC_DIR/$PACKAGE"

if [[ ! -d "$HOME_TREE" ]]; then
  echo "[ERR] package not found: $HOME_TREE" >&2
  exit 1
fi

echo "[INFO] SRC_DIR=$SRC_DIR"
echo "[INFO] DST_DIR=$DST_DIR"
echo "[INFO] Mode=$MODE  DryRun=$DRY_RUN"
echo

# home/ 配下の全ファイル（相対パス）
mapfile -t rel_files < <(cd "$HOME_TREE" && find . -type f -printf '%P\n')

if [[ "$MODE" == "link" ]]; then
  # ===== Real files at destination: report and stop (no backup) =====
  err=0
  for rel in "${rel_files[@]}"; do
    file="$DST_DIR/$rel"
    if [[ -e "$file" && ! -L "$file" ]]; then
      echo "[ERR] real file exists, move it by hand: $file"
      err=$((err + 1))
    fi
  done
  if (( err > 0 )); then
    echo "[DONE] Mode=$MODE aborted with $err [ERR]. Move the files by hand and re-run." >&2
    exit 1
  fi

  # ===== Prune dangling symlinks =====
  # リポジトリの構成変更・移動でリンク切れになった旧 symlink は stow が「自分のものではない」と
  # 判断して競合するため、リンク切れのものだけ削除する（実体があるものは触らない）
  prune_targets=()
  for rel in "${rel_files[@]}"; do
    prune_targets+=("$DST_DIR/$rel")
  done
  # 旧構成（vscode/wsl/extensions.txt を stow していた）で張っていたもの
  prune_targets+=("$DST_DIR/.vscode-server/extensions/extensions.txt")
  for link in "${prune_targets[@]}"; do
    if [[ -L "$link" && ! -e "$link" ]]; then
      if (( DRY_RUN == 1 )); then
        echo "[DRY] would remove dangling symlink: $link -> $(readlink "$link")"
      else
        unlink "$link"
        echo "[PRUNE] removed dangling symlink: $link"
      fi
    fi
  done
fi

# ===== Apply =====
STOW_FLAGS=(-v --no-folding -d "$SRC_DIR" -t "$DST_DIR")
(( DRY_RUN == 1 )) && STOW_FLAGS+=(-n)

case "$MODE" in
  link)
    # -R: 既存リンクは張り直す
    stow "${STOW_FLAGS[@]}" -R "$PACKAGE"
    ;;
  unlink)
    stow "${STOW_FLAGS[@]}" -D "$PACKAGE"
    ;;
esac

# ===== Obsidian config (native Linux only) =====
# WSL は、Windows 側の 30_link.bat が C:\vault\notes\.obsidian へジャンクションを張る（/mnt/c で共有）ので、何もしない。
# ネイティブ Linux は、windows/obsidian/.obsidian を $NOTES_DIR/.obsidian へ symlink する（NOTES_DIR は lib.sh の notes_dir）。
obsidian_err=0
if ! is_wsl; then
  link_obsidian "$MODE" "$SRC_DIR/windows/obsidian/.obsidian" "$(notes_dir)/.obsidian" "$DRY_RUN" || obsidian_err=1
fi

echo
if (( obsidian_err == 1 )); then
  echo "[DONE] Mode=$MODE finished with an [ERR] (.obsidian). Move it by hand and re-run." >&2
  exit 1
fi
echo "[DONE] Mode=$MODE completed."
[[ "$MODE" == "link" ]] && echo "Enter chsh -s /usr/bin/zsh"
exit 0
