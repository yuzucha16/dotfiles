# ~/.zprofile
# login shell / 非対話プロセスでも安全な設定

##########
# XDG Base Directory
##########
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${GHQ_ROOT:=$HOME/vault/repos}"

export XDG_CONFIG_HOME
export XDG_CACHE_HOME
export XDG_DATA_HOME
export XDG_STATE_HOME
export GHQ_ROOT

mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$GHQ_ROOT"

##########
# PATH
##########
path_add() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1${PATH:+:$PATH}" ;;
    esac
}

[[ -d "$HOME/.local/bin" ]] && path_add "$HOME/.local/bin"
[[ -d "$HOME/bin" ]]       && path_add "$HOME/bin"
[[ -d "$HOME/.cargo/bin" ]] && path_add "$HOME/.cargo/bin"
[[ -d "/usr/local/go/bin" ]] && path_add "/usr/local/go/bin"

export PATH

##########
# Locale / Editor / Pager
##########
: "${LANG:=en_US.UTF-8}"
: "${LC_CTYPE:=$LANG}"

export LANG
export LC_ALL=
export LC_CTYPE

if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
else
    export EDITOR=vi
fi

export VISUAL="$EDITOR"

: "${LESS:=-FRSX}"
export LESS

export LESSHISTFILE="$XDG_STATE_HOME/less/history"
mkdir -p "$(dirname "$LESSHISTFILE")"

##########
# ripgrep
##########
if [[ -f "$XDG_CONFIG_HOME/ripgrep/ripgreprc" ]]; then
    export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
fi

##########
# npm
##########
if command -v npm >/dev/null 2>&1; then
    export npm_config_prefix="$XDG_DATA_HOME/npm"

    [[ -d "$npm_config_prefix/bin" ]] &&
        path_add "$npm_config_prefix/bin"
fi

##########
# Python user scripts
##########
if command -v python3 >/dev/null 2>&1; then
    py_user_bin="$(python3 -c 'import site; print(site.USER_BASE + "/bin")' 2>/dev/null)"

    [[ -n "$py_user_bin" && -d "$py_user_bin" ]] &&
        path_add "$py_user_bin"
fi

##########
# GPG
##########
if [[ -t 1 ]]; then
    GPG_TTY="$(tty 2>/dev/null)"
    [[ -n "$GPG_TTY" ]] && export GPG_TTY
fi

##########
# WSL
##########
if [[ -n "${WSL_DISTRO_NAME:-}" ]] ||
   grep -qi microsoft /proc/version 2>/dev/null; then
    export IS_WSL=1
fi

##########
# Local override
##########
if [[ -f "$XDG_CONFIG_HOME/profile.local" ]]; then
    source "$XDG_CONFIG_HOME/profile.local"
fi
