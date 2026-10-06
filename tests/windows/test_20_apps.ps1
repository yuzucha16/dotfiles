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

"RESULT: failures=$fail"
exit $fail
