# docs/setup: セットアップ手順書

新しい PC を、スクリプトの前後の手作業を含めて立ち上げるための手順書。2026-10-16 に、共有リポジトリ `workbase` の `guides/howto/` から移した（経緯と線は `workbase` の `topics/dotfiles-boundary/`）。

| ファイル | 内容 |
|---|---|
| [win11.md](win11.md) | Windows 11 の導入から `scripts/windows/` の実行まで |
| [debian-family.md](debian-family.md) | Debian 系 Linux（MX / Ubuntu / Mint）の導入から `scripts/linux/` の実行まで |
| [fonts-setup.md](fonts-setup.md) | `24_fonts.*` の前後の手動作業 |

構成やスクリプトの使い方は、ルートの `README.md` が正本。手順書は、その前後の手作業と順序・注意点だけを書く。

## 手順書を書く・直すとき

構成、各章の書式、対応バージョン表、事実の扱い、文体、ファイルの分け方は、`workbase` の `guides/AGENTS.md` の「手順書(howto/)の作り方」に従う（`$HOME\works\resources\guides\AGENTS.md`。ここに写さない）。このリポジトリでは、次の点が違う。

- 自動化できる作業は、このリポジトリのスクリプトが**正**。手順書にスクリプトの中身（パッケージ一覧など）を写さず、`scripts/` と `manifests/` を指す。
- 手順書とスクリプトの食い違いが見つかったら、同じ作業で直す。スクリプトの変更が要るときは、ユーザーの承認を得てから行う。直せないものは `docs/log.md` の Next Actions に書く。手順書の末尾に付録は作らない。
- 新しい手順書を作るときは、先に `scripts/`・`manifests/`・ルートの `README.md` を読む。同じ系統の手順書があれば、新しいファイルでなく差分表に列を足せないかを検討する。
- このリポジトリは公開。個人情報（メール、アカウント名、社内ホスト名）、秘密情報、ユーザー名を含むパスは書かない（`%USERPROFILE%`、`$HOME`、`<name>` に置き換える）。git のユーザー名・メールは、`~/.gitconfig_local` に置く、と書く。
