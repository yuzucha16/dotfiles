# Claude Code の API キー認証（個人用）

`claude` は OAuth（サブスク）のまま、`claude-api` だけ Anthropic の Console API キー（従量課金）で起動する。判断の根拠は `docs/decisions.md` の「Claude Code の API キー認証は…」。

ブラウザで見るときは `README.html`（この md を写した派生物。手順のチェックボックスとコピーボタンつき）。内容を直すときは、この md を先に直し、HTML も合わせる。

## 早見表

| やりたいこと | コマンド |
|---|---|
| OAuth で起動 | `claude` |
| API キーで起動 | `claude-api` |
| 認証・モデルの確認 | 起動後に `/status` |
| キーを保存・入れ替え | `claude-api-key.cmd -Set` |
| モデル ID の一覧 | 下の「モデル ID を取得する」 |
| モデルの切替（セッション中） | `/model` |
| 費用の目安（セッション） | `/usage` |

## 仕組み

| ファイル | 役割 |
|---|---|
| `api.settings.json` | `apiKeyHelper`（キーの取得コマンド）とモデルの環境変数。`%USERPROFILE%\.claude\` にリンクされる |
| `claude-api-key.ps1` / `.cmd` | 暗号化したキーを復号して標準出力に返す。`%USERPROFILE%\.local\bin`（PATH 上）にリンクされる |
| `windows/powershell/profile.ps1` の関数 `claude-api` | `claude --settings "$HOME\.claude\api.settings.json"` を実行する |
| `%USERPROFILE%\.claude\api-key.dpapi` | 暗号化したキー本体。**リポジトリの外。追跡しない** |

- `apiKeyHelper` は認証の優先順位が OAuth より上。共通の `settings.json` に書くと OAuth に戻れないので、別ファイルにして `--settings` で読ませる。
- `ANTHROPIC_API_KEY` をユーザー環境変数に常設しない（`claude` も API キーになる）。
- 設定ファイルは `${VAR}` 展開ができない前提で、秘密は設定に書かない。

## 秘密情報の保管方法

DPAPI（Windows のユーザーに紐づく暗号化）で `api-key.dpapi` に保存する。追加のモジュールもパスワード入力も要らず、`apiKeyHelper`（非対話）から使える。

- この Windows ユーザー + この PC でだけ復号できる。他の PC では保存し直す。
- 同じユーザーで動く他のプログラムは復号できる。強い分離が要るなら 1Password CLI（`op read`）に変える。
- 保管方法を変えるときは `claude-api-key.ps1` だけを差し替える（`api.settings.json` は変えない）。
- キーを貼るのは `-Set` のプロンプトだけ。コマンドラインに書かない（履歴に残るため）。

| 方法 | 長所 | 短所 |
|---|---|---|
| DPAPI ファイル（採用） | 追加導入なし。非対話で動く | PC ごとに保存し直し。同じユーザーの他プログラムは復号できる |
| SecretManagement + SecretStore | 標準的な方式 | モジュールの導入が要る。既定の設定だとパスワードを聞かれ、非対話のヘルパーが失敗しうる（仮説） |
| 資格情報マネージャー（`cmdkey`） | OS 標準 | `cmdkey` は保存だけで、読み出しに追加の手間がかかる |
| 1Password CLI（`op`） | PC 間で共有でき、最も堅牢 | アカウントと導入が要る（このPCには未導入） |
| 環境変数に常設 | 簡単 | 平文になる。`claude` もキー認証になる |

## 初回の手順

1. **キーを作る**: platform.claude.com の Console で、個人用の workspace を作り、その workspace で API キーを発行する（自動作成される「Claude Code」workspace ではキーを作れない）。
2. **上限を決める**: 下の「費用の上限」を先に設定する。
3. **リンクを張る**: `scripts\windows\30_link.bat -n` で内容を確認し、`scripts\windows\30_link.bat` を実行する（Developer Mode が ON であること）。新しいターミナルを開く。
4. **キーを保存する**: `claude-api-key.cmd -Set` を実行し、プロンプトにキーを貼る。`saved: ...\api-key.dpapi` と出れば成功。
5. **確認する**: `claude-api` を起動して `/status` を実行する。認証が API キーになっていること。`claude` 単独で起動したときは OAuth のままであること。
6. **モデルを決める**: 下の「モデル ID を取得する」で ID を調べ、`api.settings.json` の値を直す。

## モデル ID を取得する

Anthropic 直接の `GET /v1/models` を使う（Bedrock の `aws bedrock list-inference-profiles` に相当）。

```powershell
$key = (claude-api-key.cmd) | Select-Object -First 1
$r = Invoke-RestMethod 'https://api.anthropic.com/v1/models?limit=100' -Headers @{ 'x-api-key' = $key; 'anthropic-version' = '2023-06-01' }
$r.data | Select-Object id, display_name, max_input_tokens, max_tokens | Format-Table -AutoSize
$key = $null
```

- `id` を `api.settings.json` の `model` や `ANTHROPIC_DEFAULT_*_MODEL` に入れる。
- `max_input_tokens` がコンテキストの上限（入力）、`max_tokens` が1回の出力の上限。
- `limit=100` を付けないと、既定の件数（20）で切れる。
- 401 が返るときはキーが違う（動作確認では、ダミーのキーで 401 を確認済み）。
- `api.settings.json` の値の意味: `model` は起動時のモデル（`sonnet` などの別名か ID）。`ANTHROPIC_DEFAULT_OPUS_MODEL` / `_SONNET_MODEL` / `_HAIKU_MODEL` は、別名 `opus` `sonnet` `haiku` がどの ID を指すか。優先順位は `--model`、`ANTHROPIC_MODEL`、`model` 設定の順。
- 現在の値（2026-10-08 時点）: `model` は `sonnet`（= `claude-sonnet-5-5`。できるだけ安い Sonnet として決定）。`claude-opus-5-5` と `claude-haiku-4-5` のピン留めも、今のままで決定（2026-10-08）。

## 一覧の見方と選び方

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

## 費用の上限

従量課金なので、先に上限を決めてからキーを使う。

- **workspace の spend limit**（最優先）: Console で個人用 workspace に月額の上限を設定する。公式の説明は https://platform.claude.com/docs/en/build-with-claude/workspaces の「Workspace limits」。Console の画面の正確な位置は未確認。
- **レート制限**: 組織の利用ティアで決まる。Console の Limits ページで確認する。
- **セッションの目安**: `/usage` の費用はローカルでの推定で、請求ではない。正確な額は Console の Usage ページを見る。
- **非対話実行（`claude -p`）の上限**: CLI フラグ `--max-budget-usd` がある（`claude --help` か公式の cli-reference で確認する。未検証）。
- **コストを抑える**: 普段は Sonnet、難しい作業だけ Opus（`/model`）。区切りで `/clear`。料金は100万トークンあたり、Opus 5.5 が入力 $4・出力 $20、Sonnet 5.5 が $2・$10、Haiku 4.5 が $1・$5（2026-10-08 時点。最新は https://platform.claude.com/docs/en/about-claude/pricing）。

## 他の PC・運用

- 他の PC: `git pull` → `30_link.bat` → `claude-api-key.cmd -Set`（暗号化ファイルは PC ごと）。
- キーの入れ替え（ローテーション）: Console で新しいキーを作る → `claude-api-key.cmd -Set` で上書き → 古いキーを Console で削除する。
- キーを無効にしたい: Console でキーを削除し、`%USERPROFILE%\.claude\api-key.dpapi` を削除する。
- OAuth に戻したい: `claude` で起動する（何も戻す必要はない）。

## うまくいかないとき

| 症状 | 確認すること |
|---|---|
| `Your apiKeyHelper script is failing` | `claude-api-key.cmd` を直接実行する。`no key file` ならキー未保存（`-Set`）。10秒を超える場合は警告が出る |
| `claude-api` が見つからない | 新しいターミナルを開く（プロファイルの読み込み）。`profile.ps1` のリンク先を確認する |
| `claude-api-key.cmd` が見つからない | `30_link.bat` 実行後に新しいターミナルを開く。`%USERPROFILE%\.local\bin` が PATH にあること |
| 起動時に `claude.ai connectors are disabled because ANTHROPIC_API_KEY or another auth source is set` | 想定どおりの警告で、失敗ではない。API キー認証では claude.ai のアカウントに紐づく機能（claude.ai の connectors など）が使えない。それらが要る作業は `claude`（OAuth）で行う。`/status` が `Auth token: apiKeyHelper` なら API キー認証で動いている（2026-10-08 に確認） |
| `claude-api` なのに OAuth のまま | `/status` の `Auth token` / `API key` を確認する。`Setting sources` に `Command line arguments` が出ていれば `--settings` は読まれている（2026-10-08 に確認） |
| `claude` なのに API キーになる | 環境変数 `ANTHROPIC_API_KEY` が残っていないか確認する（`$env:ANTHROPIC_API_KEY`） |
| 401 | キーが無効か、貼り間違い。`-Set` で入れ直す |
| モデルが見つからない（404 など） | `GET /v1/models` の一覧にある ID か確認する。キーの workspace に制限が無いか確認する |
