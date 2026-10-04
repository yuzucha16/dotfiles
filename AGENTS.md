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
- dotfiles は exmem を**基本は読み取り専用で参照するだけ**。作業ログを exmem に残さない。
- **書き込みの唯一の例外**: ユーザーが「ナレッジ化して」と指示したときだけ、`exmem/inbox/` に新規ファイルを1つ置く（下の「ナレッジ化して」）。`knowledge/` `contexts/` など inbox 以外は編集しない。inbox のメモを `knowledge/` へ統合するのは exmem 側の運用（`exmem/AGENTS.md`）で、ここでは行わない。
- 参照している正本: 履歴の種の本文は `exmem/knowledge/shell-command-usecases.md`。`windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt` はそこからの派生物なので、種ファイルを直接編集しない。

## 「ナレッジ化して」

dotfiles の作業で得た、次回以降も使える知識を exmem に残すためのフック。ユーザーが「ナレッジ化して」と言ったときだけ実行する（自発的には書かない）。

1. これまでの会話から、知識・ルール・経験を抜き出す。作業ログ（何をいつやったか）は対象外で、それは `docs/log.md` と `docs/decisions.md` に残す。dotfiles 固有の経緯で他に使い回せないものも `docs/` に置く。
2. 該当する知識が無ければ、ファイルは作らず「ナレッジ無し」と答える。
3. あれば、`C:\vault\notes\resources\exmem\inbox\YYYY-MM-DD-<topic>.md`（WSL: `/mnt/c/vault/notes/resources/exmem/inbox/`）に新規作成する。`<topic>` は英小文字の kebab-case。同名のファイルがあれば上書きせず、別の名前にする。
4. 書くのは inbox の1ファイルだけ。`notes` リポジトリのコミット・push はしない（ユーザーが行う）。
5. 会社名・ユーザー名・URL の秘匿値・トークンなど、共有したくない値は書かない（`notes` は共有リポジトリ）。確認していないことは「仮説」と明記する。
6. 日付は今日の日付。`sources` の `<AIサービス名>` は実行中のAI（Claude Code なら `Claude Code`）。

ファイルの形式（見出しは省略しない。該当が無い見出しは「なし」と書く）:

````markdown
---
type: inbox
title: <テーマ>
created: <今日の日付 YYYY-MM-DD>
sources:
  - <このAIサービス名> conversation
---

# <テーマ>

## Goal
この会話で何を考えたかったか。

## Decisions
決めたこと。それぞれに根拠と、検討して捨てた案を書く。

## Facts
確認できた事実。未確認のものは「仮説」と明記する。

## Gotchas
遭遇したエラーや詰まった点と、その解決方法。

## Open Questions
まだ決まっていないこと。

## Next Actions
次にやること。
````

## コミット

- メッセージは `[対象] 内容`（例: `[shell] ...`, `[scripts] ...`, `[docs] ...`）。
- `git add` はパスを指定する（`git add -A` は `tmp/` などを拾う）。
- リスクや制約が生まれる変更は、事前にユーザーへ確認する。
