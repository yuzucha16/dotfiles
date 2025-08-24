# ~/.bash_logout — executed by bash(1) when login shell exits

# 1. 履歴を確実に保存（.bashrcでhistappend済みだが明示的にflush）
history -a
history -w

# 2. 作業ログを残したい場合（任意）
# mkdir -p "$XDG_STATE_HOME/bash"
# echo "logout $(date '+%F %T')" >> "$XDG_STATE_HOME/bash/logout.log"

# 3. プライバシーのための画面クリア（必要な場合のみ）
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

# 4. (必要なら) gpg/ssh エージェントの終了
# gpgconf --kill gpg-agent >/dev/null 2>&1 || true
# [ -n "$SSH_AGENT_PID" ] && eval "$(ssh-agent -k)" >/dev/null 2>&1
