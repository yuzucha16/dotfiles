# scripts/linux

各スクリプトの仕様（WSL とネイティブ Linux 共通）。順序と要点だけの表引きは、リポジトリ直下の `README.md` の「セットアップ手順」。下は 2026-10-16 に README から移した原文。

## WSL (Ubuntu 24.04) / Linux (apt 系)

WSL は Ubuntu の初期ユーザー作成後、WSL 内で次を順に実行する（Windows 側の clone を `/mnt/c/Users/<Windows のユーザー名>/works/repos/...` から参照する）。ネイティブ Linux は、OS を入れて、冒頭の「クイックスタート（ネイティブ Linux）」で `~/works/repos/github.com/yuzucha16/dotfiles` に clone してから実行する（OS のインストール手順は works の `resources/guides/howto/debian-family.md`）。`30_link.sh` は、置かれているリポジトリを自動で `--src` にするので、どちらでも同じ呼び方になる。Vault のトップ `WORKS_DIR` は、WSL では `/mnt/c/Users/<Windows のユーザー名>/works`（Windows 側と共有）、ネイティブ Linux では `~/works`（`home/.profile` が既定値を設定する。`~/.config/profile.local` で上書きできる）。

1. `scripts/linux/10_dirs.sh`: XDG ディレクトリ、`~/.local/bin`、`~/.ssh`、`~/works/{build,tools}` を作る
   - `scripts/linux/11_git_identity.sh`: `~/.gitconfig_local`（PC ごとの git の名前・メール）が無いときだけ、`user.name` / `user.email` を対話的に聞いて作る（Windows の `11_git_identity.bat` と同じ。既にあれば触らない）。**`30_link.sh` の前に**実行する（git が必要。ネイティブ Linux はクイックスタートで入っている。WSL は Ubuntu 標準の git か、`20_packages.sh` の後）。`git config --global` は使わない（理由は Windows 版と同じ。`~/.gitconfig` は `30_link.sh` が張る symlink）。`credential.helperselector`（Git Credential Manager）は Windows 版も書かず、`home/.gitconfig` に静的に持つ。無効な入力は5回で `[ERR]`
2. `scripts/linux/20_packages.sh [desktop]`: apt の更新、`manifests/apt.txt` のパッケージ（git / curl / wget / zsh と CLI ツール）の導入、starship、ghq（ビルド済みバイナリを `~/.local/bin` へ。Go は不要）の導入、`bat` / `fd` のリンク作成。ネイティブ Linux のデスクトップは `desktop` を付けて `apt.desktop.txt` も入れる。Docker や Go は入れない（下の「必要なときだけ入れるもの」）
   - `scripts/linux/23_ja.sh`（ネイティブ Linux のみ。WSL では何もしない）: fcitx5 + Mozc、日本語フォントを入れる。Ubuntu 系は言語パックも入れる。入れたら再ログインして、Fcitx 5 設定で Mozc を追加する（手動）
   - `scripts/linux/24_fonts.sh`: PlemolJP NF の latest を `gh` で `~/download` へ取得する（WSL でも WSL 側の `~/download`）。インストールは手動。`gh auth login` は不要。1件失敗しても残りは続け、最後に `[ERROR]` と終了コード 1（Windows の `24_fonts.bat` と同じ）
   - `scripts/linux/25_arm_gcc.sh`: `gcc-arm-none-eabi`（約 490MB。推奨の newlib も入る）を `[y/N]` で確認してから apt で入れる。容量が大きいので、必要なときだけ実行する（`apt.txt` / `apt.desktop.txt` には載せない）。空入力・`n`・標準入力が閉じているときは `[SKIP]`、既に入っていても `[SKIP]`、無効な入力は5回で `[ERR]`
3. `scripts/linux/30_link.sh [link|unlink] [-n]`: stow で `home/` を `~` に展開する（Windows の `30_link.bat` と同じ引数）。リンク切れの旧 symlink は削除する。展開先に実ファイルがあると `[ERR]` を出して止まる（自動退避はしない。手で退避/削除して再実行）。終わったら `chsh -s /usr/bin/zsh`
   - ネイティブ Linux のみ: `windows/obsidian/.obsidian` を `$WORKS_DIR/.obsidian`（`~/works/.obsidian`）へ symlink する（親が無ければ作る。`unlink` で外れる）。実ディレクトリがあると `[ERR]` で止まる（Obsidian を先に開くと、実ディレクトリができる。手で退避して再実行）。WSL では何もしない（Windows 側の `30_link.bat` が張るジャンクションを `/mnt/c` 越しに共有する）
   - `scripts/linux/31_history_seed.sh [-n]`: `manifests/history.seed.sh.txt` を `~/.local/state/{zsh,bash}/history`（`XDG_STATE_HOME` があればその下）へコピーする。履歴が無い/空のときだけ行い、既存の履歴は上書きしない（`-n`: 確認のみ）。リンクではないので、以後はシェルが自由に追記する。**最初のシェルを開く前に**実行する
4. `scripts/linux/50_repos.sh`: 共有リポジトリ `workbase` を、ネイティブ Linux では `$WORKS_DIR/resources` に `git clone` する（ghq の管理外。既にあれば skip。`WORKBASE_URL` で URL を変えられる）。WSL では、Windows 側の `50_repos.bat` が clone するので、無ければ `[WARN]` を出すだけ。そのあと、ghq で参照用リポジトリを取得する
