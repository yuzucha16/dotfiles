# Zed の agent_servers「Claude Gateway」の起動用。設定の場所をゲートウェイ用（~/.claude-gateway）にして claude-agent-acp を起動する。
# ベース URL と apiKeyHelper は ~/.claude-gateway/settings.json にある（claude-gateway-setup.cmd が作る）。トークンは起動前に取れるかだけ確かめる（取れなければ止める）。
# 設定が無ければ止める（止めないと、アダプタが ~/.claude の OAuth で黙って動く）。初回のサインインは claude-gateway-token.cmd -Login。
# Zed の env には絶対パスを書けない（ユーザー名が入る）ので、パスはここで組み立てる。args に PowerShell のコードを直書きすると変数が空になる（実機で確認）ので、スクリプトに分けている。
$dir = Join-Path $HOME '.claude-gateway'
if (-not (Test-Path (Join-Path $dir 'settings.json'))) {
    [Console]::Error.WriteLine("no gateway settings: $dir\settings.json (run: claude-gateway-setup.cmd)")
    exit 1
}
$global:LASTEXITCODE = 0   # トークンが有効なとき、ヘルパーは exit せずに終わる（$LASTEXITCODE が更新されない）ので、先に 0 にしておく
& (Join-Path $PSScriptRoot 'claude-gateway-token.ps1') -ConfigDir $dir *> $null
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine('gateway token is not available (run: claude-gateway-token.cmd -Login)')
    exit 1
}
$env:CLAUDE_CONFIG_DIR = $dir
npx -y @agentclientprotocol/claude-agent-acp
exit $LASTEXITCODE
