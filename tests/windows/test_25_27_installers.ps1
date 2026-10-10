# scripts/windows/25_awscli.bat, 26_uv.bat, 27_volta.bat の試験（ネットワーク不要）
# 使い方: pwsh -NoProfile -File tests/windows/test_25_27_installers.ps1   （終了コード = 失敗数）
# 偽の PS_EXE（インストーラ）、偽の SETX_EXE、偽の uv / volta / scoop / python / node / npm / npx を PATH の先頭に置く。
# 実環境の環境変数（setx）と PATH の登録は変更しない。入力は標準入力のファイルで渡す。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$fail = 0

function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

# 1場面を実行する。$script: bat 名、$lines: 標準入力、$withCa: ca_bundle.crt を置くか、$noCerts: CERTS_DIR を未設定にするか、$instFail: 偽インストーラを失敗させるか
function Run-Case($script, $lines, $withCa = $true, $noCerts = $false, $instFail = $false) {
  $root = Join-Path ([IO.Path]::GetTempPath()) ("t2527-" + [guid]::NewGuid().ToString('N'))
  $bin  = Join-Path $root 'bin'
  $certs = Join-Path $root 'certs'
  New-Item -ItemType Directory -Force $bin, $certs | Out-Null
  $log = Join-Path $root 'calls.log'
  if ($withCa) { Set-Content (Join-Path $certs 'ca_bundle.crt') 'dummy' -Encoding ascii }
  # 偽のコマンド（呼ばれた名前と引数を calls.log に残す）
  foreach ($n in 'setx', 'uv', 'volta', 'scoop', 'python', 'node', 'npm', 'npx') {
    Set-Content (Join-Path $bin "$n.cmd") "@echo off`r`necho $n %* >> `"$log`"`r`necho $n 1.2.3`r`nexit /b 0" -Encoding ascii
  }
  $rc = if ($instFail) { 1 } else { 0 }
  Set-Content (Join-Path $bin 'fakeps.cmd') "@echo off`r`necho installer %* >> `"$log`"`r`nexit /b $rc" -Encoding ascii
  $old = @{ PS = $env:PS_EXE; SX = $env:SETX_EXE; PATH = $env:PATH; CD = $env:CERTS_DIR; UP = $env:USERPROFILE; SC = $env:SSL_CERT_FILE }
  try {
    $env:PS_EXE = Join-Path $bin 'fakeps.cmd'
    $env:SETX_EXE = Join-Path $bin 'setx.cmd'
    $env:USERPROFILE = $root
    $env:SSL_CERT_FILE = $null
    $env:CERTS_DIR = if ($noCerts) { $null } else { $certs }
    $env:PATH = "$bin;" + $env:PATH
    $in = Join-Path $root 'stdin.txt'
    [IO.File]::WriteAllText($in, ((@($lines) | ForEach-Object { $_ + "`r`n" }) -join ''), (New-Object Text.UTF8Encoding $false))
    $bat = Join-Path $repo "scripts\windows\$script"
    $out = (cmd /c "`"$bat`" < `"$in`" 2>&1") -join "`n"
    $rc = $LASTEXITCODE
    $calls = if (Test-Path $log) { (Get-Content $log) -join "`n" } else { '' }
  } finally {
    $env:PS_EXE = $old.PS; $env:SETX_EXE = $old.SX; $env:PATH = $old.PATH; $env:CERTS_DIR = $old.CD; $env:USERPROFILE = $old.UP; $env:SSL_CERT_FILE = $old.SC
    Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue
  }
  [pscustomobject]@{ Out = $out; Rc = $rc; Calls = $calls; Certs = $certs }
}

# ---------- 25_awscli ----------
$r = Run-Case '25_awscli.bat' @('')
Check 'aws empty = n: SKIP, exit 0, nothing run'      (($r.Out -match '\[SKIP\] AWS CLI not installed') -and ($r.Rc -eq 0) -and ($r.Calls -eq ''))
$r = Run-Case '25_awscli.bat' @('n')
Check 'aws n: nothing run'                            (($r.Rc -eq 0) -and ($r.Calls -eq ''))
$r = Run-Case '25_awscli.bat' @('y')
Check 'aws y: runs the official installer'           ($r.Calls -match 'installer .*awscli\.amazonaws\.com/v2/install\.ps1')
Check 'aws y + CA file: setx AWS_CA_BUNDLE'           ($r.Calls -match [regex]::Escape('setx AWS_CA_BUNDLE "' + (Join-Path $r.Certs 'ca_bundle.crt') + '"'))
$r = Run-Case '25_awscli.bat' @('y') $false
Check 'aws y, no CA file: [SKIP], no setx, exit 0'    (($r.Out -match '\[SKIP\] .*ca_bundle\.crt not found') -and ($r.Calls -notmatch 'setx') -and ($r.Rc -eq 0))
$r = Run-Case '25_awscli.bat' @('y') $true $true
Check 'aws y, CERTS_DIR unset: [SKIP], no setx'       (($r.Out -match '\[SKIP\] CERTS_DIR is not set') -and ($r.Calls -notmatch 'setx'))
$r = Run-Case '25_awscli.bat' @('y') $true $false $true
Check 'aws installer fails: [ERR], exit 1, no setx'   (($r.Out -match '\[ERR\] installer failed') -and ($r.Rc -eq 1) -and ($r.Calls -notmatch 'setx'))
$r = Run-Case '25_awscli.bat' @('x', 'x', 'x', 'x', 'x')
Check 'aws invalid x5: [ERR], exit 1'                 (($r.Out -match '\[ERR\] invalid answer 5 times') -and ($r.Rc -eq 1) -and ($r.Calls -eq ''))

# ---------- 26_uv ----------
$r = Run-Case '26_uv.bat' @('y')
Check 'uv y: installer runs'                          ($r.Calls -match 'installer .*astral\.sh/uv/install\.ps1')
Check 'uv y: setx UV_SYSTEM_CERTS and SSL_CERT_FILE'  (($r.Calls -match 'setx UV_SYSTEM_CERTS true') -and ($r.Calls -match 'setx SSL_CERT_FILE ".*ca_bundle\.crt"'))
Check 'uv y: python 3.13 installed as default'        ($r.Calls -match 'uv python install 3\.13 --default')
Check 'uv y: pinned globally'                         ($r.Calls -match 'uv python pin --global 3\.13')
Check 'uv y: python --version is printed'             (($r.Calls -match 'python --version') -and ($r.Out -match '\[VERSION\]') -and ($r.Out -match 'python 1\.2\.3'))
Check 'uv y: SSL setx happens before the installer'   ($r.Calls.IndexOf('setx UV_SYSTEM_CERTS') -lt $r.Calls.IndexOf('installer'))
$r = Run-Case '26_uv.bat' @('n')
Check 'uv n: still installs uv and python, no setx'   (($r.Calls -match 'installer') -and ($r.Calls -match 'uv python install 3\.13') -and ($r.Calls -notmatch 'setx'))
$r = Run-Case '26_uv.bat' @('')
Check 'uv empty = n: no setx'                         (($r.Calls -match 'installer') -and ($r.Calls -notmatch 'setx'))
$r = Run-Case '26_uv.bat' @('y') $false
Check 'uv y, no CA file: [SKIP], no setx, still installs' (($r.Out -match '\[SKIP\] .*ca_bundle\.crt not found') -and ($r.Calls -notmatch 'setx') -and ($r.Calls -match 'uv python pin'))
$r = Run-Case '26_uv.bat' @('n') $true $false $true
Check 'uv installer fails: [ERR], exit 1, no uv call' (($r.Out -match '\[ERR\] uv installer failed') -and ($r.Rc -eq 1) -and ($r.Calls -notmatch 'uv python'))
$r = Run-Case '26_uv.bat' @('x', 'x', 'x', 'x', 'x')
Check 'uv invalid x5: [ERR], exit 1, nothing run'     (($r.Rc -eq 1) -and ($r.Calls -eq ''))

# ---------- 27_volta ----------
$r = Run-Case '27_volta.bat' @('y')
Check 'volta y: scoop install volta'                  ($r.Calls -match 'scoop install volta')
Check 'volta y: setx NODE_EXTRA_CA_CERTS'             ($r.Calls -match 'setx NODE_EXTRA_CA_CERTS ".*ca_bundle\.crt"')
Check 'volta y: volta install node@lts'               ($r.Calls -match 'volta install node@lts')
Check 'volta y: node / npm / npx versions printed'    (($r.Calls -match 'node --version') -and ($r.Calls -match 'npm --version') -and ($r.Calls -match 'npx --version') -and ($r.Out -match '\[VERSION\]'))
Check 'volta y: setx happens before scoop install'    ($r.Calls.IndexOf('setx NODE_EXTRA_CA_CERTS') -lt $r.Calls.IndexOf('scoop install volta'))
$r = Run-Case '27_volta.bat' @('n')
Check 'volta n: installs and pins, no setx'           (($r.Calls -match 'volta install node@lts') -and ($r.Calls -notmatch 'setx'))
$r = Run-Case '27_volta.bat' @('y') $false
Check 'volta y, no CA file: [SKIP], no setx'          (($r.Out -match '\[SKIP\] .*ca_bundle\.crt not found') -and ($r.Calls -notmatch 'setx') -and ($r.Calls -match 'volta install'))
$r = Run-Case '27_volta.bat' @('x', 'x', 'x', 'x', 'x')
Check 'volta invalid x5: [ERR], exit 1, nothing run'  (($r.Rc -eq 1) -and ($r.Calls -notmatch 'scoop install'))

# ---------- pause と [ENV] ログ（全経路で pause して終わる） ----------
$r = Run-Case '25_awscli.bat' @('y')
Check 'aws y: [ENV] shows AWS_CA_BUNDLE value, then pause' (($r.Out -match 'AWS_CA_BUNDLE\s+=.*ca_bundle\.crt') -and ($r.Out -match 'Press any key'))
$r = Run-Case '25_awscli.bat' @('y') $false
Check 'aws no CA: [ENV] says [not set]'               ($r.Out -match 'AWS_CA_BUNDLE\s+=\[not set\]')
$r = Run-Case '25_awscli.bat' @('n')
Check 'aws n: SKIP with reason, pause'                (($r.Out -match '\[SKIP\] AWS CLI not installed \(answered n\)') -and ($r.Out -match 'Press any key'))
$r = Run-Case '25_awscli.bat' @('y') $true $false $true
Check 'aws installer fails: pause, exit 1'            (($r.Out -match 'Press any key') -and ($r.Rc -eq 1))
$r = Run-Case '25_awscli.bat' @('x', 'x', 'x', 'x', 'x')
Check 'aws invalid x5: pause, exit 1'                 (($r.Out -match 'Press any key') -and ($r.Rc -eq 1))
$r = Run-Case '26_uv.bat' @('y')
Check 'uv y: [ENV] shows both values, then pause'     (($r.Out -match 'UV_SYSTEM_CERTS\s+=true') -and ($r.Out -match 'SSL_CERT_FILE\s+=.*ca_bundle\.crt') -and ($r.Out -match 'Press any key'))
$r = Run-Case '26_uv.bat' @('n')
Check 'uv n: SKIP with reason, [ENV] not set, pause'  (($r.Out -match '\[SKIP\] SSL bundle not set \(answered n\)') -and ($r.Out -match 'UV_SYSTEM_CERTS\s+=\[not set\]') -and ($r.Out -match 'Press any key'))
$r = Run-Case '26_uv.bat' @('n') $true $false $true
Check 'uv installer fails: pause, exit 1'             (($r.Out -match 'Press any key') -and ($r.Rc -eq 1))
$r = Run-Case '26_uv.bat' @('x', 'x', 'x', 'x', 'x')
Check 'uv invalid x5: pause, exit 1'                  (($r.Out -match 'Press any key') -and ($r.Rc -eq 1))
$r = Run-Case '27_volta.bat' @('y')
Check 'volta y: [ENV] shows NODE_EXTRA_CA_CERTS, then pause' (($r.Out -match 'NODE_EXTRA_CA_CERTS=.*ca_bundle\.crt') -and ($r.Out -match 'Press any key'))
$r = Run-Case '27_volta.bat' @('n')
Check 'volta n: SKIP with reason, [ENV] not set, pause' (($r.Out -match '\[SKIP\] SSL bundle not set \(answered n\)') -and ($r.Out -match 'NODE_EXTRA_CA_CERTS=\[not set\]') -and ($r.Out -match 'Press any key'))
$r = Run-Case '27_volta.bat' @('x', 'x', 'x', 'x', 'x')
Check 'volta invalid x5: pause, exit 1'               (($r.Out -match 'Press any key') -and ($r.Rc -eq 1))

# ---------- 共通の点検 ----------
$p = Get-Content (Join-Path $repo 'windows\powershell\profile.ps1') -Raw
Check 'profile.ps1 no longer sets NODE_EXTRA_CA_CERTS' ($p -notmatch 'env:NODE_EXTRA_CA_CERTS\s*=')
$e = Get-Content (Join-Path $repo 'scripts\windows\10_env.bat') -Raw
Check '10_env.bat prints the CA bundle reminder before the final pause' ($e -match '(?s)ACTION NEEDED.*ca_bundle\.crt.*pause\s*$')

"failures=$fail"
exit $fail
