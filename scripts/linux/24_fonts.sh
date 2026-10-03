#!/usr/bin/env bash
set -euo pipefail

#======================================
# フォント (PlemolJP NF / MoralerspaceHW) を GitHub の latest release から ~/download へ取得する
# インストールは手動（zip を展開して OS のフォント設定へ）。WSL でも保存先は WSL の ~/download
# 使い方: 24_fonts.sh [--dry-run]
#   --dry-run: gh を呼ばず、実行するコマンドだけ表示する（gh 未インストール・未ログインでも可）
#   一覧は manifests/fonts.txt（<owner/repo>:<asset glob>）
#======================================

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
DOTS_DIR="$(dots_dir)"
DL_DIR="$HOME/download"

DRY_RUN=0
case "${1:-}" in
  "")        ;;
  --dry-run) DRY_RUN=1 ;;
  *) echo "usage: $0 [--dry-run]" >&2; exit 2 ;;
esac

mapfile -t FONTS < <(read_list "$DOTS_DIR/manifests/fonts.txt")
if (( ${#FONTS[@]} == 0 )); then
  echo "[ERR] no fonts: $DOTS_DIR/manifests/fonts.txt" >&2
  exit 1
fi

if (( DRY_RUN )); then
  echo "[dry-run] mkdir -p $DL_DIR"
else
  command -v gh >/dev/null 2>&1 || { echo "[ERR] gh not found. Run 20_packages.sh first." >&2; exit 1; }
  gh auth status >/dev/null 2>&1 || { echo "[ERR] gh is not logged in. Run: gh auth login" >&2; exit 1; }
  mkdir -p "$DL_DIR"
fi

for entry in "${FONTS[@]}"; do
  repo="${entry%%:*}"
  pattern="${entry#*:}"
  if (( DRY_RUN )); then
    echo "[dry-run] gh release download --repo $repo --pattern '$pattern' --dir $DL_DIR --clobber"
  else
    echo "[*] $repo ($pattern)"
    gh release download --repo "$repo" --pattern "$pattern" --dir "$DL_DIR" --clobber
  fi
done

if (( DRY_RUN )); then
  echo "[dry-run] done (nothing downloaded)"
else
  echo "[*] Downloaded to $DL_DIR. Unzip and install the fonts manually."
fi
