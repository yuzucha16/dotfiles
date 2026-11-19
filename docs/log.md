# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 13

12. 【起票 11-19】【判断:ユーザー】 zellij の claude pane の未コミットの変更（`config.kdl`、`claude-a/b.kdl`、`wezterm.lua`。経緯は log-history の 11-19「NA 10」）を、どう扱うか決める。原因は画面サイズ（ee の実機: 大きくすると 3 列中央）なので、`wezterm.lua` の 2 段起動（背景作成→attach）が要るか不要かを確かめ、要らなければ戻す。完了: 4 ファイルをコミットするか戻すかが決まる。
   - 次の一手: ee の判断を聞き、commit-push-rules.md を読んでパス指定でコミット。`terminal-units.md` と `wezterm-zellij-nvim.md` も実態に更新

11. 【起票 11-19】【やる:ユーザー】 claude の statusline に認証種別（OAuth/API/Bedrock/Gateway。env と `rate_limits` からの推定）と `CLAUDE_CODE_HIDE_CWD=1` を足した（未コミット。`statusline.py`、`.claude/settings.json`）。実機で表示を確かめる。完了: 新規セッションで種別が `/status` と一致し、パスが消える。ロゴは消せない（zellij の `/clear` 注入は遅くなるので保留）。
   - 次の一手: 結果を聞いて log.md に書き、commit-push-rules.md を読んでパス指定でコミット

## Open Questions

