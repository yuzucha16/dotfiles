#!/usr/bin/env bash
# Seed the zsh / bash history (symmetric with scripts/windows/31_history_seed.bat)
# manifests/history.seed.sh.txt を、履歴ファイルが無い（または空の）ときだけコピーする。
# 既存の履歴は上書きしない。リンクにしない（シェルが実行のたびに追記するため、作業ツリーが汚れる）。
# 初めてシェルを開く前に実行する（開いているシェルは履歴をメモリに持っている）。
# 種の行は <...> のプレースホルダーを含み、そのままでは実行されない
# （exmem の shell-command-usecases を参照）。
set -Eeuo pipefail
IFS=$'\n\t'

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
SRC_DIR="$(dots_dir)"
SEED="$SRC_DIR/manifests/history.seed.sh.txt"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: 31_history_seed.sh [--dry-run|-n]

  --dry-run, -n   実行せずにプランだけ表示
  -h, --help      このヘルプ

~/.local/state/{zsh,bash}/history（XDG_STATE_HOME があればその下）が無い/空のときだけコピーする。
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "[ERR] Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -f "$SEED" ]]; then
  echo "[ERR] seed not found: $SEED" >&2
  exit 1
fi

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
echo "[INFO] seed=$SEED"
echo "[INFO] state dir=$STATE_DIR  DryRun=$DRY_RUN"
echo

for sh in zsh bash; do
  dest="$STATE_DIR/$sh/history"
  if [[ -s "$dest" ]]; then
    echo "[SKIP] $sh: history already exists ($(wc -c < "$dest") bytes): not overwritten"
    continue
  fi
  if (( DRY_RUN == 1 )); then
    echo "[DRY] $sh: would copy seed -> $dest"
    continue
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$SEED" "$dest"
  chmod 600 "$dest"
  echo "[DONE] $sh: seeded $dest"
done

echo
echo "[DONE] finished. Open a new shell."
