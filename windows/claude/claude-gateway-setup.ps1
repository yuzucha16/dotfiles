# Claude Code を、組織の LLM ゲートウェイ（Entra ID などの OIDC で認証）で使うための、この PC 専用の設定を作る。
# 実行: claude-gateway-setup.cmd [-DryRun]   （引数なしなら対話。値は Claude Desktop の「Configure Third-Party Inference」と同じもの）
# 作るもの（%USERPROFILE%\.claude-gateway\。この PC 専用。リポジトリには置かない。秘密は含まない）:
#   gateway.json … issuer / clientId / scopes / tokenType（claude-gateway-token.ps1 が読む）
#   settings.json … ANTHROPIC_BASE_URL と apiKeyHelper（claude-gateway-token.cmd）
# 続き: claude-gateway-token.cmd -Login（初回のブラウザサインイン）→ claude-gateway で起動。
# URL とクライアント ID は組織を特定できる値なので、dotfiles には持たず、毎回ここで入力する。
# 設定の場所を ~/.claude と分けるのは、apiKeyHelper を共通の設定に入れると OAuth に戻れなくなるため（Zed の起動用にも同じ場所を使う）。
[CmdletBinding()]
param(
    [string]$BaseUrl,                                      # ゲートウェイのベース URL
    [string]$Issuer,                                       # OIDC の発行者 URL（例: https://login.microsoftonline.com/<テナント>/v2.0）
    [string]$ClientId,                                     # IdP に登録されたアプリのクライアント ID
    [string]$Scopes,                                       # 空 = 既定（openid profile email offline_access）
    [ValidateSet('id_token', 'access_token')][string]$TokenType = 'id_token',
    [int]$RedirectPort,                                    # 0 / 省略 = 固定しない（IdP が固定ポートを求めるときだけ指定する）
    [string]$OpusId,                                       # ゲートウェイが提供するモデル ID。空 = ピン留めしない
    [string]$SonnetId,
    [string]$HaikuId,
    [string]$Model,                                        # セッションの既定モデル（別名か ID）。空 = Claude Code の既定
    [string]$ConfigDir = (Join-Path $HOME '.claude-gateway'),
    [switch]$DryRun,                                       # 書かずに内容だけ表示する
    [switch]$Force                                         # 既存のファイルを確認なしで上書きする
)

# https の URL だけ受け付ける（http は loopback のときだけ）。末尾の / を除いた文字列を返し、不正なら $null
function ConvertTo-GatewayUrl {
    param([string]$Text)
    $u = $null
    if (-not [Uri]::TryCreate($Text.Trim(), [UriKind]::Absolute, [ref]$u)) { return $null }
    if ($u.Scheme -eq 'https' -or ($u.Scheme -eq 'http' -and $u.IsLoopback)) { return $u.GetLeftPart([UriPartial]::Authority) + $(if ($u.AbsolutePath -ne '/') { $u.AbsolutePath.TrimEnd('/') } else { '' }) }
    $null
}

# gateway.json（トークンの取得に使う値）
function New-GatewayConfig {
    param([string]$Issuer, [string]$ClientId, [string]$Scopes, [string]$TokenType, [int]$RedirectPort = 0)
    $c = [ordered]@{ issuer = $Issuer; clientId = $ClientId }
    if ($Scopes) { $c['scopes'] = $Scopes }
    if ($RedirectPort -gt 0) { $c['redirectPort'] = $RedirectPort }
    $c['tokenType'] = $TokenType
    $c
}

# settings.json（Claude Code に読ませる設定）。ゲートウェイのモデル ID を、別名 opus / sonnet / haiku に割り当てる（空は割り当てない）
function New-GatewaySettings {
    param([string]$BaseUrl, [string]$OpusId, [string]$SonnetId, [string]$HaikuId, [string]$Model)
    $e = [ordered]@{ ANTHROPIC_BASE_URL = $BaseUrl; CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = '1' }
    if ($OpusId) { $e['ANTHROPIC_DEFAULT_OPUS_MODEL'] = $OpusId }
    if ($SonnetId) { $e['ANTHROPIC_DEFAULT_SONNET_MODEL'] = $SonnetId }
    if ($HaikuId) { $e['ANTHROPIC_DEFAULT_HAIKU_MODEL'] = $HaikuId }
    $s = [ordered]@{ apiKeyHelper = 'claude-gateway-token.cmd' }
    if ($Model) { $s['model'] = $Model }
    $s['env'] = $e
    $s
}

# dot-source されたとき（試験）は、関数だけ定義して終わる
if ($MyInvocation.InvocationName -eq '.') { return }

$ErrorActionPreference = 'Stop'
function Stop-Setup($msg) { [Console]::Error.WriteLine("[ERR] $msg"); exit 1 }

$interactive = -not [Console]::IsInputRedirected
function Resolve-Value($Name, $Value, $Prompt, [switch]$Optional) {
    if ($Value) { return $Value }
    if ($interactive) { return (Read-Host $Prompt) }
    if ($Optional) { return '' }
    Stop-Setup "-$Name が必要です。"
}
$BaseUrl = Resolve-Value 'BaseUrl' $BaseUrl 'ゲートウェイのベース URL（https://…）'
$Issuer = Resolve-Value 'Issuer' $Issuer '発行者 URL（Issuer URL。https://login.microsoftonline.com/…/v2.0 など）'
$ClientId = Resolve-Value 'ClientId' $ClientId 'クライアント ID（Client ID）'
if (-not $PSBoundParameters.ContainsKey('Scopes')) { $Scopes = Resolve-Value 'Scopes' $Scopes 'スコープ（空欄 = 既定の openid profile email offline_access）' -Optional }
if ($interactive -and -not $PSBoundParameters.ContainsKey('TokenType')) {
    $a = Read-Host 'トークン種別（id_token / access_token）[id_token]'
    if ($a) { if ($a -notin 'id_token', 'access_token') { Stop-Setup "id_token か access_token です: $a" } $TokenType = $a }
}
if ($interactive -and -not $PSBoundParameters.ContainsKey('RedirectPort')) {
    $a = Read-Host 'リダイレクトポート（空欄 = 固定しない）'
    if ($a) { if (-not [int]::TryParse($a, [ref]$RedirectPort) -or $RedirectPort -lt 1 -or $RedirectPort -gt 65535) { Stop-Setup "1〜65535 の番号です: $a" } }
}
foreach ($m in @(@('OpusId', 'opus'), @('SonnetId', 'sonnet'), @('HaikuId', 'haiku'))) {
    if ($interactive -and -not $PSBoundParameters.ContainsKey($m[0])) {
        Set-Variable -Name $m[0] -Value (Read-Host "$($m[1]) に割り当てるゲートウェイのモデル ID（空欄 = 割り当てない）")
    }
}
if ($interactive -and -not $PSBoundParameters.ContainsKey('Model')) { $Model = Read-Host 'セッションの既定モデル（opus / sonnet / haiku か ID。空欄 = Claude Code の既定）' }

$base = ConvertTo-GatewayUrl $BaseUrl
if (-not $base) { Stop-Setup "https の URL ではありません（ベース URL）: $BaseUrl" }
$iss = ConvertTo-GatewayUrl $Issuer
if (-not $iss -or $iss -notmatch '^https://') { Stop-Setup "https の URL ではありません（発行者 URL）: $Issuer" }
if ($iss -match 'well-known') { Stop-Setup '発行者 URL に /.well-known/openid-configuration は付けません（基本の URL だけ）。' }
if (-not $ClientId.Trim()) { Stop-Setup 'クライアント ID が空です。' }

$cfgFile = Join-Path $ConfigDir 'gateway.json'
$setFile = Join-Path $ConfigDir 'settings.json'
$cfgJson = (New-GatewayConfig $iss $ClientId.Trim() $Scopes.Trim() $TokenType $RedirectPort) | ConvertTo-Json
$setJson = (New-GatewaySettings $base "$OpusId".Trim() "$SonnetId".Trim() "$HaikuId".Trim() "$Model".Trim()) | ConvertTo-Json -Depth 5
if (-not ("$OpusId$SonnetId$HaikuId".Trim())) { Write-Host '[WARN] モデル ID を1つも割り当てていません。ゲートウェイが /v1/models を持たないと、モデルが見つからないことがあります（Desktop の「推論モデルの一覧」と同じ ID を指定する）。' }

if ($DryRun) {
    Write-Host "[DRY-RUN] 書き込み先: $cfgFile"
    Write-Output $cfgJson
    Write-Host "[DRY-RUN] 書き込み先: $setFile"
    Write-Output $setJson
    exit 0
}

foreach ($f in $cfgFile, $setFile) {
    if ((Test-Path $f) -and -not $Force) {
        if (-not $interactive) { Stop-Setup "既にあります: $f（上書きするなら -Force）" }
        if ((Read-Host "既にあります: $f 上書きしますか? [y/N]") -notmatch '^[yY]') { Write-Host '[SKIP] 何も書きませんでした。'; exit 0 }
    }
}
New-Item -ItemType Directory -Force $ConfigDir | Out-Null
$utf8 = New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText($cfgFile, $cfgJson + "`n", $utf8)
[IO.File]::WriteAllText($setFile, $setJson + "`n", $utf8)
Write-Host "[DONE] $cfgFile"
Write-Host "[DONE] $setFile"
Write-Host '次: 1) claude-gateway-token.cmd -Login でブラウザにサインイン（初回だけ。トークンは DPAPI で暗号化して保管）'
Write-Host '    2) claude-gateway で起動し、/status で Anthropic base URL と Auth token（apiKeyHelper）を確認する。'
