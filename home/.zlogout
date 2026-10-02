# ~/.zlogout

# 必要なら画面をクリア
if [[ "$SHLVL" -eq 1 ]]; then
    if [[ -x /usr/bin/clear_console ]]; then
        /usr/bin/clear_console -q
    fi
fi

# 必要ならGPG agent終了
# gpgconf --kill gpg-agent >/dev/null 2>&1

# 必要ならSSH agent終了
# [[ -n "$SSH_AGENT_PID" ]] &&
#     eval "$(ssh-agent -k)" >/dev/null 2>&1
