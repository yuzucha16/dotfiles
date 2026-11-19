# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 10

9. 【起票 11-19】【やる:AI】 WezTerm+zellij+nvim 上の claude の使い勝手を整える（ee の承認済み。cwd は zellij の問題として対象外）。完了（11-19）: `home/.claude/keybindings.json`（`Chat`: enter→`chat:newline`、ctrl+enter→`chat:submit`）と `manifests/links.map` の行を追加（コミット 33e8492。ee が `30_link.bat` を実行済み）。Ctrl+Enter は pwsh と zellij の両方で届くと ee が実機で確認したので、`wezterm.lua` の変更は不要。`~\.claude\settings.json` は実ファイルだったが、dotfiles 側と差分なしで、リンクに置き換わった（ee の報告）。
   - 未着手: statusLine（直近 1 呼び出しの `context_window.current_usage` を表示。スクリプトは未作成）、テーマ `custom:gruvbox`（`home/.claude/themes/gruvbox.json` は未作成。リンクも未追加）、入力欄を広くする件（設定は無く、`/tui fullscreen` を試すだけ）。いずれも dotfiles と `~\.claude\` に実体なし。
   - 次の一手: statusLine とテーマの仕様（表示項目、色）を ee に確認してから、同じ方式（`home/.claude/` + `links.map`）で置く。push は人。


## Open Questions

