# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 19

16. 【起票 11-20】【やる:AI】 room 行に API 認証を足す。部屋では DPAPI が使えず、Windows の env も渡さない決まりなので、キーの経路（引数 / `room.py` に `--api` を足す）をユーザーが決めてから実装する。NA 15 では見送り（ユーザー 11-20）。OAuth は NA 15 で `room-profiles.json` に足した（env なしの `room start`。実機で未確認: `/login` が部屋に残るか、部屋の既定が Bedrock 等でないか）。

17. 【起票 11-20】【やる:ユーザー】 wezterm の room 選択（NA 15）の実機確認。`Ctrl+Shift+T` → `room: <project>` → Bedrock / gateway / OAuth の起動。確認: (1) 人が `links.map` を反映（`room-profiles.json` のリンク） (2) claude の終了でアンマウントされる (3) 強制終了後に `room umount` で残骸を拾える (4) Bedrock の `--settings` の env が通る (5) OAuth: `/login` が部屋に残るか、部屋の既定が Bedrock 等でないか。pc2 は Bedrock・gateway なし → OAuth だけ試せる。結果で修正し、`docs/setup/wezterm-zellij-nvim.md` の「未確認」を更新。

18. 【起票 11-20】【やる:ユーザー】 Windows と room の認証つき claude 起動を揃える設計の比較（`docs/design/auth-launch-unification.md`。案 A〜D、推奨は案 B で暫定）。実機確認 V1〜V10 と、9 章の Q1〜Q4 に答える。結果で案を決め、`decisions.md` に書く。V8 などは NA 17 と重なる。起動の遅さ（V10）は最後。

## Open Questions

