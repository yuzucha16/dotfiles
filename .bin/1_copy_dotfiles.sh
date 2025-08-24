#!/usr/bin/env bash
set -ue

# ディレクトリ設定
SRC_DIR="/mnt/c/Users/kz/vault/dev/src/github.com/yuzucha16/dotfiles"
DST_DIR="$HOME/.config"  # XDG_CONFIG_HOME

echo "[INFO] Using SRC_DIR=$SRC_DIR"
echo "[INFO] Using DST_DIR=$DST_DIR"

# 必要なディレクトリを作成
mkdir -p "$DST_DIR/git"
mkdir -p "$DST_DIR/nvim"

# stow 実行
cd "$SRC_DIR"
pwd

# ~/.config/git 配下に .gitconfig を展開
stow -v -t "$DST_DIR"   .config

# ---
# refs

#stow -v -t "$DST_DIR/git"   git
#stow -v -t "$DST_DIR/nvim"  nvim
#stow -v -t "$DST_DIR/"      starship.toml

# Windows vault
#unlink ~/.dotfiles
#unlink ~/vault
#ln -s /mnt/c/Users/kz/vault ~/vault
#ln -s /mnt/c/Users/kz/vault/dev/src/github.com/yuzucha16/dotfiles/.config ~/.dotfiles

