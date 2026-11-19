# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 9

8. 【起票 11-19】【やる:ユーザー】単位設計 `docs/setup/terminal-units.md` に沿って、既存の試作を消し、zellij・WezTerm・LazyVim を作って実機で確かめる。完了: 設計書 9 章の 9 点（性能の測定は 11 章。版の揃えは 12 章。実装は workbase の NA 59。残る未確認は lazygit の SHA-256 と Volta の検証方法）の結果が報告され、設計書が結果に合わせて直る。
   【決定済み 11-19】pane の配置は案 B。zellij の設定は room へ手で置く（`room init` では未配布）。試作は削除済み（退避 7ec6059、戻すときは revert）。nvim のリンク先は `%USERPROFILE%\.config\nvim`。
   【11-19 実機で確認済み】本番の `wezterm.lua` と LazyVim（5bfe4de）。bell: room と wsl は BEL で 🔔（room は `~/.claude/hooks/bell.sh`。workbase `d043b784` で `room init` の `bellhook` 段も直した。未 push）。**win は BEL を ConPTY が止める**ので、claude のフック `~/.claude/hooks/bell-mark.ps1` が `%TEMP%\wezterm-bell\<WEZTERM_PANE>` を置き、`wezterm.lua` の `update-status` が拾って印を付ける（zellij の中の pwsh7 と、claude の入力待ちで 🔔 を確認。`settings.json` に Notification と Stop を足した。バックアップ `settings.json.bak-bellmark`）。nvim の `checktime`（2 秒タイマー）、`Ctrl+Tab`、タブ名・重複防止、`Alt+f`、`Alt+x`、`Alt+c` も確認済み。zellij の win は `SHELL` を見ず、`attach --create <名> options --default-shell pwsh` で渡す（新しいセッションだけに効く。既存は `delete-session` で作り直し）。
   【残り】① `Ctrl+Shift+N`（素の pwsh7 タブ）は 11-19 に実機で確認済み（pwsh が出た）。② 【11-19 決定】`Alt+n` の pwsh の warning「ListView は WindowWidth 50 未満・WindowHeight 5 未満で一時無効」は、pane の初期サイズが小さい起動時の 1 回だけ。ee の決定で何もしない（`profile.ps1` は変えない）。サイズが決まった後に ListView が出るかは、使うときに見る。③ ⑥ pwsh7・lazygit（10 章の 5〜6）、手順書の書き直し。④ 9 章の 2（閉じる操作を続けたときの形の崩れ）、WezTerm 起動直後の zellij、claude の信頼確認の省略と `Ctrl+Enter`（ee が試用中）。⑤ 【11-19 決定】二段階。先に `bell-mark.ps1` を `windows/wezterm/` へ置く（済み。実体は `~/.claude/hooks/` のまま）。次に settings の Notification/Stop だけ kit の手順にするか決める（未。規模の凍結で 1 つ畳む必要あり）。ショートカットの見直しは別の機会（ee）。
   【引き継ぎ 11-19】コミット 404ca85 まで済み。`lazy-lock.json` `lazyvim.json` は追跡する（ee の決定 11-19。コミット済み）。`scratch.txt` は 5 の確認用で未追跡のまま。workbase `d043b784` は未 push（人が push）。win の zellij の既存セッションは cmd のままなので、`zellij.exe delete-session --force <名>` で作り直す（ee の判断）。
   次の一手: ⑥ pwsh7・lazygit（10 章の 5〜6）→ 手順書の書き直し。

## Open Questions

