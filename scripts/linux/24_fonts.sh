#!/usr/bin/env bash
set -euo pipefail

#======================================
# フォント (PlemolJP NF / MoralerspaceHW) を GitHub の latest release から ~/download へ取得する
# インストールは手動（zip を展開して OS のフォント設定へ）。WSL でも保存先は WSL の ~/download
# 使い方: 24_fonts.sh
#   一覧は manifests/fonts.txt（<owner/repo>:<asset glob>）
#   gh のログインは不要（公開リリースのダウンロードは未ログインで動く）
#======================================

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
DOTS_DIR="$(dots_dir)"
DL_DIR="$HOME/download"

mapfile -t FONTS < <(read_list "$DOTS_DIR/manifests/fonts.txt")
if (( ${#FONTS[@]} == 0 )); then
  echo "[ERR] no fonts: $DOTS_DIR/manifests/fonts.txt" >&2
  exit 1
fi

command -v gh >/dev/null 2>&1 || { echo "[ERR] gh not found. Run 20_packages.sh first." >&2; exit 1; }
mkdir -p "$DL_DIR"

for entry in "${FONTS[@]}"; do
  repo="${entry%%:*}"
  pattern="${entry#*:}"
  echo "[*] $repo ($pattern)"
  gh release download --repo "$repo" --pattern "$pattern" --dir "$DL_DIR" --clobber
done

echo "[*] Downloaded to $DL_DIR. Unzip and install the fonts manually."
