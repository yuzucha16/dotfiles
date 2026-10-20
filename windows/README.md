# windows

Windows 専用の設定の一覧（`links.map` からだけ参照される）。要点は、リポジトリ直下の `README.md`。下は 2026-10-16 に README から移した原文。


| パス | 内容 |
|---|---|
| `terminal/settings.json` | Windows Terminal |
| `startup/startup.bat` | スタートアップ。`subst V: %WORKS_DIR%` |
| `wsl/.wslconfig` | WSL2 の全体設定（`%USERPROFILE%\.wslconfig` へリンク）。アイドル時にキャッシュのメモリをホストへ返す。`memory` などの上限は PC ごとに RAM が違うので書かない。反映は `wsl --shutdown` 後の再起動 |
| `powershell/history.seed.txt` | PSReadLine の履歴の種（手で選んだ定型コマンド。個人値は `<…名>` に置換済みで、そのままでは実行されない）。正本は共有リポジトリ `workbase`（`$HOME\works\resources`）の `exmem/lessons/shell-command-usecases.md`。リンクではなく、初回に履歴ファイルが無いときだけコピーする（`scripts\windows\31_history_seed.bat`） |
| `claude/` | Claude Code の API キー認証用と、Amazon Bedrock 用と、組織の LLM ゲートウェイ（OIDC サインイン）用（手順・保管方法・モデル ID の取得・費用の上限・Bedrock 版とゲートウェイ版の手順は `windows/claude/README.md`）。起動する認証は `profile.ps1` の関数で選ぶ（`claude-pick`、`claude-oauth`、`claude-api`、`claude-bedrock`、`claude-gateway`）。ゲートウェイ版は、`claude-gateway-setup.ps1` / `.cmd`（URL・発行者 URL・クライアント ID・モデル ID をプロンプトで入力し、この PC 専用の `%USERPROFILE%\.claude-gateway\` の `gateway.json` と `settings.json` を生成する。値は dotfiles に置かない）、`claude-gateway-token.ps1` / `.cmd`（`apiKeyHelper`。OIDC のトークンを返す。`-Login` でブラウザにサインインし、トークンは DPAPI で暗号化して保管）、関数 `claude-gateway`（`CLAUDE_CONFIG_DIR` を分けて起動）、Zed 用の `claude-acp-gateway.ps1` / `.cmd`。Bedrock 版は、`claude-bedrock-setup.ps1` / `.cmd`（AWS CLI で推論プロファイルの一覧を取り、この PC 専用の `%USERPROFILE%\.claude\settings-bedrock.json` を生成する）と、関数 `claude-bedrock`。実値は持たず、生成したファイルは追跡しない。`settings-api.json`（`apiKeyHelper` とモデルの環境変数。`claude-api` が `--settings` で読む）、`claude-api-key.ps1` / `.cmd`（DPAPI で暗号化したキーを復号して返す `apiKeyHelper`）。`claude` は OAuth のまま。キーは追跡しない（初回は `claude-api-key.cmd -Set` で保存。暗号化ファイルは `%USERPROFILE%\.claude\settings-api-key.dpapi`、この PC・このユーザーだけが復号できる） |
| `powershell/profile.ps1` | PowerShell プロファイル（starship / lsd / zoxide / Emacs キーバインド）。起動を軽くするため、ツール不在時の代替・`cd` 後の自動 `ll`・PSFzf は持たない。コマンド体系は `home/.config/shell/common.sh` と揃える（基本エイリアスのみ。`Ctrl+r`/`Ctrl+t` の fzf と `zfz` = `Alt+j`、`cdg` = `Alt+k` は3シェル共通。PSFzf は使わず自前ハンドラ） |
| `obsidian/.obsidian/` | Obsidian の設定（テーマ、CSS スニペット、プラグイン `colored-tags`、`app.json` など）。`links.map` で `%WORKS_DIR%\.obsidian` へジャンクションを張る。`workspace.json`（端末ごとの状態）は追跡しない |
| `obsidian/claudian-settings.json` | Claudian（Obsidian プラグイン）の設定。`links.map` で `%WORKS_DIR%\.claudian\claudian-settings.json` へファイルの symlink を張る。`.claudian\sessions\`（端末ごとの会話履歴）は張らず、追跡しない |
| `office/` | Office のテンプレ（`.potx` `.xltx` `.dotm` `.thmx` など）、UI 設定（`.exportedUI`）、サンプル。配置は手動（リンクしない）: テンプレは `%APPDATA%\Microsoft\Templates` と `%APPDATA%\Microsoft\Excel\XLSTART`、UI は Office の「リボンのユーザー設定 → インポート」 |
| `autohotkey/` `notepadpp/` `drawio/` | 各アプリの設定（Notepad++ はテーマと `config.min.xml`（初回だけ `20_apps.bat` が `config.xml` として置く最小構成）のみ。アプリが書き換えるファイルは追跡しない） |
