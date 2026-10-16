# scripts/windows

各スクリプトの仕様（引数・入力・出力・失敗時の挙動）。順序と要点だけの表引きは、リポジトリ直下の `README.md` の「セットアップ手順」。下は 2026-10-16 に README から移した原文。

## Windows

0. **事前準備（手動）**
   - 設定 → 開発者向け で「開発者モード」をオンにする（管理者権限なしで symlink を作るため。必須。オフだと `30_link.bat` は `[ERR]` になる）
   - scoop と git を入れ、clone する（冒頭の「クイックスタート」の4行。このパス構成が前提。**最初から ghq の場所に clone する**ので、zip の取得や、dotfiles の二重取得・`30_link` のやり直しは要らない）。git は最初から scoop のもの1種類だけにする（winget の git は使わない。管理者権限が要らず、PATH の優先順位の問題も起きない）
     非公開の場合は、`git clone` で GitHub のサインイン（Git Credential Manager。scoop の git に同梱）が開く（公開の場合は出ない）。zip での取得は使わない（`.git` が無く、あとで ghq の場所と食い違う）。すでに winget の git が入っているPCは、一度だけ `winget uninstall --id Git.Git -e` で消す
     Obsidian の Vault `$HOME\works`（`WORKS_DIR`）は、この PC だけのローカルなディレクトリ（ローカルのリポジトリ。remote なし、または非公開）で、clone しない。作り方は、共有リポジトリ `workbase` の `workflow-kit` を参照する。`.obsidian` は `30_link.bat` が、`windows\obsidian\.obsidian` から `WORKS_DIR` へジャンクションで張る（`WORKS_DIR` が無ければ作る）。共有リポジトリ `workbase` は、`50_repos.bat` が `WORKS_DIR\resources` に clone する（ghq の管理外）。Office のテンプレと UI 設定は自動では張らない。初回に `windows\office` から手で配置する（配置先は上の `windows/` の表）。
     Obsidian を最初に開く前に `30_link.bat` を実行する。先に Obsidian が実ディレクトリの `.obsidian` を作ると、`30_link.bat` が `[ERR]` で止まる（手で退避して再実行する）。
1. `scripts\windows\10_env.bat`: `setx` で環境変数（`XDG_*`、`WORKS_DIR=%USERPROFILE%\works`、`GHQ_ROOT=%WORKS_DIR%\repos`、`CERTS_DIR` など。`WORKS_DIR` と `CERTS_DIR` は `WSLENV` で WSL へ渡す）を設定し、ディレクトリを作る。`XDG_BIN_HOME=%USERPROFILE%\.local\bin`（Claude Code の置き場）も設定し、ユーザー PATH に `%XDG_BIN_HOME%` を1回だけ足す。**実行後は新しいターミナルを開く**（現在のセッションには反映されない）
   - `scripts\windows\optional\capslock_to_ctrl.reg`（任意）: CapsLock を Ctrl にする。管理者権限が必要で、再起動後に有効。元に戻すときは `capslock_default.reg`
   - `scripts\windows\11_git_identity.bat`: `~\.gitconfig_local`（PC ごとの git の名前・メール）が無いときだけ、`user.name` / `user.email` を対話的に聞いて作る（`credential.helperselector.selected = manager` は `home\.gitconfig` に静的に持つので書かない。SSL バックエンドを schannel（Windows の証明書ストア。ブラウザと同じ）にするかも聞く: `y` で `http.sslBackend = schannel` と `http.sslVerify = true` を書き、`n`・空は何も書かず既定の OpenSSL のまま。プロキシ下で失効確認が失敗したら、`~\.gitconfig_local` の `[http]` に `schannelCheckRevoke = false` を手で足す。git の CA は環境変数では設定しない）。既にあれば触らない。**`30_link.bat` の前に**実行する（git が必要。手順 0 で入れた scoop の git でよい）。`git config --global` は使わない: リンク前は実ファイルの `~\.gitconfig` ができて `30_link.bat` が `[ERR]` になり、リンク後はリポジトリ内の `home\.gitconfig` を書き換えてしまうため。`~\.gitconfig` が `include` するので、読まれるのは `30_link.bat` の後。無効な入力は5回で `[ERR]`（入力が閉じていても無限ループしない）
2. `scripts\windows\20_apps.bat [home]`: scoop と bucket を導入し、アプリを入れる（手順 0 で scoop を入れていれば、導入は skip する。git は先に入る）
   - PC1: `20_apps.bat`（`apps.txt` のみ）
   - PC2: `20_apps.bat home`（`apps.txt` + `apps.home.txt`）
   - Notepad++ の `config.xml` が無い/空のときだけ、`windows\notepadpp\config.min.xml`（タブ幅 2、新規文書 LF、折り返し、スナップショットバックアップ、ダークテーマ、自動更新オフなど）をコピーする。既にあれば触らない。リンクではないので、以後はアプリが自由に書き換える。最小構成を適用し直したいときは `config.xml` を削除（または空に）して再実行する
   - `scripts\windows\23_claude.bat`（任意）: Claude Code を公式インストーラ（`irm https://claude.ai/install.ps1 | iex`）で入れる。実行前に `y/N` を聞き、空・`n` なら何も入れない（無効な入力は5回で `[ERR]`）。scoop の `claude-code` は使わない（`apps.txt` から削除）
   - `scripts\windows\26_uv.bat`: uv を公式インストーラ（`irm https://astral.sh/uv/install.ps1 | iex`）で入れ、`uv python install 3.13 --default` と `uv python pin --global 3.13` を実行し、`python --version` を表示する。入れるかは聞かない。**最初に** SSL バンドルを設定するか `y/N` で聞く（`y` で、`ca_bundle.crt` があるときだけ `UV_SYSTEM_CERTS=true` と `SSL_CERT_FILE` を `setx`）
   - `scripts\windows\27_volta.bat`: `scoop install volta` → `volta install node@lts`（その時点の LTS を既定に固定）→ `node` / `npm` / `npx` の `--version` を表示する。入れるかは聞かない。**最初に** SSL バンドルを設定するか `y/N` で聞く（`y` で、`ca_bundle.crt` があるときだけ `NODE_EXTRA_CA_CERTS` を `setx`）。Node は Volta 前提で、`NODE_EXTRA_CA_CERTS` を設定するのはここだけ（`profile.ps1` では設定しない）。Windows の Volta は開発者モードが要る
   - `scripts\windows\28_npm_globals.bat`: `manifests\npm.txt` の各行を `volta install <名前>` で入れる（現在は `defuddle`。obsidian-skills が使う）。入れるかは聞かない。1件失敗しても残りは続け、最後に終了コード 1。27 の後に実行する（Volta が要る）
   - `scripts\windows\29_claude_plugins.bat`: `manifests\claude-plugins.txt` の各行（`<ソース>|<plugin>@<marketplace>`）について、`claude plugin marketplace add` と `claude plugin install` を実行する（現在は `kepano/obsidian-skills`）。入れるかは聞かない。23 の後に実行する（Claude Code が要る）
   - `25_awscli.bat` `26_uv.bat` `27_volta.bat` の共通の出力: SSL バンドルを設定しないときは、理由つきの `[SKIP]`（`n` と答えた、`CERTS_DIR` 未設定、`ca_bundle.crt` が無い）を出す。最後に `[ENV]` で設定した環境変数の名前と値（設定しなかったものは `[not set]`）を表示し、どの経路でも `pause` で止まってから終わる（終了コードは `pause` の後に返す）
   - 25〜27 は、直前に `10_env.bat` を実行済み（`CERTS_DIR` がある）前提。インストール直後は、レジストリから PATH を読み直して続きを実行する（見つからなければ、新しいターミナルで続ける案内を出して終了コード 0）。CA ファイルが無い場合は設定せず `[SKIP]`。`SSL_CERT_FILE` などは、存在しないファイルを指すと全 HTTPS が失敗するため、無条件には設定しない
   - `scripts\windows\24_fonts.bat`: PlemolJP NF（`manifests\fonts.txt`）の latest を `gh` で `%USERPROFILE%\download` へ取得する。インストールは手動（展開して .ttf を右クリック → 現在のユーザーにインストール）。`gh auth login` は不要。出力は `tmp\24_fonts.log`（Git 対象外、実行のたびに上書き）にも残り、最後に `pause` で止まる。ダウンロードが1件でも失敗したら終了コード 1
3. `scripts\windows\30_link.bat [link|unlink] [-n]`: `manifests\links.map` に従ってリンクを張る（ファイルは symlink、ディレクトリは junction。既存のリンクは張り直す）
   - `unlink`: リンクだけ削除する。`-n`: ドライラン
   - 配置先に実ファイル/実ディレクトリがあると `[ERR]` を出してそのエントリを飛ばし、最後に非ゼロで終了する。**自動退避はしない**。中身を確認して手で退避/削除し、再実行する
   - `[ERR] mklink failed` は開発者モードがオフのときに出る
   - `scripts\windows\31_history_seed.bat [-n]`: `windows\powershell\history.seed.txt` を PSReadLine の履歴ファイルへコピーする。履歴ファイルが無い/空のときだけ行い、既存の履歴は上書きしない（`-n`: 確認のみ）。リンクではないので、以後は PSReadLine が自由に追記する。**最初の pwsh を開く前に**実行する。出力は `tmp\31_history_seed.log`（Git 対象外、実行のたびに上書き）にも残り、最後に `pause` で止まる
4. `scripts\windows\40_wsl_enable.bat`（WSL を使う場合）: 管理者権限で実行。WSL2 の機能を有効化する。**再起動後**、表示される `wsl --update` / `wsl --install -d Ubuntu-24.04` を手動で実行する
5. `scripts\windows\50_repos.bat`: ghq で必要なリポジトリを取得する（dotfiles 自身は手順 0 で取得済みなので、ここでは取得しない）。共有リポジトリ `workbase` は、ghq でなく `git clone` で `%WORKS_DIR%\resources` に取得する（既にあれば skip。`WORKS_DIR` が未設定なら `[ERR]`）
