---
type: howto
title: WezTerm + claude + nvim セットアップ手順
tags:
  - setup
  - windows
  - wezterm
  - nvim
  - dotfiles
---

# WezTerm + claude + nvim セットアップ手順

WSL の作業部屋（`room-<Area>`、既定 `myenv`）で、1 タブ = 左 claude / 右 nvim の環境を、新しい PC で再現する。ゴールは、WezTerm を起動すると左に claude、右に nvim が並ぶこと。

自動化できる作業は、スクリプトが正。この手順書は、スクリプトの順序と、前後の手作業、日常の操作を書く（設定の中身は `windows/wezterm/wezterm.lua`、`home/.config/nvim/`、一覧は `windows/README.md`）。

**確認状況**: 構成の作成と部屋への導入は 2026-11-15 に済み。通常起動での組み立て、claude 自身の入力待ちでの 🔔 は、実機で未確認（`docs/log.md` の NA 5）。

## 前提

| 項目 | 内容 | 確認日 |
|---|---|---|
| 部屋 | `room init <Area>` で作る WSL ディストリビューション `room-<Area>`（ユーザー `ai`）。`room` の使い方は `workbase` の `workflow-kit/room/README.md` | 2026-11-15 |
| nvim・zellij | 部屋へは `room init` が入れる（段 `nvim` `zellij` `bellhook`。版は workbase 側で固定）。Windows 側へは `20_apps.bat` が `manifests/apps.txt` から入れる | 2026-11-15 |
| Windows | Developer Mode が ON（`30_link.bat` がシンボリックリンクを張るため） | 2026-11-15 |

## 全体の流れ

| 章 | 区分 | 完了の目安 |
|---|---|---|
| 1. 準備 | 手動 | Developer Mode が ON |
| 2. アプリとリンク | スクリプト | `wezterm` が起動でき、`%USERPROFILE%\.config\wezterm\wezterm.lua` がリンクになっている |
| 3. 部屋 | 手動 + スクリプト | 部屋に nvim・zellij・bell フックが入っている |
| 4. 部屋の設定 | スクリプト | 部屋の `nvim` が起動し、プラグインが入る |
| 5. 動作確認 | 手動 | WezTerm で左 claude / 右 nvim が組まれる |

## 1. 準備

1. Developer Mode を ON にする（設定 → システム → 開発者向け）
2. **これを先にやる**。OFF のまま `30_link.bat link` を実行すると、既存のファイルリンクが消え、Windows Terminal の設定が初期化された事故がある（2026-11-15。`docs/decisions.md` の同日の項）

完了の目安: 設定画面で Developer Mode が ON。

## 2. アプリとリンク

| スクリプト | 内容 | 注意 |
|---|---|---|
| `scripts\windows\20_apps.bat` | wezterm・neovim・zellij を入れる | 一覧は `manifests/apps.txt` |
| `scripts\windows\30_link.bat` | WezTerm の設定、`%LOCALAPPDATA%\nvim`（nvim の設定）をリンクする | 一覧は `manifests/links.map`。章 1 の後に実行する |

完了の目安: `%USERPROFILE%\.config\wezterm\wezterm.lua` が `windows/wezterm/wezterm.lua` へのリンクになっている。

## 3. 部屋

1. 部屋が無ければ、人が端末で `room init <Area>` を実行する（nvim・zellij・bell フックも入る）
2. 既存の部屋で、nvim・zellij・bell フックだけを足すときは `room init <Area> --only nvim,zellij,bellhook`
3. 部屋のシェルを整える（任意の順ではなく、この順）:

   ```powershell
   pwsh -NoProfile -File windows\room\room-shell-setup.ps1 -Area myenv
   ```

`room` は人が端末で実行する（AI は実行しない）。

完了の目安: `wsl -d room-<Area> -u ai -- which nvim zellij` が両方のパスを返す。

## 4. 部屋の設定（nvim）

```powershell
pwsh -NoProfile -File windows\room\room-nvim-config.ps1 -Area myenv
```

- 部屋の `~/.config/nvim` へ、`home/.config/nvim` を上書きコピーする。何度実行しても同じ結果
- **nvim の設定を変えたら、再実行して部屋へ反映する**（Windows 側の `%LOCALAPPDATA%\nvim` はリンクなので自動で反映される。部屋へはコピーなので、反映は手動）

完了の目安: 部屋で `nvim` を初めて開くと、プラグイン（lazy.nvim）が入る。

## 5. 動作確認

1. `WEZTERM_CONFIG_FILE` を使わず、WezTerm を通常に起動する
2. 左に claude、右に nvim が並ぶ

完了の目安: 上の状態になる。

## 日常の操作

| 操作 | キー |
|---|---|
| claude + nvim のタブを開く | `Ctrl+Shift+T` |
| 素のシェルのタブを開く | `Ctrl+Shift+N` |
| ペインを移る（左右） | `Alt+h` / `Alt+l` |
| タブを移る | `Alt+j`（次）/ `Alt+k`（前） |
| nvim でファイラー（oil.nvim）を開く | `<Space>e` |

- **bell の仕組み**: claude の入力待ち・停止で、部屋の bell フックが bell を鳴らす。別のタブにいるとき、そのタブの名前がオレンジの 🔔 になる。そのタブへ移ると消える。音は鳴らさない（`audible_bell = 'Disabled'`）
- **nvim は LazyVim**（2026-11-15。`home/.config/nvim`）。初回起動でプラグインを取得するので、ネットワークが要る（数分）
- **テーマ**（すべて dark）: 既定は `gruvbox-material`（ハイライトは Zed の Material Gruvbox Dark に合わせた。`lua/plugins/colorscheme.lua`）。`iceberg` と `tender` は入れてあるが、選ぶまで読み込まない。切り替えは、`lua/config/features.lua` の `M.theme`、環境変数 `NVIM_THEME=iceberg`、または nvim 内で `:colorscheme tender`
- **重いとき**: 環境変数 `NVIM_LITE=1` で、UI 装飾と LSP・補完をまとめて外す（treesitter の色付けは残る）。個別に外すなら `lua/config/features.lua` の `M.plugins` の該当行を `false` にする。部屋へは章 4 の再実行で反映する
- 別の部屋を使うときは、環境変数 `WEZTERM_ROOM_AREA` に Area 名を入れて WezTerm を起動する（既定 `myenv`）

## つまずき

| 症状 | 原因と対処 |
|---|---|
| `30_link.bat` の後、Windows Terminal の色が初期状態になった | Developer Mode が OFF のまま実行した。ON にして張り直し、書き換わった設定は `git checkout` で戻す（`docs/log.md` の NA 7 で、OFF のときは止める直しを予定） |
| 起動しても claude / nvim が並ばない | 部屋の名前が違う。`WEZTERM_ROOM_AREA` と、`wsl -l` の `room-<Area>` を揃える |
| 部屋に `nvim` が無い | 章 3 の `room init <Area> --only nvim,zellij,bellhook` |
| nvim の設定を変えたのに、部屋で反映されない | 章 4 を再実行する |
| タブ名が `wslhost.exe` のまま | 既知。直すかは動作確認（NA 5）で決める |
