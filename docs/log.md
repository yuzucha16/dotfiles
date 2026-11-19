# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 9

8. 【起票 11-19】【やる:ユーザー】単位設計 `docs/setup/terminal-units.md` に沿って、既存の試作（`windows/wezterm/`、`home/.config/nvim/`、`docs/setup/wezterm-claude-nvim.md`）を消し、zellij・WezTerm・LazyVim を作って実機で確かめる。完了: 設計書 9 章の 9 点（性能の測定 V1〜V6 は 11 章。版の揃えは 12 章。実装は workbase の NA 59。残る未確認は lazygit の SHA-256 と Volta の検証方法）の結果がユーザーから報告され、設計書が結果に合わせて直る。
   【決定済み 11-19】pane の配置は案 B（案 A のレイアウトは残す）。zellij の設定は room へ手で置く（`room init` では未配布）。
   【残りの確認】`Alt+x` は保留。閉じる操作を続けたときの形の崩れ（9 章の 2）。WezTerm 起動直後の zellij（`wezterm.lua` を直した。未確認）。claude の信頼確認の省略と `Ctrl+Enter` 送信（ee が試用中）。
   【11-19 試作を削除】ee が承認。退避コミット 7ec6059 の後、削除を 1 コミットにした（戻すときはその `git revert`）。nvim のリンク先は `%USERPROFILE%\.config\nvim` に決定（`XDG_CONFIG_HOME` は `10_env.bat` で設定済み）。`room-nvim-config.ps1` は残した（nvim の作り直しまで使えない）。
   次の一手: 本番で WezTerm（bell の印を含む）と LazyVim を作り、リンクを `links.map` に足す。

## Open Questions

