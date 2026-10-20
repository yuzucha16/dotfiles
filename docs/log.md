# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## Next Actions

- pwsh の starship 設定を、この PC で有効にする: `scripts\windows\30_link.bat` を実行して `~/.config/starship-pwsh.toml` のリンクを作り、Windows Terminal の新しいタブで待ち時間とブランチ名の表示を確認する（元の PC では約 2,200ms から約 230ms）。あわせて、起動の短縮（shim の迂回、init のキャッシュ）で、起動が速くなったか、`ls`、`z`、複数行入力が従来どおり動くかを確認する。
- 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（案の段階）。

## Open Questions

- なし。
