# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 15

13. 【起票 11-19】【判断:ユーザー】 `git -C` の権限まわりの残りを扱うか決める。(a) `git diff *` `git log *` の `--output=<file>`、`git commit *` の hook 実行は `-C` を消しても残る穴。(b) は 11-20 に完了（resources `37810576`）。完了: (a) を塞ぐか許容するかが決まる。
   - 次の一手: (a) は deny を足す案を `decisions.md` で検討。

## Open Questions

