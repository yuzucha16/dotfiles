#!/usr/bin/env bash
# Install gcc-arm-none-eabi (Cortex-M cross compiler) after a [y/N] confirmation.
# 容量が大きい（約 490MB。推奨の newlib も入る）ので、必要なときだけ入れる。apt.txt には載せない。
# 空入力と n は [SKIP]（既定 N）。標準入力が閉じていても [SKIP]。無効な入力は5回で [ERR]。
# 使い方: 25_arm_gcc.sh
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: 25_arm_gcc.sh

gcc-arm-none-eabi (apt, about 490MB) を [y/N] で確認してから入れる。既にあれば何もしない。
USAGE
}

case "${1:-}" in
  "") ;;
  -h|--help) usage; exit 0 ;;
  *) echo "[ERR] Unknown option: $1" >&2; usage; exit 1 ;;
esac

if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
  echo "[SKIP] already installed: $(arm-none-eabi-gcc --version | head -n 1)"
  exit 0
fi

tries=0
while :; do
  ans=""
  read -r -p "Install gcc-arm-none-eabi (apt, about 490MB)? [y/N]: " ans || { echo; echo "[SKIP] no input"; exit 0; }
  case "$ans" in
    y|Y|yes|YES) break ;;
    ""|n|N|no|NO) echo "[SKIP] not installed (answered no)"; exit 0 ;;
  esac
  echo "[WARN] answer y or n."
  tries=$((tries + 1))
  if (( tries >= 5 )); then
    echo "[ERR] no valid input after 5 tries. Nothing was installed. Run it again." >&2
    exit 1
  fi
done

sudo apt update -y
sudo apt install -y gcc-arm-none-eabi
echo "[DONE] installed gcc-arm-none-eabi. Check: arm-none-eabi-gcc --version"
