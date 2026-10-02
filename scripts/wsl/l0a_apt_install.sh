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
if [ -x /usr/local/go/bin/go ]; then
  echo "[*] golang has already installed!!"
else
  # 最新の安定版を go.dev から取得する（1行目が "go1.x.y"）
  GO_VERSION="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)"
  GO_ARCH="$(dpkg --print-architecture)"
  GO_TARBALL="/tmp/${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  echo "[*] Installing ${GO_VERSION} (${GO_ARCH})"
  curl -fsSLo "$GO_TARBALL" "https://go.dev/dl/${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "$GO_TARBALL"
  /usr/local/go/bin/go env -w GOBIN=$HOME/.local/bin
fi

### Go application: path defined on .profile
/usr/local/go/bin/go install github.com/x-motemen/ghq@latest

### Rust
#if command -v cargo >/dev/null 2>&1; then
#  echo "[*] rust has already installed!!"
#else
#  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#  $HOME/.cargo/bin/cargo version
#fi

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

# vscode server (Windows 側の VS Code から WSL を開く `code` がある場合のみ)
if command -v code >/dev/null 2>&1; then
  code .
  echo "[*] Installed vscode server!!"
else
  echo "[*] 'code' not found; skipped vscode server install"
fi

echo "[*] Install complete!"
