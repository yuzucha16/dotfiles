# 作業ログの経緯（log-history）

日付つきの Log（降順）。開始時には読まない。必要なときに検索する。現在状態は `docs/log.md`。

## Log

### 2026-11-20（NA 13 一部完了: (b) `-C` 前提の共有ノートを直した）
- ee が、`exmem/` の特定ファイルの書き換えを例外として許可し、修正レビューを依頼。変更は resources `37810576`（7 ファイル: `claude-code-permissions` `shell-command-usecases`（注記 1 行のみ。種の本文は未変更）`workflow-kit` `alignment-baseline` `ai-room-setup-manual` `ai-room-setup` `ai-room-setup-script`）。
- 修正レビュー（別エージェント 2 件）: 整合は NORMAL（`settings.json` の allow に `git -C` 無し・deny に残る・`-C` なし allow は PS 11 と Bash 11 を確認）。範囲は ANOMALY（`exmem/` の外の 2 ファイルと、名指し外の `workflow-kit.md`）。ee が「A: 5 ファイルを追認」と判断し、同種の 2 箇所（`ai-room-setup.md` `ai-room-setup-script.md`）も揃えた。
- 残した: room の clone の `git -C ~/src/<repo>`（`room.py` `project-structure.md` ほか。room の設定は未検証）。残り (a) は NA 13 に。

### 2026-11-20（NA 14 完了: Claude Code の見た目を淡い青にした）
- ee の報告: gruvbox に soft blue のハイライトを足してコミット済み。`home/.claude/themes/gruvbox-soft-blue.json`（`userMessageBackground` `#2a3b52`、diff は `#2c4a5e`/`#2b2e4a` と単語単位 `#3f6c8c`/`#44487a`）、`home/.claude/settings.json` の `"theme": "custom:gruvbox-soft-blue"` と `"viewMode": "focus"`。コミットは `8295e8d`（Claudian 削除と同じコミットに入った）。`~/.claude/themes` は dotfiles の `home/.claude/themes` への junction（確認: `Get-Item`）。
- 採否: `/focus` 相当は `viewMode: focus` で固定（採用）。実機の見え方の最終確認は ee が実施済みとして閉じた。

### 2026-11-20（Claudian と obsidian-skills を削除）
- ee の依頼（Obsidian で AI を使わないので、依存するプラグインとスキルを削除）。dotfiles `8295e8d`: `realclaudian` と `claudian-settings.json`、`links.map` の 3 行、CSS の `.claudian-*`、`29_claude_plugins.bat` `manifests/claude-plugins.txt` `test_28_29_installers.ps1`（0 件になったため）、`extraKnownMarketplaces` の obsidian-skills、README 各種の言及。実機は `claude plugin marketplace remove obsidian-skills` と、`works\.claudian` `works\resources\.claudian`（会話履歴を含む。ee の承認）の削除。works `4dbd8ea`（`AGENTS.md` のスキル段落、README の `.claudian/` 行、`.gitignore`）、resources `6157678b`（`.gitignore`）と `3164da56`（Volta の shim の例から `defuddle`）。
- 修正レビュー（別エージェント）: 範囲・取りこぼし・参照切れに問題なし。`home/.claude/settings.json` の `"model"` は行の移動で、ファイル全体を含めた。`decisions.md` に廃止の注記を足した（`3cb864a`）。
- 残した: `decisions.md` と本ファイルの履歴、`resources/exmem/lessons/claude-code-external-plugins.md`、`token-cap` の記録、`.obsidian/workspace.json`（端末ごと）。未確認: pwsh の試験、家・会社の PC の symlink（`git pull` と `30_link.bat` の再実行）。未 push。

### 2026-11-20（wezterm の既定シェルとスクロールバー。nvim のファイラは omit）
- ee の依頼で `wezterm.lua` に `default_prog = { 'pwsh' }`（起動直後を pwsh7 に。cmd は使わない）と、スクロールバー（`enable_scroll_bar`、右 padding 12px、つまみ `#8f8f8f`）を足した。ee は色が見えづらく、値の調整は数値で言えない。「これで一旦進める」。実機での見え方は未確認。
- nvim のファイラ（neo-tree を右・常時・幅 20）は実装後に ee が omit と決め、revert した（コミットなし）。
- zellij に、常時スクロールモードと、スクロールバー表示の設定はない（案内のみ。変更なし）。スクロールモードは Ctrl+s で入る既定。
- `lazy-lock.json` の未コミット差分は、先の決定のとおりコミットしない。

### 2026-11-20（NA 12 完了: zellij の設計書 2 文書を実態と照合）
- 424d450 の 2 文書を、実物と照らした。`wezterm.lua` 75〜89 行（pwsh の `cd`、背景作成→attach、room は 1 段）、`config.kdl`（`pane_frames true`、`titles`、Alt+n の bind なし）、`layouts/*.kdl`（`--resume` なし）と一致した。
- 修正レビュー（範囲、整合の 2 件）: 範囲は ANOMALY（`wezterm.lua` の `default_prog`・スクロールバーと lazy-lock を、NA 12 に含める案）、整合は NORMAL。ee の判断で、`wezterm.lua` と `lazy-lock.json` の未コミット差分は NA 12 に含めず、コミットしない（残す）。

### 2026-11-19（NA 12 一部完了: zellij の未コミット 4 ファイルをコミット。2 段起動は要る）
- ee の判断: 2 段起動は残す。`pane_frames true`（titles）と `--resume` 削除もそのままコミット。`-NoProfile` は実施しない。
- コミット: 2d29849（`wezterm.lua` の 2 段起動と `config.kdl`）、22b3a82（`claude-a/b.kdl` の `--resume` 削除）。
- 訂正: NA 10 の「原因は画面サイズ」は取り違え。根拠は ee の実機（タブを開き直すとピンク＝3 列、従来の 1 段起動は緑＝2 列）。詳細と起動の費用（約 1 秒）は `decisions.md` の同日の項。
- 残り: `terminal-units.md` と `wezterm-zellij-nvim.md` を実態に更新する（NA 12 に残した）。

### 2026-11-19（NA 11 完了: statusline の認証種別が `/status` と一致。ロゴは omit）
- ee の実機確認: 新規セッションで statusline の種別が `/status` と一致した（ee の報告）。ロゴは消せないので諦める（ee の決定。omit。zellij の `/clear` 注入は遅くなるため）。
- 閉じた NA 11 の全文: claude の statusline の認証種別（OAuth/API/Bedrock/Gateway。env と `rate_limits` からの推定。コミット済み fbda3be）を、実機で `/status` と見比べる。警告の件と cwd の件（採用しない）は済み。

### 2026-11-19（NA 11 一部完了: statusline の認証種別と、`git -C` の許可の整理）
- `statusline.py` に認証種別（env と `rate_limits` からの推定）を追加。`CLAUDE_CODE_HIDE_CWD` は採用しない（ユーザーの決定。`settings.json` の `env` を戻した）。
- `/status` に出る permission の警告（`git -C * ...` の `*` が `-c` などを通す）を、三層レビュー（整合・実用性・反証）を経て解消。`settings.json` の allow から `git -C * ...` 22 行を消し、`-C` なしの allow を 14 行足した（deny は残す）。ユーザーが承認し、実機で警告の消失を確認（根拠: ユーザーの報告）。経緯・却下案は `decisions.md` の 586 行目の追記。
- 起票: NA 13（`diff`/`log` の `--output`、`commit` の hook、`-C` 前提の共有ノート）。

### 2026-11-19（NA 10 完了: 原因の切り分け。画面サイズ）
- 完了の判断は ee が「原因の切り分けまで」と決定（layout b が既定、a/b は切替可。修正はしない）。結果: swap layout の定義は正しい。2 段起動のセッション（`dotfiles`）で 1 回目の Alt+c 後は 50/50 縦積み（dump-layout）、`next-swap-layout` で 3 列 33% になった。背景作成だけの試験セッションは `zellij run` で 3 列。ee の実機で、ウィンドウを大きくすると中央 3 列になった＝原因は画面サイズ（ee 確認。swap の幅の条件に足りないと自動で選ばれない、が仮説。zellij の内部は未確認）。
- 残りは NA 12（未コミットの 4 ファイルの扱い）に移した。回避案（Alt+c の後に `NextSwapLayout`）は未試験のまま。

### 2026-11-19（NA 10 の調査経過の全文。log.md を縮めるため退避）
10. 【起票 11-19】【やる:AI】 zellij の claude pane の配置を直す（ee が承認済み。調査と編集は済み、コミットは未）。不具合: layout-b は nvim 右端固定で claude が 中央→左下 と増える仕様だが、Alt+c の 1 回目だけ nvim の右に出る（2 回目以降は nvim の左）。
   - 実機の事実（11-19、セッションは毎回 delete-session --force で作り直した）: `--resume` の削除、`pane_frames false`、Alt+c の `cwd`、バー節（`default_tab_template`）の削除、Alt+n の削除、のどれでも直らない。`zellij action new-pane` の背景セッション試験は 1 回目から正しく並ぶ（再現せず。キー経路 `Run` か画面サイズの差か）。1 回目の後に Alt+] で `claude3` と出るが画面は変わらない。
   - 未コミットの変更（dotfiles。他にも別作業の変更があるのでパス指定でコミット）: `config.kdl`（pane_frames は今 false の試験値、`pane_frame_style "titles"`、Alt c に試験用 cwd 固定）、`claude-a/b.kdl`（`--resume` 削除=ee 承認済み。claude-b はバー節を試験で外した）、`wezterm.lua`（win に `--default-cwd`=ee 実機で OK）。**試験用の変更は戻す**: pane_frames は true（titles は ee が見分けられると確認）、Alt c の cwd と claude-b のバー節は元へ。
   - 11-19 追記（AI）: 試験用の変更は戻した（pane_frames true、Alt c の cwd 削除、claude-b のバー節を復元）。背景セッション（`attach --create-background` ＋ `zellij run`）では、バー節あり・なしの両方で `claude2` が正しく効く（claude・新 pane・nvim の 3 分割）。layout の記述は原因ではない。残る差は実機の `Alt+c` 経路（`Run`）か画面サイズ。次は ee の実機で、戻した設定の新規セッションを確かめる。
   - 11-19 追記 2（AI）: 実機で、Alt c を `pwsh -c claude` 経由にしても、swap layout の nvim をフルパスにしても直らない（試験は戻した）。dump-layout では、1 回目は 3 pane が横に等分（claude・nvim・新）、2 回目は左だけ縦に 2 つで nvim が中央のまま＝swap layout は当たるが、`command=` での nvim の照合が効かず、作成順に並ぶ。背景セッションでは照合が効く（クライアントの有無か Windows の挙動か不明）。回避案: nvim を最初の pane（左）にして、swap layout を `command` 抜きの順序だけにする。
   - 次の一手（案）: swap layout `claude2`（`exact_panes=3`）が 3 pane のとき効かない原因を探る。`min_panes`/`max_panes` へ替える、`claude3` のような入れ子の形へ揃える、`zellij --layout` で単体確認、など。直ったら `terminal-units.md` と `wezterm-zellij-nvim.md`（pane_frames・cwd・Alt+n なし・`--resume` なし）を更新。

### 2026-11-19（NA 9 完了: claude の使い勝手。Enter 改行、statusLine、テーマ）
- 原因: WezTerm は kitty プロトコルを使わず、Ctrl+Enter は LF（Ctrl+J）で届く。Claude Code の Ctrl+J は既定で改行なので、`ctrl+enter`=送信が効かず「Ctrl+Enter で改行」に見えた。`keybindings.json` に `ctrl+j`=`chat:submit` を足して解決（ee が Windows の pwsh で実機確認。Enter=改行、Ctrl+Enter=送信）。
- statusLine: `home/.claude/statusline.py`（`モデル | ctx 使用率% | 直近 1 回のトークン数 / ウィンドウサイズ`。ee の指定。トークン数は `used_percentage` と同じ input 系 3 種の合計）。`settings.json` の `statusLine.command` は `python -I ~/.claude/statusline.py`。
- テーマ: `home/.claude/themes/` に `gruvbox`（medium）・`gruvbox-hard`・`gruvbox-ansi`（端末のパレットに従う）。`/theme` で `custom:<名前>` に切り替える（ee の希望: 何度か試すので切り替え式）。`links.map` はディレクトリごとのリンク。ee が確認済み。
- ee の決定: 入力欄を広げる件（`/tui fullscreen`）は、すでに有効と出たので諦める。
- 閉じた NA 9 の全文: WezTerm+zellij+nvim 上の claude の使い勝手を整える（ee の承認済み。cwd は zellij の問題として対象外）。keybindings（33e8492）、statusLine、テーマ、入力欄の 4 項目。
- zellij の `config.kdl`・layouts と `wezterm.lua` の未コミットの変更は、別の作業のもので、このコミットに含めない。

### 2026-11-19（WezTerm: `+` ボタンで環境を選んでタブを開く）
- ee の依頼: Windows Terminal に合わせてタブ送りと GUI のタブ作成。調査の結果、`Ctrl+PageUp/PageDown` は WezTerm の既定で効く（実機で確認。変更なし）。
- `wezterm.lua` に `new-tab-button-click`（左・中クリックで `pick_target`）と、`TARGETS` の `plain` 種別（pwsh・cmd・room のシェル。zellij なし、毎回新しいタブ）を足した（095c50c）。手順書 `wezterm-zellij-nvim.md` の「日常の操作」も更新。実機で各シェルが起動（ee）。
- 別セッションの NA 9（claude の使い勝手）は触っていない。`docs/log.md` の NA 9 は別セッションの変更で、このコミットに含めない。

### 2026-11-19（NA 8 完了: bell フックを kit の手順書に、9 章の 2 は omit、通常の WSL は対象外）
- ee の決定: 9 章の 2（閉じる操作を続けたときの形の崩れ）は omit（workbase の NA 59 が close 済みのため）。通常の WSL は対象外。bell フックの settings は kit の手順書にした（workbase 6318c9db `workflow-kit/bell-hook-win.md`。dotfiles 24af0fa で章 3 を要約にした）。kit の畳みは後日（ee）。
- node 24.22.3 への room の表の更新は workbase の NA 60 に起票した（dotfiles からは `resources/` を編集しない）。設計書 9 章の 2 と 8 章に反映した。
- 閉じた NA 8 の全文（以下）:
```text
8. 【起票 11-19】【やる:ユーザー】単位設計 `docs/setup/terminal-units.md` に沿って、既存の試作を消し、zellij・WezTerm・LazyVim を作って実機で確かめる。完了: 設計書 9 章の 9 点（性能の測定は 11 章。版の揃えは 12 章。実装は workbase の NA 59。lazygit の SHA-256 は記入済み。Volta は 11-19 に不採用）の結果が報告され、設計書が結果に合わせて直る。
   【決定済み 11-19】pane の配置は案 B。zellij の設定は room へ手で置く（`room init` では未配布）。試作は削除済み（退避 7ec6059、戻すときは revert）。nvim のリンク先は `%USERPROFILE%\.config\nvim`。
   【11-19 実機で確認済み】本番の `wezterm.lua` と LazyVim、bell（win は BEL を ConPTY が止めるので旗ファイル `bell-mark.ps1` 方式。workbase `d043b784` は未 push）、nvim の checktime、`Ctrl+Shift+N`、lazygit（pwsh7 の zellij 内）ほか。詳細は `log-history.md` の 2026-11-19 と設計書 9 章。zellij の win は `attach --create <名> options --default-shell pwsh` で pwsh を渡す（新しいセッションだけに効く）。
   【残り（11-19 の終わりの時点では ② のみ。①③④ は済み。下の引き継ぎを参照）】① 手順書の書き直し（済み）。② 9 章の 2（閉じる操作を続けたときの形の崩れ）、WezTerm 起動直後の zellij、claude の信頼確認の省略と `Ctrl+Enter`（ee が試用中）。③ 【11-19 決定】bell は二段階。`bell-mark.ps1` は `windows/wezterm/` へ置いた（済み。実体は `~/.claude/hooks/`）。settings の Notification/Stop を kit の手順にするかは未決（規模の凍結で 1 つ畳む必要あり）。④ lazygit の SHA-256 は設計書 12 章に記入済み（人が 1 回確認）。Volta の検証方法は未。ショートカットの見直しは別の機会（ee）。`Alt+n` の ListView の warning は起動時だけで、何もしない（ee の決定）。
   【引き継ぎ 11-19】コミット 404ca85 まで済み。`lazy-lock.json` `lazyvim.json` は追跡する（ee の決定 11-19。コミット済み）。`scratch.txt` は 5 の確認用で未追跡のまま。workbase `d043b784` は未 push（人が push）。win の zellij の既存セッションは cmd のままなので、`zellij.exe delete-session --force <名>` で作り直す（ee の判断）。
   【11-19】pwsh7・lazygit は合格（9 章の 7）。`apps.txt` に lazygit を足した。
   【11-19】手順書 `docs/setup/wezterm-zellij-nvim.md` を新しく書いた（旧 `wezterm-claude-nvim.md` の後継。コミット済み）。未確認: 部屋の nvim 設定の反映（`room-nvim-config.ps1` は作り直し後に未実行。ee が実行する）、通常の WSL（提案: 対象外）。
   【11-19 決定】② は別の機会にまとめてやる。③ の bell フックの settings は、手順書の章 3 の手動手順を正にする（kit の手順書化と畳みは後でまとめて）。`windows/README.md` の古い注は直した。
   【11-19 決定】`room-nvim-config.ps1` は ee が実行し、正常終了（未確認だった反映は済み）。Volta は使わない（Node の取得物を検証しないため。必要になったら ee が使う）。room の Node は今の tarball + SHA-256 のまま、Windows は scoop の Node に寄せる。設計書 12.3 に反映済み。Python の取得物は uv が検証する（設計書 12.3 の注）。
   【11-19 決定】Node は 24 系のまま（26 系は別の機会）。Windows は scoop の `nodejs24`（versions。24.22.3）。room の表の版も 24.22.3 に合わせる（SHA-256 は `SHASUMS256.txt` で取り直す。実装は workbase の NA 59。dotfiles からは `resources/` を編集しない）。`volta` `nodejs` `nodejs-lts` の `scoop uninstall` と `nodejs24` の導入は ee が行う（今の実機は 26.13.1）。`apps.txt` に `nodejs24` を足した（11-19 ee の決定。コミット済み）。
   【引き継ぎ 11-19（最後のコミット 2270200。dotfiles の 5dde7a6 以降は未 push。push は人）】
   - 済み: 手順書 `wezterm-zellij-nvim.md`（章 3 の bell フックは手動の手順を正に）、`windows/README.md` の注、`room-nvim-config.ps1` の実行（ee が正常終了を確認）、Volta の検証（不採用）、Python の検証（uv が展開時に SHA-256 を検証。設計書 12.3 の注）、Node の決定（上）。
   - ee の作業（済み）: scoop の入れ替え（node 24.22.3）、workbase `d043b784` の push。残り: ② 9 章の 2・WezTerm 起動直後の zellij・claude の信頼確認の省略と `Ctrl+Enter`（別の機会にまとめる）。
   - workbase 側（別セッション。NA 59）: `tool-versions.txt` の node を 24.21.0 → 24.22.3 にし、SHA-256 を `nodejs.org/dist/v24.22.3/SHASUMS256.txt`（linux-x64.tar.xz）で取り直す。windows 列の node（`volta:node`）は scoop の `nodejs24` に直す。`decisions.md` の「Volta の node の版と揃える」（9 行目）は根拠が消えたので見直す。
   - 【11-19 ee の決定】`27_volta.bat` `28_npm_globals.bat` `manifests/npm.txt` を削除（試験・README も直した）。24 系の保守終了の確認は不要。`27_volta.bat` の入力は「SSL バンドルを設定するか y/N」の 1 問で、y なら `NODE_EXTRA_CA_CERTS` を `setx` していた。【ee の決定】`10_env.bat` が、実行時に `ca_bundle.crt` があるときだけ `NODE_EXTRA_CA_CERTS` を `setx` する（置く前に実行したら、置いた後にもう一度）。空は警告なし、存在しないファイルは起動のたびに警告（Node 24.22.3 で確認）。obsidian-skills は不要なので、defuddle / knap の導入経路（旧 28）は作り直さない。
   - 未決: bell フックの kit の手順書化と畳み（規模の凍結。まとめて後で）。通常の WSL への対応（提案: 対象外）。
   - `scratch.txt` は未追跡のまま（コミットしない）。
   次の一手: 設計書 9 章の残り（②）が埋まれば NA 8 を完了にする（別の機会。ee）。社内プロキシの PC では `ca_bundle.crt` を置いた後に `10_env.bat` を再実行する。workbase の NA 59 に node 24.22.3 を引き継ぐ（別セッション）。dotfiles の push は人。
```


### 2026-11-19（NA 8: pwsh7・lazygit、bell-mark の置き場、log.md を縮めた）
- `Ctrl+Shift+N`（素の pwsh7 タブ）を ee が実機で確認（pwsh が出た）。`lazy-lock.json` と `lazyvim.json` を追跡（a414f5f）。`bell-mark.ps1` を `windows/wezterm/` へ（6d1be4b。二段階の 1 段目）。lazygit 0.66.3 を `apps.txt` へ（688deb7）。pwsh7 の zellij 内で lazygit が起動（9 章の 7 合格）。設計書 12 章に lazygit の SHA-256 を記入（`checksums.txt` と API の digest で一致）。
- `log.md` から移した NA 8 の詳細（縮める前の原文の要点）: 本番の `wezterm.lua` と LazyVim は 5bfe4de。bell は room と wsl が BEL で 🔔（room は `~/.claude/hooks/bell.sh`。workbase `d043b784` で `room init` の `bellhook` 段も修正。未 push）。win は ConPTY が BEL を止めるので、claude のフック `~/.claude/hooks/bell-mark.ps1` が `%TEMP%\wezterm-bell\<WEZTERM_PANE>` を置き、`wezterm.lua` の `update-status` が拾って印を付ける（`settings.json` に Notification と Stop を足した。バックアップ `settings.json.bak-bellmark`）。nvim の `checktime`（2 秒タイマー）、`Ctrl+Tab`、タブ名・重複防止、`Alt+f`、`Alt+x`、`Alt+c` を確認。zellij の win は `SHELL` を見ず `attach --create <名> options --default-shell pwsh` で渡す（既存セッションは `delete-session --force` で作り直し。ee が検討中）。`Alt+n` の pwsh の warning「ListView は WindowWidth 50 未満・WindowHeight 5 未満で一時無効」は pane の初期サイズが小さい起動時の 1 回だけで、何もしない（ee の決定）。

### 2026-11-19（wrap: NA 8 の zellij の実機確認、案 B に決定）
- 一部完了（NA 8）: ee が room で zellij を実機確認した。`home/.config/zellij/{config.kdl,layouts/claude-a.kdl,claude-b.kdl}` をコミット。起動で左 claude・右 nvim、`Alt+c` で案 B の順に増える、`Alt+f`、`Alt+矢印`、`Ctrl+g` が動いた。lazygit は room に未導入で、`Alt+g` は pane が即閉じる（想定どおり）。
  - モード表示バー: 初めは出なかった（`--layout compact` では出て、自作では出ない）。`default_tab_template` はトップ階層の `pane` に付かないため、起動時の pane を `tab { }` で包んで直った（`location` は `zellij:compact-bar` にも変更）。
  - 案 B に決定（ユーザー。案 A のレイアウトは残す）。
  - `windows/wezterm/wezterm.lua`: room のタブは zellij を直接起動（`bash -lc 'exec zellij'`）に変更。未確認。
  - room の claude の設定の手順を渡した（信頼確認の省略、Enter 改行 / `Ctrl+Enter` 送信。ee が試用中）。
  - `Alt+x`（pane を閉じる）は ee が保留。今の閉じ方は claude の `/exit`、または `Ctrl+g` → `Ctrl+p` → `x`。
  - 同じコミットに、先に書いた `decisions.md`（Node は Volta、版はすべて固定）と `terminal-units.md` の変更を含む。

### 2026-11-19（digest）
- 完了（NA5）: ユーザーが close を指示（2026-11-19）。動作確認は済みとし、次の段階として NA 8（単位設計に沿った作り直しと実機確認）に進む。NA 8 が引き継ぐ。
  - 元の項目: 【起票 11-15】【やる:ユーザー】WezTerm + claude + nvim の動作確認: (a) `WEZTERM_CONFIG_FILE` を使わず、通常の起動（`links.map` のリンク）で左 claude・右 nvim が組まれる、(b) claude 自身の入力待ち・停止で、別タブにいるときタブに 🔔 が付く（11-15 は手で鳴らした bell だけ確認）、(c) タブ名が `wslhost.exe` のまま（直したいか）、(d) 動作確認で気づいた直しを伝える（直しは AI が行う）。完了: (a)〜(c) の結果がユーザーから報告される。
- omit（NA7）: ユーザーが close を指示（2026-11-19。「止まりました」）。30_link.bat の Developer Mode の確認は実装していない（git log に該当のコミットなし）。作業は止まったものとして閉じた（decisions.md の 2026-11-19 の項の追記）。リンクの失敗への備えが再び要るときは、新しい項目で起票する。
  - 元の項目: 【起票 11-15】【やる:AI】`scripts/windows/30_link.bat` を、Developer Mode がオフのときは何も変えずに止める（先に確認する）。完了: オフの状態で `link` を実行すると、既存のリンクを消さずに `[ERR]` で止まり、`tests/windows/` に再現の試験がある。理由: 11-15 に、既存のファイルリンクが消えて Windows Terminal の設定が初期化された（`decisions.md` の同日の項）。

### 2026-11-19（NA 3 を閉じる: WezTerm + zellij + claude + nvim の単位設計）
- 依頼（workbase の project thread）: zed は制約が多く、token-cap などで素の claude を使いたい。WezTerm の 1 タブ 1 cwd、複数の claude セッション、ファイル編集は nvim。単位（WezTerm の tab・pane、claude の session、nvim の buffer）の割り当てをレイヤ設計から行い、設計書を main に push するところまで。実作業は PC で行う。
- 実施: `docs/setup/terminal-units.md` を追加（main に push。e8d2577）。tab = (環境, cwd) = zellij session、pane は zellij だけが持つ、nvim はセッションに 1 つ、floating は zellij（lazygit・ターミナル）、環境は pwsh7（scoop）・wsl・room、修飾キーで層を分ける（WezTerm = Ctrl+Shift、zellij = Alt、nvim = Space・Ctrl）、bell は claude → zellij → WezTerm のタブの印。既存の試作は前提にせず、PC で消して一から作る。
- 確認: zellij 0.46.0 を、疑似端末（200×50）で動かし、`sleep` を claude・nvim の代わりにして swap layout の挙動を実測した。案 A（左右 2 分割）は 3 つ目で 2・3 つ目の位置が入れ替わり、nvim が右下へ動く。案 B（中央 3 分割。nvim は右一列で固定、claude は Z の順）は入れ替わらず、仕様どおりに増える。WezTerm の安定版（20240203）と nightly の変更履歴に floating pane は無い。zellij 0.44 以降は別タブの BEL も外側へ渡す。
- 追記（同日の後半）: ① 設計書 11 章に、WezTerm を使うと増える性能のボトルネック（`/mnt/c` 越しの I/O、監視ソフトのファイル単位の検査、`wsl.exe` と ConPTY、zellij、WezTerm の描画。疑う点 6 つ、検証 V1〜V6、対策の順）を追記した。リモートサーバー案より WSL ドメインの直接起動を推奨。cwd の置き場（Windows か WSL か）は設計に入れない。② 設計書 12 章に、ツールの版の揃えを追記した。uv・Python と同じ型（固定した表 + SHA-256）で、room に入れる全ツールを workbase の `workflow-kit/room/tool-versions.txt` で管理する。初期値は今の scoop の版（ee が `scoop list` を渡す）。通常の wsl は対象外。途中で出した「scoop の版を動的に読む」案は、ユーザーが固定の表を選んで取り下げた。コミット: 677dc78（11 章）、175cfa2・7635124・d1696d6（12 章）。③ 設計書の本文の、環境を特定する語を性質の語に直した（その語を避ける方針）。
- 未実施: 実機（PC）での確認すべて。設計書 9 章の 9 点（案 A/B の選択、実物の claude・nvim、`Alt` の locked での動作、3 環境の bell、`checktime`、セッションの復帰、pwsh7 の道具、性能 V1〜V6、版の揃え V7）。room への lazygit の段と、版の表（`tool-versions.txt`）の実装は workbase の `room.py` の変更なので別作業（未着手。workbase の NA 59。ee の `scoop list` と 2 つの可否の回答待ち）。→ NA 8
- 判断: ユーザーが使い続けること、zellij を足すこと、既存を消して作り直すことを決めた。版の管理は room の全ツールを 1 つの表で行い、通常の wsl は対象外とした。根拠は `decisions.md` の同日の項。
- 閉じた NA 3 の原文: 3. 【起票 11-15】【判断:ユーザー】WezTerm + claude + nvim の使用感を試して、使い続けるかと、足すものを決める（構成は 11-15 に作成済み。経緯は `docs/log-history.md` の同日の項、調査と手段の比較は `docs/log-draft-terminal-sessions.md`）。決める点: 使い続けるか（11-15 時点でユーザーは「もう少し使って判断」。Zed と WezTerm の相互利用は想定しない。要件の下書き: cwd ごとのセッション整理・ファイラの root 追従・認証方式の選択）。決めたら、decisions の「ターミナル起点から Zed へ移行中」（2026-10 ごろの項）を見直しとして記録する。nvim は 11-15 に LazyVim 化済み（使い勝手を確認中。重いときは `NVIM_LITE=1`）。zellij（フローティングペイン・セッション残存）、nvim の追加の拡張（AstroNvim の設定の部分マージなど）は、使って足りないと感じたときに起票する。

### 2026-11-18（Notepad++ の選択ハイライトの色）
- 依頼: 選択範囲のハイライトが背景に同化して見えない。Windows Terminal の Tab 補完の選択と同じ青にしたい。
- 実施: `windows/notepadpp/Gruvbox dark medium.xml` の「Selected text colour」を、背景 `504945` → `23555E`、文字 `FBF1C7` にした。値は `windows/powershell/profile.ps1` の PSReadLine `Selection`（背景 #23555E、文字 #FBF1C7）と同じ。
- 未確認: Notepad++ の実機での見え方（ユーザーは「いいですね」と返答）。選択範囲の文字色（fgColor）が反映されるかは仮説。

### 2026-11-15（NA3 の続き: cwd セレクタと、セッション管理の調査）
- 依頼（`brief NA3`）: `$env:WORKS_DIR\resources` などを cwd にして開きたい。room を使う場合と Windows を使う場合の両方を 1 つで扱う。
- 実施: `windows/wezterm/wezterm.lua` の `Ctrl+Shift+T` を、候補（room の `~`、Windows の resources・works・dotfiles。`TARGETS` 表）を選ぶ InputSelector にした。選ぶと、その cwd と domain（room は WSL ドメイン、Windows は local の pwsh）で、左 `claude --resume`・右 `nvim` のタブを作る。タブ名は cwd の末尾。ユーザーが実機で選択と cwd（`C:\Users\ee\works\resources`）を確認した。
- 判明: `claude --resume` に直近の会話が出ない原因は、会話が SDK 経由（Zed の ACP。セッションファイルの entrypoint が `sdk-ts`）で、CLI の一覧に出ないため（推測。公式の仕様は未確認）。ファイルは `~/.claude/projects/<cwd のキー>/` に残っている。room は別ユーザーの `~/.claude` で、履歴は別。
- 調査（Web。ブログと README が情報源）: 参考記事（Zenn の dely）は「ルートごとにタブ、作業ごとにペイン（worktree + `claude --worktree` + `/rename`）」で、今の「1 タブ = 左 claude・右 nvim」とは階層が違った。cwd ごとの整理・ファイラ連動・認証選択をそろえる既存ツールは見つからず、Claude Code デスクトップ版（2026-04 の再設計）が候補。仕様は未確認。
- 未実施: 手順書 `docs/setup/wezterm-claude-nvim.md` の操作表の更新だけ行った。`windows/README.md` の記述、SDK 経由の会話の一覧スクリプトは作らない（ユーザーが止めた）。ユーザーは当面使って判断する（NA 3）。

### 2026-11-15（NA3 の続き: nvim を LazyVim 化）
- 依頼（`brief NA3`）: 素の nvim が使いづらいので LazyVim にする。テーマは gruvbox-material（ハイライトは Zed と同じ）、iceberg と tender も入れる（すべて dark）。重いときは必要な部分だけにできる形で。
- 実施: `home/.config/nvim` を LazyVim 構成にした（`init.lua`、`lua/config/{lazy,options,autocmds,features}.lua`、`lua/plugins/{colorscheme,features,oil}.lua`）。ハイライトは Zed の `material-gruvbox.json` の構文色を treesitter に写した（gruvbox-material にだけ適用）。iceberg・tender は `lazy = true` で、選ぶまで読み込まない（切り替えは `features.lua` の `M.theme`、`NVIM_THEME`、`:colorscheme`）。重いときは `NVIM_LITE=1` か `M.plugins` の行を `false`。tokyonight・catppuccin は入れない。手順書 `docs/setup/wezterm-claude-nvim.md` に追記。
- 確認: 隔離ディレクトリの headless 起動で、3 テーマの切り替えと `@string`=`#a9b665`・`Comment`=`#928374` を確認（lite モード）。ユーザーが実機で LazyVim の動作を確認した。使い勝手は確認を継続（NA 3 に残す）。
- 未実施: Zed の背景上書き `#45413e` は写していない。

### 2026-11-15（NA4: WezTerm + claude + nvim の手順書を書いた）
- 完了（NA4）: `docs/setup/wezterm-claude-nvim.md` を新規作成（前提表、流れ、章 1〜5、日常の操作、つまずき）。`docs/setup/README.md` の表とルート `README.md` の手順書の一覧に足した。`windows/README.md` と手順・コマンドが一致することを突き合わせた。通しの実行はしていない（確認は NA 5）。ユーザーの追加依頼: `room init` の最後のログに、dotfiles の `windows\room\*.ps1` を実行すること、`pwsh -NoProfile -File ... -Area <Area>` の実行例（`room-shell-setup.ps1` と `room-nvim-config.ps1` の両方）を出す。workbase の `workflow-kit/room/room.py`（`cmd_init` の最後の `ctx.say`）に足した（workbase 側でコミット）。`py_compile` は通った。実機の `room init` の出力は未確認。
  - 元の項目: 【起票 11-15】【やる:AI】WezTerm + claude + nvim の手順書を書く（`docs/setup/` に 1 本）。完了: 手順書が `docs/setup/` にあり、`README.md` から辿れて、`windows/README.md` と内容が食い違わない。

### 2026-11-15（NA6: room init に nvim・zellij・bell フックの段を移した）
- 完了（NA6）: workbase の `workflow-kit/room/room.py` の `INIT_STEPS` に `nvim`（v0.12.6）`zellij`（v0.46.0）`bellhook` を足した（部屋の中で SHA-256 検証、ai の `~/.local`、x64 のみ。bell は Notification・Stop に足し、既存の設定は残す）。試験 2 本を足し、全 193 件 OK。ユーザーが実機で `room init <Area> --only nvim,zellij,bellhook` の成功を確認した。nvim の設定の置き場は、ユーザーの決定で dotfiles から送るまま（部屋の標準にしない）。dotfiles の `windows/room/room-dev-setup.ps1` を `room-nvim-config.ps1`（設定の送り込みだけ）に縮め、`windows/README.md` を直した。手順書の内容の一致は NA 4 の側で保つ
  - 元の項目: 【起票 11-15】【やる:AI】`windows/room/room-dev-setup.ps1` 相当を `room init` の工程へ移す（workbase の `workflow-kit/room/room.py` の `INIT_STEPS` に、nvim・zellij・nvim の設定・bell フックの工程を足す）。方針: 部屋の初期化は workbase が定義する共通基盤。dotfiles → workbase の一方向の依存を守り、workbase 側に dotfiles の挙動を書かない（nvim の設定の置き場を、部屋の標準にするか、dotfiles から送るままにするかを、着手時に `brief` で決める）。完了: 新しい部屋を `room init` で作ると、`nvim` `zellij` が `~/.local/bin` にあり、bell フックが `~/.claude/settings.json` に入る。`room-dev-setup.ps1` が不要になるか、nvim の設定の送り込みだけに縮み、`windows/README.md` と手順書（NA 4）が合っている。

### 2026-11-15（NA3: WezTerm + claude + nvim の構成を作り、部屋へ導入。一部完了）
- 依頼（探索型。`brief` で NA3 を指定）: 1 タブ = 左 claude / 右 nvim を、WezTerm で試せる状態にする。
- 実施: `windows/wezterm/wezterm.lua`（WSL ドメイン `room-<Area>`、`Ctrl+Shift+T` で左右のタブ、bell でタブに 🔔）、`home/.config/nvim/init.lua`（lazy.nvim・gruvbox・oil.nvim）、`manifests/apps.txt`（wezterm・neovim・zellij）、`manifests/links.map`（wezterm の設定、`%LOCALAPPDATA%\nvim`）、`windows/room/room-dev-setup.ps1`（部屋へ nvim v0.12.6・zellij v0.46.0・nvim の設定・bell フックを SHA-256 固定で入れる。2 回実行して重複しないことを確認）、`windows/README.md`。
- 確認（実機）: (a) 新しいタブで左 claude・右 nvim が組まれた、(c) 右で `<Space>e` が oil.nvim を開いた、(b) 別タブにいるとき、手で鳴らした bell でタブがオレンジの 🔔 になった。claude 自身の入力待ちでの bell は未確認。
- 事故: Developer Mode オフのまま `30_link.bat link` を全件実行し、既存のファイルリンクが消えた。Windows Terminal の色が変わった（初期設定の再生成）。Developer Mode をオンにして張り直し、Terminal の書き換え分は `git checkout` で戻した。経緯と対策は `decisions.md` の同日の項。
- 見送り: `home/.claude/settings.json` への bell フック（部屋の claude には効かないため）。

### 2026-11-15（review 消化）
- 完了（NA1）: README・win11.md・debian-family.md を非公開向けに直した（GCM のサインイン、gh auth login → gh auth setup-git）。docs/setup/README.md の「公開」も直した。workbase 側の debian-family.md は 10-16 に dotfiles へ移っており無効。grep で『公開なので』の記述が残っていないことを確認
  - 元の項目: 【起票 11-13】【やる:AI】dotfiles の README と手順書（`win11.md`、Linux のクイックスタート）と、workbase の `cheatsheets/env/debian-family.md` の手順 7 を、非公開リポジトリ向けに直す（2026-11-13 に 3 リポジトリを非公開にした。2026-10-16 の「公開で確定」で削除した、サインインの注記を戻す）。完了: 非公開の clone に認証が要る旨（Windows は GCM のサインイン、Linux は `gh auth login` → `gh auth setup-git`）が書かれ、「公開なので認証なしで clone できる」という記述が `grep` で残っていない。
- 完了（NA2）: ユーザーが完了と報告
  - 元の項目: 【起票 11-13】【やる:ユーザー】PC1 で、公開の切り替えを使った pull を 1 回通す（未確認）: この PC から対象を公開 → PC1 で `git pull` → すぐ非公開に戻す → `gh repo view` で `PRIVATE` を確認する（works の `docs/log.md` の Open Questions 1 が決まれば、切り替えはエージェントに任せられる）。
- 完了（NA）: ユーザーが完了と報告
  - 元の項目: 【起票 11-02】Obsidian の 2 Vault 化の動作確認（Windows の実機。別セッション）: `30_link.bat` で、(a) `uv` `py` `python` のどれでも `obsidian_sync.py` が走る、(b) `%WORKS_DIR%\.obsidian` と `%WORKS_DIR%\resources\.obsidian` の 2 本のジャンクションができる、(c) `%WORKS_DIR%\resources` が無いときは `[SKIP]` で `resources\` を作らない、(d) 旧 `%WORKS_DIR%\.obsidian`（旧 `windows\obsidian\.obsidian` へのジャンクション）は上書きされる、(e) 両方の Vault が開き、works の検索から `resources/` が外れる。`30_link.bat` の新しい分岐は未確認（11-02 にユーザーが works で `resources` `resources_p` `repos` がエクスプローラーから消えたと報告したので、(a)(b)(e) の大半は動いたと見てよい。(c)(d) と `uv` なしの経路が残り）。11-02 に `30_link.bat` へ `noparent2`（Claudian の resources 側の symlink 用）を足した。clone 前に `resources` が無いとき `[SKIP]` になるかも、(c) と一緒に確かめる（実機で symlink が張れたことは確認済み）。
- 完了（NA）: ユーザーが完了と報告（10_env.bat と WFKIT_DIR の確認）
  - 元の項目: 別のPCで `10_env.bat` を実行し、新しいターミナルで `$env:WFKIT_DIR` が設定されること、Tab 補完で `$env:WFKIT_DIR` が実パスに変わらないこと（`profile.ps1` の Tab ハンドラ）を確かめる（2026-10-30 起票。この PC では動作確認済み）。
- 完了（NA）: ユーザーが完了と報告
  - 元の項目: 【起票 10-30】`room-myenv` に dotfiles のシェル環境を入れる案 B（案 A は同日に手で実施。starship と履歴の種のみ。fzf の Ctrl-R は 11-03 に `room-shell-setup.ps1` で導入済み）: zsh・zoxide・lsd・bat・fd・zsh-autosuggestions を root で入れ、`home/` の `.zshrc` `.bashrc` `common.sh` などを標準入力で送る。`room.py` のサブコマンド（workbase 側）か、dotfiles 側の送る `.ps1` かは未定。`~/.bashrc` は `room.py` と uv が追記するので、上書きせず追記で済ませる。stow と dotfiles リポジトリの持ち込みはしない（部屋は `/mnt/c` が空）。
- 完了（NA）: ユーザーが完了と報告
  - 元の項目: 【起票 11-03】`windows/powershell/boot-commtools.ps1` と `cleanup-recyclebin.ps1` の実機の確認（ユーザー）: (a) `boot-commtools.ps1` を taskschd.msc に登録して 30 分おきに回す（登録はユーザーが行う。条件はスクリプト先頭のコメント）。使ってみて、最小化（`-WindowStyle Minimized`）が要るか決める（11-03 は外した）。Teams の既存の自動起動と二重にならないかも見る。(b) `cleanup-recyclebin.ps1` の実際の削除（`y` の後の `InvokeVerb('delete')`）は未確認（11-03 は `-ListOnly` だけ。ゴミ箱の最古が 10-15 で対象 0 件だった）。対象が出る 12 月中旬以降に、`-Months` を小さくして試すか、実行して確かめる。
- 完了（NA）: ユーザーが完了と報告
  - 元の項目: 【起票 11-03】`windows/powershell/set-virtual-desktop.ps1` の実機確認の残り（ユーザー。(a)(b) は 11-03 にこの PC で OK）: (c) `-Relayout`（workspace の「Move existing windows」を有効にして）で位置とサイズが戻るか。(d) taskschd への登録（ログオン時や画面ロック解除時に `-MoveOnly` を足すかも決める）。複数ウィンドウを持つアプリ（Edge など）は、`MainWindowHandle` の 1 枚しか移さない。
- 完了（NA）: ユーザーが完了と報告
  - 元の項目: 【起票 11-03】他の PC への VirtualDesktop モジュールの入れ方を決める（この PC は 1.5.11 導入済み）: `Install-Module VirtualDesktop -Scope CurrentUser` は scoop・`20_apps.bat` の対象外。`20_apps.bat` に足すか、手で入れる手順に残すかを決める。workspace（`dev` `office`）のレイアウトは PC ごとに Capture する（`workspaces.json` は追跡しない。decisions 参照）ので、新しい PC では Capture と `-List` の確認も要る。既存の PC では、`workspaces.json` に旧インストール版のパス（例: `AppData\Local\Programs\Zed`）が残ると警告が出る（この PC は 11-03 に Zed を直した）ので、`application-path` を点検する。
- 完了（NA）: ユーザーが完了と報告
  - 元の項目: 【起票 11-08】Obsidian の Scriptorium（ライト）のフォントを目視で確認する（ユーザー）: UI・本文が Noto Sans JP、コードが PlemolJP Console NF になっているか。効いていなければ `snippets/theme-fonts.css` を直す。不要になった `--font-*-override` の指定（Brutalist 向け）を削るかも決める。
- 完了（OQ）: ユーザーが完了と報告
  - 元の項目: `scoop update` で、同梱の Markdown 用 UDL（`markdown._preinstalled_DM.udl.xml`）が実ファイルに戻り、`markdown.udl.xml` へのリンクが外れるか。戻ったら手で削除して `30_link.bat` をやり直す（2026-10-30 起票。未確認）。他の PC でも、最初は同梱の UDL を手で削除してから `30_link.bat` を実行する。

### 2026-11-15（タブでの Claude セッション管理の手段を調査。変更なし）
- 依頼（探索型）: Zed + ACP で Claude を使っているが、エディタ・ペインを使わなくなり、並列セッションをタブで管理したい。手段を調べて比較する。
- 実施: Web 調査。WezTerm / Windows Terminal / tmux・zellij / herdr / `claude agents` / Zed のスレッドと比べた。4 層（ターミナル・マルチプレクサ・エディタ・Claude 側）に整理した。ターミナルとマルチプレクサはタブ・ペインが重なる。
- 決めたこと: まず WezTerm（Lua）＋ Neovim で試す。1 タブ = 左 claude / 右 nvim、ファイラは右から出す。以降は PC の環境で行う。
- 未確認: WSL での bell 通知、herdr の WSL 動作（Windows 版はベータ）、ファイラの選定。
- 詳細: `docs/log-draft-terminal-sessions.md`（Next Actions 3 の参照先）。

### 2026-11-13（dotfiles を非公開にした）
- 依頼（確定型）: 3 リポジトリを private にして、この PC から push と pull ができる環境にする（works の同日の項に全体）。
- 実施: dotfiles を PRIVATE にし、`git fetch` と push が通った（`cb387ed`）。`AGENTS.md` の push の項の公開範囲を直し、`decisions.md` に「非公開にする。2026-10-16 の『公開で確定』を置き換える」を足した。
- 未了: README と手順書の非公開向けの直し、PC1 での pull の確認（`log.md` の Next Actions 1・2）。

### 2026-11-13（Windows Terminal の選択ハイライトを見やすくした）
- 依頼（確定型）: PSReadLine の ListView と fzf の Ctrl+r の選択行が、端末の背景 `#45413E` に溶けて見づらい。色の候補・選定も含めて改善する。
- 実施: 選択行の背景を `#23555E`（Gruvbox の faded blue `#076678` を、第1案で「少し強い」とのことで弱めた色）、文字を `#FBF1C7` にした。`profile.ps1` で ListView の選択行（`ListPredictionSelected`）と Tab 補完メニューの選択（`Selection`）を同じ変数 `$selected` で指定し、予測の薄い文字は `#A89984`、一覧の `>` は `#FABD2F` にした。fzf は `FZF_DEFAULT_OPTS` の `--color`（`bg+` を同じ色、`gutter` を背景色）で、`profile.ps1` と `home/.config/shell/common.sh` に入れた（WSL の bash / zsh も同じ見た目）。
- 確認: `profile.ps1` の構文、`bash -n common.sh`、`Set-PSReadLineOption -Colors` が通ることまで。見た目はユーザーが試用中（候補 B 琥珀・C 紫・D 明るい灰は会話で提示。選ばれなかった）。
- 未対応: `windows/room/room-shell-setup.ps1` の fzf 設定（room 内の別環境）は、そろえていない。

### 2026-11-08（Obsidian のテーマを Scriptorium（ライト）に。Brutalist と Typora-Vue は入れない）
- 依頼（探索型。ゴールは比較できる環境まで）: ライトの Scriptorium と Brutalist を入れて切り替えられるようにし、フォントは Noto Sans JP、コードは PlemolJP にする。比較の後、Scriptorium（ライト）を既定にし、Brutalist と Typora-Vue を破棄してコミット。
- 実施: 正本 `windows/obsidian/resources/.obsidian/` に `themes/Scriptorium/` を追加し、`appearance.json` を `moonstone` + `Scriptorium`、フォントを Noto Sans JP / PlemolJP Console NF にした。`snippets/theme-fonts.css` を新規に足し、`appearance.override.json`（works）の有効スニペットにも足した。Typora-Vue は `git rm`。`obsidian_sync.py` で works 側を反映し、`--check` で一致を確認した。
- 未確認: Scriptorium でのフォントの効き方（目視）。`theme-fonts.css` の Brutalist 向けの指定は、Brutalist を外したので不要。
- 最終の注意: 作業の終わりに Obsidian が起動していた。`appearance.json` はディスク上で意図どおりだったが、Obsidian がメモリ上の設定で上書きする可能性があるので、`git status` で確かめる。

### 2026-11-07（fonts.txt に Noto Sans JP を追加。一覧に任意のタグを設けた）
- 依頼: この PC に Noto Sans JP があるか → あった（`C:\Windows\Fonts\NotoSansJP-VF.ttf`、`NotoSerifJP-VF.ttf`。どちらも作成日時 2026-09-14 03:25:19）。入れた主体は不明（OS 標準の日付は 2024-04-01、dotfiles に記載なし）。クリーンな PC では無い前提にして、`24_fonts.*` で取得できるようにした（ユーザーの決定。`decisions.md` の同日の項）。
- 実施: `manifests/fonts.txt` を `owner/repo:asset glob[:release tag]` にし、`notofonts/noto-cjk:16_NotoSansJP.zip:Sans2.004` を追加。`noto-cjk` の latest は Serif のリリースで Sans の zip が無いため、タグを固定した。`24_fonts.bat`（`:GET` サブルーチン）と `24_fonts.sh` を直し、`tests/linux/test_scripts.sh` にタグ付きの試験を 1 件足した。`fonts-setup.md` の保存先の誤り（`download` → `Downloads`）も直した。
- 確認: 偽の `gh` で `.bat` のタグあり・なしの呼び出しを確認。`test_scripts.sh` は 71/71（WSL）。未確認: 実際の 27MB のダウンロードとインストール。
- 閉じた項目（済）: 【起票 11-04】`room-completion.ps1` の実機確認。`room clean` の廃止に伴い、読み込みを `profile.ps1` から外した（61acdc5）ため、確認の対象が無くなった。

### 2026-11-06（scoop の共通 manifest に quarto を追加）
- 依頼: scoop で quarto を入れられるように manifest へ追加してコミットする。
- 実施: `scoop search` で `quarto`（1.11.9）が extras バケットにあるのを確認し、共通の `manifests/apps.txt` の「editor / viewer」に追加した（f6ff55a）。`apps.home.txt` でなく共通に置いたので、家だけにしたければ移す。
- 未確認: この PC への `scoop install quarto` と `20_apps.bat` の通し実行（manifest の追加だけ）。`scripts/` は変えていないので `tests/linux/test_scripts.sh` は実行していない。

### 2026-11-05（Obsidian の既定の編集モードを閲覧ビューにした）
- ユーザーの依頼: Obsidian のノートが編集モードで開くのが不便。正本の `windows/obsidian/resources/.obsidian/app.json` に `"defaultViewMode": "preview"` を足し（223daa8）、`obsidian_sync.py` で works 用の派生 `app.json` に反映した（works 側は追跡しない）。
- 実機確認（同日、ユーザー）: 起動直後に前回のタブが編集モードで開いた。原因は設定ではなく、`workspace.json`（追跡しない）が開いていたタブの `"mode": "source"` を保存して復元するため（`defaultViewMode` は新しく開くノートにだけ効く）。タブを一度閲覧モードにして保存させたら、閲覧モードで開くようになった。解決として Next Actions の起票を閉じた。
- 他の PC では `30_link.bat` か `obsidian_sync.py` で `app.json` を反映し、最初の 1 回だけ開いているタブを閲覧モードにする。

### 2026-11-04（room clean --path の Tab 補完を profile から読み込む）
- workbase の `workflow-kit/room/room-completion.ps1`（正本）を、`profile.ps1` の `room-sh` の後で読み込む 4 行を足した（`$env:WFKIT_DIR` が無い、またはファイルが無ければ何もしない）。72f06ff と 8693e77（未設定時に `Join-Path` が落ちるのを直した）。push 済み。実機未確認（pwsh が無い環境で作った）。2〜3 日使ってユーザーが採否を決める。
### 2026-11-03（PowerToys Workspaces の Zed の警告を、scoop 版のパスに直した）
- 症状: ログオン時の Workspaces で、Zed の項目に警告マーク（三角）が出ていた。
- 原因: `%LOCALAPPDATA%\Microsoft\PowerToys\Workspaces\workspaces.json` の Zed が、10-04 に削除した Inno Setup 版のパス（`AppData\Local\Programs\Zed\Zed.exe`、`app-user-model-id` は `ZedIndustries.Zed`）のままだった（scoop 版への統一は exmem の `scoop-app-management.md`）。
- 対処: `application-path` と `app-user-model-id` を `%USERPROFILE%\scoop\apps\zed\current\Zed.exe`（junction。更新でパスが変わらない）に書き換えた（編集前は同じ場所に `.bak`）。ユーザーが、警告が消えたことを確認した（実機）。
- `workspaces.json` は PC ごとのローカル管理で追跡しない（decisions 参照）。リポジトリの変更なし。他の PC でも、旧インストール版のパスが残っていれば同じ修正が要る。

### 2026-11-03（set-virtual-desktop.ps1: この PC で VirtualDesktop を導入し、動作確認が OK）
- 実施: `Install-Module VirtualDesktop -Scope CurrentUser` でこの PC に導入（1.5.11、`Get-Module -ListAvailable` で確認。build 26300 でも動いた）。
- 確認: 実行ログで、`-Name nope` は `$desktopMap` に無く停止、`office` が `workspaces.json` に無いとき `ERROR: workspace 'office' not found`（原因は未 Capture。スクリプトの不具合ではない）、Desktop 2 の自動作成、dev の起動待ち（`windows ready: True`）と `already on Desktop 1` の経路。ユーザーが `office` を Capture した後、動作確認は OK と報告（ユーザー報告。ログは未保存）。
- 閉じた項目: 「この PC に VirtualDesktop を入れる」（済）、実機確認の (a)(b)（一部済。(c)(d) は log に残す）。
- 決定: workspace のレイアウトは PC ごとにローカルで持つ（`decisions.md`）。

### 2026-11-03（set-virtual-desktop.ps1: PowerToys Workspaces を読んで動的にした）
- 依頼: 趣味 PC の `set-virtual-desktop.ps1`（298 行。写真 6 枚を `tmp/pic2` に置いた）を取り込み、`dev` と `office` の workspace を `.lnk` 固定でなく、新しいスナップショットを手軽に渡せる形にする。位置とサイズも維持したい。PowerToys は scoop から入れる。
- 実施: `manifests/apps.txt` に `powertoys` を追加（共通。extras バケット、この PC は 0.102.3001.0）。`workspaces.json`（`%LOCALAPPDATA%\Microsoft\PowerToys\Workspaces\`）から名前で GUID とアプリ一覧を引き、`PowerToys.WorkspacesLauncher.exe <GUID>` を直接呼ぶ。プロセス名は `application-path` から導出（`explorer` は除外）。デスクトップ番号は ps1 先頭の `$desktopMap`（ユーザーの選択。別ファイルにしない）。固定 90 秒の待ちは、ウィンドウが揃うまでのポーリング（上限 90 秒）に変えた。
- 確認: 5.1 と 7 で `-List` が動く（dev の GUID とプロセス 4 つを読む）。`-Name` の不正でエラー終了。
- 未確認: VirtualDesktop モジュールが無いこの PC では、起動・移動の経路を実行していない。`-Relayout`（`move-existing-windows`）の効き方。
- 知見: `workspaces.json` には仮想デスクトップの情報が無い（位置・サイズ・モニターだけ）。デスクトップの振り分けは ps1 側の責任。`Workspaces\settings.json` はホットキーだけで、定義ではない。

### 2026-11-03（check-drive-usage.ps1: C ドライブの削除候補の調査）
- 依頼: 趣味 PC の同名スクリプト（1,382 行。写真 33 枚を `tmp/pic` に置いた）を、C ドライブの使用量が多い場所と、逼迫したときの削除候補を出すスクリプトとして `windows/powershell/` に取り込む。
- 実施: 写真から書き起こし、pwsh 7 用に `#Requires -Version 7` と使い方のコメントを足した。調査と表示だけで、削除しない。`-Top`（回収ランキング）と `-ChildTop`（直下ランキング）。`windows/README.md` の表に 1 行。
- 変更（ユーザーの指示）: (a) Claude の Store パッケージ名 `Claude_<接尾辞>` の決め打ちをやめ、`Packages\Claude_*` の最初の一致を使う（無ければ 0 GB 扱い）。(b) 回収ランキングは、優先度順でなく容量順（`Priority` の項目は削除。優先度順だと `-Top` で WSL などが落ちていた）。(c) `$ErrorActionPreference = 'SilentlyContinue'`（アクセスできない場所は読み飛ばす）は、そのまま。
- 確認: 構文エラー 0。この PC で実行し（約 99 秒）、全セクションが出ること、容量順（WSL 9.39 GB、Scoop 9.09 GB…）になることを見た。削除は一切しない。
- 未確認: 他の PC（Store 版 Claude がある環境）で、`Claude_*` の一致が効くか。

### 2026-11-03（Outlook/Teams の定期起動と、ゴミ箱の整理スクリプト）
- 依頼: `boot-commtools.ps1`（Outlook と Teams を未起動なら起動。30 分おきにタスク スケジューラ。常時起動のメモリ消費を避ける）と `cleanup-recyclebin.ps1`（数か月より前のゴミ箱の項目だけを確認して完全削除）を `windows/powershell/` に。タスクの登録はユーザー。
- 実施: 2 本を pwsh 7 用に作成（`c750bf8`）。`boot-commtools.ps1` は `-WhatIf`、`cleanup-recyclebin.ps1` は `-ListOnly`（`-Months` 既定 2）を足した。削除日時を読めない項目は対象外にして件数を警告。`windows/README.md` の表に 2 行。
- 変更（ユーザーの指示）: `boot-commtools.ps1` の最小化起動（`-WindowStyle Minimized`）は、使ってみて決めるため外した。
- 確認: `-WhatIf` で両方が「起動」と出る。`-ListOnly` で 90 件・最古 10-15・日時の解釈が正しいこと（対象 0 件）。
- 未確認: 実際の起動、実際の削除、taskschd からの実行。

### 2026-11-03（room に fzf の Ctrl-R を導入）
- 依頼: 履歴を fzf で検索できる関連を、dotfiles から room へ。複雑にしない。
- 実施: `room-starship-setup.ps1` を `room-shell-setup.ps1` に改名し、fzf v0.74.5 を追加（SHA-256 固定、`~/.local/bin`、`~/.bashrc` に冪等ブロック、Ctrl-R のみ）。`room-myenv` で実行し、チェックサム・`bind -X`・再実行の冪等を確認。`windows/README.md`・`decisions.md`・`log.md` を更新。
- 未確認: Terminal のタブでの Ctrl-R の見た目。

### 2026-11-03（Zed の ps1 ハイライト修復と、テーマの行き来）
- 依頼: Zed で `.ps1` のハイライトが効かない。10-30 のテーマ変更（Material Gruvbox Dark → Gruvbox Dark）が原因か、ほかの悪影響も挙げて直したい。
- 原因: テーマではなかった。`%LOCALAPPDATA%\Zed\extensions\installed` の `powershell`（brackets/indents/outline.scm）と `html`（5 つの .scm）が NUL 埋めで壊れ、Zed.log に `failed to load language PowerShell: Error loading brackets query`（HTML は約 3,000 回）。クラッシュなどで書き込みが途中で切れたと推測（未確認）。他の拡張は無事（.scm/.toml/.json/.wasm を検査）。
- 修復: 2 拡張の `installed` ディレクトリを削除し、Zed 再起動で `auto_install_extensions` に再取得させた。ユーザーが `.ps1` のハイライト復活を確認（11-03）。
- 変更: `settings.json` の `theme_overrides` に `Material Gruvbox Dark` を足し、テーマセレクタ（Ctrl+K Ctrl+T）で両テーマを行き来できるようにした。ユーザーが両テーマで override が効くことを確認（11-03）。README の Zed の行、`decisions.md`（10-30 の項への追記）、`log.md` を更新。
- omit（11-03 ユーザーの判断）: Open Question「`vba`（dev extension）の入れ直し手順を README に書くか」。必要になったらやる。
- 影響の洗い出し（未対応のまま報告）: 文字色が明るい（`#ebdbb2`）、Markdown の見出し・強調・コードの色が Notepad++/Obsidian とずれる、UI の面の色と端末パレットが標準になった、`theme_overrides` が標準テーマ名に依存。

### 2026-11-02（部屋の starship 導入をスクリプトにした）
- 依頼: pc1 で部屋の starship が効かない。原因は、10-30 の導入が pc2 での手作業で、pc1 の部屋には入っていなかったこと。スクリプト化を依頼された。
- 変更: `windows/room/room-starship-setup.ps1`（`-Area`、既定 `myenv`）。`windows/README.md` に1行。
- 確認（pc2）: 導入済みの部屋で再実行し、starship 1.27.0・`.bashrc` の1行が1つ・履歴の先頭行が1つのまま（冪等）。存在しない Area は止まる。**未確認**: pc1 の部屋での実行。
- 注意: `uv run room.py` を持たない PC では部屋が無いので、先に `room init` が要る。
- 位置づけ: 連番バッチ（`scripts\windows\`）からは呼ばない（ユーザーが同意）。この導入は `room init` の仕事で、今後は自動で入る。ps1 は既存の部屋への手動の入口として残す。判断は `decisions.md`。

### 2026-11-02（Claudian を resources の Vault にだけ戻した）
- 依頼（ユーザー）: `a08e8c8`（10-25 に Claudian と excel-to-markdown-table を削除）の Claudian 分だけを、resources の `.obsidian` に戻す。works は Claudian を入れないので削除のまま。
- 変更: `resources/.obsidian/plugins/realclaudian/`（元のブロブと同一）と `community-plugins.json`（`db2944b`）。`claudian-settings.json` は削除されておらず、works 側の symlink だけ無かったので、`links.map` に resources 用の 1 行を足し、`30_link.bat` に `noparent2`（リンク先の 2 つ上が無いときだけ `[SKIP]`）を足した（`6f8ed69`。ドライラン確認、ユーザーが実機で symlink 成功を確認）。
- workbase 側: `/.claudian/` を `.gitignore` に追加（works と同じ。sessions を追跡しない。workbase の `7c9af4e`。push は未）。excel-to-markdown-table は戻していない。

### 2026-11-02（works のエクスプローラーから 3 フォルダを隠し、`resources_p/` を除外に足した）
- 依頼（ユーザー）: works のファイルエクスプローラーから `resources` `resources_p` `repos` を見えなくする。重さは感じないとのことで、`resources_p/` も除外フィルタに足した。
- 変更: `works/.obsidian/snippets.works/hide-vault-folders.css`（`:has()` で非表示）、`appearance.override.json`（スニペットを有効化）、`obsidian_sync.py` が `appearance.json` の override と `snippets.works/` の混ぜ込みに対応、`app.override.json` に `resources_p/`。試験 76 項目。コミット `f39f625` と続き。ユーザーの実機で消えたことを確認。

### 2026-11-02（Obsidian の設定を resources 用と works 用の 2 つに分けた）
- 依頼: workbase 側で Vault の 2 分割が正式化された（`topics/room-type-consolidation`）ので、dotfiles 側を実装する。動作確認は別セッション。
- 変更: `windows/obsidian/.obsidian` を `resources/.obsidian`（共通設定の正本）と `works/.obsidian`（固有分）に分けた。`scripts/obsidian_sync.py` を新設（正本から works の派生分を生成。`--check` `-n`）。`links.map` に 2 本（resources 側は `|noparent`）。`30_link.bat` は先に sync を走らせ、第 3 項を読む。`30_link.sh`（ネイティブ）も同様。`.gitignore` に派生分を追加。`tests/linux/test_scripts.sh` に sync と 2 本のリンクを追加（75 項目、WSL 相当の Linux で通過）。
- 根拠と詳細: `docs/decisions.md` の同日の項。

### 2026-10-30（Zed の Gruvbox Dark で Markdown のリストマーカーをオレンジに）
- 依頼: テーマを Material Gruvbox Dark から Gruvbox Dark に変えたら、Markdown の `1.` `2.` の色が本文と区別できなくなった。オレンジにする。
- 変更: `home/.config/zed/settings.json` の `theme_overrides` → `Gruvbox Dark` → `syntax` に `punctuation.list_marker` を `#e78a4e` で追加（旧 `themes/material-gruvbox.json` と同じ色）。`-` の箇条書きにも効く。ユーザーが実機で確認し、そのままでよいと判断した。

### 2026-10-30（履歴を `uv run --script $env:WFKIT_DIR\...` の形に統一し、種に workflow-kit を足した）
- 依頼: Python の実行を `uv run --script` に、`$env:WFKIT_DIR` を使う形に揃えたので、履歴と履歴の種も同じ形にする。種にないスクリプトとオプションも足す。
- このPCの履歴: `ConsoleHost_history.txt` を 547 → 396 行（重複は全体で削除し、新しい方を残した。バックアップは同じ場所の `.bak-20261030`）。`uv run room.py ...`、`uv run .\workflow-kit\tools\x.py`、`python workflow-kit/tools/x.py` を `uv run --script $env:WFKIT_DIR\room\room.py ...` / `...\tools\x.py` に、`--prices` のパスも `$env:WFKIT_DIR\tools\...` に直した。壊れた1行は削除。
- 種: 正本 `exmem/lessons/shell-command-usecases.md` を、ユーザーの承認で編集し（AGENTS.md の例外。今回限り）、そこから `windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt` を再生成した。`workflow-kit` の節（`room.py` の全サブコマンドと主なオプション、`tools\` の主なスクリプト）を新設。git と wsl の行を少し足した。`uv run <スクリプト名>.py` は `uv run --script <スクリプトのパス>.py` に。`aws configure --profile n1-trial` は `aws configure --profile <プロファイル名>` に直した。zsh/bash の種は `git pull --rebase` の1行のみ（`WFKIT_DIR` は Windows だけ）。
- 確認: 追加行をパーサーで検査（先頭が `<` の語を含む行だけがパースエラー）。`bash tests/linux/test_scripts.sh` は 55/55。

### 2026-10-30（Terminal の設定の復旧と、room-myenv のプロファイル・starship）
- 依頼: Terminal の起動ディレクトリが `~` に戻り、Azure Cloud Shell が出る件の確認。続けて、`room-myenv` に `ai` で入るプロファイルの追加、部屋へのシェル環境の転送の見積もり。
- 原因: scoop 版 Terminal の `settings.json`（`links.map` のリンク先）が、20:59 に初期設定で作り直され、リンクでない実ファイルになっていた。リポジトリ側は無傷。ユーザーが `30_link.bat` で戻して正常を確認した。引き金は未確認（リンクの置き換えか、読めなくなって作り直しか）。
- 変更: `windows/terminal/settings.json` に `room-myenv`（`uv run room.py shell myenv`）。部屋に starship v1.27.0、`starship.toml`、履歴の種、`.bashrc` の1行（手作業。判断は `decisions.md`）。案 B を `log.md` の Next Actions に起票。
- 確認: `uv run room.py shell --help`、JSON の読み込み、部屋での `starship --version`。Terminal のタブからの起動は未確認。

### 2026-10-30（Notepad++ のプラグイン自動導入と Markdown の配色。コミット 1b27019）
- 依頼: CSVLint と Markdown Viewer++ を自動で入れる。Markdown の色（見出し緑・コード青・強調黄）を Zed の `settings.json` と同じ色コードにする。続けて、プレビューの背景をダークに、エディタ側も同じ配色に。
- 変更: `windows/notepadpp/install-plugins.ps1`（固定版・SHA256 検証、`-ResetCss`）、`markdown-viewer.css`、`markdown.udl.xml`（同梱の Markdown 用 UDL のコピー）、`links.map` の1行、`20_apps.bat` の呼び出し、README 2つ。色は `#a7b85a`（見出し）、`#d8a657`（強調）、`#7daea3`（コード）、`#282828`（背景）。
- 経緯: プレビューが白いままだった原因は、実機の `htmlCssStyle` が `body` を足す前の古い CSS のままで、スクリプトが「空のときだけ書く」作りだったこと（実機の ini で確認）。`-ResetCss` を足し、ユーザーが実機で動作確認した。エディタ側の色は、同梱の UDL（`markdown._preinstalled_DM.udl.xml`）の色を差し替えた。
- 見送り: CSV を見るだけで列を揃える件。CSVLint には機能が無く（配布元の docs で確認）、Columns++ の Elastic Tabstops はタブ区切りが前提。ユーザーが見送りを決めた。
- 確認: 作業用フォルダでスクリプトを2回動かして冪等性を確認。このPCの実機はユーザーが動作確認した。`tests/linux/test_scripts.sh` は `scripts/linux/` と `home/.profile` に触れていないので実行していない。push はしていない。

### 2026-10-30（Zed の設定を見直し、WFKIT_DIR と pwsh の Tab 補完を足した）
- 依頼: Zed の `settings.json` の改良、Windows Terminal の開始位置と環境変数 `WFKIT_DIR`、`auto_install_extensions` の点検、pwsh の Tab 補完が `$env:WFKIT_DIR` を実パスに書き換える件。
- Zed（`home/.config/zed/settings.json`）: アイコンテーマを dark/light とも `Material Icon Theme` に、`project_panel.file_icons` を `true` に、`auto_update` を `false` に。dark テーマを `Gruvbox Dark` にし、Markdown 用の `theme_overrides` のキーも `Gruvbox Dark` に（色と太さは同じ）。`auto_install_extensions` に `material-icon-theme` と `log` を追加。
- 拡張の点検: `%LOCALAPPDATA%\Zed\extensions\installed` と突き合わせた。UI で入れた拡張は `settings.json` に書かれないので、手で足す必要がある（`log` はそれで漏れていた）。未宣言で残るのは dev extension の `vba` だけ（レジストリに無いので自動では入らない）。JSON は Zed 本体の組み込み、TOML・HTML・XML は拡張。
- Windows Terminal（`windows/terminal/settings.json`）: `defaults` の `startingDirectory` を `%WORKS_DIR%\resources` にし、PowerShell プロファイルの `workflow-kit\room` の指定を外した（直前の `c2c6953` を戻した形）。
- `10_env.bat`: `WFKIT_DIR=%WORKS_DIR%\resources\workflow-kit` を `setx` し、`[ENV]` の一覧に出す。`WSLENV` には足していない。CRLF のまま。
- pwsh（`windows/powershell/profile.ps1`）: Tab 補完は `$env:VAR\...` を実パスに展開する（PowerShell の仕様。`TabExpansion2` で確認）。Tab のキーハンドラを差し替え、`MenuComplete` の後に、補完前のバッファに書いてあった `$env:WFKIT_DIR` `$env:WORKS_DIR` だけを実パスから戻す（`Restore-EnvVarRefs`）。履歴に変数の形で残る。却下: PSDrive（外部コマンドに `wfkit:\` のまま渡って動かない）。
- 確認: 置換の関数は4パターンで試験。実機の Tab 操作は、ユーザーが「すべて動作確認とれた」と報告。
- README（`README.md` の Zed の行、`scripts/windows/README.md` の `10_env.bat` の行）を実態に合わせた。`tests/linux/test_scripts.sh` は、`scripts/linux/` と `home/.profile` に触れていないので実行していない。

### 2026-10-29（pwsh の開始ディレクトリを room にした）
- 依頼: pwsh の起動時に `$WORKS_DIR\resources\workflow-kit\room` にいて、すぐ `uv run room.py ...` を打てるようにする。
- 経緯: 最初は `profile.ps1` の末尾で「ホームで始まったときだけ `Set-Location`」にしたが、Windows Terminal は `profiles.defaults` の `startingDirectory` を `%WORKS_DIR%` にしているので条件に合わなかった。`profile.ps1` の変更は取り消した。
- 変更（ユーザーが実機で確認）: `windows/terminal/settings.json` の PowerShell プロファイルにだけ `startingDirectory` を `%WORKS_DIR%\resources\workflow-kit\room` で足した。`defaults`（CMD、Ubuntu）は `%WORKS_DIR%` のまま。Windows Terminal 以外（VS Code、Zed）から起動した pwsh の開始位置は変わらない。
- 触らなかったもの: `docs/decisions.md` の未コミットの変更（元からある）。

### 2026-10-29（na2: `--gateway` が動かない件。Zed に部屋用の項目を足した）
- 依頼: 部屋で `--gateway` を試したが動かない。Claude Code では Bedrock が優先されるか、Zed では `claude-acp-gateway.cmd` が見つからない。
- 調べたこと: 認証の優先順位は Bedrock（`CLAUDE_CODE_USE_BEDROCK`）が最上位。`aws-key` は `~/.aws/credentials` を置くだけで Bedrock を有効にしないので、それだけでは負けない。`--gateway` は `CLAUDE_CODE_USE_BEDROCK` と `ANTHROPIC_API_KEY` を外すが、`ANTHROPIC_AUTH_TOKEN` は外さない。原因の特定には部屋の `/status` が要る（未確認）。Zed の「Claude Gateway」は Windows の `.cmd` を呼ぶので、interop を切った部屋では見つからない。
- 変更（ユーザーの承認）: `home/.config/zed/settings.json` に「Claude Gateway (room)」を追加（`npx` で直接起動、`CLAUDE_CONFIG_DIR=/home/ai/.claude-gateway`）。`/home/ai` は未確認。Zed での動作は未確認。
- 触らなかったもの: `docs/decisions.md` と `home/.claude/settings.json` の未コミットの変更（元からある）。
- 追記（同日、ユーザーの依頼）: `windows/claude/README.md` と `README.html` に「IAM アクセスキーを使う・更新する」（第1章。`aws configure --profile`、`list`、`sts get-caller-identity`、一時キー、部屋の `room aws-key`）と、Zed の agent 表に「Claude Gateway (room)」の行を足した。コマンドは AWS CLI の一般的な使い方による。実機では実行していない。
- Next Actions の整理（ユーザーの申告。確認はユーザーの実機）:
  - **済（na1）**: pwsh の starship 設定を、この PC で有効にする（`30_link.bat` でリンクを作り、表示と起動の速さ、`ls`、`z`、複数行入力を確認する項目）。ユーザーが完了と申告した。
  - **済（na2）**: 部屋の `room start --gateway` の実機確認（`/status`、約50分後の接続、終了後のトークン削除、Zed の「Claude Gateway (room)」）。ユーザーが、動作確認が終わり問題なしと申告した。`ANTHROPIC_AUTH_TOKEN` を外す件は、問題が出なかったので起票していない。
  - **見送り（na3）**: 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（案の段階だった）。ユーザーが「時期が来たらまたやる」と言って、取り下げた（omit）。決定ではない。

### 2026-10-29（部屋からゲートウェイを使う `room start --gateway` を足した）
- 依頼: WSL の部屋から、`windows/claude/readme.html` 第4章のゲートウェイで Claude を使いたい。Bedrock が部屋で使える仕組み（`room aws-key` で `~/.aws/credentials` に長期キー）と対比して設計した。
- 決定（ユーザー）: 単独の `room gw-token` は作らず、`room start` が受ける。タスク スケジューラは使わない（ゲートウェイは常用でなくバックアップ）。`apiKeyHelper` は部屋で `cat` にする。`--cmd` に組み込む。実装は workbase の `workflow-kit/room/room.py`。判断の根拠は `decisions.md` の「部屋（専用 WSL）からの利用」。
- 結果: `room.py` に `--gateway`（設定とトークンの事前確認、`~/.claude-gateway` への書き込み、約50分ごとの置き換え、終了時の削除）。`workflow-kit/room/tests` 160 件が失敗0（`GatewayTest` 5 件を追加）。実機の部屋では未確認（別セッションで行う。`log.md` の Next Actions）。workbase 側のコミットは `workflow-kit/room/` の3ファイル。`home/.claude/settings.json` の未コミットの変更は元からあり、触っていない。

### 2026-10-25（期日の節を戻した）
- 整合の基準（workbase の `docs/alignment-baseline.md`）に合わせて、`docs/log.md` に期日の節を戻した（項目は「なし」。`db6533a`）。

### 2026-10-25（`UserPromptSubmit` フックを足した）

- workbase の作業の言葉の索引（`triggers:`）を、依頼ごとに AI の文脈へ出すため、`home/.claude/settings.json` に `UserPromptSubmit` を足した（`42c7c6a`）。スクリプトは workbase の `workflow-kit/tools/triggers_hook.py`。ファイルが無い PC で依頼が止まらないよう `Test-Path` で守る。判断は `decisions.md` の同日の項。発火は workbase の作業セッションで確認した。`home/.config/zed/settings.json` の未コミットの変更は元からあり、触っていない。

### 2026-10-20 続き3（pwsh の起動を短くする変更を `profile.ps1` に足した）

- Windows Terminal の新しいタブの起動が遅い（pwsh 本体が約 2,200ms で減らせず、プロファイルが約 1,500ms）ため、別の PC で作られた `profile.ps1` の追加の差分（画像で受け取った）を適用した。内容: Scoop の shim の迂回（PATH の先頭に実体のディレクトリ）、starship / zoxide の init 出力のキャッシュ（`%LOCALAPPDATA%\pwsh-init-cache`）、starship の継続プロンプトの固定文字列化。先の starship の切り替え（続き2）の上に、組み合わせて適用した（差分は切り替え前の `profile.ps1` が基準）。
- 結果（元の PC の計測。この PC では未計測）: プロファイル読み込みが約 1,520ms から約 740〜860ms（-45〜50%）。この PC では、構文エラー0件、正規表現の一致、`tests/windows/test_claude_launchers.ps1` 失敗0を確認した。起動時間と実ターミナルでの動作は未確認。判断は `decisions.md`「pwsh の起動を短くする」。

### 2026-10-20 続き2（pwsh のプロンプトが約 2.2 秒かかる問題に、pwsh 専用の starship 設定を入れた）

- Windows Terminal + PowerShell 7 で、プロンプト1回が約 2,200ms（directory 1,360ms、git_status 610ms）かかっていた。原因は starship が git を調べるときのプロセス生成の遅さ（`cmd /c exit` が約 165ms、`git --version` が約 540ms。会社 PC に Defender のほか、ファイルとプロセスを監視するフィルタドライバがある）。別の PC で調査・修正された差分（画像で受け取った）を、この PC に同じように適用した。
- 内容: `windows/powershell/starship.toml`（pwsh 専用。`git_branch` / `git_status` を外し、`directory` の `truncate_to_repo` を false にし、`env_var.PS_GIT_BRANCH` を表示）、`windows/powershell/profile.ps1`（`STARSHIP_CONFIG` を切り替え、`Invoke-Starship-PreCommand` が `.git/HEAD` を直接読んでブランチ名を出す）、`manifests/links.map`（`~/.config/starship-pwsh.toml` へのリンク。差分には無く、この PC で補った）、`windows/README.md`。
- 結果（元の PC での計測。この PC では未計測）: 約 2,200ms から約 230ms（-90%）。計測は Claude Code の子プロセス内で、Windows Terminal 内の値は未測定。この PC では、プロファイルの構文エラー0件だけ確認した。リンクの作成（`30_link.bat`）と、新しいタブでの体感は未確認。判断は `decisions.md`「pwsh だけ starship の git 系モジュールを外す」。 の範囲を承認。SSO の件を閉じた。他の PC の展開を完了）

- ユーザーが `.cmd` の `pause` の範囲を承認した。もとの依頼は「`setup` 系の bat 全般」で、理由は「失敗したときにログを見落とすため」。対話専用の入口だけに入れ、`apiKeyHelper` として呼ばれる経路（`claude-gateway-token.cmd` の `-Login` 以外）と Zed の起動用（`claude-acp-gateway.cmd`）には入れない。これに合わせて `claude-bedrock-setup.cmd`（対話の setup なのに `pause` が無かった）にも、`claude-gateway-setup.cmd` と同じ形で `pause`（終了コードは保つ）を足した。
- SSO の件は、ユーザーが閉じた。依頼の取り違え（接続先は SSO でなくゲートウェイ）が原因で、AWS SSO の追加は `84e4471` で取り消し済み。SSO に関する Next Actions と Open Questions は消した。`claude-bedrock-setup.ps1` にもともとある `-Sso` と試験は、ゲートウェイの依頼とは別の既存機能なので残した（外す指示は無い）。
- 共通設定の引き継ぎ（Open Question だったもの）を、ユーザーの「お手軽にできるなら」で実装した: `claude-gateway-setup.ps1` が `~/.claude/settings.json` の `theme`、`permissions`、`hooks`、`enabledPlugins`、`extraKnownMarketplaces` を、ゲートウェイの `settings.json` に写す（作成時点の写し）。`apiKeyHelper`・`env`・`model` は写さない。`skills` と `CLAUDE.md` は写さない。試験3項目を追加し、失敗0。リンクにしなかったのは、settings は合成されず、1ファイルにゲートウェイの値を混ぜる必要があるため（`decisions.md` の同項）。
- 無音更新の実機確認が完了した（ユーザーの報告）: サインインの1時間後も接続が続いた。「この PC に `~/.claude-gateway` が無い」の項は、PC2 にゲートウェイ接続が無い（使わない）ため、省略とした。
- 他の PC での展開（`30_link.bat`、`claude-gateway-setup.cmd`、`claude-gateway-token.cmd -Login`）は、ユーザーが完了と報告した。

### 2026-10-20（Claude Code と Zed を、組織の OIDC ゲートウェイにつないだ。AWS SSO と Claude apps gateway の案は取り消した）

- ユーザーの依頼は「Zed の ACP エージェントと、`claude-pick` を使う Claude Code に、SSO の接続を足す」。接続先の種類が分からないまま進め、2回作り直した。(1) AWS の IAM Identity Center（`bedrock-sso`、`fb99d58`）。案内の URL が `awsapps.com/start` ではなく、AWS SSO でないと分かり、`84e4471` で取り消した。(2) Anthropic の Claude apps gateway（`/login` の Cloud gateway、`9fc2aaf`）。ゲートウェイの名前解決の結果が公開アドレスで、`gateway hosts must be on your organization's private network` で拒否された。(3) 汎用の LLM ゲートウェイ + Entra ID の OIDC（Claude Desktop の「Configure Third-Party Inference」と同じ構成）だった。
- 最終の実装（`8a180be`）: `claude-gateway-setup.cmd`（URL・発行者 URL・クライアント ID・スコープ・リダイレクトポート・モデル ID をプロンプトで入力し、`%USERPROFILE%\.claude-gateway\` に書く。値は dotfiles に置かない）、`claude-gateway-token.ps1` / `.cmd`（`apiKeyHelper`。`-Login` でブラウザの認可コード + PKCE のサインイン、トークンは DPAPI で暗号化、期限が近ければリフレッシュトークンで無音更新）、`claude-gateway` と `claude-pick gateway`（`CLAUDE_CONFIG_DIR` を分けて起動）、Zed の「Claude Gateway」（`claude-acp-gateway.ps1` / `.cmd`）。判断は `decisions.md`（【この件】組織の LLM ゲートウェイ）。
- 確認: ユーザーが実機で、CLI の `claude-gateway` と Zed の「Claude Gateway」の両方が接続できたと報告。試験4本が失敗0（`test_claude_gateway_token.ps1` 29項目＝偽の IdP を使う、`test_claude_gateway_setup.ps1` 25項目、`test_claude_launchers.ps1` 21項目、`test_claude_bedrock_setup.ps1` 26項目）。試験で `$LASTEXITCODE` の不具合（成功経路が `exit` しない）を見つけて直した。
- `pause`: ユーザーの求め（`.bat` に `pause`）に対し、`claude-gateway-token.cmd` の末尾に入れると `apiKeyHelper` が待ち続けて出力も壊れることを実測した。対話専用の入口だけに入れる形にした（`Open Questions` の提案。未承認）。
- 続けて、ユーザーの求めで「ナレッジ化して」を実行（`exmem/inbox/2026-10-20-claude-code-oidc-gateway.md`。未追跡のまま）と、理解ガイド `guides/explain/llm-gateway-oidc.md` を workbase に作成（索引 `guides/guides-index.md` も更新）。
- 未確認: サインインの約1時間後の自動更新（CLI と Zed）。他の PC での展開。

### 2026-10-18（WSL へ `WORKS_DIR` と `CERTS_DIR` が渡らない原因を直した）

- 2026-10-06 から未特定だった原因は、`WSLENV` の区切りが `;` だったこと。`scripts/windows/10_env.bat` を `:` に直し、この PC の User の `WSLENV` を `CERTS_DIR/p:WORKS_DIR/p` にした。`wsl --shutdown` の後、`printenv WORKS_DIR CERTS_DIR` が rc=0 で両方を返した。判断は `docs/decisions.md`（【汎用】`WSLENV` の区切りは `:`）。他の PC は `10_env.bat` の再実行で直る（未確認）。同日のログインシェルで `GHQ_ROOT` は空だった（未調査）。

### 2026-10-16（`docs/setup/` のリンク確認を完了とした）

- `DESKTOP-C7JJ83A` で、`docs/setup/` の手順書間のリンクと、手順書が挙げるリポジトリ内のパス（`scripts/`、`manifests/`、`home/`、`windows/powershell/` の各ファイル）が実在することを確認した。`main` は `origin/main` と一致。https の外部リンクは開いていない。ユーザーが完了と確認し、`log.md` の項を消した。
- 続けて、ユーザーが「dotfiles 側の課題」の未対応3件（`chsh` 後の再ログインの案内、`50_repos.sh` の前提、MX Linux 実機での `20_packages.sh` / `23_ja.sh` の確認）を完了と確認し、`log.md` の項を消した。
### 2026-10-16（手順書3本を workbase から `docs/setup/` へ移した）

- `win11.md`・`debian-family.md`・`fonts-setup.md` を、workbase の `guides/howto/` から `docs/setup/` へ移した（dotfiles-boundary の決定。移動先と、書式規則も dotfiles へ移すことはユーザーの決定）。書式・文体の規則は workbase の `guides/AGENTS.md` に1か所だけ残し（`guides/howto/` に dotfiles に依存しない手順書が残るため。ユーザーの決定）、`docs/setup/README.md` には dotfiles 固有の規則と参照だけを置いた。
- 付録「dotfiles 側の課題」は削除した（同じリポジトリで直せるため）。「解消済み」は消し、未対応の3件を `log.md` の Next Actions へ移した。本文は、「dotfiles が正」の言い方を「このリポジトリが正」に、`fonts.md` を `fonts-setup.md` のリンクに直した。
- README（ディレクトリの表、Linux の手順書の参照、「exmem との関係」の手順書の行）と `decisions.md` の手順書の参照を `docs/setup/` に直した。`decisions.md` の 2026-10-06 の経緯の項は履歴なので変えていない。
- workbase 側（topics/dotfiles-boundary/）は同日に完了して削除した。dotfiles に関わる変更: exmem の pc-setup-manuals.md にあった scripts/wsl → scripts/linux の改名の決定を decisions.md に移した（6973408）。exmem の pc-setup-manuals.md と zed-dotfiles.md は割り、ほか約19ノートの dotfiles の実物の写しは、dotfiles が正という指し先に置き換えた。履歴の種の正本は、割らずに exmem のまま（ユーザーの決定）。dotfiles → workbase の一方向の規則は、app-config-placement.md とワークスペースのルートの AGENTS.md に書いた。
### 2026-10-16（dotfiles を公開で確定。実機確認の項目を完了として整理した）

- ユーザーが完了と確認した項目を `log.md` から消した: 他PCでの確認（`30_link` の再実行ほか）、Claude Code の設定ファイル改名の移行、Bedrock（`n1-trial`、`claude-bedrock-setup`）、AWS CLI・uv・Volta のインストーラ、Windows Terminal の WSL プロファイル、`.reg` / `.ahk` の `git status`、Claudian の入力欄パッチの試用、会社 PC の git の schannel（他PCでの確認に含まれるものとして整理）。
- リポジトリの公開・非公開を、公開で確定（ユーザーの決定。`gh repo view` で PUBLIC を確認）。README のクイックスタート（Windows の注記、Linux の B と未確認の注記）と、workbase の手順書 `win11.md`（手順 5）・`debian-family.md`（手順 7 と手順 10 の注記）から、非公開向けの記述を削除した。`decisions.md` の該当項に確定を追記。
- 残り: 外部スキルの取り込み前チェックの運用（案の段階）、`docs/setup/`（dotfiles-boundary が正本）。
- 続けて、ユーザーが「上に無い古い確認項目」と「古い Open Questions」を完了と確認し、`log.md` のポインタを消した（原文はこの下の 2026-10-16 の項に残る）。`docs/setup/` の移動は別セッションで進める。
- `windows/notepadpp/Gruvbox dark medium.xml` の index を CRLF から LF にそろえた（`git add --renormalize`。ユーザーの決定。根拠は `decisions.md` の `.reg` / `.ahk` の改行の項）。Open Questions が空になった。

### 2026-10-16（log.md の Next Actions を実状に合わせて整理した）

- 並行作業で済んでいた項目を `log.md` から消した: 未 push のコミットの一覧（rebase でハッシュが変わり一致しないため、ユーザーが完了と判断。旧一覧は `cc20299` `71e326d` `000125e` `a404711` `293c0a3` `3ed784e` `2ef40d4` と resources の7件）、colored-tags の `data.json` の試用（完了。追跡から外したまま続ける。期日の節も空になったので削除）、defuddle / knap の他PCへの展開（ユーザーが完了と確認）、`windows/README.md` の末尾の空行（削除）。
- `ListView` の見送りを撤回（ユーザーの決定）。`decisions.md` のシェルの項に「撤回済み」と書き、`log.md` の Open Questions から消した。
- `docs/setup/` の置き場の整合: dotfiles に `docs/setup/` は無く、resources の `topics/dotfiles-boundary/` の案は未着手（そのトピックの `docs/log.md` で 2026-10-15 時点）。確認の結果、食い違いは無く、進捗はトピック側が正本として `log.md` に1行の指し先だけ残した。

### 2026-10-16（exmem の旧名の参照を直した。works への依存の整理の一部）

- `AGENTS.md` `README.md` `windows/README.md` `docs/decisions.md` の現在形の参照を、新名に直した（`knowledge/` → `lessons/`、廃止した `contexts/` を削除、`cheatsheets/env/` → `guides/howto/`、`knowledge-hook.md` → `stock-hook.md`）。`decisions.md` の `links.map` と `30_link` の順序の記述（`notes` `NOTES_DIR`）を現状に直した。日付つきの履歴は、`hooks.md` の読み替え規則に従い書き換えていない。コミット `3ed784e` `2ef40d4`。方針は works の `docs/decisions.md` の先頭の項。

### 2026-10-16（3 リポジトリの規則を揃えた。README を分割し、AGENTS.md を kit にそろえた）

- works・resources・dotfiles の規則を揃える作業の一部。dotfiles の変更: README の旧名参照（`knowledge-hook.md` → `stock-hook.md`、`cheatsheets/env/` → `guides/howto/`。`cc20299`）。`AGENTS.md` に、コミット・push の前に `docs-rules.md` を読む導線、push の方針、rebase の禁止（ユーザーの決定。`71e326d`）。`docs-rules.md` を読む時機の統一（`000125e`）。`docs/log.md` を 17.9KB から 3.8KB に縮め、原文を下の項へ移した（`a404711`）。README を 34.8KB から 16KB に縮め、詳細を原文のまま下位の README に移し、履歴リセットは `decisions.md` の Facts に移した。`AGENTS.md` の読む順番を README → `docs/log.md` にそろえた（ユーザーの決定。`293c0a3`）。階層化の規則（上段は表引き、下段に詳細）は、kit の `docs-rules.md` に追加した。

### 2026-10-16（log.md を縮めるために、Next Actions と Open Questions の原文を移した）

- `log.md` が 17.9KB（目安 4KB）になったため、下の原文を移した。`log.md` に残したのは、10-07 以降で実機確認が要る項を圧縮した版。移した時点で完了とみなした項: Claude Code の API キー認証（10-08）、Zed の最適化の後始末（10-04）。下は原文のまま（旧パス・旧名もそのまま）。

## Next Actions

- colored-tags の `data.json` を追跡から外す試用の判断（2026-10-15 から1週間。2026-10-22 頃。判断は `docs/decisions.md` の先頭の項目）: 色の食い違いや不便が無ければ続ける。戻すなら `.gitignore` の行を消して `git add` する。他PCでは `git pull` の前に、`data.json` に未コミットの変更があれば退避する（追跡削除の pull で上書きの衝突になる）。pull 後もファイルは残る想定だが、消えたら Obsidian が作り直す。
- obsidian-skills と defuddle / knap の他PCへの展開（2026-10-14。家・会社の各 PC）: `git pull` のあと、`27_volta.bat` → `28_npm_globals.bat` → `29_claude_plugins.bat` を実行する（23_claude と Volta が前提）。`knap --version` と `/skills` で6つが見えることを確認する。`knap` は試用で、不要なら `manifests/npm.txt` の2行を削除して `volta uninstall knap`。
- 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（2026-10-14。案の段階。決まれば `docs/decisions.md` の外部スキルの項に足す）。
- Claudian の入力欄パッチ（2026-10-12）の試用: 使って見た目・Enter の挙動（箇条書きの継続、空の項目で抜ける）に問題が無いか確認する。続けるなら、プラグインの更新で `main.js` が上書きされるため、パッチの当て直し手順を `docs/decisions.md` かこのファイルに残す。戻すなら、`windows/obsidian/.obsidian/plugins/realclaudian/main.js` `styles.css` を、パッチ前のコミットに `git checkout <パッチ前のコミット> -- <パス>` で戻す。
- Claude 用の AWS profile `n1-trial` の実機の作成（2026-10-11。家・会社の各 PC。このPCも未実施）: `git pull` のあと、`aws configure sso`（または `aws configure --profile n1-trial`）で profile を作る。SSO なら `aws sso login --profile n1-trial`。`claude-bedrock-setup.cmd -AwsProfile n1-trial` で `settings-bedrock.json` を作り直し、`claude-bedrock` と Zed の `Claude Bedrock` の起動を確認する。`default` の profile を作っていた PC は、不要なら削除する。あわせて `settings-bedrock.txt` ができること、その全文を works の Claudian の Bedrock スニペット（`.claudian/claudian-settings.json`）へ貼れること（複数行の保存を含む）を確認する（2026-10-11 に出力を追加。AWS 実機では未実行）。
- Claude Code の設定ファイルの改名（2026-10-11）に伴う実機の移行（家・会社の各 PC。このPCも未実施）: `git pull` → `30_link.bat` を再実行（`settings-api.json` のリンクができる）→ `%USERPROFILE%\.claude\` の旧 `api.settings.json`（リンク）を手で削除。暗号化済みのキーは `api-key.dpapi` を `settings-api-key.dpapi` に改名する（または `claude-api-key.cmd -Set` で保存し直す）。これをしないと `claude-api` が「キー無し」で止まる。Bedrock は `claude-bedrock-setup.cmd` を再実行して `settings-bedrock.json` を作り、旧 `bedrock.settings.json` を削除する。その後 `claude-api` と `claude-bedrock` の起動を確認する。
- AWS CLI・uv・Volta のインストーラ（2026-10-10 時点。コミット済みなら push 済みか確認）: 実機で `25_awscli.bat` `26_uv.bat` `27_volta.bat` を実行し、各 `--version`、`python --version`、`node` / `npm` / `npx` の版、PATH の再読込、`awscli.amazonaws.com/v2/install.ps1` の URL を確認する。`ca_bundle.crt` を `%USERPROFILE%\.certs` に置いた PC で `y` を試し、`setx` の値を確認する。Windows の `python` が Microsoft Store のスタブに先に当たらないかも見る。`10_env.bat` の最後の案内（オレンジ）の表示は未確認（実行すると `setx` が動く）。
- 会社 PC で git の schannel を確認する（2026-10-10）: `git -c http.sslBackend=schannel ls-remote https://github.com/yuzucha16/dotfiles HEAD`。`CRYPT_E_NO_REVOCATION_CHECK` が出たら、`~\.gitconfig_local` の `[http]` に `schannelCheckRevoke = false` を足す。
- Claude Code の Bedrock 版（2026-10-08 時点）: AWS CLI を入れた PC で `30_link.bat` を再実行（`links.map` に2行追加）し、`claude-bedrock-setup.cmd` で一覧の取得と設定の生成、`claude-bedrock` の起動と `/status` を実機で確認する。`aws bedrock list-inference-profiles` の出力の形が想定と違えば、`Get-InferenceProfileIds` と試験の偽の `aws` を直す。
- Claude Code の API キー認証（2026-10-08 時点）: `claude-api` の起動と `/status` は確認済み（`Auth token: apiKeyHelper`。claude.ai connectors の警告は仕様どおり）。`claude` 単独の OAuth ログイン（Pro）と `GET /v1/models` の取得も確認済みで、`model` は Sonnet 5.5 に決定。Opus と Haiku のピンも今のままで決定。他PCでは、キーを保存し直す（暗号化ファイルは PC ごと）。
- Claude Code と Zed のスレッド復元（2026-10-07）の後始末: 数日使って問題が無ければ、バックアップ（`~\.claude\projects_backup_20261007`、`projects_backup_20261007b`、`~\.claude\zed-fix\zed-db-backup-*`）と、旧ディレクトリ `~\.claude\projects\C--vault-*` の重複を削除する。`.obsidian`（2本）、`vault_ee`（2本）、`exmem` に寄せた11本が実際に開けるかも確認する。Zed の Codex のスレッド（31件）が、旧パスで失敗するかを確認する。
- `~\.claude\settings.json` の許可ルール `Bash(git -C * status *)` などが、`claude` の起動のたびに警告を出す（2026-10-07。`*` が `git -C` の直後にあるため）。`git -C <パス>` を許す形に直すかを、ユーザーに確認してから決める（dotfiles の `home/.claude/settings.json` がリンク元のはず。未確認）。
- Windows Terminal の WSL プロファイル（2026-10-14 に更新）: `disabledProfileSources` に `Microsoft.WSL` を足し、`Ubuntu-24.04` だけ固定プロファイルにした（`452067b`）。この PC では、Terminal を開き直しても差分は出なかった。他PCでは `git pull` のあと、Terminal を開いて、メニューが PowerShell・CMD・Ubuntu-24.04 になり、`settings.json` に差分が出ないことを確認する。WSL のディストリビューションを足しても、Terminal には出ない（AI 作業部屋へは `room-sh <Area>` で入る）。
- 他PCでは `git pull` のあと、`.reg` / `.ahk`（`.gitattributes` の変更）と Terminal の `settings.json`（改行の正規化）の `git status` が clean か確認する（2026-10-07。作業ツリーが LF のまま残っていると差分に見える場合は、`git add --renormalize` か取り直しが要る）。
- `10_env.bat` を再実行して、`%USERPROFILE%\.certs` ができること、`CERTS_DIR` と `WSLENV`（`CERTS_DIR/p` が1回だけ）が更新されることを確認する。新しいターミナルと新しい WSL セッション（`wsl --shutdown` のあと）で、`$CERTS_DIR` が `/mnt/c/Users/<名前>/.certs` になり、`ca_bundle.crt`（旧 `company-ca.crt`）があれば `NODE_EXTRA_CA_CERTS` が設定されることを確認する。旧 `works\areas\dev-env\certs`（空）は、確認後に削除する（2026-10-06 時点）。
- 履歴の種の `git config --global user.name` / `user.email`（`windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt` の各2行）を見直す。`~/.gitconfig` は `30_link` が張る symlink なので、リンク後に実行すると、リポジトリ内の `home/.gitconfig` が書き換わる。種の正本は exmem の `knowledge/shell-command-usecases.md` で、種ファイルは派生物なので、直すのは正本の統合のあと（種を直接編集しない。2026-10-06 時点）。
- VC++ ランタイムの `[WARN]`（ランタイムが無いとき）の表示を確認する。新アカウントでは `[Installed]` 側しか出ず、`[WARN]` 側は実機で未確認（2026-10-06 時点。ランタイムが無い環境でだけ出る。判断基準は `docs/decisions.md` の「vcredist2022 は自動導入せず…」）。
- Zed の最適化（2026-10-04）の後始末: Zed を再起動して、テーマ・Ctrl+Enter 送信・右のプロジェクトパネル・Markdown の見え方を確認する。Vim オフの試験は 2026-10-11 頃に続けるか判断する（戻し方は `settings.json` のコメント）。他のPCでは `30_link.bat` の前に、空の `%APPDATA%\zed\themes` を削除する。WSL で点滅を止めるのは `.bashrc` / `.zshrc`（反映は新しいシェルで確認）。OS 全体の点滅停止（`CursorBlinkRate=-1`）は必要なら検討する。
- シェルの3シェル共通化（fzf とキーバインドの現仕様の表は `docs/decisions.md` の Facts）:
  - WSL に `ghq` を入れたら `cdg`（zsh/bash）を実機で確認する。
  - その他、3シェルの差を洗い出して共通化する。
- ヒストリの種を進める。方針と種の本文（正本）は exmem の `knowledge/shell-command-usecases.md`。種ファイル `windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt`、配置スクリプト `scripts/{windows,linux}/31_history_seed.*` は作成・検証済み。Windows の `31_history_seed.bat` は、新アカウントの実機で通し済み（2026-10-06、ユーザー報告）。残り: Linux（zsh/bash）の `31_history_seed.sh` を新しいPCで通し実行、数週間使って間引き（置換した apt などの行を優先して見直す）。
- GitHub の既定ブランチを `main` にし、問題が無ければ `202509` をリモート・ローカルで削除する（ユーザーの確認待ち）。
- 各PC（家・会社）で `git pull` → Windows は `30_link.bat`（家は `link home`）、Linux/WSL は `30_link.sh` を再実行する。新しいシェルで zsh の `lt` / `ll` / `l`、`cdg` を確認する。
- このPCで `.wslconfig` を反映する: `30_link.bat` → `wsl --shutdown` → 開き直して `vmmemWSL` を観察する。
- 未 push のコミットを push する（Zed の最適化の `[zed]` `[shell]` は push 済み。残りは 2026-10-04 の `[docs]` 分と `terminal.shell` 削除の `[zed]`。整理分の内訳:`22_python` 削除、starship、Zed 拡張、VS Code 削除、Notepad++ の雛形方式、light テーマ削除）。starship と zed のコミットには、別件の削除が混ざっている（`docs/decisions.md` の Gotchas）。分け直すかは任意。
- 古い Notepad++ のリンク切れ（`stylers.xml` `contextMenu.xml` `NppExec.ini`、`themes\Gruvbox light medium.xml`）と `~/vimfiles` の旧プラグイン（`:PlugClean`）を掃除する。実機に残る scoop の VS Code（`scoop uninstall vscode`、`scoop\persist\vscode` 内のリンク）も、不要なら手で消す。
- `scripts/linux/30_link.sh` にある旧 `.vscode-server/extensions/extensions.txt` の掃除行を、消すか判断する。
- 参照用に退避した他PCの生ヒストリ（`works/resources/_local/ConsoleHost_history.txt`。Git 対象外）は、使い終わったら削除する。
- 新しいPC（または VM）に Linux を入れ、`10` → `50` を通し実行して、手順書（`works/resources/cheatsheets/env/debian-family.md`）どおり進むか確認する。MX Linux 25.3 の「要確認」を潰す。非公開リポジトリの手順 B（`gh auth login` から clone まで）もここで確認する。
- `24_fonts.sh`（Linux）で、実際にダウンロードしてフォントを入れる（Windows の `24_fonts.bat` は 2026-10-06 に実機で確認済み）。1週間使って「Light で続ける / Text に上げる / HackGen に戻す」を決める（メインフォントは PlemolJP Console NF の Light を試用中。Zed・Windows Terminal・Notepad++ に反映済み）。
- `30_link.sh` の最後に `chsh` 後の再ログインの案内を足す。`50_repos.sh` の前提（`source ~/.profile`、`ghq` が PATH にある）を整理する。`50_repos.bat` に取得したいリポジトリを足す。
- `git bundle` のバックアップの所在を確認する（見つからない）。必要なら保管場所を決める。
- 古い WSL では `fdfind` → `fd` のリンクが無いので、`20_packages.sh` を再実行するか手でリンクを張る。

- 実機の WSL で、新しいターミナルを開いて `10_env.bat` の実行後の状態を確認する（2026-10-06 時点）: `echo $WORKS_DIR $GHQ_ROOT`（`/mnt/c/Users/<名前>/works` と `~/works/repos`）、`cmd.exe /c echo %WSLENV%`（`WORKS_DIR/p` と `CERTS_DIR/p` が1回ずつ）。既存の WSL の `~/vault`（旧 `GHQ_ROOT`）は動かしていない。`mv ~/vault ~/works` で移すか決める。
- ネイティブ Linux の実機で、`30_link.sh`（`.obsidian` の symlink）と `50_repos.sh`（`workbase` の clone）、`WORKS_DIR` の既定値（`~/works`。2026-10-06 に `~/vault/works` から変更）を通して確認する。WSL では、一時ディレクトリで試験済み（2026-10-05）。ネイティブの分岐は、`PROC_VERSION_FILE` の差し替えで再現しただけ。

## Open Questions

- `windows/notepadpp/Gruvbox dark medium.xml` の改行（index が CRLF）を LF にそろえるか。Notepad++ が保存時に CRLF へ書き直すかが未確認（2026-10-07）。`windows/office/*.exportedUI` は意図的に `-text` なので対象外。
- dotfiles のリポジトリを公開にするか非公開にするか（未定。2026-10-06 時点は非公開）。決まったら、README のクイックスタート（Windows・Linux）と、workbase の手順書 `win11.md` の手順 5・`debian-family.md` の手順 7 から、使わない方の記述を削除する。



- 実機の通し実行が未確認: `20_packages.sh`、`40_wsl_enable.bat`、`50_repos.sh`、`unlink` の実動作（ドライランのみ確認）。`10_env.bat` / `20_apps.bat` / `50_repos.bat` は、2026-10-06 に新アカウントの Windows で確認済み。処理は旧スクリプトと同じ文字列置換・統合なので挙動は同じと推定（仮説）。
- `.wslconfig` を WSL が読むか、`vmmemWSL` が縮むか。**このPCではまだリンクされていない**（2026-10-03 確認）。
- GitHub の既定ブランチが `main` か。リモートには `main`（`e1e4ac7`）と `202509` の両方がある（2026-10-03 確認）。ローカルの `origin/HEAD` は `202509` を指している。
- 家・会社のPCで、新構成への再同期後の動作（未確認）。
- `git bundle` のバックアップ（約40 MB）が、`C:\vault\backup\dotfiles-before-rebuild-20261002-235045.bundle` に**見つからない**（2026-10-03 確認）。
- 古いコミットが GitHub に SHA 指定で一定期間残る可能性がある（HackGen は OFL、機密無し）。完全に消すには GitHub サポートへの依頼が必要。
- `stylers.xml` の Gruvbox 以外の独自カスタマイズの有無（`git show` で履歴から復元できる）。`NppExec.ini` の `pandoc_preview` 登録は失われた。
- pwsh の `PSReadLine`（`ListView` 予測表示）のコストは未計測。
- 「`ListView` は重い可能性があるが見送り」（`docs/decisions.md` のシェルの項）と、現在の `profile.ps1:19` が `ListView` を設定していることが食い違う。見送りを撤回したのか未確認。`ListView` の件数は PSReadLine 2.4.5 で設定項目が無く、10件固定のはず（ソース未確認、記憶による）。
- pwsh の `Ctrl+R` の候補は、履歴ファイルの行ごとになる。複数行のコマンドは履歴ファイルでは行ごとに分かれているため、複数行コマンドの全体は選べない。
- `templates/claude/settings.sandbox.json` の用途（使い捨ての検証環境に手でコピーする）は README に書いたが推測。
- 他PCに残る旧構成のリンクやファイル（`setx` で作った旧環境変数、旧 Go、旧 vim プラグインなど）の整理。
- 固有ツールが増えたときの一の位の割り当て順。`21` と `22` は削除で欠番になった（再利用するか、詰めずに空けておくか）。
- `w0` 系に残る日本語コメント。
- `windows/` 配下のアプリ状態ファイルの追跡範囲。Notepad++ は Gruvbox dark と `config.min.xml` に絞った（2026-10-04）。他のアプリは見直していない。
- Zed の Linux デスクトップ導入時の `links.map` 側の対応。
- Zed の `tool_permissions` のパターン（`.env`・鍵ファイルの編集禁止、`git reset --hard` などの確認）が、claude-acp のツール名と一致して実際に効くか（未確認）。`default: "allow"` で承認を Claude Code に一本化した運用感。
- `ESC[2 q`（点滅なしカーソル）が Windows Terminal の pwsh と WSL で効くか（zsh の `precmd` 方式は、点滅が出ていた報告のあとに直したが再確認していない）。
- claude-acp の `default_config_options.mode: "plan"` を入れた意図（新しいセッションが常にプランモードで始まる）。
- エージェントパネルのスレッドをタブにする設定は無い（`agent.threads_sidebar` は位置と自動表示のみ）。


### 2026-10-14（AI 作業部屋のために、Zed の WSL 接続と Terminal のプロファイルを足し、Terminal は部屋を出さない形に直した）

- AI 作業部屋（`resources` の `mobile-session/ai-workspace-boundary/`）の実機確認の途中で、Zed の `wsl_connections`（`ai-room-test`）と Windows Terminal の WSL プロファイル 2 件（`ai-room-test`、`room-office-admin`）が自動で書き足された。コミットした（`b621cd1`）あと、ユーザーが「部屋を作るたびに差分が出るのは困る。pwsh のプロファイルが選べなくなるのも困る。`Ubuntu-24.04` だけ残したい」と述べた。
- Terminal の `disabledProfileSources` に `Microsoft.WSL` を足し（旧方式の `Windows.Terminal.Wsl` は既にあったが、新しい WSL の方式は別名）、`Ubuntu-24.04` を固定プロファイル（`wsl.exe -d Ubuntu-24.04`、guid は同じ）にし、部屋の 2 件を削除した。`windows/powershell/profile.ps1` に `room-sh <Area>`（`wsl.exe -d room-<Area>`）を足した（`452067b`）。Terminal を閉じてから編集した。
- 確認済み（ユーザーの実機）: Terminal のメニューが PowerShell・CMD・Ubuntu-24.04 になり、`Ctrl+Shift+3` で Ubuntu が開く。`settings.json` に差分が出ない。`room-sh office-admin` で部屋に入れる。判断は `docs/decisions.md` の先頭の項目。
- 含めなかった差分: `colored-tags/data.json`（タグ `security` の色。Obsidian の自動更新）。

### 2026-10-15（colored-tags の data.json を追跡から外した）

- 原因: `data.json` の中身はほぼ `knownTags`（タグ → パレット番号の台帳）で、プラグインがタグの増減に応じて自動で書き換え、番号は出現順に振る。複数 PC で番号が衝突し、diff が頻発する。プラグインのソースは未確認（diff と `tagColors` が空であることからの推測）。
- ユーザーの決定: タグが100個近く、色を固定しても覚えられず価値が低いので、`.gitignore` に入れて追跡から外す（案3）。1週間の試用。色は PC ごとに独立になる。案2（`tagColors` で固定）、案4（clean フィルタ）は見送り。

### 2026-10-14（obsidian-skills と defuddle の自動導入を足した）

- ユーザーの依頼で、`/plugin marketplace add kepano/obsidian-skills` と `/plugin install obsidian@obsidian-skills`、`npm install -g defuddle` を dotfiles の自動導入にした。`manifests/npm.txt` + `scripts/windows/28_npm_globals.bat`（`volta install`。Volta の shim 管理に載せるため `npm -g` は使わない）と、`manifests/claude-plugins.txt` + `scripts/windows/29_claude_plugins.bat`（`claude plugin marketplace add` / `install`）。ユーザーの選択: CLI 方式（settings.json の宣言は不採用）、Windows のみ（Linux/WSL は対象外）。
- 確認: `claude plugin --help` で CLI を確認。`29` は誤って実環境の `claude` を呼び、`obsidian@obsidian-skills` が user スコープで実際に導入された（成功）。`28` は偽の `volta` で `volta install defuddle` の呼び出しを確認。試験スクリプトは未追加。
- ユーザーの実機の確認（報告）: `28_npm_globals.bat` と `29` の導入は正常完了。`/skills` に6つが `locked by plugin` で並び、Claudian でも `obsidian-markdown`、`defuddle` と `knap` の連携を使えた。ユーザーの指示で `knap` を `manifests/npm.txt` に足した（試用。コミット `23e995b`）。
- 改善（ユーザーの承認「.batははまりやすいので改善案いれましょう」）: `29_claude_plugins.bat` が `PATH` の先頭に `~\.local\bin` を足していたため、偽の `claude` の試験で本物が呼ばれた。`claude` が PATH に無いときだけ末尾に足す形に直し、`tests/windows/test_28_29_installers.ps1`（5項目、failures=0）を追加した。`.bat` の点検の順序は `docs/decisions.md` の Gotchas。`test_20_apps.ps1` も failures=0（ASCII の確認を含む）。
- `home/.claude/settings.json` に、`claude plugin install` が書いた `enabledPlugins` と `extraKnownMarketplaces` が入っていた（リンク先が dotfiles のため）。ユーザーの決定（A）で、CLI 方式と設定の宣言の併用にし、2キーをコミットした。`theme` の位置は元に戻した。判断は `docs/decisions.md` の外部スキルの項。
- 外部スキルの取り込み方（スキル本体は写さない、導入の宣言は `claude-plugins.txt`、使い分けは使う側の `AGENTS.md`）を `docs/decisions.md` に決定として書いた（`f48f89f`）。`works/AGENTS.md` にも Obsidian 作業用のスキルの1項目を足した（works 側のコミット `fa2bafc`）。

### 2026-10-12（Claudian の入力欄に、Markdown の色付けと Enter の自動インデントを足した。試用）

- ユーザーの依頼で、Obsidian の Claudian（v2.3.16）のチャット入力欄を、Zed のように見出しの色付け・自動インデントが効く状態にした。調査: 入力欄は textarea ではなく CodeMirror 6（`claudian-composer-editor`）で、Markdown 言語・ハイライト・インデント引き継ぎが未導入（`main.js` を grep して確認）。Obsidian は Markdown 言語を公開していないため、`windows/obsidian/.obsidian/plugins/realclaudian/main.js` の `EditorState.create` の extensions に、行ごとの正規表現による装飾（見出し、箇条書きの記号、インラインコード、`**強調**`、コードフェンス）と、Enter で箇条書き・インデントを引き継ぐコマンドを直接足した。`styles.css` に色のクラス、`snippets/material-gruvbox-bold.css` に見出し（`#A7B85A`）・強調（`--bold-color`）の色を足し、markdown ビューにそろえた。言語ごとのコードの色付けは、パーサーが無いので不可。確認: `node --check main.js` は通過。ユーザーが Obsidian で表示を見て、見出し・箇条書き・コードの色が付くことを確認した（スクリーンショット）。Enter の挙動は未確認。プラグインの更新で上書きされる。

### 2026-10-12（Claudian のチャットの見出し・強調の色を、markdown ビューにそろえた）

- ユーザーの依頼で、Obsidian の Claudian（AI エージェント）のチャットの見出しがオレンジ・赤、強調がオレンジで、markdown ビュー（見出しは緑）と違っていたのを直した。原因は、既存のスニペット `material-gruvbox-bold.css` が `.markdown-rendered` と `.cm-*` にしか効かず、チャット本文（`.claudian-message-content`）に当たっていなかったこと。同スニペットに `.theme-dark .claudian-message-content` の見出し h1〜h6（`#A7B85A`、`!important`）と強調 `strong` / `b`（テーマの `--bold-color`、`font-weight: 500`）を足した。ダークテーマ限定。確認: Obsidian を再起動して、左（Claudian）と右（markdown ビュー）の見出し・強調の色が一致した（ユーザーの報告とスクリーンショット）。再起動前は反映されず、原因は再起動の漏れだった。

### 2026-10-11（`claude-bedrock-setup` に、貼り付け用の `settings-bedrock.txt` の出力を足した）

- ユーザーの依頼（Claudian のスニペットと `settings-bedrock.json` の値の二重管理を避けたい。正は `.json`、`.txt` は派生物）で、`claude-bedrock-setup.ps1` が `.json` と同じ場所に `settings-bedrock.txt` を書くようにした。中身は `env` ブロックの `KEY=VALUE` の行（LF、BOM なし、コメントなし）で、毎回 `.json` と一緒に上書きする。`-DryRun` は内容を表示するだけ。README（`.md` と `.html`）と試験（2件追加）も合わせた。確認: `pwsh -NoProfile -File tests/windows/test_claude_bedrock_setup.ps1` が 26 件 PASS（偽の `aws`。AWS 実機は未実行）。コミット `c66909c`。
- 背景: works 側の Claudian は、`sharedEnvironmentVariables` を空にして OAuth（`.credentials.json`）を既定にし、Bedrock はスニペットで明示的に選ぶ形にした。スニペットは `--settings` を読めないため、`.txt` を人間が貼る。API キーは Claudian では使わない（複雑になるため。dotfiles の `claude-api` と `apiKeyHelper` で足りる）。

### 2026-10-11（Claude 用の AWS profile 名を `M1-trial` から `n1-trial` に変えた）

- ユーザーの指示で、直前に決めた `M1-trial` を `n1-trial` に変えた（`home/.config/zed/settings.json` の `AWS_PROFILE`、Next Actions、`docs/decisions.md`）。ユーザーは、`M1` が部署名のエイリアスなので公開しても問題ないと確認した。下の項目の `M1-trial` は、変更前の名前として読み替える。profile 名は大文字と小文字を区別するので、実機では `n1-trial`（小文字）で作る。

### 2026-10-11（Claude 用の AWS profile 名を `M1-trial` にした）

- ユーザーの指示で、Zed の `Claude Bedrock` の `AWS_PROFILE` を `default` から `M1-trial` に変えた（`home/.config/zed/settings.json`）。命名はユーザーの方針（部署名-開発案件）で、`default` を将来のほかの AWS 用に空けるため。事前の洗い出しで、コード中の `default` 指定はここだけ、このPCに `~\.aws\config` と生成済みの `settings-bedrock.json` は無いと確認した。試験の仮名（`prof`、`work`）と README のプレースホルダは変更不要。判断は `docs/decisions.md` の「Claude 用の AWS profile 名を `M1-trial` に…」。実機の profile 作成は Next Actions。

### 2026-10-11（Claude Code の設定ファイルの改名）

- ユーザーの指示で、`windows/claude/api.settings.json` を `settings-api.json`、`%USERPROFILE%\.claude\bedrock.settings.json`（生成物）を `settings-bedrock.json`、`%USERPROFILE%\.claude\api-key.dpapi` を `settings-api-key.dpapi` に改名した（`.claude\` で `settings.json` の隣に並べるため）。`links.map`、`profile.ps1`（`claude-api` `claude-bedrock`）、`claude-bedrock-setup.ps1`、`claude-api-key.ps1`、README（md と html）、ルートの `README.md`、試験2本の参照を直した。試験 `test_claude_launchers.ps1` と `test_claude_bedrock_setup.ps1` は失敗0。コミットは `45e0668`（改名だけ）と `c0ebab6`（参照の更新）。過去の `log.md` と `decisions.md` の旧名は履歴として残した（ユーザーの確認）。判断は `docs/decisions.md` の「Claude Code の設定ファイル名を…」。実機の移行（`30_link.bat` の再実行、旧リンクと旧ファイルの削除）は Next Actions。

### 2026-10-10（25〜27 の出力を改善: pause、理由つき SKIP、[ENV] 表示）

- ユーザーの指示で、`25_awscli.bat` `26_uv.bat` `27_volta.bat` を直した。(1) どの終了経路でも `pause` で止まる（終了を `:END` に集約し、`pause` の後に終了コードを返す）。(2) SSL バンドルを設定しない理由を `[SKIP]` で出す（`n` と答えた場合を追加。`CERTS_DIR` 未設定と `ca_bundle.crt` 無しは従来どおり、`AWS_CA_BUNDLE not set` を明記）。(3) 最後に `[ENV]` で、設定した環境変数の名前と値を表示（未設定は `[not set]`。Volta は `VOLTA_HOME` も表示）。試験 `tests/windows/test_25_27_installers.ps1` に pause・SKIP・`[ENV]` の確認を足し、全件 PASS（実機の `setx` は未実行）。3つの方針は exmem の inbox にメモ化した。

### 2026-10-10（CA ファイル名を `ca_bundle.crt` に変更。git は schannel のまま）

- ユーザーの指示で、`company-ca.crt` を `ca_bundle.crt` に改名した（スクリプト、`common.sh`、README、試験。日付つきの過去の記録は書き換えていない）。実機の `%USERPROFILE%\.certs` は空だったので、ファイルの改名は無し。
- git の CA は、いったん `GIT_SSL_CAINFO` にしかけたが、バンドルの完全性を保証できず（git の既定の CA を置き換えるため）、ユーザーの決定で取りやめた。`12_git_ca.bat` は作って削除した。`11_git_identity.bat` の schannel の質問は元のまま（変更なし）。判断は `docs/decisions.md` の schannel の項。
- 未確認: プロキシ下の schannel の失効確認（会社 PC で `git -c http.sslBackend=schannel ls-remote https://github.com/yuzucha16/dotfiles HEAD`）。
### 2026-10-10（AWS CLI・uv・Volta のインストーラを追加した）

- ユーザーの依頼で、`scripts/windows/` に `25_awscli.bat`（`y/N` で確認、入れたら `AWS_CA_BUNDLE`）、`26_uv.bat`（確認なし、`uv python install 3.13 --default` と `pin --global 3.13`、`python --version` を表示、先に SSL の `y/N`）、`27_volta.bat`（scoop、`volta install node@lts`、`node` `npm` `npx` の版を表示、先に SSL の `y/N`）を追加した。`10_env.bat` の最後に、CA バンドルを `%CERTS_DIR%` へ置く案内（オレンジ、英語）を足した。`profile.ps1` の `NODE_EXTRA_CA_CERTS` は削除し、`27_volta.bat` の `setx` に一本化した（ユーザーの決定。WSL の `common.sh` は残す）。
- 決まったこと（ユーザーの承認）: LTS は `node@lts`。インストール直後は絶対パスを使わず、レジストリから PATH を読み直す。CA ファイルが無いときは `y` でも設定しない（`SSL_CERT_FILE` などは存在しないファイルだと HTTPS が全滅するため）。
- 確認: `tests/windows/test_25_27_installers.ps1`（31項目）と `test_20_apps.ps1` が failures=0（偽の `setx` / インストーラ / `uv` / `volta` を使用。実環境の環境変数は不変）。`uv 0.11.32` に `python install --default` と `python pin --global` があることは実機で確認、`scoop` の `volta` は main バケット（2.0.2）にあることを確認。
- 未確認: 実際に各インストーラを走らせた動作（`awscli.amazonaws.com/v2/install.ps1` の URL はユーザー指定のまま未検証）、会社プロキシ下での動作、レジストリからの PATH 再読込（実機）、Volta の開発者モード、`10_env.bat` のオレンジ表示（実行すると `setx` が動くため未実行）。Windows の `python` が Microsoft Store のスタブに先に当たらないか。
- 落とし穴: `Write` で作った `.bat` は LF になり、ラベル（`:ASKYN`）が見つからなくなった。CRLF にして解消（`.gitattributes` は crlf）。偽の `.cmd` を試験で呼ぶには `call` が要る。

### 2026-10-08（起動する認証を選ぶ関数を追加した）

- ユーザーの依頼で、`profile.ps1` に `claude-oauth` と `claude-pick` を追加し、`tests/windows/test_claude_launchers.ps1`（14項目、すべて通る）と、手順書の「起動する認証を選ぶ」の節を足した。判断は `docs/decisions.md` の「Claude Code の起動時に、OAuth / API キー / Bedrock を選ぶ関数…」。実機で未確認: `claude-pick` の fzf、`claude-oauth` 後の `/status`。
### 2026-10-08（Claude Code の Bedrock 利用のセットアップを追加した）

- ユーザーの依頼で、`windows/claude/` に `claude-bedrock-setup.ps1` / `.cmd` を追加し、`links.map` に2行、`profile.ps1` に関数 `claude-bedrock`、`tests/windows/test_claude_bedrock_setup.ps1`（24項目、すべて通る）を足した。手順書（`windows/claude/README.md` と `.html`）に「Bedrock 版」を追加した。実際の AWS での実行は未確認（`aws` 未導入の PC）。判断は `docs/decisions.md` の「Claude Code の Bedrock 利用は…」。
### 2026-10-08（Claude Code の API キー認証を併用できるようにした）

- ユーザーの指示で、`windows/claude/`（`api.settings.json`、`claude-api-key.ps1`、`claude-api-key.cmd`）を追加し、`links.map` に3行、`profile.ps1` に関数 `claude-api` を足した。ダミーのキーでヘルパーの復号と、キー無しのエラー終了を確認した。その後、ユーザーの実機で `30_link.bat` → `claude-api-key.cmd -Set` → `claude-api` の起動と `/status` を確認し、`claude` 単独は OAuth（Pro）、モデルは Sonnet 5.5（Opus と Haiku のピンは現状維持）に決まった。判断は `docs/decisions.md` の「Claude Code の API キー認証は…」。

### 2026-10-08（AI エージェントの導入を整理。Claude Code は公式インストーラに一本化）

- ユーザーの指示で、`manifests/apps.txt` から `claude` / `claude-code` / `chatgpt` を削除し、`claude` と `chatgpt` は `apps.home.txt` にコメントアウトで移した。`apt.txt` の `universal-ctags` / `global` / `gcc-arm-none-eabi` は `apt.desktop.txt` に移した。
- `scripts/windows/23_claude.bat` を新設した。`y/N`（既定 N、無効な入力は5回で `[ERR]`）で聞き、`y` なら `irm https://claude.ai/install.ps1 | iex` を実行する。README の手順 2 に追記。
- `10_env.bat` に、`XDG_BIN_HOME=%USERPROFILE%\.local\bin` の設定（`setx`、ディレクトリ作成）と、ユーザー PATH へ `%XDG_BIN_HOME%` を1回だけ足す処理を追加した（ユーザーの指示。当初は実パスを直接足していたが、他の `XDG_*` と同じ流儀に直した。実パスの既存エントリも「ある」と見なす。`setx` は 1024 文字で切れ、`%VAR%` を展開するため、レジストリの生の値を `ExpandString` で書き戻す）。
- 確認: `tests/windows/test_20_apps.ps1` は failures=0。`23_claude.bat` は空入力と `n` が `[SKIP]` になることを実行して確認。`10_env.bat` の PATH 処理は、このPCで既に登録済みの `[SKIP]` 側だけ確認した。
- 未確認: `y` で実際にインストーラを走らせた動作、PATH が無い PC での `[OK]` 側、`tests/linux/test_scripts.sh`（`apt.txt` 変更後）の再実行。scoop で `claude` / `claude-code` を入れ済みの PC は、手で `scoop uninstall` しないと二重になる。

### 2026-10-07（Claude Code と Zed のスレッドを、`works` の構成で復元した）

- Vault を `C:\vault\works` から `C:\Users\ck\works` へ移したあと、`--resume` で復元できなかったセッション（ユニーク56本。ユーザーの記憶は58本）を、ユーザーの依頼で復元した。Zed のスレッドも開けるようにした。リポジトリのファイルは変えていない（変更先は `~\.claude` と Zed のデータ）。
- 原因は3つ。(1) 54本すべてが SDK 経由（`entrypoint: sdk-ts`）で、`claude --resume` の一覧の対象外（公式ドキュメント）。(2) jsonl の `cwd` と保存先ディレクトリが旧パスのまま。(3) Zed の `db.sqlite` の `sidebar_threads.folder_paths` が旧パスで、開くとエージェントの起動に失敗した（`failed to spawn command`）。
- 直したこと（判断は `docs/decisions.md` の Decisions の「旧パス…のセッションを、`works` の構成に合わせて移行した」）: ① 旧ディレクトリだけにあった20本を、新しいディレクトリへコピーして `cwd` を書き換えた。② コピー済みの30本の `cwd` を書き換えた。③ `entrypoint` を `cli` にした（1本で一覧に出ることを確認してから全件）。④ Zed の `sidebar_threads` の47件の `folder_paths` を更新した（Zed 終了後に自動実行するスクリプト `~\.claude\zed-fix\`）。確認: `claude --resume` の一覧（works と dotfiles）、ID 指定、Zed のスレッド履歴で開けた（ユーザーの報告）。
- 復元できなかったもの: Zed のスレッドのうち、ディスクにセッションが無い5件（9/26〜9/30。2件は ID の無い空のスレッド）。ディスクにあるのは56本で、ユーザーの記憶の58本との差は2本（行き先は不明）。
- 落とし穴（`docs/decisions.md` の Gotchas の3項）: 一覧が空になる原因は `entrypoint`。Zed の中のエージェントは、Zed を閉じると止まるので、終了を待つスクリプトを別プロセスで起動した。`claude` の起動時に許可ルールの警告が出る（未対応。Next Actions）。
- ナレッジ化: `exmem/inbox/` にメモ2本（`2026-10-07-claude-code-resume-sdk-sessions.md`、`2026-10-07-zed-thread-db-folder-paths.md`）。既存の `knowledge/claude-code-storage.md` の「原因不明・解決なし」の記述との食い違いを、メモの Open Questions に書いた。
- 反省: 最初の実行で、削除を含む1つの PowerShell コマンドが、安全装置にブロックされた（何も実行されなかった。分けて再実行した）。
- workflow-kit の改善2点を反映した（ユーザーの承認。版 `2026-10-07.3`）: `closing-hook.md` の手順 2 に、変更先がリポジトリの外だけの作業では、開いた作業ディレクトリの `docs/` を対象にする、と足した。手順 3 に、親の `AGENTS.md` が定める終了処理の追加の手順（指標の記録など）を続けて行う、と足した。記録は kit の `improvements.md` と `README.md` の変更履歴。

### 2026-10-07（Windows Terminal の `settings.json` の差分の解消。`.gitattributes` に `.reg` と `.ahk` を追加）

- WSL を再インストールしたあとに `windows/terminal/settings.json` の差分（約200行）が出た件を、ユーザーの依頼で調べて直した。原因は2つ。(1) index が CRLF のまま残っていたため（`.gitattributes` は LF を正としているのに、`.bat` しか正規化していなかった）。(2) WSL の再インストールで、Terminal が同名の `Ubuntu-24.04` を新しい guid で追加したため。実質の差分は10行だけだった（`git diff --ignore-space-at-eol`）。
- 直したこと（判断と落とし穴は `docs/decisions.md` の Gotchas の2項）: 改行だけを LF にそろえた（`39930cc`）。古い方の WSL プロファイル（`commandline: "wsl.exe -d Ubuntu-24.04"`、guid `963ff2f7…`）を削除した（`3c49d9b`。Terminal が並べ替えた `Terminal.FindText` も含む）。確認: JSON として読める、参照が無い（grep）、`wsl -l -v` で Ubuntu-24.04 は1つ。
- ユーザーの決定で、`.gitattributes` に `*.reg text eol=crlf` と `*.ahk text eol=crlf` を足し、index を LF にした（`cf4a54f`。判断は `docs/decisions.md` の Decisions）。`windows/notepadpp/Gruvbox dark medium.xml` は、index が CRLF のまま未決（Open Questions）。
- 反省: 最初の2コミット（`39930cc`、`3c49d9b`）を、`docs-rules.md` の「コミットの身元」に従わず、ユーザーの名義（`yuzucha16`）で作った。トレーラーも無い。`cf4a54f` からは `agent` 名義とトレーラー付き。履歴は書き換えていない（未 push のため、書き換えるかはユーザーの判断。`rebase` は事前確認が要る）。
- 未確認: Terminal を再起動して、削除した WSL プロファイルが書き戻されないか。再インストールのたびに guid が変わる理由。
- 「終了処理して」の改善2点をユーザーが承認し、workflow-kit を版 `2026-10-07.5` に上げた（変更は `workbase` 側で、dotfiles のコミット対象外）: コミットを分けるときは `git commit` にパスを指定しない、エージェントの身元とトレーラーは作業の途中のコミットにも適用し、終了処理で点検して報告する。`exmem/inbox/2026-10-07-gitattributes-leftover-crlf-index.md` を作った（コミット対象外）。

### 2026-10-06（Vault を `%USERPROFILE%\works` へ移した。Linux 側も `~/works` にそろえた）

- Vault を `C:\vault\works` から `%USERPROFILE%\works` に、ghq の root を `%USERPROFILE%\works\repos` に移した（ユーザーの決定。判断は `docs/decisions.md`）。`10_env.bat`（`VAULT_HOME` を廃止、`WORKS_DIR` を `WSLENV` で WSL へ渡す）、`home/.profile`、`scripts/linux/lib.sh`・`30_link.sh`・`50_repos.sh`、`windows/startup/startup.bat`、`windows/terminal/settings.json`、`tests/`、`AGENTS.md`、`README.md` を直した（コミット `92fd142` `[env]`、`5d59374` `[docs]`）。
- Linux 側も `~/works`、ghq の root を `~/works/repos` にそろえた（ユーザーの指示。`b6c26c9` `[linux]`）。WSL の `GHQ_ROOT` の既定は `~/works/repos`、`10_dirs.sh` は `~/works/{build,tools}`。試験は 51/51 合格（最初は 49/51。`ghq get` のコメントアウトに試験が追随していなかったため、試験を直した）。
- Obsidian が書き換えた `windows/obsidian/.obsidian/plugins/colored-tags/data.json` を、`841672b` `[obsidian]` でコミットした。
- `10_env.bat` の実機の再実行と、新しい WSL セッションでの確認は未実施（Next Actions）。

### 2026-10-06（`clang-format` と `gcc-arm-none-eabi` を、実機（WSL）に導入した）

- ユーザーが、`manifests/apt.txt` に追記した 2 つ（`clang-format` 18.1.3、`gcc-arm-none-eabi` 13.2.1）を、WSL に導入した（ユーザーの報告。`arm-none-eabi-gcc --version` の出力で確認）。`works` の Project が、Cortex-M 向けのフットプリントと libc 非依存の実測に使った（Cortex-M0 で除算の補助関数への依存が出て、M0 を対象外にした。詳細は `works` の `archives/learn-c-pool-allocator/docs/`）。Next Actions の導入待ちの項目を消した。

### 2026-10-06（`gcc-arm-none-eabi` を `manifests/apt.txt` に足した）

- `works` の Project `learn-c-pool-allocator`（組込み向けの C の学習）で、Cortex-M 向けの `.text` `.data` `.bss` の実測と、libc 非依存の確認（ARM 向けのビルドで未定義シンボルが無いこと）を行うため、`manifests/apt.txt` の `# devel` に `gcc-arm-none-eabi` を追記した（ユーザーの承認）。確認: `apt-cache policy` で、Ubuntu 24.04 に `15:13.2.rel1-2`（GCC 13.2）がある。インストールサイズは約 490MB（`Installed-Size: 505199` KB）。`libnewlib-arm-none-eabi` が推奨で、`20_packages.sh` の `apt install -y` は推奨も入れる（今回は freestanding のビルドなので newlib は不要。必要なら `--no-install-recommends`）。実機への導入は、`sudo` にパスワードが要るため、ユーザーが行う。

### 2026-10-06（`clang-format` を `manifests/apt.txt` に足した）

- `works` の Project `learn-c-pool-allocator`（C の学習）で、コードリーディングのコストを抑えるために `clang-format` を使う（ユーザーの指示。一貫性のためではなく、読みやすさのため）。`manifests/apt.txt` の `# devel` に `clang-format` を追記した。`read_list` が行内コメントを除くことを確認した。`bash tests/linux/test_scripts.sh` は 50/50 合格（確認: 2026-10-06、WSL）。実機（WSL）への導入は、`sudo` にパスワードが要るため、ユーザーが `sudo apt install -y clang-format`（または `20_packages.sh`）で行う。`works` 側の詳細は、`projects/learn-c-pool-allocator/docs/dotfiles-additions.md`。

### 2026-10-06（`転記待ち` 20 件を `転記済` に進めた。「inboxを整理して」の最初の実行。kit 版 `2026-10-06.18`）

- この実行で出た改善2点（案の表の形、本文を外す範囲の目安）を、ユーザーが承認し、kit に反映した（版 `2026-10-06.18`、`workbase` の `9567c15`。dotfiles のコミット対象外）。

- exmem の統合（`b70f0d4`。メモ4つを `knowledge/` の `dotfiles-shell-tuning.md`、`windows-cli-pitfalls.md`、`pc-setup-manuals.md`、`obsidian-vault.md` に統合）のあと、`docs/decisions.md` の `転記待ち` 20 件を、統合先の本文と照らして `転記済` に進めた（ユーザーの承認）。確認: 各項目の根拠と却下案が、統合先に写っていること（全件「突き合わせ済み」。「存在の確認のみ」は無し）。汎用の本文を外し、固有の文脈（Principles の「履歴に戻らない・ブランチを切らない」、起動時間のキャッシュ見送りと VS Code 拡張の削減、git の SSL の試験結果）は残した。統合先の Facts の多くは「再現は未実施」のまま。結果: `check-docs.ps1` が FAIL 0、WARN 0、`転記待ち` 0 件。

### 2026-10-06（共通ルールに「終了処理して」を足した。`.obsidian` の決定を撤回済みにした）

- kit の版 `2026-10-06.17`（「終了処理して」と「inboxを整理して」の新設。`workbase` の `93d2a41`）に合わせて、この `AGENTS.md` の共通ルールに `closing-hook.md` を足した。dotfiles は exmem 側の統合をしないので、`integrate-hook.md` は足さない。ユーザーの確認で、決定「`.obsidian` は `notes` に置く」（2026-10-04）を撤回済みにした（`docs/decisions.md`）。`転記待ち` は上限の 20 件なので、次の作業の終わりに、exmem で「inboxを整理して」を実行して減らす（Next Actions）。

### 2026-10-06（`docs/decisions.md` の棚卸しと「ナレッジ化して」）

- ユーザーの指示で、`check-docs.ps1` の FAIL 64 件（全項目に行き先が無い）を直した。65 項目にラベルと行き先を付けた（コミット `23857da` に混ざって入った。経緯は下の kit 版 `2026-10-06.16` の項目）。内訳: local 35、転記済 12（exmem に、同じ話題のノートがあることを、キーワード検索で確認したもの。根拠・却下案の全体の突き合わせは未実施）、未仕分けだった汎用項目 17（下の「ナレッジ化して」で転記待ちにした）。`.obsidian` を `notes` に置く決定（2026-10-04）は、2026-10-05 の構造変更で dotfiles に戻っている（works の `docs/log.md`）ので、撤回の扱いをユーザーに確認する（`local` の理由に書いた）。結果: FAIL 0、WARN 0（転記待ちは上限の 20 件）。
- 「ナレッジ化して」を実行した（ユーザーの指示）。`exmem/inbox/` に3つのメモを作った（コミット対象外。点検スクリプト PASS 71、FAIL 0、WARN 0）: `2026-10-06-certs-location-wslenv-path.md`（置き場の変更と `WSLENV`）、`2026-10-06-windows-cli-pitfalls.md`（PowerShell・バッチ・git の落とし穴）、`2026-10-06-dotfiles-startup-and-tracking-tips.md`（起動時間、WSL、追跡方針）。対応する項目の行き先を `転記待ち` にした。

### 2026-10-06（会社 CA 証明書の置き場を `%USERPROFILE%\.certs` に変更）

- ユーザーの指示で、`CERTS_DIR` を `works\areas\dev-env\certs` から `%USERPROFILE%\.certs` へ移した。`scripts/windows/10_env.bat`（値、mkdir、`WSLENV` への `CERTS_DIR/p` の追加。重複して足さない）、`home/.config/shell/common.sh`（`${CERTS_DIR:-$HOME/.certs}`）、`README.md` を更新。判断は `docs/decisions.md`（【この件】会社 CA 証明書の置き場…）。構文と分岐は確認済み。`10_env.bat` の実行と WSL での `$CERTS_DIR` は未確認（Next Actions）。

### 2026-10-06（11_git_identity.bat に schannel の質問を追加）

- 「ナレッジ化して」の改善1点をユーザーが承認し、workflow-kit を版 `2026-10-06.16` に上げた（変更は `workbase` 側で、dotfiles のコミット対象外）: `docs-rules.md` の「コミットの前に確認する」①に、`git diff --cached --stat` の行数が自分の変更量と合うかの確認を足した。コミット `23857da` で、並行編集（ラベルと行き先の付与）の約40行が `docs/decisions.md` に混ざったため。ユーザーは、混ざったコミットはこのままでよいと判断した（履歴は書き換えない）。

- 「ナレッジ化して」を実行し、`exmem/inbox/2026-10-06-git-ssl-backend-credential-placement.md` を作った（コミット対象外。点検スクリプト PASS 27、失敗0、警告0）。`docs/decisions.md` に決定と Gotcha（`https.sslVerify` は git に無いキー）を足し、行き先を `転記待ち` にした。

- ユーザーの依頼で、`scripts/windows/11_git_identity.bat` に「SSL バックエンドを schannel にするか」の質問を足した。`y` で `.gitconfig_local` に `[http] sslBackend = schannel` と `sslVerify = true`（`[http]` 内。当初の `https.sslVerify` は git に無いキーなので `http.sslVerify` に直した） を書き、`n`・空は何も書かない（既定の OpenSSL）。y/n 以外は再入力で、5回で `[ERR]`。`tests/windows/test_11_git_identity.ps1` に6件を足し、failures=0（確認: 2026-10-06、`test_20_apps.ps1` も failures=0）。README の該当行も更新。`credential.helperselector.selected = manager` は、ユーザーの決定で `home/.gitconfig` に静的に持ち、スクリプトからは書かない（`11_git_identity.bat` から削除、試験は「書かない」に変更）。`home/.gitconfig` にあった未コミットの schannel 設定は、ユーザーが外した（確認: `Get-Content`。`helperselector` だけが残る）ので、`n` なら OpenSSL のまま。

### 2026-10-06（works の docs の行き先の点検で、決定を転記）

- works の docs/decisions.md の項目を、転記先と突き合わせる点検（kit の版 `2026-10-06.13` の仕組み）で、dotfiles の決定「Linux 側の試験スクリプトを `tests/linux/` に置く（2026-10-05）」が、works にだけ記録され、この docs/decisions.md に無いことが分かった。docs/decisions.md に項目を足した（ユーザーの承認。内容は、works にあった決めたこと・根拠・却下案・確認済み。コミット `fc23286`）。log.md の 2026-10-05 の記録（試験スクリプトの保存）とは対応している。

### 2026-10-06（点検スクリプトの改善3点を反映）

- ユーザーの承認で、点検スクリプトの改善3点を反映した（workflow-kit 版 `2026-10-06.12`。変更は `workbase` 側で、dotfiles のコミット対象外）。`tools/check-inbox.ps1`: 「なし」の後ろに文字があるときの専用 FAIL、複数のメモにまたがる重複の候補の WARN。`tools/find-knowledge.ps1`: `-Body` で本文も検索。直す前に一時ディレクトリで再現し、直した後に確認した。実装の誤り（長さで絞る正規表現が、バッククォートの対応をずらす）を、実メモの結果が事前の測定より1件少なかったことで見つけて直し、回帰試験を足した。実メモ4件の点検は失敗0。これは、2026-10-06.11 で足した「点検スクリプトの改善」の手順の、最初の実行。

### 2026-10-06（「ナレッジ化して」の続き: 点検スクリプトのナレッジ化と、workflow-kit の改善）

- ユーザーの指示で、点検スクリプト（`check-inbox.ps1`、`find-knowledge.ps1`）の設計・限界・育て方を `exmem/inbox/2026-10-06-inbox-check-script-design.md` に残した（コミット対象外）。既存の知識ノート `workflow-kit.md` には、版の記録として1行言及があるだけだった。あわせて、`vcredist2022` を自動導入しない決定は、ユーザーの承認で「現時点の決定」として Decisions に残した（`2026-10-06-scoop-suggest-vcredist-runtime.md`。解除するときは、現在形の記述を直し、日付つきの記録は書き換えずに「撤回済み」と理由を足す。時制の方針）。workflow-kit を版 `2026-10-06.11` に上げた（ユーザーの承認と指示。変更は `workbase` 側の `e3cfb82` で、dotfiles のコミット対象外）: 「なし」は見出しの直後に1語だけの行にする、分けた複数のメモに共通する事実・落とし穴は1つにだけ書く、依頼された実装は依頼を根拠に Decisions に書ける（依頼に無い選択は「提案」）、点検スクリプトの改善も、フックの改善と同じ承認制の手順で回す。

### 2026-10-06（「ナレッジ化して」の実行）

- 「ナレッジ化して」を実行し、3話題を `exmem/inbox/` に作った（コミット対象外）: `2026-10-06-windows-bat-scripting-pitfalls.md`（`.bat` の ASCII、`set /p` とパイプ、`%errorlevel%`、対話ループの上限、試験の番人）、`2026-10-06-fresh-pc-bootstrap-private-repo.md`（最終の場所への初回 clone、scoop だけの git、private の扱い、`git config --file`）、`2026-10-06-scoop-suggest-vcredist-runtime.md`（`suggest` と VC++ ランタイムの判断基準）。点検スクリプトは3件とも PASS（失敗0、警告0）。メモの中で、履歴の種（exmem の `knowledge/shell-command-usecases.md`）の `git config --global user.name` / `user.email` の行が、symlink の `~/.gitconfig` と食い違うことを「統合時の修正」に書いた。dotfiles 固有の経緯（Zed と Obsidian のフォント、Linux との対称化の範囲、手順書の更新）は、ナレッジ化せず `docs/` に残してある。

### 2026-10-06（動作確認の Close）

- ユーザーが新しい Windows アカウントで、`10` から `50` の Windows スクリプトを実機で通し、問題なしと報告した。`24_fonts.bat` は実際にダウンロードした。VC++ ランタイムの `[WARN]` は出なかった（`[Installed]` 側のみ。`[WARN]` 側は未確認のまま Next Actions に残した）。これを受けて、次の項目を Close（削除）した: 新アカウントでの `20_apps.bat` と Scoop 導入、`10_env.bat` / `20_apps.bat` / `50_repos.bat` の実機の通し実行、Windows の新PCでの通し実行と Win11 の「要確認」、`scoop install git` 直後の `git` 利用、`.bat` の文字化け修正の再実行、`11_git_identity.bat` の実機動作、`24_fonts.bat` の実ダウンロード（PlemolJP のアセット名 `PlemolJP_NF_v*.zip` が通る）、`~/.gitconfig_local` の設定確認（`11_git_identity` で置き換わった）、winget の git の `winget uninstall`（決定を撤回済み）。Windows の OOBE 回避（手順書の 1〜4）は、この確認に含まれず、手順書に「要確認」のまま。続けて、`31_history_seed.bat` も同じ新アカウントの実機で通し済みと確認した（Windows 側のみ。Linux の `31_history_seed.sh` は未確認のまま Next Actions に残した）。この後、ユーザーが「ナレッジ化して」を依頼する予定（`docs/` は更新済み）。

### 2026-10-06（workbase の手順書を現在のスクリプトに合わせた）

- ユーザーの指示で、workbase の手順書 `cheatsheets/env/` の古い記述を、現在の dotfiles に合わせて直した。`win11.md`: 手順 6 の表から削除済みの `21_vscode.bat` と `22_python.bat` を外し、`24_fonts.bat` の行を現状（PlemolJP のみ、`gh` のログイン不要、`--dry-run` なし、ログと `pause`、失敗で終了コード 1）に、`20_apps.bat` の行に VC++ のオレンジ表示を、`31` の行にログと `pause` を足した。全体の流れの `10` → `11` → `20` → `30` と、動作確認の `code README.md`（VS Code は削除済み）、確認日（2026-10-06。5〜7 は実機で通した、ユーザー報告）も直した。`fonts.md`: Moralerspace を外し、`--dry-run` と `gh auth login` の記述を削除。`debian-family.md`: 削除済みの `21_vscode.sh` の行を削除。確認: `cheatsheets` 全体を Grep し、`21_vscode` / `22_python` / `MoralerspaceHW` / `24_fonts` の `--dry-run` の残りが無いこと（`gh auth login` は Linux の非公開リポジトリの手順 B にだけ残る）。変更は workbase 側（別コミット）。

### 2026-10-06（リポジトリの公開・非公開が未定なので、手順を両方併記）

- ユーザーの判断で、リポジトリを公開にするか非公開にするかは未定のため、手順を両方書いた（運用が決まったら、使わない方を削除する。判断は `docs/decisions.md` の「リポジトリの公開・非公開は未定。両方の手順を併記した」）。dotfiles の `README.md`: Windows のクイックスタートに「非公開ならサインインが開く、公開なら出ない（4行は同じ）」を追記、Linux のクイックスタートを「A. 公開（git だけ）」「B. 非公開（`gh auth login` ほか）」にした。workbase の手順書（`cheatsheets/env/debian-family.md` の手順 7・8・10、`win11.md` の手順 5・6 と付録）も同じ方針で更新し、`11_git_identity` の案内も足した。`win11.md` の手順 5 は、winget の git を使わず scoop の4行にそろえた（dotfiles の README と矛盾していたため。同じ節の範囲）。`win11.md` には、ほかにも古い記述が残る（下の Next Actions）。変更は workbase 側（別リポジトリ）にもあり、そちらは別コミット。

### 2026-10-06（Linux / WSL を Windows と対称にする）

- ユーザーの指示で、今日 Windows 側に入れた変更を Linux / WSL にそろえた（判断と「対称にしないもの」の理由は `docs/decisions.md` の「Linux / WSL を Windows と対称にした」）。(1) `scripts/linux/11_git_identity.sh` を新設（`~/.gitconfig_local` を対話で作る）。(2) `24_fonts.sh` が、1件失敗しても続行し、最後に終了コード 1 にする。(3) README に「クイックスタート（ネイティブ Linux）」（`apt install git gh` → `gh auth login` → `gh auth setup-git` → `git clone`）と、Linux の手順 1 の `11`、試験の説明を追記。(4) `tests/linux/test_scripts.sh` に 14 項目を追加。確認: WSL（Ubuntu 24.04.4）で 50/50 合格、Windows 側の試験も合格（`test_20_apps.ps1` 28 件、`test_11_git_identity.ps1` 15 件）。未確認: 新しい Linux の実機での `gh auth login` から clone までの通し。workbase の手順書 `debian-family.md` の手順 7（「公開リポジトリ」）がリポジトリの private 化と食い違っている（dotfiles からは直していない）。

### 2026-10-06（Windows の実機確認後の調整）

- ユーザーが Windows の通し実行を実機で確認した（問題なし）。その中で出た3点を直した（判断は `docs/decisions.md` の「`scoop-completion` と Moralerspace を manifest から外した。`.bat` のコメントは全て英語にした」）。(1) `20_apps.bat` の冒頭の文字化け: 日本語コメントが cp932 のコンソールで壊れていたので、`10_env` / `20_apps` / `40_wsl_enable` のコメントを全て英語にし、`scripts/windows/*.bat` が ASCII であることの検査を `tests/windows/test_20_apps.ps1` に足した。(2) `scoop-completion` は未使用だったので `apps.txt` から削除（このPCの導入済み分は手で `scoop uninstall scoop-completion`）。(3) `fonts.txt` の Moralerspace を削除（README とコメントも更新）。確認: `test_20_apps.ps1` が failures=0（ASCII の検査8件を含む）、WSL の `tests/linux/test_scripts.sh` が 36/36 合格。続けて、Zed と Obsidian のフォントのフォールバックから `Moralerspace Neon HW` を外した（ユーザーの指示。Zed 3か所、Obsidian 3か所）。また `20_apps.bat` の VC++ ランタイムの表示（`[Installed]` / `[WARN]`）を、見落としを防ぐため、オレンジ（ANSI 256色の 208）にした。ESC は `prompt $E` で取得するので、ソースは ASCII のまま。`test_20_apps.ps1` が failures=0（色の検査2件を含む）。実機の表示は未確認（Windows Terminal / Win11 のコンソールは対応している想定）。

### 2026-10-06（初回の git を scoop だけにする。winget の git を撤回）

- ユーザーの判断（「理想は scoop で完結」）で、手順 0 の git を winget から scoop に変えた（判断は `docs/decisions.md` の「初回は scoop の git だけで最終の場所に clone する」。前項の winget 案は「撤回済み」として残した）。`20_apps.bat` の winget の git の撤去処理と試験7件を削除（直前のコミット `3f7e794` の前の状態に戻した）。README の手順 0 を scoop の4コマンドに書き換えた。確認: `pwsh tests/windows/test_20_apps.ps1` が failures=0。実機の新アカウントでの通し実行は未確認。リポジトリが private で、clone に GitHub のサインインが要ることも確認し、README に書いた。手順 1〜3 のスクリプト化は、リポジトリが private で clone 前にスクリプトを匿名で取得できない（raw URL は 404）ため、ユーザーの判断でスクリプトにせず、README の貼り付けブロックにした。4コマンドを README の冒頭「クイックスタート」に置き、手順 0 はそこを参照する（コマンドの重複を避けた）。却下案: ブラウザで Raw を保存して実行する `00_bootstrap.bat`（GitHub の Raw は LF で、`.bat` のラベルが壊れることがあるため、ラベルなしの書き方が要る。受け渡しの手間もある）。開発者モードは管理者権限が要るので自動化できない（symlink を試しに作れば有効か確認はできる）。

### 2026-10-06（初回取得の見直し: 最終の場所に clone、git は scoop に統一、11_git_identity.bat）

- 運用が「zip で取得 → 番号順に実行 → `50_repos` で ghq 管理下に再取得 → `30_link` をもう一度」で二重だったのを見直した（判断は `docs/decisions.md` の「初回の取得は winget の git で最終の場所に clone し、git は scoop に統一する」）。ユーザーの選択で、初回は winget の git で最初から `C:\vault\repos\github.com\yuzucha16\dotfiles` に clone し（README の手順 0 のとおり。zip は使わない）、git の正本は scoop。`50` を前に出す案は、`ghq` と `GHQ_ROOT` に依存するため採らず、置き場所をそろえた。
- 追加・変更: (1) `scripts/windows/11_git_identity.bat` を新設。`~\.gitconfig_local` が無いときだけ、`user.name` / `user.email` を対話入力し、`git config --file` で作る（`--global` は `30_link` と衝突するので使わない）。無効な入力は5回で `[ERR]`。(2) `20_apps.bat` に、scoop の git のあとで winget の git を検出し、確認（既定は消さない）のうえ `winget uninstall --id Git.Git -e` する処理を足した（`WINGET_EXE` で差し替え可能）。(3) `50_repos.bat` のユーザーの変更 `ghq get yuzucha16/dotfiles` は、取得済みで不要になったので、元のコメント行（`rem ghq get yuzucha16/adv360-pro-zmk`）に戻した。(4) README の手順 0・1・2・5 を更新。
- 確認: `pwsh tests/windows/test_20_apps.ps1`（winget の分岐 7 件を追加）と、新規の `tests/windows/test_11_git_identity.ps1`（15 件）が failures=0。偽の `USERPROFILE` と偽の `winget` だけを使い、実環境の `~\.gitconfig_local` は不変。実機で winget の git を入れた PC での通し実行は未確認。

### 2026-10-06（24_fonts.bat の出力保存と pause、50_repos.bat の変更）

- `24_fonts.bat` に、`31_history_seed.bat` と同じ方式（`:MAIN` の出力を `tmp\24_fonts.log` に記録、表示後に `pause`）を入れた。従来は末尾に `pause` が無く、ダブルクリックで結果が見えなかった。あわせて、`gh release download` の失敗を検出して `[ERROR]` を出し、1件でも失敗したら終了コード 1 にした（従来は失敗しても「Downloaded」と出ていた）。`gh` は `call gh` で呼ぶ。確認: 偽の `gh.cmd` と偽の `USERPROFILE` で、成功（rc=0）、失敗（rc=1、`[ERROR]` が2件）、`gh` なし（rc=1）を実行し期待どおり。実際のダウンロードは未実行。
- ユーザーが `50_repos.bat` に加えた変更（コメントアウトされていた `ghq get yuzucha16/adv360-pro-zmk` を `ghq get yuzucha16/dotfiles` に置換）を、ユーザーの指示でコミットに含めた。内容は未検証（上の行のコメント「dotfiles itself is already cloned by hand」と食い違っている）。

### 2026-10-06（31_history_seed.bat の出力保存と pause）

- `31_history_seed.bat` をダブルクリックで実行すると、一瞬でウィンドウが閉じて結果が分からなかった（ユーザーの報告）。本体を `:MAIN` に分けて出力を `tmp\31_history_seed.log`（`.gitignore` 済み、実行のたびに上書き）へ記録し、画面に表示したあと `pause` で止まるようにした。終了コードは従来どおり（成功・SKIP・dry-run は 0、引数誤り・種なし・コピー失敗は 1）。確認: `-n`、不正な引数、偽の `APPDATA` での実コピーと2回目の SKIP を実行し、期待どおり（実環境の履歴 15,964 バイトは不変）。他の `.bat`（`30_link`、`24_fonts` など）にはログを足していない。`pause` の無い `24_fonts.bat` は未対応。

### 2026-10-06（vcredist2022 の提案への対応）

- `20_apps.bat` の `scoop install` で、lsd / ripgrep / bat / starship / windows-terminal / chatgpt が `extras/vcredist2022` を提案する件を調べた。`suggest`（任意）で必須ではなく、`extras/vcredist2022` のインストーラが UAC 昇格（`-RunAs`）を要するため、ユーザースコープのみの方針と衝突する。自動導入はせず、`20_apps.bat` に、VC++ 2015-2022 x64 ランタイムがレジストリに無いときだけ `[WARN]` と手動導入コマンドを出す確認を足した。入れる基準3点は `docs/decisions.md` の「vcredist2022 は自動導入せず、不足時だけ警告する」。確認: `pwsh tests/windows/test_20_apps.ps1` が failures=0（既存の試験。新しい警告の分岐の自動試験は未作成）、`reg query` の判定は「ある」「ない」の両方を実機で確認。`bat` の `less`・`vim` の `vimtutor` の提案は入れない判断（同じ項に記載）。

### 2026-10-06（`vault\notes` → `vault\works` の rename 後の点検）

- ユーザーが実機で `vault\notes` を `vault\works` に rename したあと、dotfiles への影響を点検した。結果は、デグレなし（確認: 2026-10-06）。ユーザー環境変数 `WORKS_DIR` / `CERTS_DIR` は新パス（旧 `NOTES_DIR` は無し）、`C:\vault\works\.obsidian` のジャンクションは dotfiles へ正しく張られている、`workbase`（`works\resources`）は `main...origin/main`、WSL から `/mnt/c/vault/works` の `.obsidian` と `exmem` が見える、`bash tests/linux/test_scripts.sh` は 36/36 合格（実 WSL の項目も通った）。`docs/` に残っていた現在のパス参照（`notes/resources/...` の4か所）を `works/resources/...` に直した。過去の経緯の記述（`.obsidian` を `notes` に置いた判断など）は、当時の呼称のまま残した。未確認: 会社PCの `company-ca.crt` の所在（このPCの `areas\dev-env\certs` は存在するが中身は未確認）、他のPCでの `10_env.bat` と `30_link.bat` の再実行。

- Vault のトップが `notes` から `works` に変わるのに合わせて、`NOTES_DIR` を `WORKS_DIR` に、パスを `C:\vault\works` / `/mnt/c/vault/works` / `~/vault/works` に改めた（`AGENTS.md`、`README.md`、`links.map`、`10_env.bat`、`50_repos.bat`、`.profile`、`lib.sh`（`works_dir`）、`30_link.sh`、`50_repos.sh`、`tests/linux/test_scripts.sh`）。`CERTS_DIR` は `%WORKS_DIR%\areas\dev-env\certs` にし（`10_env.bat` はこのディレクトリを作らない）、`common.sh` の WSL 側の参照も合わせた。Linux のテストは 35/35 合格（実 WSL の項目は rename 前なので skip）。**実機の `setx` と rename は、ユーザーが行う**（手順は、トップの `docs/log.md`）。
### 2026-10-06

- Scoop 導入の失敗と実行ポリシーの扱い、PowerShell の二重引用符で文書が壊れた件を「ナレッジ化して」で `exmem/inbox/2026-10-06-scoop-install-execution-policy.md` に残した（実機の新アカウントでの確認は未実施のため、Open Questions に残してある）。実行で出た改善1点（仮説の表記 `（仮説）` は完全一致で書く）を承認し、workflow-kit に反映した（版 `2026-10-06.7`）。変更は `workbase` 側で、dotfiles のコミット対象外。

- Windows 側の試験環境（`tests/windows/`）を「ナレッジ化して」で `exmem/inbox/2026-10-06-windows-bat-script-testing-dryrun.md` に残した（WSL 側の `shell-script-testing-wsl` と対称。Scoop の原因調査と実行ポリシーの判断は、実機確認後にナレッジ化する）。実行で出た改善1点（ファイル名の語数の数え方と `sources` の定形）を承認し、workflow-kit に反映した（版 `2026-10-06.6`）。変更は `workbase` 側で、dotfiles のコミット対象外。

- 新しい Windows アカウントで、Scoop の導入が「アクセスが拒否されました。」で失敗した件を調べた（ユーザーの報告では `10_env.bat` だが、該当処理は `20_apps.bat`）。原因は特定できず（候補の検討と却下は `docs/decisions.md` の Gotchas）。実機で成功した手順（`Invoke-RestMethod | Invoke-Expression`）に合わせて `20_apps.bat` を直した。`powershell.exe` を完全パス（`PS_EXE`）で呼び、失敗時に `Get-ExecutionPolicy -List` を出す。実行ポリシーは、ユーザーの判断で、実効値が Restricted/AllSigned/Undefined のときだけ CurrentUser を RemoteSigned にし、変更の失敗は警告で続行する。あわせて、ネットワーク無し・実インストール無しの試験 `tests/windows/test_20_apps.ps1` を作り、18/18 合格（確認: 2026-10-06、終了コード0。実機のポリシーは不変）。新アカウントでの実機確認は未実施。
- `main` が `origin/main` と分岐（各4コミット）したので、ユーザーの指示でローカルを `origin/main` の上に rebase した。衝突は `docs/log.md` の Log 節だけ（双方が新しい日付の節を足した）で、両方を残して日付の降順にした。順序は、ローカルが 2026-10-05 23:12〜23:27、リモートが 2026-10-06 08:18〜08:25（別PCと思われる）で、古い側を新しい側の上に載せた形（時系列に沿う。事後にユーザーへ確認）。ローカル4コミットのコミット日時は 2026-10-06 09:12 に変わった（author date は元のまま）。rebase 前は `7fe015f`（reflog から `git reset --hard 7fe015f` で戻せる）。反省: rebase 前に双方の日時を比べず、順序をユーザーに確認しなかった。以後は `AGENTS.md` のコミットの項のとおり事前に確認する。
- 「ナレッジ化して」を実行した（`exmem/inbox/2026-10-06-git-rebase-chronology-check.md`。コミット対象外）。改善案を1点承認し、workflow-kit を版 `2026-10-06.4` に上げた: 手順 2 に「規則や置き場の選択も、ユーザーが明示または承認したなら Decisions に書く」を足した（変更は `workbase` 側、dotfiles のコミット対象外）。
- 「inbox のメモはコミットしない」の範囲が曖昧で、報告が「`workbase` の変更全体を人に任せる」と読めた（ユーザーの指摘）。対象は、「ナレッジ化して」のフックが作ったメモのファイルだけで、ほかの変更はコミットしてよい。workflow-kit を版 `2026-10-06.5` に上げ、`docs-rules.md` と `knowledge-hook.md` に範囲と報告の書き方を明記した。`workbase` は3コミット（`69f5580` kit、`4293b86` exmem の統合、`ba83c3f` 手順書。agent 名義）に分けてコミットし、inbox のメモ8件は未追跡のまま残した。push は未実施（ユーザーが行う）。
- `workbase`（`C:\vault\notes\resources`）の `git pull` が、未コミットの `exmem/knowledge/` の変更と衝突した。tracked の変更を stash → `git pull --ff-only` → `git stash pop` で戻し、衝突した3ファイル（`tags.md`、`workflow-kit.md`、`pc-setup-manuals.md`）は双方の内容を残して解消した。別PCが同じ inbox メモを `shell-script-testing-wsl.md` に統合済みだったため、こちらの重複ノート `wsl-shell-script-testing.md` は削除した（`sources` の1行は移した。リンクも更新）。stash は内容が作業ツリーに入っていることを確認して破棄した。`workbase` へのコミットはしていない（ユーザーが行う）。
- rebase 後に WSL（Ubuntu 24.04）で `bash tests/linux/test_scripts.sh` を実行し、36/36 合格、失敗0を確認した（根拠: スクリプトの出力 `RESULT: 36/36 passed, failures=0`）。未 push（`origin/main` の先頭が祖先なので、通常の `git push` で足りる）。
- clone 直後の大量の差分（64ファイル、約8,000行）の原因が改行コード（index は LF、作業ツリーは CRLF）と判明。`.gitattributes` を追加（`5af8dd1`）し、`.bat` 8本の index を LF に正規化（`7e9ae20`）。実質差分の4ファイルは破棄し、`git restore .` で作業ツリーを取り直した。`home/.gitconfig` の `[user]` は `~/.gitconfig_local` に移し済みのため破棄。詳細は `docs/decisions.md` の Gotchas。
- 上の件の「ナレッジ化して」で出た改善2点を、workflow-kit に反映（版 `2026-10-06.3`）: 点検スクリプトの `<…>` 検出からインラインコードを除外、既存知識の検索用 `tools/find-knowledge.ps1` を追加。変更は `workbase` 側（dotfiles のコミット対象外）。

### 2026-10-05

- Linux 側の試験スクリプトを `tests/linux/test_scripts.sh` として保存した（ユーザーの承認。試験のたびに使い捨てていたものを、再利用できる形にした）。場所は自動判定、試験用のリポジトリは自前で作る（vault に依存しない）、WSL とネイティブの分岐は `PROC_VERSION_FILE` で強制、実環境を見る項目と `stow` が必要な項目は、無ければ skip する。WSL で36項目すべて合格（確認: 2026-10-05、終了コード0）。`README.md` に「スクリプトの試験」の節と `tests/` を、`AGENTS.md` に「`scripts/linux/` などを変えたら実行する」を足した。
- Vault の構造変更（`notes` を PC ローカルのトップと、共有の `workbase` に分けた）に合わせて、Windows 側を更新した（コミット `cded219`）。`.obsidian`（15ファイル）と `office/` を `windows/` に戻し、`links.map` を `windows\obsidian\.obsidian|%NOTES_DIR%\.obsidian` に、`50_repos.bat` に `workbase` の `git clone`（`%NOTES_DIR%\resources`、ghq の管理外）を足した。ジャンクション越しのディレクトリを Grep / Glob / `rg` が辿らないため、ghq の位置からのリンクにしなかった。
- Linux 側を対応した（ユーザーの指示）。`scripts/linux/lib.sh` に `notes_dir`（`NOTES_DIR` があればそれ、WSL は `/mnt/c/vault/notes`、ネイティブは `~/vault/notes`）、`clone_workbase`、`link_obsidian` を足し、`50_repos.sh`（ネイティブは `workbase` を `$NOTES_DIR/resources` に clone、WSL は Windows 側が clone するので確認のみ）、`30_link.sh`（ネイティブのみ `.obsidian` を symlink、WSL は Windows 側のジャンクションを共有）、`home/.profile`（`NOTES_DIR` の既定値）を変えた。確認: WSL（Ubuntu 24.04）の実機で、一時ディレクトリと偽の HOME を使い、35項目が合格（構文、`NOTES_DIR` の分岐3種、clone の4場面、`link_obsidian` の9場面、`30_link.sh` の通しの5場面、`50_repos.sh` の5場面）。実環境の `~` は変更していない。`~/.profile` は dotfiles への symlink なので、新しいログインシェルで `NOTES_DIR=/mnt/c/vault/notes` になり、`workbase` の clone が見えることも確認した。試験用に、`is_wsl` と `.profile` に環境変数 `PROC_VERSION_FILE`（`/proc/version` の差し替え）を足した。ネイティブ Linux の実機は未確認。

### 2026-10-04

- 「ナレッジ化して」（`exmem/inbox/2026-10-04-config-dir-placement-criteria.md`）で出た改善案2点を承認し、workflow-kit の `knowledge-hook.md` を直した: 同日の他メモと決定が食い違うときの書き方、`docs/` の更新済みの確認方法（`docs/log.md` の今日の項目で判定。`git status` の差分では判定できないので、提案の文言を変えた）。記録は `improvements.md`。
- `.obsidian` を `notes` に置くか dotfiles に置くかの判断基準（6項目）を決め、`notes` に残すと決定した（判断は `docs/decisions.md` の「`.obsidian` は `notes` に置く」）。決め手は、Vault との連動、依存の向き（dotfiles → `notes` の片方向）、ジャンクションが要らないこと。基準6（粒度）は、置き場ではなく Claude を開く場所（`notes` のルート）で解決する。`notes` 側の撤去作業（`.obsidian/AGENTS.md` など）は、ユーザーが実施し、ファイルが無いことと `.obsidian` の `git status` が clean であることを確認した（根拠: `Get-ChildItem`、`git status`）。`notes/AGENTS.md` への「`.obsidian/` 単体で Claude を開かない」の追記は、不要とユーザーが判断した。`knowledge/obsidian-vault.md` に「設定」節の更新と置き場の決定を反映した（`notes` の `2893e74`）。
- 「ナレッジ化して」（`exmem/inbox/2026-10-04-gh-release-download-without-login.md`）で出た改善案2点を承認し、workflow-kit の `knowledge-hook.md` を直した: 既存ノートとの食い違いは Open Questions に「統合時の修正」として書く、統合先の候補は狭い候補と広い候補を並べてよい（`improvements.md` に記録）。
- `24_fonts.*` から `gh auth status` の前提チェックと `--dry-run` を削除した。未ログインで `gh release download` が成功することを実機で確認したため（判断は `docs/decisions.md` の「フォント取得」）。
- `docs/` の運用と「ナレッジ化して」フックの本文を、共通機能 `notes/resources/workflow-kit/` へ移した。dotfiles の `AGENTS.md` は、共通ルールへの参照と dotfiles 固有のルール（exmem との関係、履歴の種の正本、コミット）だけに薄くした。目的は、同じ仕組みを他の作業ディレクトリでも使い、改善を1か所に集めること。戻すときは、このコミットを `git revert` する（旧 `AGENTS.md` の本文が戻る）。以後のフックの改善は、kit 側の `improvements.md` に残る。
- 「ナレッジ化して」の4回目（Zed の最適化）で出た改善案のうち2点を承認し、`AGENTS.md` を直した: `claude-acp` の `mode: "plan"` 既定だと毎回プランモードで始まる旨を手順 1 に追記、「`docs/` が未更新なら先に更新してからナレッジ化する」という実行順序を手順の冒頭に追記。
- Zed の設定を最適化した（判断は `docs/decisions.md` の「Zed の最適化」）。自作テーマ Material Gruvbox Dark、カーソル点滅を Zed・pwsh・bash・zsh で停止、AI の設定（Ctrl+Enter 送信、承認を Claude Code に一本化）、Markdown と Obsidian の併用設定、Vim を1週間オフ、`settings.json` / `keymap.json` の整理。コミットは `[zed]` と `[shell]` の2つ。`terminal.shell` の pwsh 明示は既存の決定に反するので削除した。ナレッジ化は `exmem/inbox/2026-10-04-zed-eye-strain-agent-settings.md` と `2026-10-04-terminal-cursor-blink-decscusr.md`。
- Notepad++ の設定を把握し、整理した（判断は `docs/decisions.md` の「Notepad++ の設定整理」）。プラグイン全削除、`shortcuts.xml` / `contextMenu.xml` を管理外に、`%APPDATA%\Notepad++` の残骸を削除、`config.xml` の設定値（スナップショット、LF、折り返し、点滅なし、自動更新オフ）を決めた。Zed の `tab_size` も 2 にそろえた。`exmem/inbox/2026-10-04-notepadpp-settings-optimization.md` を作った。
- 不要なものを整理した（判断は `docs/decisions.md` の「不要アプリの削除と Notepad++ config の雛形方式」）。
  - 削除: `22_python.bat`、VS Code 一式（1コミット。revert で復活できる）、Gruvbox light、`32_notepadpp.*`。
  - Notepad++ の `config.xml` は、最小構成の雛形 `config.min.xml` を `20_apps.bat` が初回だけコピーする方式にした（実機で動作確認済み）。
  - starship の os アイコン後の余分なスペースを直した。Zed の `auto_install_extensions` に `git-firefly` `toml` `xml` を追加した。
  - 「ナレッジ化して」で `exmem/inbox/2026-10-04-dotfiles-cleanup-notepadpp-config.md` を作った。
- 「ナレッジ化して」の2回目（`exmem/inbox/2026-10-04-scoop-vs-unmanaged-apps.md`）で出た改善案3点を承認し、`AGENTS.md` を直した: プランモードの承認を拒否されたら書き込まず解除方法を案内する、統合先の確認に検索キーワードを添える、確認した事実に根拠を添える。
- 「ナレッジ化して」の初回実行（`exmem/inbox/2026-10-04-repo-and-exmem-separation.md`）で出た改善案3点を承認し、`AGENTS.md` を直した: 形式に `tags` と `Principles` を追加（exmem の標準プロンプトと同じ形に）、教訓は Principles へ、1ファイル1テーマ（統合先が違う話題はファイルを分ける）。
- 「ナレッジ化して」フックを `AGENTS.md` に定義し、続けて指示文を改善した（プランモードなら先に抜ける、知識の判定基準、既存ノートとの重複確認、単体で読める書き方、実行後の改善報告）。exmem への書き込みは `inbox/` の新規1ファイルだけ。
- 作業ログの置き場を整理した。dotfiles は exmem を読み取り専用で参照するだけにし、経緯・決定・次にやることは `docs/` に持つ。exmem に書かれていた dotfiles の記録（`contexts/dotfiles/context.md`、`knowledge/dotfiles.md`）はここへ移し、exmem 側から削除した。
- zfz/cdg を `Alt+j`/`Alt+k` で3シェル共通にした。zsh で ListView 相当の自作一覧を試し、zsh/bash の ListView 相当は作らず、fzf の `Ctrl+R`（履歴）・`Ctrl+T`（ファイル）に切り替えた（コミット・push 済み）。pwsh にも同じキーで fzf を入れ（`ListView` は残す。実機で動作確認済み）、bash の `.bashrc` 末尾の `cd ~` を削除した。
- 両PCの履歴を分析してユースケースを整理し、「履歴の種」の方針を決めた。傾向と種の本文は exmem の `knowledge/shell-command-usecases.md`、種ファイルは dotfiles。zsh/bash 向けの種（`manifests/history.seed.sh.txt`）と配置スクリプト（`scripts/linux/31_history_seed.sh`）も作った。目的はコマンド履歴のベースを dotfiles 側で管理して、PC 移行時の調べ直しを減らすこと。

### 2026-10-03

- dotfiles の再編・複雑度削減・スクリプト命名・手順書・フォント導入・フォント選定の6件のメモを統合し、実物と照合した。
  - 一致: `scripts/` と `manifests/` の構成、`links.map` の Notepad++ の追跡範囲、Zed のフォント設定、インストール済みフォント4種、`cheatsheets/env/` の3ファイル。
  - 食い違い・未反映: `git bundle` のバックアップがメモのパスに無い。`.wslconfig` はこのPCに未リンク。`gh` は scoop に入っている。
- Office テンプレと `.obsidian` を `notes` リポジトリへ移管した。
- 手順書は `notes/resources/cheatsheets/env/`（`win11.md`、`debian-family.md`、`fonts.md`）。実機での通し確認は未実施。

### 2026-10-02

- `yuzucha16/dotfiles` を再編した。履歴を単一コミットに作り直し、`scripts/{windows,linux}/`・`manifests/`・`home/`（`~` の鏡）・`windows/`・`templates/` の構成にした。スクリプトは `NN_<内容>` の命名で、WSL とネイティブ Linux は `scripts/linux/` に1本化した。
