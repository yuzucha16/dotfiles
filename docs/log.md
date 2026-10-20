# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## Next Actions

- 外部スキルを取り込む前に、配布元と `SKILL.md` を確認する運用にするか決める（案の段階）。
- `claude-gateway` と Zed の「Claude Gateway」で、サインインの約1時間後に `apiKeyHelper` の無音更新が働くかを確認する（2026-10-20 時点。接続自体は両方で確認済み）。
- 他の PC で、`30_link.bat` を実行して `claude-gateway-*` / `claude-acp-gateway` のリンクを張り、`claude-gateway-setup.cmd` → `claude-gateway-token.cmd -Login` を行う（PC ごとの設定と暗号化したトークンは追跡しない）。

## Open Questions

- 提案（AI。未承認）: `.cmd` の `pause` は、対話専用の入口（`claude-gateway-setup.cmd` と、`claude-gateway-token.cmd -Login`）だけに入れ、`apiKeyHelper` として呼ばれる経路と Zed の起動用（`claude-acp-gateway.cmd`）には入れない。ユーザーは `.bat` 全般に `pause` を入れる規則を求めたが、規則の対象は `scripts\windows\*.bat` で、ヘルパーに入れると待ち続けて出力も壊れることを実測したため、範囲を絞った（`decisions.md` の組織の LLM ゲートウェイの項）。
- 提案（AI。未承認）: ゲートウェイ用の設定を `CLAUDE_CONFIG_DIR`（`~/.claude-gateway`）に分けた構成は動作確認済み。ただし `~/.claude` の共通設定（permissions、hooks、`CLAUDE.md`）が効かない。引き継ぎ方（コピー、リンク、足す項目の選別）を決める。
- `claude-bedrock-setup.ps1` にもともとある `-Sso`（IAM Identity Center 用の `awsAuthRefresh`）と試験は残している。今回の AWS SSO の追加は取り消したが、この既存の機能も不要なら外す。
