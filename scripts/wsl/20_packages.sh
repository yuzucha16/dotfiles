#!/usr/bin/env bash
set -euo pipefail

#======================================
# WSL CLI ツールのセットアップ
# apt + 単体バイナリ (starship, ghq) + bat/fd のリンク。
# Docker / Go などは入れない（必要なときに README の手順で手動導入）
#======================================

echo "[*] Updating package lists..."
sudo apt update -y
sudo apt upgrade -y

# 導入するパッケージ一覧
PACKAGES=(
    # base
    git
    curl
    wget
    zsh

    # utils
    vim
    unzip
    stow

    # console
    lsd
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
)

echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

sudo apt autoremove -y
sudo apt clean

mkdir -p "$HOME/.local/bin"

# zsh は補完キャッシュ (compinit -C) を使うので、ツールを入れたら作り直させる
rm -f "$HOME"/.zcompdump*

# Starship
if command -v starship >/dev/null 2>&1; then
  echo "[*] starship has already installed!!"
else
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# ghq（ビルド済みバイナリを ~/.local/bin へ。Go は不要）
if [ -x "$HOME/.local/bin/ghq" ]; then
  echo "[*] ghq has already installed!!"
else
  GHQ_ARCH="$(dpkg --print-architecture)"   # amd64 / arm64
  GHQ_TMP="$(mktemp -d)"
  curl -fsSLo "$GHQ_TMP/ghq.zip" "https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_${GHQ_ARCH}.zip"
  unzip -q "$GHQ_TMP/ghq.zip" -d "$GHQ_TMP"
  install -m 755 "$GHQ_TMP/ghq_linux_${GHQ_ARCH}/ghq" "$HOME/.local/bin/ghq"
  rm -rf "$GHQ_TMP"
  echo "[*] Installed ghq"
fi

# bat / fd は Ubuntu では batcat / fdfind として入る。common.sh は bat / fd 前提
if command -v bat >/dev/null 2>&1; then
  echo "[*] bat has already linked!!"
else
  sudo ln -s /usr/bin/batcat /usr/local/bin/bat
fi

if command -v fd >/dev/null 2>&1; then
  echo "[*] fd has already linked!!"
else
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
fi

echo "[*] Install complete!"
