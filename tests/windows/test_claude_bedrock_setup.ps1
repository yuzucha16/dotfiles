# windows/claude/claude-bedrock-setup.ps1 の試験（ネットワーク・AWS 不要）
# 使い方: pwsh -NoProfile -File tests/windows/test_claude_bedrock_setup.ps1   （終了コード = 失敗数）
# 一覧の取得は、偽の aws 関数（dot-source した関数の試験）と、PATH から aws を外した実行だけを使う。実環境の ~/.claude には触れない（-OutFile は一時ディレクトリ）。
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script = Join-Path $repo 'windows\claude\claude-bedrock-setup.ps1'
$pwsh = (Get-Command pwsh).Source
$fail = 0

function Check($name, $ok) {
  if ($ok) { "[PASS] $name" } else { "[FAIL] $name"; $script:fail++ }
}

# --- 関数の試験（偽の aws） ---
. $script

function aws {
  $global:LASTEXITCODE = 0
  if ($args -contains 'FAILCASE') { $global:LASTEXITCODE = 255; return }
  '{"inferenceProfileSummaries":[' +
  '{"inferenceProfileId":"us.anthropic.claude-sonnet-4-6"},' +
  '{"inferenceProfileId":"us.amazon.nova-pro-v1:0"},' +
  '{"inferenceProfileId":"us.anthropic.claude-opus-4-8"},' +
  '{"inferenceProfileId":"us.anthropic.claude-haiku-4-5-20251001-v1:0"},' +
  '{"inferenceProfileId":"us.anthropic.claude-sonnet-4-6"}]}'
}

$ids = Get-InferenceProfileIds -Region 'us-east-1' -AwsProfile 'p'
Check 'ids: only Anthropic Claude, sorted, unique' (($ids -join ',') -eq 'us.anthropic.claude-haiku-4-5-20251001-v1:0,us.anthropic.claude-opus-4-8,us.anthropic.claude-sonnet-4-6')
Check 'family: opus'   ((Get-FamilyCandidates $ids 'opus') -eq 'us.anthropic.claude-opus-4-8')
Check 'family: sonnet' ((Get-FamilyCandidates $ids 'sonnet') -eq 'us.anthropic.claude-sonnet-4-6')
Check 'family: haiku count' (@(Get-FamilyCandidates $ids 'haiku').Count -eq 1)
Check 'family: none -> empty' (@(Get-FamilyCandidates $ids 'fable').Count -eq 0)
$threw = $false
try { Get-InferenceProfileIds -Region 'FAILCASE' -AwsProfile '' | Out-Null } catch { $threw = $true }
Check 'ids: aws failure throws' $threw

$s = New-BedrockSettings -AwsProfile 'prof' -Region 'ap-northeast-1' -Prefix 'jp' -OpusId 'o' -SonnetId 's' -HaikuId 'h' -Model 'sonnet' -Sso $true
Check 'settings: env keys' (($s.env.Keys -join ',') -eq 'CLAUDE_CODE_USE_BEDROCK,AWS_REGION,AWS_PROFILE,ANTHROPIC_BEDROCK_REGION_PREFIX,ANTHROPIC_DEFAULT_OPUS_MODEL,ANTHROPIC_DEFAULT_SONNET_MODEL,ANTHROPIC_DEFAULT_HAIKU_MODEL')
Check 'settings: sso refresh with profile' ($s.awsAuthRefresh -eq 'aws sso login --profile prof')
$s = New-BedrockSettings -AwsProfile '' -Region 'r' -Prefix 'none' -OpusId $null -SonnetId $null -HaikuId $null -Model 'sonnet' -Sso $false
Check 'settings: minimal (no profile/prefix/pins/refresh)' ((($s.env.Keys -join ',') -eq 'CLAUDE_CODE_USE_BEDROCK,AWS_REGION') -and -not $s.Contains('awsAuthRefresh'))

# 対話の選択（偽の Read-Host）
$script:answers = [System.Collections.Generic.Queue[string]]::new()
function Read-Host { param($p) $script:answers.Dequeue() }
$items = @('a', 'b', 'c')
$script:answers.Enqueue('2')
Check 'choice: number selects the item'   ((Read-Choice 'T' $items 6>$null) -eq 'b')
$script:answers.Enqueue('')
Check 'choice: blank -> null'             ($null -eq (Read-Choice 'T' $items 6>$null))
'x', '9', '3' | ForEach-Object { $script:answers.Enqueue($_) }
Check 'choice: invalid answers are asked again' ((Read-Choice 'T' $items 6>$null) -eq 'c')
Check 'choice: empty list -> null'        ($null -eq (Read-Choice 'T' @() 6>$null))
Remove-Item Function:\Read-Host

# --- スクリプトの実行（標準入力は空 = 非対話） ---
function Run-Script($argList, $noAws = $false) {
  $old = $env:PATH
  try {
    if ($noAws) { $env:PATH = (Split-Path $pwsh) + ';' + (Join-Path $env:SystemRoot 'System32') }
    $out = ($null | & $pwsh -NoProfile -File $script @argList 2>&1) -join "`n"
    [pscustomobject]@{ Out = $out; Rc = $LASTEXITCODE }
  } finally { $env:PATH = $old }
}
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("tbedrock-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $tmp | Out-Null
$out = Join-Path $tmp 'sub\bedrock.settings.json'
$full = @('-AwsProfile', 'work', '-Region', 'ap-northeast-1', '-Prefix', 'jp', '-OpusId', 'o-id', '-SonnetId', 's-id', '-HaikuId', 'none', '-OutFile', $out)
try {
  $r = Run-Script ($full + '-Sso')
  $j = if (Test-Path $out) { Get-Content $out -Raw | ConvertFrom-Json } else { $null }
  Check 'run: exit 0 and file written'          (($r.Rc -eq 0) -and $j)
  Check 'run: env values'                       (($j.env.AWS_REGION -eq 'ap-northeast-1') -and ($j.env.ANTHROPIC_DEFAULT_SONNET_MODEL -eq 's-id') -and ($j.env.ANTHROPIC_BEDROCK_REGION_PREFIX -eq 'jp'))
  Check 'run: none -> haiku not pinned'         ($null -eq $j.env.ANTHROPIC_DEFAULT_HAIKU_MODEL)
  Check 'run: -Sso -> awsAuthRefresh'           ($j.awsAuthRefresh -eq 'aws sso login --profile work')
  Check 'run: model defaults to sonnet'         ($j.model -eq 'sonnet')
  Check 'run: warns when a pin is missing'      ($r.Out -match '\[WARN\]')

  $r = Run-Script ($full + '-Force')
  $j2 = Get-Content $out -Raw | ConvertFrom-Json
  Check 'force: overwrites, no refresh without -Sso' (($r.Rc -eq 0) -and ($null -eq $j2.awsAuthRefresh))

  $before = Get-Content $out -Raw
  $r = Run-Script $full
  Check 'exists (non-interactive, no -Force): refuses' (($r.Rc -eq 1) -and ($r.Out -match '-Force') -and ((Get-Content $out -Raw) -eq $before))

  Remove-Item $out -Force
  $r = Run-Script ($full + '-DryRun')
  Check 'dry-run: prints JSON, writes nothing'  (($r.Rc -eq 0) -and ($r.Out -match 'CLAUDE_CODE_USE_BEDROCK') -and -not (Test-Path $out))

  $r = Run-Script @('-Region', 'ap-northeast-1', '-OutFile', $out) $true
  Check 'no aws and no pins: error, exit 1'     (($r.Rc -eq 1) -and ($r.Out -match 'AWS CLI') -and -not (Test-Path $out))

  $r = Run-Script ($full + @('-Prefix', 'xx'))
  Check 'invalid prefix: rejected'              (($r.Rc -ne 0) -and -not (Test-Path $out))
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

"failures: $fail"
exit $fail
