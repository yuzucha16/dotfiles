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
  alias ll='ls -l'                # 標準的な詳細表示
  alias la='ls -a'                # 隠しファイル込み
  alias lla='ls -la'              # 隠し含めた詳細表示
  alias lt='ls --tree'            # ツリー表示（デフォ深さ無制限）
  alias l1='ls -1'                # 1カラムで一覧

  # ツリーを深さ制限付きで（例: 2階層）
  alias l2='ls --tree --depth 2'
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

# ===== cd後に自動一覧表示（lsd 優先） =====
# 表示モード: grid / long / tree を選べる（未設定なら grid）
#   export CD_LS_MODE=long
#   export CD_LS_MODE=tree; export CD_LS_DEPTH=2
# 深さは tree モード時のみ有効（既定: 2）
: "${CD_LS_MODE:=grid}"
: "${CD_LS_DEPTH:=2}"

# 一覧表示の実体
_cd_ls() {
  if command -v lsd >/dev/null 2>&1; then
    case "$CD_LS_MODE" in
      long) lsd -l --group-dirs=first --color=always ;;
      tree) lsd --tree --depth "$CD_LS_DEPTH" --group-dirs=first --color=always | head -200 ;;
      grid|*) lsd --group-dirs=first --color=always ;;
    esac
  elif command -v eza >/dev/null 2>&1; then
    case "$CD_LS_MODE" in
      long) eza -l --group-directories-first --color=always ;;
      tree) eza --tree --level="$CD_LS_DEPTH" --group-directories-first --color=always | head -200 ;;
      grid|*) eza --group-directories-first --color=always ;;
    esac
  else
    # 最後の砦: GNU ls
    case "$CD_LS_MODE" in
      long) ls -l --color=auto -F ;;
      tree) ls -la --color=auto -F ;;  # treeモードの代替
      grid|*) ls --color=auto -F ;;
    esac
  fi
}

# ===== ディレクトリ変更検知フック（重複防止版） =====
__CD_LIST_LAST_PWD="$PWD"

__cd_list_on_chpwd() {
  if [[ "$PWD" != "$__CD_LIST_LAST_PWD" ]]; then
    __CD_LIST_LAST_PWD="$PWD"
    _cd_ls
  fi
}

__append_prompt_command() {
  local hook="$1"
  # すでに入っていたら追加しない
  if [[ "$PROMPT_COMMAND" != *"__cd_list_on_chpwd"* ]]; then
    if [[ -z "$PROMPT_COMMAND" ]]; then
      PROMPT_COMMAND="$hook"
    else
      PROMPT_COMMAND="$hook; $PROMPT_COMMAND"
    fi
  fi
}
__append_prompt_command "__cd_list_on_chpwd"
# =====================================================

# モード切替の小さなヘルパ（例: cdls tree 3）
cdls() {
  case "$1" in
    grid|long|tree) CD_LS_MODE="$1" ;;
    *) echo "Usage: cdls {grid|long|tree} [depth]" >&2; return 2 ;;
  esac
  [ "$2" ] && CD_LS_DEPTH="$2"
  echo "cd listing: mode=$CD_LS_MODE depth=$CD_LS_DEPTH"
}
# ===========================================

# ===== fzf Alt-C with lsd preview =====

# fzfの標準キーバインド/補完（apt版の例）
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f /usr/share/doc/fzf/examples/completion.bash ]   && source /usr/share/doc/fzf/examples/completion.bash

# ディレクトリ候補列挙コマンド
if command -v fdfind >/dev/null 2>&1; then
  export FZF_ALT_C_COMMAND='fdfind -H -t d --strip-cwd-prefix 2>/dev/null'
elif command -v fd >/dev/null 2>&1; then
  export FZF_ALT_C_COMMAND='fd -H -t d --strip-cwd-prefix 2>/dev/null'
else
  export FZF_ALT_C_COMMAND='find . -type d -print 2>/dev/null'
fi

# ===== lsd プレビュー =====
if command -v lsd >/dev/null 2>&1; then
  # lsd を tree の代わりに使う
  _PREVIEW_CMD='lsd --tree --depth 2 --color=always --group-dirs=first {} | head -200'
else
  _PREVIEW_CMD='tree -C -F -L 2 -a --dirsfirst {} | head -200'
fi

# fzf Alt-C のプレビューオプション
export FZF_ALT_C_OPTS="--preview='$_PREVIEW_CMD' \
  --preview-window=right:60%:wrap \
  --height=80% --layout=reverse --border \
  --bind=alt-p:toggle-preview,alt-j:preview-down,alt-k:preview-up"

# デフォルトのfzf全般に効くオプション
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --cycle --marker='*' --border --layout=reverse"

#### =========[ ローカル上書き（任意） ]=========
# XDG 配下でのローカル拡張（マシン固有・社内PC等）
[ -f "$XDG_CONFIG_HOME/bashrc.local" ] && . "$XDG_CONFIG_HOME/bashrc.local"

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

cd ~/dev/src
#. "$HOME/.cargo/env"

source /home/ycy/.config/broot/launcher/bash/br
