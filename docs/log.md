# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。定例は実行したら次回の期日に書き換える。書式は resources の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| 2026-10-22 頃 | 単発 | colored-tags の `data.json` を追跡から外す試用の判断（根拠は `decisions.md` の先頭の項）。他PCは `git pull` の前に `data.json` の未コミットの変更を退避する | ユーザー |

## Next Actions

- 未 push のコミットを push する（ユーザー。dotfiles は許可リスト外）: `cc20299` `71e326d` `000125e` `a404711` `293c0a3`。あわせて resources の `9c87f10` `2156d92` `2a35149` `3cdeeb1` `286d714`。追加（2026-10-16 の依存の整理）: dotfiles `3ed784e` `2ef40d4`、resources `6d8f427` `b50bab2`。
- README を分割した（2026-10-16。34.8KB → 16KB）。詳細は `scripts/windows/README.md` `scripts/linux/README.md` `tests/README.md` `windows/README.md`。`windows/README.md` の末尾の空行を直す。resources の `topics/dotfiles-boundary/` の `docs/setup/` の案と、置き場の整合を確認する。

他PCでは `git pull` のあと、`30_link.bat`（Linux/WSL は `30_link.sh`）を再実行してから、次を確認する。

- obsidian-skills と defuddle / knap の他PCへの展開: `27_volta.bat` → `28_npm_globals.bat` → `29_claude_plugins.bat`。`knap --version` と `/skills` で確認する。`knap` は試用（不要なら `manifests/npm.txt` の2行を消して `volta uninstall knap`）。
- 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（案の段階）。
- Claudian の入力欄パッチの試用（2026-10-12）: Enter の挙動と見た目を確認する。続けるなら、プラグイン更新で `main.js` が上書きされるため、当て直し手順を残す。
- Claude Code の設定ファイル改名（2026-10-11）の移行: `30_link.bat` の再実行、旧 `api.settings.json` `bedrock.settings.json` の削除、`api-key.dpapi` を `settings-api-key.dpapi` に改名。`claude-api` と `claude-bedrock` の起動を確認する。
- Claude 用の AWS profile `n1-trial` の作成と、`claude-bedrock-setup.cmd -AwsProfile n1-trial` の実行。`settings-bedrock.txt` の全文を Claudian の Bedrock スニペットへ貼れるかも確認する（Bedrock の実機は未確認）。
- AWS CLI・uv・Volta のインストーラ（`25_awscli.bat` `26_uv.bat` `27_volta.bat`）を実機で確認する。`ca_bundle.crt` を置いた PC では `setx` の値も見る。
- 会社 PC で git の schannel: `git -c http.sslBackend=schannel ls-remote https://github.com/yuzucha16/dotfiles HEAD`。`CRYPT_E_NO_REVOCATION_CHECK` が出たら `schannelCheckRevoke = false`。
- Windows Terminal の WSL プロファイル（2026-10-14）: Terminal を開き、メニューが PowerShell・CMD・Ubuntu-24.04 で `settings.json` に差分が出ないことを確認する。
- `.reg` / `.ahk` と Terminal の `settings.json` の `git status` が clean か確認する（`.gitattributes` の変更の後。差分が出たら `git add --renormalize`）。
- 上に無い古い確認項目（スレッド復元の後始末、Zed 以外の実機確認、履歴の種、`10_env.bat` の再実行、VC++ ランタイムの `[WARN]`、Linux の通し実行など）は、`log-history.md` の 2026-10-16 の項にある。

## Open Questions

- dotfiles のリポジトリの公開・非公開（未定。2026-10-06 時点は非公開）。決まったら、README のクイックスタートと、workbase の手順書 `win11.md`・`debian-family.md` の使わない方の記述を削除する。
- 「`ListView` は重い可能性があるが見送り」（`decisions.md` のシェルの項）と、`profile.ps1:19` が `ListView` を設定していることが食い違う。見送りを撤回したのか未確認。
- `windows/notepadpp/Gruvbox dark medium.xml` の改行（index が CRLF）を LF にそろえるか。Notepad++ が保存時に CRLF へ書き直すかが未確認。
- 古い Open Questions（`.wslconfig`、既定ブランチ、細かい設定の確認など）は、`log-history.md` の 2026-10-16 の項にある。
