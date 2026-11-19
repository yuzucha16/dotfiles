"""Claude Code status line: model | context used % | last-call tokens / window size."""
import json
import os
import sys


def fmt(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def auth_type(data):
    """認証方式の推定（公式の項目は無い）。優先順位は Claude Code の認証順に合わせる。
    環境変数と user settings の env / apiKeyHelper を見る。確実なのは /status。"""
    env = dict(os.environ)
    helper = None
    try:
        with open(os.path.join(os.path.expanduser("~"), ".claude", "settings.json"), encoding="utf-8") as f:
            st = json.load(f)
        env.update({k: str(v) for k, v in (st.get("env") or {}).items()})
        helper = st.get("apiKeyHelper")
    except Exception:
        pass
    if env.get("CLAUDE_CODE_USE_BEDROCK") in ("1", "true"):
        return "Bedrock"
    if env.get("ANTHROPIC_AUTH_TOKEN") or "spend_limit" in data:
        return "Gateway"
    if env.get("ANTHROPIC_API_KEY") or helper:
        return "API"
    if "rate_limits" in data:
        return "OAuth"
    return "?"


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        print("statusline: bad input")
        return
    model = (data.get("model") or {}).get("display_name") or "?"
    cw = data.get("context_window") or {}
    pct = cw.get("used_percentage")
    size = cw.get("context_window_size")
    cu = cw.get("current_usage")

    parts = [model, auth_type(data)]
    parts.append(f"ctx {pct:.0f}%" if isinstance(pct, (int, float)) else "ctx -")
    if cu:
        # same input-only formula as used_percentage
        used = sum(cu.get(k) or 0 for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
        tok = fmt(used)
    else:
        tok = "-"
    parts.append(f"{tok} / {fmt(size)}" if size else tok)
    print(" | ".join(parts))


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
