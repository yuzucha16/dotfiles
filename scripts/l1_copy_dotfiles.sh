#!/usr/bin/env bash
set -ue

# ディレクトリ設定
SRC_DIR="/mnt/c/Users/kz/vault/dev/src/github.com/yuzucha16/dotfiles"
DST_DIR="$HOME"  

echo "[INFO] Using SRC_DIR=$SRC_DIR"
echo "[INFO] Using DST_DIR=$DST_DIR"

# 必要なディレクトリを作成
mkdir -p "$DST_DIR/.config/git"
mkdir -p "$DST_DIR/.config/nvim-wsl"
mkdir -p "$DST_DIR/.config/nvim-wsl/lua/shared"

# stow 実行
cd "$SRC_DIR"
stow -v -t "$DST_DIR"   bash

cd "$SRC_DIR/.config"   # XDG_CONFIG_HOME
stow -v -t "$DST_DIR/.config/broot"     broot
stow -v -t "$DST_DIR/.config/git"       git
stow -v -t "$DST_DIR/.config/nvim-wsl"  nvim-wsl
stow -v -t "$DST_DIR/.config"           starship
stow -v -t "$DST_DIR/.config/nvim-wsl/lua/shared"    shared


# ---
# refs
#stow -v -t "$DST_DIR"   .config

# Windows vault
#unlink ~/.dotfiles
#unlink ~/vault
#ln -s /mnt/c/Users/kz/vault ~/vault
#ln -s /mnt/c/Users/kz/vault/dev/src/github.com/yuzucha16/dotfiles/.config ~/.dotfiles

