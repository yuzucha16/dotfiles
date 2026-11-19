"""Claude Code status line: model | context used % | last-call tokens / window size."""
import json
import sys


def fmt(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


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

    parts = [model]
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
