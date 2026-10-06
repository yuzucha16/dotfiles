# ~/.config/shell/common.sh — bash / zsh 共通の対話シェル設定
# .bashrc / .zshrc から source される（zsh では compinit の後）。
# シェル固有の設定（履歴・補完・キーバインド・プロンプト）は各 rc に置く
# （zfz / cdg のキーバインドだけは、関数と一緒にここに置く）。
# コマンド体系は pwsh 側 (profile.ps1) と揃えること（基本エイリアスのみ）。
# 方針: 起動を軽く保つ。ツール (lsd/fzf/fd/bat/zoxide/ghq) は l0a で入る前提で、
# 不在時の代替は持たない。fzf は Ctrl-r（履歴検索）と Ctrl-t（ファイル検索）、
# zfz / cdg の選択に使う（補完と Alt-c は使わない）。

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
# fzf (Ctrl-r: 履歴検索 / Ctrl-t: ファイル検索)
##########
export FZF_DEFAULT_OPTS='--height=40% --reverse'
export FZF_CTRL_T_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS='--preview "bat --style=plain --color=always --line-range :200 {}"'

# apt 版 fzf のキーバインド。補完 (completion.*) は読まない
_fzf_shell=bash
[ -n "${ZSH_VERSION:-}" ] && _fzf_shell=zsh
[ -f "/usr/share/doc/fzf/examples/key-bindings.$_fzf_shell" ] &&
  . "/usr/share/doc/fzf/examples/key-bindings.$_fzf_shell"
unset _fzf_shell

# key-bindings が Alt-c（cd）も奪うので、標準の capitalize-word に戻す
if [ -n "${ZSH_VERSION:-}" ]; then
  bindkey -M emacs '^[c' capitalize-word
else
  bind -m emacs-standard '"\ec": capitalize-word'
fi

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
# $CERTS_DIR (Windows 側の %CERTS_DIR% = %USERPROFILE%\.certs は、WSLENV の /p で WSL のパスに変換されて渡る)。
# 未設定 (ネイティブ Linux など) は ~/.certs
##########
_company_ca="${CERTS_DIR:-$HOME/.certs}/company-ca.crt"
if [ -f "$_company_ca" ]; then
  export NODE_EXTRA_CA_CERTS="$_company_ca"
fi
unset _company_ca

##########
# Editor
##########
export EDITOR=vim
export VISUAL=vim
