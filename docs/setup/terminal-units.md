---
type: design
title: WezTerm + zellij + claude + nvim の単位設計
tags:
  - wezterm
  - zellij
  - nvim
  - claude
  - design
---

# WezTerm + zellij + claude + nvim の単位設計

素の Claude Code を、WezTerm・zellij・Neovim で動かす開発環境の「単位」の設計。どの単位を何に対応させ、誰が管理するかを決める。

- **状態**: 設計だけ(2026-11-18〜19)。実装は PC で、既存の試作(`windows/wezterm/wezterm.lua`、`home/.config/nvim/`、[[wezterm-claude-nvim]])を消して一から作る。この設計書は既存の試作を前提にしない。
- **残すもの**: 既存の試作の「bell でタブに印を付ける」仕組み(5 章)だけは、考え方を引き継ぐ。
- **方針**: 複雑にしない。層は 4 つ(WezTerm、zellij、claude、nvim)で、それぞれの責務を重ねない。

## 1. 層と単位

| 層 | 単位 | この構成での意味 | 数 |
|---|---|---|---|
| WezTerm | window | 画面 | 1 |
| WezTerm | workspace | 使わない | ― |
| WezTerm | tab | **cwd 1 つ**(リポジトリ、または worktree) | cwd の数 |
| WezTerm | pane | タブに 1 つだけ。中で zellij が動く | 1 |
| zellij | session | **タブと 1 対 1**。名前は cwd から決める | タブと同数 |
| zellij | tab | 使わない(1 セッション 1 タブ) | 1 |
| zellij | tiled pane | claude と nvim の置き場 | 2〜4 |
| zellij | floating pane | ターミナル、git の TUI、その他 | 0〜1 |
| Claude Code | session | 1 つの会話。zellij の pane 1 つを占める。会話は cwd ごとに保存され、`claude --resume` の一覧も cwd ごと | 1〜3 |
| Neovim | instance | セッションに 1 つ | 1 |
| Neovim | buffer | 開いたファイル。何個でも | 任意 |
| Neovim | window(split)・floating | nvim の中の表示。ピッカーなど nvim の UI に使う | 任意 |
| Neovim | tabpage、`:terminal` | 使わない | ― |

一言でいうと、**WezTerm の tab = cwd = zellij の session、zellij の pane = プロセス(claude か nvim)、ファイルは nvim の buffer**。

## 2. 原則

1. **tab = cwd = zellij session**。同じ cwd のタブは作らない。WezTerm のタブを閉じても zellij のセッションは残り(detach)、同じ cwd のタブを開き直すと、claude も nvim もそのまま戻る。
2. **pane は zellij だけが持つ**。WezTerm は pane を分割しない。分割を 2 つの層でできると、キーも状態も 2 重になるため。
3. **nvim はセッションに 1 つ**。2 つの nvim で同じファイルを開くと、swap の警告(E325)と、どちらが新しいかの混乱が起きる。1 つにまとめれば、buffer の一覧と undo が 1 か所で済む。
4. **floating は zellij に寄せる**。ターミナルと git の TUI は zellij の floating pane で開く。nvim の floating は nvim 自身の UI(ピッカー、通知)だけにし、nvim の中でターミナルを開かない。同じ用途の floating を 2 つの層に持たないため。
5. **並列に編集させたいときは、git worktree を作って別のタブにする**。worktree は別の cwd なので、原則 1 がそのまま保てる。同じ cwd の複数セッションは、編集するファイルを分ける(調べもの・レビューのセッションと、編集のセッション 1 つ、が基本の形)。

## 3. pane の配置

基本形は「左 claude、右 nvim」。claude が増えると右上に積み、nvim は右下へ寄る。

```
2 panes(基本形)        3 panes                 4 panes
+---------+---------+   +---------+---------+   +---------+---------+
|         |         |   |         | claude2 |   |         | claude2 |
| claude1 |  nvim   |   | claude1 +---------+   | claude1 +---------+
|         |         |   |         |  nvim   |   |         | claude3 |
|         |         |   |         |         |   |         +---------+
+---------+---------+   +---------+---------+   |         |  nvim   |
                                                +---------+---------+
floating(どの形でも 1 つ): ターミナル / git の TUI / その他
```

- 配置は zellij のレイアウト(KDL)で書く。基本形を `default_layout` にし、3・4 pane の形を `swap_tiled_layout`(pane の数で自動に切り替わるレイアウト)で書く。claude を足すキー(`Alt+c`)は `Run "claude"` で新しい pane を開くだけで、配置はレイアウトが決める。claude を閉じると、前の形に戻る。
- **最大数の扱い**: 「claude 3、nvim 1、floating 1 の計 5」は、**レイアウトを書く範囲**として残し、**数の制限としては実装しない**(推奨)。制限を実装すると、超えたときの動き(拒否する、警告する)まで決める必要があり、仕様が増えるため。4 を超えて tiled pane を開いた場合は、zellij の既定の並べ方になる(壊れはしない)。
- nvim の幅は、右の列の下の段だけになる。狭いときは zellij の全画面(pane を一時的に全面にする)で広げる。

## 4. 責務とキーの分担

| 層 | 管理するもの | キー(修飾キーで層を分ける) |
|---|---|---|
| WezTerm(`wezterm.lua`) | タブの作成(cwd を選ぶ)、同じ cwd のタブがあればそこへ移る、タブ名、bell の印、フォント・色 | `Ctrl+Shift+<キー>` だけ(例: `Ctrl+Shift+T` で cwd を選んでタブ) |
| zellij(`config.kdl`、レイアウト) | session、pane の配置、floating、全画面、claude の pane を足す | `Alt+<キー>` だけ(pane の移動、`Alt+f` floating、`Alt+c` claude を足す) |
| claude(`~/.claude/settings.json`) | 会話、入力待ち・停止の通知(bell) | claude 自身のキー |
| nvim(LazyVim) | buffer、split、ファイラ、ディスクの変更の取り込み | `<Space>` 始まりと `Ctrl` |

- **zellij は「unlock-first」のキーの型にする**(既定は locked で、`Ctrl+g` で解除してから zellij の操作をする)。zellij の既定は `Ctrl+p` `Ctrl+n` `Ctrl+o` `Ctrl+s` などを取ってしまい、nvim と claude のキーとぶつかるため。`Alt` の操作は locked でも使える形にする(要確認。9 章)。
- **ぶつかるもの**: LazyVim の `Alt+j` / `Alt+k`(行の移動)は、zellij の `Alt+j` / `Alt+k`(pane の移動)に取られる。行の移動を諦めるか、zellij の pane の移動を矢印(`Alt+←↓↑→`)だけにするかを、使いながら決める。
- WezTerm は `Alt` を使わない(既存の試作の `Alt+h/j/k/l` は消す)。

## 5. 通知(claude → WezTerm のタブの印)

既存の試作の仕組みを引き継ぎ、間に zellij が入るだけにする。

1. claude のフック(Notification と Stop)が、`printf '\a' > /dev/tty` で BEL を出す。room では、`room init` の段 `bellhook` が入れる。
2. zellij が、pane の BEL を外側の端末(WezTerm)へそのまま渡す。zellij 0.44 以降は、別のタブの BEL も渡す。**例外: 隠した floating pane の BEL は、表示するまで渡らない**(zellij の issue #3245)。claude は floating に置かないので、この構成では当たらない。
3. WezTerm の `bell` イベントで、別のタブなら `wezterm.GLOBAL` に印を付け、`format-tab-title` でタブをオレンジの 🔔 にする。そのタブへ移ったら消す(既存の試作と同じ)。

- 分かるのは「どのタブ(cwd)が呼んでいるか」まで。タブの中のどの claude かは、zellij 側の表示で見る(zellij 0.46 の、入力待ちの pane を一覧する機能が使えるかは未確認)。
- 音は鳴らさない(`audible_bell = 'Disabled'`)。

## 6. 起動の流れ

1. `Ctrl+Shift+T` で cwd の候補を選ぶ。同じ cwd のタブがあれば、そこへ移って終わり。
2. 無ければ、WezTerm がその cwd でタブを作り、`zellij attach --create <セッション名>` を実行する。セッション名は cwd から決める(例: `dotfiles`、`resources`。同じ名前の別の cwd は、親のディレクトリ名を足して区別する)。
3. 新しいセッションなら、`default_layout` で左 claude(`claude --resume` の一覧から選ぶ)、右 nvim が開く。既存のセッションなら、前の状態に戻る。
4. タブ名は cwd の名前にする(WezTerm の Lua が付ける)。

## 7. 作らないもの(線引き)

- WezTerm の pane 分割、WezTerm の workspace、zellij の複数タブ、nvim の tabpage と `:terminal`。
- WezTerm の Lua と nvim の Lua をつなぐ仕組み(ソケット、`--remote`)。両者の約束は「cwd が同じ」ことだけ。必要になったら、cwd から決まる名前のソケットで nvim を起動し、claude から `nvim --server … --remote` で開く形を足す。
- pane の最大数の強制(3 章)。
- claude の差分を nvim で見る連携(`claudecode.nvim` など)。使ってみて要るなら足す。

## 8. ee の判断が要ること

1. **Windows ネイティブのタブを最初から入れるか**。zellij は 0.44 から Windows でネイティブに動く(2026-03)が、bell のフックは PowerShell の別の書き方になり、room と 2 通りになる。**推奨: 最初は room(WSL)だけで組み、使い勝手が固まってから Windows を足す**(room には zellij 0.46 と `bellhook` が既にあるため)。
2. **floating の git の TUI に何を使うか**(lazygit、tig など)。room にはまだ入っていない。
3. **pane の最大数**: 3 章の推奨(レイアウトの範囲として残し、制限は実装しない)で良いか。

## 9. PC で確かめること(実装のとき)

1. swap layout で、claude を足したときに nvim が右下へ寄るか(既存の pane がどの枠に入るかの順は、zellij の文書に明記が無い)。寄らなければ、レイアウトで nvim の pane を `command` 付きで固定するか、claude を足すときに nvim の pane の上へ開く操作に変える。
2. unlock-first の型で、`Alt` の操作が locked のまま使えるか。
3. 別の WezTerm タブにいるとき、claude の入力待ちで、そのタブに 🔔 が付くか(zellij を挟んだ BEL)。
4. claude がファイルを書き換えたとき、nvim に反映されるか。LazyVim は FocusGained で `checktime` するが、zellij の中の pane の移動で FocusGained が来るかは未確認。来なければ、一定の間隔で `checktime` する autocmd を足す。
5. WezTerm のタブを閉じて開き直すと、zellij のセッションに戻り、claude が動き続けているか。

## 10. 実装の順(PC で)

1. 既存の試作(`windows/wezterm/wezterm.lua`、`home/.config/nvim/`、`docs/setup/wezterm-claude-nvim.md`)を消す。
2. zellij: `config.kdl`(unlock-first、`Alt+c`、`default_layout`)とレイアウト 1 つ(基本形 + swap layout)。
3. WezTerm: タブ = cwd(候補の一覧、重複の防止、zellij の起動)と bell の印だけの `wezterm.lua`。
4. nvim: LazyVim(または AstroNvim)を入れ、この設計から要るのは `checktime` だけ。
5. 9 章を確かめ、結果でこの設計書を直す。

## 出典

- zellij の BEL の扱い: [zellij issue #4595](https://github.com/zellij-org/zellij/issues/4595)、[zellij issue #3245](https://github.com/zellij-org/zellij/issues/3245)(0.44 で別のタブの BEL も渡す。隠した floating は渡らない)
- zellij の swap layout: [Swap Layouts](https://zellij.dev/documentation/swap-layouts)
- zellij の Windows 対応(0.44、2026-03-23): [Zellij 0.44.0](https://zellij.dev/news/remote-sessions-windows-cli/)
- WezTerm に floating pane が無いこと(安定版 20240203、nightly の変更履歴にも無い。2026-11-18 に確認): [WezTerm Change Log](https://wezterm.org/changelog.html)
