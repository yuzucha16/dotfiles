# tests

スクリプトの試験の詳細。要点は、リポジトリ直下の `README.md`。下は 2026-10-16 に README から移した原文。

## スクリプトの試験（WSL / Linux）

`bash tests/linux/test_scripts.sh` で、`scripts/linux/*.sh` と `home/.profile` を試験する（終了コード = 失敗数。60項目）。`scripts/linux/` や `home/.profile` を変えたら実行する。

- 一時ディレクトリと偽の HOME だけを使い、実環境の `~` は変更しない。ネットワークも使わない（`ghq` は偽物、clone 元はローカルの bare リポジトリ）。
- WSL とネイティブ Linux の分岐は、環境変数 `PROC_VERSION_FILE`（`/proc/version` の差し替え）で強制する。どちらの環境でも、両方の分岐を試験できる。実環境を見る項目は、WSL でないとき等は skip する。
- 観点: 構文と改行コード、`WORKS_DIR` の分岐、`clone_workbase`（新規・skip・非空のディレクトリ・空のディレクトリ）、`link_obsidian`（dry-run・再リンク・unlink・実体があれば `[ERR]`・リンク切れ・元が無い）、`30_link.sh` の通し、`50_repos.sh`、`11_git_identity.sh`（新規・skip・空入力・`@` なし・特殊文字・入力が閉じている・git なし）、`24_fonts.sh`（偽の `gh` で、成功・1件失敗しても続行・`gh` なし）、`25_arm_gcc.sh`（偽の `sudo` で、y・空・n・入力が閉じている・無効5回・無効のあと y・導入済み）。`stow` が無いと、`30_link.sh` の通しは skip する。
- 新しいスクリプトや関数を足したときは、同じ観点（新規作成、再実行、dry-run、元に戻す、実体があれば止まる）で項目を足す。

## スクリプトの試験（Windows）

`pwsh -NoProfile -File tests/windows/test_20_apps.ps1` で、`scripts/windows/20_apps.bat` の Scoop 導入の分岐と、VC++ ランタイム表示の色、`scripts/windows/*.bat` が ASCII だけであることを試験する（終了コード = 失敗数。28項目）。`pwsh -NoProfile -File tests/windows/test_11_git_identity.ps1` で、`11_git_identity.bat` を試験する（15項目。偽の `USERPROFILE` と、ファイルのリダイレクトで渡す入力を使う。`set /p` は標準入力がパイプだと2行目以降を取りこぼすため）。偽の `USERPROFILE`、環境変数 `PS_EXE` で差し替えた偽の powershell、偽の `scoop.cmd` だけを使い、ネットワークにも実環境の scoop にも触れない（観点: scoop が無く導入成功、導入失敗、scoop が既にある。バット内の PowerShell 部分は取り出して、実効ポリシー5種と、設定失敗時の続行を試験する）。実際の導入は、新しいアカウントか VM で確認する。`pwsh -NoProfile -File tests/windows/test_28_29_installers.ps1` で、`28_npm_globals.bat` と `29_claude_plugins.bat` を試験する（5項目。偽の `volta` / `claude` と偽の `USERPROFILE` だけを使い、実環境には触れない）。`pwsh -NoProfile -File tests/windows/test_claude_bedrock_setup.ps1` で、`windows/claude/claude-bedrock-setup.ps1` を試験する（24項目。偽の `aws` 関数と、PATH から `aws` を外した実行だけを使い、AWS にも実環境の `~/.claude` にも触れない）。`pwsh -NoProfile -File tests/windows/test_claude_launchers.ps1` で、`profile.ps1` の Claude Code 起動関数 5つを試験する（21項目。AST で関数だけ取り出し、偽の `claude` と `fzf` を使う。`claude-gateway` は設定とサインイン済みの確認、`CLAUDE_CONFIG_DIR` の設定と復元、競合する認証の変数の退避を見る）。`pwsh -NoProfile -File tests/windows/test_claude_gateway_setup.ps1` で、`windows/claude/claude-gateway-setup.ps1`（URL の検証、`gateway.json` と `settings.json` の生成、モデル ID の割り当て、非対話の実行、既存ファイルの拒否、`-DryRun`）と、Zed の起動用 `claude-acp-gateway.ps1`（設定が無い・トークンが無いと止まる、`CLAUDE_CONFIG_DIR` を設定して起動、終了コードの引き継ぎ。偽の `USERPROFILE` と偽の `npx.cmd`）を試験する（25項目）。`pwsh -NoProfile -File tests/windows/test_claude_gateway_token.ps1` で、`windows/claude/claude-gateway-token.ps1`（`apiKeyHelper`）を試験する（27項目。PKCE（RFC 7636 の例）・JWT・コールバックの解析・DPAPI の保管の関数と、ローカルの偽の IdP（`HttpListener`）での、有効なトークンの再利用、期限切れの無音更新、更新の拒否、リフレッシュトークン無し、`access_token` モード。標準出力にトークンだけが出ることも見る。ブラウザの `-Login` は試験していない。実際の IdP にも実環境の `~/.claude-gateway` にも触れない）。
