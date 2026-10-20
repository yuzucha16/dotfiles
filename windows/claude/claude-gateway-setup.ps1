# Claude Code を、組織の Claude apps gateway（SSO サインイン）で使うための、この PC 専用の設定を作る。
# 実行: claude-gateway-setup.cmd [-Url https://…] [-DryRun]   （引数なしなら対話。URL をプロンプトで入力する）
# 作るもの: %USERPROFILE%\.claude-gateway\settings.json（forceLoginMethod と forceLoginGatewayUrl。この PC 専用。リポジトリには置かない）
# 起動: claude-gateway（windows/powershell/profile.ps1 の関数。CLAUDE_CONFIG_DIR をこの場所にして claude を起動する）。初回は /login → Cloud gateway で Enter、ブラウザで承認。
# ゲートウェイの URL は組織を特定できる値なので、dotfiles には持たず、毎回ここで入力する。
# 設定の場所を ~/.claude と分けるのは、ゲートウェイのサインインが OAuth（サブスク）のログインの代わりになり、1つしか使えないため。
[CmdletBinding()]
param(
    [string]$Url,                                          # 省略 = 対話で入力する
    [string]$ConfigDir = (Join-Path $HOME '.claude-gateway'),
    [switch]$DryRun,                                       # 書かずに内容だけ表示する
    [switch]$Force                                         # 既存のファイルを確認なしで上書きする
)

# https の URL だけ受け付ける（http は loopback のときだけ）。正規化した文字列を返し、不正なら $null
function ConvertTo-GatewayUrl {
    param([string]$Text)
    $u = $null
    if (-not [Uri]::TryCreate($Text.Trim(), [UriKind]::Absolute, [ref]$u)) { return $null }
    if ($u.Scheme -eq 'https' -or ($u.Scheme -eq 'http' -and $u.IsLoopback)) { return $u.GetLeftPart([UriPartial]::Authority) + $(if ($u.AbsolutePath -ne '/') { $u.AbsolutePath.TrimEnd('/') } else { '' }) }
    $null
}

function New-GatewaySettings {
    param([string]$Url)
    [ordered]@{ forceLoginMethod = 'gateway'; forceLoginGatewayUrl = $Url }
}

# dot-source されたとき（試験）は、関数だけ定義して終わる
if ($MyInvocation.InvocationName -eq '.') { return }

$ErrorActionPreference = 'Stop'
function Stop-Setup($msg) { [Console]::Error.WriteLine("[ERR] $msg"); exit 1 }

$interactive = -not [Console]::IsInputRedirected
if (-not $Url) {
    if (-not $interactive) { Stop-Setup '-Url が必要です（例: https://claude-gateway.example.com）。' }
    $Url = Read-Host 'ゲートウェイの URL（https://…。組織から案内された値）'
}
$norm = ConvertTo-GatewayUrl $Url
if (-not $norm) { Stop-Setup "https の URL ではありません: $Url" }

$outFile = Join-Path $ConfigDir 'settings.json'
$json = (New-GatewaySettings $norm) | ConvertTo-Json

if ($DryRun) {
    Write-Host "[DRY-RUN] 書き込み先: $outFile"
    Write-Output $json
    exit 0
}

if ((Test-Path $outFile) -and -not $Force) {
    if (-not $interactive) { Stop-Setup "既にあります: $outFile（上書きするなら -Force）" }
    if ((Read-Host "既にあります: $outFile 上書きしますか? [y/N]") -notmatch '^[yY]') { Write-Host '[SKIP] 何も書きませんでした。'; exit 0 }
}
New-Item -ItemType Directory -Force $ConfigDir | Out-Null
[IO.File]::WriteAllText($outFile, $json + "`n", (New-Object Text.UTF8Encoding $false))
Write-Host "[DONE] $outFile"
Write-Host '次: claude-gateway を起動し、/login → Cloud gateway で Enter、ブラウザで会社のアカウントで承認する。初回は TLS 証明書の指紋の確認が出る（管理者が案内した値と照合する）。'
Write-Host '    /status でプロバイダがゲートウェイであることを確認する。'
