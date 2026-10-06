# scripts/windows/11_git_identity.bat の試験（ネットワーク不要）
# 使い方: pwsh -NoProfile -File tests/windows/test_11_git_identity.ps1   （終了コード = 失敗数）
# 偽の USERPROFILE だけを使い、実環境の ~/.gitconfig_local や git の設定は変更しない。入力は標準入力に流す。git は実物を使う。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$bat  = Join-Path $repo 'scripts\windows\11_git_identity.bat'
$fail = 0

function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

# 1場面を実行する。$lines: 標準入力の各行、$existing: 事前に置く .gitconfig_local の内容（$null = 無し）、$noGit: PATH から git を外す
function Run-Case($lines, $existing = $null, $noGit = $false) {
  $root = Join-Path ([IO.Path]::GetTempPath()) ("t11git-" + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force $root | Out-Null
  $local = Join-Path $root '.gitconfig_local'
  if ($null -ne $existing) { Set-Content $local $existing -Encoding ascii }
  $old = @{ UP = $env:USERPROFILE; PATH = $env:PATH }
  try {
    $env:USERPROFILE = $root
    if ($noGit) { $env:PATH = Join-Path $env:SystemRoot 'System32' }
    # set /p はパイプだと2行目以降を取りこぼすので、入力はファイルのリダイレクトで渡す（空配列 = 空ファイル = 入力が尽きた状態）
    $in = Join-Path $root 'stdin.txt'
    [IO.File]::WriteAllText($in, ((@($lines) | ForEach-Object { $_ + "`r`n" }) -join ''), (New-Object Text.UTF8Encoding $false))
    $out = (cmd /c "`"$bat`" < `"$in`" 2>&1") -join "`n"
    $rc = $LASTEXITCODE
    $content = if (Test-Path $local) { Get-Content $local -Raw } else { $null }
  } finally {
    $env:USERPROFILE = $old.UP; $env:PATH = $old.PATH
    Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue
  }
  [pscustomobject]@{ Out = $out; Rc = $rc; File = $content }
}

# 1. 新規作成: user.name / user.email と credential の設定が入る
$r = Run-Case @('Taro Yamada', 'taro@example.com')
Check 'create: exit 0'                       ($r.Rc -eq 0)
Check 'create: [DONE]'                       ($r.Out -match '\[DONE\] created')
Check 'create: user.name written'            ($r.File -match 'name = Taro Yamada')
Check 'create: user.email written'           ($r.File -match 'email = taro@example.com')
Check 'create: helperselector = manager'     (($r.File -match '\[credential "helperselector"\]') -and ($r.File -match 'selected = manager'))

# 2. 既にある: 触らない
$r = Run-Case @('x', 'x@y.z') "[user]`n`tname = keep`n"
Check 'exists: [SKIP] and exit 0'            (($r.Out -match '\[SKIP\] already exists') -and ($r.Rc -eq 0))
Check 'exists: file unchanged'               (($r.File -match 'name = keep') -and ($r.File -notmatch 'x@y\.z'))

# 3. 空の入力は再入力
$r = Run-Case @('', 'Hanako', '', 'hanako@example.com')
Check 'empty name -> warns and asks again'   (($r.Out -match 'user\.name must not be empty') -and ($r.File -match 'name = Hanako'))
Check 'empty email -> warns and asks again'  (($r.Out -match 'user\.email must not be empty') -and ($r.File -match 'email = hanako@example.com'))

# 4. @ の無いメールは再入力
$r = Run-Case @('Jiro', 'not-an-email', 'jiro@example.com')
Check 'email without @ -> warns and asks again' (($r.Out -match 'should contain "@"') -and ($r.File -match 'email = jiro@example.com') -and ($r.File -notmatch 'not-an-email'))

# 5. cmd の特殊文字を含む名前がそのまま入る（& % など）
$r = Run-Case @('A & B 100%', 'ab@example.com')
Check 'special characters in name are kept'  ($r.File -match 'name = A & B 100%')

# 6. git が無い → [ERR]、ファイルは作らない
$r = Run-Case @('x', 'x@y.z') $null $true
Check 'no git: [ERR] and exit 1'            (($r.Out -match '\[ERR\] git not found') -and ($r.Rc -eq 1))
Check 'no git: no file created'              ($null -eq $r.File)

# 7. 入力が尽きた（標準入力が閉じている）→ 無限ループせず、5回で [ERR] と exit 1、ファイルは作らない
$r = Run-Case @()
Check 'closed stdin: gives up with [ERR] and exit 1' (($r.Out -match '\[ERR\] no valid input after 5 tries') -and ($r.Rc -eq 1))
Check 'closed stdin: no file created'                ($null -eq $r.File)

"RESULT: failures=$fail"
exit $fail
