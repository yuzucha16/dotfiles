#!/usr/bin/env bash
set -eu

# ===== 設定 =====
DEV_HOME="${HOME}/dev"             # 共通ワークスペースのルート
SRC_DIR="${DEV_HOME}/src"          # ghq.root にする場所
BUILD_DIR="${DEV_HOME}/build"
RUN_DIR="${DEV_HOME}/run"
TOOLS_DIR="${DEV_HOME}/tools"
SCRIPTS_DIR="${DEV_HOME}/scripts"
CACHE_DIR="${DEV_HOME}/cache"
TEMPLATES_DIR="${DEV_HOME}/templates"

BASHRC="${HOME}/.bashrc"
MARK_BEGIN="# >>> DEV_WORKSPACE >>>"
MARK_END="# <<< DEV_WORKSPACE <<<"

# ===== ディレクトリ作成 =====
mkdir -p "${SRC_DIR}" "${BUILD_DIR}" "${RUN_DIR}" "${TOOLS_DIR}" "${SCRIPTS_DIR}" "${CACHE_DIR}" "${TEMPLATES_DIR}"

# ===== ghq 設定（あれば） =====
if command -v ghq >/dev/null 2>&1; then
  git config --global ghq.root "${SRC_DIR}"
else
  echo "[info] ghq が見つかりませんでした。後で 'git config --global ghq.root ${SRC_DIR}' を実行してください。"
fi

# ===== .gitignore_global の用意 & 設定 =====
GIG="${TEMPLATES_DIR}/.gitignore_global"
cat > "${GIG}" <<'EOF'
# build outputs (common)
build/
out/
dist/
*.o
*.obj
*.a
*.so
*.dll
*.exe

# language caches
.node_modules/
target/
.gradle/
.mvn/
__pycache__/
*.pyc

# editor/OS junk
.DS_Store
Thumbs.db
*.swp
*.swo
EOF

git config --global core.excludesfile "${GIG}"

# ===== ~/.bashrc へ環境変数＆関数を追記（マーカーで全体置換） =====
BLOCK=$(cat <<EOF
${MARK_BEGIN}
# 共通ワークスペース
export DEV_HOME="${DEV_HOME}"
export SRC_DIR="\$DEV_HOME/src"
export BUILD_DIR="\$DEV_HOME/build"
export RUN_DIR="\$DEV_HOME/run"
export TOOL_DIR="\$DEV_HOME/tools"
export VAULT_HOME="/mnt/v"       # Windows 側との連携用（V: の中身）

# 言語/ツールのキャッシュ（必要に応じてアンコメント）
# export CCACHE_DIR="\$DEV_HOME/cache/ccache"
# export PIP_CACHE_DIR="\$DEV_HOME/cache/pip"
# export npm_config_cache="\$DEV_HOME/cache/npm"
# export CARGO_TARGET_DIR="\$DEV_HOME/build/cargo"

# ショートカット関数
# r org repo -> ソースへジャンプ
r() {
  if [[ \$# -ne 2 ]]; then
    echo "Usage: r <org> <repo>" >&2; return 2
  fi
  local path="\$SRC_DIR/github.com/\$1/\$2"
  if [[ -d "\$path" ]]; then
    cd "\$path"
  else
    echo "not found: \$path" >&2; return 1
  fi
}

# b repo -> ビルド出力ディレクトリへ（なければ作る）
b() {
  if [[ \$# -ne 1 ]]; then
    echo "Usage: b <repo>" >&2; return 2
  fi
  mkdir -p "\$BUILD_DIR/\$1"
  cd "\$BUILD_DIR/\$1"
}

# rb org repo -> ビルド生成（CMake想定の雛形）
rb() {
  if [[ \$# -ne 2 ]]; then
    echo "Usage: rb <org> <repo>" >&2; return 2
  fi
  local src="\$SRC_DIR/github.com/\$1/\$2"
  local bld="\$BUILD_DIR/\$2"
  mkdir -p "\$bld"
  if command -v cmake >/dev/null 2>&1; then
    cmake -S "\$src" -B "\$bld" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo 2>/dev/null || true
    cd "\$bld"
  else
    echo "[info] cmake が見つかりません。b <repo> で手動運用してください。" >&2
  fi
}
${MARK_END}
EOF
)

# 既存ブロックを置換 or 追記
if grep -Fq "${MARK_BEGIN}" "${BASHRC}" 2>/dev/null; then
  # begin〜endの間を削除
  sed -i "/${MARK_BEGIN}/,/${MARK_END}/d" "${BASHRC}"
fi

# 新しいブロックを末尾に追記
printf "\n%s\n" "${BLOCK}" >> "${BASHRC}"

echo
echo "✅ スケルトン作成完了"
echo "  DEV_HOME  : ${DEV_HOME}"
echo "  SRC_DIR   : ${SRC_DIR}"
echo "  BUILD_DIR : ${BUILD_DIR}"
echo "  RUN_DIR   : ${RUN_DIR}"
echo "  ghq.root  : \$(git config --global ghq.root || echo '(未設定)')"
echo
echo "▶ 反映するには新しいシェルを開くか、次を実行:"
echo "   source ${BASHRC}"
