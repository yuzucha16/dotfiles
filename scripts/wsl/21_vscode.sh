#!/usr/bin/env bash
# VS Code Server extensions installer (WSL)
# manifests/vscode-extensions.wsl.txt にある拡張を入れる（導入済みは code 側がスキップ）
# 使い方: ./21_vscode.sh [リストのパス]
# 書き出し: code --list-extensions > manifests/vscode-extensions.wsl.txt
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="${1:-$SCRIPT_DIR/../../manifests/vscode-extensions.wsl.txt}"

if ! command -v code >/dev/null 2>&1; then
  echo "[WARN] 'code' not found. Open this WSL from VS Code on Windows once, then rerun." >&2
  exit 0
fi

if [[ ! -f "$LIST" ]]; then
  echo "[ERR] list not found: $LIST" >&2
  exit 1
fi

echo "[INFO] Using list: $LIST"
args=()
while IFS= read -r ext || [[ -n "$ext" ]]; do
  ext="${ext%$'\r'}"
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  args+=(--install-extension "$ext")
done < "$LIST"

(( ${#args[@]} > 0 )) && code "${args[@]}"

echo "[DONE] vscode extensions"
