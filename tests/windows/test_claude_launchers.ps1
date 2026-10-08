# windows/powershell/profile.ps1 の Claude Code 起動関数（claude-api / claude-bedrock / claude-oauth / claude-pick）の試験
# 使い方: pwsh -NoProfile -File tests/windows/test_claude_launchers.ps1   （終了コード = 失敗数）
# プロファイルは丸ごとは読まず（starship などが要る）、AST で対象の関数だけを取り出して定義する。偽の claude / fzf を使い、実環境の ~/.claude にも環境変数にも触れない。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$profilePath = Join-Path $repo 'windows\powershell\profile.ps1'
$fail = 0
function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

$fakeHome = Join-Path ([IO.Path]::GetTempPath()) ("tlaunch-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force (Join-Path $fakeHome '.claude') | Out-Null

# 関数を取り出して定義する。$HOME は偽のディレクトリ（$fakeHome）に置き換える（$HOME は書き換えられないため）
$ast = [System.Management.Automation.Language.Parser]::ParseFile($profilePath, [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -in 'claude-api', 'claude-bedrock', 'claude-oauth', 'claude-pick' }, $true)
Check 'profile defines the 4 launcher functions' ($defs.Count -eq 4)
foreach ($d in $defs) { Invoke-Expression ($d.Extent.Text.Replace('$HOME', '$fakeHome')) }

# 偽の claude: 受け取った引数と、認証に関わる環境変数の見え方を記録する
$script:calls = @()
function claude {
  $script:calls += [pscustomobject]@{
    Args = @($args)
    Key = $env:ANTHROPIC_API_KEY; Bedrock = $env:CLAUDE_CODE_USE_BEDROCK; Token = $env:ANTHROPIC_AUTH_TOKEN; Oauth = $env:CLAUDE_CODE_OAUTH_TOKEN
  }
}

# --- claude-oauth ---
$env:ANTHROPIC_API_KEY = 'k'; $env:CLAUDE_CODE_USE_BEDROCK = '1'; $env:ANTHROPIC_AUTH_TOKEN = 't'; $env:CLAUDE_CODE_OAUTH_TOKEN = 'o'
$script:calls = @()
claude-oauth --resume
$c = $script:calls[0]
Check 'oauth: API key / Bedrock / auth token are hidden from claude' (-not $c.Key -and -not $c.Bedrock -and -not $c.Token)
Check 'oauth: OAuth token is kept'                                    ($c.Oauth -eq 'o')
Check 'oauth: arguments are passed through'                           (($c.Args -join ' ') -eq '--resume')
Check 'oauth: variables are restored afterwards'                      (($env:ANTHROPIC_API_KEY -eq 'k') -and ($env:CLAUDE_CODE_USE_BEDROCK -eq '1') -and ($env:ANTHROPIC_AUTH_TOKEN -eq 't'))

function claude { throw 'boom' }
$threw = $false
try { claude-oauth } catch { $threw = $true }
Check 'oauth: variables are restored even if claude fails' ($threw -and ($env:ANTHROPIC_API_KEY -eq 'k') -and ($env:CLAUDE_CODE_USE_BEDROCK -eq '1'))

# 元々セットされていない変数は、終了後もセットされない
Remove-Item Env:ANTHROPIC_API_KEY, Env:CLAUDE_CODE_USE_BEDROCK, Env:ANTHROPIC_AUTH_TOKEN
function claude { $script:calls += [pscustomobject]@{ Args = @($args) } }
$script:calls = @()
claude-oauth
Check 'oauth: unset variables stay unset' (($null -eq $env:ANTHROPIC_API_KEY) -and ($null -eq [Environment]::GetEnvironmentVariable('CLAUDE_CODE_USE_BEDROCK', 'Process')))
Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN

# --- claude-api / claude-bedrock ---
$script:calls = @()
claude-api --model sonnet
Check 'api: --settings api.settings.json, then arguments' (($script:calls[0].Args[0] -eq '--settings') -and ($script:calls[0].Args[1] -eq (Join-Path $fakeHome '.claude\api.settings.json')) -and (($script:calls[0].Args[2..3] -join ' ') -eq '--model sonnet'))

$script:calls = @()
$msg = (claude-bedrock 6>&1) -join "`n"
Check 'bedrock: no settings file -> message, claude not called' (($script:calls.Count -eq 0) -and ($msg -match 'claude-bedrock-setup'))
Set-Content (Join-Path $fakeHome '.claude\bedrock.settings.json') '{}'
$script:calls = @()
claude-bedrock -p hi
Check 'bedrock: with the file -> --settings then arguments' (($script:calls[0].Args[0] -eq '--settings') -and ($script:calls[0].Args[1] -like '*bedrock.settings.json') -and (($script:calls[0].Args[2..3] -join ' ') -eq '-p hi'))

# --- claude-pick ---
function claude-oauth { $script:picked = 'oauth:' + ($args -join ' ') }
function claude-api { $script:picked = 'api:' + ($args -join ' ') }
function claude-bedrock { $script:picked = 'bedrock:' + ($args -join ' ') }
claude-pick api --resume
Check 'pick: mode as the first argument, rest passed on' ($script:picked -eq 'api:--resume')
claude-pick bedrock
Check 'pick: bedrock'                                     ($script:picked -eq 'bedrock:')
function fzf { 'oauth' }
claude-pick -p hi
Check 'pick: no mode -> fzf choice, all arguments passed on' ($script:picked -eq 'oauth:-p hi')
function fzf { }
$script:picked = $null
claude-pick
Check 'pick: fzf cancelled -> nothing is started'          ($null -eq $script:picked)

Remove-Item $fakeHome -Recurse -Force -ErrorAction SilentlyContinue
"failures: $fail"
exit $fail
