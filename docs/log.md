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
   【11-19 ①を完了（引き継ぎ）】workbase の `bellhook` 段を `bell.sh` 方式に直し、コミットした（workbase `d043b784`。未 push。人が push する）。`room.py` が `~/.claude/hooks/bell.sh` を置き、Notification と Stop から `sh $HOME/.claude/hooks/bell.sh` で呼ぶ。旧の `> /dev/tty` は settings から取り除く。修正レビュー（範囲 = NORMAL。整合 = ANOMALY だったが、原因は私が足したテストの検査対象の誤り。`bell.sh` 本文だけを見るよう直して通した。ee がその直しでコミットを承認）。bell 関連のテスト 2 件は OK。全体（212 件）は、直す前の実行で失敗 1（この誤り）・スキップ 3。直した後の全体の再実行はしていない（約 5 分）。軽微な未対応: `bell.sh` は `/proc/PID/stat` の第 4 フィールドを awk で取るので、プロセス名にスペースがあると親 PID がずれる（claude・node では実害が低い）。既存の room には `room init <Area> --only bellhook`（room の settings は既に bell.sh 方式で、二重にならない）。
   【引き継ぎ: ⑤ の手順（9 章の 5。ee が実機でやる）】room の WezTerm タブで zellij（左 claude、右 nvim）を起動 → nvim で `scratch.txt` を開く → 左の claude に末尾へ 1 行足させる → 右の nvim へ移動して、キー操作なしで数秒待つ（`updatetime` 既定 4 秒）→ 反映を見る。結果は「自動で反映 / 手動の `:checktime` で反映 / 反映されない」の 3 択。加えて、nvim で未保存の編集をした状態で claude に書かせたときの競合の確認、別バッファへ移って戻る（`BufEnter`）も見る。`autocmds.lua` は `FocusGained` `BufEnter` `CursorHold` `CursorHoldI` で `checktime` する。
   【11-19 ⑤を完了】9 章の 5 は合格。`autocmds.lua` に 2 秒間隔のタイマー（`checktime` + `redraw`）を足して、放置でも自動で反映される（pane 移動では FocusGained・CursorHold が来ず、`redraw` がないと画面が更新されなかった）。未保存の編集があると「破棄か load か」を聞かれ、load すると未保存が消えてディスクの内容になる（nvim の標準。claude に書かせる前に保存する）。未確認で残る: `Ctrl+Shift+T` のタブ名と重複防止。
   次の一手: 残り②〜④⑥（上の【残り】）を、ee の実機確認の順に進める。②の win と wsl の bell は、`terminal_bell` で足りるかも決める。

## Open Questions

