# Claude Code の apiKeyHelper 用。DPAPI で暗号化した API キーを復号して、標準出力に返す。
# 保存: claude-api-key.cmd -Set   （キーはプロンプトに貼る。コマンド履歴や引数に残らない）
# 暗号化ファイルは、この Windows ユーザー + この PC でだけ復号できる。リポジトリには置かない。
# 保管方法を変えるときは、このファイルだけを差し替える（api.settings.json は変えない）。
param([switch]$Set)

$keyFile = if ($env:CLAUDE_API_KEY_FILE) { $env:CLAUDE_API_KEY_FILE } else { Join-Path $HOME '.claude\api-key.dpapi' }

if ($Set) {
    $secure = Read-Host 'Anthropic API key' -AsSecureString
    $secure | ConvertFrom-SecureString | Set-Content -Path $keyFile -Encoding ascii
    Write-Host "saved: $keyFile"
    return
}

if (-not (Test-Path $keyFile)) {
    [Console]::Error.WriteLine("no key file: $keyFile (run: claude-api-key.cmd -Set)")
    exit 1
}
$secure = (Get-Content -Path $keyFile -Raw).Trim() | ConvertTo-SecureString
[System.Net.NetworkCredential]::new('', $secure).Password
