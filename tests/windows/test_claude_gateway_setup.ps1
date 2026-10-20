# windows/claude/claude-gateway-setup.ps1（設定の生成）と claude-acp-gateway.ps1（Zed の起動用）の試験（ネットワーク・AWS 不要）
# 使い方: pwsh -NoProfile -File tests/windows/test_claude_gateway_setup.ps1   （終了コード = 失敗数）
# 設定の出力先（-ConfigDir）は一時ディレクトリ。実環境の ~/.claude-gateway には触れない。Zed の起動用は、偽の HOME と偽の npx.cmd で試験する。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script = Join-Path $repo 'windows\claude\claude-gateway-setup.ps1'
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
Check 'url: path kept without trailing slash'    ((ConvertTo-GatewayUrl 'https://gw.example.com/claude/') -eq 'https://gw.example.com/claude')
Check 'url: http rejected'                       ($null -eq (ConvertTo-GatewayUrl 'http://gw.example.com'))
Check 'url: http on loopback accepted'           ((ConvertTo-GatewayUrl 'http://localhost:8080') -eq 'http://localhost:8080')
Check 'url: not a URL rejected'                  (($null -eq (ConvertTo-GatewayUrl 'gw.example.com')) -and ($null -eq (ConvertTo-GatewayUrl '')))
$s = New-GatewaySettings 'https://gw.example.com'
Check 'settings: login keys only' ((($s.Keys -join ',') -eq 'forceLoginMethod,forceLoginGatewayUrl') -and ($s.forceLoginMethod -eq 'gateway'))

# --- スクリプトの実行（標準入力は空 = 非対話） ---
function Run-Script($argList) {
  $out = ($null | & $pwsh -NoProfile -File $script @argList 2>&1) -join "`n"
  [pscustomobject]@{ Out = $out; Rc = $LASTEXITCODE }
}
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("tgateway-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $tmp | Out-Null
$dir = Join-Path $tmp 'cfg'
$file = Join-Path $dir 'settings.json'
try {
  $r = Run-Script @('-Url', 'https://gw.example.com/', '-ConfigDir', $dir)
  $j = if (Test-Path $file) { Get-Content $file -Raw | ConvertFrom-Json } else { $null }
  Check 'run: exit 0 and file written' (($r.Rc -eq 0) -and $j)
  Check 'run: gateway keys'            (($j.forceLoginMethod -eq 'gateway') -and ($j.forceLoginGatewayUrl -eq 'https://gw.example.com'))

  $before = Get-Content $file -Raw
  $r = Run-Script @('-Url', 'https://other.example.com', '-ConfigDir', $dir)
  Check 'exists (non-interactive, no -Force): refuses' (($r.Rc -eq 1) -and ($r.Out -match '-Force') -and ((Get-Content $file -Raw) -eq $before))
  $r = Run-Script @('-Url', 'https://other.example.com', '-ConfigDir', $dir, '-Force')
  Check 'force: overwrites' (($r.Rc -eq 0) -and ((Get-Content $file -Raw | ConvertFrom-Json).forceLoginGatewayUrl -eq 'https://other.example.com'))

  Remove-Item $file
  $r = Run-Script @('-Url', 'https://gw.example.com', '-ConfigDir', $dir, '-DryRun')
  Check 'dry-run: prints JSON, writes nothing' (($r.Rc -eq 0) -and ($r.Out -match 'forceLoginGatewayUrl') -and -not (Test-Path $file))

  $r = Run-Script @('-ConfigDir', $dir)
  Check 'no -Url, non-interactive: error, exit 1' (($r.Rc -eq 1) -and ($r.Out -match '-Url') -and -not (Test-Path $file))
  $r = Run-Script @('-Url', 'http://gw.example.com', '-ConfigDir', $dir)
  Check 'invalid URL: rejected, nothing written' (($r.Rc -eq 1) -and -not (Test-Path $file))

  # --- Zed の起動用 ---
  # 偽の HOME は環境変数 USERPROFILE（Windows の pwsh の $HOME）で渡す。偽の npx.cmd は CLAUDE_CONFIG_DIR を記録する
  $bin = Join-Path $tmp 'bin'; New-Item -ItemType Directory -Force $bin | Out-Null
  $log = Join-Path $tmp 'npx.log'
  Set-Content (Join-Path $bin 'npx.cmd') "@echo off`r`necho %CLAUDE_CONFIG_DIR% %*>>`"$log`"`r`nexit /b 3"
  $fakeHome = Join-Path $tmp 'home'; New-Item -ItemType Directory -Force $fakeHome | Out-Null
  $oldPath = $env:PATH; $oldHome = $env:USERPROFILE
  try {
    $env:PATH = $bin + ';' + $env:PATH; $env:USERPROFILE = $fakeHome
    $null | & $pwsh -NoProfile -File $launch 2>$null
    Check 'acp: no settings -> exit 1, agent not started' (($LASTEXITCODE -eq 1) -and -not (Test-Path $log))
    New-Item -ItemType Directory -Force (Join-Path $fakeHome '.claude-gateway') | Out-Null
    Set-Content (Join-Path $fakeHome '.claude-gateway\settings.json') '{}'
    $null | & $pwsh -NoProfile -File $launch 2>$null
    $logged = if (Test-Path $log) { Get-Content $log -Raw } else { '' }
    Check 'acp: CLAUDE_CONFIG_DIR set, agent started, exit code passed through' (($LASTEXITCODE -eq 3) -and ($logged -match [regex]::Escape((Join-Path $fakeHome '.claude-gateway'))) -and ($logged -match 'claude-agent-acp'))
  } finally { $env:PATH = $oldPath; $env:USERPROFILE = $oldHome }
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

"failures: $fail"
exit $fail
