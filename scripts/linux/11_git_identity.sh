#!/usr/bin/env bash
# Create ~/.gitconfig_local (per-PC git identity) interactively (symmetric with scripts/windows/11_git_identity.bat)
# ~/.gitconfig_local が無いときだけ、user.name / user.email を対話的に聞いて作る。既にあれば触らない。
# 30_link.sh の前に実行する（git が必要。apt の git か、20_packages.sh で入る）。
# `git config --global` は使わない: ~/.gitconfig は dotfiles の home/.gitconfig への symlink（30_link.sh）で、
#   リンク前は実ファイルができて 30_link.sh が [ERR] になり、リンク後は repo 内のファイルを書き換えてしまうため。
#   ~/.gitconfig が ~/.gitconfig_local を include するので、--file で書く（読まれるのは 30_link.sh の後）。
# Windows 版にある credential.helperselector（Git Credential Manager）は Linux には無いので、書かない。
# 無効な入力は5回で [ERR]（標準入力が閉じていても無限ループしない）。
set -Eeuo pipefail

LOCAL="$HOME/.gitconfig_local"

usage() {
  cat <<'USAGE'
Usage: 11_git_identity.sh

~/.gitconfig_local が無いときだけ、git の user.name / user.email を対話的に聞いて作る。
USAGE
}

case "${1:-}" in
  "") ;;
  -h|--help) usage; exit 0 ;;
  *) echo "[ERR] Unknown option: $1" >&2; usage; exit 1 ;;
esac

command -v git >/dev/null 2>&1 || { echo "[ERR] git not found. Install it first (sudo apt install -y git)." >&2; exit 1; }

if [[ -e "$LOCAL" ]]; then
  echo "[SKIP] already exists: $LOCAL"
  exit 0
fi

echo "Creating $LOCAL"
tries=0
fail_input() {
  tries=$((tries + 1))
  if (( tries >= 5 )); then
    echo "[ERR] no valid input after 5 tries. Nothing was written. Run it again." >&2
    exit 1
  fi
}

name=""
while [[ -z "$name" ]]; do
  read -r -p "git user.name  : " name || name=""
  [[ -n "$name" ]] || { echo "[WARN] user.name must not be empty."; fail_input; }
done

email=""
while :; do
  read -r -p "git user.email : " email || email=""
  if [[ -z "$email" ]]; then
    echo "[WARN] user.email must not be empty."
  elif [[ "$email" != *@* ]]; then
    echo '[WARN] user.email should contain "@".'
  else
    break
  fi
  fail_input
done

if ! { git config --file "$LOCAL" user.name "$name" && git config --file "$LOCAL" user.email "$email"; }; then
  echo "[ERR] git config failed. Remove $LOCAL and run again." >&2
  exit 1
fi

echo "[DONE] created $LOCAL"
cat "$LOCAL"
