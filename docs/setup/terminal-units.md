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

- **状態**: 設計だけ(2026-11-18〜19)。pane の配置は 2 案(4 章)を並べ、実機で動かして 1 つに決める。実装は PC で、既存の試作(`windows/wezterm/wezterm.lua`、`home/.config/nvim/`、[[wezterm-claude-nvim]])を消して一から作る。この設計書は既存の試作を前提にしない。
- **残すもの**: 既存の試作の「bell でタブに印を付ける」仕組み(5 章)だけは、考え方を引き継ぐ。
- **方針**: 複雑にしない。層は 4 つ(WezTerm、zellij、claude、nvim)で、それぞれの責務を重ねない。
- **決定(2026-11-19、ee)**: 環境は pwsh7・wsl・room の 3 つ(2 章)。floating の git ツールは lazygit。pane の数の制限は設けない。

## 1. 層と単位

| 層 | 単位 | この構成での意味 | 数 |
|---|---|---|---|
| WezTerm | window | 画面 | 1 |
| WezTerm | workspace | 使わない | ― |
| WezTerm | tab | **環境と cwd の組 1 つ**(リポジトリ、または worktree) | 組の数 |
| WezTerm | pane | タブに 1 つだけ。中で zellij が動く | 1 |
| zellij | session | **タブと 1 対 1**。名前は cwd から決める | タブと同数 |
| zellij | tab | 使わない(1 セッション 1 タブ) | 1 |
| zellij | tiled pane | claude と nvim の置き場 | claude N + nvim 1 |
| zellij | floating pane | lazygit、ターミナル、その他 | 必要なとき |
| Claude Code | session | 1 つの会話。zellij の pane 1 つを占める。会話は cwd ごとに保存され、`claude --resume` の一覧も cwd ごと | pane と同数 |
| Neovim | instance | セッションに 1 つ | 1 |
| Neovim | buffer | 開いたファイル。何個でも | 任意 |
| Neovim | window(split)・floating | nvim の中の表示。ピッカーなど nvim の UI に使う | 任意 |
| Neovim | tabpage、`:terminal` | 使わない | ― |

一言でいうと、**WezTerm の tab = (環境, cwd) = zellij の session、zellij の pane = プロセス(claude か nvim)、ファイルは nvim の buffer**。

## 2. 環境(Windows Terminal のプロファイルに相当)

WezTerm から入る先は、Windows Terminal にある 3 つと同じにする。

| 環境 | WezTerm の起動先 | 中で動くもの |
|---|---|---|
| pwsh7 | ローカル。scoop の pwsh7(`~\scoop\shims\pwsh.exe`。パスは実装時に確認) | Windows ネイティブの claude・nvim・zellij・lazygit |
| wsl | WSL ドメイン(既定のディストリビューション) | 通常の WSL の claude・nvim・zellij・lazygit |
| room | WSL ドメイン `room-<Area>`(隔離。`/mnt/c` なし) | 同上。`room init` が nvim・zellij・claude・bell フックを入れる |

- **タブの識別は(環境, cwd)**。同じパスでも、環境が違えば別のタブ(Windows の `C:\...` と WSL の `/home/...` は別物で、zellij のサーバーも環境ごとに別)。
- `Ctrl+Shift+T` の候補は「環境 + cwd」の一覧(`wezterm.lua` に書く)。環境ごとに cwd の書き方が違うので、一覧で持つ。
- 道具の入れ方(実装時に確認する):

| 道具 | pwsh7 | wsl | room |
|---|---|---|---|
| zellij | scoop `zellij`(`manifests/apps.txt` に既にある。0.44 から Windows ネイティブ) | 12.5 の判断 | `room init` の段 `zellij`(scoop の版に合わせる。12 章) |
| nvim | scoop `neovim`(`apps.txt` に既にある) | 12.5 の判断 | `room init` の段 `nvim`(scoop の版に合わせる。12 章) |
| lazygit | scoop `lazygit`(未確認) | 12.5 の判断 | `room init` に段を足す(scoop の版に合わせる。workbase 側の別作業。未着手) |
| claude | 既存の `windows/claude/` | 個別に導入 | `room init` の段 `claude`(版は固定していない。12 章) |

- **版は、scoop の版を基準に、`room init` が合わせる**(12 章)。

## 3. 原則

1. **tab = (環境, cwd) = zellij session**。同じ組のタブは作らない。WezTerm のタブを閉じても zellij のセッションは残り(detach)、同じ組のタブを開き直すと、claude も nvim もそのまま戻る。
2. **pane は zellij だけが持つ**。WezTerm は pane を分割しない。分割を 2 つの層でできると、キーも状態も 2 重になるため。
3. **nvim はセッションに 1 つ**。2 つの nvim で同じファイルを開くと、swap の警告(E325)と、どちらが新しいかの混乱が起きる。1 つにまとめれば、buffer の一覧と undo が 1 か所で済む。
4. **floating は zellij に寄せる**。lazygit とターミナルは zellij の floating pane で開く。nvim の floating は nvim 自身の UI(ピッカー、通知)だけにし、nvim の中でターミナルを開かない。同じ用途の floating を 2 つの層に持たないため。
5. **並列に編集させたいときは、git worktree を作って別のタブにする**。worktree は別の cwd なので、原則 1 がそのまま保てる。同じ cwd の複数セッションは、編集するファイルを分ける(調べもの・レビューのセッションと、編集のセッション 1 つ、が基本の形)。

## 4. pane の配置(2 案。実際に動かして選ぶ)

claude を足すたびに、形が**決まった順**で変わる(認知を下げるため、増え方は固定する)。どちらの案も、zellij の「swap layout」(pane の数で形が自動に切り替わる機能)だけで書け、自作のスクリプトは要らない。claude を足すキー(`Alt+c`)は、`claude` の pane を 1 つ開くだけで、形はレイアウトが決める。**案はレイアウトのファイル 1 つで、`config.kdl` の `default_layout` で切り替える**(2 つのファイルを持ち、使ってみて 1 つに絞る)。

共通の約束: 最初は左 claude・右 nvim。nvim は、レイアウトの枠に `command="nvim"` を書き、**引数なしの同じコマンドで起動する**(zellij は、コマンドが同じ pane を同じ枠に入れる。名前では入らない)。

### 案 A: 左右 2 分割(nvim が右下へ寄る)

```
claude 1 つ(初期)       claude 2 つ              claude 3 つ
+---------+---------+   +---------+---------+   +---------+---------+
|         |         |   | claude  |         |   | claude  | claude  |
| claude  |  nvim   |   +---------+  nvim   |   +---------+---------+
|         |         |   | claude  |         |   | claude  |  nvim   |
+---------+---------+   +---------+---------+   +---------+---------+
```

1. 左半分が最初の claude、右半分が nvim。
2. 2 つ目で、左半分が上下に分かれる。
3. 3 つ目で、右半分が上下に分かれる。右上が claude、右下が nvim(nvim が動く)。

```kdl
layout {
    pane split_direction="vertical" {
        pane command="claude" { args "--resume"; }   // 左: 最初の claude
        pane command="nvim"                          // 右: nvim
    }
    swap_tiled_layout name="claude2" {
        tab exact_panes=3 {                          // claude 2 つ + nvim
            pane split_direction="vertical" {
                pane split_direction="horizontal" { pane; pane; }   // 左: claude 上下
                pane                                                  // 右: nvim
            }
        }
    }
    swap_tiled_layout name="claude3" {
        tab exact_panes=4 {                          // claude 3 つ + nvim
            pane split_direction="vertical" {
                pane split_direction="horizontal" { pane; pane; }                  // 左: claude 上下
                pane split_direction="horizontal" { pane; pane command="nvim"; }   // 右: claude / nvim
            }
        }
    }
}
```

実測(2026-11-19、zellij 0.46.0、仮想の端末 200×50。`sleep` を claude・nvim の代わりにした):

- 形は仕様どおりになる。nvim は右下へ寄る。
- **3 つ目を足した瞬間に、2 つ目と 3 つ目の claude の位置が入れ替わる**(2 つ目が右上へ動き、新しい 3 つ目が左下に入る)。フォーカスの位置には左右されない(3 通りで同じ結果)。pane のタイトルで見分ける。
- 4 つ目以降は定義していない(zellij の既定の並べ方)。

### 案 B: 中央 3 分割(nvim は右一列に固定。claude は Z の順)

```
claude 1 つ(初期)       claude 2 つ                 claude 3 つ                 claude 4 つ
+---------+---------+   +------+------+-------+   +------+------+-------+   +------+------+-------+
|         |         |   |      |      |       |   |  c1  |      |       |   |  c1  |  c2  |       |
|   c1    |  nvim   |   |  c1  |  c2  | nvim  |   +------+  c2  | nvim  |   +------+------+ nvim  |
|         |         |   |      |      |       |   |  c3  |      |       |   |  c3  |  c4  |       |
+---------+---------+   +------+------+-------+   +------+------+-------+   +------+------+-------+
```

1. 最初は、左 claude(c1)、右 nvim。
2. 2 つ目で、中央に 1 列が増える(左から c1、c2、nvim)。
3. 3 つ目で、左の列が上下に分かれ、c3 が左下に入る。
4. 4 つ目で、中央の列が上下に分かれ、c4 が中央下に入る。claude は Z の順(c1 左上、c2 中央上、c3 左下、c4 中央下)に埋まる。

nvim は、どの段階でも右一列のまま動かない。

```kdl
layout {
    pane split_direction="vertical" {
        pane command="claude" { args "--resume"; }   // 左: 最初の claude
        pane command="nvim"                          // 右: nvim
    }
    swap_tiled_layout name="claude2" {
        tab exact_panes=3 {                          // claude 2 つ + nvim
            pane split_direction="vertical" { pane; pane; pane command="nvim"; }
        }
    }
    swap_tiled_layout name="claude3" {
        tab exact_panes=4 {                          // claude 3 つ + nvim: 左を上下に
            pane split_direction="vertical" {
                pane split_direction="horizontal" { pane; pane; }
                pane
                pane command="nvim"
            }
        }
    }
    swap_tiled_layout name="claude4" {
        tab exact_panes=5 {                          // claude 4 つ + nvim: 中央も上下に
            pane split_direction="vertical" {
                pane split_direction="horizontal" { pane; pane; }
                pane split_direction="horizontal" { pane; pane; }
                pane command="nvim"
            }
        }
    }
}
```

実測(同じ条件):

- claude を 3 回足して、**どの段階でも位置が入れ替わらず**、Z の順(c1 左上、c2 中央上、c3 左下、c4 中央下)になり、nvim は右一列(x=134、幅 66)のまま動かなかった。
- 5 つ目以降の claude は、定義が無くても、中央の列に積まれた(中央が 3 段になる。nvim は動かない)。
- 閉じたとき: 最後に足した pane を閉じると、1 つ前の形に戻る。途中の pane(例: c2)を閉じると、前の形に戻り、残りの会話の位置が詰まる。**閉じる操作を続けたときに、形が崩れた例が 1 回あった**(原因は未解明。9 章)。
- 幅: 200 桁の画面で、claude の列が 67 桁ずつ、nvim が 66 桁。claude には狭いので、`size` で nvim を 30% ほどに絞る調整が要る(未検証)。

### 2 案の比較

| 観点 | 案 A(左右 2 分割) | 案 B(中央 3 分割) |
|---|---|---|
| nvim の位置 | 3 つ目で右下へ動く | **右一列で動かない** |
| 会話の位置 | 3 つ目で 2・3 つ目が入れ替わる | **入れ替わらない(Z の順)** |
| 覚える規則 | 3 段階の形 | 「左から、上から」の 1 つ(Z) |
| 最初の claude の幅 | 画面の半分 | 3 分の 1(2 つ目から) |
| 5 つ目以降 | zellij の既定 | 中央の列に積まれる |

**推奨は案 B**(認知を下げる、という目的に合う。nvim が動かず、会話の位置が増えた順に決まる)。弱点は claude の幅なので、実機でその幅で使えるかを見て決める。

## 5. 責務とキーの分担

| 層 | 管理するもの | キー(修飾キーで層を分ける) |
|---|---|---|
| WezTerm(`wezterm.lua`) | タブの作成(環境と cwd を選ぶ)、同じ組のタブがあればそこへ移る、タブ名、bell の印、フォント・色 | `Ctrl+Shift+<キー>` だけ(例: `Ctrl+Shift+T` で環境と cwd を選んでタブを開く) |
| zellij(`config.kdl`、レイアウト) | session、pane の配置、floating、全画面、claude を足す | `Alt+<キー>` だけ(pane の移動、`Alt+c` claude を足す、`Alt+g` lazygit、`Alt+f` floating の表示切替) |
| claude(`~/.claude/settings.json`) | 会話、入力待ち・停止の通知(bell) | claude 自身のキー |
| nvim(LazyVim) | buffer、split、ファイラ、ディスクの変更の取り込み | `<Space>` 始まりと `Ctrl` |

- **zellij は「unlock-first」のキーの型にする**(既定は locked で、`Ctrl+g` で解除してから zellij の操作をする)。zellij の既定は `Ctrl+p` `Ctrl+n` `Ctrl+o` `Ctrl+s` などを取ってしまい、nvim と claude のキーとぶつかるため。`Alt` の操作は locked でも使える形にする(要確認。9 章)。
- **ぶつかるもの**: LazyVim の `Alt+j` / `Alt+k`(行の移動)は、zellij の `Alt+j` / `Alt+k`(pane の移動)に取られる。行の移動を諦めるか、zellij の pane の移動を矢印(`Alt+←↓↑→`)だけにするかを、使いながら決める。
- WezTerm は `Alt` を使わない(既存の試作の `Alt+h/j/k/l` は消す)。
- **floating**: `Alt+g` で lazygit を floating で開く(閉じると pane も消える)。ターミナルも同じ型(キーは実装時に決める)。

## 6. 通知(claude → WezTerm のタブの印)

既存の試作の仕組みを引き継ぎ、間に zellij が入るだけにする。

1. claude が入力待ち・停止のときに BEL を出す。room では、`room init` の段 `bellhook` が、claude のフック(Notification と Stop)で `printf '\a' > /dev/tty` を実行する。
2. zellij が、pane の BEL を外側の端末(WezTerm)へそのまま渡す。zellij 0.44 以降は、別のタブの BEL も渡す。**例外: 隠した floating pane の BEL は、表示するまで渡らない**(zellij の issue #3245)。claude は floating に置かないので、この構成では当たらない。
3. WezTerm の `bell` イベントで、別のタブなら `wezterm.GLOBAL` に印を付け、`format-tab-title` でタブをオレンジの 🔔 にする。そのタブへ移ったら消す(既存の試作と同じ)。

- 分かるのは「どのタブ(環境と cwd)が呼んでいるか」まで。タブの中のどの claude かは、zellij 側の表示で見る。
- 音は鳴らさない(`audible_bell = 'Disabled'`)。
- **pwsh7 と wsl**: room の `bellhook` は room にしか入らない。pwsh7(PowerShell のフックから端末へ BEL を出す書き方)と wsl は、実装時に確かめる(9 章)。claude 本体に、入力待ちで bell を鳴らす設定(`preferredNotifChannel` の `terminal_bell`)があれば、フックなしで 3 環境とも同じにできる(未確認)。

## 7. 起動の流れ

1. `Ctrl+Shift+T` で「環境 + cwd」の候補を選ぶ。同じ組のタブがあれば、そこへ移って終わり。
2. 無ければ、WezTerm がその環境・cwd でタブを作り、`zellij attach --create <セッション名>` を実行する。セッション名は cwd から決める(例: `dotfiles`、`resources`。同じ名前の別の cwd は、親のディレクトリ名を足して区別する)。
3. 新しいセッションなら、既定のレイアウトで左 claude(`claude --resume` の一覧から選ぶ)、右 nvim が開く。既存のセッションなら、前の状態に戻る。
4. タブ名は「環境: cwd の名前」にする(WezTerm の Lua が付ける)。

## 8. 作らないもの(線引き)

- WezTerm の pane 分割、WezTerm の workspace、zellij の複数タブ、nvim の tabpage と `:terminal`。
- WezTerm の Lua と nvim の Lua をつなぐ仕組み(ソケット、`--remote`)。両者の約束は「cwd が同じ」ことだけ。必要になったら、cwd から決まる名前のソケットで nvim を起動し、claude から `nvim --server … --remote` で開く形を足す。
- pane の数の制限、pane を並べる自作のスクリプト(4 章のとおり、どちらの案もレイアウトだけで足りる)。
- claude の差分を nvim で見る連携(`claudecode.nvim` など)。使ってみて要るなら足す。

## 9. PC で確かめること(実装のとき)

1. **2 案(4 章)を実機で動かして選ぶ**。`default_layout` を切り替えて、案 A の入れ替わりが気になるか、案 B の claude の幅(200 桁で 67 桁)で使えるかを見る。案 B の幅は、nvim の `size` を 30% ほどに絞って調整する。案 A の入れ替わりが気になるなら、3 つ目の形を「右上に 2 つ目、右下に nvim」に変える案もある(未検証)。
2. 実物の `claude` と `nvim` で、4 章の形になるか。claude の pane を閉じたとき(`close_on_exit true` にする想定)、前の形に戻るか。案 B で、途中の pane を続けて閉じたときに形が崩れた例の再現(4 章)。
3. unlock-first の型で、`Alt` の操作が locked のまま使えるか。
4. 別の WezTerm タブにいるとき、claude の入力待ちで、そのタブに 🔔 が付くか。room、pwsh7、wsl の 3 つで(zellij を挟んだ BEL。Windows ネイティブの zellij が BEL を渡すかは未確認)。
5. claude がファイルを書き換えたとき、nvim に反映されるか。LazyVim は FocusGained で `checktime` するが、zellij の中の pane の移動で FocusGained が来るかは未確認。来なければ、一定の間隔で `checktime` する autocmd を足す。
6. WezTerm のタブを閉じて開き直すと、zellij のセッションに戻り、claude が動き続けているか。
7. pwsh7 で、zellij・nvim・lazygit(scoop)が入り、`claude` が zellij の中で動くか。
8. 性能のボトルネック(11 章。V1〜V6 の測定)。
9. 版の揃え(12 章。V7: scoop の版と、部屋の記録が一致するか)。

## 10. 実装の順(PC で)

1. 既存の試作(`windows/wezterm/wezterm.lua`、`home/.config/nvim/`、`docs/setup/wezterm-claude-nvim.md`)を消す。
2. zellij: `config.kdl`(unlock-first、`Alt+c`、`Alt+g`)とレイアウト 2 ファイル(4 章の案 A と案 B。`default_layout` で切り替える)。まず room で動かす(zellij・nvim・bellhook が入っている)。
3. WezTerm: 環境と cwd の候補、タブの重複の防止、zellij の起動、bell の印だけの `wezterm.lua`。
4. nvim: LazyVim を入れる。この設計から要るのは `checktime` だけ。
5. lazygit: pwsh7 は scoop(`apps.txt` に足す)、room は `room init` に段を足す(workbase 側)。版は scoop に合わせる(12 章)。
6. pwsh7 と wsl を足し、9 章を確かめ、結果でこの設計書を直す。

## 11. 性能のボトルネック(WezTerm を使うと増える点。検証して、必要なら対策する)

zed は WSL 側にリモートサーバーを立て、画面だけを Windows に出していたので、ファイルを触る処理は WSL の中で済んでいた。この構成は、**WezTerm が Windows 側の端末で、claude・nvim・zellij・lazygit は WSL の中のプロセス**になる。その違いで、zed では気づかなかった遅さが出うる。ここでは、疑う点と、測り方と、直す順を決めておく。**測る前に直さない**(差が出た所だけ直す)。

cwd の置き場(Windows 側か WSL 側か)は、設計に入れない(Windows 側を使う選択肢を残すため)。遅さが出たときに、環境ごとの cwd の候補(2 章)の書き方で寄せる。

### 11.1 リモートサーバー案と直接起動案

| | 直接起動(WezTerm の WSL ドメイン) | リモートサーバー案(WSL 内に `wezterm-mux-server` を置き、WezTerm が接続) |
|---|---|---|
| 経路 | WezTerm → `wsl.exe`(ConPTY 経由) → WSL 内のプロセス | WezTerm → ソケット(SSH ドメインか unix ドメイン) → WSL 内のサーバー → プロセス |
| 層 | 1 つ減る(サーバーが無い) | サーバーの起動・接続・認証を持つ |
| セッションの残存 | zellij が担う(タブを閉じても残る) | サーバーが担う(zellij と役が重なる) |
| 性能 | ConPTY を通るだけ | 描画がソケット越しに加わる |

**推奨は直接起動**(この設計のとおり)。zed のリモートの利点は、「画面」と「ファイルを触る処理」を別の場所に分けられることだったが、端末では、全部が端末の中のプロセスで動くため、分ける物が無い。リモートサーバー案は、zellij と役が重なって層が増えるだけになる。なお WezTerm に SSH ドメイン・unix ドメインがあること(WSL 内にサーバーを置く形が作れること)は一般的な機能で、この環境では試していない(未検証)。

### 11.2 疑う点(仮説。実測するまで確定しない)

| # | 疑う点 | 起きる条件 | 兆候 | 対策の候補 |
|---|---|---|---|---|
| 1 | **`/mnt/c` 越しのファイル I/O**(WSL 2 は Windows 側のファイルを、別の経路(9p)で読む。小さいファイルを大量に触る処理で遅くなりやすい) | cwd が `/mnt/c` 配下(room で Windows 側の project を触るとき) | `git status`、`rg`、ファイルの走査、ビルド、nvim のピッカー・ファイラ、lazygit の更新が遅い | 走査する対象を成果物に絞る。作業のリポジトリを WSL の `~/` に置く(room は workbase を `~/` に置いている)。git の設定(`core.untrackedCache` など)の調整 |
| 2 | **監視ソフトの、ファイル単位の検査**(Windows 側のファイル操作に検査が上乗せされる。`/mnt/c` 越し、pwsh7 の環境が当たる。WSL の仮想ディスクの中は、ファイル単位では検査されないことが多いが、製品による。未確認) | Windows 側の cwd、Windows 側で動く claude・nvim・git | 同じ操作が、Windows 側と `~/` で大きく違う | 作業のリポジトリを `~/` に置く。除外の申請(組織の運用による。できない前提で組む) |
| 3 | **`wsl.exe` と ConPTY の経路**(タブを開くたびの起動、入力と描画が ConPTY を通る) | room・wsl のタブ全般 | タブを開いてからプロンプトが出るまで、入力の遅れ、大量出力の描画 | zellij のセッションを残して再接続する(2 回目以降は、claude・nvim の起動が要らない)。WSL の仮想マシンが止まらないようにする(`.wslconfig` の `vmIdleTimeout`。未確認) |
| 4 | **zellij を挟む分の描画** | 大量出力、全画面の再描画 | zellij なしより出力が詰まる | zellij の設定の調整、重いときは該当の操作だけ zellij の外で行う |
| 5 | **WezTerm の描画設定**(GPU の使い方、更新の頻度) | 業務用 PC の GPU・仮想環境 | 大量出力でカクつく、入力が遅れる | `front_end` と `max_fps` の設定を変えて比べる |
| 6 | (切り分け)**claude の応答の遅さは、端末でなくネットワークかもしれない** | プロキシ、ゲートウェイ経由 | `claude` だけが遅く、`ls` や `rg` は速い | 端末の測定(V1〜V5)と分けて見る。ネットワークは別の問題 |

### 11.3 検証項目(実装のとき。結果はこの表に書き足す)

同じ操作を、同じ規模のリポジトリで、**環境(WSL の `~/`、`/mnt/c`、pwsh7)ごとに 3 回**測る(1 回目はキャッシュが効かないので、2 回目以降と分けて書く)。

| # | 測ること | 方法 | 比べる相手 | 見る疑い |
|---|---|---|---|---|
| V1 | ファイルの走査 | `time git status`、`time rg -l <語>`、`time find . -type f \| wc -l` | `~/` と `/mnt/c`(と、pwsh7 の同等のコマンド) | 1、2 |
| V2 | 実際の project(Windows 側の成果物) | nvim のピッカーとファイラ、lazygit の起動と更新、ビルドの体感と時間 | 同じ project を `~/` にコピーしたもの | 1、2 |
| V3 | タブの起動 | 「環境 + cwd」を選んでから、プロンプトと claude の入力欄が出るまで。room・wsl・pwsh7 で、**新しいセッションと、zellij に再接続する 2 回目** | 環境どうし、1 回目と 2 回目 | 3 |
| V4 | 大量出力の描画 | `seq 1 200000` が終わるまでの時間と、画面のカクつき | WezTerm 直、zellij 経由、(参考)Windows Terminal | 3、4、5 |
| V5 | 入力の遅れ | nvim と claude の入力欄で、キーを打ってから出るまでの体感。可能なら動画で比べる | zellij あり・なし、WezTerm と Windows Terminal | 3、4、5 |
| V6 | 端末とネットワークの切り分け | claude の応答が遅いとき、同じタブで `ls`、`rg` の速さを見る | claude 以外のコマンド | 6 |

- **基準**: 数値の閾値は、測ってから決める(先に決めない)。暫定は「体感で待たされるか」と、「同じ操作で環境間の比が大きいか」。
- **記録**: 結果は、この表に日付つきで書き足し、決まった対策は `docs/decisions.md` に残す(2026-11-19 に、ユーザーが「場合によっては検証・対策する」と指示)。

### 11.4 対策の順

1. **まず測る**(11.3)。差が出なかった点は、何もしない。
2. 差が出たら、軽い順に試す: (a) 走査する対象を絞る(`rg` の対象、ピッカーの root) → (b) zellij の再接続を使う(タブの起動を減らす) → (c) 作業のリポジトリの置き場を `~/` に寄せる(**Windows 側を使う選択肢は残す**。環境ごとの cwd の候補の書き方で、既定をどちらにするかだけを変える) → (d) WezTerm の描画設定、`.wslconfig` → (e) 監視ソフトの除外の申請(組織の運用による)。
3. 対策した後は、同じ検証をもう一度行い、効いたかを確かめる。

## 12. ツールの版を Windows と WSL・room で揃える

ee の要望(2026-11-19): Windows と WSL 側のツールの版を、可能な限り合わせる。**基準は scoop の版**で、WSL 側には、その版と同じか近い版を入れる。**入れるのは `room init` でまとめて行う**。uv と Python は、すでに `workflow-kit/room/.python-version` で揃えている(こちらは固定した 1 か所が基準。ツールは scoop が基準、という違いがある)。

### 12.1 仕組み

1. Windows 側は、今までどおり scoop が入れる・更新する(`manifests/apps.txt`。`neovim` `zellij` は既にある。`lazygit` を足す)。版の固定(`scoop hold`)は、しない。
2. `room init`(Windows の PC で実行する)が、scoop で今入っている版を読む。読み方の案: `%USERPROFILE%\scoop\apps\<アプリ>\current\manifest.json` の `version`(未確認。`scoop list` の出力を読む方法もある)。
3. 部屋の段 `nvim` `zellij` `lazygit` が、**その版を、配布元(GitHub Releases)の同じタグから取って入れる**。nvim・zellij・lazygit は、Windows と Linux が同じタグで配られているので、**同じ版**になる。SHA-256 は、同じリリースが配るチェックサムのファイルで検証する(下の 12.3)。
4. scoop にその版が無い、または scoop が入っていない PC(PC1 など。実機の都合)では、`room.py` の固定した版(今の `NVIM_VERSION` `ZELLIJ_VERSION`)を、予備として使う。
5. 入れた版は、`room init` の報告に出し、部屋の中にも記録する(例: `~/.local/share/room-tools.txt`。場所は実装時に決める)。

### 12.2 揃える範囲

| ツール | 揃え方 | 精度 |
|---|---|---|
| nvim・zellij・lazygit | 上の仕組み | **同じ版** |
| ripgrep・fd | 部屋は apt(ディストリビューション依存)。差で困ったときだけ、同じ仕組みの段を足す | 近い版 |
| claude | 部屋は `install.sh`、Windows は `windows/claude/`。どちらも自動更新される。固定しない | 近い版(自動更新の差) |
| uv・Python | 既存(`.python-version`) | 同じ版 |
| WezTerm・pwsh7 | Windows だけ | 対象外 |

### 12.3 決める・確かめること

- **SHA-256 の検証が、今より弱くなる**: 今の room は、版ごとの SHA-256 を `room.py` に持っている(正本が `room.py`)。scoop の版に合わせると、版が動くので、**同じリリースのチェックサムのファイルを取って検証する**形になる。通信の途中の破損と、取り違えは防げるが、GitHub のリリースそのものが差し替えられたときは防げない(固定した SHA-256 なら防げた)。**推奨: この弱さを受け入れる**(同じ配布元を信頼する範囲で、版を追う運用を優先する)。固定した SHA-256 の予備は、予備の版のときに使う。
- **PC ごとに部屋の版が違いうる**: scoop を更新した日が PC ごとに違うので、同じ日に作った部屋でも、PC1 と PC2 で版が違う。許容する(「可能な限り」)。記録(12.1 の 5)で、違いを後から確かめる。
- **scoop を更新した後の追従**: `scoop update` の後に、`room init <Area> --only nvim,zellij,lazygit` を再実行すれば、部屋が追いつく。同じ版なら何もしない(何度実行しても同じ結果)。追従を忘れると差が出るので、次の点検を用意する。
- **揃っているかの点検(読み取り専用)**: scoop の版と、部屋の記録を比べ、違うものだけを出す(`room init` の報告、または単独のコマンド。実装時に決める)。
- scoop のアプリ名と、GitHub のタグの対応(`neovim` → `v<版>`、`zellij` → `v<版>`、`lazygit` → `v<版>`)は、実装時に確かめる(タグの付け方が違うアプリが無いか)。

### 12.4 実装の置き場

- **workbase 側の別作業**(未着手): `room.py` の段 `nvim` `zellij` の改修と、段 `lazygit` の追加。`room init` が scoop の版を読む処理。dotfiles の設計書には「何を揃えるか」だけを書き、挙動は workbase に書く(`workbase-dotfiles-boundary` の決定どおり。workbase は dotfiles の中身を読まない。読むのは、PC に入っている scoop の場所だけ)。
- **dotfiles 側**: `manifests/apps.txt` に `lazygit` を足すだけ(`neovim` `zellij` は既にある)。

### 12.5 ee の判断が要ること

1. **「wsl」(room でない通常の WSL)にも入れるか**。`room init` は、部屋(専用のディストリビューション)を作る・整える道具なので、通常の wsl は対象外になる。**推奨: 当面は room だけ**(ee の用途は room が中心で、wsl は予備のため)。wsl にも要るなら、同じ段を既存のディストリビューションへ向ける方法を、workbase 側で別に検討する。
2. **SHA-256 の検証の弱さ(12.3)を受け入れるか**(推奨: 受け入れる)。

## 出典

- zellij の BEL の扱い: [zellij issue #4595](https://github.com/zellij-org/zellij/issues/4595)、[zellij issue #3245](https://github.com/zellij-org/zellij/issues/3245)(0.44 で別のタブの BEL も渡す。隠した floating は渡らない)
- zellij の swap layout: [Swap Layouts](https://zellij.dev/documentation/swap-layouts)(4 章の挙動は、0.46.0 の実測)
- zellij の Windows 対応(0.44、2026-03-23): [Zellij 0.44.0](https://zellij.dev/news/remote-sessions-windows-cli/)
- WezTerm に floating pane が無いこと(安定版 20240203、nightly の変更履歴にも無い。2026-11-18 に確認): [WezTerm Change Log](https://wezterm.org/changelog.html)
