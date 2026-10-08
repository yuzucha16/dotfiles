# Claude Code を Amazon Bedrock で使うための、この PC 専用の設定ファイルを作る。
# 実行: claude-bedrock-setup.cmd [-DryRun]   （引数なしなら対話。AWS CLI で推論プロファイルの一覧を取って選ぶ）
# 作るもの: %USERPROFILE%\.claude\bedrock.settings.json（この PC 専用。リポジトリには置かない。秘密は含まない）
# 起動: claude-bedrock（windows/powershell/profile.ps1 の関数。claude --settings でそのファイルを読む）
# プロファイル名・リージョン・モデル ID は環境ごとに違う値なので、dotfiles には実値を持たず、このスクリプトで毎回その場で作る。
# 認証情報（アクセスキー、AWS_BEARER_TOKEN_BEDROCK など）は書かない。SSO か AWS プロファイルを使う。
[CmdletBinding()]
param(
    [string]$AwsProfile,                                   # 省略 = 対話で選ぶ（空欄 = 既定の資格情報）
    [string]$Region,                                       # 例: ap-northeast-1
    [ValidateSet('us', 'eu', 'apac', 'jp', 'au', 'global', 'none')][string]$Prefix,  # 推論プロファイルの接頭辞。none = 指定しない
    [string]$OpusId,                                       # 推論プロファイル ID。none = ピン留めしない
    [string]$SonnetId,
    [string]$HaikuId,
    [string]$Model,                                        # セッションの既定モデル（別名か ID）。省略 = sonnet
    [switch]$Sso,                                          # IAM Identity Center を使う（awsAuthRefresh を書く）
    [string]$OutFile = (Join-Path $HOME '.claude\bedrock.settings.json'),
    [switch]$DryRun,                                       # 書かずに内容だけ表示する
    [switch]$Force                                         # 既存のファイルを確認なしで上書きする
)

function Test-Interactive { -not [Console]::IsInputRedirected }

# aws bedrock list-inference-profiles の結果から、Anthropic の推論プロファイル ID を返す
function Get-InferenceProfileIds {
    param([string]$Region, [string]$AwsProfile)
    $cliArgs = @('bedrock', 'list-inference-profiles', '--region', $Region, '--output', 'json')
    if ($AwsProfile) { $cliArgs += @('--profile', $AwsProfile) }
    $json = & aws @cliArgs
    if ($LASTEXITCODE -ne 0) { throw "aws bedrock list-inference-profiles が失敗しました（終了コード $LASTEXITCODE）" }
    $o = ($json -join "`n") | ConvertFrom-Json
    @($o.inferenceProfileSummaries | ForEach-Object { $_.inferenceProfileId } |
        Where-Object { $_ -like '*anthropic.claude-*' } | Sort-Object -Unique)
}

function Get-FamilyCandidates {
    param([string[]]$Ids, [string]$Family)
    @($Ids | Where-Object { $_ -match "claude.*$Family" })
}

function Read-Choice {
    param([string]$Title, [string[]]$Items)
    if ($Items.Count -eq 0) { Write-Host "${Title}: 候補がありません（設定しない）"; return $null }
    Write-Host ''
    Write-Host $Title
    for ($i = 0; $i -lt $Items.Count; $i++) { Write-Host ('  {0,2}) {1}' -f ($i + 1), $Items[$i]) }
    while ($true) {
        $a = Read-Host '番号（空欄 = 設定しない）'
        if ([string]::IsNullOrWhiteSpace($a)) { return $null }
        $n = 0
        if ([int]::TryParse($a, [ref]$n) -and $n -ge 1 -and $n -le $Items.Count) { return $Items[$n - 1] }
        Write-Host '[WARN] 一覧の番号で答えてください。'
    }
}

function Resolve-Pin {
    param([bool]$Bound, [string]$Value, [string]$Family, [string[]]$Ids, [bool]$Interactive)
    if ($Bound) { if ($Value -eq 'none') { return $null } else { return $Value } }
    if (-not $Interactive) { throw "-$((Get-Culture).TextInfo.ToTitleCase($Family))Id が必要です（ピン留めしないなら none）" }
    Read-Choice "$Family に割り当てるモデル" (Get-FamilyCandidates $Ids $Family)
}

function New-BedrockSettings {
    param([string]$AwsProfile, [string]$Region, [string]$Prefix, [string]$OpusId, [string]$SonnetId, [string]$HaikuId, [string]$Model, [bool]$Sso)
    $envBlock = [ordered]@{ CLAUDE_CODE_USE_BEDROCK = '1'; AWS_REGION = $Region }
    if ($AwsProfile) { $envBlock['AWS_PROFILE'] = $AwsProfile }
    if ($Prefix -and $Prefix -ne 'none') { $envBlock['ANTHROPIC_BEDROCK_REGION_PREFIX'] = $Prefix }
    if ($OpusId) { $envBlock['ANTHROPIC_DEFAULT_OPUS_MODEL'] = $OpusId }
    if ($SonnetId) { $envBlock['ANTHROPIC_DEFAULT_SONNET_MODEL'] = $SonnetId }
    if ($HaikuId) { $envBlock['ANTHROPIC_DEFAULT_HAIKU_MODEL'] = $HaikuId }
    $s = [ordered]@{}
    if ($Sso) { $s['awsAuthRefresh'] = if ($AwsProfile) { "aws sso login --profile $AwsProfile" } else { 'aws sso login' } }
    if ($Model) { $s['model'] = $Model }
    $s['env'] = $envBlock
    $s
}

# dot-source されたとき（試験）は、関数だけ定義して終わる
if ($MyInvocation.InvocationName -eq '.') { return }

$ErrorActionPreference = 'Stop'
function Stop-Setup($msg) { [Console]::Error.WriteLine("[ERR] $msg"); exit 1 }

$interactive = Test-Interactive
$pinsGiven = $PSBoundParameters.ContainsKey('OpusId') -and $PSBoundParameters.ContainsKey('SonnetId') -and $PSBoundParameters.ContainsKey('HaikuId')
$hasAws = [bool](Get-Command aws -ErrorAction SilentlyContinue)
if (-not $pinsGiven -and -not $hasAws) {
    Stop-Setup 'AWS CLI (aws) が見つかりません。導入してから再実行するか、-OpusId / -SonnetId / -HaikuId を指定してください（導入例: winget install Amazon.AWSCLI）。'
}

# プロファイル
if (-not $PSBoundParameters.ContainsKey('AwsProfile') -and $interactive -and $hasAws) {
    $names = @(& aws configure list-profiles 2>$null)
    $AwsProfile = Read-Choice 'AWS プロファイル（空欄 = 既定の資格情報）' $names
}
$profArgs = if ($AwsProfile) { @('--profile', $AwsProfile) } else { @() }

# SSO
if (-not $PSBoundParameters.ContainsKey('Sso') -and $interactive) {
    $Sso = [bool]((Read-Host 'IAM Identity Center (SSO) を使いますか? [y/N]') -match '^[yY]')
}

# リージョン
if (-not $Region) {
    $def = if ($hasAws) { (& aws configure get region @profArgs 2>$null) } else { $null }
    if ($interactive) {
        $a = Read-Host "AWS リージョン [$def]"
        $Region = if ($a) { $a } else { $def }
    } else { $Region = $def }
    if (-not $Region) { Stop-Setup '-Region が必要です（例: ap-northeast-1）。' }
}

# 接頭辞
if (-not $PSBoundParameters.ContainsKey('Prefix')) {
    $Prefix = 'none'
    if ($interactive) {
        $a = Read-Host '推論プロファイルの接頭辞（us / eu / apac / jp / au / global。空欄 = Claude Code の自動選択）'
        if ($a) {
            if ($a -notin 'us', 'eu', 'apac', 'jp', 'au', 'global') { Stop-Setup "接頭辞は us / eu / apac / jp / au / global のどれかです: $a" }
            $Prefix = $a
        }
    }
}

# 推論プロファイルの一覧（ピン留めが全部指定されていれば取らない）
$ids = @()
if (-not $pinsGiven) {
    & aws sts get-caller-identity @profArgs --region $Region *> $null
    if ($LASTEXITCODE -ne 0) {
        if (-not $Sso) { Stop-Setup 'AWS に認証できません。aws sso login（または資格情報の設定）をしてから再実行してください。' }
        Write-Host '[INFO] aws sso login を実行します。'
        & aws sso login @profArgs
        if ($LASTEXITCODE -ne 0) { Stop-Setup 'aws sso login が失敗しました。' }
    }
    try { $ids = Get-InferenceProfileIds -Region $Region -AwsProfile $AwsProfile } catch { Stop-Setup $_.Exception.Message }
    if ($ids.Count -eq 0) { Stop-Setup "リージョン $Region に Anthropic の推論プロファイルがありません。Bedrock のモデルアクセスとリージョンを確認してください。" }
}

try {
    $opus = Resolve-Pin $PSBoundParameters.ContainsKey('OpusId') $OpusId 'opus' $ids $interactive
    $sonnet = Resolve-Pin $PSBoundParameters.ContainsKey('SonnetId') $SonnetId 'sonnet' $ids $interactive
    $haiku = Resolve-Pin $PSBoundParameters.ContainsKey('HaikuId') $HaikuId 'haiku' $ids $interactive
} catch { Stop-Setup $_.Exception.Message }
if (-not ($opus -and $sonnet -and $haiku)) {
    Write-Host '[WARN] ピン留めしない別名は、Claude Code の組み込みの既定に解決されます（アカウントで使えないモデルだと、起動時に下位モデルへ切り替わります）。'
}

# セッションの既定モデル
if (-not $PSBoundParameters.ContainsKey('Model')) {
    $Model = 'sonnet'
    if ($interactive) {
        $a = Read-Host 'セッションの既定モデル（opus / sonnet / haiku か ID）[sonnet]'
        if ($a) { $Model = $a }
    }
}

$settings = New-BedrockSettings -AwsProfile $AwsProfile -Region $Region -Prefix $Prefix -OpusId $opus -SonnetId $sonnet -HaikuId $haiku -Model $Model -Sso ([bool]$Sso)
$json = $settings | ConvertTo-Json -Depth 5

if ($DryRun) {
    Write-Host "[DRY-RUN] 書き込み先: $OutFile"
    Write-Output $json
    exit 0
}

if ((Test-Path $OutFile) -and -not $Force) {
    if (-not $interactive) { Stop-Setup "既にあります: $OutFile（上書きするなら -Force）" }
    if ((Read-Host "既にあります: $OutFile 上書きしますか? [y/N]") -notmatch '^[yY]') { Write-Host '[SKIP] 何も書きませんでした。'; exit 0 }
}
New-Item -ItemType Directory -Force (Split-Path $OutFile) | Out-Null
[IO.File]::WriteAllText($OutFile, $json + "`n", (New-Object Text.UTF8Encoding $false))
Write-Host "[DONE] $OutFile"
Write-Host '次: claude-bedrock で起動し、/status でプロバイダ（Amazon Bedrock）・リージョン・モデルを確認する。'
if ($Sso) { Write-Host "SSO の期限が切れたら: aws sso login$(if ($AwsProfile) { " --profile $AwsProfile" })" }
