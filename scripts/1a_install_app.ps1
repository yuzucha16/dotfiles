<#
  fuga.ps1
  - 内蔵リストから Scoop を一括インストール
  - Scoop 呼び出し時のみ別プロセスで -ExecutionPolicy Bypass を付与
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param()  # ← ここに何も定義しない（-WhatIf/-Verbose は標準提供）

# === インストールアプリ一覧 ================================
$EmbeddedList = @'
# 行頭 # はコメント。空行OK
# 先に必要なバケットを追加
bucket extras
bucket versions

# 通常パッケージ
windows-terminal
pwsh
psreadline
starship
scoop-completion
neovim
llvm
goneovim
notepadplusplus
winmerge
ghq
sourcegit
ripgrep
fd
which
lsd
broot
zoxide

# バージョン固定
#python@3.12.6

# バケット指定
#extras/7zip
'@
# =======================================================================

$ErrorActionPreference = "Stop"

function Write-Info($msg){ Write-Host "[*] $msg" }
function Write-Warn($msg){ Write-Warning $msg }
function Write-Err ($msg){ Write-Error   $msg }

# Scoop 本体の ps1 パス（ユーザーインストール前提）
$scoopPs1 = Join-Path $env:USERPROFILE "scoop\apps\scoop\current\bin\scoop.ps1"

# Verbose の有無（標準の -Verbose が有効なら 'Continue'）
$IsVerbose = ($VerbosePreference -eq 'Continue')
$IsWhatIf  = ($WhatIfPreference -eq $true)

# Scoop 呼び出し（別プロセス・一時バイパス）
function Invoke-Scoop {
    param([Parameter(Mandatory)][string[]]$Args)

    # Windows PowerShell と PowerShell(Core) 両対応
    $pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source
    $hostExe  = $(if ($pwshPath) { 'pwsh' } else { 'powershell' })

    $psArgs = @('-ExecutionPolicy','Bypass','-NoProfile','-File', $scoopPs1) + $Args
    if ($IsVerbose) { Write-Info ("$hostExe " + ($psArgs -join ' ')) }

    $p = Start-Process -FilePath $hostExe -ArgumentList $psArgs -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -ne 0) {
        throw "Scoop コマンドが失敗しました (exit=$($p.ExitCode)) : scoop $($Args -join ' ')"
    }
}

# 前提チェック
if (-not (Test-Path $scoopPs1)) {
    Write-Err "Scoop が見つかりませんでした：$scoopPs1"
    Write-Host "  まだ未導入なら以下の例で導入してください（どちらか）"
    Write-Host "    powershell -NoProfile -ExecutionPolicy Bypass -Command ""iwr -useb get.scoop.sh | iex"""
    Write-Host "    pwsh       -NoProfile -ExecutionPolicy Bypass -Command ""iwr -useb get.scoop.sh | iex"""
    exit 1
}

# 内蔵リストをパース（空行/コメント除外）
$items = $EmbeddedList -split "`r?`n" |
    Where-Object { $_ -match '\S' } |
    Where-Object { $_ -notmatch '^\s*#' } |
    ForEach-Object { $_.Trim() }

if ($items.Count -eq 0) {
    Write-Warn "インストール対象がありません（内蔵リストが空）"
    exit 0
}

Write-Info "Scoop本体     : $scoopPs1"
Write-Info "処理開始"

$failed = @()

foreach ($line in $items) {
    try {
        # "bucket <name> [url]" の簡易DSL
        if ($line -match '^(?i)\s*bucket\s+([^\s]+)(?:\s+([^\s]+))?\s*$') {
            $name = $matches[1]
            $url  = $matches[2]
            $args = @('bucket','add', $name)
            if ($url) { $args += $url }

            if ($PSCmdlet.ShouldProcess("bucket $name", "add")) {
                Invoke-Scoop -Args $args
            } elseif ($IsWhatIf) {
                Write-Info "[WhatIf] scoop $($args -join ' ')"
            }
            continue
        }

        # それ以外はパッケージ名として扱う
        $args = @('install', $line)
        if ($IsVerbose) { $args += '-v' }

        if ($PSCmdlet.ShouldProcess($line, "install")) {
            Invoke-Scoop -Args $args
        } elseif ($IsWhatIf) {
            Write-Info "[WhatIf] scoop $($args -join ' ')"
        }
    }
    catch {
        Write-Warn "失敗: $line"
        Write-Host "  -> $($_.Exception.Message)"
        $failed += $line
    }
}

if ($failed.Count -gt 0) {
    Write-Warn "一部失敗しました：`n  - " + ($failed -join "`n  - ")
    exit 2
}

Write-Info "完了しました。"
pause