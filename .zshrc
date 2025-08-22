# Created by newuser for 5.9

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin


# >>> DEV_WORKSPACE >>>
# 共通ワークスペース
export DEV_HOME="/home/kz/dev"
export SRC_DIR="$DEV_HOME/src"
export BUILD_DIR="$DEV_HOME/build"
export RUN_DIR="$DEV_HOME/run"
export TOOL_DIR="$DEV_HOME/tools"
export VAULT_HOME="/mnt/v"       # Windows 側との連携用（V: の中身）

# 言語/ツールのキャッシュ（必要に応じてアンコメント）
# export CCACHE_DIR="$DEV_HOME/cache/ccache"
# export PIP_CACHE_DIR="$DEV_HOME/cache/pip"
# export npm_config_cache="$DEV_HOME/cache/npm"
# export CARGO_TARGET_DIR="$DEV_HOME/build/cargo"

# ショートカット関数
# r org repo -> ソースへジャンプ
function r() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: r <org> <repo>" >&2; return 2
  fi
  local path="$SRC_DIR/github.com/$1/$2"
  if [[ -d "$path" ]]; then
    cd "$path"
  else
    echo "not found: $path" >&2; return 1
  fi
}

# b repo -> ビルド出力ディレクトリへ（なければ作る）
function b() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: b <repo>" >&2; return 2
  fi
  mkdir -p "$BUILD_DIR/$1"
  cd "$BUILD_DIR/$1"
}

# rb org repo -> ビルド生成（CMake想定の雛形）
function rb() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: rb <org> <repo>" >&2; return 2
  fi
  local src="$SRC_DIR/github.com/$1/$2"
  local bld="$BUILD_DIR/$2"
  mkdir -p "$bld"
  if command -v cmake >/dev/null 2>&1; then
    cmake -S "$src" -B "$bld" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo 2>/dev/null || true
    cd "$bld"
  else
    echo "[info] cmake が見つかりません。b <repo> で手動運用してください。" >&2
  fi
}
# <<< DEV_WORKSPACE <<<
