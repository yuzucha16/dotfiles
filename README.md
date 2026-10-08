# dotfiles

Windows 11 + WSL (Ubuntu 24.04) / Linux (apt 系: MX / Ubuntu / Mint) の開発環境を、複数PCで同じ状態に再現するための設定とセットアップスクリプト。

- PC1は最小構成、PC2は追加分を足す、という運用。差分は `*.home.*` のファイルに分離している。
- 設定ファイルはこのリポジトリを正とし、各アプリの場所へシンボリックリンクで配置する（Windows: `30_link.bat`、WSL / Linux: `30_link.sh`/stow）。

## クイックスタート（Windows・新しいPC）

先に、設定 → 開発者向け で「開発者モード」をオンにする（手動。`30_link.bat` の symlink に必須）。そのあと、PowerShell に次の4行を貼る（scoop と git を入れ、ghq の場所に clone する）。リポジトリの公開・非公開は未定（2026-10-06 時点は非公開）。**非公開なら、clone で GitHub のサインインが開く。公開なら、サインインは出ない（4行は同じ）。**運用が決まったら、この注記を整理する。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
scoop install git
git clone https://github.com/yuzucha16/dotfiles $HOME\works\repos\github.com\yuzucha16\dotfiles
```

続きは「セットアップ手順」の手順 1（`10_env.bat`）から。`git` が見つからなければ、新しい PowerShell を開き直してから3行目以降を実行する。詳しい注意は手順 0。

## クイックスタート（ネイティブ Linux・新しいPC）

OS を入れたあと、ターミナルで ghq の場所に clone する。**リポジトリの公開・非公開は未定**（2026-10-06 時点は非公開）。状況に合わせて A か B に読み替える。運用が決まったら、使わない方を削除する（手順書 `debian-family.md` の手順 7 も同じ）。

**A. 公開の場合**（サインイン不要）:

```bash
sudo apt install -y git
git clone https://github.com/yuzucha16/dotfiles ~/works/repos/github.com/yuzucha16/dotfiles
```

**B. 非公開の場合**（git と gh を入れ、GitHub にサインインして clone する。`gh auth login` は、GitHub.com → HTTPS → ブラウザ（ワンタイムコード）の順に選ぶ）:

```bash
sudo apt install -y git gh
gh auth login
gh auth setup-git
git clone https://github.com/yuzucha16/dotfiles ~/works/repos/github.com/yuzucha16/dotfiles
```

B は**未確認**: 新しい Linux の実機では未実行（Ubuntu 24.04 の apt に `gh` 2.45.0 があることだけ確認した）。

続きは「セットアップ手順」の「WSL / Linux」の手順 1（`10_dirs.sh`）から。SSH 鍵で取得してもよい（`git clone git@github.com:yuzucha16/dotfiles.git`。鍵の登録は手順書 `debian-family.md` の「SSH と GitHub」）。WSL は Windows 側の clone を使うので、このクイックスタートは不要（Windows 側のクイックスタートを済ませる）。

## ディレクトリ

```text
dotfiles/
├── README.md
├── AGENTS.md       エージェント向けの入口（CLAUDE.md は @AGENTS.md だけ）
├── .gitignore
├── docs/           作業ログ（log.md: 現在状態と次にやること）と判断の記録（decisions.md: 根拠・却下案・Gotchas）
├── scripts/
│   ├── windows/    10〜50 のセットアップスクリプト（`optional/` は任意の .reg）
│   └── linux/      10〜50 のセットアップスクリプト（WSL とネイティブ Linux 共通。違いは `lib.sh` の `is_wsl` などで分岐）
├── manifests/      スクリプトが読むリスト（apps / apt / links）
├── tests/          スクリプトの試験（`tests/linux/test_scripts.sh`、`tests/windows/test_20_apps.ps1`、`tests/windows/test_claude_bedrock_setup.ps1`、`tests/windows/test_claude_launchers.ps1`。下の「スクリプトの試験」）
├── home/           ~ を鏡写しにした共有ツリー（WSL は stow、Windows は links.map でリンク）
├── windows/        Windows 専用の設定（links.map からだけ参照される）
└── templates/      配置しない雛形（`claude/settings.sandbox.json` は、使い捨ての検証環境のプロジェクトで `.claude/settings.json` に手でコピーする。push / reset / clean / rm を許可する広い権限なので、通常のリポジトリには入れない）
```

### `home/`: `~` の鏡

`home/` の中身は、そのまま `~`（Windows では `%USERPROFILE%`）の下に置かれる。WSL では `stow --no-folding -t ~ home` の1回で全部展開する。

| パス | 内容 |
|---|---|
| `.bashrc` `.zshrc` `.profile` `.zprofile` `.bash_logout` `.zlogout` | シェル設定。`.zprofile` は `.profile` を読むだけ |
| `.vimrc` `.gitconfig` `.gitignore_global` | vim / git（`.vimrc` は初回起動時に vim-plug とプラグインを自動導入する。保存先は Windows が `~/vimfiles`、WSL / Linux が `~/.vim`。`curl` が必要） |
| `.claude/settings.json` | Claude Code のユーザー設定（許可設定のベース） |
| `.config/shell/common.sh` | bash / zsh 共通の alias・関数（fzf は `Ctrl+R` 履歴検索・`Ctrl+T` ファイル検索と、`zfz`（`Alt+j`）/`cdg`（`Alt+k`）で使う。fzf の補完と `Alt+c` は使わない）・zoxide・CA・EDITOR。`.bashrc` / `.zshrc` が source する。コマンド体系は `windows/powershell/profile.ps1` と揃える |
| `.config/{git/config,starship.toml,bat/config}` | git 共通設定 / starship / bat |
| `.config/zed/{settings,keymap}.json`、`.config/zed/themes/` | Zed（Windows は `%APPDATA%\zed` へリンク。`themes/` はジャンクション。自作テーマ Material Gruvbox Dark） |

### `windows/`: Windows 専用

| パス | 内容 |
|---|---|
| `terminal/settings.json` | Windows Terminal |
| `startup/startup.bat` | スタートアップ。`subst V: %WORKS_DIR%` |
| `wsl/.wslconfig` | WSL2 の全体設定（`%USERPROFILE%\.wslconfig` へリンク）。アイドル時にキャッシュのメモリをホストへ返す。`memory` などの上限は PC ごとに RAM が違うので書かない。反映は `wsl --shutdown` 後の再起動 |
| `powershell/history.seed.txt` | PSReadLine の履歴の種（手で選んだ定型コマンド。個人値は `<…名>` に置換済みで、そのままでは実行されない）。正本は共有リポジトリ `workbase`（`$HOME\works\resources`）の `exmem/knowledge/shell-command-usecases.md`。リンクではなく、初回に履歴ファイルが無いときだけコピーする（`scripts\windows\31_history_seed.bat`） |
| `claude/` | Claude Code の API キー認証用と、Amazon Bedrock 用（手順・保管方法・モデル ID の取得・費用の上限・Bedrock 版の手順は `windows/claude/README.md`）。起動する認証は `profile.ps1` の関数で選ぶ（`claude-pick`、`claude-oauth`、`claude-api`、`claude-bedrock`）。Bedrock 版は、`claude-bedrock-setup.ps1` / `.cmd`（AWS CLI で推論プロファイルの一覧を取り、この PC 専用の `%USERPROFILE%\.claude\bedrock.settings.json` を生成する）と、関数 `claude-bedrock`。実値は持たず、生成したファイルは追跡しない。`api.settings.json`（`apiKeyHelper` とモデルの環境変数。`claude-api` が `--settings` で読む）、`claude-api-key.ps1` / `.cmd`（DPAPI で暗号化したキーを復号して返す `apiKeyHelper`）。`claude` は OAuth のまま。キーは追跡しない（初回は `claude-api-key.cmd -Set` で保存。暗号化ファイルは `%USERPROFILE%\.claude\api-key.dpapi`、この PC・このユーザーだけが復号できる） |
| `powershell/profile.ps1` | PowerShell プロファイル（starship / lsd / zoxide / Emacs キーバインド）。起動を軽くするため、ツール不在時の代替・`cd` 後の自動 `ll`・PSFzf は持たない。コマンド体系は `home/.config/shell/common.sh` と揃える（基本エイリアスのみ。`Ctrl+r`/`Ctrl+t` の fzf と `zfz` = `Alt+j`、`cdg` = `Alt+k` は3シェル共通。PSFzf は使わず自前ハンドラ） |
| `obsidian/.obsidian/` | Obsidian の設定（テーマ、CSS スニペット、プラグイン `colored-tags`、`app.json` など）。`links.map` で `%WORKS_DIR%\.obsidian` へジャンクションを張る。`workspace.json`（端末ごとの状態）は追跡しない |
| `office/` | Office のテンプレ（`.potx` `.xltx` `.dotm` `.thmx` など）、UI 設定（`.exportedUI`）、サンプル。配置は手動（リンクしない）: テンプレは `%APPDATA%\Microsoft\Templates` と `%APPDATA%\Microsoft\Excel\XLSTART`、UI は Office の「リボンのユーザー設定 → インポート」 |
| `autohotkey/` `notepadpp/` `drawio/` | 各アプリの設定（Notepad++ はテーマと `config.min.xml`（初回だけ `20_apps.bat` が `config.xml` として置く最小構成）のみ。アプリが書き換えるファイルは追跡しない） |

### 新しい設定をどこに置くか

1. WSL / Linux でも使う（`~` 以下に置けるもの）→ `home/` に、`~` からの相対パスで置く
2. Windows にしかないアプリの設定 → `windows/<アプリ名>/`
3. 配置しない雛形 → `templates/`
4. 使わなくなったもの → 削除する（履歴に残るので復元できる）

置いたら `manifests/links.map`（Windows）に1行足す。`home/` に置いたものは WSL では自動で展開される。

## スクリプトの命名規則

`scripts/<windows|linux>/<NN>_<内容>.<bat|sh>`

- OS はディレクトリで表す（ファイル名に `w` / `l` は付けない）
- 十の位 = 層（実行順）: `10` 環境・ディレクトリ、`20` アプリ/パッケージ導入、`30` リンク、`40` OS 機能（WSL 有効化など）、`50` リポジトリ取得
- 一の位 = 同じ層の中身: `0` は層の本体、`1` 以降は固有ツール（`11` = git の名前・メール、`23` = 日本語入力（Linux のみ）、`24` = フォント、`31` = 履歴の種（Windows は PSReadLine、Linux は zsh/bash））。Windows と Linux で同じ番号は同じ役割（片方にしかないものは欠番）。WSL とネイティブ Linux は同じスクリプトで、WSL 固有の挙動は `is_wsl` で分ける
- 任意で実行するものは `optional/` に置く（番号なし）
- `.bat` のコメントは ASCII（英語）で書く。日本語（UTF-8）のコメントは、コードページ 932 のコンソールで行末のバイトが次の行と混ざり、意図しないコマンドやゴミファイルが生まれることがある
- 家用のアプリの追加分は `apps.home.txt` のように `.home.` を挟んだファイルに書く（`manifests/`）。リンクの map は共通の `links.map` のみ

## セットアップ手順

### Windows

0. **事前準備（手動）**
   - 設定 → 開発者向け で「開発者モード」をオンにする（管理者権限なしで symlink を作るため。必須。オフだと `30_link.bat` は `[ERR]` になる）
   - scoop と git を入れ、clone する（冒頭の「クイックスタート」の4行。このパス構成が前提。**最初から ghq の場所に clone する**ので、zip の取得や、dotfiles の二重取得・`30_link` のやり直しは要らない）。git は最初から scoop のもの1種類だけにする（winget の git は使わない。管理者権限が要らず、PATH の優先順位の問題も起きない）
     非公開の場合は、`git clone` で GitHub のサインイン（Git Credential Manager。scoop の git に同梱）が開く（公開の場合は出ない）。zip での取得は使わない（`.git` が無く、あとで ghq の場所と食い違う）。すでに winget の git が入っているPCは、一度だけ `winget uninstall --id Git.Git -e` で消す
     Obsidian の Vault `$HOME\works`（`WORKS_DIR`）は、この PC だけのローカルなディレクトリ（ローカルのリポジトリ。remote なし、または非公開）で、clone しない。作り方は、共有リポジトリ `workbase` の `workflow-kit` を参照する。`.obsidian` は `30_link.bat` が、`windows\obsidian\.obsidian` から `WORKS_DIR` へジャンクションで張る（`WORKS_DIR` が無ければ作る）。共有リポジトリ `workbase` は、`50_repos.bat` が `WORKS_DIR\resources` に clone する（ghq の管理外）。Office のテンプレと UI 設定は自動では張らない。初回に `windows\office` から手で配置する（配置先は上の `windows/` の表）。
     Obsidian を最初に開く前に `30_link.bat` を実行する。先に Obsidian が実ディレクトリの `.obsidian` を作ると、`30_link.bat` が `[ERR]` で止まる（手で退避して再実行する）。
1. `scripts\windows\10_env.bat`: `setx` で環境変数（`XDG_*`、`WORKS_DIR=%USERPROFILE%\works`、`GHQ_ROOT=%WORKS_DIR%\repos`、`CERTS_DIR` など。`WORKS_DIR` と `CERTS_DIR` は `WSLENV` で WSL へ渡す）を設定し、ディレクトリを作る。`XDG_BIN_HOME=%USERPROFILE%\.local\bin`（Claude Code の置き場）も設定し、ユーザー PATH に `%XDG_BIN_HOME%` を1回だけ足す。**実行後は新しいターミナルを開く**（現在のセッションには反映されない）
   - `scripts\windows\optional\capslock_to_ctrl.reg`（任意）: CapsLock を Ctrl にする。管理者権限が必要で、再起動後に有効。元に戻すときは `capslock_default.reg`
   - `scripts\windows\11_git_identity.bat`: `~\.gitconfig_local`（PC ごとの git の名前・メール）が無いときだけ、`user.name` / `user.email` を対話的に聞いて作る（`credential.helperselector.selected = manager` は `home\.gitconfig` に静的に持つので書かない。SSL バックエンドを schannel にするかも聞く: `y` で `http.sslBackend = schannel` と `http.sslVerify = true` を書き、`n`・空は何も書かず既定の OpenSSL のまま）。既にあれば触らない。**`30_link.bat` の前に**実行する（git が必要。手順 0 で入れた scoop の git でよい）。`git config --global` は使わない: リンク前は実ファイルの `~\.gitconfig` ができて `30_link.bat` が `[ERR]` になり、リンク後はリポジトリ内の `home\.gitconfig` を書き換えてしまうため。`~\.gitconfig` が `include` するので、読まれるのは `30_link.bat` の後。無効な入力は5回で `[ERR]`（入力が閉じていても無限ループしない）
2. `scripts\windows\20_apps.bat [home]`: scoop と bucket を導入し、アプリを入れる（手順 0 で scoop を入れていれば、導入は skip する。git は先に入る）
   - PC1: `20_apps.bat`（`apps.txt` のみ）
   - PC2: `20_apps.bat home`（`apps.txt` + `apps.home.txt`）
   - Notepad++ の `config.xml` が無い/空のときだけ、`windows\notepadpp\config.min.xml`（タブ幅 2、新規文書 LF、折り返し、スナップショットバックアップ、ダークテーマ、自動更新オフなど）をコピーする。既にあれば触らない。リンクではないので、以後はアプリが自由に書き換える。最小構成を適用し直したいときは `config.xml` を削除（または空に）して再実行する
   - `scripts\windows\23_claude.bat`（任意）: Claude Code を公式インストーラ（`irm https://claude.ai/install.ps1 | iex`）で入れる。実行前に `y/N` を聞き、空・`n` なら何も入れない（無効な入力は5回で `[ERR]`）。scoop の `claude-code` は使わない（`apps.txt` から削除）
   - `scripts\windows\24_fonts.bat`: PlemolJP NF（`manifests\fonts.txt`）の latest を `gh` で `%USERPROFILE%\download` へ取得する。インストールは手動（展開して .ttf を右クリック → 現在のユーザーにインストール）。`gh auth login` は不要。出力は `tmp\24_fonts.log`（Git 対象外、実行のたびに上書き）にも残り、最後に `pause` で止まる。ダウンロードが1件でも失敗したら終了コード 1
3. `scripts\windows\30_link.bat [link|unlink] [-n]`: `manifests\links.map` に従ってリンクを張る（ファイルは symlink、ディレクトリは junction。既存のリンクは張り直す）
   - `unlink`: リンクだけ削除する。`-n`: ドライラン
   - 配置先に実ファイル/実ディレクトリがあると `[ERR]` を出してそのエントリを飛ばし、最後に非ゼロで終了する。**自動退避はしない**。中身を確認して手で退避/削除し、再実行する
   - `[ERR] mklink failed` は開発者モードがオフのときに出る
   - `scripts\windows\31_history_seed.bat [-n]`: `windows\powershell\history.seed.txt` を PSReadLine の履歴ファイルへコピーする。履歴ファイルが無い/空のときだけ行い、既存の履歴は上書きしない（`-n`: 確認のみ）。リンクではないので、以後は PSReadLine が自由に追記する。**最初の pwsh を開く前に**実行する。出力は `tmp\31_history_seed.log`（Git 対象外、実行のたびに上書き）にも残り、最後に `pause` で止まる
4. `scripts\windows\40_wsl_enable.bat`（WSL を使う場合）: 管理者権限で実行。WSL2 の機能を有効化する。**再起動後**、表示される `wsl --update` / `wsl --install -d Ubuntu-24.04` を手動で実行する
5. `scripts\windows\50_repos.bat`: ghq で必要なリポジトリを取得する（dotfiles 自身は手順 0 で取得済みなので、ここでは取得しない）。共有リポジトリ `workbase` は、ghq でなく `git clone` で `%WORKS_DIR%\resources` に取得する（既にあれば skip。`WORKS_DIR` が未設定なら `[ERR]`）

### WSL (Ubuntu 24.04) / Linux (apt 系)

WSL は Ubuntu の初期ユーザー作成後、WSL 内で次を順に実行する（Windows 側の clone を `/mnt/c/Users/<Windows のユーザー名>/works/repos/...` から参照する）。ネイティブ Linux は、OS を入れて、冒頭の「クイックスタート（ネイティブ Linux）」で `~/works/repos/github.com/yuzucha16/dotfiles` に clone してから実行する（OS のインストール手順は works の `resources/cheatsheets/env/debian-family.md`）。`30_link.sh` は、置かれているリポジトリを自動で `--src` にするので、どちらでも同じ呼び方になる。Vault のトップ `WORKS_DIR` は、WSL では `/mnt/c/Users/<Windows のユーザー名>/works`（Windows 側と共有）、ネイティブ Linux では `~/works`（`home/.profile` が既定値を設定する。`~/.config/profile.local` で上書きできる）。

1. `scripts/linux/10_dirs.sh`: XDG ディレクトリ、`~/.local/bin`、`~/.ssh`、`~/works/{build,tools}` を作る
   - `scripts/linux/11_git_identity.sh`: `~/.gitconfig_local`（PC ごとの git の名前・メール）が無いときだけ、`user.name` / `user.email` を対話的に聞いて作る（Windows の `11_git_identity.bat` と同じ。既にあれば触らない）。**`30_link.sh` の前に**実行する（git が必要。ネイティブ Linux はクイックスタートで入っている。WSL は Ubuntu 標準の git か、`20_packages.sh` の後）。`git config --global` は使わない（理由は Windows 版と同じ。`~/.gitconfig` は `30_link.sh` が張る symlink）。`credential.helperselector`（Git Credential Manager）は Windows 版も書かず、`home/.gitconfig` に静的に持つ。無効な入力は5回で `[ERR]`
2. `scripts/linux/20_packages.sh [desktop]`: apt の更新、`manifests/apt.txt` のパッケージ（git / curl / wget / zsh と CLI ツール）の導入、starship、ghq（ビルド済みバイナリを `~/.local/bin` へ。Go は不要）の導入、`bat` / `fd` のリンク作成。ネイティブ Linux のデスクトップは `desktop` を付けて `apt.desktop.txt` も入れる。Docker や Go は入れない（下の「必要なときだけ入れるもの」）
   - `scripts/linux/23_ja.sh`（ネイティブ Linux のみ。WSL では何もしない）: fcitx5 + Mozc、日本語フォントを入れる。Ubuntu 系は言語パックも入れる。入れたら再ログインして、Fcitx 5 設定で Mozc を追加する（手動）
   - `scripts/linux/24_fonts.sh`: PlemolJP NF の latest を `gh` で `~/download` へ取得する（WSL でも WSL 側の `~/download`）。インストールは手動。`gh auth login` は不要。1件失敗しても残りは続け、最後に `[ERROR]` と終了コード 1（Windows の `24_fonts.bat` と同じ）
3. `scripts/linux/30_link.sh [link|unlink] [-n]`: stow で `home/` を `~` に展開する（Windows の `30_link.bat` と同じ引数）。リンク切れの旧 symlink は削除する。展開先に実ファイルがあると `[ERR]` を出して止まる（自動退避はしない。手で退避/削除して再実行）。終わったら `chsh -s /usr/bin/zsh`
   - ネイティブ Linux のみ: `windows/obsidian/.obsidian` を `$WORKS_DIR/.obsidian`（`~/works/.obsidian`）へ symlink する（親が無ければ作る。`unlink` で外れる）。実ディレクトリがあると `[ERR]` で止まる（Obsidian を先に開くと、実ディレクトリができる。手で退避して再実行）。WSL では何もしない（Windows 側の `30_link.bat` が張るジャンクションを `/mnt/c` 越しに共有する）
   - `scripts/linux/31_history_seed.sh [-n]`: `manifests/history.seed.sh.txt` を `~/.local/state/{zsh,bash}/history`（`XDG_STATE_HOME` があればその下）へコピーする。履歴が無い/空のときだけ行い、既存の履歴は上書きしない（`-n`: 確認のみ）。リンクではないので、以後はシェルが自由に追記する。**最初のシェルを開く前に**実行する
4. `scripts/linux/50_repos.sh`: 共有リポジトリ `workbase` を、ネイティブ Linux では `$WORKS_DIR/resources` に `git clone` する（ghq の管理外。既にあれば skip。`WORKBASE_URL` で URL を変えられる）。WSL では、Windows 側の `50_repos.bat` が clone するので、無ければ `[WARN]` を出すだけ。そのあと、ghq で参照用リポジトリを取得する

### スクリプトの試験（WSL / Linux）

`bash tests/linux/test_scripts.sh` で、`scripts/linux/*.sh` と `home/.profile` を試験する（終了コード = 失敗数。50項目）。`scripts/linux/` や `home/.profile` を変えたら実行する。

- 一時ディレクトリと偽の HOME だけを使い、実環境の `~` は変更しない。ネットワークも使わない（`ghq` は偽物、clone 元はローカルの bare リポジトリ）。
- WSL とネイティブ Linux の分岐は、環境変数 `PROC_VERSION_FILE`（`/proc/version` の差し替え）で強制する。どちらの環境でも、両方の分岐を試験できる。実環境を見る項目は、WSL でないとき等は skip する。
- 観点: 構文と改行コード、`WORKS_DIR` の分岐、`clone_workbase`（新規・skip・非空のディレクトリ・空のディレクトリ）、`link_obsidian`（dry-run・再リンク・unlink・実体があれば `[ERR]`・リンク切れ・元が無い）、`30_link.sh` の通し、`50_repos.sh`、`11_git_identity.sh`（新規・skip・空入力・`@` なし・特殊文字・入力が閉じている・git なし）、`24_fonts.sh`（偽の `gh` で、成功・1件失敗しても続行・`gh` なし）。`stow` が無いと、`30_link.sh` の通しは skip する。
- 新しいスクリプトや関数を足したときは、同じ観点（新規作成、再実行、dry-run、元に戻す、実体があれば止まる）で項目を足す。

### スクリプトの試験（Windows）

`pwsh -NoProfile -File tests/windows/test_20_apps.ps1` で、`scripts/windows/20_apps.bat` の Scoop 導入の分岐と、VC++ ランタイム表示の色、`scripts/windows/*.bat` が ASCII だけであることを試験する（終了コード = 失敗数。28項目）。`pwsh -NoProfile -File tests/windows/test_11_git_identity.ps1` で、`11_git_identity.bat` を試験する（15項目。偽の `USERPROFILE` と、ファイルのリダイレクトで渡す入力を使う。`set /p` は標準入力がパイプだと2行目以降を取りこぼすため）。偽の `USERPROFILE`、環境変数 `PS_EXE` で差し替えた偽の powershell、偽の `scoop.cmd` だけを使い、ネットワークにも実環境の scoop にも触れない（観点: scoop が無く導入成功、導入失敗、scoop が既にある。バット内の PowerShell 部分は取り出して、実効ポリシー5種と、設定失敗時の続行を試験する）。実際の導入は、新しいアカウントか VM で確認する。`pwsh -NoProfile -File tests/windows/test_claude_bedrock_setup.ps1` で、`windows/claude/claude-bedrock-setup.ps1` を試験する（24項目。偽の `aws` 関数と、PATH から `aws` を外した実行だけを使い、AWS にも実環境の `~/.claude` にも触れない）。`pwsh -NoProfile -File tests/windows/test_claude_launchers.ps1` で、`profile.ps1` の Claude Code 起動関数 4つを試験する（14項目。AST で関数だけ取り出し、偽の `claude` と `fzf` を使う）。

### 必要なときだけ入れるもの（WSL・手動）

- Docker Engine: `curl -fsSL https://get.docker.com | sudo sh` → `sudo usermod -aG docker $USER` → WSL に再ログイン
- Go: <https://go.dev/doc/install> の手順で `/usr/local/go` へ。PATH は `~/.config/profile.local` に `export PATH="/usr/local/go/bin:$PATH"` を書く
- npm / Python のユーザー bin などの PATH も、必要なら同じく `profile.local` に書く

## PC ごとの個別設定（リポジトリに入れないもの）

- git のユーザー名・メールアドレス: `~/.gitconfig_local`（`home/.gitconfig` が include する）
- プロキシの CA 証明書: `%CERTS_DIR%\company-ca.crt`（`%USERPROFILE%\.certs`。`10_env.bat` が作る）。WSL へは `WSLENV`（`CERTS_DIR/p`）で `$CERTS_DIR` として渡る（`/mnt/c/...` を直接読まない）。環境変数が無い Linux では `~/.certs`。あれば `NODE_EXTRA_CA_CERTS` に設定される
- シェルの個別上書き: `~/.config/{profile,bashrc,zshrc}.local`
- PC1,PC2の差分: `manifests/apps.<profile>.txt`

## 日常の運用

| やりたいこと | 方法 |
|---|---|
| アプリを追加 | `manifests/apps.txt`（共通）か `apps.home.txt`（家のみ）に1行追記 |
| 設定ファイルのリンクを追加 | `manifests/links.map` に `リポジトリ相対パス\|リンク先` を1行追記（WSL は `home/` に置けば stow が自動で張る） |
| アプリが書き換えた設定を取り込む | リンクなら自動で反映されている |
| zsh の補完を追加したのに効かない | 補完キャッシュ (`compinit -C`) を作り直す: `rm ~/.zcompdump*` して zsh を開き直す（`20_packages.sh` は自動で消す） |
| 構成を変えた後に他のPCへ反映 | `git pull` → Windows は `30_link.bat`、WSL は `30_link.sh` を再実行 |
| コミットメッセージ | `[対象] 内容`（例: `[zed] ...`, `[scripts] ...`） |

アプリが自動で書き換える状態ファイル（Obsidian の `workspace.json` など）は追跡しない。`.gitignore` に追加する。

## exmem との関係

exmem（`$HOME\works\resources\exmem`。共有リポジトリ `workbase` の一部）は、AIとの壁打ちで得たナレッジの置き場。dotfiles は exmem を**基本は読み取り専用で参照するだけ**。作業の経緯・決定・次にやることは、このリポジトリの `docs/` に残す。書き込みの唯一の例外は、エージェントに「ナレッジ化して」と指示したとき、`exmem/inbox/` に再利用できる知識を1ファイル置くこと（手順と形式は共通機能 `works/resources/workflow-kit/knowledge-hook.md`）。

- 参照するもの: 履歴の種の本文（`exmem/knowledge/shell-command-usecases.md`。種ファイルはその派生物）。
- 手順書は `workbase` の `cheatsheets/env/`（`$HOME\works\resources\cheatsheets\env\`）。

## 履歴リセット (2026-10-02)

大きなフォント・プラグインの blob を履歴から消すため、履歴を1コミットに作り直して強制 push した（40MB → 約1MB）。以前の履歴は `$HOME\backup\dotfiles-before-rebuild-*.bundle`（このリポジトリを作業していたPC）に残してある。
他のPCの clone は、未 push の変更が無いことを確認してから次を実行する。

```powershell
git fetch origin
git reset --hard origin/main
git gc --prune=now
```

その後、通常どおり `30_link.bat`（Windows）/ `30_link.sh`（WSL）を再実行する。

## 既知の課題

- Office のテンプレと UI 設定、`.obsidian` は、2026-10-03 に `notes` リポジトリへ移管したが、2026-10-05 に dotfiles（`windows/office/`、`windows/obsidian/.obsidian/`）へ戻した（Vault を PC ローカルのリポジトリと共有の `workbase` に分けたため。Office の配置は手動）。
- Linux（WSL / ネイティブ）の `workbase` の clone（`50_repos.sh`）、`.obsidian` のリンク（`30_link.sh`、ネイティブのみ）、`WORKS_DIR`（`home/.profile`）は、2026-10-05 に対応した。WSL（Ubuntu 24.04）の実機で、一時ディレクトリと偽の HOME を使って35項目を試験した（ネイティブ Linux の分岐は、`PROC_VERSION_FILE` で差し替えて再現した。ネイティブ Linux の実機は未確認）。ワークスペース生成フックの既定の対象 `$HOME\works` は Windows と WSL の標準の場所なので、ネイティブ Linux では対象を言葉で指定する（例: `~/works`）。
- `10_dirs.sh` が作る `~/works`（WSL 自身の作業用。`GHQ_ROOT` の既定も `~/works/repos`。Windows と同じ並びにそろえた。2026-10-06 に `~/vault` から改めた）と、Windows の `%USERPROFILE%\works` は別物（後者は WSL から `/mnt/c/Users/<Windows のユーザー名>/works` で見える。2026-10-06 に `C:\vault` から移した）
