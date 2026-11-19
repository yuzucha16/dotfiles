# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 15

14. 【起票 11-20】【判断:ユーザー（案は承認済み。実装前に前提確認）】 Claude Code（CLI）の見た目を目に優しくする。(a) ユーザープロンプトの背景を淡い青に、(b) diff の背景も同じ淡い青系に、(c) ツール出力の表示を絞る。調査済み（公式 `terminal-config` `fullscreen` `settings-reference`、2026-11-20）: カスタムテーマは `~/.claude/themes/<slug>.json`（`name` `base` `overrides`。色は `#rrggbb` など）。トークンは `userMessageBackground`（プロンプト背景）、`diffAdded` `diffRemoved` `diffAddedWord` `diffRemovedWord`（diff）。`/theme` で選ぶと `custom:<slug>` が保存される。`/focus` は「最後のプロンプト、ツール呼び出しの 1 行要約（編集は diffstat つき）、最終応答」だけの静かな表示で、設定は次のセッションにも残る（もう一度 `/focus` で解除）。`viewMode`（`default`/`verbose`/`focus`）で起動時の表示を固定できる（詳細は未確認）。`Ctrl+O` はトランスクリプトの切替。端末では mod の `$.theme.set` は描画されないので使わない。完了: テーマ JSON を置き `/theme` で選んで見え方をユーザーが確認、`/focus` か `viewMode` の採否が決まる。
   - 次の一手: ユーザーに前提を確認してから `~/.claude/themes/` を作る。置き場はユーザー環境全体なので、dotfiles の管理対象にするか（`home/.claude/` 等）も先に決める。色案は淡い青（背景 `#2a3b52` 前後、diff は `#2a3b52` 系で追加/削除を明度差で区別）。`/focus` を試して `viewMode` の値を `settings-reference` で確かめる。

13. 【起票 11-19】【判断:ユーザー】 `git -C` の権限まわりの残りを扱うか決める。(a) `git diff *` `git log *` の `--output=<file>`、`git commit *` の hook 実行は `-C` を消しても残る穴。(b) `-C` 前提の共有ノート（`exmem/lessons/shell-command-usecases.md:153`、`claude-code-permissions.md:74-76,107`、`ai-room-setup-manual.md:74,166`）は dotfiles から書けないので「ナレッジ化して」で直す。完了: (a) を塞ぐか許容するか、(b) を直すかが決まる。
   - 次の一手: 決定後、(a) は deny を足す案を `decisions.md` で検討、(b) は「ナレッジ化して」

## Open Questions

