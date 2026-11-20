---
type: design
title: 案 B（設定ファイル方式）の実装・確認計画（PC への持ち出し用）
tags:
  - wezterm
  - claude
  - room
  - auth
  - design
---

# 案 B（設定ファイル方式）の実装・確認計画

2026-11-20。`docs/design/auth-launch-unification.md`（比較の設計書。以下「比較書」）から、**案 B だけ**を抜き出した持ち出し用。経緯・他案・緩和案・三層レビューは比較書を見る（章番号は比較書のもの）。ee の方針: **今後は「現状維持（案 A）」か「案 B」で進める。** 個人的には案 B（ee、2026-11-20）。

## 1. 目的と受け入れ条件

- 目的: Windows で動く認証が room でも同じ形で動き、動かないときは同じ手順で切り分けられる。使う人が Windows か room かを意識しない。
- **must（受け入れ条件）: bedrock と oauth が Windows と room で揃っている。** gateway と api は、最終的に Windows だけでもよい（考え方だけ揃える）。
- 範囲外: zellij、起動の遅さ（最後）、案 C・D・E（E は 8 章）。
- 依存の向き: dotfiles → workbase の一方向。`room.py`（workbase）は変えない。

## 2. 今の問題（コードから読んだこと）

- room の bedrock だけ、**JSON を起動の引数で運ぶ**（`wezterm.lua` の `open_room`: `--cmd 'claude --settings $(echo <base64> | base64 -d)'`、env は `room-profiles.json`）。Windows は `claude --settings <ファイル>`（`profile.ps1` の `claude-bedrock`）で、ファイルを指す。ここが違う。
- 層が多い: Lua → pwsh → uv → `room.py`（クォートなしで `cd <マウント先> && <cmd>` と連結）→ `wsl.exe` → 部屋の外側のシェル → `bash -ic`。
- 最後のエラーは「`--settings` の JSON が不正」。**原因は未特定**（比較書 3 章。H1〜H5）。`base64_encode`（Lua の自前実装）は、Python に移して検算し、標準の base64 と一致した。
- 値の置き場が食い違う: `windows/claude/README.md` は、Bedrock のプロファイル名・リージョン・モデル ID を **PC 専用に生成し、リポジトリに置かない**と書く。一方、`room-profiles.json`（git 追跡）の bedrock にその種類の値がある。

## 3. 案 B の設計

### 3.1 3 点組（4 認証に共通の型）

| 点 | 内容 |
|---|---|
| ① 設定 | 秘密を含まない JSON（env だけ）。`claude --settings <ファイル>` で渡す。両環境で同名・同位置（`~/.claude/settings-<id>.json`）。oauth は設定ファイルなし |
| ② 資格 | その環境の `~` の下にある。**環境間で運ばない**（gateway の ID トークンだけは今も Windows から押す） |
| ③ 起動 | 常に `claude [--settings ①]`。環境の残りは、Windows では外す（oauth）。room は元々きれい |

### 3.2 must の 2 認証の中身

| 認証 | ① 設定 | ② 資格（各環境で別。種類は揃えない） | 起動（room） |
|---|---|---|---|
| oauth | なし | Windows: `~\.claude`、room: `~/.claude`。各環境で 1 回 `/login` | 環境なしの `room start <p>`（今のまま） |
| bedrock | `settings-bedrock.json`（env: `CLAUDE_CODE_USE_BEDROCK` `AWS_REGION` `AWS_PROFILE` とモデル） | Windows: `~\.aws`（SSO か IAM キー）、room: `~/.aws/credentials`（`room aws-key`。部屋に AWS CLI は無い）。**`AWS_PROFILE` の名前を両側でそろえる** | `room start <p> --cmd 'claude --settings $HOME/.claude/settings-bedrock.json'` |

gateway（`room start --gateway`）と api（room は未対応）は、今のまま触らない。

### 3.3 変更の内容（dotfiles だけ）

1. **値の正本を Windows の PC 専用ファイルにする（R3）。** `%USERPROFILE%\.claude\settings-bedrock.json`（`claude-bedrock-setup` が生成。リポジトリに置かない。秘密なし）。**`room-profiles.json` から bedrock の値（`env`）を外し**、認証の一覧（id・ラベル・タグ・設定ファイル名）だけにする。**これは `decisions.md` の NA 15 の決定の変更なので、ee の承認を得てから行う。**
2. **配布スクリプトを足す**（`windows/room/` に、`room-nvim-config.ps1` と同じ型。例: `room-claude-profiles.ps1 -Area <Area>`）。
   - 元（上のファイル）から **`env` だけ**を取り出す（`awsAuthRefresh` など、部屋の AWS CLI の無い環境で動かないキーは落とす）。
   - 部屋の `~/.claude/settings-bedrock.json` に、標準入力（`wsl.exe -d room-<Area> -u ai -- sh -s`）で書く。横で完成させてから `mv`（途中の状態を見せない）。引数に値を載せない。
   - **元が無い PC（家の PC など）では、何もせず「skip」と表示する。**
   - 書いた内容の SHA-256（先頭 8 桁）を表示する（値は出さない）。
3. **`wezterm.lua` の `open_room`**: `auth.env` の base64 の分岐と `base64_encode` を消し、`auth.settings` があれば `--cmd 'claude --settings $HOME/.claude/<設定ファイル名>'` にする。
   - `--cmd` に使う文字は **英数字と `/ . $ - _` だけ**にする（どの層でも解釈が変わらないように）。
   - **`claude` で始まる**こと（`room.py` の `--add-dir` の処理は、先頭が `claude` のときだけ効く）。
   - 元ファイルが無い PC では、その認証を選択肢に出さない（Lua で `io.open` の有無を見る）。
   - `load_auths` のフォールバック（`room-profiles.json` が読めないとき）も確認する。
4. **点検表のスクリプト**（例: `windows/claude/claude-auth-status.ps1`。Windows 側から `wsl.exe` で部屋も見る）。4 認証 × 両環境で、**名前と有無だけ**（値は出さない）:
   - 設定ファイルがあるか、元と部屋の写しの**内容が一致するか**（SHA-256 の比較。古さの検出）。
   - 資格の置き場があるか（`~/.aws/credentials` に `AWS_PROFILE` の名前の節があるか。節の名前だけ）。
   - 環境に認証の変数が残っていないか（`ANTHROPIC_*` `CLAUDE_CODE_USE_*` `AWS_*` の名前と長さだけ）。
5. **試験**（`tests/windows/` に追加。型は既存の `test_claude_*.ps1`）: 取り出しで `env` だけになること、元が無いとき skip、値が標準出力に出ないこと、`--cmd` の文字種。
6. **文書**: `docs/setup/wezterm-zellij-nvim.md`（room の認証の節、「未確認」）、`windows/claude/README.md`（部屋の節）、`tests/README.md`、`docs/decisions.md`（NA 15 の更新と、A か B かの決定）。

### 3.4 運用

- 元の値を変えたら、配布スクリプトを再実行する。部屋を作り直した（`room init`・`reset`）ときも再配布する。古さは点検表のハッシュで見つける。
- 手で再現できる 1 行（デバッグの入口）: 部屋の中で `claude --settings $HOME/.claude/settings-bedrock.json`。

### 3.5 残る非対称（設計で消せない。手順書に明記する）

| 非対称 | 理由 |
|---|---|
| oauth のログイン | 部屋は Windows の資格を読めない（`/mnt/c` なし、interop 切り）。部屋で 1 回 `/login` が要る |
| bedrock の AWS 資格の種類 | 部屋に AWS CLI が無く、IAM キー（`room aws-key`）だけ。Windows は SSO でもよい。置き場（`~/.aws`）と設定の形が同じなら、種類は揃えない |

## 4. 進め方と判断の分岐

原因が未特定なので、**先に案 A の原因特定（V2 の二分探索、6.1）と V3 を行い、原因が分かってから、A か B かを決める**（ee、2026-11-20: B と確定させるのは A の原因が分かってから。きちんと比較する）。比較は 6.4 の表に記入して行う。

| 手順 | 内容 |
|---|---|
| 1 | V1、V2-0〜V2-6（A の原因特定）、V3 を実行し、結果を 6 章の表に書く |
| 2 | 6.4 の比較表（A の修正の大きさと、B の得るもの）を埋め、下の分岐で A か B かを決める（ee に報告して確認） |
| 3 | B なら 3.3 の 1（NA 15 の変更）の承認を得てから、3.3 の 2 → 3 → 4 → 5 → 6 の順に実装する |
| 4 | V5・V6・V7・V8 で受け入れ条件（must）を確認する |

| V2・V3 の結果 | 判断 |
|---|---|
| V2 で、引数の途中で引用符が落ちる（H2）／展開されない（H1）と分かり、`--cmd` の 1 行を直せば NA 17 が通る | **案 A を先に適用してよい**（応急）。ただし R3（値の正本が 2 つ）は直らないので、B の 3.3 の 1・2 は別に進める |
| V2 で原因が引用符でない（H3・H4・H5）。または V3（手で置いた設定ファイル）で bedrock が通る | **案 B で進める**（引数の層を通らなくなるので、原因が何でも構造の弱さは消える） |
| V3 も通らない（AWS の資格・env の内容の問題） | 設定の運び方でなく資格の問題。`room aws-key` の状態と `AWS_PROFILE` の名前を先に直す（A でも B でも同じ） |

## 5. 決めてほしいこと（B に関わるもの）

| # | 質問 | 影響 |
|---|---|---|
| Q2 | ~~会社の方針で、IAM の長期キー（`room aws-key`）は許されるか~~ | **回答済み（ee、2026-11-20）: 許される。** 現時点でも `aws-key` で Zed の ACP を起動している。room の bedrock は must を満たせる |
| Q3 | 3.3 の 1（`room-profiles.json` から bedrock の値を外し、Windows の PC 専用ファイルを正本にする。NA 15 の決定の変更）でよいか | B の前提。承認が要る |
| Q1 | 認証を選ぶ 2 段目は `room:` の行だけか。`win:` の zellij の経路（今は素の `claude`）にも入れたいか | B の範囲。入れるなら別の設計（案 C） |

## 6. 実機で確認する項目（B に関わるもの）

結果は表の右に日付つきで書き足す。値（プロファイル名、モデル ID、URL）は書かず、「ある・ない」と形だけを書く。room の試験用の Project は `myinv*` か `mydev*` の名前にする（ダミー）。`<Area>` は Area 名。

### 6.1 切り分け（コードは変えない）

| # | 確かめること | 手順 | 期待・判断 | 結果 |
|---|---|---|---|---|
| V1 | 部屋で `claude` と `base64` に届く | `wsl -d room-<Area> -u ai -- bash -ic "command -v claude base64"` | 両方のパスが出る。出なければ H3 | |
| V2 | **案 A の原因特定**（引数が部屋に届くまでに何が起きるか） | 次の 6.1b の二分探索（V2-0〜V2-6）を、上から順に行う | 最初に壊れる層が原因の層 | |
| V3 | 案 B の動作そのもの（手で） | 部屋に `~/.claude/settings-bedrock.json`（env だけの JSON）を手で置く。例: pwsh で `Get-Content $HOME\.claude\settings-bedrock.json \| wsl -d room-<Area> -u ai -- sh -c 'cat > $HOME/.claude/settings-bedrock.json'`（`awsAuthRefresh` などは先に消す）。キー名の確認: `python3 -c "import json;print(list(json.load(open('/home/ai/.claude/settings-bedrock.json'))))"`。部屋で `claude --settings $HOME/.claude/settings-bedrock.json`。`~/.aws/credentials` に `AWS_PROFILE` の名前の節があるか（節の名前だけ） | `/status` が Bedrock・リージョン・モデルを示す。通れば B は成立。通らなければ、原因は引用符でなく AWS の資格・env の内容（H4） | |

### 6.1b 案 A の原因特定（V2。層ごとの二分探索）

ee が実施する。**上から順に行い、最初に壊れた層が原因の層**。壊れたら、そこで止めて、エラーの全文（と、壊れた出力）を控える。値（プロファイル名、モデル ID、URL）は文書に書かない。

準備（pwsh。実物の `<b64>` は、失敗するタブの「起動: …」の行にあるものを使う。ここで作るものは、形が同じ代用）:

```powershell
$json = @{ env = (Get-Content $HOME\.claude\settings-bedrock.json -Raw | ConvertFrom-Json).env } | ConvertTo-Json -Compress -Depth 5
$b64  = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))
```

| # | 層 | 手順 | 正常 | 壊れたら（原因の層） |
|---|---|---|---|---|
| V2-0 | 部屋の claude と資格（引数の運び方を使わない） | 部屋の bash で、`CLAUDE_CODE_USE_BEDROCK` `AWS_REGION` `AWS_PROFILE` とモデルの env を直接 `export` して `claude`。`/status` | Bedrock で動く（Zed の ACP が動いているので、動く見込み） | 資格・リージョン・モデルの問題（H4）。A でも B でもなく、先に直す |
| V2-1 | `--settings` にファイルを渡す（= V3） | 3.3 の 2 の中身を手で置き、部屋で `claude --settings $HOME/.claude/settings-bedrock.json` | 動く | env の内容の問題。ファイルの形（`env` だけか） |
| V2-2 | `--settings` に JSON 文字列を直接渡す（シェルの層だけ） | 部屋の bash で `claude --settings '{"env":{...}}'`（`$json` の中身を単一引用符で） | 動く | claude が JSON 文字列をどう受けるか（パスと JSON の見分け。H5）。形の問題 |
| V2-3 | 部屋の中で完結する展開 | 部屋の bash で `printf '%s\n' $(echo <b64> \| base64 -d)`。続けて `claude --settings $(echo <b64> \| base64 -d)` | 引用符つきの JSON が出て、動く | `base64` か `bash -ic` の初期化の出力（H3） |
| V2-4 | `wsl.exe` を通す（pwsh と cmd） | pwsh: `wsl -d room-<Area> -u ai -- bash -ic 'printf "%s\n" $(echo <b64> \| base64 -d)'`（**単一引用符**）。cmd.exe: 同じ行を、cmd の引用の規則で。両方の出力を比べる | 引用符つきの JSON | 引用符が落ちる（H2）／`$(echo` がそのまま出る（H1）。pwsh と cmd で違えば、呼び出し側の層 |
| V2-5 | `room.py` を通す（`claude` でない無害なコマンドで） | `uv run --script $env:WFKIT_DIR\room\room.py start <myinv の Project> --cmd 'printf "%s\n" $(echo <b64> \| base64 -d)'` | 引用符つきの JSON が出る | `room.py` の連結（`cd <マウント先> && <cmd>`）と、Python からの `wsl.exe` の呼び出し（V2-4 は正常なのにここで壊れるなら、この層） |
| V2-6 | wezterm のタブが実行する行そのもの | `wezterm.lua` の `open_room` が作る `pwsh.exe -NoLogo -NoExit -Command "uv run --script … start <p> --cmd 'claude --settings $(echo <b64> \| base64 -d)'"` を、cmd.exe から手で打つ。次に、wezterm のタブで同じ認証を選ぶ | 起動する | 手では動くのにタブで壊れるなら、Lua の文字列と wezterm の起動の層。手でも壊れるなら、V2-5 との差（`claude --settings` の呼び出し）を見る |

記録: 壊れた最初の層、その出力・エラーの全文、直すなら **どこを何行直すか**（案 A の修正案）。

### 6.2 must の確認

| # | 確かめること | 手順 | 期待・判断 | 結果 |
|---|---|---|---|---|
| V5 | **oauth（部屋）の既定と `/login` の完了** | `Claude OAuth (room)` で起動し `/status`。部屋の `~/.claude/settings.json` のキーの**名前だけ**を見る（`python3 -c "import json;print(list(json.load(open('/home/ai/.claude/settings.json'))))"`）。ブラウザが開かない部屋で、`/login` が URL とコードの貼り付けで完了できるか。終了して起動し直し、ログインが残るか | `apiKeyHelper` や `env` が既定に入っていない。`/login` が完了し、残る | |
| V6 | Windows の基準。`claude --version` も両側で | pwsh で `claude-pick oauth` / `bedrock` を起動し、各 `/status` の認証・プロバイダ・リージョン・モデルを控える。部屋でも `claude --version` | これが V7 の比べる相手。版が違うと `--settings` の挙動差が混ざるので、先に記録する | |
| V7 | **must: oauth と bedrock が揃う** | V6 の表と、room の `/status` を並べる。モデル ID は、Windows の `settings-bedrock.json` と部屋の写しの env を比べる。点検表（実装後）も並べる | 非対称（3.5）以外が一致 | |
| V8 | 後始末（NA 17 の(2)(3)） | claude の終了でタブの `room start` が終わりアンマウントされるか。強制終了後に `room umount` で残骸を拾えるか | 両方できる | |

### 6.3 その他（B の判断材料）

| # | 確かめること | 手順 | 期待・判断 | 結果 |
|---|---|---|---|---|
| V9 | `win:` の zellij の中の claude の認証と、環境の残り | `win:` のタブで `/status`。`Get-ChildItem Env:` で `ANTHROPIC_*` `CLAUDE_CODE_USE_*` `AWS_*` の**名前と長さだけ**を見る | 認証が環境の残りで決まっていないか。Q1 の判断材料 | |
| V10 | 部屋の Bedrock の資格（Q2 は回答済み） | 部屋の `~/.aws/credentials` に `AWS_PROFILE` と同名の節があるか（節の名前だけ）。Windows は `aws sts get-caller-identity --profile <名前>` が通る方式（SSO か IAM キー）を控える | 同名の節がある（Zed の ACP が動いているので、ある見込み）。名前がずれていれば、そろえる | |

### 6.4 案 A と案 B の比較表（原因が分かったら記入。ee、2026-11-20: きちんと比較する）

A 列は V2 の結果で記入する。B 列は、設計からの見込み（V3・実装後に確かめる）。

| 観点 | 案 A（原因の層を直す） | 案 B（設定ファイル） |
|---|---|---|
| 直す場所と、直す行数 | （記入） | 配布スクリプト 1、`wezterm.lua`、`room-profiles.json`、点検表、試験、文書（約 9〜10 ファイル） |
| 直したあと、bedrock が起動するか | （記入） | 見込み: 起動する（V3 で手では確認） |
| 部屋で手で再現できるか（デバッグの入口） | （記入） | 1 行（`claude --settings $HOME/.claude/settings-bedrock.json`） |
| 同じ種類の不具合の再発（引数の層が増えたとき） | （記入） | 引数に値を載せないので、構造上ほぼ無い |
| 値の正本が 1 つになるか（R3） | 直らない（別に直す） | 直る（NA 15 の変更。承認が要る） |
| must（oauth・bedrock の仕組みが揃う）を満たすか | 満たさない（bedrock だけ別機構のまま） | 満たす |
| 起動時間 | （記入。変わらない見込み） | 未測定（ほぼ無視できる見込み） |
| 戻しやすさ | （記入） | 変更を 1 コミットにまとめれば容易 |
| 判断 | （記入） | （記入） |

## 7. 作業の規則（dotfiles の `AGENTS.md` から。抜粋）

- 値（プロファイル名、モデル ID、URL、ユーザー名を含むパス）をリポジトリの文書・コードに書かない（`%USERPROFILE%`、`$HOME`、`<名前>` にする）。リポジトリは公開に切り替えることがある。
- `scripts/linux/` と `home/.profile` を変えたら `bash tests/linux/test_scripts.sh`。Windows 側は `pwsh -NoProfile -File tests/windows/<該当>.ps1`。
- コミットは `[対象] 内容`。`git add` はパスを指定する。AI は push しない（人が push する）。
- リスクや制約が生まれる変更（NA 15 の変更など）は、事前に ee に確認する。

## 8. 後回し（案 B の後）

- **案 E（緊急起動用の `claude-pick`）**: zellij が使えないとき、部屋の bash のシェルから `claude-pick` で起動する薄いラッパー。**案 B の設定ファイルを読むだけ**なので、B のあとで足せる。対象は oauth と bedrock（gateway は単独では使えない）。比較書の 5 章 E、V13。
- gateway を `--settings` に寄せる（R1。V11）、api の room 対応（Q7）、起動の遅さ（V12）。比較書の 8・9・10 章。

## 参照

- 比較書: `docs/design/auth-launch-unification.md`（3 章: 原因の仮説、5 章: 全案、8 章: 緩和案 R1〜R7、10 章: 確認項目の全体、13 章: 三層レビュー）。
- 実物: `windows/wezterm/wezterm.lua`（`open_room`）、`windows/wezterm/room-profiles.json`、`windows/powershell/profile.ps1`（`claude-pick`、`claude-bedrock`）、`windows/claude/README.md`、`windows/room/room-nvim-config.ps1`（配布スクリプトの型）。
- workbase の `workflow-kit/room/room.py`（`cmd_start`、`claude_extra_args`）と `workflow-kit/room/README.md`（`aws-key`）。
- `docs/decisions.md` の NA 15 の項。
