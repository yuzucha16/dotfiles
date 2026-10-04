# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに、Next Actions と Log を更新する。判断の根拠・却下案・Gotchas は `docs/decisions.md`。

## Next Actions

- `.obsidian` の置き場の決定（2026-10-04）の後始末（`notes` 側の作業。dotfiles からは書かない）: 未コミットの `notes/.obsidian/{AGENTS.md,CLAUDE.md,docs/}` を撤去してよいかユーザーに確認する。撤去後は `notes/AGENTS.md` の「`.obsidian/`」節に、判断基準の要約と「`.obsidian/` 単体で Claude を開かない」を足す。`.obsidian/docs/` にしか無い内容は、置き場の決定（dotfiles 側に記録済み）と、colored-tags の追跡・改行コードの Open Questions（`exmem/inbox/2026-10-04-obsidian-settings-state-and-knowledge-drift.md` に既出）。
- Zed の最適化（2026-10-04）の後始末: Zed を再起動して、テーマ・Ctrl+Enter 送信・右のプロジェクトパネル・Markdown の見え方を確認する。Vim オフの試験は 2026-10-11 頃に続けるか判断する（戻し方は `settings.json` のコメント）。他のPCでは `30_link.bat` の前に、空の `%APPDATA%\zed\themes` を削除する。WSL で点滅を止めるのは `.bashrc` / `.zshrc`（反映は新しいシェルで確認）。OS 全体の点滅停止（`CursorBlinkRate=-1`）は必要なら検討する。
- シェルの3シェル共通化（fzf とキーバインドの現仕様の表は `docs/decisions.md` の Facts）:
  - WSL に `ghq` を入れたら `cdg`（zsh/bash）を実機で確認する。
  - その他、3シェルの差を洗い出して共通化する。
- ヒストリの種を進める。方針と種の本文（正本）は exmem の `knowledge/shell-command-usecases.md`。種ファイル `windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt`、配置スクリプト `scripts/{windows,linux}/31_history_seed.*` は作成・検証済み。残り: 新しいPCで通し実行、数週間使って間引き（置換した apt などの行を優先して見直す）。
- GitHub の既定ブランチを `main` にし、問題が無ければ `202509` をリモート・ローカルで削除する（ユーザーの確認待ち）。
- 各PC（家・会社）で `git pull` → Windows は `30_link.bat`（家は `link home`）、Linux/WSL は `30_link.sh` を再実行する。新しいシェルで zsh の `lt` / `ll` / `l`、`cdg` を確認する。
- このPCで `.wslconfig` を反映する: `30_link.bat` → `wsl --shutdown` → 開き直して `vmmemWSL` を観察する。
- `git config user.name` / `user.email` を `~/.gitconfig_local` にPCごとに設定済みか確認する（仮値 `user <user@example.com>` のままコミットしない）。
- 未 push のコミットを push する（Zed の最適化の `[zed]` `[shell]` は push 済み。残りは 2026-10-04 の `[docs]` 分と `terminal.shell` 削除の `[zed]`。整理分の内訳:`22_python` 削除、starship、Zed 拡張、VS Code 削除、Notepad++ の雛形方式、light テーマ削除）。starship と zed のコミットには、別件の削除が混ざっている（`docs/decisions.md` の Gotchas）。分け直すかは任意。
- 古い Notepad++ のリンク切れ（`stylers.xml` `contextMenu.xml` `NppExec.ini`、`themes\Gruvbox light medium.xml`）と `~/vimfiles` の旧プラグイン（`:PlugClean`）を掃除する。実機に残る scoop の VS Code（`scoop uninstall vscode`、`scoop\persist\vscode` 内のリンク）も、不要なら手で消す。
- `scripts/linux/30_link.sh` にある旧 `.vscode-server/extensions/extensions.txt` の掃除行を、消すか判断する。
- 参照用に退避した他PCの生ヒストリ（`notes/resources/_local/ConsoleHost_history.txt`。Git 対象外）は、使い終わったら削除する。
- 新しいPC（または VM）で `10` → `50` を通し実行し、手順書（`notes/resources/cheatsheets/env/`）どおり進むか確認する。MX Linux 25.3 と Win11 の「要確認」を潰す。
- `24_fonts.*` で実際にダウンロードしてフォントを入れる（`gh auth login` は不要）。`fonts.txt` の PlemolJP は `PlemolJP_NF_v*.zip` のまま。試用中の「Console NF」に当たる実際のアセット名はリリースで未確認なので、確かめて合わせる。1週間使って「Light で続ける / Text に上げる / HackGen に戻す」を決める（メインフォントは PlemolJP Console NF の Light を試用中。Zed・Windows Terminal・Notepad++ に反映済み）。
- `30_link.sh` の最後に `chsh` 後の再ログインの案内を足す。`50_repos.sh` の前提（`source ~/.profile`、`ghq` が PATH にある）を整理する。`50_repos.bat` に取得したいリポジトリを足す。
- `git bundle` のバックアップの所在を確認する（見つからない）。必要なら保管場所を決める。
- 古い WSL では `fdfind` → `fd` のリンクが無いので、`20_packages.sh` を再実行するか手でリンクを張る。

## Open Questions

- 実機の通し実行が未確認: `10_env.bat`（ユーザー環境変数を書き換える）、`20_apps.bat`（Notepad++ の `config.xml` の雛形コピーは確認済み）、`20_packages.sh`、`40_wsl_enable.bat`、`50_repos.*`、`unlink` の実動作（ドライランのみ確認）。処理は旧スクリプトと同じ文字列置換・統合なので挙動は同じと推定（仮説）。
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

### 2026-10-04

- `.obsidian` を `notes` に置くか dotfiles に置くかの判断基準（6項目）を決め、`notes` に残すと決定した（判断は `docs/decisions.md` の「`.obsidian` は `notes` に置く」）。決め手は、Vault との連動、依存の向き（dotfiles → `notes` の片方向）、ジャンクションが要らないこと。基準6（粒度）は、置き場ではなく Claude を開く場所（`notes` のルート）で解決する。`notes` 側の撤去作業（`.obsidian/AGENTS.md` など）は未実施で、ユーザーの確認待ち。
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
