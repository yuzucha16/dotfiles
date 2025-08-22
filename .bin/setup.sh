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
    #zsh
    #build-essential
    #ninja-build
    #cmake
    #git
    #pkg-config
    #unzip
    #curl
    #clang
    #clangd
    #clang-tidy
    #clang-format
    #lldb
    #lld
    #ccache
    #valgrind 
    #gdb 
    bear
    gawk # これ以降はYocto用途
    ##git-core -- already installed?
    #wget
    #diffstat 
    #unzip
    #texinfo
    #gcc-multilib
    #chrpath
    #socat
    #cpio
    #python3
    #python3-pip
    #python3-pexpect
    #xz-utils
    #debianutils
    #iputils-ping
    #python3-git
    #python3-jinja2
    ##libegl1-mesa  -- nothing
    #libsdl1.2-dev 
    ##pylint3 -- nothing
    #xterm
    # ここに追加したいツールを書いていく
)

echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

# Starhip
curl -sS https://starship.rs/install.sh | sh

# Nvim 0.11+
sudo apt install -y snapd
sudo snap install nvim --classic

# 不要なパッケージ削除
echo "[*] Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# Go https://go.dev/doc/install
sudo curl -fsSLo /tmp/go1.25.0.linux-amd64.tar.gz https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go1.25.0.linux-amd64.tar.gz
sudo /usr/local/go/bin/go install github.com/x-motemen/ghq@latest
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/go/bin/ghq
    
# 既定値（すでに環境に値があればそれを優先）
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

# ---- 現在のシェルに反映 ----
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

ensure_export() {
  local var="$1"
  local val="$2"
  local file="$3"

  # 既に同名の export 行があれば何もしない（ゆるめのマッチ）
  if ! grep -qE "^\s*export\s+${var}=" "$file" 2>/dev/null; then
    printf 'export %s="%s"\n' "$var" "$val" >> "$file"
  fi
}

# ---- ディレクトリ作成 ----
mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \

# zshインストール
sudo chsh -s /usr/bin/zsh
#/usr/bin/zsh

echo "[*] Setup complete!"
