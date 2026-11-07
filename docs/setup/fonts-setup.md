---
type: howto
title: フォント セットアップ手順
tags:
  - font
  - setup
  - dotfiles
---

# フォント セットアップ手順

使うフォントは PlemolJP（1:2 の等幅。Nerd Fonts のグリフ入り）と、Noto Sans JP（プロポーショナル。Excalidraw の図の書き出しなど、本文用）。
取得はスクリプト、インストールは手動。スクリプトは、このリポジトリの `scripts/*/24_fonts.*` が正。

## 対象アプリ

Zed / Notepad++ / Obsidian / Windows Terminal

## インストール対象

| ファイル | 役割 |
|---|---|
| `PlemolJPConsoleNF-Light.ttf` | **main** |
| `PlemolJPConsoleNF-Regular.ttf` | sub |
| `PlemolJPConsoleNF-Text.ttf` | sub |
| `PlemolJPConsoleNF-Bold.ttf` | |
| `PlemolJPConsoleNF-Italic.ttf` | |

- Noto Sans JP は `16_NotoSansJP.zip`（`notofonts/noto-cjk` の `Sans2.004`。latest が Serif のリリースなので、タグを固定している）。展開した `.ttf`（可変フォントなら 1 ファイル）を選んでインストールする。ファミリー名は `Noto Sans JP`（`Noto Sans CJK JP` は別物）。
- PlemolJP は `PlemolJP_NF_v*.zip` に入っている。Moralerspace は、2026-10-06 に使わないことにした（一覧とフォントのフォールバックから外した）。

## 手順

1. `gh` を入れる（`20_apps.bat` / `20_packages.sh` が `manifests` の一覧から入れる）。**ログインは不要**（公開リリースのダウンロードは、未ログインで動く）
2. 取得する

   ```powershell
   scripts\windows\24_fonts.bat
   ```

   ```bash
   scripts/linux/24_fonts.sh
   ```

   - 1件失敗しても残りは続け、最後に `[ERROR]` と終了コード 1 になる。Windows は出力が `tmp\24_fonts.log`（リポジトリの `tmp/`）にも残り、最後に `pause` で止まる

   - 保存先は `~/download`（Windows は `%USERPROFILE%\Downloads`）。WSL で取ると WSL 側の `~/download` に入る。Windows のフォントとして使うなら、Windows 側のスクリプトで取る
   - 一覧は `manifests/fonts.txt`（`owner/repo:asset glob[:release tag]`。タグなしは latest）
3. zip を展開し、上の表の `.ttf` を選んで右クリック →「現在のユーザーにインストール」（Linux は `~/.local/share/fonts/` に置いて `fc-cache -f`）
4. 各アプリを再起動してから、フォント名を設定する
