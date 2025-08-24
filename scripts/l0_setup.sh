#!/usr/bin/env bash
set -euo pipefail

#======================================
# Ubuntu 開発環境セットアップスクリプト
#======================================

# ミラーサーバを山形大学に変更
#echo "[*] Switching apt mirror to Yamagata University..."
#sudo sed -i.bak -E 's|http://[a-zA-Z0-9.-]+.ubuntu.com/ubuntu/|http://ftp.yz.yamagata-u.ac.jp/pub/linux/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources

# windowsのパスを継承しない
# appendWindowsPath だけ false にする（存在すれば置換）
sudo sed -i '/^\[interop\]/,/^\[/{s/^[[:space:]]*appendWindowsPath[[:space:]]*=.*$/appendWindowsPath = false/}' /etc/wsl.conf
# [interop] セクションが無ければ追記
grep -q '^\[interop\]' /etc/wsl.conf || echo -e '\n[interop]\nappendWindowsPath = false' | sudo tee -a /etc/wsl.conf >/dev/null

# 更新
echo "[*] Updating package lists..."
sudo apt update -y
sudo apt upgrade -y

# 開発に必要なパッケージ一覧
PACKAGES=(
    stow
    #build-essential
    #ninja-build
    #cmake
    #universal-ctags
    #git
    #pkg-config
    #unzip
    #fzf
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
    #bear
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
#sudo chsh -s /usr/bin/zsh
#/usr/bin/zsh

echo "[*] Setup complete!"
