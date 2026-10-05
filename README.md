# dotfiles

Windows 11 + WSL (Ubuntu 24.04) / Linux (apt 系: MX / Ubuntu / Mint) の開発環境を、複数PCで同じ状態に再現するための設定とセットアップスクリプト。

- PC1は最小構成、PC2は追加分を足す、という運用。差分は `*.home.*` のファイルに分離している。
- 設定ファイルはこのリポジトリを正とし、各アプリの場所へシンボリックリンクで配置する（Windows: `30_link.bat`、WSL / Linux: `30_link.sh`/stow）。

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
| `startup/startup.bat` | スタートアップ。`subst V: C:\vault` |
| `wsl/.wslconfig` | WSL2 の全体設定（`%USERPROFILE%\.wslconfig` へリンク）。アイドル時にキャッシュのメモリをホストへ返す。`memory` などの上限は PC ごとに RAM が違うので書かない。反映は `wsl --shutdown` 後の再起動 |
| `powershell/history.seed.txt` | PSReadLine の履歴の種（手で選んだ定型コマンド。個人値は `<…名>` に置換済みで、そのままでは実行されない）。正本は共有リポジトリ `workbase`（`C:\vault\notes\resources`）の `exmem/knowledge/shell-command-usecases.md`。リンクではなく、初回に履歴ファイルが無いときだけコピーする（`scripts\windows\31_history_seed.bat`） |
| `powershell/profile.ps1` | PowerShell プロファイル（starship / lsd / zoxide / Emacs キーバインド）。起動を軽くするため、ツール不在時の代替・`cd` 後の自動 `ll`・PSFzf は持たない。コマンド体系は `home/.config/shell/common.sh` と揃える（基本エイリアスのみ。`Ctrl+r`/`Ctrl+t` の fzf と `zfz` = `Alt+j`、`cdg` = `Alt+k` は3シェル共通。PSFzf は使わず自前ハンドラ） |
| `obsidian/.obsidian/` | Obsidian の設定（テーマ、CSS スニペット、プラグイン `colored-tags`、`app.json` など）。`links.map` で `%NOTES_DIR%\.obsidian` へジャンクションを張る。`workspace.json`（端末ごとの状態）は追跡しない |
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
- 一の位 = 同じ層の中身: `0` は層の本体、`1` 以降は固有ツール（`23` = 日本語入力（Linux のみ）、`24` = フォント、`31` = 履歴の種（Windows は PSReadLine、Linux は zsh/bash））。Windows と Linux で同じ番号は同じ役割（片方にしかないものは欠番）。WSL とネイティブ Linux は同じスクリプトで、WSL 固有の挙動は `is_wsl` で分ける
- 任意で実行するものは `optional/` に置く（番号なし）
- `.bat` のコメントは ASCII（英語）で書く。日本語（UTF-8）のコメントは、コードページ 932 のコンソールで行末のバイトが次の行と混ざり、意図しないコマンドやゴミファイルが生まれることがある
- 家用のアプリの追加分は `apps.home.txt` のように `.home.` を挟んだファイルに書く（`manifests/`）。リンクの map は共通の `links.map` のみ

## セットアップ手順

### Windows

0. **事前準備（手動）**
   - 設定 → 開発者向け で「開発者モード」をオンにする（管理者権限なしで symlink を作るため。必須。オフだと `30_link.bat` は `[ERR]` になる）
   - git を入れ、次の場所に clone する（このパス構成が前提）
     ```powershell
     winget install Git.Git
     git clone https://github.com/yuzucha16/dotfiles C:\vault\repos\github.com\yuzucha16\dotfiles
     ```
     Obsidian の Vault `C:\vault\notes`（`NOTES_DIR`）は、この PC だけのローカルなディレクトリ（ローカルのリポジトリ。remote なし、または非公開）で、clone しない。作り方は、共有リポジトリ `workbase` の `workflow-kit` を参照する。`.obsidian` は `30_link.bat` が、`windows\obsidian\.obsidian` から `NOTES_DIR` へジャンクションで張る（`NOTES_DIR` が無ければ作る）。共有リポジトリ `workbase` は、`50_repos.bat` が `NOTES_DIR\resources` に clone する（ghq の管理外）。Office のテンプレと UI 設定は自動では張らない。初回に `windows\office` から手で配置する（配置先は上の `windows/` の表）。
     Obsidian を最初に開く前に `30_link.bat` を実行する。先に Obsidian が実ディレクトリの `.obsidian` を作ると、`30_link.bat` が `[ERR]` で止まる（手で退避して再実行する）。
1. `scripts\windows\10_env.bat`: `setx` で環境変数（`XDG_*`、`VAULT_HOME=C:\vault`、`GHQ_ROOT`、`NOTES_DIR` など）を設定し、ディレクトリを作る。**実行後は新しいターミナルを開く**（現在のセッションには反映されない）
   - `scripts\windows\optional\capslock_to_ctrl.reg`（任意）: CapsLock を Ctrl にする。管理者権限が必要で、再起動後に有効。元に戻すときは `capslock_default.reg`
2. `scripts\windows\20_apps.bat [home]`: scoop と bucket を導入し、アプリを入れる
   - PC1: `20_apps.bat`（`apps.txt` のみ）
   - PC2: `20_apps.bat home`（`apps.txt` + `apps.home.txt`）
   - Notepad++ の `config.xml` が無い/空のときだけ、`windows\notepadpp\config.min.xml`（タブ幅 2、新規文書 LF、折り返し、スナップショットバックアップ、ダークテーマ、自動更新オフなど）をコピーする。既にあれば触らない。リンクではないので、以後はアプリが自由に書き換える。最小構成を適用し直したいときは `config.xml` を削除（または空に）して再実行する
   - `scripts\windows\24_fonts.bat`: PlemolJP NF / MoralerspaceHW（`manifests\fonts.txt`）の latest を `gh` で `%USERPROFILE%\download` へ取得する。インストールは手動（展開して .ttf を右クリック → 現在のユーザーにインストール）。`gh auth login` は不要
3. `scripts\windows\30_link.bat [link|unlink] [-n]`: `manifests\links.map` に従ってリンクを張る（ファイルは symlink、ディレクトリは junction。既存のリンクは張り直す）
   - `unlink`: リンクだけ削除する。`-n`: ドライラン
   - 配置先に実ファイル/実ディレクトリがあると `[ERR]` を出してそのエントリを飛ばし、最後に非ゼロで終了する。**自動退避はしない**。中身を確認して手で退避/削除し、再実行する
   - `[ERR] mklink failed` は開発者モードがオフのときに出る
   - `scripts\windows\31_history_seed.bat [-n]`: `windows\powershell\history.seed.txt` を PSReadLine の履歴ファイルへコピーする。履歴ファイルが無い/空のときだけ行い、既存の履歴は上書きしない（`-n`: 確認のみ）。リンクではないので、以後は PSReadLine が自由に追記する。**最初の pwsh を開く前に**実行する
4. `scripts\windows\40_wsl_enable.bat`（WSL を使う場合）: 管理者権限で実行。WSL2 の機能を有効化する。**再起動後**、表示される `wsl --update` / `wsl --install -d Ubuntu-24.04` を手動で実行する
5. `scripts\windows\50_repos.bat`: ghq で必要なリポジトリを取得する。共有リポジトリ `workbase` は、ghq でなく `git clone` で `%NOTES_DIR%\resources` に取得する（既にあれば skip。`NOTES_DIR` が未設定なら `[ERR]`）

### WSL (Ubuntu 24.04) / Linux (apt 系)

WSL は Ubuntu の初期ユーザー作成後、WSL 内で次を順に実行する（Windows 側の clone を `/mnt/c/vault/...` から参照する）。ネイティブ Linux は、OS を入れて `~/vault/repos/github.com/yuzucha16/dotfiles` に clone してから実行する（OS のインストール手順は notes の `resources/cheatsheets/env/debian-family.md`）。`30_link.sh` は、置かれているリポジトリを自動で `--src` にするので、どちらでも同じ呼び方になる。

1. `scripts/linux/10_dirs.sh`: XDG ディレクトリ、`~/.local/bin`、`~/.ssh`、`~/vault/{build,tools}` を作る
2. `scripts/linux/20_packages.sh [desktop]`: apt の更新、`manifests/apt.txt` のパッケージ（git / curl / wget / zsh と CLI ツール）の導入、starship、ghq（ビルド済みバイナリを `~/.local/bin` へ。Go は不要）の導入、`bat` / `fd` のリンク作成。ネイティブ Linux のデスクトップは `desktop` を付けて `apt.desktop.txt` も入れる。Docker や Go は入れない（下の「必要なときだけ入れるもの」）
   - `scripts/linux/23_ja.sh`（ネイティブ Linux のみ。WSL では何もしない）: fcitx5 + Mozc、日本語フォントを入れる。Ubuntu 系は言語パックも入れる。入れたら再ログインして、Fcitx 5 設定で Mozc を追加する（手動）
   - `scripts/linux/24_fonts.sh`: PlemolJP NF / MoralerspaceHW の latest を `gh` で `~/download` へ取得する（WSL でも WSL 側の `~/download`）。インストールは手動。`gh auth login` は不要
3. `scripts/linux/30_link.sh [link|unlink] [-n]`: stow で `home/` を `~` に展開する（Windows の `30_link.bat` と同じ引数）。リンク切れの旧 symlink は削除する。展開先に実ファイルがあると `[ERR]` を出して止まる（自動退避はしない。手で退避/削除して再実行）。終わったら `chsh -s /usr/bin/zsh`
   - `scripts/linux/31_history_seed.sh [-n]`: `manifests/history.seed.sh.txt` を `~/.local/state/{zsh,bash}/history`（`XDG_STATE_HOME` があればその下）へコピーする。履歴が無い/空のときだけ行い、既存の履歴は上書きしない（`-n`: 確認のみ）。リンクではないので、以後はシェルが自由に追記する。**最初のシェルを開く前に**実行する
4. `scripts/linux/50_repos.sh`: ghq で参照用リポジトリを取得する

### 必要なときだけ入れるもの（WSL・手動）

- Docker Engine: `curl -fsSL https://get.docker.com | sudo sh` → `sudo usermod -aG docker $USER` → WSL に再ログイン
- Go: <https://go.dev/doc/install> の手順で `/usr/local/go` へ。PATH は `~/.config/profile.local` に `export PATH="/usr/local/go/bin:$PATH"` を書く
- npm / Python のユーザー bin などの PATH も、必要なら同じく `profile.local` に書く

## PC ごとの個別設定（リポジトリに入れないもの）

- git のユーザー名・メールアドレス: `~/.gitconfig_local`（`home/.gitconfig` が include する）
- プロキシの CA 証明書: `%CERTS_DIR%\company-ca.crt`（WSL では `/mnt/c/vault/certs/company-ca.crt`）。あれば `NODE_EXTRA_CA_CERTS` に設定される
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

exmem（`C:\vault\notes\resources\exmem`。共有リポジトリ `workbase` の一部）は、AIとの壁打ちで得たナレッジの置き場。dotfiles は exmem を**基本は読み取り専用で参照するだけ**。作業の経緯・決定・次にやることは、このリポジトリの `docs/` に残す。書き込みの唯一の例外は、エージェントに「ナレッジ化して」と指示したとき、`exmem/inbox/` に再利用できる知識を1ファイル置くこと（手順と形式は共通機能 `notes/resources/workflow-kit/knowledge-hook.md`）。

- 参照するもの: 履歴の種の本文（`exmem/knowledge/shell-command-usecases.md`。種ファイルはその派生物）。
- 手順書は `workbase` の `cheatsheets/env/`（`C:\vault\notes\resources\cheatsheets\env\`）。

## 履歴リセット (2026-10-02)

大きなフォント・プラグインの blob を履歴から消すため、履歴を1コミットに作り直して強制 push した（40MB → 約1MB）。以前の履歴は `C:\vault\backup\dotfiles-before-rebuild-*.bundle`（このリポジトリを作業していたPC）に残してある。
他のPCの clone は、未 push の変更が無いことを確認してから次を実行する。

```powershell
git fetch origin
git reset --hard origin/main
git gc --prune=now
```

その後、通常どおり `30_link.bat`（Windows）/ `30_link.sh`（WSL）を再実行する。

## 既知の課題

- Office のテンプレと UI 設定、`.obsidian` は、2026-10-03 に `notes` リポジトリへ移管したが、2026-10-05 に dotfiles（`windows/office/`、`windows/obsidian/.obsidian/`）へ戻した（Vault を PC ローカルのリポジトリと共有の `workbase` に分けたため。Office の配置は手動）。
- Linux（WSL / ネイティブ）は、`workbase` の clone（`50_repos.sh`）と `.obsidian` の扱いが未対応（TODO）。`NOTES_DIR` の Linux での値も未確認。
- `10_dirs.sh` が作る `~/vault` と Windows の `C:\vault` は別物（WSL からは `/mnt/c/vault` で見える）
