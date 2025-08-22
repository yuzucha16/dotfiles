# --------------------------------------------
# 基本オプション / 補完の初期化は一度だけ
# --------------------------------------------
setopt prompt_subst
setopt interactive_comments
setopt auto_pushd pushd_ignore_dups
setopt no_flow_control
setopt extended_glob
setopt auto_cd
setopt notify
setopt print_eight_bit
setopt print_exit_value
setopt mark_dirs
setopt no_clobber

# スペル補正（強すぎると邪魔なので必要に応じてどちらか一方）
# setopt correct
# setopt correct_all

autoload -Uz compinit promptinit colors
# compaudit の権限警告を無視したいなら -u（必要なければ外す）
compinit -u
promptinit
colors

# --------------------------------------------
# Prezto（zplug 経由）
# --------------------------------------------
if [[ -s "$HOME/.zplug/repos/sorin-ionescu/prezto/init.zsh" ]]; then
  source "$HOME/.zplug/repos/sorin-ionescu/prezto/init.zsh"
fi

# --------------------------------------------
# General
# --------------------------------------------
export EDITOR=vim
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/go/bin:/usr/local/go/bin"
export PATH="$PATH:/snap/onefetch/current/bin"   # snap版 onefetch を使う場合のみ

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

umask 022
ulimit -c 0

# --------------------------------------------
# Completion
# --------------------------------------------
# compinit は上で初期化済み
zstyle ':completion:*' menu select
setopt list_packed
# setopt list_types
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:manuals' separate-sections true
setopt magic_equal_subst

# --------------------------------------------
# History
# --------------------------------------------
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=100000
#setopt histignore

