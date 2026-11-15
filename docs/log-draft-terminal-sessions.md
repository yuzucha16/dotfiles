# タブ = セッション環境の調査メモ（2026-11-15）

`docs/log.md` の Next Actions 3 が参照する。レイアウトは、ユーザーの指示（2026-11-15）で「左 claude / 右 nvim、ファイラは右から出す」。

## ① Next Actions 3 の詳細

3. 【起票 11-15】【やる:ユーザー（PC 環境）】タブ = Claude セッションの開発環境を試す（Zed のエディタ・ペインをほぼ使わなくなり、並列セッションをタブで管理したいため）。構成: WezTerm（Lua、WSL ドメイン）で、1 タブ = 左ペイン claude / 右ペイン nvim（next action の markdown を開く）。ファイラは右の nvim からショートカットで出す（cwd をルート。oil.nvim / mini.files / neo-tree から選ぶ）。通知は Claude Code のフック（Notification / Stop）で bell → WezTerm の `bell` と `format-tab-title` でタブに印を付ける。完了: 実機（WSL）で (a) 新しいタブで左 claude・右 nvim が組まれる、(b) claude の入力待ちでタブに印が付く、(c) 右でファイラが開く。足りなければ zellij（フローティングペイン・セッション残存）か herdr（WSL は未確認）を足す。dotfiles に入れる段階で、`.wezterm.lua`・フック・nvim 設定を追加し、decisions の「ターミナル起点から Zed へ移行中」（2026-10 ごろの項）を見直しとして記録する。

## ② 調査の経緯（`log-history.md` の 2026-11-15 の項と同じ）

### 2026-11-15 タブでの Claude セッション管理の手段を調査（変更なし）
- 背景: Zed + ACP で Claude を使っていたが、コードや markdown を見る機会が減り、Zed のエディタ・ペインがほぼ機能していない。並列セッションをタブで管理したい。
- 調べたこと（Web 調査。リポジトリは未変更）:
  - 手段: Windows Terminal / WezTerm / tmux・zellij / herdr / Claude Code の `claude agents`（agent view）/ デスクトップアプリ / Zed のスレッドサイドバーと Terminal Threads / claude-squad など。
  - 層の整理: ターミナル（WezTerm, Windows Terminal）、マルチプレクサ（tmux, zellij, herdr）、エディタ（Neovim など）、Claude 側（フック、agent view）の 4 層。ターミナルとマルチプレクサはタブ・ペインが重なるので、片方に寄せる。
  - WezTerm と Windows Terminal: 動的なレイアウトと通知連動（Lua の mux API、`bell`、`format-tab-title`）は WezTerm。Windows Terminal は `wt.exe` で固定レイアウトの起動まで。WezTerm の番号付き安定版は 2024-02-03 で止まっている（Nightly は継続）。
  - herdr は端末のプラグインではなく単体のマルチプレクサ（エージェント状態をサイドバーに出す）。Windows 版はベータ、WSL は記載なし。ライセンス表記が資料で食い違う（Apache-2.0 / AGPL-3.0）。
  - 参考にした記事: zenn.dev/dely_jp/articles/5d4e89c275789f（bell 方式）、zenn.dev/khasegawa/articles/3eb5a8d7c3e3cb（状態ファイル方式。macOS 前提）。
- 決めたこと: まず WezTerm + Lua + Neovim で試す（zellij は必要になったら足す）。レイアウトは左 claude / 右 nvim、ファイラは右から出す。以降の作業は PC の環境で行う。
- 未確認: WSL での bell 通知の経路、herdr の WSL 動作、ファイラの選定。
