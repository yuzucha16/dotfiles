# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

- pwsh の starship 設定を、この PC で有効にする: `scripts\windows\30_link.bat` を実行して `~/.config/starship-pwsh.toml` のリンクを作り、Windows Terminal の新しいタブで待ち時間とブランチ名の表示を確認する（元の PC では約 2,200ms から約 230ms）。あわせて、起動の短縮（shim の迂回、init のキャッシュ）で、起動が速くなったか、`ls`、`z`、複数行入力が従来どおり動くかを確認する。
- 【起票 10-29】部屋からゲートウェイで Claude を使う `room start <Project> --gateway`（workbase の `workflow-kit/room/room.py`。コミット済み）を、実機の部屋で確かめる（別セッション）。見るもの: `/status` が Anthropic base URL＝ゲートウェイ、認証＝`apiKeyHelper`。約50分後も接続が続く（トークンの置き換え）。終了後に部屋の `~/.claude-gateway/token` が消える。決定は `decisions.md` の「部屋（専用 WSL）からの利用」。
- 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（案の段階）。

## Open Questions

- なし。
