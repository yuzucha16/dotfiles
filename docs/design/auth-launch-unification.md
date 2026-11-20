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

2026-11-20 起草、同日に、条件の追加（第 2 版）、案 E（第 3 版）、三層レビューの反映（第 4 版。13 章）。**まだ何も決めていない。** 現状の構成を維持する選択肢も含めて比べ、実機で確かめる項目（10 章）を並べる。実装は含まない。

## 1. ねらいと条件

- ねらい: Windows で動く認証は room でも動き、動かないときは**同じ手順で切り分けられる**こと。使う人が Windows か room かを意識しないこと。
- 条件（ee、2026-11-20）:
  1. 横並びで見たいので、**4 認証（oauth・bedrock・gateway・api）すべて**を、Windows と room の両方で比べる。
  2. **仕組みと考え方を揃える**ことを目指す（例: oauth は、それぞれの `~` に資格があればよい）。
  3. **must は bedrock と oauth が Windows と room で揃っていること。** gateway と api は、最終的に Windows だけでもよい。ただし考え方は揃えられるはずなので、揃える案は出す。
  4. 緩和すると楽になる点があれば提案する（8 章）。
  5. zellij が使えない（重い）ときの**緊急用の高速起動**として、素のシェルから `claude-pick` だけで起動できる経路がほしい（案 E。wezterm の `--cmd` に環境設定を渡すのが負担なため）。ee の訂正: 「WSL の pwsh7」は誤りで、部屋の bash のシェルのこと。`room start` が要る場面は、ee が自分で打つ。
- 範囲外: zellij の使いこなし（3 番目の課題）。起動の遅さ（1 番目の課題）は、各案の影響だけ 9 章に書き、手を付けるのは最後。
- 依存の向き: dotfiles → workbase の一方向を保つ（`room.py` は workbase。dotfiles の挙動を書かない）。
- 「WSL」は、このリポジトリの wezterm が使う**専用の部屋（room）**のこととして扱う（Q5）。

## 2. 現状（コードから読んだこと）

2026-11-20 時点の `windows/wezterm/wezterm.lua`、`windows/wezterm/room-profiles.json`、`windows/powershell/profile.ps1`、`windows/claude/README.md`、workbase の `workflow-kit/room/room.py` を読んだ。実機での動作は 10 章で確かめる。

### 2.1 4 認証の経路

| 認証 | Windows | room（wezterm → `room start`） | 資格の置き場（Windows / room） |
|---|---|---|---|
| oauth | `claude-oauth`: 環境の認証変数を一時的に外して `claude` | 環境なしの `room start`（`claude`） | Windows の `~\.claude` / 部屋の `~/.claude`。**別々**（`/login` が各環境で要る） |
| bedrock | `claude-bedrock`: `claude --settings ~\.claude\settings-bedrock.json`（PC ごとに `claude-bedrock-setup` が生成。リポジトリに置かない） | `--cmd 'claude --settings $(echo <base64> \| base64 -d)'`。env は git 追跡の `room-profiles.json` | `~\.aws`（SSO か、IAM キー）/ 部屋の `~/.aws/credentials`（`room aws-key`。部屋に AWS CLI は無い） |
| gateway | `claude-gateway`: `CLAUDE_CONFIG_DIR=~\.claude-gateway`、`apiKeyHelper` | `room start --gateway`: 同名のディレクトリ。`apiKeyHelper` は `cat` | Windows: DPAPI の `token.dpapi`（無音更新）/ 部屋: `token`（**Windows から約 50 分ごとに押す**。部屋は interop が切れていて Windows を呼べない） |
| api | `claude-api`: `claude --settings settings-api.json`（`apiKeyHelper`） | 未対応（NA 16） | Windows: DPAPI の `settings-api-key.dpapi` / 部屋: 無し（DPAPI が無い） |

### 2.2 読み取れること・見つけたこと（要確認）

- **壊れているのは bedrock だけ**に見える。gateway は構造が並行（ファイルと設定ディレクトリを指し、引数に特殊な文字が無い）。
- **bedrock だけ、JSON を起動の引数で運ぶ。** Windows は「ファイルを指す」、room は「引数に埋め込む」で、ここが違う。
- **4 認証の「資格」は、どれも各環境の `~` の下にある**（oauth は `.claude`、bedrock は `.aws`、gateway は `.claude-gateway`、api は DPAPI のファイル）。ee の原則（資格は各環境の `~` にあればよい）は、すでにほぼ成り立つ。足りないのは、room の api の置き場と、設定の形の統一。
- **値の置き場が食い違っている。** `windows/claude/README.md` は、Bedrock のプロファイル名・リージョン・モデル ID は環境ごとに違う値なので、設定ファイルは PC 専用に生成し**リポジトリに置かない**と書く。一方 `room-profiles.json`（git 追跡）の bedrock には、その種類の値が入っている（NA 15）。家の PC は Bedrock が無いので、PC ごとに値が違う前提は実際にある。**正本が 2 つ**で、公開に切り替えることがあるリポジトリの方針とも合わない。
- `win:` の zellij の中の claude は、認証を選ばない。`home/.config/zellij/layouts/claude-b.kdl` の `pane command="claude"` と、`config.kdl` の `Alt+c`（`Run "claude"`）は、素の `claude` を起動する。認証を選ぶ 2 段目があるのは `room: <project>` の行だけに読める（Q1）。
- `room: <project>` の行は zellij を使わない（NA 15 の決定）。

### 2.3 引数がくぐる層（bedrock の room 行）

Lua の文字列 → pwsh の `-Command` → Windows のコマンドライン → `uv` → `room.py` の argparse → `room.py` が `cd <マウント先> && <cmd>` と**クォートなしで連結** → `wsl.exe` の引数 → 部屋の外側のシェル → `bash -ic`。`room.py` 自身のコメント（`push_shared` の付近）に、`wsl.exe` は引数を部屋の外側のシェルでもう一度解釈する、とある。JSON を引数に埋め込むと、**少なくとも 4〜5 回の引用符の解釈**を通る。

## 3. 症状の見立て（仮説。V2 で切り分ける）

最後に出たエラーは「`--settings` の JSON が不正」。`base64_encode`（Lua の自前実装）は、Python に移して `room-profiles.json` の env で検算し、標準の base64 と**一致した**。符号化の側ではない見込み。残る候補:

| 仮説 | 説明 | そうなら見える症状 |
|---|---|---|
| H1 | `$(echo … \| base64 -d)` が展開されない | claude に `$(echo …` がそのまま渡る。多くは「ファイルが無い」系で、「不正な JSON」とは出ない見込み（`--settings` がパスと JSON をどう見分けるかは未確認） |
| H2 | 展開はされるが、途中のシェルが引用符を落とす | `{env:{CLAUDE_CODE_USE_BEDROCK:1,…}}` のような、引用符のない JSON。報告された症状に合う。ただし、`room.py` の連結（`cd <マウント先> && <cmd>`）を読む限り、`bash -ic` が展開した結果は再解釈されにくく、**弱い**（三層レビューの反証） |
| H3 | 部屋に `base64` が無い、または `bash -ic` の初期化の出力が混ざる | 復元した文字列が壊れる |
| H4 | 部屋の環境に認証の変数が残って混線する。または、`AWS_PROFILE` の名前が部屋の `~/.aws/credentials` に無い（`room.py` の `GATEWAY_CMD_PREFIX` が `env -u CLAUDE_CODE_USE_BEDROCK` を付けているのは、部屋に残る経路があった名残の可能性） | JSON のエラーでなく、認証・資格のエラーになる見込み |
| H5 | 「不正な JSON」と出た層が、`--settings` の値でない（別の層のエラーを読み違えている） | エラーの全文を控えると分かる（V2 の (a) で全文も控える） |

ee の見立て（展開が起きない）と、私の読み（「不正な JSON」と出たなら展開は起きている）は食い違う。V2 で決着する。**原因が未特定のうちは、案 B に決めず、V2・V3 の結果で案 A か案 B かを決める**（13 章）。JSON を引数に載せる限り、引用符の層が増えるたびに再発しうる、という構造の弱さは、原因によらず残る。

## 4. 揃える考え方（4 認証に共通の型）

認証を、次の **3 点組**で定義する。Windows と room で、点の中身（保管方法）は違ってよいが、点の置き場と形は同じにする。

| 点 | 内容 | 揃える形 |
|---|---|---|
| ① 設定 | 秘密を含まない JSON。env と、`apiKeyHelper` のコマンド名だけ | `claude --settings <ファイル>` で渡す。置き場は両環境で同名・同位置（`~/.claude/settings-<id>.json`）。oauth は設定ファイルなし |
| ② 資格 | その環境の `~` の下にある | **運ばない。** 例外は gateway の ID トークンだけ（約 1 時間で切れるので押す） |
| ③ 起動 | 常に `claude [--settings ①]` | 環境の残りは、Windows では外す（oauth）。room は元々きれい |

4 認証に当てはめる（太字が、今と違う点）:

| 認証 | ① 設定 | ② 資格 | 入れ方（環境ごとに違ってよい） | 優先度 |
|---|---|---|---|---|
| oauth | なし | `~/.claude/.credentials.json` | 各環境で 1 回 `/login` | **must** |
| bedrock | `settings-bedrock.json`（env: `CLAUDE_CODE_USE_BEDROCK` `AWS_REGION` `AWS_PROFILE` とモデル） | `~/.aws/`（Windows: SSO のキャッシュか IAM キー / room: IAM キー） | Windows: `aws sso login` か `aws configure` / room: `room aws-key` | **must** |
| gateway | `settings-gateway.json`（`apiKeyHelper`、`ANTHROPIC_BASE_URL`、モデル）。**今は `~/.claude-gateway/settings.json` と `CLAUDE_CONFIG_DIR`。`--settings` に寄せるかは 8 章 R1** | `~/.claude-gateway/token`（`apiKeyHelper` が返す） | Windows: DPAPI + 自前で更新 / room: Windows が押す（Windows 付属） | 考え方は揃える。room は後回し可 |
| api | `settings-api.json`（`apiKeyHelper`、モデル） | キーのファイル。Windows: DPAPI / room: **`~/.claude-api/key`（権限 600）** | Windows: `claude-api-key.cmd -Set` / room: `room aws-key` と同じ型（画面に出さず標準入力で渡す）の新しい入口 | 考え方は揃える。room は後回し可 |

- gateway と api は、設定の側が `apiKeyHelper` を書くだけで、**資格の保管方法は環境ごとに閉じる**（Windows は DPAPI を復号、room は `cat`）。この分け方が、「考え方を揃える」の中身になる。
- room に api のキーを置くと、AI から読める場所に長期のキーがある状態になる（`aws-key` と同じ性質）。置くなら、Console の workspace の spend limit を先に決める（`windows/claude/README.md` の「費用の上限」）。Q7。
- **横並びの点検表**を、デバッグの入口にする（5・7 章）。各環境で、4 認証の「設定ファイルがあるか」「資格の置き場があるか」「環境に認証の変数が残っていないか」を、**名前と有無だけ**で 1 表に出す（値は出さない）。

## 5. 案

### 案 A: 現状を維持する（引用符だけ直す）

- 内容: 構成はそのまま。V2 で壊れ方が分かれば、`--cmd` の組み立て（引用符・展開の位置）だけを直す。
- 4 認証への当てはめ: oauth は今のまま、bedrock だけ引数の JSON、gateway は設定ディレクトリ方式、api は room に無い。**横並びにならない**（動くようになっても、bedrock の仕組みが Windows と別のまま）。
- 良い点: 変更が最小。workbase に触れない。
- 悪い点: must の「仕組みが揃っている」を満たさない。引用符の層が多く、部屋の側で何が渡ったかを手で再現しにくい。

### 案 B: 設定ファイル方式（4 章の 3 点組をそのまま実装する）

- 内容:
  1. 部屋にも、Windows と同じ `~/.claude/settings-<id>.json` を置く。引数で運ばない。
  2. 起動は `--cmd 'claude --settings $HOME/.claude/settings-bedrock.json'`。使う文字は英数字と `/ . $ - _` だけにして、どの層でも解釈が変わらないようにする。**`claude` で始まるので、`room start` の `--add-dir` の処理（先頭が `claude` のときだけ効く）も保たれる。**
  3. 部屋への置き方は、dotfiles の小さなスクリプト（`windows/room/` に、`room-nvim-config.ps1` と同じ型）が、標準入力（`wsl.exe … sh -s`）で書く。**元になるのは Windows の PC 専用ファイル**（8 章 R3）。
  4. 点検表のスクリプト（両環境で同じ見た目）を足す。
- 良い点: 引用符の問題が構造ごと無くなる。`room.py` は変えない。部屋で `claude --settings ~/.claude/settings-bedrock.json` と**手で打って再現できる**。oauth・bedrock・gateway・api の 4 つが、同じ型で並ぶ。
- 悪い点: 部屋にファイルを置く手順が 1 回増える（元の値を変えたら再実行。古さを点検表で見つける。部屋を作り直したら再配布）。点検表が Windows 用と room 用の 2 実装になる（点検の対象を、ファイルの有無とハッシュに絞って薄くする）。gateway を同じ型にするには R1（Zed を要件から外す）が要り、部屋の側は workbase の `room.py` の変更も要る。
- 起動の時間: 未測定。起動時の処理は増えないので、ほぼ無視できる見込み。

### 案 C: 単一のランチャー（wezterm は識別子だけ渡す）

- 内容: `claude-launch <認証> --room <project>` / `--win <cwd>` のような入口を 1 つ作り、4 認証の定義を 1 つの表に持つ。引用符の処理・環境変数の退避・`room start` の組み立ても 1 か所。`--dry-run` で組み立てた行を表示。Windows の `claude-pick` は、これを呼ぶ薄い関数にする。
- 良い点: 入口が本当に 1 つ。4 認証の横並び（一覧・点検）が自然に作れる。`win:` の zellij 経路にも同じ入口で認証選択を足せる。
- 悪い点: 変更が大きい。今動いている pwsh の関数（`profile.ps1`、`tests/windows/test_claude_launchers.ps1`、Zed の `claude-acp-*.cmd`）と二重になるか、置き換えの試験が要る。起動にプロセスが 1 つ増える（未測定。pwsh 経由で `-NoProfile` にしないと、過去の記録では +数秒の恐れ）。部屋の側は結局、案 B のファイルを使う（C は B の上に乗る）。

### 案 D: 部屋の bash に、同名の関数（`claude-pick` など）を作る

- 内容: 部屋の `.bashrc` に `claude-bedrock` `claude-oauth` `claude-gateway` `claude-api` `claude-pick` を、Windows と同じ名前・同じ挙動で作る。
- 良い点: 部屋の中でも同じ名前を打てる。
- 悪い点: pwsh と bash の**二重実装**で、ずれる。`--cmd 'claude-bedrock'` にすると、`room.py` の `--add-dir` の処理が効かなくなり、workbase の変更が要る。B の設定ファイルの上に載せる見た目だけの糖衣としてなら成り立つが、単独では勧めない。**案 E は、これを「設定ファイルを読むだけ」に薄くした形として扱う。**

### 案 E: 案 B の上に、薄い共通ラッパー `claude-pick` を両環境に置く（zellij なしの緊急起動）

- 背景（ee、2026-11-20）: zellij が特に重い。zellij が使えないとき、素のシェルから、wezterm の `--cmd` に環境設定を渡さずに、`claude-pick` だけで起動したい。緊急時の高速起動のバックアップ。
- 内容:
  1. ラッパーは、案 B の設定ファイル（Windows の PC 専用ファイルが正本、部屋へは複製）を**読むだけ**。持つのは、認証の名前（oauth・bedrock）から `claude --settings <ファイル>`（oauth は環境の残りを外して `claude`）への対応と、選択（fzf。無ければ番号入力）だけ。値も資格も持たない。
  2. Windows は今の `claude-pick`（`profile.ps1`）がそのまま。部屋には、同名・同じ引数（`claude-pick [oauth|bedrock] [claude への引数]`。gateway は単独では使えず、api は部屋に資格が無いので、選択肢に出さない）のものを `~/.local/bin/claude-pick` に置く。置くのは、設定ファイルの配布と同じ dotfiles のスクリプト（`room init` の外。workbase は変えない）。
  3. 形は **bash 版 1 本**（部屋の shell。ee の訂正）。Windows の `claude-pick`（pwsh）とは別実装だが、設定ファイルを読むだけで 15 行前後と薄い。pwsh を部屋に入れる案（旧 E2）は、`room init` から PowerShell 7 を外した決定（2026-11-10。workbase の `room/README.md`）と衝突するので落とした。uv の 1 本（旧 E3）は案 C に含める。
  4. 入口: wezterm の既存の素のシェルの行（`room-<Area> (shell)`、`pwsh (Windows)`）を開き、`claude-pick` と打つ。zellij も `room start` も通らない。
- 良い点: 起動が軽くなる見込み（zellij の 2 段起動と、`room start` の前処理を通らない。ただし WSL の cold start、`bash -ic` の初期化、`claude` の起動は残る。V13 で実測するまで主張しない）。`--cmd` に環境設定を載せないので、引用符の問題が入らない。zellij や wezterm の設定が壊れていても使える（バックアップ）。Windows と room で、同じ名前を打てる。
- 制約（速さと引き換え。`room start` を通らないため）:
  - Project のマウント（`/mnt/room/<Project>`）が無い。作業は部屋の `~` か `~/src` の下になる。`--add-dir` も付かない。終了時の変更の回収も無い。
  - **gateway は、単独では使えない。** トークンは `room start --gateway` が起動の間だけ約 50 分ごとに押し、終了時に消す（`room.py` の `gateway_start` と `gateway_stop`）。別のタブで `room start --gateway` が動いている間は、トークンと設定が部屋にあるので動くが、素のシェルだけでは押されない。bash 版には gateway を出さない（選んで詰まらないように）。
  - したがって、緊急起動の対象は **oauth と bedrock**（must と一致）。api は部屋に資格が無い（Windows の素の pwsh なら使える）。
- 起動の時間: シェルの起動と `claude` の起動だけ（V13 で測って、通常の経路と比べる）。
- 保守: 普段使わない経路は、壊れていても気づかない。点検表で存在を確かめ、`tests/linux/test_scripts.sh` の型で試験を足す。手順書に「作業リポジトリを触る緊急には使えない（認証の確認、短い質問向け）」と 1 行で書く。
- 位置づけ: 案 B の代わりではなく、B の上の任意の層。wezterm からの通常の経路（`room start` + `claude --settings …`）は残す。

## 6. 比較

| 観点 | A 現状維持 | B 設定ファイル | C 単一ランチャー | D bash 関数 |
|---|---|---|---|---|
| **must（oauth・bedrock）の仕組みが揃う** | 揃わない（bedrock が別機構） | **揃う** | 揃う | 見た目だけ。中身は二重 |
| 4 認証を横並びにできるか | できない | できる（点検表 + 同じ型） | 最も自然 | 名前だけ |
| gateway・api に考え方を広げられるか | 広がらない | 広がる（R1 で gateway も同じ型） | 広がる | 広がらない |
| 引用符の再発 | 残る | 構造上ほぼ無い | 1 か所に集約 | 残る |
| 部屋で手で再現できるか | できない | **できる（1 行）** | `--dry-run` | できる |
| `room.py`（workbase）の変更 | なし | **oauth・bedrock はなし**（gateway を R1 で部屋まで揃えると要る） | なし | 要る |
| 変更の範囲 | 数行 | dotfiles のみ（約 9〜10 ファイル: 配布スクリプト、`wezterm.lua`、`room-profiles.json`、点検表 2 本、試験、手順書 2、`decisions.md`） | dotfiles 大（Windows の既存と二重化） | dotfiles + workbase |
| 起動時間への影響 | なし | 未測定（ほぼ無視できる見込み） | pwsh 経由なら +数秒の恐れ（未測定） | なし |
| 既存の動く経路を壊すリスク | 低い | 低い（Windows の関数は触らない） | 中〜高 | 低い |
| 戻しやすさ | 容易 | 容易（変更を 1 コミットにまとめれば） | 難しい | 容易 |

案 E は、案 B の上に載る任意の層なので、表に列を足さない（5 章の E に評価を書いた）。

## 7. 推奨（暫定。V1〜V5・V10・V11・V13 の結果で見直す）

**暫定: 案 B を基礎にし、点検表を足す。ただし原因が未特定なので、決めるのは V2・V3 の結果のあと（案 A か案 B か）。三層レビュー（13 章）で、残す 2 案は B と E（E は B の上の層）。** 理由は 3 つ。(1) must の「仕組みが揃う」を満たすのは B 以降で、B が最も小さい。(2) workbase を変えず、dotfiles だけで進められる。(3) 4 章の 3 点組が、そのまま 4 認証の横並びの表になり、デバッグの入口（部屋で手で打てる 1 行、点検表）が Windows と同じ形になる。

段階:

| 段階 | 内容 | 条件 |
|---|---|---|
| 1（must） | oauth と bedrock を 3 点組で揃える。oauth は、部屋で `/login` が完了し、残るかの確認（V5）が中心。bedrock は、部屋に `settings-bedrock.json` を置いて `--settings` で指す。点検表を足す | V2・V3・V5・V10 |
| 2（考え方） | gateway と api を同じ型にする。gateway は R1 が通れば `--settings` に寄せる。api は、Windows は今のまま、room は設計メモだけ（`apiKeyHelper` が `~` のファイルを返す型）。room の実装は後回しでよい | V4・V11、Q4・Q7 |
| 2b（緊急起動） | 案 E: 部屋に `claude-pick` を置き、zellij なしの素のシェルから起動できるようにする。対象は oauth と bedrock。段階 1 の設定ファイルを読むだけなので、段階 1 のあとで足せる | V13 |
| 3 | 起動の遅さ（課題 1） | V12 |
| V13 | 案 E の前提と、緊急経路の速さ | (a) 部屋に fzf があるか（無ければ番号入力にする）: `wsl -d room-<Area> -u ai -- bash -ic "command -v fzf"`。(b) 素のシェルの行（`room-<Area> (shell)`）で、`room start` なしに、`claude`（oauth）と `claude --settings $HOME/.claude/settings-bedrock.json`（V3 の置き方）が起動するか。cwd は `~`。(c) (b) の起動時間（タブを開いてから claude の入力待ちまで）を、`room: <project>` の通常経路と、`win:` の zellij と並べる | (a) 無ければ番号入力で足りる。(b) 起動する。(c) 緊急経路が、通常より十分に速いこと（V12 の候補のうち、何を省いた効果かも分かる） |

- 点検表は、複製の古さを**内容のハッシュの比較**（値は出さない）で見つける。部屋を作り直したら再配布する。元が無い PC（家）では、配布せず、認証の項目も出さない（`room-profiles.json` に PC の差を持ち込まない）。
- 案 A は、V2 で原因が引用符の 1 か所の欠陥と分かり、直せば NA 17 を通せるなら、**当面の応急としては成り立つ**。ただし must の「仕組みが揃う」は満たさないので、案 B への移行を続けて進める。
- 案 C は、段階 1・2 を実機で通したあとに、「`win:` の zellij 経路にも認証選択を入れる」と決めたとき（Q1）に再評価する。
- 案 D は、案 E（薄い共通ラッパー）として、段階 2b で扱う。

案 B でも残る非対称（設計で消せない。**手順書に明記して揃える**）:

| 非対称 | 理由 |
|---|---|
| oauth のログイン | 部屋は Windows の資格を読めない（`/mnt/c` なし、interop 切り）。部屋で 1 回 `/login` が要る |
| bedrock の AWS 資格の種類 | 部屋に AWS CLI が無く、IAM キー（`room aws-key`）だけ。Windows は SSO でもよい。**置き場（`~/.aws`）と設定の形が同じなら、種類は揃えない**（R2） |
| gateway のトークンの更新 | リフレッシュトークンは Windows の DPAPI に残り、部屋には約 1 時間で切れる ID トークンだけを押す。Windows が動いている間だけ使える |
| api の保管 | Windows は DPAPI、room は（置くなら）権限 600 のファイル |

## 8. 緩和案（条件を緩めると楽になる点。根拠つき）

| # | 緩める点 | 根拠 | 効果 | 代償・リスク | 推奨 |
|---|---|---|---|---|---|
| R1 | **Zed の agent を、起動の要件から外す**（残してよいが、制約にしない） | gateway が `--settings` でなく `CLAUDE_CONFIG_DIR` で分かれている理由は、「`--settings` の別ファイルは Zed の起動に使えない」（`decisions.md` の 2026-10-20 の却下案）。その後、ee は Zed を離れる方向を示している（同 2026-11-19） | 4 認証が、すべて `claude --settings <ファイル>` の同じ型になる。共通の `~/.claude` の設定（hooks、permissions、`CLAUDE.md`）が gateway でも効き、「作成時点の写し」と、room の `gateway_hooks_merge`（hooks の写し）が不要になる。api は既にこの型 | Zed の「Claude Gateway」は、今のまま残すなら現状維持（外すのは要件だけ）。**`--settings` で gateway が通るかは未確認**（V11）。部屋の側まで揃えるには、workbase の `room.py`（`GATEWAY_CMD_PREFIX`、`gateway_room_settings`、hooks の写し）の変更が要る | 採る（V11 で通れば） |
| R2 | **資格の「種類」は揃えず、「置き場」だけ揃える**（bedrock: Windows は SSO でもキーでもよい。room はキー） | 部屋に AWS CLI が無く（`room init` の道具一覧に無い）、`aws sso login` ができない。SSO のキャッシュも IAM キーも `~/.aws` の下にあり、ee の原則（`~` に資格がある）に収まる | bedrock の must を、Windows の SSO 運用を変えずに満たせる | 会社が IAM 長期キーを許さない場合は、room の bedrock が成り立たない（Q2。その場合は R2 の前提が崩れる） | 採る |
| R3 | **Bedrock の値の正本を、Windows の PC 専用ファイルにし、`room-profiles.json` から bedrock の値を外す。部屋には複製する** | README の方針（プロファイル名・リージョン・モデル ID は環境ごとに違い、リポジトリに置かない）と、`room-profiles.json` の実態が食い違う（2.2）。gateway も、すでに「Windows の `settings.json` から部屋の分を作って置く」（`room.py` の `gateway_room_settings`）方式 | 正本が 1 つになる。家の PC（Bedrock なし）では項目を出さない判定も、ファイルの有無で済む。リポジトリに値を置かない | 複製の手順が 1 回要る（元を変えたら再実行。点検表で古さを見つける）。`room-profiles.json` は、認証の一覧（id・ラベル・タグ）だけになる。**`decisions.md` の NA 15 の決定（認証は `room-profiles.json`）の変更**になる（承認が要る） | 採る |
| R4 | **「WSL」を room に限る**（interop のある通常の WSL は対象外のまま） | `wezterm.lua` の候補は win と room だけ。通常の WSL は未対応（`wezterm-zellij-nvim.md` の確認状況） | 考える環境が 2 つで済む（通常の WSL は interop で Windows を呼べて、gateway などが楽になるが、別の設計になる） | ee が通常の WSL も使うなら、別途設計が要る（Q5） | 採る（Q5 の確認後） |
| R5 | **gateway と api の room 対応を、設計メモにとどめ、実装は後回し** | ee の条件（最終的に Windows だけでも可）。room の gateway は Windows が動いている間しか使えない（2.1）。api は、部屋に長期キーを置くかの判断が要る（Q7） | must（oauth・bedrock）に集中できる | room の api・gateway は当面使えない（gateway は既に使える。api は元から未対応） | 採る |
| R6 | **Windows の環境変数に、認証の変数を恒久で置かない規約にする**（`ANTHROPIC_*`、`CLAUDE_CODE_USE_*` は、起動のたびに `--settings` で与える） | `claude-oauth` が環境の残りを外す仕組みを持つのは、残りがありうるため（`windows/claude/README.md` の診断）。room は元々きれい（`WSLENV` を空にして Windows の環境変数を渡さない） | oauth が、両環境とも「何も足さず `claude` を起動する」だけの同じ型になる。点検表の「環境の残り」の欄が、常に空になることを期待できる | 規約を守る必要がある（点検表が見張る）。`claude-oauth` は保険として残してよい | 採る（V9 で今の残りを確認してから） |
| R7 | **起動前の点検を、room の `room start` と分けて持つ**（認証の疎通だけを確かめる軽い経路を 1 つ持つ） | `room start` は、共有知の送付・マウントなど重い処理を含む（`room.py` の `cmd_start`）。認証の不具合の切り分けに、毎回これを通すのは遅く、層も多い | デバッグが速い（V3 がそのまま常設の手順になる）。起動の遅さの切り分けにも使える | 経路が 1 つ増える（手順書に書くだけ。コードは増やさない） | 採る |

## 9. 起動の遅さ（課題 1）への影響と、最後にやる測定

- 案 A・B・D は、起動時間を変えない。案 C は、プロセスが 1 つ増える（未測定）。**認証の統一は、速さの改善にはならない**（遅くもならない）。R7 は、切り分けの時間を縮める。
- 60 秒の内訳は、まだ測っていない。**候補**（測定するまで確定しない）:
  1. pwsh の起動。`log-history.md` に、pwsh 本体が約 2.2 秒、プロファイルが約 1.5 秒という過去の記録がある（Windows Terminal のタブ。wezterm の room タブも同じ pwsh を使う）。`room: <p>` のタブは `uv run` を 1 つ走らせるだけなので、`-NoProfile` にできる可能性がある。
  2. `room start` の直列の処理: 共有知の tar の送付、信頼の記録、Area の写し、`drvfs` のマウント、`gateway_check`（Windows の `claude-gateway-token` を呼ぶ。pwsh 起動とネットワークを含みうる）。
  3. WSL のディストリビューションの cold start（`wsl --terminate` 後の最初の起動）。
  4. `uv run --script` の起動（2 回目以降はキャッシュ）。
  5. zellij の 2 段起動（約 1 秒。実測済みで `docs/setup/terminal-units.md` 7 章）。
- 「zellij の welcome まで 60 秒」の経路は、`win:` の行か、`room:` の行（`room start`）かで内訳が違う（Q6）。

## 10. 実機で確認する項目

結果は、この表の右に日付つきで書き足す。**どこで: ee の実機**（pc2 は Bedrock・gateway なし → OAuth だけ試せる）。値（プロファイル名、モデル ID、URL）は書かず、「ある・ない」と形だけを書く。room の試験用の Project は、`myinv*` か `mydev*` の名前にする（ダミー。コミットを汚さない）。

### 10.1 切り分け（今の bedrock が壊れる理由。コードは変えない）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V1 | 部屋で `claude` と `base64` に届く | `wsl -d room-<Area> -u ai -- bash -ic "command -v claude base64"` | 両方のパスが出る。出なければ H3 |
| V2 | 引数が部屋に届くまでに何が起きるか（H1〜H3） | (a) 失敗するタブの「起動: …」の行（`room.py` が表示する、展開前の `cmd`）を控える。(b) pwsh から `wsl -d room-<Area> -u ai -- bash -ic 'printf "%s\n" $(echo <base64> | base64 -d)'` を実行（`<base64>` は (a) の値。pwsh では**単一引用符**で囲む）。(c) 同じ行を `cmd.exe` から実行し、結果を比べる | (b) が引用符つきの JSON なら、展開は正常（H1・H3 は否定）。引用符が落ちたら H2。`$(echo` がそのまま出たら H1 |
| V3 | 案 B の動作そのもの（コードを変えずに、手で） | 部屋で `~/.claude/settings-bedrock.json` に、env だけの JSON を手で置き、`claude --settings $HOME/.claude/settings-bedrock.json` を打つ。`~/.aws/credentials` に、同名のプロファイルの節があるか（節の名前だけ）も見る | `/status` が Bedrock・リージョン・モデルを示す。通れば案 B は成立。通らなければ、原因は引用符でなく AWS の資格・env の内容 |
| V4 | gateway のベースライン（NA 17 の(2)） | `room: <project>` → `Claude Gateway (room)` | claude が起動し、`/status` がゲートウェイ。構造が並行な認証が動くことの確認（案 B の前提） |
| V5 | **oauth の部屋の既定と、`/login` の完了**（must） | `Claude OAuth (room)` で起動し `/status`。部屋の `~/.claude/settings.json` のキーの**名前だけ**を見る（`python3 -c "import json;print(list(json.load(open('/home/ai/.claude/settings.json'))))"`）。ブラウザが開かない部屋で `/login` が URL とコードの貼り付けで完了できるか。終了して起動し直し、ログインが残るか | `apiKeyHelper` や `env` が既定に入っていない。`/login` が完了し、残る |

### 10.2 Windows 側の基準（比べる相手）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V6 | Windows の 4 つが今、期待どおりか。**`claude --version` も両側で控える** | pwsh で `claude-pick oauth` / `bedrock` / `gateway` / `api`（キーがある PC だけ）を順に起動し、各 `/status` の認証・プロバイダ・リージョン・モデルを表にして控える。部屋でも `claude --version` | これが 10.3 の「揃っているか」の基準になる。版が違うと、`--settings` や `apiKeyHelper` の挙動差が混ざるので、先に記録する |

### 10.3 対称性・緩和案の確認（案 B を実装したあと、または手で）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V7 | **must: oauth と bedrock が、Windows と room で揃う** | V6 の表と、room の `/status` を並べる。モデル ID は、Windows の `settings-bedrock.json` と部屋の写しの env を比べる。点検表（実装後）で、両環境の「設定・資格・環境の残り」を並べる | 非対称（7 章の表）以外が一致。ずれていたら、元（R3）を正にして複製し直す |
| V8 | 後始末（NA 17 の(2)(3)） | claude の終了でタブの `room start` が終わりアンマウントされるか。強制終了後に `room umount` で残骸を拾えるか | 両方できる |
| V9 | `win:` の zellij の中の claude の認証と、環境の残り（R6） | `win:` のタブで `/status`。`Alt+c` で足した claude も見る。`Get-ChildItem Env:` で `ANTHROPIC_*` `CLAUDE_CODE_USE_*` `AWS_*` の**名前と長さだけ**を見る | 認証が環境の残りで決まっていないか。Q1・R6 の判断材料 |
| V10 | Bedrock の資格の方式（R2。Q2 の前提） | Windows で `aws sts get-caller-identity --profile <名前>` が通る方式（SSO か IAM キー）と、部屋の `~/.aws/credentials` に同名の節があるか（節の名前だけ） | 会社が長期キーを許すなら R2 は成り立つ。許さないなら、room の bedrock が must を満たせるか、別の道（Q2）を決める |
| V11 | gateway が `--settings` で通るか（R1） | Windows で `CLAUDE_CONFIG_DIR` を使わずに `claude --settings ~\.claude-gateway\settings.json`。`/status` がゲートウェイか。終了して普通の `claude` が OAuth に戻るか | 通れば R1 を採れる。通らなければ gateway は今の設定ディレクトリ方式のまま（考え方の統一は、4 章の表の注記にとどめる） |

### 10.4 起動の遅さと、緊急起動の経路（案 E。最後にやる。V13 の (a)(b) は先にやってよい）

| # | 確かめること | 手順 | 期待・判断 |
|---|---|---|---|
| V12 | 区間ごとの時間 | (a) `Measure-Command { pwsh -NoLogo -Command exit }` と `-NoProfile` つきの差。(b) `uv run --script $env:WFKIT_DIR\room\room.py start <myinv の Project> --no-launch` の出力に、行ごとの時刻を付けて段ごとの時間を見る（`… \| ForEach-Object { "{0:HH:mm:ss.fff} {1}" -f (Get-Date), $_ }`）。(c) `wsl --terminate room-<Area>` の直後と、動いている状態の `room start` の差（cold と warm）。(d) `win:` の行は、タブを開いてから zellij の画面が出るまでを、手元の時計かスクリーン録画で | 9 章の候補 1〜5 のどれが大きいか。60 秒が出る条件（どの行、cold か warm か、gateway か）も控える |

## 11. 決めてほしいこと

| # | 質問 | 影響 |
|---|---|---|
| Q1 | 認証を選ぶ 2 段目は、`room:` の行だけか。`win:` の zellij の経路（今は素の `claude`）にも入れたいか | 入れるなら、案 C（単一の入口）の価値が上がる |
| Q2 | **会社の方針で、IAM の長期キー（`room aws-key`）は許されるか。** 許されない場合、room の bedrock をどうするか（通常の WSL を使う、部屋に AWS CLI を入れる、room の bedrock は must から外す、など） | R2 の前提。must の成否に直結する |
| Q3 | R3（Windows の PC 専用ファイルを正本にして、部屋へ複製。`room-profiles.json` から bedrock の値を外す）でよいか | 二重管理の解消と、リポジトリに値を置かない方針の整合 |
| Q4 | R1（Zed を要件から外す）でよいか | gateway を同じ型にできる。Zed の起動は現状維持のまま |
| Q5 | 「WSL」は room のことでよいか（通常の WSL は対象外） | R4 |
| Q6 | 60 秒かかったのは、どの行か（`win:` か `room:`）、どの認証か、WSL が止まっていたときか | 9 章の候補のどこから測るか |
| Q7 | room に api のキーを置くことを、将来許容するか（`aws-key` と同じ性質。AI から読める場所に長期キー）。API 認証（NA 16）をこの設計に含めるか | 4 章の表の api の room の欄。R5 の後回しの期限 |

## 12. 決めたあとの流れ（案 B を選んだ場合の素描）

1. V2・V3・V5・V10 で、原因・案 B の成立・oauth の `/login`・Bedrock の資格の方式を確かめる。
2. 部屋に設定ファイルを置くスクリプトを足す（`windows/room/`。元は Windows の PC 専用ファイル）。`wezterm.lua` の `--cmd` を、ファイルを指す単純な文字列にする。`base64_encode` は不要になるので消す。`room-profiles.json` は、認証の一覧だけにする（R3。NA 15 の決定の変更なので承認を得る。`wezterm.lua` の `load_auths` のフォールバックも確認）。
3. 点検表のスクリプトを足す（両環境で同じ見た目。値は出さない）。`tests/` に、設定の形と、`room-profiles.json` に秘密や値が入っていないことの検査を足す。
4. 案 E を採るなら、部屋に `claude-pick` を置く（設定ファイルの配布と同じスクリプトで。V13）。
5. V7・V8 を確認し、`docs/setup/wezterm-zellij-nvim.md` と `windows/claude/README.md` を更新、`docs/decisions.md` に決定を書く。
6. 段階 2（gateway・api の型）、その後、起動の遅さ（V12）に進む。

## 13. 三層レビューと、2 案への絞り込み（2026-11-20）

入力: この設計書の 1〜12 章（案 A〜E）。観点: 設計の整合（整）、運用の実用性（運）、反証（反）。サブエージェント 3 件を並列に走らせ、報告はデータとして扱った（ee の依頼）。ee の訂正（WSL は bash の shell。`room start` は ee が打つ）を入力に含めた。

### 13.1 案ごとの評価

| 案 | 整 | 運 | 反 | 要点 |
|---|---|---|---|---|
| A 現状維持 | × | △ | ○ | must の「仕組みが揃う」を満たさない。ただし原因が引用符の 1 か所なら十分で、V2 の結果次第では本命になりうる |
| B 設定ファイル | ◎ | ◎ | ○ | 条件に最も合い、手で 1 行再現できる。見積もりは甘く（約 9〜10 ファイル）、原因が未特定のまま推している点は直した |
| C 単一ランチャー | △ | △ | △ | 既存の pwsh・Zed・試験と二重になる。B の後、Q1 の結果次第で再評価 |
| D bash 関数 | × | × | × | 単独では二重実装と `--add-dir` の欠落。E に吸収 |
| E 緊急ラッパー（bash 1 本） | ○ | ○ | ○ | 薄くて安い。B が前提で、oauth と bedrock 限定。V13 で実測するまで速さは主張しない |

### 13.2 絞り込み: 案 B と 案 E

- 票: B は 3 観点すべてが残す。E は整・運が残し、反も「B の上の任意層として残してよい」。A は反だけが残す（V2 の結果次第）。C は 3 観点とも見送り、D は E に吸収。
- **残す 2 案は B と E。** E は B の設定ファイルを読むだけの層なので、実際の道筋は「V2・V3 で原因を確かめる → B → E」。
- **案 A は、2 案の外の保険。** V2 で原因が引用符の 1 か所と分かれば、NA 17 を先に通す応急として使える。ただし R3（Bedrock の値の正本が 2 つ）は A では直らないので、別に直す。

### 13.3 指摘と反映

| # | 指摘 | 観点 | 分類 | 反映 |
|---|---|---|---|---|
| 1 | E2（部屋に pwsh7）・E3、V13(a)、Q8 は前提が誤り。`room init` から PowerShell 7 を外した決定（2026-11-10）と衝突する | 整・運・反 | 異常 | 反映済み。E を bash 1 本にし、Q8 を削除 |
| 2 | 「B は `room.py` の変更なし」は、oauth・bedrock の範囲だけ。gateway を部屋まで揃えると変更が要る | 整 | 異常 | 反映済み（5・6 章、R1） |
| 3 | R3 は NA 15 の決定の変更 | 整 | 異常 | 反映済み（R3、12 章）。承認が要る |
| 4 | 原因が未特定のまま B を推している（3 章と 7 章が循環）。H2 は `room.py` の連結を読む限り弱い。H4（環境の残り・資格名の不一致）、H5（別の層のエラー）を見ていない | 反 | 異常 | 反映済み（3・7 章）。決めるのは V2・V3 のあと |
| 5 | B の見積もりが甘い。「起動時間は変わらない」「戻しやすい」も断定できない。C は pwsh 経由なら +数秒の恐れ | 運 | 軽微 | 反映済み（5・6 章） |
| 6 | 複製の古さの検出が弱い。ハッシュの比較、再作成での再配布、元が無い PC（家）の扱いを足す | 運・反 | 要検討 | 採用。反映済み（7 章） |
| 7 | E は、普段使わない経路なので保守が要る。用途を限る。gateway は「単独では使えない」で、選択肢に出さない | 運・整 | 軽微 | 反映済み（5 章 E） |
| 8 | R2 の根拠の取り違え（AWS CLI が無い根拠は `room init` の道具一覧） | 整 | 軽微 | 反映済み |
| 9 | 暗黙の仮定（`--settings` のパスと JSON の見分け、env と環境・既定設定の合成、`/login`、gateway の `--settings`）が未確認 | 反 | 要検討 | 既存の V3・V5・V11 で確認する。結果で 7 章を見直す |

## 出典

- `windows/wezterm/wezterm.lua`（`open_room`、`open_target`）、`windows/wezterm/room-profiles.json`、`windows/powershell/profile.ps1`（`claude-pick` ほか）、`windows/claude/README.md`、`home/.config/zellij/`。
- workbase の `workflow-kit/room/room.py`（`cmd_start`、`claude_extra_args`、`GATEWAY_CMD_PREFIX`、`gateway_room_settings`）と `workflow-kit/room/README.md`（`aws-key`、`start --gateway`）。
- `docs/decisions.md` の NA 15 の項と 2026-10-20 のゲートウェイの項、`docs/setup/terminal-units.md` の 7 章、`docs/setup/wezterm-zellij-nvim.md`。
