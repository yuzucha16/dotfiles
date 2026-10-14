# scripts/windows/28_npm_globals.bat, 29_claude_plugins.bat の試験（ネットワーク不要）
# 使い方: pwsh -NoProfile -File tests/windows/test_28_29_installers.ps1   （終了コード = 失敗数）
# 偽の volta / claude を PATH の先頭に置く。実環境の claude / volta と ~\.claude は呼ばない。
# 試験の前に、各スクリプトが PATH を書き換えて偽物より先に本物を見つけないことを確認する（29 で実際に起きた）。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$fail = 0

function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

# $script: bat 名、$fakes: 置く偽コマンド名、$failOn: この文字列を含む呼び出しを失敗させる
function Run-Case($script, $fakes, $failOn = '') {
  $root = Join-Path ([IO.Path]::GetTempPath()) ("t2829-" + [guid]::NewGuid().ToString('N'))
  $bin = Join-Path $root 'bin'
  New-Item -ItemType Directory -Force $bin | Out-Null
  $log = Join-Path $root 'calls.log'
  foreach ($n in $fakes) {
    $body = "@echo off`r`necho $n %*>> `"$log`"`r`n"
    if ($failOn) { $body += "echo %*| findstr /C:`"$failOn`" >nul && exit /b 1`r`n" }
    $body += "exit /b 0"
    Set-Content (Join-Path $bin "$n.cmd") $body -Encoding ascii
  }
  $old = @{ PATH = $env:PATH; UP = $env:USERPROFILE }
  try {
    $env:USERPROFILE = $root
    $env:PATH = "$bin;" + $env:PATH
    $bat = Join-Path $repo "scripts\windows\$script"
    $out = (cmd /c "`"$bat`" < NUL 2>&1") -join "`n"
    $rc = $LASTEXITCODE
    $calls = if (Test-Path $log) { (Get-Content $log) -join "`n" } else { '' }
  } finally {
    $env:PATH = $old.PATH; $env:USERPROFILE = $old.UP
    Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue
  }
  [pscustomobject]@{ Out = $out; Rc = $rc; Calls = $calls }
}

# ---------- 28_npm_globals ----------
$r = Run-Case '28_npm_globals.bat' @('volta')
Check 'npm: installs defuddle and knap with volta install'  (($r.Calls -match 'volta install defuddle') -and ($r.Calls -match 'volta install knap') -and ($r.Rc -eq 0))
$r = Run-Case '28_npm_globals.bat' @('volta') 'defuddle'
Check 'npm: one failure continues, exit 1'                  (($r.Calls -match 'volta install knap') -and ($r.Rc -eq 1))

# ---------- 29_claude_plugins ----------
$r = Run-Case '29_claude_plugins.bat' @('claude')
Check 'plugins: marketplace add then install (fake claude)' (($r.Calls -match 'claude plugin marketplace add kepano/obsidian-skills') -and ($r.Calls -match 'claude plugin install obsidian@obsidian-skills') -and ($r.Rc -eq 0))
$r = Run-Case '29_claude_plugins.bat' @('claude') 'marketplace add'
Check 'plugins: add failure skips install, exit 1'          (($r.Calls -notmatch 'plugin install') -and ($r.Rc -eq 1))
$r = Run-Case '29_claude_plugins.bat' @('claude') 'plugin install'
Check 'plugins: install failure, exit 1'                    ($r.Rc -eq 1)

"failures=$fail"
exit $fail
