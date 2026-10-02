# ~/.zprofile
# zsh のログインシェルは ~/.profile を読まないため、ここで読み込む。
# 設定本体は ~/.profile（POSIX sh 互換）に一本化している。
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
