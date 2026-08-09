#!/usr/bin/env bash
set -euo pipefail

#======================================
# Ubuntu 開発環境セットアップスクリプト
#======================================

# 開発に必要なパッケージ一覧
PACKAGES=(
    # utils
    vim
    git
    wget
    unzip
    stow
    
    # console
    fzf
    lsd
    bat
    tree
    zoxide
    ripgrep
    fd-find
    
    # devel

    # ここに追加したいツールを書いていく
)

# Obsolete
#    cmake
#    pkg-config
#    ninja-build
#    build-essential
#    universal-ctags
#    gdb
#    bear
#    clang
#    clangd
#    clang-tidy
#    clang-format
#    lld
#    lldb
#    ccache
#    valgrind  
#	   universal-ctags
#	   global
  
echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

# 不要なパッケージ削除
echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# Starship
curl -sS https://starship.rs/install.sh | sh

### Nvim 0.11.4 from appImage
#cd /tmp
#curl -LO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.appimage
#sudo chmod +x nvim-linux-x86_64.appimage
#sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
#/usr/local/bin/nvim --version
#sudo apt install -y snapd
#sudo snap install nvim --classic

# Go application
/usr/local/go/bin/go install github.com/x-motemen/ghq@latest
/usr/local/go/bin/go install github.com/knqyf263/pet@latest

# Rust application
$HOME/.cargo/bin/cargo install broot lsd navi tealdeer
$HOME/.cargo/bin/tldr --update
$HOME/.cargo/bin/broot

# symbolic link
sudo ln -s /usr/bin/batcat /usr/local/bin/bat

# zshインストール
#sudo chsh -s /usr/bin/zsh
#/usr/bin/zsh

echo "[*] Install complete!"
