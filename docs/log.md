# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## Next Actions

- 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（案の段階）。
- `docs/setup/debian-family.md` に付いていた「dotfiles 側の課題」のうち、未対応だったもの（移動時に付録を消してここへ移した。現状は未確認）: (1) `chsh` 後の再ログインの案内が `30_link.sh` の出力に無い、(2) `50_repos.sh` は `source ~/.profile` と、`ghq` が PATH にあることが前提、(3) MX Linux の実機で `20_packages.sh` / `23_ja.sh` を通した確認が未了（WSL の Ubuntu 24.04 では構文チェックと `30_link.sh -n` まで）。
- 手順書の移動（`docs/setup/`）の後始末: 他 PC での `docs/setup/` のリンク確認。workbase 側の手順は resources の `topics/dotfiles-boundary/`（進捗はそのトピックの `docs/log.md` が正本）。

## Open Questions

なし。
