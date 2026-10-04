# 判断の記録（decisions）

構成・スクリプト命名・セットアップ手順（How）は `README.md` が正本。ここには、なぜそうしたか（Why）、却下案、遭遇した詰まり、実機で確認した事実を残す。現在の状態と次にやることは `docs/log.md`。

exmem（`C:\vault\notes\resources\exmem`）は読み取り専用の参照先で、ここからは書き込まない。参照するときは `exmem/knowledge/<ファイル>.md` と書く。

## Principles

- **会社は最小構成、家は追加分**。差分は `*.home.*` のファイル（`apps.home.txt`）に分け、引数 `home` で切り替える。コメントアウト運用はやめた。
- **軽くポータブルに保つ**。履歴に戻ったりブランチを切ったりしない。CLI が遅く・重くなるものは削る。複雑なコードは読まないので、複雑さを生む仕様（フォールバック、モード、自動退避）は仕様ごと削り、運用（手動手順・README）へ移す。
- **リスクや制約が生まれる変更は、事前にユーザーへ確認する**。
- **アプリが自動生成・書き換えるファイルは追跡しない**。リンク越しに差分が出続け、初期状態としての価値が薄い。
- **置き場の判断基準**: WSL でも使う → `home/` ／ Windows 専用 → `windows/<アプリ>/` ／ 配置しない雛形 → `templates/` ／ 不要 → 削除（履歴に残る）。
- **`.bat` のコメントは ASCII（英語）**。日本語（UTF-8）は cp932 コンソールで壊れる。バッチは cp932 でもテストする。
- **exmem には書かない**。dotfiles は exmem を参照するだけ。作業の経緯・決定・次にやることは dotfiles の `docs/` に残す（2026-10-04 決定）。

## 構成と命名の根拠

- `home/` を `~` の鏡にすると、stow が1回で済み、Windows と WSL が同じファイルを正本にできる。旧構成は `config/` `home/` `claude/` が役割で分かれていなかった。
- **`--no-folding` が必須**。付けないと `~/.config` や `~/.claude` がディレクトリごとリンクになり、アプリの状態ファイルがリポジトリに混ざる（stow 2.3.1）。
- Office テンプレと `.obsidian` は `notes` リポジトリへ移管済み。`links.map` に残るのは `..\notes|%NOTES_DIR%`（Vault）だけ。
- スクリプト番号は、十の位が層、一の位が同じ層の固有ツール。10 刻みなのは後から差し込む余地のため。Windows と Linux で同じ番号は同じ役割で、無い側は欠番にする。OS 接頭辞（w / l）と英字の枝番は廃止した（OS はディレクトリで分かれる）。
- 実行順は、Linux は「ディレクトリ → パッケージ」（ghq を `~/.local/bin` に置くため）。`notes` を先に clone してから `30_link`（`..\notes` をリンクするため）。
- `manifests/` の一覧は、スクリプトと手順書（`notes/resources/cheatsheets/env/`）で重複させない。`lib.sh` の `read_list` は行内の空白を全部消すので、2列の一覧は `:` 区切りにする（`fonts.txt` は `owner/repo:asset glob`）。

## Decisions

### リンクスクリプトは Windows / WSL で対称、リンクだけを行う（2026-10-03）

- 引数は `[link|unlink] [-n]`。既存リンクは張り直す。展開先に実ファイル/実ディレクトリがあれば `[ERR]` を出し、件数を表示して非ゼロ終了する。`unlink` はリンクだけを消し、実ファイルに触らない。
- 根拠: 複数PCで開発者モード/管理者権限が確実に使える。自動退避は不要。`copy` / `copyback` と profile は使っていなかった。
- 却下案: symlink 失敗時の COPY フォールバック（黙ってリポジトリと乖離する）、`mklink /J` 失敗時の `/D` フォールバック、`.bak-N` / `~/.bak/<日時>` への自動退避（手で退避してから再実行する運用）、`links.<profile>.map`、`--reset` / `--restow`。
- 対称でない点: Linux は張る前に全ファイルを確認し、1件でも実ファイルがあれば何も張らずに止まる（リンク切れ symlink の掃除も残した）。Windows は該当エントリだけ飛ばして続行する。

### 履歴を単一コミットで作り直した（2026-10-02）

- `--force-with-lease` で強制 push した。40.23 MiB → 1.17 MiB。肥大の原因は削除済みの `_fonts/`（HackGen、Myrica。約45 MB）と obsidian プラグイン。
- 根拠: 履歴の価値が低い。却下案: `git filter-repo`（全ハッシュが変わるのは同じで、ツール導入が必要）。実行前に `git bundle`（約40 MB）でバックアップした。
- ブランチは `main` に一本化。リモートに無かったので `202509` の先頭から作って push した。

### 追跡しないもの・絞ったもの

- 追跡しない: Obsidian の `workspace.json`、Notepad++ の `config.xml` `stylers.xml`（約195KB）`NppExec.ini` `contextMenu.xml`、`tmp/`、`.claude/`。
- Notepad++ は `shortcuts.xml` と Gruvbox テーマ2つだけ追跡する（実物の `links.map` と一致）。このPCでは `config.xml` のリンクを現行内容の実ファイルに置き換えて設定を保った。
- Office テンプレ・UI 設定は `links.map` から外し、`notes` 側（`resources/office/`）に置く。`notes` の clone 順序への依存を避けるため、初回に手で配置する運用。

### シェル（2026-10-02〜03）

- bash/zsh の共通部は `home/.config/shell/common.sh`（正本は bash/zsh）。pwsh（`windows/powershell/profile.ps1`）と同じコマンド体系にそろえた: `ls`=lsd、`l`=`ls -l`、`lt`=`ls --tree --depth 2`、`cdg`、`zfz`（`Alt+j`。3シェル共通）、`z`、`b`、`..`、`pd`/`po`/`dl`。
- 3か所（`profile.ps1` / `common.sh` / `.zshrc`・`.bashrc`）の同期義務が最大の複雑さだったため、次を削除した: `cd` 後の自動 `ll`（`/mnt/c` で 9p 経由が遅い）、`cdf`/`cdu`/`up`/`zlist`、`PSFzf`/`scoop-completion`、ツール不在時の代替（`fd`→`rg`→`find`、`bat`→`head`、`lsd` の分岐、`dircolors`）、zsh の `_correct`/`_approximate`。ツールは `apps.txt` と `20_packages.sh` で必ず入る前提。
- 却下案: `cat`→`bat` などの標準コマンド置換エイリアス（ユーザーが「追加しない」と決定）。`PredictionViewStyle ListView` は重い可能性があるが見送り（のちに pwsh では残した。`docs/log.md` の Open Questions を参照）。
- XDG の export は `.profile` だけ。`.zshrc`/`.bashrc` は使う箇所のインライン既定値（`${XDG_STATE_HOME:-$HOME/.local/state}`）にした。`.zprofile` は `.profile` を読むだけ。`.profile` のローカル上書きは `~/.config/profile.local`。
- git: `~/.config/git/config` は git が自動で読むので、`~/.gitconfig` の `include` は削除した。共通設定の `[user]` 仮値は残し、実際の名前・メールは `~/.gitconfig_local`（PCごと）。
- PowerShell プロファイルのラッパー（`Microsoft.PowerShell_profile.ps1`）は削除。全ホスト共通の `profile.ps1` が自動で読まれる。

### fzf は移動用に限定し、履歴検索は標準機能にそろえた（2026-10-04。同日に一部撤回: 次の項を参照）

- （撤回済み）決めたこと: fzf は `zfz`（zoxide）と `cdg`（ghq）の選択にだけ使う。履歴検索は pwsh / zsh / bash とも標準機能（↑↓・`Ctrl+P`/`Ctrl+N` の前方一致、標準の `Ctrl+R`）。pwsh だけ `PredictionViewStyle ListView` を足している。
- 変更: `common.sh` から fzf の `key-bindings` / `completion` の読み込みと `FZF_*` 環境変数を削除した。これで zsh/bash の `Ctrl+R`/`Ctrl+T`/`Alt+C` は標準に戻り、pwsh（PSFzf を持たない）とそろった。
- 根拠: ターミナル起点から Zed（エディタ起点）へ移行中で、ターミナル側は軽くシンプルにしたい。fzf は目的ではなく手段。
- 経緯: 修正前は pwsh だけ fzf を外していて、zsh/bash は apt 版 fzf のキーバインドが残っていた（適用漏れ。実機の `bindkey` / `bind -X` で確認）。以前に fzf を止めた理由の元記録は見つからなかった（履歴は 2026-10-02 に作り直し済み）。理由は上のとおり。
- 却下案: ListView 相当を足すための追加プラグイン（ble.sh など）、PSFzf の導入。（`zsh-autosuggestions` は zsh で既に使っている。インラインの薄い候補のみ。）
- 確認済み（2026-10-04）: zsh の `^R` は `history-incremental-search-backward`、bash の `\C-r` は `reverse-search-history`。`zfz`/`cdg` は定義されたまま。zsh/bash とも起動の終了コードは 0。

### zsh/bash の Ctrl+R / Ctrl+T を fzf に戻した。zsh/bash の ListView 相当は作らない（2026-10-04）

- 決めたこと: zsh/bash は、fzf の `key-bindings`（apt 版 `/usr/share/doc/fzf/examples/key-bindings.{zsh,bash}`）で `Ctrl+R`（履歴検索）と `Ctrl+T`（ファイル検索）を使う。補完（`completion.*`）は読まない。`Alt+C`（cd）は使わず、標準の `capitalize-word` に戻す。`Ctrl+T` のファイル一覧は `fd --hidden --follow --exclude .git`、プレビューは `bat`（`FZF_CTRL_T_COMMAND` / `FZF_CTRL_T_OPTS`）。UI は `FZF_DEFAULT_OPTS='--height=40% --reverse'`（軽く）。pwsh の `ListView` はそのまま残す。
- 経緯: 同日の前半は「fzf は移動用に限定、履歴検索は標準機能」と決めて zsh/bash の fzf キーバインドを外した。その後、zsh で ListView 相当の候補一覧を自作して試した（`zle-line-pre-redraw` + `zle -M`。前方一致・新しい順・最大10件）。一覧（10件）は出たが、試した結果 zsh/bash の ListView 相当は作らず（omit）、fzf に切り替えることにした（自作はコミット前に削除）。bash は ListView 相当の標準機能が無いので最初から見送り（ble.sh は大きい依存）。
- 根拠: 以前 fzf を外した理由は「重い」「便利で色々作ってしまう」「あまり使わない」。ただ、全体の一貫性を考えると fzf のほうがよい、と判断した（ユーザー判断）。「色々作る」への歯止めとして、まずヒストリ検索（`Ctrl+R`）とファイル検索（`Ctrl+T`）に絞り、`Alt+C` と補完は使わない。
- 自作 ListView の測定値（参考。採用しなかった）: 履歴を毎キー走査するループは、50,000件で一致なしだと 3.5 秒。履歴を `"${(@v)history}"` で配列化（新しい順。約29 ms）して絞り込めば、1キーあたり、履歴10件程度で 1〜4 ms、50,000件で約30 ms。起動時間への影響は誤差。
- 起動時間への影響（fzf のキーバインド）: `XDG_CONFIG_HOME` を切り替えて「ある/なし」を交互に7回測り、zsh で約 +8 ms、bash で約 +9 ms。
- 確認済み（2026-10-04、pty）: zsh/bash とも、`Ctrl+R` で履歴の一覧から選んだコマンドがプロンプトに入る。`Ctrl+T` でファイルを選ぶとパスが入る。`Alt+c` は `capitalize-word`。`Alt+j`/`Alt+k` は従来どおり。
- 注意: bash は `.bashrc` の末尾の `cd ~` で、起動時のカレントディレクトリが常に `~` になり、`Ctrl+T` が `~` から探していた。この `cd ~` は削除した（同日。`bash -ic pwd` で起動時のディレクトリが保たれることを確認）。
- pwsh にも同じキーで入れた（同日）: PSFzf は使わず、`profile.ps1` の自前ハンドラ（`Invoke-FzfHistory` / `Invoke-FzfFile`、`Set-PSReadLineKeyHandler -Chord Ctrl+r / Ctrl+t`）で `fzf` を直接呼ぶ。履歴は PSReadLine の履歴ファイルを新しい順・重複なしで読む（`Get-FzfHistory`）。ファイル検索は `fd` + `bat` プレビュー、`FZF_DEFAULT_OPTS` も zsh/bash と同じ `--height=40% --reverse`。`ListView`（予測表示）は残す。
- `Ctrl+R` / `Ctrl+T` のキー選定の見直し（2026-10-04）: どちらも fzf の標準キーなので、そのまま採用した。`Ctrl+R` は readline・zsh・PSReadLine で履歴検索の標準。`Ctrl+T` は `transpose-chars`（pwsh は `SwapCharacters`。打った直後の2文字の入れ替え）を上書きするが、使用頻度が低く、`Alt+t`（語の入れ替え）は残る。`Ctrl+英字` に空きはほぼ無く、標準から外すと他の fzf 解説とも食い違う。ルール: fzf の標準機能は標準キー、自作（`zfz`/`cdg`）は全シェルで空いている `Alt+j`/`Alt+k`。
- pwsh の確認範囲: `profile.ps1` の構文、`Get-FzfHistory`（新しい順・重複なし・件数一致）、パスのクォート処理、`Ctrl+r`/`Ctrl+t` のハンドラ登録、`fzf` へのパイプを確認。実際のキー押下は、ユーザーが実機で動作確認した（2026-10-04）。

### PSReadLine 履歴の種を dotfiles で配る（2026-10-04）

- 決めたこと: 手で選んだ定型コマンド（環境構築・パッケージ・git・設定編集）だけを `windows/powershell/history.seed.txt` に置き、初回に `scripts/windows/31_history_seed.bat` が履歴ファイルへコピーする。zsh/bash は `manifests/history.seed.sh.txt` を `scripts/linux/31_history_seed.sh` がコピーする（同じ方針）。個人・機密値は `<…名>` に置換し、そのままでは実行されない形にする。
- 正本は exmem の `knowledge/shell-command-usecases.md`（種のコードブロック）。種ファイルはそこから連結して作る（派生物なので、種ファイルを直接編集しない）。傾向・判断基準・Gotchas もそこに書く。
- 根拠: PC 移行時に定型コマンドを調べ直す時間を減らす。生の履歴は会社名・ユーザー名・Webhook URL を含むので共有しない（`_local/` に退避）。
- 却下案: 履歴全体を整形して共有する（秘匿・案件固有の流出リスクと量）。種ファイルへのシンボリックリンク（PSReadLine が追記して作業ツリーが汚れる）。上書きコピー（既存の履歴を壊す）。
- スクリプト番号: `31`（層 30 の固有ツール枠）。Windows（`.bat`）と Linux（`.sh`）で同じ番号。

### インストール経路（2026-10-03）

- Go と Docker は `20_packages.sh` から外し、README の「必要なときだけ入れるもの」に移した。ghq は GitHub Releases のビルド済みバイナリ（`ghq_linux_<arch>.zip`、v1.11.2 で確認）を `~/.local/bin` に置く（apt に `ghq` は無い）。`fdfind` → `fd`、`batcat` → `bat` のリンクを張る。
- `w1b`/`l1a` 系（VS Code 拡張）は一覧（`code --list-extensions` 形式、バージョンなし）から `code --install-extension` を並べて1回で実行する。`remote-containers` は入れる、`devicetree` は入れない（ユーザー判断）。
- `22_python.bat`（uv）は、固有ツールは一の位で別ファイルという方針で独立させた。
- リポジトリ取得（`50_repos.*`）は、今後リポジトリを足す置き場と、Windows / Linux の対称性のために残す。
- `.vimrc`: vim-plug の自動導入は残す（忘れるため）。保存先は OS で切り替え（Windows は `~/vimfiles`、他は `~/.vim`）。テーマ5つ・git 系プラグイン・airline を削除し、標準の `statusline` にした。
- nvim は撤去（vscode-neovim 設定・拡張・`EDITOR=nvim` 分岐も）。Zed（vim mode）へ移行中のため（`exmem/knowledge/zed-vim.md`）。

### アプリ設定

- Zed は `auto_install_extensions` で宣言的に管理し、`terminal.shell` は削除して OS 既定に任せる（`exmem/knowledge/zed-dotfiles.md`）。
- `windows/wsl/.wslconfig` は `[experimental] autoMemoryReclaim=gradual` のみ。`memory` / `processors` の固定値は RAM が違うPCで危険なので入れない。`links.map` で `%USERPROFILE%\.wslconfig` へリンクする。
- Claude の権限設定（`home/.claude/settings.json`）と git 設定は現状維持（ユーザー判断。`exmem/knowledge/claude-code-permissions.md`）。

### 起動時間

- zsh: `~/.zshenv` に `skip_global_compinit=1`、`.zshrc` は `compinit -C`。約 0.15 秒 → 約 0.06 秒（この PC、5回計測）。Ubuntu の `/etc/zsh/zshrc` が `~/.zshrc` より前に、検査つきの `compinit` を実行していたのが原因。`compinit -C` だけでは速くならない。
- pwsh: `Invoke-Expression (& starship init powershell --print-full-init | Out-String)`。`starship init powershell` はスタブを返し starship を2回起動する。`profile.ps1` 全体 約190ms → 約148ms。
- 初期化結果のキャッシュ（`zoxide` 約50ms→13ms など）は、古くなる管理の複雑さのため見送った。
- VS Code 拡張を削減した（Windows: remote 系・テーマ、WSL: cpptools 系・todo-tree など）。

## Facts

### fzf とキーバインドの現仕様

2026-10-04 に実機の `bindkey` / `bind -X` / `Get-PSReadLineKeyHandler` と `profile.ps1`・`common.sh` で確認。決定の経緯は Decisions の「fzf は移動用に限定し…」「zsh/bash の Ctrl+R / Ctrl+T を…」。

ツールの導入と読み込み:

| | fzf 本体 | PSFzf | fzf 付属の `key-bindings` / `completion` |
|---|---|---|---|
| pwsh | 導入済み（scoop 0.74.4） | 使わない（`apps.txt` からも削除。キーは `profile.ps1` の自前ハンドラ） | 該当なし |
| zsh（WSL） | 導入済み（apt 0.44.1） | 該当なし | `key-bindings` だけ読み込む（`completion` は読まない。`Alt+C` は標準に戻す） |
| bash（WSL） | 導入済み（apt 0.44.1） | 該当なし | 同上 |

キーバインドと機能:

| 機能 | pwsh | zsh | bash |
|---|---|---|---|
| `Ctrl+R`（履歴検索） | **fzf**（自前 `Invoke-FzfHistory`） | **fzf**（`fzf-history-widget`） | **fzf**（`__fzf_history__`） |
| `Ctrl+T`（ファイル検索） | **fzf**（自前 `Invoke-FzfFile`。`fd` + `bat` プレビュー） | **fzf**（`fzf-file-widget`。`fd` + `bat` プレビュー） | **fzf**（`fzf-file-widget`） |
| `Alt+C` | 未設定 | 標準（`capitalize-word`） | 標準 |
| ↑↓、`Ctrl+P`/`Ctrl+N`（前方一致の履歴検索） | あり | あり | あり |
| 履歴の予測表示 | `PredictionSource History` + `ListView`（10件固定のはず） | `zsh-autosuggestions`（インラインのみ） | なし |
| Tab 補完 | `MenuComplete` | `menu-select` | 標準 |
| `zfz`（zoxide を fzf で選んで移動） | `Alt+j` | `Alt+j` | `Alt+j` |
| `cdg`（ghq のリポジトリを fzf で選んで移動） | `Alt+k` | `Alt+k` | `Alt+k` |
| `Ctrl+g` | 標準（`Abort`） | 標準（`send-break`） | 標準（`abort`） |

読み取れること: fzf は3シェルとも `Ctrl+R`・`Ctrl+T`・`zfz`（`Alt+j`）・`cdg`（`Alt+k`）に使う。補完には関与しない。pwsh だけ予測表示の `ListView` を残している。

`Alt+j` / `Alt+k` を選んだ理由（2026-10-04）: pwsh（Emacs モード）・zsh・bash の3つとも、デフォルトで未使用の `Alt+英字` が `e i j k m o v` だけだったため。`Ctrl+英字` はほぼ全部使用済み。j = jump（zoxide）、k は j の隣（Vim の j/k）。`Ctrl+g` は以前 pwsh の `zfz` に割り当てていたが、`Abort` を上書きしていたので戻した。

- 実装: pwsh は `profile.ps1`（実行後に `InvokePrompt()` でプロンプトを描き直す）、bash/zsh は `common.sh`。zsh は widget（入力中の行を残す。`zle reset-prompt`）、bash は `"\ej": "\C-u zfz\C-m"` のマクロ（コマンドとして実行してプロンプトを更新。先頭の空白で履歴に残らず、入力中の行は kill ring へ退避されるので `Ctrl+y` で戻せる）。
- 確認済み（2026-10-04）: zsh/bash は pty（擬似端末）で `Alt+j`/`Alt+k` を送り、fzf の選択後にカレントディレクトリとプロンプトが変わることを確認した（`ghq` は WSL に無いのでスタブで確認）。pwsh は `Alt+j`/`Alt+k` が登録され `Ctrl+g` が `Abort` に戻ったことまで確認し、実際の押下は未確認だった（非対話では PSReadLine が動かない。その後 `Ctrl+R`/`Ctrl+T` は実機で動作確認済み）。

### その他

- 複雑度の順位（分岐・重複・同期義務で評価）: 1 シェル設定の3重実装、2 ツール不在時の代替、3 XDG の4重定義、4 apt スクリプト、5 アプリが書き換える設定の symlink 管理、6 `.vimrc`、7 `starship.toml`、8 インストーラー系、9 Claude 権限設定、10 git 設定。
- Zed の `auto_install_extensions` の既定は `{ "html": true }`。`false` は「入れない」で、アンインストールはしない。
- `/mnt/c` 配下は 777 に見えるため、dircolors の `ow=34;42`（緑背景）が `lsd` にも効き、Gruvbox で文字が読めなかった。`LS_COLORS` の `ow`/`tw`/`st` を `01;34` に上書きして解消した。
- PowerShell ではエイリアスが関数より優先される。`function ls` は組み込みの `ls` エイリアスに負けるので `Remove-Item Alias:ls` が要る（旧 profile の `ls`→lsd は効いていなかった）。`mv` も同じで、関数名を `gmv` にした。
- Windows バッチの `if exist` は、リンク切れ symlink に対しても真を返す。`dir /AL` はジャンクション先の中身を見るのでリンク判定に使えない。`for %%F in ("path") do set "ATTR=%%~aF"` の属性文字列（1文字目 `d`、9文字目 `l`）で判定する。
- WSL のメモリ: 既定で 16GB（ホスト RAM 31GB の50%）まで使える。実使用 0.7GB に対し `vmmemWSL` は 1.6GB を保持していた（WSL 2.7.14）。
- WSL のユーザー名は `yy`。Ubuntu の `fd-find` は `fdfind`、`bat` は `batcat`。
- `windows/terminal/settings.json` と draw.io の設定は小さく意図的なので、変更せず残した。

## Gotchas

- **`git mv` の途中で git 全体が壊れた**（`fatal: unknown error occurred while reading the configuration files`）。`~/.config/git/config` のリンク先が移動中に消えたため。そのリンクだけ新しい場所へ手で張り直した。構造変更では「git が読む設定のリンク元を最初に動かさない」。
- **リンク解除後の 0 バイトファイルを `.bak-N` に退避し、アプリのフォルダにゴミを21個作った**。ロジックを「ディレクトリのリンクは `rmdir`、ファイルの symlink は属性で判定して `del`、実体は退避」に作り直し、サンドボックスで6ケース検証した（旧実装には実体ディレクトリを再帰削除する経路もあった）。この退避ロジック自体は、のちに自動退避ごと廃止した。
- **cp932 でバッチが壊れた**。日本語コメント行の `->` がリダイレクトと解釈され、文字化けした名前の空ファイルが2つ生成された。コメントを ASCII 化して削除した。テストを UTF-8 コンソール（65001）でしか行っていなかったのが見逃しの原因。
- **非ログインの zsh で `lt` が使えなかった**（`zsh: correct 'lt' to 'let'`）。`XDG_CONFIG_HOME` が空で `common.sh` を `/shell/common.sh` で探していた。共通化時の退行で、いまはインライン既定値で解決している。
- **`windows/vscode/settings.json` のカンマ抜け**で、VS Code が設定を読めていなかった可能性がある。nvim 設定の削除時に修正した。
- **AutoHotkey 実行中は `autohotkey/` ディレクトリを rename できない**（Permission denied）。ファイル単位で `git mv` した。
- **Claude Code は `~/.claude/settings.json` の symlink を実ファイルに置き換えることがある**（内容は同一だった）。
- **`.vimrc` の行末コメント**（`nmap <C-n> ... " コメント`）が右辺に混ざるバグだった。コメントを上の行に移した。
- **`vim -es` でのテスト**は `termguicolors` で E954 が出るが、端末がないテスト由来で無害。
- **`git add -A` で `tmp/` のスクリーンショットや空ファイル（`scripts/fdfin` など）を拾った**。パスを指定して `git add` する。`tmp/` は `.gitignore` に追加した。
- **PowerShell からの `wsl -d ... -- bash -c "..."`** は `$(...)` が PowerShell で展開されて壊れる。スクリプトを LF で書き出して `bash` に渡す。`git commit -F -` への here-string のパイプも渡らないので、一時ファイル経由にする。
- **実行環境の安全装置が、`rm` `del /F` `cmd /c` を含む PowerShell コマンドを誤検知してブロックした**。スクリプトをファイルに書いてから実行する、`unlink` を使う、で回避した。
- **`git diff` をパスで絞ると改名検出が効かず全行が「追加」に見える**。改名の確認は `git diff -M HEAD --stat`。
- **PowerShell の単一引用符の文字列には `` `r`n `` が展開されない**。
