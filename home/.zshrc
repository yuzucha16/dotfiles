# ~/.zshrc

# XDG は .zprofile (.profile) で export 済み。非ログインシェルでは未定義なので、
# 使う箇所でインライン既定値 (${XDG_xxx:-...}) を使う

##########
# Interactive shell
##########

# Emacs keybindings
bindkey -e

# 履歴検索: 入力中の文字列で始まる履歴を上下キーで検索
bindkey '^[[A' history-beginning-search-backward   # up
bindkey '^[[B' history-beginning-search-forward    # down
bindkey '^P' history-beginning-search-backward     # p
bindkey '^N' history-beginning-search-forward      # n

##########
# History
##########

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

HISTSIZE=50000
SAVEHIST=200000

mkdir -p "$(dirname "$HISTFILE")"

# bash の ignoreboth 相当
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS

# セッション間で履歴共有
setopt SHARE_HISTORY

# 履歴が満杯のとき、重複エントリを先に削除
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

# -C: 補完定義のセキュリティ検査と再生成を省く（起動が約 0.08 秒速くなる）。
# 補完を追加するツールを入れたら `rm ~/.zcompdump*` して zsh を開き直す（l0a は自動で消す）
autoload -Uz compinit
compinit -C

bindkey '^I' menu-select

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
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

# 終了時に実行中のジョブがあれば確認
setopt CHECK_JOBS


##########
# alert
##########

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
  "$(history 1 | sed -e '\''s/^[[:space:]]*[0-9]\+[[:space:]]*//;s/[;&|][[:space:]]*alert$//'\'')"'


##########
# 共通設定 (alias / 関数 / fzf / zoxide / CA / EDITOR)
##########

[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/common.sh" ]] &&
    source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/common.sh"


##########
# Local override
##########

[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zshrc.local" ]] &&
    source "${XDG_CONFIG_HOME:-$HOME/.config}/zshrc.local"


##########
# autosuggestions
##########

[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh


##########
# Starship
##########

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
