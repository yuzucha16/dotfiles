---
type: howto
title: WezTerm + zellij + claude + nvim セットアップ手順
tags:
  - setup
  - windows
  - wezterm
  - zellij
  - nvim
  - dotfiles
---

# WezTerm + zellij + claude + nvim セットアップ手順

新しい PC で、WezTerm の 1 タブ = zellij の 1 セッション（claude と nvim が並ぶ）の環境を再現する。ゴールは、`Ctrl+Shift+T` で「環境 + cwd」を選ぶと、zellij が開いて claude と nvim が並ぶこと。

設計は `terminal-units.md`（単位、キー、通知の仕組み）が正。この手順書は、スクリプトの順序と前後の手作業、日常の操作を書く。設定の中身は `windows/wezterm/wezterm.lua`、`home/.config/zellij/`、`home/.config/nvim/`、一覧は `manifests/links.map` と `manifests/apps.txt`。

**確認状況**: pwsh7（win）と room の実機確認は 2026-11-19 に済み（設計書 9 章）。wsl 環境（`wezterm.lua` の候補に未登録）と、room の nvim 設定の反映（章 4）は未確認。

## 対応バージョン表

| 項目 | 版 | 手順の確認日 |
|---|---|---|
| zellij | 0.46.0（Windows ネイティブは 0.44 から） | 2026-11-19 |
| nvim | 0.12.6（LazyVim） | 2026-11-19 |
| lazygit | 0.66.3 | 2026-11-19 |
| room の道具の版 | 設計書 12 章の表が正 | 2026-11-19 |

## 全体の流れ

| 章 | 区分 | 完了の目安 |
|---|---|---|
| 1. 準備 | 手動 | Developer Mode が ON |
| 2. アプリとリンク | スクリプト | `wezterm` `zellij` `nvim` `lazygit` が入り、設定がリンクになっている |
| 3. claude の bell フック | 手動 | win の claude の入力待ちで、別タブに 🔔 が付く |
| 4. 部屋（room） | 手動 + スクリプト | 部屋に nvim・zellij・bell フックと、設定が入っている |
| 5. 動作確認 | 手動 | 左に claude、右に nvim が並ぶ |

## 1. 準備

1. Developer Mode を ON にする（設定 → システム → 開発者向け）
2. **これを先にやる**。OFF のまま `30_link.bat link` を実行すると、既存のファイルリンクが消え、Windows Terminal の設定が初期化された事故がある（2026-11-15。`docs/decisions.md` の同日の項）

完了の目安: 設定画面で Developer Mode が ON。

## 2. アプリとリンク

| スクリプト | 内容 | 注意 |
|---|---|---|
| `scripts\windows\20_apps.bat` | wezterm・zellij・neovim・lazygit などを入れる | 一覧は `manifests/apps.txt` |
| `scripts\windows\30_link.bat` | WezTerm・zellij・nvim の設定をリンクする | 一覧は `manifests/links.map`。章 1 の後に実行する |

- nvim のリンク先は `%USERPROFILE%\.config\nvim`（`XDG_CONFIG_HOME` は `10_env.bat` が設定する。**新しいターミナルを開いてから**使う）
- zellij は Windows で `%APPDATA%\Zellij\config` を読む（XDG ではない）。リンクは `30_link.bat` が張る

完了の目安: `%USERPROFILE%\.config\wezterm\wezterm.lua` と `%APPDATA%\Zellij\config` がリンクになっている。初回の `nvim` でプラグイン（lazy.nvim）が入る（ネットワークが要る。数分）。

## 3. claude の bell フック（win）

win では、BEL を ConPTY が止める。そこで、フックが旗ファイルを置き、WezTerm が拾ってタブに印を付ける。

1. `windows\wezterm\bell-mark.ps1` を `%USERPROFILE%\.claude\hooks\` へ置く（コピー。リンクの一覧には未登録）
2. `%USERPROFILE%\.claude\settings.json` の Notification と Stop のフックから、`pwsh -NoProfile -File <上のパス>` を実行するようにする

- **未決**: フックの設定を kit の手順にするか（`docs/log.md` の NA 8）。決まるまで手動
- room の bell は、`room init` の段 `bellhook` が入れる（章 4）

完了の目安: 別のタブにいるとき、win の claude の入力待ちで、そのタブの名前がオレンジの 🔔 になる。

## 4. 部屋（room）

1. 部屋が無ければ、人が端末で `room init <Area>` を実行する（nvim・zellij・bell フックも入る）
2. 既存の部屋で足すときは `room init <Area> --only nvim,zellij,bellhook`
3. zellij の設定は **`room init` では配られない**。部屋の `~/.config/zellij/` へ、`home/.config/zellij/` を手で置く（`config.kdl` と `layouts\`）
4. nvim の設定: `pwsh -NoProfile -File windows\room\room-nvim-config.ps1 -Area myenv`（要確認: 試作の削除後に、作り直した設定で未実行）

`room` は人が端末で実行する（AI は実行しない）。

完了の目安: `wsl -d room-<Area> -u ai -- which nvim zellij` が両方のパスを返し、部屋の `~/.config/zellij/config.kdl` がある。

## 5. 動作確認

1. WezTerm を通常に起動し、`Ctrl+Shift+T` で候補（`wezterm.lua` の `TARGETS`）から選ぶ
2. 新しいセッションなら、左に claude、右に nvim が並ぶ（案 B。`config.kdl` の `default_layout`）

完了の目安: 上の状態になる。WezTerm のタブを閉じて同じ候補を開き直すと、同じセッションに戻る。

## 日常の操作

| 層 | 操作 | キー |
|---|---|---|
| WezTerm | 環境と cwd を選んでタブを開く（同じ組があれば、そこへ移る） | `Ctrl+Shift+T` |
| WezTerm | 素の pwsh7 のタブ | `Ctrl+Shift+N` |
| zellij | 操作モードの解除・戻り（既定は locked） | `Ctrl+g` |
| zellij | claude を足す / lazygit（floating）/ floating の表示切替 | `Alt+c` / `Alt+g` / `Alt+f` |
| zellij | pane を移る / 閉じる | `Alt+←↓↑→` / `Alt+x` |
| nvim | LazyVim の操作 | `<Space>` 始まり |

- 別の部屋を使うときは、環境変数 `WEZTERM_ROOM_AREA` に Area 名を入れて WezTerm を起動する（既定 `myenv`）
- 環境と cwd の候補を増やすときは、`wezterm.lua` の `TARGETS` に足す

## つまずき

| 症状 | 原因と対処 |
|---|---|
| win の zellij の中が cmd になる | zellij は Windows で `SHELL` を見ない。`wezterm.lua` が `options --default-shell pwsh` を渡すが、**新しいセッションだけに効く**。既存は `zellij.exe delete-session --force <名>` で作り直す |
| win で bell の印が付かない | BEL は ConPTY が止める。章 3 のフックと、`%TEMP%\wezterm-bell\` に旗が置かれるかを確かめる |
| 別タブの印が、マウスを動かすまで出ない | `wezterm.lua` が `update-status` で再描画する作りなので、`status_update_interval` を消していないか確かめる |
| claude が書き換えたファイルが、nvim に出ない | `autocmds.lua` の 2 秒間隔の `checktime` と `redraw` を確かめる。未保存の編集があると、nvim は「破棄か load か」を聞く（nvim の標準の動作） |
| LazyVim の `Alt+j` / `Alt+k` が効かない | zellij の pane の移動と衝突するため、zellij の移動は矢印だけにしてある（設計書 5 章） |
| `Alt+n` で ListView の warning が出る | 起動時だけで、何もしない（ee の決定 2026-11-19） |
