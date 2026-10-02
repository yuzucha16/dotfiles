#!/usr/bin/env bash
set -eu

# ===== 設定 =====
DEV_HOME="${HOME}/vault"             # 共通ワークスペースのルート
SRC_DIR="${DEV_HOME}"                # ghq.root にする場所
BUILD_DIR="${DEV_HOME}/build"
TOOLS_DIR="${DEV_HOME}/tools"

BASHRC="${HOME}/.bashrc"
MARK_BEGIN="# >>> DEV_WORKSPACE >>>"
MARK_END="# <<< DEV_WORKSPACE <<<"

# ===== ディレクトリ作成 =====
mkdir -p "${SRC_DIR}" "${BUILD_DIR}" "${TOOLS_DIR}"

# 既存ブロックを置換 or 追記
if grep -Fq "${MARK_BEGIN}" "${BASHRC}" 2>/dev/null; then
  # begin〜endの間を削除
  sed -i "/${MARK_BEGIN}/,/${MARK_END}/d" "${BASHRC}"
fi

# 新しいブロックを末尾に追記
#printf "\n%s\n" "${BLOCK}" >> "${BASHRC}"

echo
echo "✅ スケルトン作成完了"
echo "  DEV_HOME  : ${DEV_HOME}"
echo "  SRC_DIR   : ${SRC_DIR}"
echo "  BUILD_DIR : ${BUILD_DIR}"
echo "  ghq.root  : \$(git config --global ghq.root || echo '(未設定)')"
echo
echo "▶ 反映するには新しいシェルを開くか、次を実行:"
echo "   source ${BASHRC}"
