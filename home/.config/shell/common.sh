# ~/.config/shell/common.sh — bash / zsh 共通の対話シェル設定
# .bashrc / .zshrc から source される（zsh では compinit の後）。
# シェル固有の設定（履歴・補完・キーバインド・プロンプト）は各 rc に置く
# （zfz / cdg のキーバインドだけは、関数と一緒にここに置く）。
# コマンド体系は pwsh 側 (profile.ps1) と揃えること（基本エイリアスのみ）。
# 方針: 起動を軽く保つ。ツール (lsd/fzf/fd/bat/zoxide/ghq) は l0a で入る前提で、
# 不在時の代替は持たない。fzf はキーバインド・補完を読み込まず、zfz/cdg の
# 選択にだけ使う（履歴検索は標準機能。pwsh と同じ）。

##########
# ls 系 (lsd)
##########
alias grep='grep --color=auto'

alias ls='lsd --group-dirs=first --color=auto'
alias l='ls -l'
alias la='ls -a'
alias ll='ls -la'
alias lt='ls --tree --depth 2'

alias l1='ls -1'
alias l2='ls --tree --depth 2'
alias l3='ls --tree --depth 3'

##########
# ディレクトリ移動
##########
alias ..='cd ..'
alias ...='cd ../..'
alias b='cd -'

alias pd='pushd'
alias po='popd'
alias dl='dirs -v'

##########
# zoxide (z / zi)
##########
if [ -n "${ZSH_VERSION:-}" ]; then
  eval "$(zoxide init zsh)"
else
  eval "$(zoxide init bash)"
fi

# zoxide の履歴から選んで移動
zfz() {
  local dir
  dir="$(zoxide query -l 2>/dev/null | fzf --prompt='zoxide> ' --height=80% --reverse)"
  [ -n "$dir" ] && builtin cd "$dir"
}

# ghq 管理下のリポジトリを選んで移動
cdg() {
  local dir
  dir="$(ghq list -p | fzf)"
  [ -n "$dir" ] && builtin cd "$dir"
}

# キーバインド: Alt+j = zfz, Alt+k = cdg（pwsh の profile.ps1 と揃える。全シェルで未使用のキーを選んだ）
if [ -n "${ZSH_VERSION:-}" ]; then
  # 入力中の行は残し、移動後にプロンプトを描き直す
  _zfz_widget() { zle -I; zfz; zle reset-prompt; }
  _cdg_widget() { zle -I; cdg; zle reset-prompt; }
  zle -N _zfz_widget
  zle -N _cdg_widget
  bindkey '^[j' _zfz_widget
  bindkey '^[k' _cdg_widget
else
  # プロンプトを更新するため、コマンドとして実行する（先頭の空白で履歴には残らない。
  # 入力中の行は kill ring へ退避されるので Ctrl-y で戻せる）
  bind '"\ej": "\C-u zfz\C-m"'
  bind '"\ek": "\C-u cdg\C-m"'
fi

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
