#!/usr/bin/env bash
set -euo pipefail

#======================================
# Ubuntu 開発環境セットアップスクリプト
#======================================

# 開発に必要なパッケージ一覧
PACKAGES=(
    stow
    build-essential
    ninja-build
    cmake
    universal-ctags
    git
    pkg-config
    unzip
    fzf
    clang
    clangd
    clang-tidy
    clang-format
    lldb
    lld
    ccache
    valgrind 
    gdb 
    bear
    zoxide
    fd-find
    tree
    ripgrep
    # ここに追加したいツールを書いていく
)

echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

# 不要なパッケージ削除
echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo "[*] Install complete!"
