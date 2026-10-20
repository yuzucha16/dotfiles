# windows/claude/claude-gateway-setup.ps1（設定の生成）と claude-acp-gateway.ps1（Zed の起動用）の試験（ネットワーク・AWS 不要）
# 使い方: pwsh -NoProfile -File tests/windows/test_claude_gateway_setup.ps1   （終了コード = 失敗数）
# 設定の出力先（-ConfigDir）は一時ディレクトリ。実環境の ~/.claude-gateway には触れない。Zed の起動用は、偽の USERPROFILE と偽の npx.cmd で試験する。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script = Join-Path $repo 'windows\claude\claude-gateway-setup.ps1'
$token = Join-Path $repo 'windows\claude\claude-gateway-token.ps1'
$launch = Join-Path $repo 'windows\claude\claude-acp-gateway.ps1'
$pwsh = (Get-Command pwsh).Source
$fail = 0
function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

# --- 関数の試験 ---
. $script
Check 'url: https accepted'                      ((ConvertTo-GatewayUrl 'https://gw.example.com') -eq 'https://gw.example.com')
Check 'url: trailing slash and spaces removed'   ((ConvertTo-GatewayUrl '  https://gw.example.com/ ') -eq 'https://gw.example.com')
Check 'url: path kept without trailing slash'    ((ConvertTo-GatewayUrl 'https://login.example.com/tenant/v2.0/') -eq 'https://login.example.com/tenant/v2.0')
Check 'url: http rejected'                       ($null -eq (ConvertTo-GatewayUrl 'http://gw.example.com'))
Check 'url: http on loopback accepted'           ((ConvertTo-GatewayUrl 'http://localhost:8080') -eq 'http://localhost:8080')
Check 'url: not a URL rejected'                  (($null -eq (ConvertTo-GatewayUrl 'gw.example.com')) -and ($null -eq (ConvertTo-GatewayUrl '')))
$c = New-GatewayConfig 'https://i.example.com/v2.0' 'cid' '' 'id_token'
Check 'config: no scopes key when empty'         (($c.Keys -join ',') -eq 'issuer,clientId,tokenType')
$c = New-GatewayConfig 'https://i.example.com/v2.0' 'cid' 'api://x/.default' 'access_token'
Check 'config: scopes and token type'            (($c.scopes -eq 'api://x/.default') -and ($c.tokenType -eq 'access_token'))
$c = New-GatewayConfig 'https://i.example.com/v2.0' 'cid' '' 'id_token' 53180
Check 'config: redirectPort only when given'     (($c.redirectPort -eq 53180) -and -not (New-GatewayConfig 'i' 'c' '' 'id_token').Contains('redirectPort'))
$s = New-GatewaySettings 'https://gw.example.com' '' '' '' ''
Check 'settings: apiKeyHelper and base URL, no pins' (($s.apiKeyHelper -eq 'claude-gateway-token.cmd') -and ($s.env.ANTHROPIC_BASE_URL -eq 'https://gw.example.com') -and -not $s.env.Contains('ANTHROPIC_DEFAULT_SONNET_MODEL') -and -not $s.Contains('model'))
$s = New-GatewaySettings 'https://gw.example.com' 'o-id' 's-id' 'h-id' 'sonnet'
Check 'settings: model pins and default model'   (($s.env.ANTHROPIC_DEFAULT_OPUS_MODEL -eq 'o-id') -and ($s.env.ANTHROPIC_DEFAULT_SONNET_MODEL -eq 's-id') -and ($s.env.ANTHROPIC_DEFAULT_HAIKU_MODEL -eq 'h-id') -and ($s.model -eq 'sonnet'))
$sh = Join-Path ([IO.Path]::GetTempPath()) ("tshared-" + [guid]::NewGuid().ToString('N') + '.json')
Set-Content $sh '{"theme":"dark","permissions":{"allow":["Read(x)"]},"hooks":{"Stop":[]},"apiKeyHelper":"evil","env":{"ANTHROPIC_BASE_URL":"https://other"},"model":"opus"}'
$m = Merge-SharedSettings (New-GatewaySettings 'https://gw.example.com' '' '' '' '') $sh
Check 'shared: theme/permissions/hooks copied'   (($m.theme -eq 'dark') -and ($m.permissions.allow[0] -eq 'Read(x)') -and $m.Contains('hooks'))
Check 'shared: apiKeyHelper/env/model not overridden' (($m.apiKeyHelper -eq 'claude-gateway-token.cmd') -and ($m.env.ANTHROPIC_BASE_URL -eq 'https://gw.example.com') -and -not $m.Contains('model'))
Check 'shared: missing file leaves settings as is' ((Merge-SharedSettings (New-GatewaySettings 'https://gw.example.com' '' '' '' '') 'Z:\nope.json').Count -eq 2)
Remove-Item $sh

# --- スクリプトの実行（標準入力は空 = 非対話） ---
function Run-Script($argList) {
  $out = ($null | & $pwsh -NoProfile -File $script @argList 2>&1) -join "`n"
  [pscustomobject]@{ Out = $out; Rc = $LASTEXITCODE }
}
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("tgateway-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $tmp | Out-Null
$dir = Join-Path $tmp 'cfg'
$cfgFile = Join-Path $dir 'gateway.json'
$setFile = Join-Path $dir 'settings.json'
$base = @('-BaseUrl', 'https://gw.example.com/', '-Issuer', 'https://login.example.com/tenant/v2.0', '-ClientId', '11111111-2222-3333-4444-555555555555', '-Scopes', '', '-RedirectPort', '53180', '-SonnetId', 'gw-sonnet', '-Model', 'sonnet', '-ConfigDir', $dir)
try {
  $r = Run-Script $base
  $j = if (Test-Path $cfgFile) { Get-Content $cfgFile -Raw | ConvertFrom-Json } else { $null }
  $js = if (Test-Path $setFile) { Get-Content $setFile -Raw | ConvertFrom-Json } else { $null }
  Check 'run: exit 0 and both files written' (($r.Rc -eq 0) -and $j -and $js)
  Check 'run: gateway.json values'           (($j.issuer -eq 'https://login.example.com/tenant/v2.0') -and ($j.clientId -eq '11111111-2222-3333-4444-555555555555') -and ($j.tokenType -eq 'id_token') -and ($null -eq $j.scopes))
  Check 'run: redirectPort in gateway.json'  ($j.redirectPort -eq 53180)
  Check 'run: settings.json values'          (($js.env.ANTHROPIC_BASE_URL -eq 'https://gw.example.com') -and ($js.apiKeyHelper -eq 'claude-gateway-token.cmd') -and ($js.env.ANTHROPIC_DEFAULT_SONNET_MODEL -eq 'gw-sonnet') -and ($js.model -eq 'sonnet') -and ($null -eq $js.env.ANTHROPIC_DEFAULT_OPUS_MODEL))
  Check 'run: no secrets or login keys'      (-not ((Get-Content $setFile -Raw) -match 'forceLogin|token"|secret'))

  $before = Get-Content $cfgFile -Raw
  $r = Run-Script ($base + '-TokenType', 'access_token')
  Check 'exists (non-interactive, no -Force): refuses' (($r.Rc -eq 1) -and ($r.Out -match '-Force') -and ((Get-Content $cfgFile -Raw) -eq $before))
  $r = Run-Script ($base + @('-TokenType', 'access_token', '-Force'))
  Check 'force: overwrites' (($r.Rc -eq 0) -and ((Get-Content $cfgFile -Raw | ConvertFrom-Json).tokenType -eq 'access_token'))

  Remove-Item $cfgFile, $setFile
  $r = Run-Script ($base + '-DryRun')
  Check 'dry-run: prints JSON, writes nothing' (($r.Rc -eq 0) -and ($r.Out -match 'issuer') -and ($r.Out -match 'apiKeyHelper') -and -not (Test-Path $cfgFile) -and -not (Test-Path $setFile))

  $r = Run-Script @('-ConfigDir', $dir)
  Check 'no -BaseUrl, non-interactive: error, exit 1' (($r.Rc -eq 1) -and ($r.Out -match '-BaseUrl') -and -not (Test-Path $cfgFile))
  $r = Run-Script @('-BaseUrl', 'http://gw.example.com', '-Issuer', 'https://i.example.com', '-ClientId', 'c', '-Scopes', '', '-ConfigDir', $dir)
  Check 'http base URL: rejected, nothing written' (($r.Rc -eq 1) -and -not (Test-Path $cfgFile))
  $r = Run-Script @('-BaseUrl', 'https://gw.example.com', '-Issuer', 'https://i.example.com/.well-known/openid-configuration', '-ClientId', 'c', '-Scopes', '', '-ConfigDir', $dir)
  Check 'issuer with .well-known: rejected'       (($r.Rc -eq 1) -and -not (Test-Path $cfgFile))

  # --- Zed の起動用 ---
  # 偽の HOME は環境変数 USERPROFILE（Windows の pwsh の $HOME）で渡す。偽の npx.cmd は CLAUDE_CONFIG_DIR を記録する
  . $token -ConfigDir $dir        # トークンの保管関数を借りて、有効なトークンの保管ファイルを作る（試験用）
  $bin = Join-Path $tmp 'bin'; New-Item -ItemType Directory -Force $bin | Out-Null
  $log = Join-Path $tmp 'npx.log'
  Set-Content (Join-Path $bin 'npx.cmd') "@echo off`r`necho %CLAUDE_CONFIG_DIR% %*>>`"$log`"`r`nexit /b 3"
  $fakeHome = Join-Path $tmp 'home'; New-Item -ItemType Directory -Force $fakeHome | Out-Null
  $gw = Join-Path $fakeHome '.claude-gateway'
  $oldPath = $env:PATH; $oldHome = $env:USERPROFILE
  try {
    $env:PATH = $bin + ';' + $env:PATH; $env:USERPROFILE = $fakeHome
    $null | & $pwsh -NoProfile -File $launch 2>$null
    Check 'acp: no settings -> exit 1, agent not started' (($LASTEXITCODE -eq 1) -and -not (Test-Path $log))

    New-Item -ItemType Directory -Force $gw | Out-Null
    Set-Content (Join-Path $gw 'settings.json') '{}'
    Set-Content (Join-Path $gw 'gateway.json') '{"issuer":"https://i.example.com","clientId":"c","tokenType":"id_token"}'
    $null | & $pwsh -NoProfile -File $launch 2>$null
    Check 'acp: no token -> exit 1, agent not started' (($LASTEXITCODE -eq 1) -and -not (Test-Path $log))

    $exp = [DateTimeOffset]::UtcNow.AddHours(1).ToUnixTimeSeconds()
    $jwt = 'e30.' + (ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes("{`"exp`":$exp}"))) + '.sig'
    Save-TokenCache (Join-Path $gw 'token.dpapi') ([pscustomobject]@{ id_token = $jwt; access_token = ''; refresh_token = 'r' })
    $null | & $pwsh -NoProfile -File $launch 2>$null
    $logged = if (Test-Path $log) { Get-Content $log -Raw } else { '' }
    Check 'acp: token ok -> CLAUDE_CONFIG_DIR set, agent started, exit code passed through' (($LASTEXITCODE -eq 3) -and ($logged -match [regex]::Escape($gw)) -and ($logged -match 'claude-agent-acp'))
  } finally { $env:PATH = $oldPath; $env:USERPROFILE = $oldHome }
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

"failures: $fail"
exit $fail
