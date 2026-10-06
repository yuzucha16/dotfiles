# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに、Next Actions と Log を更新する。判断の根拠・却下案・Gotchas は `docs/decisions.md`。

## Next Actions

- `転記待ち` が上限の 20 件に達している。exmem（`C:\vault\works\resources\exmem`）で「inboxを整理して」を実行し、`転記済` に進める案を承認する（2026-10-06 時点。メモは4つ、`exmem/inbox/` にある）。
- `10_env.bat` を再実行して、`%USERPROFILE%\.certs` ができること、`CERTS_DIR` と `WSLENV`（`CERTS_DIR/p` が1回だけ）が更新されることを確認する。新しいターミナルと新しい WSL セッション（`wsl --shutdown` のあと）で、`$CERTS_DIR` が `/mnt/c/Users/<名前>/.certs` になり、`company-ca.crt` があれば `NODE_EXTRA_CA_CERTS` が設定されることを確認する。旧 `works\areas\dev-env\certs`（空）は、確認後に削除する（2026-10-06 時点）。
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

- ネイティブ Linux の実機で、`30_link.sh`（`.obsidian` の symlink）と `50_repos.sh`（`workbase` の clone）、`WORKS_DIR` の既定値（`~/vault/works`。2026-10-06 に `NOTES_DIR` / `notes` から改名）を通して確認する。WSL では、一時ディレクトリで試験済み（2026-10-05）。ネイティブの分岐は、`PROC_VERSION_FILE` の差し替えで再現しただけ。

## Open Questions

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

## Log

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
