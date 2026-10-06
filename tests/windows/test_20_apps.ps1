# scripts/windows/20_apps.bat の試験（dry-run。ネットワークも実インストールも使わない）
# 使い方: pwsh -NoProfile -File tests/windows/test_20_apps.ps1   （終了コード = 失敗数）
# 偽の USERPROFILE と、偽の powershell.exe（PS_EXE で差し替え）・偽の scoop.cmd だけを使う。実環境の scoop や PATH は変更しない。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$bat  = Join-Path $repo 'scripts\windows\20_apps.bat'
$fail = 0

function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

# 1場面を実行して、出力と偽コマンドの呼び出し記録を返す。$psExit: 偽 powershell の終了コード、$withScoop: 最初から scoop があるか
function Run-Case($psExit, $withScoop) {
  $root = Join-Path ([IO.Path]::GetTempPath()) ("t20apps-" + [guid]::NewGuid().ToString('N'))
  $home_ = Join-Path $root 'home'; $shims = Join-Path $home_ 'scoop\shims'
  New-Item -ItemType Directory -Force $shims | Out-Null
  $log = Join-Path $root 'calls.log'

  # 偽の scoop.cmd: 引数を記録するだけ
  $scoopStub = "@echo off`r`necho scoop %*>>`"$log`"`r`nexit /b 0`r`n"
  if ($withScoop) { Set-Content (Join-Path $shims 'scoop.cmd') $scoopStub -Encoding ascii }

  # 偽の powershell.exe: 引数を記録し、成功時は scoop.cmd を作る（本物のインストーラの代わり）
  $psStub = Join-Path $root 'fakeps.cmd'
  $body = "@echo off`r`necho ps %*>>`"$log`"`r`n"
  if ($psExit -eq 0) { $body += "> `"$shims\scoop.cmd`" echo @echo off`r`n>> `"$shims\scoop.cmd`" echo echo scoop %%*^>^>`"$log`"`r`n" }
  $body += "exit /b $psExit`r`n"
  Set-Content $psStub $body -Encoding ascii

  $old = @{ UP = $env:USERPROFILE; PS = $env:PS_EXE; PATH = $env:PATH }
  try {
    $env:USERPROFILE = $home_; $env:PS_EXE = $psStub
    $out = (cmd /c "`"$bat`" < nul 2>&1") -join "`n"
    $calls = if (Test-Path $log) { Get-Content $log -Raw } else { '' }
  } finally {
    $env:USERPROFILE = $old.UP; $env:PS_EXE = $old.PS; $env:PATH = $old.PATH
    Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue
  }
  [pscustomobject]@{ Out = $out; Calls = $calls }
}

# 1. scoop が無い・インストーラ成功 → 公式手順のコマンドで呼び、続けて scoop install に進む
$r = Run-Case 0 $false
Check 'no scoop: installer is invoked'             ($r.Out -match 'Scoop not found')
Check 'no scoop: sets RemoteSigned for CurrentUser' ($r.Calls -match 'Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser')
Check 'no scoop: policy is changed only when needed' ($r.Calls -match "-in 'Restricted','AllSigned','Undefined'")
Check 'no scoop: fetches get.scoop.sh'             ($r.Calls -match 'get\.scoop\.sh')
Check 'no scoop: no -ExecutionPolicy Bypass flag'  ($r.Calls -notmatch '-ExecutionPolicy Bypass')
Check 'no scoop: proceeds to scoop install'        ($r.Calls -match 'scoop install')
Check 'no scoop: no [ERROR]'                       ($r.Out -notmatch '\[ERROR\]')

# 2. scoop が無い・インストーラ失敗 → [ERROR] と実行ポリシーの一覧を出して止まる（scoop は呼ばない）
$r = Run-Case 1 $false
Check 'failure: prints [ERROR] Scoop install failed' ($r.Out -match '\[ERROR\] Scoop install failed')
Check 'failure: dumps Get-ExecutionPolicy -List'     ($r.Calls -match 'Get-ExecutionPolicy -List')
Check 'failure: scoop is not called'                 ($r.Calls -notmatch 'scoop ')

# 3. scoop がある → インストーラは呼ばない
$r = Run-Case 0 $true
Check 'scoop present: installer is not invoked' ($r.Calls -notmatch 'get\.scoop\.sh')
Check 'scoop present: proceeds to scoop install' ($r.Calls -match 'scoop install')

# 4. バット内の PowerShell 部分を実際に取り出し、Set-ExecutionPolicy / Invoke-RestMethod を偽物（関数）に差し替えて分岐を試験する。
#    実効ポリシーは powershell.exe の -ExecutionPolicy（Process スコープ）で作る。実機のレジストリは変えない。
$snippet = ((Get-Content $bat) | Where-Object { $_ -match 'Set-ExecutionPolicy' -and $_ -match 'call "%PS_EXE%"' } | Select-Object -First 1) -replace '^.*-NoProfile -Command "(.*)"\s*$', '$1'
$realPs = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
function Run-Snippet($policy, $setThrows) {
  $mock = "`$global:log=@(); function Set-ExecutionPolicy { `$global:log += 'set'; if ($(if ($setThrows) {'$true'} else {'$false'})) { throw 'denied' } }; " +
          "function Invoke-RestMethod { `$global:log += 'irm'; '' }; function Invoke-Expression { `$global:log += 'iex' }; "
  $out = & $realPs -NoProfile -ExecutionPolicy $policy -Command ($mock + $snippet + "; 'LOG=' + (`$global:log -join ',')") 2>&1
  ($out | Out-String)
}
foreach ($p in 'Restricted', 'AllSigned') {
  $o = Run-Snippet $p $false
  Check "snippet: $p -> sets policy then installs" ($o -match 'LOG=set,irm,iex')
}
foreach ($p in 'RemoteSigned', 'Unrestricted', 'Bypass') {
  $o = Run-Snippet $p $false
  Check "snippet: $p -> leaves policy alone" ($o -match 'LOG=irm,iex')
}
$o = Run-Snippet 'Restricted' $true
Check 'snippet: set fails -> warns and still installs' (($o -match 'Set-ExecutionPolicy failed: denied') -and ($o -match 'LOG=set,irm,iex'))

"RESULT: failures=$fail"
exit $fail
