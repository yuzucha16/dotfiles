# Claude Code の認証（Bedrock / API キー / OAuth。個人用）

Claude Code と Zed の agent を、3つの認証で使い分ける。章は Bedrock → API キー → OAuth の順。

| 章          | 認証                         | 起動                        | 課金        |
| ---------- | -------------------------- | ------------------------- | --------- |
| 1. Bedrock | Amazon Bedrock（AWS 経由）     | `claude-bedrock`          | AWS の従量課金 |
| 2. API キー  | Anthropic の Console API キー | `claude-api`              | 従量課金      |
| 3. OAuth   | サブスク（Pro など）               | `claude` / `claude-oauth` | 定額        |

`claude` は OAuth のまま、`claude-api` と `claude-bedrock` だけ別の認証で起動する。判断の根拠は `docs/decisions.md` の「Claude Code の API キー認証は…」。

ブラウザで見るときは `README.html`（この md を写した派生物。手順のチェックボックスとコピーボタンつき）。内容を直すときは、この md を先に直し、HTML も合わせる。

## 早見表

| やりたいこと | コマンド |
|---|---|
| 起動する認証を選ぶ | `claude-pick`（fzf で選ぶ）、`claude-pick oauth` / `api` / `bedrock`（下の「起動する認証を選ぶ」） |
| Bedrock の設定を作る・起動 | `claude-bedrock-setup.cmd`、`claude-bedrock`（第1章） |
| API キーで起動 | `claude-api`（第2章） |
| キーを保存・入れ替え | `claude-api-key.cmd -Set`（第2章） |
| OAuth で起動 | `claude`（環境変数が残っていても確実に OAuth にするなら `claude-oauth`。第3章） |
| 認証・モデルの確認 | 起動後に `/status` |
| モデルの切替（セッション中） | `/model` |
| 費用の目安（セッション） | `/usage` |

## 起動する認証を選ぶ

認証の優先順位は固定（クラウドプロバイダ、`ANTHROPIC_AUTH_TOKEN`、`ANTHROPIC_API_KEY`、`apiKeyHelper`、OAuth の順）で、設定で OAuth を上げることはできない。そのため、**起動のたびに、どの認証で起動するかを選ぶ**。切り替えは起動単位で、動いているセッションの中では切り替えない（終了して選び直す。同じディレクトリなら `claude --resume` で続きを選べる）。

| コマンド | 認証 |
|---|---|
| `claude-pick` | fzf で `oauth` / `api` / `bedrock` を選んで起動する。`claude-pick api --resume` のように、モードを先頭に書けば選択を省ける。モードを省いた引数（`claude-pick --resume`）は、選んだあとの `claude` に渡す |
| `claude-bedrock` | Bedrock |
| `claude-api` | API キー |
| `claude-oauth` | OAuth（サブスク）。環境に残った変数を、その起動の間だけ外す |
| `claude` | 環境に認証の変数が無ければ OAuth。残っていると、その認証になる |

- OAuth のログイン情報（`.credentials.json`）は、`claude-api` や `claude-bedrock` を使っても消えない。`claude-oauth` で戻れる。
- 管理設定（managed settings）でプロバイダやログイン方式が固定されている環境では、選べないことがある（管理側の設定が最優先）。
- 試験: `pwsh -NoProfile -File tests/windows/test_claude_launchers.ps1`（偽の `claude` と `fzf`。環境変数の退避と復元、引数の受け渡し、選択を試験する）。

### Zed の agent

Zed では `home/.config/zed/settings.json` の `agent_servers` に、認証ごとの agent を並べている。

| agent | 認証 | 備考 |
|---|---|---|
| `Claude Bedrock` | Bedrock | `env` に `CLAUDE_CODE_USE_BEDROCK` とリージョン・モデルを書く（第1章） |
| `Claude API` | API キー | 起動は `claude-acp-api.cmd`（第2章） |
| `claude-acp` | OAuth | レジストリ版。主な入口（第3章） |

## 1. Bedrock（AWS 経由）

`claude-bedrock` だけ Bedrock 経由で起動する（`claude` は OAuth のまま）。ただし、プロファイル名・リージョン・モデル ID は環境ごとに違う値なので、設定ファイルは**この PC 専用に生成**し、リポジトリには置かない（`%USERPROFILE%\.claude\settings-bedrock.json`。秘密は含まない）。

| やりたいこと | コマンド |
|---|---|
| 設定を作る（対話） | `claude-bedrock-setup.cmd`（`-DryRun` で書かずに内容だけ表示） |
| Bedrock で起動 | `claude-bedrock` |
| 確認 | 起動後に `/status`（プロバイダが Amazon Bedrock、リージョン、モデル） |

### 前提（AWS 側。1アカウントにつき1回）

1. AWS CLI v2 を入れる（例: `winget install Amazon.AWSCLI`）。SSO なら `aws configure sso` でプロファイルを作る。
2. Bedrock のコンソールで、Anthropic のモデルの use case form を提出する（モデルアクセス）。Opus 5.5・Sonnet 5.5・Haiku 5.5 は、アカウントごとの利用可否を Model access で確認する。
3. IAM 権限: `bedrock:InvokeModel`、`bedrock:InvokeModelWithResponseStream`、`bedrock:ListInferenceProfiles`、`bedrock:GetInferenceProfile`（と Marketplace の購読権限）。
4. 認証は IAM Identity Center（SSO）が推奨。アクセスキーや `AWS_BEARER_TOKEN_BEDROCK` は設定ファイルに書かない（プロファイルか環境変数で渡す）。

### 手順

1. SSO なら `aws sso login --profile <プロファイル>`（未ログインでも、スクリプトが SSO を選んでいれば実行する）。
2. `claude-bedrock-setup.cmd` を実行し、順に答える: AWS プロファイル → SSO を使うか → リージョン → 接頭辞 → 一覧から Opus / Sonnet / Haiku に割り当てる推論プロファイル → セッションの既定モデル（既定は `sonnet`）。一覧は `aws bedrock list-inference-profiles` の結果（Anthropic のものだけ）。
3. `claude-bedrock` で起動し、`/status` で確認する。

- **接頭辞**: 空欄なら Claude Code が地域から自動で選ぶ（`ap-*` は `apac.`）。日本国内に閉じたいときは `jp`（東京 `ap-northeast-1`、大阪 `ap-northeast-3` が対応）。地域固定のエンドポイントは Global に対して +10%。
- **非対話**（引数で全部指定。`none` はピン留めしない）: `claude-bedrock-setup.cmd -AwsProfile <名前> -Region ap-northeast-1 -Prefix jp -OpusId <ID> -SonnetId <ID> -HaikuId <ID> -Sso -DryRun`。全部の ID を指定すれば、AWS CLI は要らない。
- **貼り付け用の派生物**: `settings-bedrock.json` と同じ場所に、`env` ブロックを `KEY=VALUE` の行にした `settings-bedrock.txt` も出す（毎回 `.json` と一緒に上書き）。**正は `.json`**。Obsidian の Claudian のスニペットのように、環境変数を文字列で貼る先へ、全文をそのままコピペする（`--settings` で読めないツール用。値の二重管理を、転記だけにする）。`.txt` を直接編集せず、直すときは `claude-bedrock-setup.cmd` を再実行する。
- ピン留めは3つとも決めておく。ピン留めしないと、別名は Claude Code の組み込みの既定に解決される。Opus だけをピン留めすると、バックグラウンド処理にも Opus が使われうる。
- `CLAUDE_CODE_USE_BEDROCK` を共通の `settings.json` に入れない（常に Bedrock 優先になり、OAuth に戻れない）。
- Bedrock では、WebSearch、fast mode、`/logout` は使えない。
- 管理設定（managed settings）が配られている環境では、それが最優先で、`--settings` の値より強い。
- 試験: `pwsh -NoProfile -File tests/windows/test_claude_bedrock_setup.ps1`（偽の `aws` で、一覧の絞り込み、設定の組み立て、非対話の実行を試験）。**実際の AWS での実行は未検証**（このスクリプトを書いた PC に AWS CLI が無かった）。

### Zed（Claude Bedrock）

`agent_servers` の `Claude Bedrock` は、`npx -y @agentclientprotocol/claude-agent-acp` を `env`（`CLAUDE_CODE_USE_BEDROCK`、`AWS_REGION`、`AWS_PROFILE`、`ANTHROPIC_BEDROCK_REGION_PREFIX`、`ANTHROPIC_DEFAULT_*_MODEL`）つきで起動する。秘密は含まない。SSO は事前に `aws sso login` しておく。

### うまくいかないとき（Bedrock）

| 症状 | 確認すること |
|---|---|
| `AWS CLI (aws) が見つかりません` | AWS CLI を入れて新しいターミナルを開く。または全部の ID を引数で渡す |
| `AWS に認証できません` | `aws sso login --profile <名前>`。SSO を使わないなら資格情報（プロファイル）を設定する |
| `Anthropic の推論プロファイルがありません` | リージョンが違う、またはモデルアクセスが未申請 |
| 起動時に `on-demand throughput isn't supported` | ピン留めのモデルを、モデル ID ではなく推論プロファイル ID にする（一覧から選べば正しい） |
| 起動時に別のモデルへ切り替わる | ピン留めしたモデルがアカウントで使えない。一覧から選び直す |
| `claude-bedrock` が見つからない | 新しいターミナルを開く。`profile.ps1` のリンクを確認する |
| `/status` が Bedrock でない | `settings-bedrock.json` の内容と、`ANTHROPIC_API_KEY` などの環境変数の残りを確認する |

## 2. API キー（Console・従量課金）

`claude-api` だけ Anthropic の Console API キーで起動する（`claude` は OAuth のまま）。キーは DPAPI で暗号化して保管し、設定ファイルには書かない。

### 仕組み

| ファイル | 役割 |
|---|---|
| `settings-api.json` | `apiKeyHelper`（キーの取得コマンド）とモデルの環境変数。`%USERPROFILE%\.claude\` にリンクされる |
| `claude-api-key.ps1` / `.cmd` | 暗号化したキーを復号して標準出力に返す。`%USERPROFILE%\.local\bin`（PATH 上）にリンクされる |
| `claude-acp-api.ps1` / `.cmd` | Zed の agent「Claude API」の起動用。キーを復号して `ANTHROPIC_API_KEY` に入れ、`claude-agent-acp` を起動する。空なら止める。同じく `.local\bin` にリンクされる。Zed の `args` に PowerShell のコードを直書きすると変数が空になるので、スクリプトに分けている |
| `windows/powershell/profile.ps1` の関数 `claude-api` | `claude --settings "$HOME\.claude\settings-api.json"` を実行する |
| `%USERPROFILE%\.claude\settings-api-key.dpapi` | 暗号化したキー本体。**リポジトリの外。追跡しない** |

- `apiKeyHelper` は認証の優先順位が OAuth より上。共通の `settings.json` に書くと OAuth に戻れないので、別ファイルにして `--settings` で読ませる。
- `ANTHROPIC_API_KEY` をユーザー環境変数に常設しない（`claude` も API キーになる）。
- 設定ファイルは `${VAR}` 展開ができない前提で、秘密は設定に書かない。

### 秘密情報の保管方法

DPAPI（Windows のユーザーに紐づく暗号化）で `settings-api-key.dpapi` に保存する。追加のモジュールもパスワード入力も要らず、`apiKeyHelper`（非対話）から使える。

- この Windows ユーザー + この PC でだけ復号できる。他の PC では保存し直す。
- 同じユーザーで動く他のプログラムは復号できる。強い分離が要るなら 1Password CLI（`op read`）に変える。
- 保管方法を変えるときは `claude-api-key.ps1` だけを差し替える（`settings-api.json` は変えない）。
- キーを貼るのは `-Set` のプロンプトだけ。コマンドラインに書かない（履歴に残るため）。

| 方法 | 長所 | 短所 |
|---|---|---|
| DPAPI ファイル（採用） | 追加導入なし。非対話で動く | PC ごとに保存し直し。同じユーザーの他プログラムは復号できる |
| SecretManagement + SecretStore | 標準的な方式 | モジュールの導入が要る。既定の設定だとパスワードを聞かれ、非対話のヘルパーが失敗しうる（仮説） |
| 資格情報マネージャー（`cmdkey`） | OS 標準 | `cmdkey` は保存だけで、読み出しに追加の手間がかかる |
| 1Password CLI（`op`） | PC 間で共有でき、最も堅牢 | アカウントと導入が要る（このPCには未導入） |
| 環境変数に常設 | 簡単 | 平文になる。`claude` もキー認証になる |

### 初回の手順

1. **キーを作る**: platform.claude.com の Console で、個人用の workspace を作り、その workspace で API キーを発行する（自動作成される「Claude Code」workspace ではキーを作れない）。
2. **上限を決める**: 下の「費用の上限」を先に設定する。
3. **リンクを張る**: `scripts\windows\30_link.bat -n` で内容を確認し、`scripts\windows\30_link.bat` を実行する（Developer Mode が ON であること）。新しいターミナルを開く。
4. **キーを保存する**: `claude-api-key.cmd -Set` を実行し、プロンプトにキーを貼る。`saved: ...\settings-api-key.dpapi` と出れば成功。
5. **確認する**: `claude-api` を起動して `/status` を実行する。認証が API キーになっていること。`claude` 単独で起動したときは OAuth のままであること。
6. **モデルを決める**: 下の「モデル ID を取得する」で ID を調べ、`settings-api.json` の値を直す。

### Zed（Claude API）

`agent_servers` の `Claude API` は、`command` に `claude-acp-api.cmd` だけを書く。キーの復号と `ANTHROPIC_API_KEY` の設定は、`claude-acp-api.ps1` が行う。

- Zed の `args` に PowerShell のコード（`-Command "..."`）を直書きすると、変数（`$s` など）が空になって失敗する（2026-10-10 に実機で確認。ローカルの pwsh では同じ引数が動く。Zed 側の展開が原因と推測しているが未確認）。コードはスクリプトに置く。
- キーが空のときは `empty API key` で終了する。止めないと、アダプタが黙って OAuth に切り替わる。
- 前提: `30_link.bat` 実行済みで、`claude-api-key.cmd -Set` でキーを保存済みであること。`~\.local\bin` が Zed から見える PATH にあること（見えないときは Zed を再起動する）。

### モデル ID を取得する

Anthropic 直接の `GET /v1/models` を使う（Bedrock の `aws bedrock list-inference-profiles` に相当）。

```powershell
$key = (claude-api-key.cmd) | Select-Object -First 1
$r = Invoke-RestMethod 'https://api.anthropic.com/v1/models?limit=100' -Headers @{ 'x-api-key' = $key; 'anthropic-version' = '2023-06-01' }
$r.data | Select-Object id, display_name, max_input_tokens, max_tokens | Format-Table -AutoSize
$key = $null
```

- `id` を `settings-api.json` の `model` や `ANTHROPIC_DEFAULT_*_MODEL` に入れる。
- `max_input_tokens` がコンテキストの上限（入力）、`max_tokens` が1回の出力の上限。
- `limit=100` を付けないと、既定の件数（20）で切れる。
- 401 が返るときはキーが違う（動作確認では、ダミーのキーで 401 を確認済み）。
- `settings-api.json` の値の意味: `model` は起動時のモデル（`sonnet` などの別名か ID）。`ANTHROPIC_DEFAULT_OPUS_MODEL` / `_SONNET_MODEL` / `_HAIKU_MODEL` は、別名 `opus` `sonnet` `haiku` がどの ID を指すか。優先順位は `--model`、`ANTHROPIC_MODEL`、`model` 設定の順。
- 現在の値（2026-10-08 時点）: `model` は `sonnet`（= `claude-sonnet-5-5`。できるだけ安い Sonnet として決定）。`claude-opus-5-5` と `claude-haiku-4-5` のピン留めも、今のままで決定（2026-10-08）。

### 一覧の見方と選び方

| 列 | 意味 |
|---|---|
| `id` | 設定に書く名前。一覧の表示どおりに書くのが確実（日付つきの `claude-haiku-4-5-20251001` のような ID もそのまま） |
| `display_name` | 人間向けの名前 |
| `max_input_tokens` | 1回に読ませられる量（コンテキスト）。1000000 は100万トークン、200000 は20万 |
| `max_tokens` | 1回の応答で出せる最大の量。128000 は12.8万トークン |

- 名前の数字が大きいほど新しい世代。系統は、Fable が最上位で最高額、Opus が高性能、Sonnet が標準（性能と費用のバランス）、Haiku が軽量で安い。
- 費用の目安（2026-10-08 時点、100万トークンあたりの入力 / 出力）:

| モデル | 入力 / 出力 |
|---|---|
| Haiku 5.5 | $0.10 / $0.50（100k 超のプロンプトは $0.50 / $2.50） |
| Haiku 4.5 | $1 / $5 |
| Sonnet 5.5、Sonnet 5 | $2 / $10 |
| Sonnet 4.6 | $3 / $15 |
| Opus 5.5 | $4 / $20 |
| Opus 5、4.8、4.7、4.6、4.5 | $5 / $25 |
| Fable 5.1、5 | $10 / $50 |

- **できるだけ安い Sonnet は Sonnet 5.5**。Sonnet 5 と同額だが、キャッシュ読み出しが半額（$0.10 と $0.20）で新しい。Sonnet 4.6 は高い。
- さらに節約するなら `/effort` で思考の量を下げる。Haiku 5.5 はさらに安いが、思考を切れない（出力として課金される）ので、1回の作業あたりの費用は実測してから判断する。
- Opus と Haiku のピンは、`/model` で切り替えるときと、軽い処理に使われる（Haiku）ときの割り当て。使わないなら安全側（高額の Opus を避ける）に寄せる。

### 費用の上限

従量課金なので、先に上限を決めてからキーを使う。

- **workspace の spend limit**（最優先）: Console で個人用 workspace に月額の上限を設定する。公式の説明は https://platform.claude.com/docs/en/build-with-claude/workspaces の「Workspace limits」。Console の画面の正確な位置は未確認。
- **レート制限**: 組織の利用ティアで決まる。Console の Limits ページで確認する。
- **セッションの目安**: `/usage` の費用はローカルでの推定で、請求ではない。正確な額は Console の Usage ページを見る。
- **非対話実行（`claude -p`）の上限**: CLI フラグ `--max-budget-usd` がある（`claude --help` か公式の cli-reference で確認する。未検証）。
- **コストを抑える**: 普段は Sonnet、難しい作業だけ Opus（`/model`）。区切りで `/clear`。料金は100万トークンあたり、Opus 5.5 が入力 $4・出力 $20、Sonnet 5.5 が $2・$10、Haiku 4.5 が $1・$5（2026-10-08 時点。最新は https://platform.claude.com/docs/en/about-claude/pricing）。

### 他の PC・運用

- 他の PC: `git pull` → `30_link.bat` → `claude-api-key.cmd -Set`（暗号化ファイルは PC ごと）。
- キーの入れ替え（ローテーション）: Console で新しいキーを作る → `claude-api-key.cmd -Set` で上書き → 古いキーを Console で削除する。
- キーを無効にしたい: Console でキーを削除し、`%USERPROFILE%\.claude\settings-api-key.dpapi` を削除する。
- OAuth に戻したい: 終了して `claude-oauth`（または `claude`）で起動し直す（何も戻す必要はない）。

### うまくいかないとき（API キー）

| 症状 | 確認すること |
|---|---|
| `Your apiKeyHelper script is failing` | `claude-api-key.cmd` を直接実行する。`no key file` ならキー未保存（`-Set`）。10秒を超える場合は警告が出る |
| `claude-api` が見つからない | 新しいターミナルを開く（プロファイルの読み込み）。`profile.ps1` のリンク先を確認する |
| `claude-api-key.cmd` が見つからない | `30_link.bat` 実行後に新しいターミナルを開く。`%USERPROFILE%\.local\bin` が PATH にあること |
| 起動時に `claude.ai connectors are disabled because ANTHROPIC_API_KEY or another auth source is set` | 想定どおりの警告で、失敗ではない。API キー認証では claude.ai のアカウントに紐づく機能（claude.ai の connectors など）が使えない。それらが要る作業は `claude`（OAuth）で行う。`/status` が `Auth token: apiKeyHelper` なら API キー認証で動いている（2026-10-08 に確認） |
| `claude-api` なのに OAuth のまま | `/status` の `Auth token` / `API key` を確認する。`Setting sources` に `Command line arguments` が出ていれば `--settings` は読まれている（2026-10-08 に確認） |
| Zed の「Claude API」が `empty API key` で終了する | `claude-acp-api.cmd` を直接実行して確かめる。リンク（`30_link.bat`）とキーの保存（`-Set`）を確認する。`args` にコードを書いていないこと |
| Zed で `claude-acp-api.cmd` が見つからない | `~\.local\bin` が PATH にあるか確認し、Zed を再起動する。または `command` にフルパスを書く |
| 401 | キーが無効か、貼り間違い。`-Set` で入れ直す |
| モデルが見つからない（404 など） | `GET /v1/models` の一覧にある ID か確認する。キーの workspace に制限が無いか確認する |

## 3. OAuth（サブスク）

普段使いの認証。`claude` を何も設定せずに起動すると OAuth（サブスク）になる。共通の `home/.claude/settings.json` には、`apiKeyHelper` も `CLAUDE_CODE_USE_*` も入れない（入れると OAuth に戻れなくなる）。

| やりたいこと | コマンド |
|---|---|
| OAuth で起動 | `claude` |
| 環境変数が残っていても確実に OAuth で起動 | `claude-oauth` |
| 確認 | 起動後に `/status` |

- `claude-oauth` は、`ANTHROPIC_API_KEY`、`ANTHROPIC_AUTH_TOKEN`、`CLAUDE_CODE_USE_BEDROCK`（と `_MANTLE` `_VERTEX` `_FOUNDRY`）が環境に残っていても、その起動の間だけ外す（終了後に元へ戻す）。
- ログイン情報（`.credentials.json`）は、`claude-api` や `claude-bedrock` を使っても消えない。何も戻さずに `claude-oauth` で戻れる。
- OAuth では claude.ai のアカウントに紐づく機能（claude.ai の connectors など）が使える。それらが要る作業は OAuth で行う。
- Zed では `claude-acp`（レジストリ版）が OAuth で動く。`agent_servers` の `default_config_options` で、モードを `auto`、モデルを `sonnet` にしている。

### うまくいかないとき（OAuth）

| 症状 | 確認すること |
|---|---|
| `claude` なのに API キーや Bedrock になる | 環境変数の残りを確認する（下の診断）。急ぐなら `claude-oauth` で起動する |
| ログインを求められる | `claude` を起動してログインし直す。`claude-api` / `claude-bedrock` を使っただけでは、ログイン情報は消えない |

`claude` なのに OAuth にならないときの診断（値は出さず、名前と長さだけ見る）:

```powershell
Get-ChildItem Env: | Where-Object Name -match '^(ANTHROPIC_|CLAUDE_CODE_USE_|CLAUDE_CODE_OAUTH|AWS_BEARER)' | ForEach-Object { '{0} (length {1})' -f $_.Name, $_.Value.Length }
```

設定側は、ユーザー設定とプロジェクト設定に `apiKeyHelper`、`ANTHROPIC_API_KEY`、`CLAUDE_CODE_USE_*` が無いかを見る。
