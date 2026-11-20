---
type: design
title: Windows と room の認証つき claude 起動を揃える設計（比較）
tags:
  - wezterm
  - claude
  - room
  - auth
  - design
---

# Windows と room の認証つき claude 起動を揃える設計（比較）

2026-11-20 起草。**まだ何も決めていない。** 現状の構成を維持する選択肢も含めて比べ、実機で確かめる項目（8 章）を並べる。実装は含まない。

## 1. ねらいと範囲

- ねらい: Windows 側で動く認証は room でも動き、動かないときは**同じ手順で切り分けられる**こと。使う人が Windows か room かを意識しないこと。
- 範囲: 認証の選び方と、`claude` を起動する部分（wezterm の `Ctrl+Shift+T` → 起動）。
- 範囲外: zellij の使いこなし（3 番目の課題）。起動の遅さ（1 番目の課題）は、各案の影響だけ 7 章に書き、手を付けるのは最後。
- 依存の向き: dotfiles → workbase の一方向を保つ（`room.py` は workbase。dotfiles の挙動を書かない）。

## 2. 現状（コードから読んだこと）

2026-11-20 時点の `windows/wezterm/wezterm.lua`、`windows/wezterm/room-profiles.json`、`windows/powershell/profile.ps1`、workbase の `workflow-kit/room/room.py` を読んだ。実機での動作は 8 章で確かめる。

### 2.1 認証ごとの起動の経路

| 認証 | Windows（pwsh の関数） | room（wezterm → `room start`） | 揃っているか |
|---|---|---|---|
| gateway | `claude-gateway`: `CLAUDE_CONFIG_DIR=~/.claude-gateway`、DPAPI のトークン、`apiKeyHelper` | `room start <p> --gateway`: 同名のディレクトリ。トークンは Windows から約 50 分ごとに部屋へ押す。`apiKeyHelper` は `cat` | 構造は並行。引数に特殊な文字が無い |
| bedrock | `claude-bedrock`: `claude --settings ~/.claude/settings-bedrock.json`（PC ごとに `claude-bedrock-setup` が生成。追跡しない） | `--cmd 'claude --settings $(echo <base64> \| base64 -d)'`（env は git 追跡の `room-profiles.json`）。AWS の資格は `room aws-key` | **揃っていない**（設定の出所が 2 つ。JSON を引数で運ぶ） |
| oauth | `claude-oauth`: 環境変数を一時的に外して `claude` | 環境なしの `room start`。ログインは部屋の `~/.claude` に別に持つ | 揃わない（ログインが別々に保存される） |
| api | `claude-api`: `settings-api.json`、DPAPI の `apiKeyHelper` | 未対応（NA 16。部屋に DPAPI が無い） | 対象外 |

読み取れること:

- **壊れているのは bedrock だけ**に見える（gateway は構造が並行で、引数に引用符が要らない）。
- **bedrock だけ、JSON を起動の引数で運ぶ**。この 1 点が、Windows（ファイルを指す）と room（引数に埋め込む）の違いで、デバッグを難しくしている。

### 2.2 見つけたこと（要確認）

- wezterm の `win:` 行（zellij の中）は、認証を選ばない。`home/.config/zellij/layouts/claude-b.kdl` の `pane command="claude"` と、`config.kdl` の `Alt+c`（`Run "claude"`）は、素の `claude` を起動する。つまり**認証を選ぶ 2 段目があるのは `room: <project>` の行だけ**で、Windows の `claude-pick` は、タブの中で人が打つ関数として使われているように読める。ee の言う「二段設計」が room 行だけを指すのか、`win:` にも広げたいのかで、設計の範囲が変わる（9 章の Q1）。
- `room: <project>` の行は zellij を使わない（NA 15 の決定）。つまり room で認証を選ぶ経路と、zellij の上の claude の経路は、今は別。

### 2.3 引数がくぐる層（bedrock の room 行）

Lua の文字列 → pwsh の `-Command`（パース 1）→ Windows のコマンドライン → `uv` → `room.py` の argparse → `room.py` が `cd <マウント先> && <cmd>` と**クォートなしで連結** → `wsl.exe` の引数 → 部屋の外側のシェル → `bash -ic`。`room.py` 自身のコメント（`push_shared` の付近）に、`wsl.exe` は引数を部屋の外側のシェルでもう一度解釈する、とある。JSON を引数に埋め込むと、**少なくとも 4〜5 回の引用符の解釈**を通る。

## 3. 症状の見立て（仮説。8 章の V2 で切り分ける）

最後に出たエラーは「`--settings` の JSON が不正」。`base64_encode`（Lua の自前実装）は、Python に移して `room-profiles.json` の env で検算し、標準の base64 と**一致した**。したがって符号化の側ではない見込み。残る候補:

| 仮説 | 説明 | そうなら見える症状 |
|---|---|---|
| H1 | `$(echo … \| base64 -d)` が展開されない | claude に `$(echo …` がそのまま渡る。多くは「ファイルが無い」系で、「不正な JSON」とは出ない見込み（`--settings` がパスと JSON をどう見分けるかは未確認） |
| H2 | 展開はされるが、途中のシェルが引用符を落とす | `{env:{CLAUDE_CODE_USE_BEDROCK:1,…}}` のような、引用符のない JSON。**報告された症状に合う** |
| H3 | 部屋に `base64` が無い、または `bash -ic` の初期化の出力が混ざる | 復元した文字列が壊れる |

H1 だけは、ee の見立て（展開が起きない）と、私の読み（「不正な JSON」と出たなら展開は起きている）が食い違う。V2 で決着する。**どれであっても、JSON を引数に載せる限り、引用符の層が増えるたびに再発する**（案 A の弱点）。

## 4. 案

### 案 A: 現状を維持する（引用符だけ直す）

- 内容: 構成はそのまま。V2 で壊れ方が分かれば、`--cmd` の組み立て（引用符・展開の位置）だけを直す。
- 良い点: 変更が最小。workbase に触れない。
- 悪い点: Windows と room の差（2.1 の bedrock の行）が残る。引用符の層が多く、次の認証を足すたびに同じ種類の不具合が出うる。部屋の側で何が渡ったかを、手で再現しにくい。

### 案 B: 設定ファイル方式（JSON を引数で運ばず、ファイルを指す）

- 内容:
  1. 認証の定義の正本は `room-profiles.json` 1 つ（秘密なし。今のまま）。
  2. dotfiles の小さなスクリプト（`windows/room/` に、`room-nvim-config.ps1` と同じ型）が、各認証の `env` だけの JSON を、部屋の `~/.claude-profiles/<id>.json` に、標準入力（`wsl.exe … sh -s`）で書く。引数に載せないので、引用符の層を通らない。
  3. 起動は `--cmd 'claude --settings $HOME/.claude-profiles/bedrock.json'`。使う文字は英数字と `/ . $ -` だけにして、どの層でも解釈が変わらないようにする。**`claude` で始まるので、`room start` の `--add-dir` の処理（`cmd` の先頭が `claude` のときだけ効く）も保たれる。**
  4. gateway と同じ型（ファイル + 起動の引数は単純）になり、Windows の `--settings <ファイル>` とも同じ形になる。
- 良い点: 引用符の問題が構造ごと無くなる。`room.py`（workbase）は変えない。部屋の中で `claude --settings ~/.claude-profiles/bedrock.json` と**手で打って再現できる**（デバッグの入口が Windows と同じ「コマンド 1 行」になる）。変更は dotfiles だけ（スクリプト 1、`wezterm.lua` の数行、`README`）。
- 悪い点: 部屋にファイルを置く手順が 1 回増える（`room-profiles.json` を変えたら再実行。ファイルが古いことの検出が要る）。Windows 側の `settings-bedrock.json`（PC ごとに生成）と `room-profiles.json` の bedrock が、**別々の正本のまま**（モデル ID などのずれを一致検査で見張る必要がある。NA 30 の記録にも同じ指摘がある）。
- 起動の時間: 変わらない（起動時の処理は増えない。`echo | base64 -d` の数ミリ秒が減る程度）。

### 案 C: 単一のランチャー（wezterm は識別子だけ渡す）

- 内容: `claude-launch`（uv の Python スクリプトなど。dotfiles に置き、`~/.local/bin` にリンク）を 1 つ作る。wezterm は `claude-launch <認証> --room <project>` / `--win <cwd>` のように**識別子だけ**を渡す。引用符・環境変数の退避・`room start` の組み立ては、ランチャーが 1 か所で持つ。Windows の `claude-pick` も、このランチャーを呼ぶ薄い関数にする。`--dry-run` で、組み立てたコマンドを表示できる。
- 良い点: 入口が本当に 1 つ。引用符の処理が 1 か所。`win:` の zellij 経路にも同じ入口で認証選択を足せる。
- 悪い点: 変更が大きい。今 Windows で動いている pwsh の関数（`profile.ps1`、`tests/windows/test_claude_launchers.ps1`、Zed の起動用 `claude-acp-*.cmd`）と**二重になる**か、置き換えの試験が要る。起動に Python（uv）の 1 プロセス分が増える（未測定）。room の `--cmd` が単純でないなら、結局案 B の部屋側のファイルも要る（C は B の上に乗る）。
- 起動の時間: プロセスが 1 つ増える。pwsh を `-NoProfile` で起動するなどで相殺できるかは、V10 で測る。

### 案 D: 部屋の bash に、同名の関数（`claude-pick` など）を作る

- 内容: 部屋の `.bashrc` に `claude-bedrock` `claude-oauth` `claude-gateway` `claude-pick` を、Windows と同じ名前・同じ挙動で作る。
- 良い点: 部屋の中でも同じ名前を打てる。
- 悪い点: pwsh と bash の**二重実装**で、ずれる。`--cmd 'claude-bedrock'` にすると、`room.py` の `--add-dir` の処理（先頭が `claude` のときだけ）が効かなくなり、workbase の変更が要る。B の設定ファイルの上に載せる**見た目だけの糖衣**としてなら成り立つが、単独では勧めない。

## 5. 比較

| 観点 | A 現状維持 | B 設定ファイル | C 単一ランチャー | D bash 関数 |
|---|---|---|---|---|
| Windows と room の対称性 | 低い | 高い（どちらも「ファイルを指す」） | 最も高い | 見た目は高い。中身は二重 |
| 引用符の再発 | 残る | 構造上ほぼ無い | 1 か所に集約 | 残る（関数の中） |
| 部屋で手で再現できるか | できない（展開を手で組む） | **できる（1 行）** | `--dry-run` で表示 | できる |
| デバッグの入口 | 弱い | 強い | 強い | 中 |
| 変更の範囲 | 数行 | dotfiles のみ（約 4 ファイル） | dotfiles 大（Windows の既存と二重化） | dotfiles + workbase |
| `room.py`（workbase）の変更 | なし | **なし** | なし（B を前提にすれば） | 要る |
| 起動時間への影響 | なし | なし | プロセス +1（未測定） | なし |
| 既存の動く経路を壊すリスク | 低い | 低い（Windows は触らない） | 中〜高 | 低い |
| 戻しやすさ | 容易 | 容易（ファイルを消すだけ） | 難しい | 容易 |

## 6. 推奨（暫定。V1〜V5 の結果で見直す）

**案 B を最初にやる。** 理由は 3 つ。(1) 壊れているのが bedrock だけで、その原因が「JSON を引数で運ぶ」構造にある（gateway は並行して動く形で、ファイルを指す）。(2) workbase を変えずに、dotfiles だけで直せる。(3) 部屋で手で再現できる入口ができ、「片方が動けば片方が動く」の確認が、同じ 1 行のコマンドの比較になる。

- 案 A は、V2 で原因が引用符の 1 か所の欠陥と分かり、直せば NA 17 を通せるなら、**当面の応急としては成り立つ**。ただし対称性は得られないので、案 B への移行は続けて検討する。
- 案 C は、案 B を実機で通したあとに、**「`win:` の zellij 経路にも認証選択を入れる」と決めたとき**（Q1）に再評価する。その時点で、Windows の関数との二重化の費用を見積もる。
- 案 D は、必要になったら案 B の上に足す糖衣として扱う。

案 B の後も残る非対称（設計で消せないので、**手順書に明記して揃える**）:

| 非対称 | 理由 |
|---|---|
| oauth のログイン | 部屋は Windows の資格を読めない（`/mnt/c` なし、interop 切り）。部屋で 1 回 `/login` が要る |
| bedrock の AWS 資格 | 部屋に AWS CLI が無く、`room aws-key`（`~/.aws/credentials`）。Windows が SSO のとき、方式が違う。プロファイル名を両側でそろえる |
| gateway のトークン | リフレッシュトークンは Windows の DPAPI に残り、部屋には約 1 時間で切れる ID トークンだけを押す |
| api | 部屋にキーを安全に渡す経路が無い（NA 16） |

## 7. 起動の遅さ（課題 1）への影響と、最後にやる測定

- 案 A・B・D は、起動時間を変えない。案 C は、プロセスが 1 つ増える（未測定）。**認証の統一は、速さの改善にはならない**（遅くもならない）。
- 60 秒の内訳は、まだ測っていない。**候補**（測定するまで確定しない）:
  1. pwsh の起動。`log-history.md` に、pwsh 本体が約 2.2 秒、プロファイルが約 1.5 秒という過去の記録がある（Windows Terminal のタブ。wezterm の room タブも同じ pwsh を使う）。`room: <p>` のタブは `uv run` を 1 つ走らせるだけなので、`-NoProfile` にできる可能性がある。
  2. `room start` の直列の処理: 共有知の tar の送付、信頼の記録、Area の写し、`drvfs` のマウント、`gateway_check`（Windows の `claude-gateway-token` を呼ぶ。pwsh 起動とネットワークを含みうる）。
  3. WSL のディストリビューションの cold start（`wsl --terminate` 後の最初の起動）。
  4. `uv run --script` の起動（2 回目以降はキャッシュ）。
  5. zellij の 2 段起動（約 1 秒。実測済みで `docs/setup/terminal-units.md` 7 章）。
- 「zellij の welcome まで 60 秒」の経路は、`win:` の行か、`room:` の行（`room start`）かで内訳が違う。どちらで 60 秒だったかを Q3 で聞く。

## 8. 実機で確認する項目

結果は、この表の右に日付つきで書き足す。**「どこで」は、ee の実機（pc2 は Bedrock・gateway なし → OAuth だけ試せる）**。値（プロファイル名、モデル ID、URL）は書かず、「ある・ない」と形だけを書く。room の試験用の Project は、`myinv*` か `mydev*` の名前にする（ダミー。コミットを汚さない）。

### 8.1 切り分け（今の bedrock が壊れる理由。コードは変えない）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V1 | 部屋で `claude` と `base64` に届く | `wsl -d room-<Area> -u ai -- bash -ic "command -v claude base64"` | 両方のパスが出る。出なければ H3 |
| V2 | 引数が部屋に届くまでに何が起きるか（H1〜H3） | (a) 失敗するタブの「起動: …」の行（`room.py` が表示する、展開前の `cmd`）を控える。(b) pwsh から `wsl -d room-<Area> -u ai -- bash -ic "printf '%s\n' \$(echo <base64> \| base64 -d)"` を実行（`<base64>` は (a) の値）。(c) 同じ行を `cmd.exe` から実行し、結果を比べる | (b) が引用符つきの JSON なら、展開は正常（H1・H3 は否定）。引用符が落ちたら H2。`$(echo` がそのまま出たら H1 |
| V3 | 案 B の動作そのもの（コードを変えずに、手で） | 部屋で `~/.claude-profiles/` に、env だけの JSON を手で置き、`claude --settings $HOME/.claude-profiles/bedrock.json` を打つ。`~/.aws/credentials` に、同名のプロファイルの節があるか（節の名前だけ）も見る | `/status` が Bedrock・リージョン・モデルを示す。通れば案 B は成立。通らなければ、原因は引用符でなく AWS の資格・env の内容 |
| V4 | gateway のベースライン（NA 17 の(2)） | `room: <project>` → `Claude Gateway (room)` | claude が起動し、`/status` がゲートウェイ。構造が並行な認証が動くことの確認（案 B の前提） |
| V5 | oauth の部屋の既定（NA 17 の(5)） | `Claude OAuth (room)` で起動し `/status`。部屋の `~/.claude/settings.json` のキーの**名前だけ**を見る（`python3 -c "import json;print(list(json.load(open('/home/ai/.claude/settings.json'))))"`）。`/login` 後に終了して起動し直し、ログインが残るか | `apiKeyHelper` や `env` が既定に入っていない。ログインが残る |

### 8.2 Windows 側の基準（比べる相手）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V6 | Windows の 3 つが今、期待どおりか | pwsh で `claude-pick oauth` / `bedrock` / `gateway` を順に起動し、各 `/status` の認証・プロバイダ・リージョン・モデルを表にして控える | これが 8.3 の「揃っているか」の基準になる |

### 8.3 対称性（案 B を実装したあと）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V7 | 同じ認証で、Windows と room の `/status` が揃う | oauth・bedrock・gateway のそれぞれで、V6 の表と room の `/status` を並べる。モデル ID は `room-profiles.json` と Windows の `settings-bedrock.json` の env を比べる | 非対称（6 章の表）以外が一致。モデル ID がずれていたら、どちらを正にするかを Q2 で決める |
| V8 | 後始末（NA 17 の(2)(3)） | claude の終了でタブの `room start` が終わりアンマウントされるか。強制終了後に `room umount` で残骸を拾えるか | 両方できる |
| V9 | `win:` の zellij の中の claude の認証 | `win:` のタブで `/status`。`Alt+c` で足した claude も見る。`ANTHROPIC_*` や `CLAUDE_CODE_USE_*` が環境に残っていないかも（名前と長さだけ） | 認証が環境の残りで決まっていないか。Q1 の判断材料 |

### 8.4 起動の遅さ（最後にやる）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V10 | 区間ごとの時間 | (a) `Measure-Command { pwsh -NoLogo -Command exit }` と `-NoProfile` つきの差。(b) `uv run --script $env:WFKIT_DIR\room\room.py start <myinv の Project> --no-launch` の出力に、行ごとの時刻を付けて段ごとの時間を見る（`… \| ForEach-Object { "{0:HH:mm:ss.fff} {1}" -f (Get-Date), $_ }`）。(c) `wsl --terminate room-<Area>` の直後と、動いている状態の `room start` の差（cold と warm）。(d) `win:` の行は、タブを開いてから zellij の画面が出るまでを、手元の時計かスクリーン録画で | 7 章の候補 1〜5 のどれが大きいか。60 秒が出る条件（どの行、cold か warm か、gateway か）も控える |

## 9. 決めてほしいこと

| # | 質問 | 影響 |
|---|---|---|
| Q1 | 認証を選ぶ 2 段目は、`room:` の行だけか。`win:` の zellij の経路（今は素の `claude`）にも入れたいか | 入れるなら、案 C（単一の入口）の価値が上がる |
| Q2 | Bedrock の値（プロファイル名・リージョン・モデル ID）の正本は、`room-profiles.json`（git 追跡、秘密なし）でよいか。Windows の `settings-bedrock.json` は、そこに合わせる（検査だけ／生成する）か | 二重管理の扱い。NA 30 の記録と同じ論点 |
| Q3 | 60 秒かかったのは、どの行か（`win:` か `room:`）、どの認証か、WSL が止まっていたときか | 7 章の候補のどこから測るか |
| Q4 | API 認証（NA 16）を、この設計に含めるか。含めるなら、部屋へのキーの経路（引数か、`room.py` の新しい引数か） | 案 B の表に 1 行増える。`room.py`（workbase）の変更が要る可能性 |

## 10. 決めたあとの流れ（案 B を選んだ場合の素描）

1. V2・V3 で原因と案 B の成立を確かめる。
2. 部屋にプロファイルを置くスクリプトを足す（`windows/room/`）。`wezterm.lua` の `--cmd` を、ファイルを指す単純な文字列にする。base64 の関数は不要になるので消す。
3. `room-profiles.json` と Windows の `settings-bedrock.json` の env の一致検査を、`tests/` に足す（秘密は読まない。キーの名前と、秘密でない値の一致だけ）。
4. V7・V8 を確認し、`docs/setup/wezterm-zellij-nvim.md` の「未確認」を更新、`docs/decisions.md` に決定を書く。
5. 起動の遅さ（V10）に進む。

## 出典

- `windows/wezterm/wezterm.lua`（`open_room`、`open_target`）、`windows/wezterm/room-profiles.json`、`windows/powershell/profile.ps1`（`claude-pick` ほか）、`windows/claude/README.md`、`home/.config/zellij/`。
- workbase の `workflow-kit/room/room.py`（`cmd_start`、`claude_extra_args`、`GATEWAY_CMD_PREFIX`）と `workflow-kit/room/README.md`。
- `docs/decisions.md` の NA 15 の項、`docs/setup/terminal-units.md` の 7 章、`docs/setup/wezterm-zellij-nvim.md`。
