# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

- 【起票 11-02】Obsidian の 2 Vault 化の動作確認（Windows の実機。別セッション）: `30_link.bat` で、(a) `uv` `py` `python` のどれでも `obsidian_sync.py` が走る、(b) `%WORKS_DIR%\.obsidian` と `%WORKS_DIR%\resources\.obsidian` の 2 本のジャンクションができる、(c) `%WORKS_DIR%\resources` が無いときは `[SKIP]` で `resources\` を作らない、(d) 旧 `%WORKS_DIR%\.obsidian`（旧 `windows\obsidian\.obsidian` へのジャンクション）は上書きされる、(e) 両方の Vault が開き、works の検索から `resources/` が外れる。`30_link.bat` の新しい分岐は未確認（11-02 にユーザーが works で `resources` `resources_p` `repos` がエクスプローラーから消えたと報告したので、(a)(b)(e) の大半は動いたと見てよい。(c)(d) と `uv` なしの経路が残り）。11-02 に `30_link.bat` へ `noparent2`（Claudian の resources 側の symlink 用）を足した。clone 前に `resources` が無いとき `[SKIP]` になるかも、(c) と一緒に確かめる（実機で symlink が張れたことは確認済み）。

- 別のPCで `10_env.bat` を実行し、新しいターミナルで `$env:WFKIT_DIR` が設定されること、Tab 補完で `$env:WFKIT_DIR` が実パスに変わらないこと（`profile.ps1` の Tab ハンドラ）を確かめる（2026-10-30 起票。この PC では動作確認済み）。

- 【起票 10-30】`room-myenv` に dotfiles のシェル環境を入れる案 B（案 A は同日に手で実施。starship と履歴の種のみ）: zsh・fzf・zoxide・lsd・bat・fd・zsh-autosuggestions を root で入れ、`home/` の `.zshrc` `.bashrc` `common.sh` などを標準入力で送る。`room.py` のサブコマンド（workbase 側）か、dotfiles 側の送る `.ps1` かは未定。`~/.bashrc` は `room.py` と uv が追記するので、上書きせず追記で済ませる。stow と dotfiles リポジトリの持ち込みはしない（部屋は `/mnt/c` が空）。

## Open Questions

- `scoop update` で、同梱の Markdown 用 UDL（`markdown._preinstalled_DM.udl.xml`）が実ファイルに戻り、`markdown.udl.xml` へのリンクが外れるか。戻ったら手で削除して `30_link.bat` をやり直す（2026-10-30 起票。未確認）。他の PC でも、最初は同梱の UDL を手で削除してから `30_link.bat` を実行する。
なし