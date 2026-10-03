#!/usr/bin/env bash
set -euo pipefail

#======================================
# 日本語入力 (fcitx5 + mozc) とフォント。ネイティブ Linux のデスクトップ用
# WSL では何もしない（入力は Windows 側が担当）
# 入れたら再ログインし、Fcitx 5 設定で Mozc を入力メソッドに追加する（手動）
#======================================

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if is_wsl; then
  echo "[*] WSL: skip Japanese input setup"
  exit 0
fi

# 設定ツールのパッケージ名はディストロで違うことがあるので、あるほうを入れる
CONFIG_PKG=""
for pkg in fcitx5-config-qt fcitx5-configtool; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    CONFIG_PKG="$pkg"
    break
  fi
done

PACKAGES=(fcitx5 fcitx5-mozc fonts-noto-cjk fonts-ipafont)
[[ -n "$CONFIG_PKG" ]] && PACKAGES+=("$CONFIG_PKG")

# Ubuntu 系 (Mint を含む) は言語パックも入れる
if distro_is ubuntu; then
  PACKAGES+=(language-pack-ja language-pack-gnome-ja)
fi

echo "[*] Installing packages: ${PACKAGES[*]}"
sudo apt update -y
sudo apt install -y "${PACKAGES[@]}"

im-config -n fcitx5

fc-cache -f

echo "[DONE] Re-login, then add Mozc in 'Fcitx 5 Configuration'."
