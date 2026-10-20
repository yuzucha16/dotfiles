# Zed の agent_servers「Claude Gateway」の起動用。設定の場所をゲートウェイ用（~/.claude-gateway）にして claude-agent-acp を起動する。
# 設定が無ければ止める（止めないと、アダプタが ~/.claude の OAuth で黙って動く）。作り方: claude-gateway-setup.cmd、初回のログインは claude-gateway で /login。
# Zed の env には絶対パスを書けない（ユーザー名が入る）ので、パスはここで組み立てる。args に PowerShell のコードを直書きすると変数が空になる（実機で確認）ので、スクリプトに分けている。
$dir = Join-Path $HOME '.claude-gateway'
if (-not (Test-Path (Join-Path $dir 'settings.json'))) {
    [Console]::Error.WriteLine("no gateway settings: $dir\settings.json (run: claude-gateway-setup.cmd)")
    exit 1
}
$env:CLAUDE_CONFIG_DIR = $dir
npx -y @agentclientprotocol/claude-agent-acp
exit $LASTEXITCODE
