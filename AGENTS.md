# AGENTS.md

dotfiles は、Windows 11 + WSL2 / Linux（apt 系）の作業環境を、複数PC（家・会社）で同じ状態に再現するための設定とセットアップスクリプト。

## 共通ルール

共通ルールの置き場は `$HOME\works\resources\workflow-kit`（WSL: `/mnt/c/Users/<Windows のユーザー名>/works/resources/workflow-kit`）。ユーザーが合言葉（手順書を呼ぶ短い言葉。日本語の別名つき）を言ったら、そこの `hooks.md` の表に従って手順書を読み、実行する。`docs-rules.md` は、`docs/` を更新するときと、コミット・push の前に読む。

読めない場合（`workbase` を clone していない PC など）は、記憶で代用せず、ユーザーに伝えて止まる。

## 読む順番

1. `README.md`（窓口。構成と使い方。16KB 目安なので、見出しの一覧を先に見て、必要な節だけ読んでもよい。詳細は下位の `README.md`）
2. `docs/log.md`（開始時に読むのはここまで。「期日」の節があれば、今日以前または3日以内の項目を、最初の返答で知らせて判断を求める）
3. `docs/decisions.md` と `docs/log-history.md` は開始時に読まない。何かを決める・変える前に `decisions.md` を検索する。経緯が要るときは `log-history.md` を検索する。

下位の単位の「<名前> の続き」は、kit の `docs-rules.md` の「上の階層で起動して…」に従う。

## このリポジトリ固有のルール

- 構成やスクリプトの使い方は `README.md` が正本。`docs/` に同じ表を重複させない。
- exmem は `$HOME\works\resources\exmem`（WSL: `/mnt/c/Users/<Windows のユーザー名>/works/resources/exmem`）。共有リポジトリ `workbase`（`$HOME\works\resources` に clone）の一部で、dotfiles とは別リポジトリ。dotfiles は exmem を**基本は読み取り専用で参照するだけ**。作業ログを exmem に残さない。書き込みの例外は「ナレッジ化して」だけ（`lessons/` など inbox 以外は編集しない）。
- 参照している正本: 履歴の種の本文は `exmem/lessons/shell-command-usecases.md`。`windows/powershell/history.seed.txt` と `manifests/history.seed.sh.txt` はそこからの派生物なので、種ファイルを直接編集しない。
- 「ナレッジ化して」で残さないもの（dotfiles 固有で他に使い回せない経緯）は、`docs/log.md` と `docs/decisions.md` に残す。
- `scripts/linux/` や `home/.profile` を変えたら、`bash tests/linux/test_scripts.sh` を実行して、失敗が0であることを確認する（WSL で実行できる。観点は `tests/README.md`）。

## コミット

- メッセージは `[対象] 内容`（例: `[shell] ...`, `[scripts] ...`, `[docs] ...`）。
- `git add` はパスを指定する（パスなしの `git add -A` と `git add .` は使わない。`tmp/` などを拾うため）。
- コミット・push の前に、kit の `docs-rules.md` の「コミットと push」を、そのセッションで読んでいなければ読む（身元・トレーラー・機密の検索もそこに従う）。
- push はユーザーが行う（許可リストなし）。禁止のコマンド（`--force` など）は、kit の `docs-rules.md` の「しないこと」に従う（`settings.json` の deny が機械的に止める。rebase は 2026-10-16 ユーザーの決定で禁止）。
- merge の前に、双方のコミット日時（`git log --format='%h %ad %s' --date=iso`）を比べ、どちらが新しいかをユーザーに伝えて、順序でよいか確認する。
- リスクや制約が生まれる変更は、事前にユーザーへ確認する。
