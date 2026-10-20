# Zed の agent_servers「Claude Bedrock SSO」の起動用。SSO の資格情報が切れていたら aws sso login してから claude-agent-acp を起動する。
# プロファイルは環境変数 AWS_PROFILE（Zed の env で渡す）から読む。ログインの出力は標準エラーへ出す（標準出力は ACP のプロトコルが使うため）。
# Zed の args に PowerShell のコードを直書きすると、変数が空になる（実機で確認）ので、スクリプトに分けている。
function Stop-Launch($msg) { [Console]::Error.WriteLine($msg); exit 1 }

$p = $env:AWS_PROFILE
if (-not $p) { Stop-Launch 'AWS_PROFILE is empty (set it in the agent env in Zed settings)' }
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { Stop-Launch 'aws CLI not found (winget install Amazon.AWSCLI)' }

& aws sts get-caller-identity --profile $p *> $null
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("credentials are not valid; running: aws sso login --profile $p")
    & aws sso login --profile $p *>&1 | ForEach-Object { [Console]::Error.WriteLine("$_") }
    if ($LASTEXITCODE -ne 0) { Stop-Launch "aws sso login failed (profile: $p)" }
}
npx -y @agentclientprotocol/claude-agent-acp
exit $LASTEXITCODE
