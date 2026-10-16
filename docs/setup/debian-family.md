---
type: howto
title: Debian系 Linux セットアップ手順 (MX / Ubuntu / Mint)
tags:
  - linux
  - setup
  - dotfiles
---

# Debian系 Linux セットアップ手順 (MX / Ubuntu / Mint)

インストール準備から、エディタで dotfiles のテキスト（`README.md`）が開けるところまで。
apt を使うディストロ（MX Linux、Ubuntu、Linux Mint）を1本にまとめ、違う部分は各章の末尾の「ディストロ差分」の表に書く。

- 前提: **Windows 11 と Linux を複数台入れる、マルチブート**（Windows → Linux 2〜3 台）。SWAP は 8GB、ディスクは **非暗号化**
- Windows 側の準備（先に入れる、高速スタートアップ OFF、BitLocker 無効、C: の縮小）は `win11.md` の「Linux とデュアルブートする場合」
- 自動化は、このリポジトリの `scripts/` が正。このメモは「いつ・何を手でやるか」と、スクリプトの前後を補う

## 対応バージョン

バージョン依存の情報はこの表だけに書く。新しい版が出たら、ここを更新して手順を再確認する。

| 項目     | MX Linux                                                          | Ubuntu                                                     | Linux Mint                                                       |
| ------ | ----------------------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------- |
| 対象     | **25.3 "Infinity"**（Xfce / KDE / Fluxbox）                         | **26.04 LTS** "Resolute Raccoon"（GNOME）                    | **22.3**（Cinnamon）                                               |
| ベース    | Debian 13.7 "trixie"                                              | （Ubuntu 自身）                                                | Ubuntu 24.04                                                     |
| 公開     | 2026-09-20                                                        | 2026-04                                                    | （Mint 23 は 2026-12 予定。未公開）                                       |
| init   | **systemd**（既定。SysVinit 版は選ばない）                                   | systemd                                                    | systemd                                                          |
| 入手元    | [mxlinux.org/download-links](https://mxlinux.org/download-links/) | [ubuntu.com/download](https://ubuntu.com/download/desktop) | [linuxmint.com/download.php](https://linuxmint.com/download.php) |
| 確認日    | 2026-10-03                                                        | 2026-10-03                                                 | 2026-10-03（Mint は **要確認** が多い）                                   |
| 実機での確認 | 未                                                                 | 未                                                          | 未                                                                |

- MX は Xfce / KDE / Fluxbox のほか、新しいハードウェア向けの **AHS**、Raspberry Pi 版がある。ここでは通常版の Xfce を想定する。AHS は別カーネルなので、使う場合は **要確認**。
- 参考: [MX Linux 25.3 (9to5Linux)](https://9to5linux.com/mx-linux-25-3-infinity-is-out-with-linux-kernel-7-2-based-on-debian-13-7)、[Ubuntu release cycle](https://ubuntu.com/about/release-cycle)、[Linux Mint 23 (Phoronix)](https://www.phoronix.com/news/Mint-23-Alfa)

## 全体の流れ

| # | 章 | 区分 | 完了の目安 |
|---|---|---|---|
| 1 | 準備 | 手動 | 起動 USB ができ、BIOS 設定が済んでいる |
| 2 | パーティション設計 | 手動 | どこを何に使うか決まっている（下の表） |
| 3 | インストール | 手動 | 再起動して、インストールしたディストロにログインできる |
| 4 | 起動メニューと時計 | 手動 | 複数 OS を選んで起動できる。時刻がずれない |
| 5 | 初回更新 | 手動 | `apt upgrade` が通る |
| 6 | 日本語入力とフォント | 手動 | 日本語が入力でき、表示される |
| 7 | リポジトリ取得 | 手動 | `dotfiles` が所定の場所にある |
| 8 | スクリプト実行 | スクリプト | `10` → `20` → `30` が通り、zsh で起動する |
| 9 | 動作確認 | 手動 | エディタで `README.md` が見える |
| 10 | SSH と GitHub | 手動 / 任意 | `ssh -T git@github.com` が通る |

## 1. 準備

- 作業前にデータを退避する。
- BIOS / UEFI を確認する。
  - **UEFI ブート**（CSM / Legacy は無効）
  - Secure Boot: Ubuntu は有効のままで入る。MX は **要確認**。起動しない・NVIDIA ドライバで困るなどがあれば、一時的に無効にする
- 起動 USB を作る（8GB 以上）。ISO は入手元（上の表）から取り、**チェックサム / 署名で検証**する（MX 25.3 には ISO の署名を確認するツール「Verify ISO Sig」がある）。
  - Windows からは Rufus で書き込む。パーティション構成は **GPT**、ターゲットは **UEFI (non CSM)**
  - 「ISO イメージ / DD イメージ」を聞かれたら、まず ISO モード。起動しなければ DD モードで作り直す（**要確認**）
- 起動メニュー: メーカー依存（`F12` / `F9` / `Esc` など）。

## 2. パーティション設計

**ディスクの分割テーブルは GPT。** Windows が先に入っていて、**C: を縮小した未割り当て領域**に Linux を入れる前提。

| # | パーティション | 数 | ファイルシステム | サイズ（目安） | マウント | フラグ | フォーマット |
|---|---|---|---|---|---|---|---|
| 1 | **EFI システム (ESP)** | **1つを全 OS で共有**（Windows が作ったものを使う） | FAT32 | 100MB〜（既存） | `/boot/efi` | **`boot`, `esp`** | **しない** |
| 2 | Windows (MSR, C:, 回復) | 既存 | NTFS | 既存 | — | — | **触らない** |
| 3 | **swap** | **1つを全 Linux で共有** | linux-swap | **8GB** | （swap） | `swap` | する（初回のみ） |
| 4 | Linux A の `/` | ディストロごとに1つ | ext4 | 60〜100GB | `/` | — | する |
| 5 | Linux B の `/` | 同上 | ext4 | 同上 | `/` | — | する |
| 6 | Linux C の `/` | 同上 | ext4 | 同上 | `/` | — | する |

- `/home` は分けない（`/` に含める）。ディストロ間で `/home` を共有すると、設定ファイルが衝突する。
- 暗号化（LUKS）、LVM は使わない。
- swap は **共有でよい**。休止（hibernate）は使わない前提。休止を使う場合は、容量が RAM 以上必要。

### 忘れやすい点（EFI まわり）

- **ESP は新しく作らず、Windows のものを再利用する。** 新しく作ると、ブート項目が分散する。
- ESP は **フォーマットしない**（フォーマットすると Windows が起動しなくなる）。インストーラーで「フォーマット」のチェックが付いていたら外す。
- ESP には **`boot` と `esp` のフラグ**が付いている（GParted では `boot, esp` と表示）。付いていなければ、GParted で右クリック → フラグの編集で付ける。
- ESP の **マウントポイントは `/boot/efi`**。インストーラーで ESP を選び、マウントポイントを設定し忘れると、ブートローダーが入らない。
- swap のフラグは `swap`。タイプは `linux-swap`。
- 2 台目以降の Linux では、**swap と ESP を選ぶだけ**（作り直さない）。`/` だけ新しい領域を割り当てる。
- ESP は FAT32 で 100MB のことがある。複数のディストロを入れて容量が足りなければ、**要確認**（通常は数 MB ずつなので足りる）。

## 3. インストール

ライブ USB で起動して、インストーラーを開く。

共通の手順:

1. 言語・キーボード・タイムゾーンを選ぶ（日本語キーボードは `Japanese`）
2. パーティションは **手動 / カスタム**を選ぶ（「ディスク全体を使う」を選ぶと **Windows が消える**）
3. 上の「パーティション設計」のとおり割り当てる
   - ESP: マウント `/boot/efi`、**フォーマットしない**
   - swap: swap として使う
   - `/`: ext4、**フォーマットする**、マウント `/`
4. ブートローダー（GRUB）の場所は **ESP**（ディスクの MBR ではない）
5. ユーザー名・ホスト名・パスワードを入力する（ユーザー名は ASCII）
6. インストール後、再起動する。**USB は再起動前に抜く**

### ディストロ差分

| 項目 | MX Linux | Ubuntu | Linux Mint |
|---|---|---|---|
| インストーラー | MX Linux Installer | Ubuntu インストーラー | Mint のインストーラー（22.x は Ubiquity 系。**要確認**） |
| パーティションの選び方 | 「ディスクレイアウトのカスタマイズ」（名称は **要確認**） | 「手動でインストール」/「Something else」（名称は **要確認**） | 「それ以外」（**要確認**） |
| ESP の指定 | 該当パーティションで `/boot/efi` を指定（インストーラーは指定のない ESP を触らない） | 同左 | 同左 |
| 追加のオプション | GRUB のインストール先が ESP になっているか確認（**要確認**） | 「サードパーティソフトウェア」のチェックは任意 | メディアコーデックのチェックは任意 |
| 注意 | **systemd 版の ISO を使う**（SysVinit 版を選ばない。25.3 の通常版は systemd が既定） | 初回起動で Snap の更新が走ることがある | Snap は既定で無効。インストーラーは Mint 23 で刷新予定（**要確認**） |

## 4. 起動メニューと時計

### 起動メニュー

- 複数のディストロを入れると、**どれか1台の GRUB** が起動メニューを持つ。他は `os-prober` で検出して追加する。
- 最後に入れたディストロの GRUB が優先されることが多い。**メニューの親をどれにするか決めておく**（Windows の起動項目は自動で追加される）。
- Windows や他の Linux がメニューに出ないとき:

  ```shell
  sudo vim /etc/default/grub     # GRUB_DISABLE_OS_PROBER=false にする（行が無ければ追加）
  sudo update-grub
  ```

  - Debian 13 / Ubuntu では `os-prober` が既定で無効のことがある。MX は **要確認**。
- GRUB が出ずに Windows が直接起動するときは、BIOS の起動順位で `debian` / `ubuntu` / `MX` などの項目を先頭に変える。

### 時計のずれ

Windows はハードウェア時計をローカル時間、Linux は UTC で扱うため、OS を切り替えると時刻が9時間ずれる。**Windows 側を UTC に合わせる**（管理者権限の PowerShell）。

```powershell
reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
```

Linux 側は既定のまま。`timedatectl` で `RTC in local TZ: no` を確認する。

## 5. 初回更新

```shell
sudo apt update && sudo apt upgrade
```

- 初回は時間がかかる。**再起動が必要な更新**（カーネル）があれば、再起動する。
- `sudo apt dist-upgrade` / `sudo apt full-upgrade` は、通常は不要。

### ディストロ差分

| 項目 | MX Linux | Ubuntu | Linux Mint |
|---|---|---|---|
| 更新ツール | MX Updater（GUI）または `apt` | ソフトウェアの更新（GUI）または `apt` | アップデートマネージャー |
| リポジトリ | MX 独自のリポジトリ（Debian + MX）。ミラーは **MX Repo Manager** で選ぶ | `/etc/apt/sources.list.d/ubuntu.sources`（deb822 形式）。日本のミラーに変えるなら URL を `jp.archive.ubuntu.com` に置換 | ソフトウェアソース（GUI）でミラーを選ぶ |
| 注意 | — | 旧 `/etc/apt/sources.list` の `sed` は効かない（24.04 以降は deb822） | — |

## 6. 日本語入力とフォント

入力メソッドは **fcitx5 + Mozc**。パッケージの導入は dotfiles の `23_ja.sh`（章8）がやる。dotfiles を取得する前に使いたい場合は、次を手動で実行する（スクリプトと同じ内容）。

```shell
sudo apt install fcitx5 fcitx5-mozc fcitx5-config-qt   # 設定ツール名は下の差分表
im-config -n fcitx5
```

- 再起動（または再ログイン）する。
- 「Fcitx 5 設定」を開き、**入力メソッドに `Mozc` を追加**する。日本語キーボードなら、`Keyboard - English (US)` は不要。
- 確認: エディタで `半角/全角`（または `Ctrl+Space`）を押し、日本語が入力できる。

フォント:

```shell
sudo apt install fonts-noto-cjk fonts-ipafont
```

- 任意のプログラミング用フォント（Myrica など）は、各配布元（[tomokuni/Myrica](https://github.com/tomokuni/Myrica)）のリリースから取って、`~/.local/share/fonts/` に置き、`fc-cache -fv` を実行する。

### ディストロ差分

| 項目 | MX Linux | Ubuntu | Linux Mint |
|---|---|---|---|
| 日本語化 | 言語は **MX Package Installer → Popular Apps → Language** の「Japanese」系（名称は **要確認**）。入力は上の `apt` でもよい | `sudo apt install language-pack-ja language-pack-gnome-ja`（または設定 → システム → 地域と言語） | 言語設定（Language Settings）で日本語を追加 |
| 設定ツール | `fcitx5-config-qt` | `fcitx5-config-qt`（無ければ `fcitx5-configtool`。`23_ja.sh` は、あるほうを入れる。**要確認**） | 同左 |
| 環境変数 | `im-config` が設定する | **Wayland が既定**。`~/.xprofile` は読まれない。必要なら `~/.config/environment.d/` に書く | X11 / Cinnamon。`im-config` で足りる |
| 備考 | MX のフォーラムなどでは古い `fcitx`（v4）の手順がある。Debian 13 は **fcitx5** を使う | 一部のアプリ（Chrome など）で二重入力になる場合がある。設定で調整 | — |

参考: [Ubuntu 26.04 で fcitx5-mozc を導入する (note)](https://note.com/nidoneru_zzz/n/n16eb7a71bada)、[MX Linux Forum: Japanese fcitx](https://forum.mxlinux.org/viewtopic.php?p=589278)

## 7. リポジトリ取得

dotfiles を **所定のパスに** clone する。リポジトリは公開なので、SSH 鍵もサインインも不要（HTTPS で取れる）。

```shell
sudo apt install -y git curl
git clone https://github.com/yuzucha16/dotfiles ~/works/repos/github.com/yuzucha16/dotfiles
```

- SSH 鍵で取得してもよい（`git clone git@github.com:yuzucha16/dotfiles.git ~/works/repos/github.com/yuzucha16/dotfiles`。鍵の登録は「10. SSH と GitHub」）。
- `ghq` のルート（`GHQ_ROOT`）は、ネイティブ Linux では `~/works/repos`（`home/.profile` の既定。Windows の `%USERPROFILE%\works\repos` に対応する）。WSL では、WSL 自身の `~/works/repos`（Windows 側を共有せず、`/mnt/c` の上に置かない）
- git のユーザー名・メールアドレスは、リポジトリに入れない。`~/.gitconfig_local` に書く（`home/.gitconfig` が include する）。対話で作るスクリプトが `scripts/linux/11_git_identity.sh`（次の章）。手で書くなら:

  ```shell
  git config --file ~/.gitconfig_local user.name "<name>"
  git config --file ~/.gitconfig_local user.email "<email>"
  ```

## 8. スクリプト実行

`scripts/linux/` は WSL とネイティブ Linux 共通のスクリプト群。`dotfiles` で次の順に実行する。

| 順 | スクリプト | 内容 | 注意 |
|---|---|---|---|
| 10 | `10_dirs.sh` | XDG ディレクトリ、`~/.local/bin`、`~/.ssh`、`~/works/{build,tools}` を作る | |
| 11 | `11_git_identity.sh` | `~/.gitconfig_local` が無いときだけ、git の名前・メールを対話で聞いて作る | 既にあれば触らない。**30 の前**に実行する（git が必要） |
| 20 | `20_packages.sh desktop` | apt の更新、`manifests/apt.txt` + `apt.desktop.txt` のパッケージ、starship、ghq、`bat` / `fd` のリンクを入れる | `sudo` とネット接続が必要。パッケージの一覧はスクリプトでなく `manifests/` を直す |
| 23 | `23_ja.sh` | fcitx5 + Mozc、日本語フォントを入れ、`im-config -n fcitx5` を実行する。Ubuntu 系は言語パックも入れる | **再ログイン**後に、Fcitx 5 設定で Mozc を追加する（手動、「6. 日本語入力」） |
| 30 | `30_link.sh -n` → `30_link.sh` | stow で `home/` を `~` に展開する | 初回は **`-n`（ドライラン）**で確認する。リポジトリの場所は自動で判定される |
| 31 | `31_history_seed.sh [-n]` | zsh/bash の履歴に、定型コマンドの種（`manifests/history.seed.sh.txt`）を入れる | 履歴が無い/空のときだけ。既存の履歴は上書きしない。**最初のシェルを開く前に**実行する |

```shell
cd ~/works/repos/github.com/yuzucha16/dotfiles/scripts/linux
bash 10_dirs.sh
bash 11_git_identity.sh
bash 20_packages.sh desktop
bash 23_ja.sh
bash 30_link.sh -n      # 確認
bash 30_link.sh         # 実行
chsh -s /usr/bin/zsh
```

- 展開先に実ファイル（初期の `.bashrc` や `.profile` など）があると `[ERR]` で止まる。**自動退避はしない**。中身を確認して、手で退避（`mv ~/.bashrc ~/.bashrc.orig`）してから再実行する。
- `chsh` の後は、**再ログイン**で zsh が有効になる。初回の zsh 起動時にプラグインの導入が走ることがある。

## 9. 動作確認

新しいターミナルを開いて確認する。

```shell
echo $SHELL                 # /usr/bin/zsh
ls -l ~/.gitconfig          # dotfiles へのシンボリックリンク
which vim bat fd ghq        # 見つかる
```

エディタで `README.md` を開く。どれか 1 つで文字化けなく見えれば完了。

```shell
cd ~/works/repos/github.com/yuzucha16/dotfiles
vim README.md
```

GUI エディタ（Xfce のテキストエディタ、gedit など）で開く場合は、ファイルマネージャーから `README.md` を開く。

## 10. SSH と GitHub

push する場合に設定する（読み取りだけなら不要）。

```shell
ssh-keygen -t ed25519 -C "<comment>"      # 保存先は既定のまま（~/.ssh/id_ed25519）
cat ~/.ssh/id_ed25519.pub                 # GitHub の Settings → SSH keys に登録
```

`~/.ssh/config`:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
```

```shell
chmod 600 ~/.ssh/config
ssh -T git@github.com          # "Hi <user>! You've successfully authenticated" が出る
git -C ~/works/repos/github.com/yuzucha16/dotfiles remote set-url origin git@github.com:yuzucha16/dotfiles.git
```

- 鍵は RSA でなく **ed25519** を使う。
- `ssh-keygen` では `~` が展開されないことがある。保存先は既定のままにするか、絶対パスで指定する。

## 任意設定

| 項目 | 方法 |
|---|---|
| SSD の TRIM | `systemctl status fstrim.timer` で有効を確認。無効なら `sudo systemctl enable --now fstrim.timer` |
| エラーの確認 | `systemctl --failed`、`journalctl -p 3 -xb` |
| ホスト名の変更 | `sudo hostnamectl set-hostname <name>` |
| ホームのフォルダ名を英語にする | `LANG=C xdg-user-dirs-update --force`（`xdg-user-dirs-gtk` が要るディストロでは `LANG=C xdg-user-dirs-gtk-update --force`） |
| ファイアウォール | `sudo apt install gufw`（または `ufw`）で有効にする |
| バックアップ | Timeshift（システム）、Grsync（ファイル） |
| 不要パッケージの削除 | `sudo apt autoremove` |
