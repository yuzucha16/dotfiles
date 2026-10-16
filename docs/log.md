# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## Next Actions

- 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（案の段階）。
- resources の `topics/dotfiles-boundary/` が、手順書3本を dotfiles の `docs/setup/` へ移す案を持つ（2026-10-16 時点で未着手。dotfiles に `docs/setup/` は無い）。進捗はそのトピックの `docs/log.md` が正本。
- 上に無い古い確認項目（スレッド復元の後始末、Zed 以外の実機確認、履歴の種、`10_env.bat` の再実行、VC++ ランタイムの `[WARN]`、Linux の通し実行など）は、`log-history.md` の 2026-10-16 の項にある。

## Open Questions

- `windows/notepadpp/Gruvbox dark medium.xml` の改行（index が CRLF）を LF にそろえるか。Notepad++ が保存時に CRLF へ書き直すかが未確認。
- 古い Open Questions（`.wslconfig`、既定ブランチ、細かい設定の確認など）は、`log-history.md` の 2026-10-16 の項にある。
