---
type: howto
title: Windows 11 セットアップ手順
tags:
  - windows
  - setup
  - dotfiles
---

# Windows 11 セットアップ手順

インストール準備から、エディタで dotfiles のテキスト（`README.md`）が開けるところまで。
スクリプトは、このリポジトリの `scripts/windows/` が正。このメモは「いつ・何を手でやるか」と、スクリプトの前後を補う。

## 対応バージョン

バージョン依存の情報はこの表だけに書く。新しい版が出たらここを更新する。

| 項目 | 内容 |
|---|---|
| 対象 | Windows 11 Home / Pro 25H2（ビルド 26200 系） |
| 手順の確認日 | 2026-10-06（5 のリポジトリ取得から 7 の動作確認までは、実機の Windows で通した（ユーザー報告）。2026-10-03 に書いた 1〜4 の OOBE 回避は Web 上の情報で確認したもので、実機での再確認は **要確認**） |
| ISO / 書き込み | [Microsoft 公式のダウンロード](https://www.microsoft.com/software-download/windows11) / [Rufus](https://rufus.ie) |
| オフライン OOBE | 下の「OOBE」。方法は版で変わる |
| 次の章 | Linux とデュアルブートする場合は `debian-family.md` |

## 全体の流れ

| # | 章 | 区分 | 完了の目安 |
|---|---|---|---|
| 1 | 準備 | 手動 | USB メディアができ、BIOS 設定が済んでいる |
| 2 | インストール | 手動 | デスクトップまで進む |
| 3 | OOBE（ネット無し） | 手動 | ローカルアカウントで入れた |
| 4 | 初回設定 | 手動 | ネット接続・更新・開発者モード ON |
| 5 | リポジトリ取得 | 手動 | `dotfiles` が所定の場所にある |
| 6 | スクリプト実行 | スクリプト | `10` → `11` → `20` → `30` が通る |
| 7 | 動作確認 | 手動 | エディタで `README.md` が見える |
| 8 | 任意設定 | 手動 / 任意 | 必要なものだけ |

## 1. 準備

- 作業前にデータを退避する（Windows を入れ直すとディスクの中身が消える）。
- BIOS / UEFI で確認する（メーカーにより名称が違う）。
  - **UEFI ブート**（CSM / Legacy は無効）
  - **Secure Boot** 有効、**TPM 2.0**（fTPM / PTT）有効
  - Linux とデュアルブートする場合は、**Secure Boot を有効のまま** Linux を入れられるかは、ディストロ次第（Ubuntu は対応。MX は **要確認**）。問題が出たら一時的に無効にする
- 起動 USB を作る（8GB 以上）。
  1. 公式ページから **Windows 11 ディスクイメージ (ISO)** をダウンロードする
  2. Rufus で ISO を選んで書き込む。パーティション構成は **GPT**、ターゲットは **UEFI (non CSM)**
  3. 書き込み時の「Windows ユーザーエクスペリエンス」ダイアログで、**「オンライン Microsoft アカウントの要件を削除する」** にチェックを入れると、OOBE でローカルアカウントを作れる（下の「OOBE」の方法 A）

## 2. インストール

1. USB から起動する（起動メニュー: メーカー依存で `F12` / `F9` / `Esc` など）
2. 言語・キーボードを選ぶ。プロダクトキーは「プロダクトキーがありません」でよい（認証済みなら自動）
3. エディションを選ぶ（Home / Pro。メーカーのライセンスに合わせる）
4. **「カスタム: Windows のみをインストールする」** を選ぶ
5. 保存先ディスクを決める
   - ディスク全体が空なら、**「ドライブ 0 の割り当てられていない領域」を選んで「次へ」**。EFI・MSR・OS・回復は自動で作られる
   - 古い OS が入っているディスクは、**そのディスクのパーティションを全部削除**してから選ぶ（別ディスクのデータを消さないよう、ドライブ番号と容量を確認する）
6. 再起動を何度か繰り返す。**USB は最初の再起動後に抜く**（入れたままだと、またインストーラーが立ち上がることがある）

### Linux とデュアルブートする場合

**Windows を先に入れる**（Linux 側が Windows を GRUB に拾いやすい）。

- 上の手順 5 では、ディスク全体を Windows に使わせてよい。Linux 用の領域は **インストール後に Windows の「ディスクの管理」で C: を縮小して作る**。
- 縮小は **未割り当て**のまま残す。フォーマットしない。Linux インストーラーが使う。
- Linux を入れる前に、次の 2 つを済ませておく。
  - **高速スタートアップを無効にする**: コントロールパネル → 電源オプション → 電源ボタンの動作 → 現在利用可能ではない設定を変更します → 「高速スタートアップを有効にする」のチェックを外す
  - **BitLocker / デバイスの暗号化が無効**であることを確認する（設定 → プライバシーとセキュリティ → デバイスの暗号化）。有効だと、パーティション変更後に回復キーを求められる
- **Windows の EFI システムパーティションは、Linux 側で再利用する**。フォーマットしない（詳細は `debian-family.md` のパーティション）。

## 3. OOBE（ネット無し・ローカルアカウント）

OOBE（初回セットアップ画面）で、Microsoft アカウントとネット接続を求められるのを避けて、ローカルアカウントで入る。

**前提: LAN ケーブルを抜く。Wi-Fi は接続しない。**（つながるとアカウント作成を強制されやすい）

**方法は新しい順に A → B → C と試す。A が最も安定している。**

| 方法 | 手順 | 状態 |
|---|---|---|
| A. Rufus のオプション | 「準備」で `オンライン Microsoft アカウントの要件を削除する` にチェックして USB を作る。OOBE でローカルアカウントを作る画面が出る | 推奨。USB 作成時に決まる |
| B. `start ms-cxh:localonly` | OOBE のネットワーク接続画面で `Shift + F10` → コマンドプロンプトに `start ms-cxh:localonly` を入力して Enter。ローカルアカウント作成画面が開く | 新しいビルド（26220.6772 以降）では **修正されて使えない**。**要確認** |
| C. `oobe\bypassnro` | `Shift + F10` → `oobe\bypassnro` → 再起動後に「インターネットに接続していません」が出る | 25H2 では **廃止**（以前は定番だった）。使えない |

- 方法 B / C で `Shift + F10` が効かないノート PC では、`Fn + Shift + F10` を試す。
- ローカルアカウントを作るときは、ユーザー名に **ASCII のみ**を使う（日本語名だとフォルダ名やパスで後から困る）。
- パスワードのヒントやセキュリティの質問が要求される。後から変更できる。
- 参考:
  - [It is still possible to bypass Microsoft Account in Windows 11 25H2 (Winaero)](https://winaero.com/bypass-microsoft-account-windows-11-25h2/)
  - [Tip: Install Windows 11 Version 25H2 With a Local Account (Thurrott)](https://www.thurrott.com/windows/windows-11/328183/tip-install-windows-11-version-25h2-with-a-local-account)

> OOBE を過ぎてから、ローカルアカウントのまま使い続けてよい。Microsoft アカウントの紐づけは後からでもできる。

## 4. 初回設定

1. ネットワークに接続する（Wi-Fi: タスクバー右下、または 設定 → ネットワークとインターネット）
2. **Windows Update** を実行し、更新がなくなるまで繰り返す（再起動を挟む）
3. **開発者モード**を ON にする（設定 → システム → 開発者向け）
   - 管理者権限なしで symlink を作るために必須。OFF だと `30_link.bat` が `[ERR] mklink failed` になる
4. 表示言語・地域・キーボードを確認する（日本語キーボードのモデルで、`半角/全角` や `無変換` の挙動が変わる）
5. OneDrive が「ドキュメント」「デスクトップ」を自動バックアップしていたら、**OFF にする**
   - PowerShell プロファイルのリンク先は `%USERPROFILE%\Documents\PowerShell\` で、OneDrive に付け替えられるとパスがずれる

## 5. リポジトリ取得

`dotfiles` を、**所定のパスに**clone する（このパス構成が前提）。リポジトリは公開なので、サインインは出ない。

git は **scoop のもの1種類だけ**にする（winget の git は使わない）。dotfiles の `README.md` の冒頭「クイックスタート」と同じ4行を、PowerShell に貼る。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
scoop install git
git clone https://github.com/yuzucha16/dotfiles $HOME\works\repos\github.com\yuzucha16\dotfiles
```

- `scoop install git` のあとに `git` が見つからなければ、新しい PowerShell を開き直してから3行目以降を実行する。
- すでに winget の git が入っているPCは、一度だけ `winget uninstall --id Git.Git -e` で消す（システムの PATH が先に見つかり、scoop の git より優先されるため）。
- Vault（`$HOME\works`）は clone しない。共有リポジトリ `workbase` は、dotfiles の `50_repos.bat` が `$HOME\works\resources` に clone する。ワークスペース（PARA、`AGENTS.md`）は、`workbase` の `workflow-kit` の「workflowを導入して」で作る。`.obsidian` は `30_link.bat` が張る。これらはこの手順書の範囲外（dotfiles の `README.md` を参照）。
- git のユーザー名・メールアドレスは、リポジトリに入れない。`~/.gitconfig_local` に書く（`home/.gitconfig` が include する）。対話で作るスクリプトが `11_git_identity.bat`（次の章。`30_link.bat` の前に実行する）。手で書くなら:

```powershell
git config --file ~/.gitconfig_local user.name "<name>"
git config --file ~/.gitconfig_local user.email "<email>"
```

## 6. スクリプト実行

`$HOME\works\repos\github.com\yuzucha16\dotfiles\scripts\windows\` で、**番号順に**実行する。エクスプローラーからのダブルクリックでよい。

| 順 | スクリプト | 内容 | 注意 |
|---|---|---|---|
| 10 | `10_env.bat` | `setx` で環境変数（`XDG_*`、`WORKS_DIR=%USERPROFILE%\works`、`GHQ_ROOT=%WORKS_DIR%\repos` など）を設定し、ディレクトリを作る | **実行後は新しいターミナルを開く**（現在のセッションには反映されない） |
| 11 | `11_git_identity.bat` | `~\.gitconfig_local` が無いときだけ、git の名前・メールを対話で聞いて作る | 既にあれば触らない。**30 の前**に実行する（git が必要。5 で入れた scoop の git でよい） |
| 20 | `20_apps.bat [home]` | scoop（5 で入れていれば skip）と bucket を導入し、`manifests\apps.txt` のアプリを入れる。家 PC は `home` を付ける（`apps.home.txt` も入る） | 管理者権限は不要。ネット接続が必要。最後に **オレンジ色**で VC++ ランタイムの `[Installed]` / `[WARN]` が出る（`[WARN]` で、実際にアプリが起動しないときだけ `scoop install extras/vcredist2022`。UAC が出る） |
| 24 | `24_fonts.bat` | PlemolJP NF を `gh` で `~\download` に取得する。インストールは手動（[fonts-setup.md](fonts-setup.md)） | `gh` のログインは不要。出力は `tmp\24_fonts.log` にも残り、最後に `pause` で止まる。1件でも失敗したら終了コード 1 |
| 30 | `30_link.bat [-n]` | `links.map` に従って設定ファイルのリンクを張る | 先に **`-n`（ドライラン）**で確認する。配置先に実ファイルがあると `[ERR]`。**自動退避はしない**ので、手で退避してから再実行 |
| 31 | `31_history_seed.bat [-n]` | PSReadLine の履歴に、定型コマンドの種（`windows\powershell\history.seed.txt`）を入れる | 履歴が無い/空のときだけ。既存の履歴は上書きしない。**最初の pwsh を開く前に**実行する。出力は `tmp\31_history_seed.log` にも残り、最後に `pause` で止まる |

- 管理者権限が必要なのは、任意の `.reg`（任意設定）と WSL 有効化（`40_wsl_enable.bat`、WSL を使う場合のみ）だけ。
- `50_repos.bat` は、ghq で必要なリポジトリを取るためのもの。この手順書の範囲外。

## 7. 動作確認

新しい PowerShell（Windows Terminal）を開いて確認する。

```powershell
scoop list                 # 導入したアプリが並ぶ
git --version
Get-Item $HOME\.gitconfig  # リンク（LinkType: SymbolicLink）になっている
```

エディタで `README.md` を開く。どれか 1 つで文字化けなく見えれば完了。

```powershell
cd $HOME\works\repos\github.com\yuzucha16\dotfiles
notepad++ README.md
zed README.md
vim README.md
```

## 8. 任意設定

| 項目 | 方法 |
|---|---|
| CapsLock を Ctrl にする | `dotfiles\scripts\windows\optional\capslock_to_ctrl.reg` を実行（管理者権限）。再起動後に有効。戻すときは `capslock_default.reg` |
| PowerShell の履歴数を増やす | `Set-Variable -Name MaximumHistoryCount -Value 32767`（`profile.ps1` に書くと恒久化。既定は 4096） |
| WSL2 / Ubuntu | `40_wsl_enable.bat` を管理者権限で実行 → 再起動 → `wsl --update` → `wsl --install -d Ubuntu-24.04`。以降は dotfiles の README の WSL の節 |
| Notepad の置換 | `notepad` を Notepad++ に置き換える方法は、レジストリ（`Image File Execution Options`）を書き換える方法がある。更新で壊れやすいので、既定では **勧めない** |
