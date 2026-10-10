# Zed の agent_servers「Claude API」の起動用。DPAPI のキーを環境変数に入れて claude-agent-acp を起動する。
# キーが空なら止める（止めないと、アダプタが黙って OAuth に切り替わる）。
# Zed の args に PowerShell のコードを直書きすると、変数が空になる（実機で確認）ので、スクリプトに分けている。
$key = & (Join-Path $PSScriptRoot 'claude-api-key.ps1') 2>&1 | Where-Object { $_ -is [string] } | Select-Object -First 1
if (-not $key) {
    [Console]::Error.WriteLine('empty API key (run: claude-api-key.cmd -Set)')
    exit 1
}
$env:ANTHROPIC_API_KEY = $key
npx -y @agentclientprotocol/claude-agent-acp
exit $LASTEXITCODE
