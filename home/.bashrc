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
HISTIGNORE='ls:ll:la:l:cd:pwd:clear:history'

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
# starship が使えない環境のフォールバック
PS1='\[\e[1;32m\]\u@\h \[\e[1;34m\]\w\[\e[0m\]\$ '

# 長時間コマンド終了通知（WSL では notify-send が無い場合あり）
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
  "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#### =========[ 共通設定 (alias / 関数 / fzf / zoxide / CA / EDITOR) ]=========
[ -f "$XDG_CONFIG_HOME/shell/common.sh" ] && . "$XDG_CONFIG_HOME/shell/common.sh"

#### =========[ ローカル上書き（任意） ]=========
# XDG 配下でのローカル拡張（マシン固有・社内PC等）
[ -f "$XDG_CONFIG_HOME/bashrc.local" ] && . "$XDG_CONFIG_HOME/bashrc.local"

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

cd ~
