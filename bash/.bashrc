# ~/.bashrc — interactive shells only

# ==== 非対話シェルでは抜ける ====
case $- in
  *i*) ;;
    *) return;;
esac

# XDG は .profile で export 済み想定（未定義ならフォールバック）
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

#### =========[ 履歴強化 (XDG 配置) ]=========
# 履歴ファイルを XDG_STATE_HOME へ
HISTFILE="$XDG_STATE_HOME/bash/history"
mkdir -p "$(dirname "$HISTFILE")"

HISTSIZE=50000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups
# 不要な履歴は保存しない
HISTIGNORE='ls:ll:la:cd:pwd:clear:history'

# 追記 & セッション間即時共有（既存の PROMPT_COMMAND を壊さない）
shopt -s histappend
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

#### =========[ 入力補助・補完 ]=========
# 端末サイズ変化を自動で反映
shopt -s checkwinsize
# ディレクトリ名だけで cd
shopt -s autocd
# cd のタイプミスを自動修正
shopt -s cdspell
# ** で再帰グロブ
shopt -s globstar
# 複数行コマンドを履歴1エントリにまとめる
shopt -s cmdhist
# 拡張グロブ
shopt -s extglob

# bash-completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Readline 補完改善
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set menu-complete-display-prefix on'
bind 'set page-completions off'
# Tab/Shift-Tab で順方向/逆方向補完
bind '"\t": menu-complete'
bind '"\e[Z": reverse-menu-complete'
# ↑/↓ で同じ接頭辞の履歴検索
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
# Ctrl-p/Ctrl-n にも割当
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

#### =========[ プロンプト ]=========
PS1='\[\e[1;32m\]\u@\h \[\e[1;34m\]\w\[\e[0m\]\$ '
# starship/direnv 等は必要ならここで初期化
# command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
# command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

#### =========[ alias ]=========
# dircolors は XDG とホーム直下の両対応
if command -v dircolors >/dev/null 2>&1; then
  if [ -r "$XDG_CONFIG_HOME/dircolors" ]; then
    eval "$(dircolors -b "$XDG_CONFIG_HOME/dircolors")"
  elif [ -r "$HOME/.dircolors" ]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# ls 系
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
# ===== lsd alias 設定 =====

# lsdがあるときだけ有効化
if command -v lsd >/dev/null 2>&1; then
  # ls → lsd
  alias ls='lsd --group-dirs=first --color=auto'

  # よく使うバリエーション
  alias l='ls -l'                # 標準的な詳細表示
  alias la='ls -a'                # 隠しファイル込み
  alias ll='ls -la'              # 隠し含めた詳細表示
  alias lt='ls --tree'            # ツリー表示（デフォ深さ無制限）
  #alias ll='ls -l'                # 標準的な詳細表示
  #alias lla='ls -la'              # 隠し含めた詳細表示
  #alias l1='ls -1'                # 1カラムで一覧
  
  # ツリーを深さ制限付きで（例: 2階層）
  alias l1='ls -1'                # 1カラムで一覧
  alias l2='ls --tree --depth 2'
  alias l3='ls --tree --depth 3'
fi

# ディレクトリ移動
alias ..='cd ..'
alias ...='cd ../..'

# 長時間コマンド終了通知（WSL では notify-send が無い場合あり）
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
  "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#### =========[ fzf 連携 (あれば自動有効化) ]=========
if command -v fzf >/dev/null 2>&1; then
  # 検索コマンド (fd > rg > find)
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  # プレビュー (bat > head)
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS='--preview "bat --style=plain --color=always {} | head -200"'
  else
    export FZF_CTRL_T_OPTS='--preview "head -200 {}"'
  fi

  # （必要なら）公式のキーバインド/補完を有効化
  # [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
  # [ -f /usr/share/doc/fzf/examples/completion.bash ] && . /usr/share/doc/fzf/examples/completion.bash
fi

##########
# zoxide 初期化
##########
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash 2>/dev/null || zoxide init zsh 2>/dev/null)"
fi

##########
# fd の別名（Ubuntu は fdfind）
##########
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

##########
# 1) 直前ディレクトリに即戻る（リカバリ最短）
##########
alias b='cd -'   # “back” の意味で覚えやすく

##########
# 2) zoxide DB を fzf で選んでジャンプ（どこからでも候補に出る）
#    → 「上位や別プロジェクトも探したい」問題の本命対策
##########
zfz() {
  local dir
  dir="$(zoxide query -l 2>/dev/null | fzf --prompt='zoxide> ' --height=80% --reverse)"
  [ -n "$dir" ] && cd "$dir"
}

# 迷ったらまず候補を見る：zoxide の候補表示だけ
zlist() {
  zoxide query -l | nl -ba
}

##########
# 3) プロジェクト起点の fzf cd（Git ルート優先、なければカレント）
#    → 「配下だけで良いけど、プロジェクトのトップから探したい」ケース
##########
cdf() {
  local root dir
  if command -v git >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel 2>/dev/null)"
  fi
  root="${root:-.}"
  dir="$(
    fd -t d -H -I --strip-cwd-prefix . "$root" 2>/dev/null \
    | fzf --prompt="cdf ($root)> " --height=80% --reverse
  )"
  [ -n "$dir" ] && cd "${root%/}/$dir"
}

##########
# 4) 親ディレクトリだけを選んで上に移動（“上位も対象にしたい”の軽量解）
##########
cdu() {
  # 現在位置から / までの親一覧を作って fzf
  local IFS=/ parts=() p path
  read -ra parts <<<"$(pwd)"
  path="/"
  local list=("/")
  for p in "${parts[@]:1}"; do
    path="${path%/}/$p"
    list+=("$path")
  done
  local pick
  pick="$(printf '%s\n' "${list[@]}" | fzf --prompt='parent> ' --height=60% --reverse)"
  [ -n "$pick" ] && cd "$pick"
}

##########
# 5) 上に n 階層上がる関数（例: up 3）
##########
up() {
  local n="${1:-1}" path="."
  while [ "$n" -gt 0 ]; do path="$path/.."; n=$((n-1)); done
  cd "$path"
}

##########
# 6) pushd/popd を少し使いやすく
##########
alias pd='pushd'
alias po='popd'
alias dl='dirs -v'  # スタック可視化

# cdしたら自動でlsする関数
cd() {
    # 引数があればそのディレクトリへ、なければホームへ
    if [ $# -eq 0 ]; then
        builtin cd ~ || return
    else
        builtin cd "$@" || return
    fi
    # cd成功時にls実行
    ls --color=auto -F
}

# fzfの標準キーバインド/補完（apt版の例）
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f /usr/share/doc/fzf/examples/completion.bash ]   && source /usr/share/doc/fzf/examples/completion.bash

#### =========[ ローカル上書き（任意） ]=========
# XDG 配下でのローカル拡張（マシン固有・社内PC等）
[ -f "$XDG_CONFIG_HOME/bashrc.local" ] && . "$XDG_CONFIG_HOME/bashrc.local"

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

cd ~/dev/src

source /home/ycy/.config/broot/launcher/bash/br
export EDITOR=nvim
export VISUAL=nvim
