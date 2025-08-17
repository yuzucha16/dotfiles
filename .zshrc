# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi
# Source Prezto.
if [[ -s "$HOME/.zplug/repos/sorin-ionescu/prezto/init.zsh" ]]; then
  source "$HOME/.zplug/repos/sorin-ionescu/prezto/init.zsh"
fi

# -----------------------------
# Lang
# -----------------------------
#export LANG=ja_JP.UTF-8
#export LESSCHARSET=utf-8

# -----------------------------
# General
# -----------------------------
autoload -Uz colors ; colors # 色を使用
export EDITOR=vim # エディタをvimに設定
setopt IGNOREEOF # Ctrl+Dでログアウトしてしまうことを防ぐ
export PATH="$PATH:$HOME/bin"                       # bin
export PATH="$PATH:$HOME/go/bin:/usr/local/go/bin:" # go
export PATH="$PATH:/snap/onefetch/current/bin"      # onefetch
setopt auto_pushd # cdした際のディレクトリをディレクトリスタックへ自動追加
setopt pushd_ignore_dups # ディレクトリスタックへの追加の際に重複させない
#bindkey -e # emacsキーバインド
#bindkey -v # viキーバインド
setopt no_flow_control # フローコントロールを無効にする
setopt extended_glob # ワイルドカード展開を使用する
setopt auto_cd # cdコマンドを省略して、ディレクトリ名のみの入力で移動
#setopt xtrace # コマンドラインがどのように展開され実行されたかを表示するようになる
setopt auto_pushd # 自動でpushdを実行
setopt pushd_ignore_dups # pushdから重複を削除
#setopt no_beep # ビープ音を鳴らさないようにする
setopt auto_param_keys # カッコの対応などを自動的に補完する
setopt auto_cd # ディレクトリ名の入力のみで移動する
setopt notify # bgプロセスの状態変化を即時に知らせる
setopt print_eight_bit # 8bit文字を有効にする
setopt print_exit_value # 終了ステータスが0以外の場合にステータスを表示する
setopt mark_dirs # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt correct # コマンドのスペルチェックをする
setopt correct_all # コマンドライン全てのスペルチェックをする
setopt no_clobber # 上書きリダイレクトの禁止

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
setopt noautoremoveslash # パスの最後のスラッシュを削除しない
#setopt hash_cmds # 各コマンドが実行されるときにパスをハッシュに入れる
export RSYNC_RSH=ssh # rsysncでsshを使用する

# その他
umask 022
ulimit -c 0

# -----------------------------
# Prompt
# -----------------------------
# %M    ホスト名
# %m    ホスト名
# %d    カレントディレクトリ(フルパス)
# %~    カレントディレクトリ(フルパス2)
# %C    カレントディレクトリ(相対パス)
# %c    カレントディレクトリ(相対パス)
# %n    ユーザ名
# %#    ユーザ種別
# %?    直前のコマンドの戻り値
# %D    日付(yy-mm-dd)
# %W    日付(yy/mm/dd)
# %w    日付(day dd)
# %*    時間(hh:flag_mm:ss)
# %T    時間(hh:mm)
# %t    時間(hh:mm(am/pm))
autoload -Uz promptinit ; promptinit ; prompt powerlevel10k
#PROMPT='%F{cyan}%n@%m%f:%~# '

# -----------------------------
# Completion
# -----------------------------
autoload -Uz compinit ; compinit # 自動補完を有効にする
#setopt complete_in_word # 単語の入力途中でもTab補完を有効化
setopt correct # コマンドミスを修正
zstyle ':completion:*' menu select # 補完の選択を楽にする
setopt list_packed # 補完候補をできるだけ詰めて表示する
#setopt list_types # 補完候補にファイルの種類も表示する
export LSCOLORS=Exfxcxdxbxegedabagacad # 色の設定

# 補完時の色設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion::complete:*' use-cache true # キャッシュの利用による補完の高速化
autoload -U colors ; colors ; zstyle ':completion:*' list-colors "${LS_COLORS}" # 補完候補に色つける
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 大文字・小文字を区別しない(大文字を入力した場合は区別する)
zstyle ':completion:*:manuals' separate-sections true # manの補完をセクション番号別に表示させる
setopt magic_equal_subst # --prefix=/usr などの = 以降でも補完

# -----------------------------
# History
# -----------------------------
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=100000

setopt histignorealldups # ヒストリーに重複を表示しない
setopt share_history # 他のターミナルとヒストリーを共有
setopt hist_ignore_all_dups # すでにhistoryにあるコマンドは残さない
#alias h='fc -lt '%F %T' 1' # historyに日付を表示
setopt hist_reduce_blanks # ヒストリに保存するときに余分なスペースを削除する
setopt inc_append_history # 履歴をすぐに追加する
setopt hist_verify # ヒストリを呼び出してから実行する間に一旦編集できる状態になる
#setopt hist_reduce_blanks #余分なスペースを削除してヒストリに記録する
#setopt hist_save_no_dups # historyコマンドは残さない
#bindkey '^R' history-incremental-pattern-search-backward # ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
#bindkey "^S" history-incremental-search-forward
#bindkey "^P" history-beginning-search-backward-end # ^P,^Nを検索へ割り当て
#bindkey "^N" history-beginning-search-forward-end

# -----------------------------
# Function
# -----------------------------

# -----------------------------
# Alias
# -----------------------------
# グローバルエイリアス
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'

# エイリアス
alias lst='ls -ltr --color=auto'
alias ls='ls --color=auto'
alias la='ls -la --color=auto'
alias ll='ls -a -l --color=auto'

alias du="du -h"
alias df="df -Th"
alias su="su -l"
alias so='source'
alias vi='vim'
alias vz='vim ~/.zshrc'
alias c='cdr'
alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias ..='c ../'
alias back='pushd'
alias diff='diff -U1'

#alias tma='tmux attach'
#alias tml='tmux list-window'

#alias dki="docker run -i -t -P"
#alias dex="docker exec -i -t"
#alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

# -----------------------------
# Plugin
# -----------------------------

## Automatically start application
function do_autostart() {
  autokey-gtk -c
}
#do_autostart

# fzf-history
fzf-history-selection() {
    BUFFER=`history -n 1 | tac | awk '!a[$0]++' | fzf`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

# cdr
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert  both
    zstyle ':chpwd:*'      recent-dirs-default true
    zstyle ':chpwd:*'      recent-dirs-max     1000
    zstyle ':chpwd:*'      recent-dirs-file    "$HOME/.cache/chpwd-recent-dirs"
fi

function fzf-cdr (){
    local selected_dir="$(cdr -l | sed 's/^[0-9]\+ \+//' | fzf --prompt="cdr >" --query "$LBUFFER")"
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N fzf-cdr
bindkey '^E' fzf-cdr

# fbr - checkout git branch
function fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
    fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.*//" | sed "s#remotes/[^/]*/##")
}

function fcshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
FZF-EOF"
}

function fzf-z-search() {
    local res=$(z | sort -rn | cut -c 12- | fzf)
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}
zle -N fzf-z-search
bindkey '^f' fzf-z-search

export FZF_DEFAULT_OPTS="--height 25% --layout=reverse --border --preview-window 'right:50%'"

function fzf-change-dir() {
    local WORKDIR=$(ghq list -p | fzf --preview "onefetch {}" --preview-window=right:60% --height 50%)
    [ -z "$WORKDIR" ] && return
    cd $WORKDIR
}
bindkey '^g' fzf-change-dir

# -----------------------------
# Plugin
# -----------------------------
# zplugが無ければインストール
if [[ ! -d ~/.zplug ]];then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

# zplug enabled
source ~/.zplug/init.zsh

# プラグインList

# prezto
export ZPLUG_HOME=$HOME/.zplug
source $ZPLUG_HOME/init.zsh
zplug "sorin-ionescu/prezto"
zplug "marzocchi/zsh-notify"

# zplug "ユーザー名/リポジトリ名", タグ
zplug "sindresorhus/pure"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "chrissicool/zsh-256color"
zplug "mafredri/zsh-async"
zplug "b4b4r07/enhancd", use:init.sh
zplug "rupa/z", use:"*.sh"

# Install prezto if needed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
      echo; zplug install
  fi
fi

zplug "modules/prompt", from:prezto

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
(( ! ${+functions[p10k]} )) || p10k finalize

cd ~/ghq/10.132.42.35/gitlab/i3-module/fw-generic/src

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
[[ ! -f ~/dotfiles/.p10k.zsh ]] || source ~/dotfiles/.p10k.zsh
