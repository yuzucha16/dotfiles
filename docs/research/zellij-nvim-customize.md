# zellij・nvim の変更要望: 現行の仕様と方針（調査のみ・第 2 版）

2026-11-20 調査。実装は PC で行う。設定ファイルは変えていない。
第 1 版からの変更: 「複雑にしない。要らないものは omit」「絶対パスを書かない」「Windows は scoop の pwsh7、WSL は bash」の条件で見直した。

## 前提（リポジトリから読んだもの）

- zellij 0.46.0。設定は `home/.config/zellij/config.kdl` 1 本で、Windows（`%APPDATA%\Zellij\config` へリンク）と WSL（`~/.config/zellij/`）で共用。KDL に OS の分岐は無い。
- `keybinds` は zellij 既定の preset の上に自前の bind を重ねている。既定の preset には `Alt n` = `NewPane`、`Alt f` = `ToggleFloatingPanes` がある（`config.kdl` には書いていない）。
- 新しい pane・floating のシェルは、zellij の `default_shell`。Windows では zellij が `SHELL` を見ないので、`wezterm.lua` が新しいセッションの作成時に `options --default-shell pwsh` で渡す（PATH 上の pwsh = scoop）。WSL は `SHELL`（bash）。
- nvim: 0.12.6 + LazyVim（lazy.nvim）。ファイラは Snacks explorer（LazyVim の `install_version` 8 の既定。neo-tree は入っていない）。`<leader>e` で開閉し、常時表示ではない。レイアウトは左、幅 40。

## zellij

### 1・3. Alt+n と Alt+f で、環境の標準シェルを開く

**結論: 設定の変更は要らない見込み（omit）**。今の `NewPane` と `ToggleFloatingPanes` は、どちらも `default_shell` を開く。Windows は scoop の pwsh7、WSL は bash になるので、希望と同じ。確認だけ行う（Z1）。

- Windows で違うシェル（cmd など）が出たら、原因は「`--default-shell` を渡す前に作ったセッション」。`zellij delete-session --force <名>` で作り直す（`wezterm-zellij-nvim.md` のつまずきの表と同じ）。
- 新しい設定を足す案（`Run "pwsh" …`）は、WSL の bash と書き分けられず、設定が 2 本に割れるので採らない。

### 2. 開始時のディレクトリ（pwsh7 の既定、bash は `~`）

今は、新しい pane はフォーカス中の pane のディレクトリで開く（claude の pane なら、プロジェクトのディレクトリ）。「pwsh7 の既定（通常はホーム）、bash は `~`」にするには、次のどちらか。

- **案 A（推奨）: 変えない。** プロジェクトのディレクトリで開くほうが、続きの作業に便利なことが多い。ホームが要るときは `cd ~`。
- **案 B: `default_cwd` を試す。** トップ階層に 1 行。

```kdl
default_cwd "~"
```

  - 版: `default_cwd` は zellij の設定項目（公式 options）。**`~` が展開されるかは未確認**（Z2）。展開されなければ案 A に戻す。絶対パスは書かない。
  - 注意: 以前、CLI の `--default-cwd` は swap layout を崩した（2026-11-19 実機）。設定ファイルの `default_cwd` でも同じかを Z2 で確かめる。崩れたら案 A。

### 4. スクロール（キーボードで可）

**現行**: スクロールバーは zellij に無い。キーボードでは、`Ctrl g`（解除）→ `Ctrl s`（スクロールモード）で、`j/k`、`PageUp/PageDown`、`d/u`、`Ctrl c`（最下部へ）。スクロール中は pane の枠に `SCROLL: 位置/全体` が出る（zellij のソースで確認。`titles` の枠でも出るかは Z3）。

足りなければ、1 キーで動かす bind を 1 組だけ足す（locked のままで効く。`shared { }` の中）。

```kdl
bind "Alt PageUp" { PageScrollUp; }
bind "Alt PageDown" { PageScrollDown; }
```

「今のままで足りる」なら omit。まず Z3 で試す。

### 5. nvim の pane を作るショートカット

**結論: omit（作らない）。** 用途は「誤って消した pane の復元」で、`Alt+n` で pwsh7（bash）を開いて `nvim` と打てば足りる。キーを増やすと、claude や nvim 側のキーとの衝突の確認が要る。

## nvim

### 6・7. `<leader>e` のファイラを右から出し、幅を今の 2/3 に

位置と幅だけの変更。常時表示にはしない（`<leader>e` で開閉する今の動き）。`home/.config/nvim/lua/plugins/explorer.lua` を足す。

```lua
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              position = "right",
              width = 27, -- 今の 40 の 2/3
              min_width = 27, -- 既定の min_width 40 が残ると 40 のまま
            },
          },
        },
      },
    },
  },
}
```

- `position = "right"` は snacks の公式の説明にある書き方（explorer の項）。
- 40 → 27 は snacks の既定値（40）から計算した。実際の幅は N1 で見る。

### 8. 軽い Markdown ビューア

render-markdown.nvim は、2026-11-20 時点でも LazyVim の `lang.markdown` extra が採用している（LazyVim の main で確認）。更新が止まったプラグインを標準で採用し続けることは考えにくいので、**活動中と判断した**。ただし、最終コミットの日付は取れなかった（GitHub API が使えない）。PC で `:Lazy` の画面（`render-markdown.nvim` の最終更新）か、GitHub の Releases で確かめる（N4）。

| 案 | 内容 | 長所 | 短所 |
|---|---|---|---|
| A. render-markdown.nvim のみ | バッファ内で見出し・表・コードを装飾。normal で装飾、insert で元の文字 | 開いた瞬間に「見る形」。同じバッファで編集できる。`ft = "markdown"` で、.md を開くときだけ読み込む | プラグインが 1 つ増える |
| B. 組み込みの conceal + 読み取り専用 | プラグインなし | 最軽量 | 見出し・表の装飾が無い |
| C. glow を別 pane で | 外部コマンド | nvim に何も足さない | 別 pane、別の道具、追従なし |
| D. LazyVim の `lang.markdown` extra | A + ブラウザのプレビュー + LSP + linter | 一式 | 重い。「軽い」に反する |

**推奨: A を単体で再導入する**（`colorscheme.lua` に `RenderMarkdown*` の色の設定が残っているので、見た目は前に近い）。

```lua
-- home/.config/nvim/lua/plugins/markdown.lua
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  opts = {
    code = { sign = false, width = "block" },
    heading = { sign = false },
  },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle Markdown render" },
  },
}
```

- 「開いたらすぐ view」は、normal モードがそのまま装飾表示になることで満たす（編集は `i` で生の文字になる）。
- 重い・合わなければ、このファイル 1 つを消せば元に戻る（omit しやすい）。
- 読み取り専用にしたい場合のみ、`FileType markdown` で `vim.bo.readonly = true` を足す案がある（任意。誤編集の防止）。

## 実機で確かめること

| # | 項目 | 合格の目安 |
|---|---|---|
| Z1 | `Alt+n` と `Alt+f` のシェル | Windows: `(Get-Process -Id $PID).Path` が scoop の pwsh7、`$PSVersionTable.PSVersion` が 7.x。WSL: `echo $SHELL` が bash |
| Z2 | （案 B のみ）`default_cwd "~"` | 新しい pane が `~` で開く。swap layout（`Alt c` を足したときの 3 列）が崩れない |
| Z3 | スクロール | `Ctrl g` → `Ctrl s` で動く。枠に `SCROLL:` が出る。（bind を足したとき）`Alt PageUp` が locked のまま効く |
| N1 | `<leader>e` | 右から幅 27 で開く。`<leader>e` でもう一度押すと閉じる |
| N2 | .md を開く | 装飾表示になり、`i` で生の文字に戻る。開く速さに差が出ない（`nvim --startuptime`） |
| N3 | claude が .md を書き換えた後 | 2 秒以内の取り込み後も装飾が崩れない |
| N4 | render-markdown の更新状況 | `:Lazy` で最終更新が最近か |

## 出典

- zellij 0.46.0 の既定 preset と設定: GitHub の `zellij-org/zellij`（タグ v0.46.0）。`default_cwd`・`Run` は zellij.dev の docs。枠の `SCROLL:` 表示は `zellij-server/src/ui/pane_boundaries_frame.rs`
- Snacks explorer の設定、LazyVim の既定ファイラ: `folke/snacks.nvim` の `docs/picker.md`、`LazyVim/LazyVim` の `config/init.lua`
- render-markdown.nvim: 同プラグインの README、LazyVim の `extras/lang/markdown.lua`
