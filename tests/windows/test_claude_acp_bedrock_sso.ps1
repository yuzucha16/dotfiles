# windows/claude/claude-acp-bedrock-sso.ps1（Zed の「Claude Bedrock SSO」の起動用）の試験
# 使い方: pwsh -NoProfile -File tests/windows/test_claude_acp_bedrock_sso.ps1   （終了コード = 失敗数）
# 偽の aws.cmd / npx.cmd を PATH の先頭に置く。呼び出しは一時ファイルに記録する。実環境の AWS にも ~/.aws にも触れない。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script = Join-Path $repo 'windows\claude\claude-acp-bedrock-sso.ps1'
$pwsh = (Get-Command pwsh).Source
$fail = 0
function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("tacpsso-" + [guid]::NewGuid().ToString('N'))
$bin = Join-Path $tmp 'bin'
New-Item -ItemType Directory -Force $bin | Out-Null
$log = Join-Path $tmp 'calls.log'
# 偽の aws: 呼び出しを記録する。FAKE_STS_RC が sts の終了コード、FAKE_LOGIN_RC が sso login の終了コード
Set-Content (Join-Path $bin 'aws.cmd') @'
@echo off
echo aws %*>>"%FAKE_LOG%"
if "%1 %2"=="sts get-caller-identity" exit /b %FAKE_STS_RC%
if "%1 %2"=="sso login" ( echo login-output & exit /b %FAKE_LOGIN_RC% )
exit /b 0
'@
Set-Content (Join-Path $bin 'npx.cmd') @'
@echo off
echo npx %*>>"%FAKE_LOG%"
exit /b %FAKE_NPX_RC%
'@

function Run-Launch($awsProfile, $sts, $login, $npx = 0) {
  Remove-Item $log -ErrorAction SilentlyContinue
  $old = @{ PATH = $env:PATH; P = $env:AWS_PROFILE }
  try {
    $env:PATH = $bin + ';' + (Split-Path $pwsh) + ';' + (Join-Path $env:SystemRoot 'System32')
    if ($awsProfile) { $env:AWS_PROFILE = $awsProfile } else { Remove-Item Env:AWS_PROFILE -ErrorAction SilentlyContinue }
    $env:FAKE_LOG = $log; $env:FAKE_STS_RC = "$sts"; $env:FAKE_LOGIN_RC = "$login"; $env:FAKE_NPX_RC = "$npx"
    $stdout = & $pwsh -NoProfile -File $script 2>"$tmp\err.txt"
    $rc = $LASTEXITCODE
    [pscustomobject]@{ Out = ($stdout -join "`n"); Err = "$(Get-Content "$tmp\err.txt" -Raw)"; Rc = $rc; Calls = if (Test-Path $log) { @(Get-Content $log) } else { @() } }
  } finally {
    $env:PATH = $old.PATH
    if ($old.P) { $env:AWS_PROFILE = $old.P } else { Remove-Item Env:AWS_PROFILE -ErrorAction SilentlyContinue }
  }
}

try {
  $r = Run-Launch 'db-trial' 0 0
  Check 'valid credentials: no login, agent started' (($r.Rc -eq 0) -and (-not ($r.Calls -match 'sso login')) -and ($r.Calls -match '^npx -y @agentclientprotocol/claude-agent-acp'))
  Check 'valid credentials: sts is checked with the profile' ($r.Calls[0] -eq 'aws sts get-caller-identity --profile db-trial')

  $r = Run-Launch 'db-trial' 255 0
  Check 'expired: aws sso login --profile, then the agent' (($r.Rc -eq 0) -and ($r.Calls[1] -eq 'aws sso login --profile db-trial') -and ($r.Calls[2] -match '^npx '))
  Check 'expired: login output goes to stderr, stdout stays clean (ACP protocol)' (($r.Out -eq '') -and ($r.Err -match 'login-output'))

  $r = Run-Launch 'db-trial' 255 1
  Check 'login failed: exit 1, agent not started' (($r.Rc -eq 1) -and (-not ($r.Calls -match '^npx ')) -and ($r.Err -match 'login failed'))

  $r = Run-Launch '' 0 0
  Check 'empty AWS_PROFILE: exit 1, nothing called' (($r.Rc -eq 1) -and ($r.Calls.Count -eq 0) -and ($r.Err -match 'AWS_PROFILE'))

  $r = Run-Launch 'db-trial' 0 0 3
  Check 'agent exit code is passed through' ($r.Rc -eq 3)
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

"failures: $fail"
exit $fail
