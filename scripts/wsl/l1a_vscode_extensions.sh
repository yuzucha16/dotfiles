#!/usr/bin/env bash
# VS Code Server extensions installer (WSL)
# manifests/vscode-extensions.wsl.txt にある拡張のうち、未導入のものだけ入れる
# 使い方: ./l1a_vscode_extensions.sh [リストのパス]
# 書き出し: code --list-extensions > manifests/vscode-extensions.wsl.txt
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="${1:-$SCRIPT_DIR/../../manifests/vscode-extensions.wsl.txt}"

if ! command -v code >/dev/null 2>&1; then
  echo "[WARN] 'code' not found. Open this WSL from VS Code on Windows once, then rerun." >&2
  exit 0
fi

if [[ ! -f "$LIST" ]]; then
  echo "[ERROR] list not found: $LIST" >&2
  exit 1
fi

installed="$(code --list-extensions)"

echo "[INFO] Using list: $LIST"
while IFS= read -r ext || [[ -n "$ext" ]]; do
  ext="${ext%$'\r'}"
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  if grep -qixF "$ext" <<<"$installed"; then
    echo "[Installed] $ext"
  else
    echo "Installing $ext ..."
    code --install-extension "$ext"
  fi
done < "$LIST"

echo "[DONE] vscode extensions"
