# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。

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

