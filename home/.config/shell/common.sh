# ~/.config/shell/common.sh — bash / zsh 共通の対話シェル設定
# .bashrc / .zshrc から source される（zsh では compinit の後）。
# シェル固有の設定（履歴・補完・キーバインド・プロンプト）は各 rc に置く。
# コマンド体系は pwsh 側 (profile.ps1) と揃えること。

: "${XDG_CONFIG_HOME:=$HOME/.config}"

##########
# 色付きコマンド
##########
if command -v dircolors >/dev/null 2>&1; then
  if [ -r "$XDG_CONFIG_HOME/dircolors" ]; then
    eval "$(dircolors -b "$XDG_CONFIG_HOME/dircolors")"
  elif [ -r "$HOME/.dircolors" ]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
  # /mnt/c など other-writable (ow/tw/st) なディレクトリが背景色付きで読めなくなるのを避ける
  LS_COLORS="$(printf '%s' "$LS_COLORS" | sed -E 's/(^|:)(ow|tw|st)=[^:]*/\1\2=01;34/g')"
  export LS_COLORS
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

##########
# ls 系（lsd があれば置き換え）
##########
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

##########
# ディレクトリ移動
##########
alias ..='cd ..'
alias ...='cd ../..'
alias b='cd -'

alias pd='pushd'
alias po='popd'
alias dl='dirs -v'

# cd したら自動で ll（引数なしはホームへ）
cd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ || return
  else
    builtin cd "$@" || return
  fi
  ll
}

# n 階層上へ（例: up 3）
up() {
  local n="${1:-1}" p="."
  while [ "$n" -gt 0 ]; do p="$p/.."; n=$((n-1)); done
  cd "$p"
}

##########
# fd（Ubuntu 系は fdfind）
##########
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  fd() { command fdfind "$@"; }
fi

##########
# fzf
##########
if command -v fzf >/dev/null 2>&1; then
  # 検索コマンド (fd > rg > find)
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
  elif command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
  else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*"'
  fi
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  # プレビュー (bat > head)
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS='--preview "bat --style=plain --color=always {} | head -200"'
  else
    export FZF_CTRL_T_OPTS='--preview "head -200 {}"'
  fi

  # apt 版 fzf のキーバインド / 補完
  _fzf_shell=bash
  [ -n "${ZSH_VERSION:-}" ] && _fzf_shell=zsh
  for _fzf_f in key-bindings completion; do
    [ -f "/usr/share/doc/fzf/examples/$_fzf_f.$_fzf_shell" ] &&
      . "/usr/share/doc/fzf/examples/$_fzf_f.$_fzf_shell"
  done
  unset _fzf_shell _fzf_f
fi

##########
# zoxide
##########
if command -v zoxide >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(zoxide init zsh)"
  else
    eval "$(zoxide init bash)"
  fi
fi

##########
# fzf によるディレクトリ移動
##########

# zoxide の履歴から選んで移動
zfz() {
  local dir
  dir="$(zoxide query -l 2>/dev/null | fzf --prompt='zoxide> ' --height=80% --reverse)"
  [ -n "$dir" ] && builtin cd "$dir"
}

# zoxide の候補を番号付きで表示
zlist() {
  zoxide query -l | nl -ba
}

# Git ルート（なければカレント）を起点にディレクトリ選択
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
  [ -n "$dir" ] && builtin cd "${root%/}/$dir"
}

# 親ディレクトリを選んで移動
cdu() {
  local d="$PWD" list="" pick
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    list="$d"$'\n'"$list"
    d="${d%/*}"
  done
  list="/"$'\n'"$list"
  pick="$(printf '%s' "$list" | sed '/^$/d' | fzf --prompt='parent> ' --height=60% --reverse)"
  [ -n "$pick" ] && builtin cd "$pick"
}

# ghq 管理下のリポジトリを選んで移動
cdg() {
  local dir
  dir="$(ghq list -p | fzf)"
  [ -n "$dir" ] && builtin cd "$dir"
}

##########
# 社内プロキシ用 CA 証明書 (存在する環境のみ設定)
# Windows の %CERTS_DIR% (= C:\vault\certs) を WSL から参照する
##########
_company_ca=/mnt/c/vault/certs/company-ca.crt
if [ -f "$_company_ca" ]; then
  export NODE_EXTRA_CA_CERTS="$_company_ca"
fi
unset _company_ca

##########
# Editor
##########
export EDITOR=vim
export VISUAL=vim
