# AGENTS.md

dotfiles は、Windows 11 + WSL2 / Linux（apt 系）の作業環境を、複数PC（家・会社）で同じ状態に再現するための設定とセットアップスクリプト。

## 共通ルール

共通ルールの置き場は `C:\vault\notes\resources\workflow-kit`（WSL: `/mnt/c/vault/notes/resources/workflow-kit`）。次の時機に、該当のファイルを読む。

- `docs-rules.md`: 作業を始める前と、`docs/` を更新するときに読む。`docs/` の運用。作業の終わりに `docs/log.md` と `docs/decisions.md` を更新する。
- `knowledge-hook.md`: ユーザーが「ナレッジ化して」と言ったときに読み、実行する（言われたときだけ）。書き込みは `exmem/inbox/` の新規ファイルだけ。

上のファイルが読めない場合（`notes` が無いPCなど）は、記憶で代用せず、ユーザーに伝えて止まる。

## 読む順番

1. `docs/log.md`: 現在の状態と Next Actions。作業を再開するときの入口。
2. `README.md`: 構成、スクリプトの命名規則、セットアップ手順、日常の運用（How）。
3. `docs/decisions.md`: 判断の根拠、却下案、Gotchas、実機で確認した事実（Why）。

## このリポジトリ固有のルール

- 構成やスクリプトの使い方は `README.md` が正本。`docs/` に同じ表を重複させない。
- exmem は `C:\vault\notes\resources\exmem`（WSL: `/mnt/c/vault/notes/resources/exmem`）。`notes` リポジトリの一部で、dotfiles とは別リポジトリ。dotfiles は exmem を**基本は読み取り専用で参照するだけ**。作業ログを exmem に残さない。書き込みの例外は「ナレッジ化して」だけ（`knowledge/` `contexts/` など inbox 以外は編集しない）。
- 参照している正本: 履歴の種の本文は `exmem/knowledge/shell-command-usecases.md`。`windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt` はそこからの派生物なので、種ファイルを直接編集しない。
- 「ナレッジ化して」で残さないもの（dotfiles 固有で他に使い回せない経緯）は、`docs/log.md` と `docs/decisions.md` に残す。

## コミット

- メッセージは `[対象] 内容`（例: `[shell] ...`, `[scripts] ...`, `[docs] ...`）。
- `git add` はパスを指定する（`git add -A` は `tmp/` などを拾う）。
- リスクや制約が生まれる変更は、事前にユーザーへ確認する。
