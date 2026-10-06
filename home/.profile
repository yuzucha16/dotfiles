# ~/.profile  (WSL Ubuntu 24.04)
# login shell でも非対話プロセスでも安全な内容のみ
# bash専用の対話設定は ~/.bashrc へ
# XDG はここで export する（ディレクトリ作成は l0_setup.sh）。
# 非ログインシェルでは読まれないので、rc 側は使う箇所でインライン既定値を使う

##########
# 1) XDG Base Directory / ghq
##########
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

# Vault top (a PC-local repo; the shared repo workbase is cloned into $WORKS_DIR/resources).
# WSL shares Windows' %USERPROFILE%\works through /mnt/c: Windows passes WORKS_DIR via WSLENV (WORKS_DIR/p),
# because the WSL user name can differ from the Windows one. The /mnt/c/Users/$USER fallback assumes they match.
# Native Linux uses ~/works. PROC_VERSION_FILE is only for tests.
if grep -qi microsoft "${PROC_VERSION_FILE:-/proc/version}" 2>/dev/null; then
  _wsl=1
else
  _wsl=0
fi
if [ -z "${WORKS_DIR:-}" ]; then
  if [ "$_wsl" = 1 ]; then
    WORKS_DIR="/mnt/c/Users/$USER/works"
  else
    WORKS_DIR="$HOME/works"
  fi
fi
export WORKS_DIR

# ghq root: native Linux puts it under the vault ($WORKS_DIR/repos), as on Windows.
# WSL keeps its own on the Linux filesystem (not /mnt/c: git is slow there).
if [ -z "${GHQ_ROOT:-}" ]; then
  if [ "$_wsl" = 1 ]; then
    GHQ_ROOT="$HOME/vault/repos"
  else
    GHQ_ROOT="$WORKS_DIR/repos"
  fi
fi
export GHQ_ROOT
unset _wsl

##########
# 2) PATH の整備（重複防止で冪等）
##########
path_add() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$1${PATH:+:$PATH}";; esac; }
[ -d "$HOME/.local/bin" ] && path_add "$HOME/.local/bin"
[ -d "$HOME/bin" ]        && path_add "$HOME/bin"
export PATH

##########
# 3) ロケール
##########
: "${LANG:=en_US.UTF-8}"
: "${LC_CTYPE:=$LANG}"
export LANG LC_ALL= LC_CTYPE

##########
# 4) マシン固有の上書き（任意）
##########
if [ -f "$XDG_CONFIG_HOME/profile.local" ]; then
  . "$XDG_CONFIG_HOME/profile.local"
fi

##########
# 5) bash の場合は .bashrc を読み込む（デフォルト挙動を維持）
##########
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
