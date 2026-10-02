# dotfiles

Windows 11 + WSL (Ubuntu 24.04) の開発環境を、複数PC（家・会社）で同じ状態に再現するための設定とセットアップスクリプト。

- 会社PCは最小構成、家PCは追加分を足す、という運用。差分は `*.home.*` のファイルに分離している。
- 設定ファイルはこのリポジトリを正とし、各アプリの場所へシンボリックリンクで配置する（Windows: `w2a`、WSL: `l1`/stow）。

## ディレクトリ

```text
dotfiles/
├── README.md
├── .gitignore
├── scripts/
│   ├── windows/    w0〜w5 のセットアップスクリプト（+ レジストリ .reg）
│   └── wsl/        l0〜l3 のセットアップスクリプト
├── manifests/      スクリプトが読むリスト（apps / links / vscode 拡張）
├── home/           ~ を鏡写しにした共有ツリー（WSL は stow、Windows は links.map でリンク）
├── windows/        Windows 専用の設定（links.map からだけ参照される）
├── templates/      配置しない雛形
└── archive/        現在は使っていないもの
```

### `home/`: `~` の鏡

`home/` の中身は、そのまま `~`（Windows では `%USERPROFILE%`）の下に置かれる。WSL では `stow --no-folding -t ~ home` の1回で全部展開する。

| パス | 内容 |
|---|---|
| `.bashrc` `.zshrc` `.profile` `.zprofile` `.bash_logout` `.zlogout` | シェル設定。`.zprofile` は `.profile` を読むだけ |
| `.vimrc` `.gitconfig` `.gitignore_global` | vim / git |
| `.claude/settings.json` | Claude Code のユーザー設定（許可設定のベース） |
| `.config/shell/common.sh` | bash / zsh 共通の alias・関数・fzf・zoxide・CA・EDITOR。`.bashrc` / `.zshrc` が source する。コマンド体系は `windows/powershell/profile.ps1` と揃える |
| `.config/{git/config,starship.toml,bat/config}` | git 共通設定 / starship / bat |
| `.config/zed/{settings,keymap}.json` | Zed（Windows は `%APPDATA%\zed` へリンク） |

### `windows/`: Windows 専用

| パス | 内容 |
|---|---|
| `terminal/settings.json` | Windows Terminal |
| `startup/startup.bat` | スタートアップ。`subst V: C:\vault` |
| `powershell/profile.ps1` | PowerShell プロファイル（starship / PSFzf / lsd / Emacs キーバインド）。コマンド体系は `home/.config/shell/common.sh` と揃える（`zfz` の Ctrl+g 割当のみ pwsh 固有） |
| `autohotkey/` `notepadpp/` `drawio/` `obsidian/` `vscode/` | 各アプリの設定 |
| `office/` | Word / Excel / PowerPoint のテンプレートと UI 設定（バイナリ。`office/.gitattributes` で binary 指定） |

### 新しい設定をどこに置くか

1. WSL / Linux でも使う（`~` 以下に置けるもの）→ `home/` に、`~` からの相対パスで置く
2. Windows にしかないアプリの設定 → `windows/<アプリ名>/`
3. 配置しない雛形 → `templates/`
4. 使わなくなったが残したいもの → `archive/`（不要なら削除。履歴に残る）

置いたら `manifests/links.map`（Windows）に1行足す。`home/` に置いたものは WSL では自動で展開される。

## スクリプトの命名規則

`scripts/<windows|wsl>/<OS><順序><枝番>_<内容>`

- `w` = Windows、`l` = Linux (WSL)
- 数字 = 実行順。`w0` → `w1` → … の順に実行する
- 英字の枝番 = 同じ段階の別スクリプト。`w0a` は `w0` の任意の追加（CapsLock→Ctrl のレジストリ）、`w1a` はアプリ導入、`w1b` は VS Code 拡張、`w2a` はリンク作成
- `.bat` のコメントは ASCII（英語）で書く。日本語（UTF-8）のコメントは、コードページ 932 のコンソールで行末のバイトが次の行と混ざり、意図しないコマンドやゴミファイルが生まれることがある
- 家用の追加分は `apps.home.txt` / `links.home.map` のように `.home.` を挟んだファイルに書く（`manifests/`）

## セットアップ手順

### Windows

0. **事前準備（手動）**
   - 設定 → 開発者向け で「開発者モード」をオンにする（管理者権限なしで symlink を作るため。オフでも `w2a` はコピーにフォールバックするが、リポジトリの変更が反映されなくなる）
   - git を入れ、次の場所に clone する（このパス構成が前提）
     ```powershell
     winget install Git.Git
     git clone https://github.com/yuzucha16/dotfiles C:\vault\repos\github.com\yuzucha16\dotfiles
     git clone <areas_shared のURL> C:\vault\repos\github.com\yuzucha16\areas_shared
     ```
     `areas_shared` は Obsidian のノート共有用で、`links.map` が `dotfiles` の隣にあることを前提にリンクする。
1. `scripts\windows\w0_xdg_setup.bat`: `setx` で環境変数（`XDG_*`、`VAULT_HOME=C:\vault`、`GHQ_ROOT`、`NOTES_DIR` など）を設定し、ディレクトリを作る。**実行後は新しいターミナルを開く**（現在のセッションには反映されない）
2. `scripts\windows\w0a_do_caps_ctrl.reg`（任意）: CapsLock を Ctrl にする。管理者権限が必要で、再起動後に有効。元に戻すときは `w0a_redo_caps_default.reg`
3. `scripts\windows\w1a_scoop_install.bat [home]`: scoop と bucket を導入し、アプリを入れる
   - 会社: `w1a_scoop_install.bat`（`apps.txt` のみ）
   - 家: `w1a_scoop_install.bat home`（`apps.txt` + `apps.home.txt`）
   - `scripts\windows\w1b_vscode_extensions.bat`: `manifests\vscode-extensions.win.txt` の VS Code 拡張のうち未導入のものを入れる（Zed の拡張は `home/.config/zed/settings.json` の `auto_install_extensions` で起動時に自動導入される）
4. `scripts\windows\w2a_copy_dotfiles.bat [モード] [プロファイル]`: `manifests\links.map` に従って設定を配置する
   - 会社: `w2a_copy_dotfiles.bat`（= `link`）
   - 家: `w2a_copy_dotfiles.bat link home`（プロファイルを指定するときはモードも書く）
   - モード: `link`（既定。symlink / ディレクトリは junction）、`copy`（リポジトリ → 配置先へコピー）、`copyback`（配置先 → リポジトリへコピー。**リポジトリ側が上書きされる**）
5. `scripts\windows\w3_setup_wsl.bat`（WSL を使う場合）: 管理者権限で実行。WSL2 の機能を有効化する。**再起動後**、表示される `wsl --update` / `wsl --install -d Ubuntu-24.04` を手動で実行する
6. `scripts\windows\w4_get_repos.bat`: ghq で必要なリポジトリを取得する
7. `scripts\windows\w5_win_app.bat`: winget で uv を入れ、Python 3.13 を導入する

### WSL (Ubuntu 24.04)

Ubuntu の初期ユーザー作成後、WSL 内で次を順に実行する（Windows 側の clone を `/mnt/c/vault/...` から参照する）。

1. `scripts/wsl/l0_setup.sh`: apt の更新、git / curl / wget / zsh の導入、XDG ディレクトリの作成
2. `scripts/wsl/l0a_apt_install.sh`: CLI ツール、starship、Go（最新版）、ghq、Docker Engine を導入する。Docker はグループ追加後に再ログインが必要
3. `scripts/wsl/l1_copy_dotfiles.sh [--dry-run|--restow|--reset|--unlink]`: stow で `home/` を `~` に展開する。既存の実ファイルは `~/.bak/<日時>/` に退避し、リンク切れの旧 symlink は削除する。終わったら `chsh -s /usr/bin/zsh`
   - `scripts/wsl/l1a_vscode_extensions.sh`: `manifests/vscode-extensions.wsl.txt` の拡張のうち未導入のものを VS Code Server に入れる（`code` コマンドが必要。無ければ Windows の VS Code から一度この WSL を開く）
4. `scripts/wsl/l2_init_workspace.sh`: `~/vault` を作る
5. `scripts/wsl/l3_get_repos.sh`: ghq で参照用リポジトリを取得する

## PC ごとの個別設定（リポジトリに入れないもの）

- git のユーザー名・メールアドレス: `~/.gitconfig_local`（`home/.gitconfig` が include する）
- 社内プロキシの CA 証明書: `%CERTS_DIR%\company-ca.crt`（WSL では `/mnt/c/vault/certs/company-ca.crt`）。あれば `NODE_EXTRA_CA_CERTS` に設定される
- シェルの個別上書き: `~/.config/{profile,bashrc,zshrc}.local`
- 家・会社の差分: `manifests/apps.<profile>.txt` / `manifests/links.<profile>.map`

## 日常の運用

| やりたいこと | 方法 |
|---|---|
| アプリを追加 | `manifests/apps.txt`（共通）か `apps.home.txt`（家のみ）に1行追記 |
| 設定ファイルのリンクを追加 | `manifests/links.map`（共通）か `links.home.map` に `リポジトリ相対パス\|リンク先` を1行追記 |
| VS Code 拡張を追加・削除 | 入れたら `code --list-extensions > manifests/vscode-extensions.win.txt`（WSL は `.wsl.txt`）で書き出してコミット |
| アプリが書き換えた設定を取り込む | リンクなら自動で反映されている。コピー運用のものは `w2a ... copyback` |
| 構成を変えた後に他のPCへ反映 | `git pull` → Windows は `w2a`、WSL は `l1` を再実行 |
| コミットメッセージ | `[対象] 内容`（例: `[zed] ...`, `[w1a] ...`） |

アプリが自動で書き換える状態ファイル（Obsidian の `workspace.json` など）は追跡しない。`.gitignore` に追加する。

## 履歴リセット (2026-10-02)

大きなフォント・プラグインの blob を履歴から消すため、履歴を1コミットに作り直して強制 push した（40MB → 約1MB）。以前の履歴は `C:\vault\backup\dotfiles-before-rebuild-*.bundle`（このリポジトリを作業していたPC）に残してある。
他のPCの clone は、未 push の変更が無いことを確認してから次を実行する。

```powershell
git fetch origin
git reset --hard origin/main
git gc --prune=now
```

その後、通常どおり `w2a`（Windows）/ `l1`（WSL）を再実行する。

## 既知の課題

- `windows/office/` に、リンクされていない参照用ファイル（`samples*.pptx`、`template_A3/A4.pptx`、`slide_layout.pptx`、`*.thmx`、`OneNote.exportedUI`）がある。dotfiles とは性質が違うため、`areas_shared` など別リポジトリへ移管する予定
- `l2_init_workspace.sh` の `~/vault` と Windows の `C:\vault` は別物（WSL からは `/mnt/c/vault` で見える）
- nvim はレイヤ構成のまま先送り（`archive/nvim*`。共通部 `nvim`、Windows 固有 `nvim-win`、WSL 固有 `nvim-wsl`）
