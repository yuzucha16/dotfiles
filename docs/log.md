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
   【11-19 実機で確認済み】本番の `wezterm.lua` と LazyVim（5bfe4de）。9 章の 4（🔔）は room で成功。直した点: bell だけではタブバーが再描画されず、`update-status`（500ms）と右ステータスで再描画する（未コミットだった修正を本コミットに含めた）。room の claude のフックは `/dev/tty` を開けず（制御端末なし、rc=2）、`~/.claude/hooks/bell.sh`（親をたどって `/dev/pts/N` へ BEL）に置き換えた（元は `settings.json.bak-bell`）。
   【残り】① workbase の `room init` 段 `bellhook` が同じ `printf '\a' > /dev/tty` を入れているなら `bell.sh` 方式に直す（やり直すと戻る）。② win（pwsh7）と wsl の bell は未確認（Windows の claude にフックなし。`terminal_bell` で足りるか）。③ 素のタブ（`Ctrl+Shift+N`）が bash（既定の WSL）になる。PowerShell の素のタブが要るなら別キー。④ `Alt+f` の floating が出ない（`Alt+n` は効く）。9 章の 3 と合わせて確認。⑤ nvim の `checktime`（9 章の 5）、`Ctrl+Shift+T` のタブ名（空だった。再確認）と重複防止の確認。⑥ pwsh7・lazygit（10 章の 5〜6）、手順書の書き直し。
   次の一手: ①（workbase の bellhook を bell.sh 方式に直す）と、⑤の確認結果の報告を受けて設計書 9 章を直す。

## Open Questions

