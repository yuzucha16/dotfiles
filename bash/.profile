# ~/.profile  (WSL Ubuntu 24.04)
# login shell でも非対話プロセスでも安全な内容のみ
# bash専用の対話設定は ~/.bashrc へ

# --- 0) umask（必要なら有効化）
# umask 022

##########
# 1) XDG Base Directory（最優先で定義）
##########
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${GHQ_ROOT:=$HOME/dev/src}"
: "${NVIM_APPNAME:=nvim-wsl}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME GHQ_ROOT NVIM_APPNAME

# 初回用ディレクトリ作成（存在チェック付き）
[ -d "$XDG_CONFIG_HOME" ] || mkdir -p "$XDG_CONFIG_HOME"
[ -d "$XDG_CACHE_HOME"  ] || mkdir -p "$XDG_CACHE_HOME"
[ -d "$XDG_DATA_HOME"   ] || mkdir -p "$XDG_DATA_HOME"
[ -d "$XDG_STATE_HOME"  ] || mkdir -p "$XDG_STATE_HOME"

##########
# 2) PATH の整備（重複防止で冪等）
##########
path_add() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$1${PATH:+:$PATH}";; esac; }
[ -d "$HOME/.local/bin" ] && path_add "$HOME/.local/bin"
[ -d "$HOME/bin" ]        && path_add "$HOME/bin"
[ -d "$HOME/.cargo/bin" ] && path_add "$HOME/.cargo/bin"
[ -d "/usr/local/go/bin" ] && path_add "/usr/local/go/bin"
[ -d "$HOME/.local/bin" ] && path_add "$HOME/.local/bin"
[ -d "$HOME/.cargo/bin" ] && path_add "$HOME/.cargo/bin"
export PATH

##########
# 3) ロケール / EDITOR / PAGER
##########
: "${LANG:=en_US.UTF-8}"
: "${LC_CTYPE:=$LANG}"
export LANG LC_ALL= LC_CTYPE

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
  export EDITOR=vim
else
  export EDITOR=vi
fi
export VISUAL="$EDITOR"

: "${LESS:=-FRSX}"   # -F短文自動終了 -R色 -S折返し無し -X画面復元しない
export LESS
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
[ -d "$(dirname "$LESSHISTFILE")" ] || mkdir -p "$(dirname "$LESSHISTFILE")"

##########
# 4) ツール別のXDG誘導（任意）
##########
# ripgrep
[ -f "$XDG_CONFIG_HOME/ripgrep/ripgreprc" ] && \
  export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"

# npm（ユーザーprefixをXDG配下へ）
if command -v npm >/dev/null 2>&1; then
  export npm_config_prefix="$XDG_DATA_HOME/npm"
  [ -d "$npm_config_prefix/bin" ] && path_add "$npm_config_prefix/bin"
fi

# Python ユーザスクリプトの bin を PATH へ
if command -v python3 >/dev/null 2>&1; then
  py_user_bin="$(python3 -c 'import site,sys;print(site.USER_BASE+"/bin")' 2>/dev/null || true)"
  [ -n "$py_user_bin" ] && [ -d "$py_user_bin" ] && path_add "$py_user_bin"
fi

##########
# 5) GPG/WSL 検出など（副作用小さめ）
##########
# GPG_TTY（対話端末があるときのみ）
if [ -n "${TTY:-}" ] || [ -t 1 ]; then
  GPG_TTY="$(tty 2>/dev/null || true)"; [ -n "$GPG_TTY" ] && export GPG_TTY
fi

# WSL 検出（必要になったら使う用）
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi "microsoft" /proc/version 2>/dev/null; then
  export IS_WSL=1
fi

##########
# 6) マシン固有の上書き（任意）
##########
# if [ -f "$XDG_CONFIG_HOME/profile.local" ]; then
#   . "$XDG_CONFIG_HOME/profile.local"
# fi

##########
# 7) bash の場合は .bashrc を読み込む（デフォルト挙動を維持）
##########
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

#. "$HOME/.cargo/env"
