# Claude Code の apiKeyHelper 用。組織のゲートウェイへ送る OIDC のトークン（Entra ID など）を、標準出力に返す。
# 初回のログイン: claude-gateway-token.cmd -Login   （ブラウザで認可コード + PKCE。Claude Desktop のゲートウェイ設定と同じ流れ）
# 以降: 有効なトークンがあればそれを返し、切れていれば保管したリフレッシュトークンで無音で更新する。更新できなければ -Login を促して exit 1。
# 設定: %USERPROFILE%\.claude-gateway\gateway.json（issuer / clientId / scopes / tokenType。claude-gateway-setup.cmd が作る）
# 保管: %USERPROFILE%\.claude-gateway\token.dpapi（DPAPI で暗号化。この Windows ユーザー + この PC でだけ復号できる。リポジトリには置かない）
# 標準出力にはトークンだけを出す（apiKeyHelper は、それ以外が混ざると失敗する）。メッセージは標準エラーへ。
param(
    [switch]$Login,                                        # ブラウザでサインインして、トークンを保管する
    [string]$ConfigDir = (Join-Path $HOME '.claude-gateway')
)

function ConvertTo-Base64Url {
    param([byte[]]$Bytes)
    [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

function ConvertFrom-Base64Url {
    param([string]$Text)
    $s = $Text.Replace('-', '+').Replace('_', '/')
    switch ($s.Length % 4) { 2 { $s += '==' } 3 { $s += '=' } }
    [Convert]::FromBase64String($s)
}

function New-RandomString {
    param([int]$Bytes = 16)
    $b = New-Object byte[] $Bytes
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
    ConvertTo-Base64Url $b
}

# RFC 7636: code_verifier と S256 の code_challenge
function New-PkcePair {
    $verifier = New-RandomString 48
    [pscustomobject]@{ Verifier = $verifier; Challenge = (Get-PkceChallenge $verifier) }
}
function Get-PkceChallenge {
    param([string]$Verifier)
    ConvertTo-Base64Url ([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::ASCII.GetBytes($Verifier)))
}

# JWT の本文（claims）を返す。署名の検証はしない（検証はゲートウェイの仕事）
function Get-JwtPayload {
    param([string]$Jwt)
    $parts = $Jwt.Split('.')
    if ($parts.Count -lt 2) { return $null }
    [Text.Encoding]::UTF8.GetString((ConvertFrom-Base64Url $parts[1])) | ConvertFrom-Json
}

# 期限まで $MarginSec 秒以上あれば有効
function Test-TokenFresh {
    param([string]$Jwt, [int]$MarginSec = 120)
    if (-not $Jwt) { return $false }
    $exp = (Get-JwtPayload $Jwt).exp
    if (-not $exp) { return $false }
    [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() + $MarginSec -lt [long]$exp
}

# 保管ファイル（DPAPI）。内容は {id_token, access_token, refresh_token} の JSON
function Save-TokenCache {
    param([string]$Path, $Tokens)
    ($Tokens | ConvertTo-Json -Compress | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString) | Set-Content -Path $Path -Encoding ascii
}
function Read-TokenCache {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    $secure = (Get-Content -Path $Path -Raw).Trim() | ConvertTo-SecureString
    [System.Net.NetworkCredential]::new('', $secure).Password | ConvertFrom-Json
}

function Get-OidcEndpoints {
    param([string]$Issuer)
    $d = Invoke-RestMethod -Uri ($Issuer.TrimEnd('/') + '/.well-known/openid-configuration')
    [pscustomobject]@{ Authorize = $d.authorization_endpoint; Token = $d.token_endpoint }
}

function Invoke-TokenRequest {
    param([string]$TokenEndpoint, [hashtable]$Body)
    Invoke-RestMethod -Method Post -Uri $TokenEndpoint -Body $Body -ContentType 'application/x-www-form-urlencoded'
}

# 設定のトークン種別（id_token / access_token）に合う値を、トークンの応答から取り出す
function Select-BearerToken {
    param($Response, [string]$TokenType)
    if ($TokenType -eq 'access_token') { $Response.access_token } else { $Response.id_token }
}

# 保管するトークン。応答に refresh_token が無い更新（IdP による）では、前のものを引き継ぐ
function Merge-Tokens {
    param($Response, $Previous)
    [pscustomobject]@{
        id_token      = $Response.id_token
        access_token  = $Response.access_token
        refresh_token = $(if ($Response.refresh_token) { $Response.refresh_token } else { $Previous.refresh_token })
    }
}

# 受け取ったコールバックの要求行（"GET /callback?code=…&state=… HTTP/1.1"）のクエリを返す
function Read-CallbackQuery {
    param([string]$RequestLine)
    $q = @{}
    if ($RequestLine -match '^GET\s+\S*?\?(\S+)\s+HTTP') {
        foreach ($pair in $Matches[1].Split('&')) {
            $kv = $pair.Split('=', 2)
            $q[[Uri]::UnescapeDataString($kv[0])] = if ($kv.Count -gt 1) { [Uri]::UnescapeDataString($kv[1].Replace('+', ' ')) } else { '' }
        }
    }
    $q
}

# loopback で1回だけ待ち受け、認可コードを受け取る。戻り値は @{ code; state; error }
function Wait-AuthCallback {
    param([System.Net.Sockets.TcpListener]$Listener, [int]$TimeoutSec = 180)
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSec)
    while (-not $Listener.Pending()) {
        if ([DateTime]::UtcNow -gt $deadline) { throw "サインインがタイムアウトしました（${TimeoutSec}秒）" }
        Start-Sleep -Milliseconds 200
    }
    $client = $Listener.AcceptTcpClient()
    try {
        $stream = $client.GetStream()
        $reader = New-Object IO.StreamReader($stream)
        $line = $reader.ReadLine()
        $q = Read-CallbackQuery $line
        $html = '<html><body><p>Signed in. You can close this tab and return to the terminal.</p></body></html>'
        $resp = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $([Text.Encoding]::UTF8.GetByteCount($html))`r`nConnection: close`r`n`r`n$html"
        $bytes = [Text.Encoding]::UTF8.GetBytes($resp)
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush()
        $q
    } finally { $client.Close() }
}

function Invoke-InteractiveLogin {
    param($Config, $Endpoints)
    $pkce = New-PkcePair
    $state = New-RandomString
    $nonce = New-RandomString
    $fixedPort = if ($Config.redirectPort) { [int]$Config.redirectPort } else { 0 }   # 0 = 空いているポート（Entra は loopback のポートを問わない）
    $listener = New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback, $fixedPort)
    $listener.Start()
    try {
        $port = $listener.LocalEndpoint.Port
        $redirect = "http://127.0.0.1:$port/callback"
        $scopes = if ($Config.scopes) { $Config.scopes } else { 'openid profile email offline_access' }
        $params = [ordered]@{
            client_id = $Config.clientId; response_type = 'code'; redirect_uri = $redirect; response_mode = 'query'
            scope = $scopes; state = $state; nonce = $nonce
            code_challenge = $pkce.Challenge; code_challenge_method = 'S256'
        }
        $query = ($params.GetEnumerator() | ForEach-Object { '{0}={1}' -f $_.Key, [Uri]::EscapeDataString([string]$_.Value) }) -join '&'
        $url = $Endpoints.Authorize + '?' + $query
        [Console]::Error.WriteLine('ブラウザでサインインしてください。開かないときは次の URL を開く:')
        [Console]::Error.WriteLine($url)
        Start-Process $url
        $cb = Wait-AuthCallback -Listener $listener
    } finally { $listener.Stop() }
    if ($cb.error) { throw "サインインに失敗しました: $($cb.error) $($cb.error_description)" }
    if ($cb.state -ne $state) { throw 'state が一致しません（別のサインインの応答です）' }
    if (-not $cb.code) { throw '認可コードを受け取れませんでした' }
    $resp = Invoke-TokenRequest -TokenEndpoint $Endpoints.Token -Body @{
        grant_type = 'authorization_code'; client_id = $Config.clientId; code = $cb.code
        redirect_uri = $redirect; code_verifier = $pkce.Verifier
    }
    if ($resp.id_token -and (Get-JwtPayload $resp.id_token).nonce -ne $nonce) { throw 'nonce が一致しません' }
    $resp
}

# dot-source されたとき（試験）は、関数だけ定義して終わる
if ($MyInvocation.InvocationName -eq '.') { return }

$ErrorActionPreference = 'Stop'
function Stop-Token($msg) { [Console]::Error.WriteLine($msg); exit 1 }

$cfgFile = Join-Path $ConfigDir 'gateway.json'
$cacheFile = Join-Path $ConfigDir 'token.dpapi'
if (-not (Test-Path $cfgFile)) { Stop-Token "no gateway config: $cfgFile (run: claude-gateway-setup.cmd)" }
$config = Get-Content $cfgFile -Raw | ConvertFrom-Json
$tokenType = if ($config.tokenType) { $config.tokenType } else { 'id_token' }

try {
    if ($Login) {
        $ep = Get-OidcEndpoints $config.issuer
        $resp = Invoke-InteractiveLogin -Config $config -Endpoints $ep
        $tokens = Merge-Tokens $resp $null
        if (-not (Select-BearerToken $tokens $tokenType)) { Stop-Token "応答に $tokenType がありません（scopes / tokenType を確認する）" }
        Save-TokenCache $cacheFile $tokens
        [Console]::Error.WriteLine("saved: $cacheFile")
        if (-not $tokens.refresh_token) { [Console]::Error.WriteLine('[WARN] refresh_token がありません。約1時間ごとに再サインインが必要です（scopes に offline_access があるか確認する）。') }
        return
    }

    $tokens = Read-TokenCache $cacheFile
    if (-not $tokens) { Stop-Token 'not signed in (run: claude-gateway-token.cmd -Login)' }
    $bearer = Select-BearerToken $tokens $tokenType
    if (Test-TokenFresh $bearer) { Write-Output $bearer; return }

    if (-not $tokens.refresh_token) { Stop-Token 'token expired and no refresh token (run: claude-gateway-token.cmd -Login)' }
    $ep = Get-OidcEndpoints $config.issuer
    $body = @{ grant_type = 'refresh_token'; client_id = $config.clientId; refresh_token = $tokens.refresh_token }
    if ($config.scopes) { $body['scope'] = $config.scopes }
    $resp = Invoke-TokenRequest -TokenEndpoint $ep.Token -Body $body
    $tokens = Merge-Tokens $resp $tokens
    $bearer = Select-BearerToken $tokens $tokenType
    if (-not $bearer) { Stop-Token "更新の応答に $tokenType がありません（run: claude-gateway-token.cmd -Login）" }
    Save-TokenCache $cacheFile $tokens
    Write-Output $bearer
} catch {
    Stop-Token "token error: $($_.Exception.Message) (run: claude-gateway-token.cmd -Login)"
}
