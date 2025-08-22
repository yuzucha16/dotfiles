#!/usr/bin/env bash
set -euo pipefail

#======================================
# Ubuntu 開発環境セットアップスクリプト
#======================================

# ミラーサーバを山形大学に変更
echo "[*] Switching apt mirror to Yamagata University..."
sudo sed -i.bak -E 's|http://[a-zA-Z0-9.-]+.ubuntu.com/ubuntu/|http://ftp.yz.yamagata-u.ac.jp/pub/linux/ubuntu/|g' /etc/apt/sources.list

# 更新
echo "[*] Updating package lists..."
sudo apt update -y
sudo apt upgrade -y

# 開発に必要なパッケージ一覧
PACKAGES=(
    build-essential
    ninja-build
    cmake
    git
    pkg-config
    unzip
    curl
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
    gawk # これ以降はYocto用途 #git-core
    wget
    diffstat 
    unzip
    texinfo
    gcc-multilib
    chrpath
    socat
    cpio
    python3
    python3-pip
    python3-pexpect
    xz-utils
    debianutils
    iputils-ping
    python3-git
    python3-jinja2
    libegl1-mesa
    libsdl1.2-dev 
    pylint3 
    xterm
    # ここに追加したいツールを書いていく
)

echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

# Nvim 0.11+
sudo apt install -y snapd
sudo snap install nvim --classic

# 不要なパッケージ削除
echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo "[*] Setup complete!"
