#!/usr/bin/env bash
set -euo pipefail

#======================================
# Ubuntu 開発環境セットアップスクリプト
#======================================

# 開発に必要なパッケージ一覧
PACKAGES=(
    git
    stow
    cmake
    pkg-config
    ninja-build
    build-essential
    universal-ctags
    gdb
    bear
    clang
    clangd
    clang-tidy
    clang-format
    lld
    lldb
    ccache
    valgrind  
    fzf
    bat
    tree
    zoxide
    ripgrep
    fd-find
    unzip
    # ここに追加したいツールを書いていく
)

echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

# 不要なパッケージ削除
echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# Go application
/usr/local/go/bin/go install github.com/x-motemen/ghq@latest
/usr/local/go/bin/go install github.com/knqyf263/pet@latest

# Rust application
$HOME/.cargo/bin/cargo install broot lsd navi tealdeer
$HOME/.cargo/bin/tldr --update
$HOME/.cargo/bin/broot

# symbolic link
sudo ln -s /usr/bin/batcat /usr/local/bin/bat

echo "[*] Install complete!"
