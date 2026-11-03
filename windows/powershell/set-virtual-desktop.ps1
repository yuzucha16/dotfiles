# PowerToys Workspaces を仮想デスクトップごとに起動し、各アプリのウィンドウを割り当てたデスクトップへ置く。
# workspace の定義（GUID・名前・アプリ一覧）は PowerToys 自身の workspaces.json から読む。
# .lnk も、アプリ名（プロセス名）の手書きリストも要らない。
#
# 新しい workspace を足す手順:
#   1. PowerToys Workspaces（Win+Ctrl+`）でウィンドウを並べて Capture し、名前を付けて保存する。
#   2. .\set-virtual-desktop.ps1 -List で、名前・GUID・対象アプリを確かめる。
#   3. 下の $desktopMap に「名前 = デスクトップ番号（0 始まり）」を 1 行足す。ps1 のコードは触らない。
#   GUID は PC ごとに違うので、PC をまたいで同じ名前（dev / office）を付ければ、同じ ps1 が動く。
#
# 使い方:
#   .\set-virtual-desktop.ps1                 全 workspace を起動して配置する（taskschd からもこれ）
#   .\set-virtual-desktop.ps1 -List           workspaces.json の内容と割り当てを表示する（モジュール不要）
#   .\set-virtual-desktop.ps1 -Name dev       指定した workspace だけ
#   .\set-virtual-desktop.ps1 -MoveOnly       起動はせず、動いているアプリのデスクトップを直すだけ（崩れの修復用）
#   .\set-virtual-desktop.ps1 -Relayout       動いていても Workspaces ランチャーを呼び、位置とサイズを戻す（下記）
#   -WhatIf                                   ランチャーの起動だけ止める
#
# 位置とサイズの扱い:
#   起動したときの位置とサイズは、PowerToys のランチャーが workspaces.json の値で行う。
#   -Relayout は、起動済みのウィンドウにも同じ配置を適用する想定で、workspace の「Move existing windows」
#   （workspaces.json の move-existing-windows）を有効にしておく必要がある。この動作は未確認。
#
# 前提: PowerToys（scoop の extras/powertoys）と、PowerShell モジュール VirtualDesktop（-List 以外で使う）。
[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$Name,
    [switch]$List,
    [switch]$MoveOnly,
    [switch]$Relayout
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ===================================================
# Settings
# ===================================================

# workspace 名 = 仮想デスクトップ番号（0 始まり。Desktop 1 = 0）。ここだけ手で書く。
$desktopMap = [ordered]@{
    dev    = 0
    office = 1
}

# 最後に表示しておく workspace（$desktopMap のキー）
$finishOn = 'dev'

# ランチャー起動後、アプリのウィンドウが揃うのを待つ上限（秒）。揃えば早く抜ける。
$workspaceLaunchWaitSeconds = 90

# 仮想デスクトップ切り替え直後の安定待ち（ミリ秒）
$desktopSwitchWaitMilliseconds = 700

# 起動判定と移動の対象から外すプロセス（常に動いているもの。explorer はここ）
$ignoreProcesses = @('explorer')

# ===================================================
# Paths
# ===================================================

$dotfilesRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$tmpDir = Join-Path $dotfilesRoot 'tmp'
$logFile = Join-Path $tmpDir 'set-virtual-desktop.log'
$workspacesJson = Join-Path $env:LOCALAPPDATA 'Microsoft\PowerToys\Workspaces\workspaces.json'

# ===================================================
# Functions
# ===================================================

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Write-Host $line
    $line | Add-Content -Path $logFile -Encoding UTF8 -WhatIf:$false
}

function Resolve-LauncherPath {
    # scoop は current が最新版への junction。見つからなければ公式インストーラの場所と PATH を見る。
    $candidates = @(
        (Join-Path $env:USERPROFILE 'scoop\apps\powertoys\current\PowerToys.WorkspacesLauncher.exe')
        (Join-Path $env:LOCALAPPDATA 'PowerToys\PowerToys.WorkspacesLauncher.exe')
        (Join-Path $env:ProgramFiles 'PowerToys\PowerToys.WorkspacesLauncher.exe')
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    $cmd = Get-Command 'PowerToys.WorkspacesLauncher.exe' -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw 'PowerToys.WorkspacesLauncher.exe not found. Install PowerToys (scoop install powertoys).'
}

function Get-Workspaces {
    if (-not (Test-Path $workspacesJson)) {
        throw "workspaces.json not found: $workspacesJson (capture a workspace in PowerToys Workspaces first)"
    }
    $json = Get-Content -Path $workspacesJson -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($w in @($json.workspaces)) {
        $procs = @(
            $w.applications |
                ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_.'application-path') } |
                Where-Object { $_ -and ($ignoreProcesses -notcontains $_) } |
                Select-Object -Unique
        )
        [pscustomobject]@{
            Name      = $w.name
            Id        = $w.id
            Processes = $procs
        }
    }
}

function Test-ProcessesRunning {
    param([string[]]$Names)
    foreach ($n in $Names) {
        if (-not (Get-Process -Name $n -ErrorAction SilentlyContinue)) { return $false }
    }
    return $true
}

function Test-WindowsReady {
    param([string[]]$Names)
    foreach ($n in $Names) {
        $ready = Get-Process -Name $n -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne 0 }
        if (-not $ready) { return $false }
    }
    return $true
}

function Wait-WindowsReady {
    param([string[]]$Names, [int]$TimeoutSeconds)
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-WindowsReady $Names) { return $true }
        Start-Sleep -Seconds 2
    }
    return (Test-WindowsReady $Names)
}

function Move-AppWindowsToDesktop {
    param([string]$ProcessName, [int]$DesktopIndex)

    $targetDesktop = Get-Desktop $DesktopIndex
    $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 }

    foreach ($process in $processes) {
        try {
            $hwnd = $process.MainWindowHandle
            $currentIndex = Get-DesktopIndex -Desktop (Get-DesktopFromWindow -Hwnd $hwnd)
            if ($currentIndex -ne $DesktopIndex) {
                Write-Log "${ProcessName}: moving Desktop $($currentIndex + 1) -> $($DesktopIndex + 1)"
                Move-Window -Desktop $targetDesktop -Hwnd $hwnd
            }
            else {
                Write-Log "${ProcessName}: already on Desktop $($DesktopIndex + 1)"
            }
        }
        catch {
            Write-Log "${ProcessName}: window move failed: $($_.Exception.Message)"
        }
    }
}

function Switch-ToDesktop {
    param([int]$Index)
    Get-Desktop $Index | Switch-Desktop
    Start-Sleep -Milliseconds $desktopSwitchWaitMilliseconds
}

# ===================================================
# Initialize
# ===================================================

if (-not (Test-Path $tmpDir)) {
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
}

# ===================================================
# Main
# ===================================================

try {
    $workspaces = @(Get-Workspaces)

    if ($List) {
        foreach ($w in $workspaces) {
            $desk = if ($desktopMap.Contains($w.Name)) { "Desktop $($desktopMap[$w.Name] + 1)" } else { '(not in $desktopMap)' }
            Write-Host "$($w.Name)  $($w.Id)  $desk"
            Write-Host "    processes: $($w.Processes -join ', ')"
        }
        foreach ($k in $desktopMap.Keys) {
            if (-not ($workspaces | Where-Object { $_.Name -eq $k })) {
                Write-Host "[WARN] '$k' is in `$desktopMap but not in workspaces.json"
            }
        }
        return
    }

    Write-Log '=== Workspace restore started ==='

    # 対象の決定。-Name が $desktopMap に無ければ止める。
    $targets = @($desktopMap.Keys)
    if ($Name) {
        foreach ($n in $Name) {
            if (-not $desktopMap.Contains($n)) { throw "'$n' is not in `$desktopMap" }
        }
        $targets = @($Name)
    }
    # デスクトップ番号の大きい方から処理し、最後に $finishOn へ戻る。
    $targets = @($targets | Sort-Object { $desktopMap[$_] } -Descending)

    $launcher = $null
    if (-not $MoveOnly -or $Relayout) { $launcher = Resolve-LauncherPath }

    Import-Module VirtualDesktop -ErrorAction Stop -DisableNameChecking

    $needed = ($desktopMap.Values | Measure-Object -Maximum).Maximum + 1
    while ((Get-DesktopCount) -lt $needed) {
        Write-Log 'Creating virtual desktop'
        New-Desktop | Out-Null
    }

    $failed = $false
    foreach ($t in $targets) {
        $index = $desktopMap[$t]
        $ws = @($workspaces | Where-Object { $_.Name -eq $t })
        if ($ws.Count -eq 0) {
            Write-Log "ERROR: workspace '$t' not found in workspaces.json"
            $failed = $true
            continue
        }
        if ($ws.Count -gt 1) { Write-Log "WARN: workspace '$t' is defined $($ws.Count) times; using the first" }
        $ws = $ws[0]

        Write-Log "[$t] switching to Desktop $($index + 1)"
        Switch-ToDesktop $index

        $running = Test-ProcessesRunning $ws.Processes
        if ($running) {
            Write-Log "[$t] applications already running"
        }
        elseif ($MoveOnly) {
            Write-Log "[$t] not all applications running; -MoveOnly, so not launching"
        }
        else {
            Write-Log "[$t] launching workspace $($ws.Id)"
            if ($PSCmdlet.ShouldProcess("$t $($ws.Id)", 'Launch workspace')) {
                Start-Process -FilePath $launcher -ArgumentList $ws.Id
                $ok = Wait-WindowsReady $ws.Processes $workspaceLaunchWaitSeconds
                Write-Log "[$t] windows ready: $ok"
            }
        }

        if ($running -and $Relayout) {
            Write-Log "[$t] relayout via launcher"
            if ($PSCmdlet.ShouldProcess("$t $($ws.Id)", 'Relayout workspace')) {
                Start-Process -FilePath $launcher -ArgumentList $ws.Id
                Start-Sleep -Seconds 5
            }
        }

        # ランチャーは今のデスクトップに窓を出す。取りこぼしや、既存アプリの窓をここで寄せる。
        foreach ($p in $ws.Processes) {
            Move-AppWindowsToDesktop -ProcessName $p -DesktopIndex $index
        }
    }

    $finishIndex = if ($desktopMap.Contains($finishOn)) { $desktopMap[$finishOn] } else { 0 }
    Switch-ToDesktop $finishIndex

    if ($failed) { throw 'one or more workspaces failed (see log)' }
    Write-Log 'Workspace restore completed'
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
