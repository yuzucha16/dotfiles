# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに、Next Actions と Log を更新する。判断の根拠・却下案・Gotchas は `docs/decisions.md`。

## Next Actions

- シェルの3シェル共通化（fzf とキーバインドの現仕様の表は `docs/decisions.md` の Facts）:
  - WSL に `ghq` を入れたら `cdg`（zsh/bash）を実機で確認する。
  - その他、3シェルの差を洗い出して共通化する。
- ヒストリの種を進める。方針と種の本文（正本）は exmem の `knowledge/shell-command-usecases.md`。種ファイル `windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt`、配置スクリプト `scripts/{windows,linux}/31_history_seed.*` は作成・検証済み。残り: 新しいPCで通し実行、数週間使って間引き（置換した apt などの行を優先して見直す）。
- GitHub の既定ブランチを `main` にし、問題が無ければ `202509` をリモート・ローカルで削除する（ユーザーの確認待ち）。
- 各PC（家・会社）で `git pull` → Windows は `30_link.bat`（家は `link home`）、Linux/WSL は `30_link.sh` を再実行する。新しいシェルで zsh の `lt` / `ll` / `l`、`cdg` を確認する。
- このPCで `.wslconfig` を反映する: `30_link.bat` → `wsl --shutdown` → 開き直して `vmmemWSL` を観察する。
- `git config user.name` / `user.email` を `~/.gitconfig_local` にPCごとに設定済みか確認する（仮値 `user <user@example.com>` のままコミットしない）。
- 既に入っている不要な VS Code 拡張を `code --uninstall-extension` で外す（Windows 6件、WSL 4件）。古い Notepad++ のリンク切れ（`stylers.xml` `contextMenu.xml` `NppExec.ini`）と `~/vimfiles` の旧プラグイン（`:PlugClean`）を掃除する。
- 新しいPC（または VM）で `10` → `50` を通し実行し、手順書（`notes/resources/cheatsheets/env/`）どおり進むか確認する。MX Linux 25.3 と Win11 の「要確認」を潰す。
- `gh auth login` を済ませ、`24_fonts.*` で実際にダウンロードしてフォントを入れる。1週間使って「Light で続ける / Text に上げる / HackGen に戻す」を決める（メインフォントは PlemolJP Console NF の Light を試用中。Zed・Windows Terminal・Notepad++ に反映済み）。
- `30_link.sh` の最後に `chsh` 後の再ログインの案内を足す。`50_repos.sh` の前提（`source ~/.profile`、`ghq` が PATH にある）を整理する。`50_repos.bat` に取得したいリポジトリを足す。
- `git bundle` のバックアップの所在を確認する（見つからない）。必要なら保管場所を決める。
- 古い WSL では `fdfind` → `fd` のリンクが無いので、`20_packages.sh` を再実行するか手でリンクを張る。

## Open Questions

- 実機の通し実行が未確認: `10_env.bat`（ユーザー環境変数を書き換える）、`20_apps.bat`、`20_packages.sh`、`21_*`、`22_python.bat`、`40_wsl_enable.bat`、`50_repos.*`、`unlink` の実動作（ドライランのみ確認）。処理は旧スクリプトと同じ文字列置換・統合なので挙動は同じと推定（仮説）。
- `.wslconfig` を WSL が読むか、`vmmemWSL` が縮むか。**このPCではまだリンクされていない**（2026-10-03 確認）。
- GitHub の既定ブランチが `main` か。リモートには `main`（`e1e4ac7`）と `202509` の両方がある（2026-10-03 確認）。ローカルの `origin/HEAD` は `202509` を指している。
- 家・会社のPCで、新構成への再同期後の動作（未確認）。
- `git bundle` のバックアップ（約40 MB）が、`C:\vault\backup\dotfiles-before-rebuild-20261002-235045.bundle` に**見つからない**（2026-10-03 確認）。
- 古いコミットが GitHub に SHA 指定で一定期間残る可能性がある（HackGen は OFL、機密無し）。完全に消すには GitHub サポートへの依頼が必要。
- `stylers.xml` の Gruvbox 以外の独自カスタマイズの有無（`git show` で履歴から復元できる）。`NppExec.ini` の `pandoc_preview` 登録は失われた。
- pwsh の `PSReadLine`（`ListView` 予測表示）のコストは未計測。
- 「`ListView` は重い可能性があるが見送り」（`docs/decisions.md` のシェルの項）と、現在の `profile.ps1:19` が `ListView` を設定していることが食い違う。見送りを撤回したのか未確認。`ListView` の件数は PSReadLine 2.4.5 で設定項目が無く、10件固定のはず（ソース未確認、記憶による）。
- pwsh の `Ctrl+R` の候補は、履歴ファイルの行ごとになる。複数行のコマンドは履歴ファイルでは行ごとに分かれているため、複数行コマンドの全体は選べない。
- WSL の VS Code Server 側の C++ メモリ上限は、リポジトリ管理外（`~/.vscode-server/data/Machine/settings.json`）で未設定。
- `templates/claude/settings.sandbox.json` の用途（使い捨ての検証環境に手でコピーする）は README に書いたが推測。
- 他PCに残る旧構成のリンクやファイル（`setx` で作った旧環境変数、旧 Go、旧 vim プラグインなど）の整理。
- 固有ツールが増えたときの一の位の割り当て順（23, 24…）。Linux にも Python（uv）が要るか（要れば `22_python.sh`）。
- `w0` 系に残る日本語コメント。
- `windows/` 配下のアプリ状態ファイル（Notepad++ のテーマなど）の追跡範囲は、今回は見直していない。
- Zed の Linux デスクトップ導入時の `links.map` 側の対応。

## Log

### 2026-10-04

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
