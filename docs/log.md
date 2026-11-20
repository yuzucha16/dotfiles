# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 21

16. 【起票 11-20】【やる:AI】 room 行に API 認証を足す。部屋では DPAPI が使えず、Windows の env も渡さない決まりなので、キーの経路（引数 / `room.py` に `--api` を足す）をユーザーが決めてから実装する。NA 15 では見送り（ユーザー 11-20）。OAuth は NA 15 で `room-profiles.json` に足した（env なしの `room start`。実機で未確認: `/login` が部屋に残るか、部屋の既定が Bedrock 等でないか）。

17. 【起票 11-20】【やる:ユーザー】 wezterm の room 選択（NA 15）の実機確認。`Ctrl+Shift+T` → `room: <project>` → Bedrock / gateway / OAuth の起動。確認: (1) 人が `links.map` を反映（`room-profiles.json` のリンク） (2) claude の終了でアンマウントされる (3) 強制終了後に `room umount` で残骸を拾える (4) Bedrock の `--settings` の env が通る (5) OAuth: `/login` が部屋に残るか、部屋の既定が Bedrock 等でないか。pc2 は Bedrock・gateway なし → OAuth だけ試せる。結果で修正し、`docs/setup/wezterm-zellij-nvim.md` の「未確認」を更新。

18. 【起票 11-20】【やる:ユーザー】 認証起動の設計書（`docs/design/auth-launch-unification.md`。持ち出し用は `docs/design/auth-launch-plan-b.md`）の未回答の質問 Q1・Q3〜Q7 に答える（Q2 は回答済み: IAM キーは許される）。実機確認と実装は NA 19。

19. 【起票 11-20】【やる:ユーザー+AI】 Windows と room の認証つき claude 起動を揃える（案 A か案 B。比較と三層レビューは済み。B が有力だが、確定は A の原因特定のあと）。**開始: `docs/design/auth-launch-plan-b.md` を読む。** 手順: (1) ユーザー: PC で V1、V2-0〜V2-6（案 A の原因特定）、V3 を行い、結果を同書 6 章へ記入。(2) ユーザー: 6.4 の比較表を埋めて A か B かを決め、`decisions.md` に書く。(3) B なら、Q3（NA 15 の決定の変更）を承認し、AI が同書 3.3 の 2→3→4→5→6 を実装して V5〜V8 で must（oauth・bedrock）を確認。A なら `--cmd` の修正だけ。後回し: 案 E（緊急用 `claude-pick`）、起動の遅さ（V12）。V8 などは NA 17 と重なる。

20. 【起票 11-20】【やる:ユーザー+AI】 zellij・nvim の変更（調査は済み。**開始: `docs/design/zellij-nvim-customize.md` を読む**）。手順: (1) ユーザー: PC で Z1（`Alt+n`・`Alt+f` のシェルが、Windows は scoop の pwsh7、WSL は bash か。違えばセッションを作り直す）と Z3（スクロール）を確かめ、設定の変更が要るか決める（開始ディレクトリの `default_cwd "~"`、`Alt PageUp/PageDown` は任意。nvim の pane のショートカットは omit の方針）。(2) AI: nvim に `lua/plugins/explorer.lua`（Snacks explorer を右・幅 27）と `lua/plugins/markdown.lua`（render-markdown.nvim を単体で再導入）を足し、N1〜N4 を確かめる。render-markdown の更新状況は `:Lazy` で確認（N4）。変更の前に `decisions.md` を検索する。

## Open Questions

