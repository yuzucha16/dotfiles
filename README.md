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
├── docs/           作業ログ（log.md: 現在状態と次にやること、log-history.md: 経緯）と判断の記録（decisions.md: 根拠・却下案・Gotchas）
├── scripts/
│   ├── windows/    10〜50 のセットアップスクリプト（`optional/` は任意の .reg）。仕様は `README.md`
│   └── linux/      10〜50 のセットアップスクリプト（WSL とネイティブ Linux 共通。違いは `lib.sh` の `is_wsl` などで分岐）。仕様は `README.md`
├── manifests/      スクリプトが読むリスト（apps / apt / links）
├── tests/          スクリプトの試験（一覧と観点は `README.md`。下の「スクリプトの試験」）
├── home/           ~ を鏡写しにした共有ツリー（WSL は stow、Windows は links.map でリンク）
├── windows/        Windows 専用の設定（links.map からだけ参照される。一覧は `README.md`）
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

`links.map` からだけ参照される。パスごとの内容（Terminal、WSL の設定、PowerShell のプロファイル、Claude Code の認証、Obsidian、Office、Notepad++ など）は `windows/README.md`。Claude Code の認証の手順は `windows/claude/README.md`。
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

順序と要点だけを書く。各スクリプトの仕様（引数、入力、出力、失敗時の挙動）は `scripts/windows/README.md` と `scripts/linux/README.md`。

### Windows

0. 事前準備（手動）: 「開発者モード」をオンにする（必須。オフだと `30_link.bat` が `[ERR]`）。クイックスタートの4行で scoop と git を入れ、ghq の場所に clone する。git は scoop の1種類だけ（winget の git は使わない）。Obsidian を最初に開く前に `30_link.bat` を実行する。
1. `10_env.bat`: 環境変数（`WORKS_DIR` `GHQ_ROOT` `CERTS_DIR` など）とディレクトリ。**実行後は新しいターミナルを開く**。`11_git_identity.bat`: `~\.gitconfig_local` を作る（`30_link.bat` の前に実行する）。`optional/` に CapsLock を Ctrl にする `.reg`。
2. `20_apps.bat [home]`: scoop とアプリ。PC1 は引数なし、PC2 は `home`。続けて必要なものを個別に: `23_claude`（Claude Code）、`24_fonts`、`25_awscli`、`26_uv`、`27_volta`（25〜27 は `10_env.bat` の後）、`28_npm_globals`（27 の後）、`29_claude_plugins`（23 の後）。
3. `30_link.bat [link|unlink] [-n]`: `manifests\links.map` に従ってリンクを張る。配置先に実体があると `[ERR]` でそのエントリを飛ばす（**自動退避はしない**。手で退避して再実行）。`31_history_seed.bat`: PSReadLine の履歴の種（最初の pwsh の前に）。
4. `40_wsl_enable.bat`（WSL を使う場合。管理者権限）: WSL2 を有効化。再起動後に `wsl --update` と `wsl --install -d Ubuntu-24.04`。
5. `50_repos.bat`: ghq で参照用リポジトリを取得。共有リポジトリ `workbase` は `%WORKS_DIR%\resources` に `git clone`。

### WSL (Ubuntu 24.04) / Linux (apt 系)

WSL は Ubuntu の初期ユーザー作成後、WSL 内で実行する（Windows 側の clone を `/mnt/c/Users/<Windows のユーザー名>/works/repos/...` から参照する）。ネイティブ Linux は、クイックスタートで clone してから実行する（OS の手順は `resources/guides/howto/debian-family.md`）。`WORKS_DIR` は、WSL では `/mnt/c/Users/<Windows のユーザー名>/works`（Windows 側と共有）、ネイティブでは `~/works`（`~/.config/profile.local` で上書きできる）。

1. `10_dirs.sh`: XDG ディレクトリなど。`11_git_identity.sh`: `~/.gitconfig_local`（`30_link.sh` の前）。
2. `20_packages.sh [desktop]`: apt のパッケージ、starship、ghq。続けて必要なものを個別に: `23_ja.sh`（ネイティブのみ）、`24_fonts.sh`、`25_arm_gcc.sh`。
3. `30_link.sh [link|unlink] [-n]`: stow で `home/` を `~` に展開（実体があると `[ERR]` で止まる）。終わったら `chsh -s /usr/bin/zsh`。`31_history_seed.sh`: 履歴の種（最初のシェルの前に）。
4. `50_repos.sh`: `workbase` を `$WORKS_DIR/resources` に clone（WSL では Windows 側の `50_repos.bat` が行う）。ghq で参照用リポジトリを取得。

### スクリプトの試験

`bash tests/linux/test_scripts.sh`（WSL / Linux。`scripts/linux/` や `home/.profile` を変えたら実行する。終了コード = 失敗数）、`pwsh -NoProfile -File tests/windows/test_*.ps1`（Windows）。観点と各ファイルの内容は `tests/README.md`。新しいスクリプトや関数を足したら、同じ観点（新規作成、再実行、dry-run、元に戻す、実体があれば止まる）で項目を足す。
### 必要なときだけ入れるもの（WSL・手動）

- Docker Engine: `curl -fsSL https://get.docker.com | sudo sh` → `sudo usermod -aG docker $USER` → WSL に再ログイン
- Go: <https://go.dev/doc/install> の手順で `/usr/local/go` へ。PATH は `~/.config/profile.local` に `export PATH="/usr/local/go/bin:$PATH"` を書く
- npm / Python のユーザー bin などの PATH も、必要なら同じく `profile.local` に書く

## PC ごとの個別設定（リポジトリに入れないもの）

- git のユーザー名・メールアドレス: `~/.gitconfig_local`（`home/.gitconfig` が include する）
- プロキシの CA 証明書: `%CERTS_DIR%\ca_bundle.crt`（`%USERPROFILE%\.certs`。`10_env.bat` が作る）。WSL へは `WSLENV`（`CERTS_DIR/p`）で `$CERTS_DIR` として渡る（`/mnt/c/...` を直接読まない）。環境変数が無い Linux では `~/.certs`。あれば `NODE_EXTRA_CA_CERTS` に設定される（Linux/WSL。Windows は `27_volta.bat` が `setx` で設定する）。`10_env.bat` は最後に、証明書が要る場合は `ca_bundle.crt` をここへ置くようオレンジで案内する（何も作らない・確認しない）
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

exmem（`$HOME\works\resources\exmem`。共有リポジトリ `workbase` の一部）は、AIとの壁打ちで得たナレッジの置き場。dotfiles は exmem を**基本は読み取り専用で参照するだけ**。作業の経緯・決定・次にやることは、このリポジトリの `docs/` に残す。書き込みの唯一の例外は、エージェントに「ナレッジ化して」と指示したとき、`exmem/inbox/` に再利用できる知識を1ファイル置くこと（手順と形式は共通機能 `works/resources/workflow-kit/stock-hook.md`）。

- 参照するもの: 履歴の種の本文（`exmem/knowledge/shell-command-usecases.md`。種ファイルはその派生物）。
- 手順書は `workbase` の `guides/howto/`（`$HOME\works\resources\guides\howto\`）。

## 既知の課題

- Office のテンプレと UI 設定、`.obsidian` は、2026-10-03 に `notes` リポジトリへ移管したが、2026-10-05 に dotfiles（`windows/office/`、`windows/obsidian/.obsidian/`）へ戻した（Vault を PC ローカルのリポジトリと共有の `workbase` に分けたため。Office の配置は手動）。
- Linux（WSL / ネイティブ）の `workbase` の clone（`50_repos.sh`）、`.obsidian` のリンク（`30_link.sh`、ネイティブのみ）、`WORKS_DIR`（`home/.profile`）は、2026-10-05 に対応した。WSL（Ubuntu 24.04）の実機で、一時ディレクトリと偽の HOME を使って35項目を試験した（ネイティブ Linux の分岐は、`PROC_VERSION_FILE` で差し替えて再現した。ネイティブ Linux の実機は未確認）。ワークスペース生成フックの既定の対象 `$HOME\works` は Windows と WSL の標準の場所なので、ネイティブ Linux では対象を言葉で指定する（例: `~/works`）。
- `10_dirs.sh` が作る `~/works`（WSL 自身の作業用。`GHQ_ROOT` の既定も `~/works/repos`。Windows と同じ並びにそろえた。2026-10-06 に `~/vault` から改めた）と、Windows の `%USERPROFILE%\works` は別物（後者は WSL から `/mnt/c/Users/<Windows のユーザー名>/works` で見える。2026-10-06 に `C:\vault` から移した）
