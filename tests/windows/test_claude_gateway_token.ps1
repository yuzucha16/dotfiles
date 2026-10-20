# windows/claude/claude-gateway-token.ps1（ゲートウェイ用の OIDC トークンの apiKeyHelper）の試験
# 使い方: pwsh -NoProfile -File tests/windows/test_claude_gateway_token.ps1   （終了コード = 失敗数）
# 純粋な関数は dot-source して試験する。トークンの取得と更新は、一時ディレクトリの設定と、ローカルの偽の IdP（HttpListener）で実行して試験する。
# ブラウザのサインイン（-Login）の部分は試験していない（ブラウザと実際の IdP が要る）。実環境の ~/.claude-gateway にも IdP にも触れない。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script = Join-Path $repo 'windows\claude\claude-gateway-token.ps1'
$pwsh = (Get-Command pwsh).Source
$fail = 0
function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}
function New-Jwt($exp, $extra = @{}) {
  $claims = @{ exp = $exp } + $extra
  'e30.' + (ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes(($claims | ConvertTo-Json -Compress)))) + '.sig'
}

# --- 関数の試験 ---
. $script
Check 'base64url: no padding, - and _' ((ConvertTo-Base64Url ([byte[]](0xfb, 0xff, 0xfe))) -eq '-__-')
Check 'base64url: round trip'          (([Text.Encoding]::UTF8.GetString((ConvertFrom-Base64Url (ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes('hello?>'))))) -eq 'hello?>'))
Check 'pkce: RFC 7636 test vector'     ((Get-PkceChallenge 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk') -eq 'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM')
$p = New-PkcePair
Check 'pkce: pair is consistent, verifier is long enough' (($p.Challenge -eq (Get-PkceChallenge $p.Verifier)) -and ($p.Verifier.Length -ge 43))
Check 'random: differs each time'      ((New-RandomString) -ne (New-RandomString))
$future = [DateTimeOffset]::UtcNow.AddHours(1).ToUnixTimeSeconds()
$soon = [DateTimeOffset]::UtcNow.AddSeconds(30).ToUnixTimeSeconds()
$past = [DateTimeOffset]::UtcNow.AddHours(-1).ToUnixTimeSeconds()
Check 'jwt: payload claims'            ((Get-JwtPayload (New-Jwt $future @{ nonce = 'n1' })).nonce -eq 'n1')
Check 'fresh: valid token'             (Test-TokenFresh (New-Jwt $future))
Check 'fresh: expiring within margin is stale' (-not (Test-TokenFresh (New-Jwt $soon)))
Check 'fresh: expired is stale'        (-not (Test-TokenFresh (New-Jwt $past)))
Check 'fresh: empty / not a JWT is stale' ((-not (Test-TokenFresh '')) -and -not (Test-TokenFresh 'abc'))
$q = Read-CallbackQuery 'GET /callback?code=a%2Fb%3D&state=xyz&error_description=a+b HTTP/1.1'
Check 'callback: query parsed and unescaped' (($q.code -eq 'a/b=') -and ($q.state -eq 'xyz') -and ($q.error_description -eq 'a b'))
Check 'callback: no query -> empty'    ((Read-CallbackQuery 'GET /favicon.ico HTTP/1.1').Count -eq 0)
$r = [pscustomobject]@{ id_token = 'I'; access_token = 'A'; refresh_token = $null }
Check 'bearer: id_token / access_token' (((Select-BearerToken $r 'id_token') -eq 'I') -and ((Select-BearerToken $r 'access_token') -eq 'A'))
Check 'merge: keeps previous refresh token when the response has none' ((Merge-Tokens $r ([pscustomobject]@{ refresh_token = 'R0' })).refresh_token -eq 'R0')
Check 'merge: takes a new refresh token' ((Merge-Tokens ([pscustomobject]@{ id_token = 'I'; refresh_token = 'R1' }) ([pscustomobject]@{ refresh_token = 'R0' })).refresh_token -eq 'R1')

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("ttoken-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $tmp | Out-Null
$cache = Join-Path $tmp 'token.dpapi'
Save-TokenCache $cache ([pscustomobject]@{ id_token = 'I'; access_token = 'A'; refresh_token = 'R' })
$raw = Get-Content $cache -Raw
Check 'cache: encrypted at rest (no plain tokens in the file)' (($raw -notmatch '"R"') -and ($raw -notmatch 'refresh_token'))
Check 'cache: round trip'              ((Read-TokenCache $cache).refresh_token -eq 'R')
Check 'cache: missing file -> null'    ($null -eq (Read-TokenCache (Join-Path $tmp 'none.dpapi')))

# --- 偽の IdP（別プロセスの HttpListener）で、スクリプトを実行する ---
$port = Get-Random -Minimum 20000 -Maximum 40000
$reqLog = Join-Path $tmp 'idp.log'
$mode = Join-Path $tmp 'idp.mode'      # 'ok' か 'fail'。トークンエンドポイントの応答を切り替える
Set-Content $mode 'ok'
$newJwt = New-Jwt $future @{ marker = 'refreshed' }
$job = Start-Job -ArgumentList $port, $reqLog, $mode, $newJwt -ScriptBlock {
  param($port, $reqLog, $mode, $newJwt)
  $l = New-Object System.Net.HttpListener
  $l.Prefixes.Add("http://localhost:$port/")
  $l.Start()
  while ($l.IsListening) {
    $ctx = $l.GetContext()
    $path = $ctx.Request.Url.AbsolutePath
    $body = ''
    if ($ctx.Request.HasEntityBody) { $body = (New-Object IO.StreamReader($ctx.Request.InputStream)).ReadToEnd() }
    Add-Content $reqLog "$($ctx.Request.HttpMethod) $path $body"
    $status = 200
    if ($path -like '*openid-configuration') { $json = "{`"authorization_endpoint`":`"http://localhost:$port/authorize`",`"token_endpoint`":`"http://localhost:$port/token`"}" }
    elseif ((Get-Content $mode -Raw).Trim() -eq 'fail') { $status = 400; $json = '{"error":"invalid_grant"}' }
    else { $json = "{`"id_token`":`"$newJwt`",`"access_token`":`"A2`",`"refresh_token`":`"R2`"}" }
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $ctx.Response.StatusCode = $status
    $ctx.Response.ContentType = 'application/json'
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $ctx.Response.Close()
  }
}
Start-Sleep -Seconds 2   # リスナーの起動待ち

function Run-Token($extra = @()) {
  $err = Join-Path $tmp 'err.txt'
  $out = & $pwsh -NoProfile -File $script -ConfigDir $tmp @extra 2>$err
  [pscustomobject]@{ Out = ($out -join "`n"); Err = "$(Get-Content $err -Raw -ErrorAction SilentlyContinue)"; Rc = $LASTEXITCODE }
}
try {
  $cfg = "{`"issuer`":`"http://localhost:$port`",`"clientId`":`"cid`",`"tokenType`":`"id_token`"}"

  $r = Run-Token
  Check 'no config: exit 1, nothing on stdout' (($r.Rc -eq 1) -and ($r.Out -eq '') -and ($r.Err -match 'claude-gateway-setup'))
  Set-Content (Join-Path $tmp 'gateway.json') $cfg

  Remove-Item $cache
  $r = Run-Token
  Check 'not signed in: exit 1, -Login hint, nothing on stdout' (($r.Rc -eq 1) -and ($r.Out -eq '') -and ($r.Err -match '-Login'))

  $freshJwt = New-Jwt $future @{ marker = 'cached' }
  Save-TokenCache $cache ([pscustomobject]@{ id_token = $freshJwt; access_token = ''; refresh_token = 'R' })
  Remove-Item $reqLog -ErrorAction SilentlyContinue
  $r = Run-Token
  Check 'fresh cache: prints the token, no request to the IdP' (($r.Rc -eq 0) -and ($r.Out -eq $freshJwt) -and -not (Test-Path $reqLog))

  # .cmd の入口: apiKeyHelper として（標準入力が開いたまま）呼ばれても、止まらず、標準出力はトークンだけ（pause を入れると壊れる）
  $cmdPath = (Resolve-Path (Join-Path $repo 'windows\claude\claude-gateway-token.cmd')).Path
  $psi = New-Object Diagnostics.ProcessStartInfo 'cmd.exe'
  $psi.Arguments = "/s /c `"`"$cmdPath`" -ConfigDir `"$tmp`"`""
  $psi.RedirectStandardOutput = $true; $psi.RedirectStandardInput = $true; $psi.UseShellExecute = $false
  $proc = [Diagnostics.Process]::Start($psi)
  $finished = $proc.WaitForExit(20000)
  if (-not $finished) { $proc.Kill() }
  $cmdOut = $proc.StandardOutput.ReadToEnd()
  Check 'cmd entry: returns without waiting for a key (no pause as a helper)' $finished
  Check 'cmd entry: stdout is the token only'                                 ($cmdOut.Trim() -eq $freshJwt)

  Save-TokenCache $cache ([pscustomobject]@{ id_token = (New-Jwt $past); access_token = ''; refresh_token = 'R' })
  $r = Run-Token
  $reqs = if (Test-Path $reqLog) { Get-Content $reqLog -Raw } else { '' }
  Check 'expired: refreshes silently and prints the new token' (($r.Rc -eq 0) -and ($r.Out -eq $newJwt) -and ($reqs -match 'grant_type=refresh_token') -and ($reqs -match 'refresh_token=R') -and ($reqs -match 'client_id=cid'))
  $saved = Read-TokenCache $cache
  Check 'expired: the new tokens are saved (including the rotated refresh token)' (($saved.id_token -eq $newJwt) -and ($saved.refresh_token -eq 'R2'))
  $r = Run-Token
  Check 'after refresh: served from the cache' (($r.Rc -eq 0) -and ($r.Out -eq $newJwt))

  Save-TokenCache $cache ([pscustomobject]@{ id_token = (New-Jwt $past); access_token = ''; refresh_token = 'R' })
  Set-Content $mode 'fail'
  $r = Run-Token
  Check 'refresh rejected: exit 1, -Login hint, nothing on stdout' (($r.Rc -eq 1) -and ($r.Out -eq '') -and ($r.Err -match '-Login'))

  Save-TokenCache $cache ([pscustomobject]@{ id_token = (New-Jwt $past); access_token = ''; refresh_token = $null })
  $r = Run-Token
  Check 'expired and no refresh token: exit 1, -Login hint' (($r.Rc -eq 1) -and ($r.Out -eq '') -and ($r.Err -match '-Login'))

  Set-Content $mode 'ok'
  Set-Content (Join-Path $tmp 'gateway.json') "{`"issuer`":`"http://localhost:$port`",`"clientId`":`"cid`",`"scopes`":`"api://x/.default`",`"tokenType`":`"access_token`"}"
  Save-TokenCache $cache ([pscustomobject]@{ id_token = 'x'; access_token = (New-Jwt $past); refresh_token = 'R' })
  Remove-Item $reqLog -ErrorAction SilentlyContinue
  $r = Run-Token
  Check 'access_token mode: refresh sends the scope, prints the access token' (($r.Rc -eq 0) -and ($r.Out -eq 'A2') -and ((Get-Content $reqLog -Raw) -match 'scope=api'))
} finally {
  Stop-Job $job -ErrorAction SilentlyContinue; Remove-Job $job -Force -ErrorAction SilentlyContinue
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

"failures: $fail"
exit $fail
