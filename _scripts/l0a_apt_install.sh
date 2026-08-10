#!/usr/bin/env bash
set -euo pipefail

#======================================
# Ubuntu 開発環境セットアップスクリプト
#======================================

# 開発に必要なパッケージ一覧
PACKAGES=(
    # utils
    vim
    unzip
    stow
    #git   # setup.sh
    #curl  # setup.sh
    #wget  # setup.sh
    
    # console
    lsd #eza
    fzf
    bat
    tree
    zoxide
    ripgrep
    fd-find
    zsh-autosuggestions
    
    # devel
    build-essential
    universal-ctags
    global
    
    # ここに追加したいツールを書いていく
)

# Obsolete
#    cmake
#    pkg-config
#    ninja-build
#    build-essential
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
  
echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

# 不要なパッケージ削除
echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# Starship
if command -v starship >/dev/null 2>&1; then
  echo "[*] starship has already installed!!"
else
  curl -sS https://starship.rs/install.sh | sh
fi

### Nvim 0.11.4 from appImage
#cd /tmp
#curl -LO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.appimage
#sudo chmod +x nvim-linux-x86_64.appimage
#sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
#/usr/local/bin/nvim --version
#sudo apt install -y snapd
#sudo snap install nvim --classic

### Go https://go.dev/doc/install
if command -v go >/dev/null 2>&1; then
  echo "[*] golang has already installed!!"
else
  sudo curl -fsSLo /tmp/go1.26.0.linux-amd64.tar.gz https://go.dev/dl/go1.26.0.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go1.26.0.linux-amd64.tar.gz
  /usr/local/go/bin/go env -w GOBIN=$HOME/.local/bin
fi

### Go application: path defined on .profile
/usr/local/go/bin/go install github.com/x-motemen/ghq@latest
#/usr/local/go/bin/go install github.com/knqyf263/pet@latest

### Rust
#if command -v cargo >/dev/null 2>&1; then
#  echo "[*] rust has already installed!!"
#else
#  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#  $HOME/.cargo/bin/cargo version
#fi

### Rust application: path defined on .profile
#$HOME/.cargo/bin/cargo install broot lsd navi tealdeer
#$HOME/.cargo/bin/tldr --update
#$HOME/.cargo/bin/broot

### Docker Engine
if command -v docker >/dev/null 2>&1; then
  echo "[*] docker engine has already installed!!"
else
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER
fi

# symbolic link
if command -v /usr/local/bin/bat >/dev/null 2>&1; then
  echo "[*] bat has already linked!!"
else
  sudo ln -s /usr/bin/batcat /usr/local/bin/bat
fi

# vscode server
code .
echo "[*] Installed vscode server!!"

echo "[*] Install complete!"
