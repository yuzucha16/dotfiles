# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 8

3. 【起票 11-15】【判断:ユーザー】WezTerm + claude + nvim の使用感を試して、使い続けるかと、足すものを決める（構成は 11-15 に作成済み。経緯は `docs/log-history.md` の同日の項、調査と手段の比較は `docs/log-draft-terminal-sessions.md`）。決める点: 使い続けるか。決めたら、decisions の「ターミナル起点から Zed へ移行中」（2026-10 ごろの項）を見直しとして記録する。nvim は 11-15 に LazyVim 化済み（使い勝手を確認中。重いときは `NVIM_LITE=1`）。zellij（フローティングペイン・セッション残存）、nvim の追加の拡張（AstroNvim の設定の部分マージなど）は、使って足りないと感じたときに起票する。
5. 【起票 11-15】【やる:ユーザー】WezTerm + claude + nvim の動作確認: (a) `WEZTERM_CONFIG_FILE` を使わず、通常の起動（`links.map` のリンク）で左 claude・右 nvim が組まれる、(b) claude 自身の入力待ち・停止で、別タブにいるときタブに 🔔 が付く（11-15 は手で鳴らした bell だけ確認）、(c) タブ名が `wslhost.exe` のまま（直したいか）、(d) 動作確認で気づいた直しを伝える（直しは AI が行う）。完了: (a)〜(c) の結果がユーザーから報告される。
7. 【起票 11-15】【やる:AI】`scripts/windows/30_link.bat` を、Developer Mode がオフのときは何も変えずに止める（先に確認する）。完了: オフの状態で `link` を実行すると、既存のリンクを消さずに `[ERR]` で止まり、`tests/windows/` に再現の試験がある。理由: 11-15 に、既存のファイルリンクが消えて Windows Terminal の設定が初期化された（`decisions.md` の同日の項）。

## Open Questions
