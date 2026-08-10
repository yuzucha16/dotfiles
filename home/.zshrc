# ~/.zshrc

##########
# Interactive shell
##########

# Emacs keybindings
bindkey -e


##########
# History
##########

HISTFILE="$XDG_STATE_HOME/zsh/history"

HISTSIZE=50000
SAVEHIST=200000

mkdir -p "$(dirname "$HISTFILE")"

# bash の ignoreboth 相当
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS

# セッション間で履歴共有
setopt SHARE_HISTORY

# 複数行コマンドを1エントリとして保存
setopt HIST_EXPIRE_DUPS_FIRST

# 履歴ファイルをコピーして保存
setopt HIST_SAVE_BY_COPY

##########
# 履歴から除外するコマンド
##########

zshaddhistory() {
    local line="${1%%$'\n'}"

    case "$line" in
        ls|ll|la|l|cd|pwd|clear|history)
            return 1
            ;;
    esac

    return 0
}


##########
# Completion
##########

zmodload -i zsh/complist

autoload -Uz compinit
compinit

bindkey '^I' menu-select

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' group-name ''

zstyle ':completion:*:default' list-colors \
  'di=01;34' \
  'ow=01;34' \
  'tw=01;34' \
  'ma=48;5;60;38;5;255'

zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-z}={A-Z}' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=* l:|=*'

zstyle ':completion:*' select-prompt \
  '%SScrolling active: current selection at %p%s'

zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true


##########
# Directory / shell behavior
##########

# cdせずにディレクトリ名だけで移動
setopt AUTO_CD

# cdのスペルミスを修正
setopt CORRECT


##########
# glob
##########

# bash globstar 相当
# zshでは ** がもともと再帰globとして使えるので特別な設定不要

# bash extglob相当
setopt EXTENDED_GLOB


##########
# Terminal
##########

# 端末サイズ変更を自動検出
setopt CHECK_JOBS


##########
# dircolors
##########

if command -v dircolors >/dev/null 2>&1; then
    if [[ -r "$XDG_CONFIG_HOME/dircolors" ]]; then
        eval "$(dircolors -b "$XDG_CONFIG_HOME/dircolors")"
    elif [[ -r "$HOME/.dircolors" ]]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi


##########
# aliases
##########

if command -v dircolors >/dev/null 2>&1; then
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd --group-dirs=first --color=auto'

    alias l='ls -l'
    alias la='ls -a'
    alias ll='ls -la'
    alias lt='ls --tree --depth 2'

    alias l1='ls -1'
    alias l2='ls --tree --depth 2'
    alias l3='ls --tree --depth 3'
fi

alias ..='cd ..'
alias ...='cd ../..'

alias b='cd -'

alias pd='pushd'
alias po='popd'
alias dl='dirs -v'


##########
# fzf
##########

if command -v fzf >/dev/null 2>&1; then

    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
    elif command -v rg >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
    else
        export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*"'
    fi

    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    if command -v bat >/dev/null 2>&1; then
        export FZF_CTRL_T_OPTS='--preview "bat --style=plain --color=always {} | head -200"'
    else
        export FZF_CTRL_T_OPTS='--preview "head -200 {}"'
    fi

    # Ubuntu/Debian apt版fzf
    if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi

    if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    fi
fi


##########
# zoxide
##########

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi


##########
# fd
##########

if command -v fdfind >/dev/null 2>&1 &&
   ! command -v fd >/dev/null 2>&1; then
    alias fd='fdfind'
fi


##########
# Directory navigation
##########

# cdしたら自動でll
cd() {
    builtin cd "$@" || return
    ll
}


# zoxide + fzf
zfz() {
    local dir

    dir="$(
        zoxide query -l 2>/dev/null |
        fzf --prompt='zoxide> ' --height=80% --reverse
    )"

    [[ -n "$dir" ]] && builtin cd "$dir"
}


zlist() {
    zoxide query -l | nl -ba
}


# Git rootを起点にディレクトリ選択
cdf() {
    local root dir

    if command -v git >/dev/null 2>&1; then
        root="$(git rev-parse --show-toplevel 2>/dev/null)"
    fi

    root="${root:-.}"

    dir="$(
        fd -t d -H -I --strip-cwd-prefix . "$root" 2>/dev/null |
        fzf --prompt="cdf ($root)> " --height=80% --reverse
    )"

    [[ -n "$dir" ]] &&
        builtin cd "${root%/}/$dir"
}


# 親ディレクトリ選択
cdu() {
    local -a list
    local path pick p

    list=("/")

    path="/"

    for p in ${(s:/:)PWD}; do
        [[ -z "$p" ]] && continue

        path="${path%/}/$p"
        list+=("$path")
    done

    pick="$(
        printf '%s\n' "${list[@]}" |
        fzf --prompt='parent> ' --height=60% --reverse
    )"

    [[ -n "$pick" ]] && builtin cd "$pick"
}


# ghq
cdg() {
    local dir

    dir="$(ghq list -p | fzf)"

    [[ -n "$dir" ]] && builtin cd "$dir"
}


# n階層上へ
up() {
    local n="${1:-1}"
    local path="."

    while (( n > 0 )); do
        path="$path/.."
        (( n-- ))
    done

    builtin cd "$path"
}


##########
# alert
##########

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
  "$(history 1 | sed -e '\''s/^[[:space:]]*[0-9]\+[[:space:]]*//;s/[;&|][[:space:]]*alert$//'\'')"'

##########
# Local override
##########

[[ -f "$XDG_CONFIG_HOME/zshrc.local" ]] &&
    source "$XDG_CONFIG_HOME/zshrc.local"

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

##########
# Company CA
##########

CA_PATH=/mnt/c/Users/ck/vault/certs/company-ca.crt

if [[ -f "$CA_PATH" ]]; then
    export NODE_EXTRA_CA_CERTS="$CA_PATH"
fi


##########
# Starship
##########

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi


##########
# Editor
##########

export EDITOR=vim
export VISUAL=vim
