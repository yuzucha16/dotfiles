# AGENTS.md

dotfiles は、Windows 11 + WSL2 / Linux（apt 系）の作業環境を、複数PC（家・会社）で同じ状態に再現するための設定とセットアップスクリプト。

## 読む順番

1. `docs/log.md`: 現在の状態と Next Actions。作業を再開するときの入口。
2. `README.md`: 構成、スクリプトの命名規則、セットアップ手順、日常の運用（How）。
3. `docs/decisions.md`: 判断の根拠、却下案、Gotchas、実機で確認した事実（Why）。

## 記録の置き場

dotfiles の作業の経緯・決定・次にやることは、すべてこのリポジトリの `docs/` に残す。

- 作業の終わりに、`docs/log.md` の Next Actions を更新し、Log に日付つきで追記する。
- 判断（決めたこと・根拠・却下案）、遭遇した詰まり、実機で確認した事実は `docs/decisions.md` に書く。
- 構成やスクリプトの使い方は `README.md` が正本。`docs/` に同じ表を重複させない。

## exmem（外部メモリ）との関係

- exmem はAIとの壁打ちから得たナレッジの置き場。場所は `C:\vault\notes\resources\exmem`（WSL: `/mnt/c/vault/notes/resources/exmem`）。`notes` リポジトリの一部で、dotfiles とは別リポジトリ。
- dotfiles は exmem を**読み取り専用で参照するだけ**。**exmem には書き込まない**。作業ログを exmem に残さない。
- ナレッジとして育てたい内容は、ユーザーが壁打ちを経由して exmem に入れる。エージェントは exmem を編集しない。
- 参照している正本: 履歴の種の本文は `exmem/knowledge/shell-command-usecases.md`。`windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt` はそこからの派生物なので、種ファイルを直接編集しない。

## コミット

- メッセージは `[対象] 内容`（例: `[shell] ...`, `[scripts] ...`, `[docs] ...`）。
- `git add` はパスを指定する（`git add -A` は `tmp/` などを拾う）。
- リスクや制約が生まれる変更は、事前にユーザーへ確認する。
