# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 14

13. 【起票 11-19】【判断:ユーザー】 `git -C` の権限まわりの残りを扱うか決める。(a) `git diff *` `git log *` の `--output=<file>`、`git commit *` の hook 実行は `-C` を消しても残る穴。(b) `-C` 前提の共有ノート（`exmem/lessons/shell-command-usecases.md:153`、`claude-code-permissions.md:74-76,107`、`ai-room-setup-manual.md:74,166`）は dotfiles から書けないので「ナレッジ化して」で直す。完了: (a) を塞ぐか許容するか、(b) を直すかが決まる。
   - 次の一手: 決定後、(a) は deny を足す案を `decisions.md` で検討、(b) は「ナレッジ化して」

12. 【起票 11-19】【判断:ユーザー】 zellij の claude pane の未コミットの変更（`config.kdl`、`claude-a/b.kdl`、`wezterm.lua`。経緯は log-history の 11-19「NA 10」）を、どう扱うか決める。原因は画面サイズ（ee の実機: 大きくすると 3 列中央）なので、`wezterm.lua` の 2 段起動（背景作成→attach）が要るか不要かを確かめ、要らなければ戻す。完了: 4 ファイルをコミットするか戻すかが決まる。
   - 次の一手: ee の判断を聞き、commit-push-rules.md を読んでパス指定でコミット。`terminal-units.md` と `wezterm-zellij-nvim.md` も実態に更新

## Open Questions

