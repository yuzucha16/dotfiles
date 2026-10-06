#!/usr/bin/env bash
set -euo pipefail

#======================================
# XDG ディレクトリと作業ディレクトリの作成
#======================================

# 既定値（すでに環境に値があればそれを優先）
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$HOME/.local/bin" \
  "$HOME/.ssh" \
  "$HOME/works/build" \
  "$HOME/works/tools"

echo "[*] Directories ready (workspace: $HOME/works)"
