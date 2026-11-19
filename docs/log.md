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
   【11-19 実機で確認済み】本番の `wezterm.lua` と LazyVim、bell（win は BEL を ConPTY が止めるので旗ファイル `bell-mark.ps1` 方式。workbase `d043b784` は未 push）、nvim の checktime、`Ctrl+Shift+N`、lazygit（pwsh7 の zellij 内）ほか。詳細は `log-history.md` の 2026-11-19 と設計書 9 章。zellij の win は `attach --create <名> options --default-shell pwsh` で pwsh を渡す（新しいセッションだけに効く）。
   【残り】① 手順書の書き直し。② 9 章の 2（閉じる操作を続けたときの形の崩れ）、WezTerm 起動直後の zellij、claude の信頼確認の省略と `Ctrl+Enter`（ee が試用中）。③ 【11-19 決定】bell は二段階。`bell-mark.ps1` は `windows/wezterm/` へ置いた（済み。実体は `~/.claude/hooks/`）。settings の Notification/Stop を kit の手順にするかは未決（規模の凍結で 1 つ畳む必要あり）。④ lazygit の SHA-256 は設計書 12 章に記入済み（人が 1 回確認）。Volta の検証方法は未。ショートカットの見直しは別の機会（ee）。`Alt+n` の ListView の warning は起動時だけで、何もしない（ee の決定）。
   【引き継ぎ 11-19】コミット 404ca85 まで済み。`lazy-lock.json` `lazyvim.json` は追跡する（ee の決定 11-19。コミット済み）。`scratch.txt` は 5 の確認用で未追跡のまま。workbase `d043b784` は未 push（人が push）。win の zellij の既存セッションは cmd のままなので、`zellij.exe delete-session --force <名>` で作り直す（ee の判断）。
   【11-19】pwsh7・lazygit は合格（9 章の 7）。`apps.txt` に lazygit を足した。
   【11-19】手順書 `docs/setup/wezterm-zellij-nvim.md` を新しく書いた（旧 `wezterm-claude-nvim.md` の後継。コミット済み）。未確認: 部屋の nvim 設定の反映（`room-nvim-config.ps1` は作り直し後に未実行。ee が実行する）、通常の WSL（提案: 対象外）。
   【11-19 決定】② は別の機会にまとめてやる。③ の bell フックの settings は、手順書の章 3 の手動手順を正にする（kit の手順書化と畳みは後でまとめて）。`windows/README.md` の古い注は直した。
   【11-19 決定】`room-nvim-config.ps1` は ee が実行し、正常終了（未確認だった反映は済み）。Volta は使わない（Node の取得物を検証しないため。必要になったら ee が使う）。room の Node は今の tarball + SHA-256 のまま、Windows は scoop の Node に寄せる。設計書 12.3 に反映済み。Python の取得物は uv が検証する（設計書 12.3 の注）。
   【11-19 決定】Node は 24 系のまま（26 系は別の機会）。Windows は scoop の `nodejs24`（versions。24.22.3）。room の表の版も 24.22.3 に合わせる（SHA-256 は `SHASUMS256.txt` で取り直す。実装は workbase の NA 59。dotfiles からは `resources/` を編集しない）。`volta` `nodejs` `nodejs-lts` の `scoop uninstall` と `nodejs24` の導入は ee が行う（今の実機は 26.13.1）。`apps.txt` には node の行が無いので、足すかは未決。
   次の一手: workbase の NA 59 に「node 24.22.3」を引き継ぐ。ee が scoop を入れ替える。②（別の機会）。

## Open Questions

