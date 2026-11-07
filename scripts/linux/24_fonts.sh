#!/usr/bin/env bash
set -euo pipefail

#======================================
# フォント (PlemolJP NF, Noto Sans JP) を GitHub の release（既定は latest、一覧にタグがあればそのタグ）から ~/download へ取得する
# インストールは手動（zip を展開して OS のフォント設定へ）。WSL でも保存先は WSL の ~/download
# 使い方: 24_fonts.sh
#   一覧は manifests/fonts.txt（<owner/repo>:<asset glob>[:<release tag>]）
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

failed=0
for entry in "${FONTS[@]}"; do
  repo="${entry%%:*}"
  rest="${entry#*:}"
  pattern="${rest%%:*}"
  tag=""
  [[ "$rest" == *:* ]] && tag="${rest#*:}"
  echo "[*] $repo ($pattern) ${tag:+tag=$tag}"
  # 1件失敗しても残りは続け、最後に終了コード 1 にする（Windows の 24_fonts.bat と同じ）
  # tag が空なら latest（gh release download の tag 引数を渡さない）
  if ! gh release download ${tag:+"$tag"} --repo "$repo" --pattern "$pattern" --dir "$DL_DIR" --clobber; then
    echo "[ERROR] download failed: $repo $pattern $tag" >&2
    failed=1
  fi
done

if (( failed == 1 )); then
  echo "[ERROR] some downloads failed (see above)." >&2
  exit 1
fi
echo "[*] Downloaded to $DL_DIR. Unzip and install the fonts manually."
