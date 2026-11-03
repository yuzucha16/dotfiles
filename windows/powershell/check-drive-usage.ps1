#Requires -Version 7
# C ドライブの使用量が多いフォルダを調べ、ストレージが逼迫したときの「削除候補」を一覧にする。
# 調査と表示だけで、ファイルは一切削除しない（削除は、表示を見て人が判断し、アプリの機能や公式コマンドで行う）。
#
#   pwsh -NoProfile -File check-drive-usage.ps1                      # 既定の件数で調査
#   pwsh -NoProfile -File check-drive-usage.ps1 -Top 5 -ChildTop 15  # 回収ランキングは5件、直下ランキングは15件
#
# 表示する内容（上から順）:
#   1. 回収おすすめランキング（Temp、ごみ箱、Scoop、Edge、uv、npm cache、Claude、WSL を容量順に。安全度つき）と、その直下ランキング
#   2. C: 使用済み容量の内訳（Windows、Users、Program Files など。削除候補ではなく、使用先の把握用）
#   3. Users の直下と、突出しているユーザーの2階層の内訳
#   4. AppData\Local の直下 TOP を、整理方法の目安（削除可能、アプリから清掃、圧縮候補、触らない、要確認）つきで
#
# 使用中のファイルやアクセスできないファイルは読み飛ばす（エラーは出さない）。
# ReparsePoint（ジャンクション、シンボリックリンク）は、二重集計を避けるため数えない。
# 初回は C: 全体を走査するので、数分かかることがある。
[CmdletBinding()]
param(
    # 回収おすすめランキングに出す件数
    [ValidateRange(1, 50)]
    [int]$Top = 10,

    # 各項目の直下ランキングに出す件数
    [ValidateRange(1, 50)]
    [int]$ChildTop = 10
)

$ErrorActionPreference = 'SilentlyContinue'


# =====================================================================
# 指定したパスの使用容量を取得
# =====================================================================
function Get-PathSizeBytes {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return [int64]0
    }

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue

    if ($null -eq $item) {
        return [int64]0
    }

    # ファイルの場合
    if (-not $item.PSIsContainer) {
        return [int64]$item.Length
    }

    # フォルダーの場合
    $sum = (
        Get-ChildItem `
            -LiteralPath $Path `
            -Force `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum
    ).Sum

    if ($null -eq $sum) {
        return [int64]0
    }

    return [int64]$sum
}


# =====================================================================
# 指定パスの直下を容量順にランキング
#
# フォルダーだけでなくファイルも対象。
# WSL の ext4.vhdx なども検出できる。
# =====================================================================
function Get-ChildEntryRanking {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [int]$Top = 10
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    $results = foreach (
        $entry in Get-ChildItem `
            -LiteralPath $Path `
            -Force `
            -ErrorAction SilentlyContinue
    ) {
        # All Users、Default User などのリンクによる
        # 二重集計を避ける
        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            continue
        }

        if ($entry.PSIsContainer) {
            $bytes = Get-PathSizeBytes -Path $entry.FullName
            $type = 'Folder'
        }
        else {
            $bytes = [int64]$entry.Length
            $type = 'File'
        }

        [PSCustomObject]@{
            Type   = $type
            Name   = $entry.Name
            SizeGB = [double]$bytes / 1GB
            Path   = $entry.FullName
        }
    }

    return @(
        $results |
            Sort-Object -Property SizeGB -Descending |
            Select-Object -First $Top
    )
}


# =====================================================================
# 直下ランキング表示
# =====================================================================
function Show-ChildRanking {
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [string]$Path,

        [int]$Top = 10
    )

    Write-Host ''
    Write-Host ('--- {0} ---' -f $Title) -ForegroundColor Cyan
    Write-Host $Path -ForegroundColor DarkGray

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host '対象パスが存在しません。' -ForegroundColor DarkGray
        return
    }

    $children = Get-ChildEntryRanking `
        -Path $Path `
        -Top $Top

    if ($children.Count -eq 0) {
        Write-Host '直下に集計対象がありません。' -ForegroundColor DarkGray
        return
    }

    $children |
        Format-Table `
            Type,
            @{Label='GB'; Expression={ '{0:N2}' -f $_.SizeGB }},
            Name,
            Path `
            -AutoSize
}

# =====================================================================
# 使用量の多いユーザープロファイルを2階層掘り下げる
#
# C:\Users
# └ 対象ユーザー
#     ├ 1階層目
#     │ └ 2階層目
#
# ReparsePointは二重集計防止のため除外する。
# =====================================================================
function Show-DominantUserBreakdown {
    param(
        [string]$UsersPath = 'C:\Users',

        # Users全体に占める割合がこの値以上のユーザーを対象にする
        [ValidateRange(0, 100)]
        [double]$MinimumPercent = 50,

        # 対象にするユーザー数
        [ValidateRange(1, 10)]
        [int]$UserTop = 1,

        # ユーザープロファイル直下の表示件数
        [ValidateRange(1, 50)]
        [int]$Level1Top = 10,

        # 各フォルダー配下の表示件数
        [ValidateRange(1, 50)]
        [int]$Level2Top = 10
    )

    Write-Host ''
    Write-Host '=== 使用量の多いユーザーの詳細内訳 ===' `
        -ForegroundColor Green

    Write-Host `
        ("Users全体の{0:N0}%以上を占めるユーザーを、さらに2階層表示します。" -f $MinimumPercent) `
        -ForegroundColor DarkGray

    if (-not (Test-Path -LiteralPath $UsersPath)) {
        Write-Host 'C:\Users が見つかりません。' `
            -ForegroundColor Yellow
        return
    }

    # ------------------------------------------------------
    # C:\Users 直下の実フォルダーを取得
    # ------------------------------------------------------

    $userFolders = foreach (
        $entry in Get-ChildItem `
            -LiteralPath $UsersPath `
            -Force `
            -Directory `
            -ErrorAction SilentlyContinue
    ) {
        # All Users、Default Userなどのリンクを除外
        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            continue
        }

        $bytes = Get-PathSizeBytes -Path $entry.FullName

        [PSCustomObject]@{
            Name   = $entry.Name
            Path   = $entry.FullName
            Bytes  = [double]$bytes
            SizeGB = [double]$bytes / 1GB
        }
    }

    $usersTotalBytes = (
        $userFolders |
            Measure-Object -Property Bytes -Sum
    ).Sum

    if ($null -eq $usersTotalBytes -or $usersTotalBytes -le 0) {
        Write-Host 'ユーザープロファイル容量を取得できませんでした。' `
            -ForegroundColor Yellow
        return
    }

    # ------------------------------------------------------
    # 指定割合以上を占めるユーザーだけを選択
    # ------------------------------------------------------

    $dominantUsers = @(
        $userFolders |
            ForEach-Object {
                $percent = $_.Bytes / $usersTotalBytes * 100

                [PSCustomObject]@{
                    Name    = $_.Name
                    Path    = $_.Path
                    Bytes   = $_.Bytes
                    SizeGB  = $_.SizeGB
                    Percent = $percent
                }
            } |
            Where-Object {
                $_.Percent -ge $MinimumPercent
            } |
            Sort-Object -Property SizeGB -Descending |
            Select-Object -First $UserTop
    )

    if ($dominantUsers.Count -eq 0) {
        Write-Host (
            'Users全体の{0:N0}%以上を占めるユーザーはありません。' -f
                $MinimumPercent
        ) -ForegroundColor DarkGray

        return
    }

    # ------------------------------------------------------
    # 対象ユーザーごとに2階層掘り下げる
    # ------------------------------------------------------

    foreach ($user in $dominantUsers) {

        Write-Host ''
        Write-Host (
            '### {0}: {1:N2} GB、Users全体の{2:N1}% ###' -f
                $user.Name,
                $user.SizeGB,
                $user.Percent
        ) -ForegroundColor Cyan

        Write-Host $user.Path -ForegroundColor DarkGray

        # --------------------------------------------------
        # 1階層目
        # 例:
        # AppData
        # scoop
        # .local
        # Downloads
        # --------------------------------------------------

        $level1Items = @(
            Get-ChildEntryRanking `
                -Path $user.Path `
                -Top $Level1Top
        )

        if ($level1Items.Count -eq 0) {
            Write-Host '直下に集計対象がありません。' `
                -ForegroundColor DarkGray
            continue
        }

        Write-Host ''
        Write-Host (
            '--- {0} 直下 TOP {1} ---' -f
                $user.Name,
                $Level1Top
        ) -ForegroundColor Cyan

        $level1Items |
            Format-Table `
                Type,
                @{
                    Label = 'GB'
                    Expression = {
                        '{0:N2}' -f $_.SizeGB
                    }
                },
                Name,
                Path `
                -AutoSize

        # --------------------------------------------------
        # 2階層目
        #
        # 1階層目のうち、フォルダーだけをさらに掘る。
        # ファイルは掘り下げ対象外。
        # --------------------------------------------------

        foreach ($level1 in $level1Items) {

            if ($level1.Type -ne 'Folder') {
                continue
            }

            if (-not (Test-Path -LiteralPath $level1.Path)) {
                continue
            }

            $level1Info = Get-Item `
                -LiteralPath $level1.Path `
                -Force `
                -ErrorAction SilentlyContinue

            if ($null -eq $level1Info) {
                continue
            }

            # シンボリックリンクやジャンクションは除外
            if (
                $level1Info.Attributes -band
                [IO.FileAttributes]::ReparsePoint
            ) {
                continue
            }

            $level2Items = @(
                Get-ChildEntryRanking `
                    -Path $level1.Path `
                    -Top $Level2Top
            )

            if ($level2Items.Count -eq 0) {
                continue
            }

            Write-Host ''
            Write-Host (
                '  └─ {0}: {1:N2} GB、配下 TOP {2}' -f
                    $level1.Name,
                    $level1.SizeGB,
                    $Level2Top
            ) -ForegroundColor Yellow

            $level2Items |
                Format-Table `
                    Type,
                    @{
                        Label = 'GB'
                        Expression = {
                            '{0:N2}' -f $_.SizeGB
                        }
                    },
                    Name,
                    Path `
                    -AutoSize
        }
    }
}

# =====================================================================
# Cドライブ情報取得
# =====================================================================
function Get-CDriveInfo {

    $drive = Get-CimInstance `
        Win32_LogicalDisk `
        -Filter "DeviceID='C:'" `
        -ErrorAction SilentlyContinue

    if ($null -eq $drive) {
        return $null
    }

    [PSCustomObject]@{
        SizeGB = [double]$drive.Size / 1GB
        FreeGB = [double]$drive.FreeSpace / 1GB
        UsedGB = (
            [double]$drive.Size -
            [double]$drive.FreeSpace
        ) / 1GB
    }
}


# =====================================================================
# 調査開始
# =====================================================================

Write-Host ''
Write-Host 'C: 回収おすすめランキングを調査しています...' `
    -ForegroundColor Cyan

Write-Host `
    '※ 使用中ファイルやアクセス不能なファイルは読み飛ばします。削除は一切しません。' `
    -ForegroundColor DarkGray

Write-Host ''


# =====================================================================
# Claude
# =====================================================================

# Store 版 Claude のパッケージ名には、発行元ごとの固定の接尾辞が付く（Claude_<接尾辞>）。
# 接尾辞は決め打ちせず、Claude_* に一致する最初のフォルダーを使う。無ければ存在しないパス（0 GB 扱い）。
$packagesRoot = Join-Path $env:LOCALAPPDATA 'Packages'

$claudePackagesPath = (
    Get-ChildItem `
        -LiteralPath $packagesRoot `
        -Directory `
        -Filter 'Claude_*' `
        -ErrorAction SilentlyContinue |
    Select-Object -First 1
).FullName

if (-not $claudePackagesPath) {
    $claudePackagesPath = Join-Path $packagesRoot 'Claude'
}

$claude3pPath =
    Join-Path `
        $env:LOCALAPPDATA `
        'Claude-3p'


# =====================================================================
# 調査対象
# =====================================================================

$targets = @(

    [PSCustomObject]@{
        Name     = 'Temp'
        Path     = Join-Path $env:LOCALAPPDATA 'Temp'
        Safety   = '高'
        Note     = '一時ファイル。使用中のものを除き、回収しやすい候補。'
    }

    [PSCustomObject]@{
        Name     = 'ごみ箱'
        Path     = 'C:\$Recycle.Bin'
        Safety   = '高'
        Note     = '不要な削除済みファイル。内容を確認してから空にする。'
    }

    [PSCustomObject]@{
        Name     = 'Scoop'
        Path     = Join-Path $env:USERPROFILE 'scoop'
        Safety   = '中'
        Note     = 'アプリ本体を含む。cacheや旧バージョンはScoopの機能で整理する。'
    }

    [PSCustomObject]@{
        Name     = 'Edge'
        Path     = Join-Path $env:LOCALAPPDATA 'Microsoft\Edge'
        Safety   = '中～高'
        Note     = '全量削除はしない。Edgeの設定からキャッシュを整理する。'
    }

    [PSCustomObject]@{
        Name     = 'uv'
        Path     = Join-Path $env:LOCALAPPDATA 'uv'
        Safety   = '中'
        Note     = '開発ツール関連。キャッシュを中心に整理候補。'
    }

    [PSCustomObject]@{
        Name     = 'npm cache'
        Path     = Join-Path $env:LOCALAPPDATA 'npm-cache'
        Safety   = '中～高'
        Note     = 'npmのキャッシュ。npmの機能で整理する。'
    }

    [PSCustomObject]@{
        Name     = 'WSL'
        Path     = Join-Path $env:LOCALAPPDATA 'wsl'
        Safety   = '低'
        Note     = 'Linux環境や仮想ディスクを含む。直接削除しない。'
    }
)


# =====================================================================
# 各対象のサイズ測定
# =====================================================================

$results = foreach ($target in $targets) {

    $bytes =
        Get-PathSizeBytes `
            -Path $target.Path

    [PSCustomObject]@{
        Name     = $target.Name
        SizeGB   = [double]$bytes / 1GB
        Safety   = $target.Safety
        Path     = $target.Path
        Note     = $target.Note
    }
}


# =====================================================================
# Claudeは2か所を合算
# =====================================================================

$claudePackagesBytes =
    Get-PathSizeBytes `
        -Path $claudePackagesPath

$claude3pBytes =
    Get-PathSizeBytes `
        -Path $claude3pPath

$claudeTotalBytes = [int64]$claudePackagesBytes + [int64]$claude3pBytes

$claudeTotal = [PSCustomObject]@{
    Name     = 'Claude 関連（合計）'
    SizeGB   = [double]$claudeTotalBytes / 1GB
    Safety   = '要確認'
    Path     = 'Claude Packages + Claude-3p'
    Note     = '必要データや仮想環境を含む可能性があるため、手動で全削除しない。'
}


# =====================================================================
# 回収ランキング
# =====================================================================

$ranking = @($results) + @($claudeTotal)

$ranking = @(
    $ranking |
        Where-Object {
            $_.SizeGB -gt 0
        } |
        Sort-Object -Property SizeGB -Descending |
        Select-Object -First $Top
)


Write-Host '=== 回収おすすめランキング ===' `
    -ForegroundColor Green

$rank = 0

$ranking |
    ForEach-Object {

        $rank++

        [PSCustomObject]@{
            Rank         = $rank
            Target       = $_.Name
            'Current GB' = '{0:N2}' -f $_.SizeGB
            Safety       = $_.Safety
            Path         = $_.Path
        }

    } |
    Format-Table -AutoSize

# =====================================================================
# 判断メモ
# =====================================================================

Write-Host ''
Write-Host '=== 判断メモ ===' `
    -ForegroundColor Green

foreach ($item in $ranking) {

    Write-Host (
        '[{0}] {1:N2} GB - {2}' -f `
            $item.Name,
            $item.SizeGB,
            $item.Note
    )
}


# =====================================================================
# もう一段掘る
# =====================================================================

Write-Host ''
Write-Host (
    '=== 各項目の直下ランキング TOP {0} ===' -f $ChildTop
) -ForegroundColor Green


foreach ($item in $ranking) {

    # Claudeだけは2つの実ディレクトリを別々に表示
    if ($item.Name -eq 'Claude 関連（合計）') {

        Show-ChildRanking `
            -Title 'Claude Packages' `
            -Path $claudePackagesPath `
            -Top $ChildTop

        Show-ChildRanking `
            -Title 'Claude-3p' `
            -Path $claude3pPath `
            -Top $ChildTop

        continue
    }

    Show-ChildRanking `
        -Title $item.Name `
        -Path $item.Path `
        -Top $ChildTop
}


# =====================================================================
# WSLについて補足
# =====================================================================

Write-Host ''
Write-Host '=== WSL 補足 ===' `
    -ForegroundColor Green

Write-Host `
    'WSLでは ext4.vhdx などの大きな仮想ディスクがファイルとして表示される場合があります。' `
    -ForegroundColor DarkGray

Write-Host `
    'フォルダーだけでなく、直下の大きなファイルもランキング対象にしています。' `
    -ForegroundColor DarkGray

Write-Host `
    'WSL配下のファイルやフォルダーは直接削除しないでください。' `
    -ForegroundColor Yellow


# =====================================================================
# Cドライブ情報
# =====================================================================

Write-Host ''
Write-Host '=== C: ドライブ ===' `
    -ForegroundColor Green

$driveInfo = Get-CDriveInfo

if ($null -ne $driveInfo) {

    [PSCustomObject]@{
        'Total GB' = '{0:N2}' -f $driveInfo.SizeGB
        'Used GB'  = '{0:N2}' -f $driveInfo.UsedGB
        'Free GB'  = '{0:N2}' -f $driveInfo.FreeGB
    } |
        Format-Table -AutoSize
}

# =====================================================================
# Cドライブ使用済み容量の大分類
#
# 削除候補ではなく、
# 「何にどれだけ使われているか」を確認するための表示。
# =====================================================================

function Get-CDriveUsedBreakdown {
    param(
        [int]$Top = 15
    )

    $systemDrive = 'C:\'

    $drive = Get-CimInstance `
        Win32_LogicalDisk `
        -Filter "DeviceID='C:'" `
        -ErrorAction SilentlyContinue

    if ($null -eq $drive) {
        return
    }

    $totalBytes = [double]$drive.Size
    $freeBytes  = [double]$drive.FreeSpace
    $usedBytes  = $totalBytes - $freeBytes

    Write-Host ''
    Write-Host '=== C: 使用済み容量の内訳 ===' `
        -ForegroundColor Green

    Write-Host `
        '※ 削除候補ではありません。Cドライブの使用先を把握するための分類です。' `
        -ForegroundColor DarkGray

    Write-Host `
        '※ System Volume Informationなど、アクセスできない領域は差額として表示します。' `
        -ForegroundColor DarkGray

    Write-Host ''

    # ------------------------------------------------------
    # Cドライブ直下のフォルダー
    # ------------------------------------------------------

    $folderResults = foreach (
        $folder in Get-ChildItem `
            -LiteralPath $systemDrive `
            -Force `
            -Directory `
            -ErrorAction SilentlyContinue
    ) {
        # ジャンクションやシンボリックリンクによる
        # 二重計上を避ける
        if ($folder.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            continue
        }

        $bytes = Get-PathSizeBytes `
            -Path $folder.FullName

        [PSCustomObject]@{
            Category = $folder.Name
            Type     = 'Folder'
            SizeGB   = [double]$bytes / 1GB
            Bytes    = [double]$bytes
            Path     = $folder.FullName
        }
    }

    # ------------------------------------------------------
    # Cドライブ直下の大きなシステムファイル
    #
    # pagefile.sys
    # hiberfil.sys
    # swapfile.sys
    # MEMORY.DMP など
    # ------------------------------------------------------

    $fileResults = foreach (
        $file in Get-ChildItem `
            -LiteralPath $systemDrive `
            -Force `
            -File `
            -ErrorAction SilentlyContinue
    ) {
        [PSCustomObject]@{
            Category = $file.Name
            Type     = 'File'
            SizeGB   = [double]$file.Length / 1GB
            Bytes    = [double]$file.Length
            Path     = $file.FullName
        }
    }

    $measuredResults = @($folderResults) + @($fileResults)

    $measuredBytes = (
        $measuredResults |
            Measure-Object `
                -Property Bytes `
                -Sum
    ).Sum

    if ($null -eq $measuredBytes) {
        $measuredBytes = 0
    }

    # ------------------------------------------------------
    # Windowsが報告する使用済み容量との差額
    #
    # 主に以下を含む可能性がある
    # - System Volume Information
    # - 復元ポイント
    # - シャドウコピー
    # - 保護されたシステム領域
    # - アクセス不能ファイル
    # - ファイルシステム管理領域
    # ------------------------------------------------------

    $unmeasuredBytes = $usedBytes - [double]$measuredBytes

    if ($unmeasuredBytes -lt 0) {
        # ハードリンク等により見かけ上の集計が
        # 実使用量を超えた場合は0扱いにする
        $unmeasuredBytes = 0
    }

    $breakdown = @($measuredResults)

    if ($unmeasuredBytes -gt 0) {
        $breakdown += [PSCustomObject]@{
            Category = '保護・未集計領域'
            Type     = 'System'
            SizeGB   = [double]$unmeasuredBytes / 1GB
            Bytes    = [double]$unmeasuredBytes
            Path     = 'System Volume Information、復元ポイント、アクセス不能領域など'
        }
    }

    # ------------------------------------------------------
    # 表示用ランキング
    # ------------------------------------------------------

    $sorted = @(
        $breakdown |
            Where-Object {
                $_.SizeGB -gt 0
            } |
            Sort-Object `
                -Property SizeGB `
                -Descending
    )

    $rank = 0

    $sorted |
        Select-Object -First $Top |
        ForEach-Object {
            $rank++

            $percent = if ($usedBytes -gt 0) {
                $_.Bytes / $usedBytes * 100
            }
            else {
                0
            }

            [PSCustomObject]@{
                Rank        = $rank
                Category    = $_.Category
                Type        = $_.Type
                'Used GB'   = '{0:N2}' -f $_.SizeGB
                'Used %'    = '{0:N1}%' -f $percent
                Description = switch -Wildcard ($_.Category) {
                    'Windows' {
                        'Windows本体、更新、ドライバー、コンポーネント'
                    }

                    'Users' {
                        'ユーザープロファイル、AppData、Scoop、開発環境'
                    }

                    'Program Files' {
                        '64ビットアプリケーション'
                    }

                    'Program Files (x86)' {
                        '主に32ビットアプリケーション'
                    }

                    'ProgramData' {
                        '全ユーザー共通のアプリデータ'
                    }

                    '$Recycle.Bin' {
                        'ごみ箱'
                    }

                    'pagefile.sys' {
                        '仮想メモリ'
                    }

                    'hiberfil.sys' {
                        '休止状態・高速スタートアップ'
                    }

                    'swapfile.sys' {
                        'Windowsのスワップ領域'
                    }

                    '保護・未集計領域' {
                        '復元ポイント、シャドウコピー、保護領域など'
                    }

                    default {
                        $_.Path
                    }
                }
            }
        } |
        Format-Table -AutoSize

    # ------------------------------------------------------
    # 使用済み容量全体のサマリー
    # ------------------------------------------------------

    Write-Host ''
    Write-Host '=== 使用済み容量サマリー ===' `
        -ForegroundColor Green

    $measuredPercent = if ($usedBytes -gt 0) {
        [double]$measuredBytes / $usedBytes * 100
    }
    else {
        0
    }

    $unmeasuredPercent = if ($usedBytes -gt 0) {
        [double]$unmeasuredBytes / $usedBytes * 100
    }
    else {
        0
    }

    [PSCustomObject]@{
        'C: Total GB' = '{0:N2}' -f ($totalBytes / 1GB)
        'C: Used GB'  = '{0:N2}' -f ($usedBytes / 1GB)
        '集計済み GB' = '{0:N2}' -f (
            [double]$measuredBytes / 1GB
        )
        '集計済み %'  = '{0:N1}%' -f $measuredPercent
        '未集計 GB'   = '{0:N2}' -f (
            [double]$unmeasuredBytes / 1GB
        )
        '未集計 %'    = '{0:N1}%' -f $unmeasuredPercent
        'C: Free GB'  = '{0:N2}' -f ($freeBytes / 1GB)
    } |
        Format-Table -AutoSize

    Write-Host ''
    Write-Host '見方:' -ForegroundColor Cyan
    Write-Host '・Windows、Program Files、ProgramDataは通常必要な領域です。'
    Write-Host '・Usersは個人データ、キャッシュ、開発環境が中心です。'
    Write-Host '・pagefile.sysは物理メモリを補助する仮想メモリです。'
    Write-Host '・hiberfil.sysは休止状態や高速スタートアップに使われます。'
    Write-Host '・保護・未集計領域は、通常の再帰集計では読めないWindows管理領域です。'
    Write-Host '・フォルダー容量はハードリンク等の影響で、実使用量と完全一致しない場合があります。' `
        -ForegroundColor DarkGray
}

# =====================================================================
# AppData\Local の項目を整理方法別に分類
#
# 分類はあくまで目安。
# この関数は調査・表示のみで、削除や圧縮は行わない。
# =====================================================================
function Get-LocalCleanupClassification {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Type
    )

    $normalizedName = $Name.ToLowerInvariant()
    $normalizedPath = $Path.ToLowerInvariant()

    # ファイルは名前だけでは判断しにくいため、原則として要確認
    if ($Type -eq 'File') {
        return [PSCustomObject]@{
            Classification = '要確認'
            Risk           = '中'
            Action         = 'ファイルの用途と更新日時を確認'
            Reason         = '単独ファイルは名前だけで安全性を判断しにくい'
        }
    }

    switch -Regex ($normalizedName) {

        '^temp$' {
            return [PSCustomObject]@{
                Classification = '削除可能'
                Risk           = '低'
                Action         = 'Windowsの一時ファイル機能、または使用中を除いて削除'
                Reason         = '一時ファイル置き場'
            }
        }

        '^crashdumps$' {
            return [PSCustomObject]@{
                Classification = '削除可能'
                Risk           = '低'
                Action         = '障害解析に不要なら古いダンプを削除'
                Reason         = 'アプリのクラッシュダンプ'
            }
        }

        '^(npm-cache|pip-cache)$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '低'
                Action         = 'npm cache clean --force など、管理コマンドを使用'
                Reason         = '再取得可能なパッケージキャッシュ'
            }
        }

        '^uv$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '低'
                Action         = 'uv cache clean'
                Reason         = 'uvのキャッシュや管理データを含む'
            }
        }

        '^(microsoftedge|edge)$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '低～中'
                Action         = 'Edgeの設定から「キャッシュされた画像とファイル」を削除'
                Reason         = 'User Dataには履歴、Cookie、パスワード等も含まれる'
            }
        }

        '^bravesoftware$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '低～中'
                Action         = 'Braveの設定から閲覧キャッシュを削除'
                Reason         = 'ブラウザープロファイル全体の直接削除は避ける'
            }
        }

        '^google$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '低～中'
                Action         = 'Chrome等の設定から閲覧キャッシュを削除'
                Reason         = 'ブラウザーやGoogleアプリのプロファイルを含む可能性がある'
            }
        }

        '^mozilla$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '低～中'
                Action         = 'Firefoxの設定からキャッシュを削除'
                Reason         = 'ブラウザープロファイルを含む可能性がある'
            }
        }

        '^claude-3p$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '中～高'
                Action         = 'Claude終了後、vm_bundles等の用途を確認してClaude側から整理'
                Reason         = '仮想環境やセッション関連データを含む可能性がある'
            }
        }

        '^zed$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '中'
                Action         = 'Zed終了後、Cacheやログなどの内訳を確認'
                Reason         = '設定、拡張機能、キャッシュが混在する可能性がある'
            }
        }

        '^zoom$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '中'
                Action         = 'Zoomの設定やアプリ終了後にログ・キャッシュを確認'
                Reason         = 'ログ、更新ファイル、設定が混在する可能性がある'
            }
        }

        '^adobe$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '中'
                Action         = 'AdobeアプリまたはCreative Cloudからキャッシュを整理'
                Reason         = 'アプリ設定やライセンス関連データを含む可能性がある'
            }
        }

        '^microsoft$' {
            return [PSCustomObject]@{
                Classification = '触らない'
                Risk           = '高'
                Action         = 'Microsoft配下をさらにアプリ別に調査'
                Reason         = 'Edge、Outlook、Office、OneDrive等が混在する'
            }
        }

        '^packages$' {
            return [PSCustomObject]@{
                Classification = '触らない'
                Risk           = '高'
                Action         = 'Packages全体は削除せず、パッケージ別に調査'
                Reason         = 'Microsoft Store・MSIXアプリのデータ領域'
            }
        }

        '^wsl$' {
            return [PSCustomObject]@{
                Classification = '触らない'
                Risk           = '高'
                Action         = 'Linux側の清掃後、必要に応じてVHDXを正規手順で縮小'
                Reason         = 'WSLの仮想ディスクやLinux環境本体を含む'
            }
        }

        '^programs$' {
            return [PSCustomObject]@{
                Classification = '触らない'
                Risk           = '高'
                Action         = '不要ならWindowsの「インストールされているアプリ」からアンインストール'
                Reason         = 'ユーザー単位でインストールされたアプリ本体'
            }
        }

        '^rancher-desktop$' {
            return [PSCustomObject]@{
                Classification = 'アプリから清掃'
                Risk           = '高'
                Action         = 'Rancher Desktopの設定やCLIからイメージ・VMを整理'
                Reason         = 'コンテナー、イメージ、仮想ディスクを含む可能性がある'
            }
        }

        '(^|[-_ ])(cache|caches|code cache|gpu cache)$' {
            return [PSCustomObject]@{
                Classification = '削除可能'
                Risk           = '低～中'
                Action         = '対象アプリを完全終了してから削除'
                Reason         = '名前上は再生成可能なキャッシュと考えられる'
            }
        }

        '(^|[-_ ])(log|logs|logging)$' {
            return [PSCustomObject]@{
                Classification = '圧縮候補'
                Risk           = '中'
                Action         = 'まず古いログを削除。保存が必要な場合だけZIPへ退避'
                Reason         = 'ログは削除を優先し、必要なログのみ圧縮保存する'
            }
        }

        default {
            return [PSCustomObject]@{
                Classification = '要確認'
                Risk           = '中'
                Action         = 'もう1階層掘り下げてCache、logs、データ本体を区別'
                Reason         = 'フォルダー名だけでは用途を安全に判断できない'
            }
        }
    }
}

# =====================================================================
# AppData\Local 直下TOPを分類付きで表示
# =====================================================================
function Show-LocalCleanupGuide {
    param(
        [string]$Path = $env:LOCALAPPDATA,

        [ValidateRange(1, 100)]
        [int]$Top = 20
    )

    Write-Host ''
    Write-Host (
        '=== AppData\Local 直下 TOP {0}・整理方法の目安 ===' -f $Top
    ) -ForegroundColor Green

    Write-Host $Path -ForegroundColor DarkGray

    Write-Host `
        '※ 分類はフォルダー名と一般的な用途による目安です。削除・圧縮は実行しません。' `
        -ForegroundColor DarkGray

    Write-Host `
        '※ 「削除可能」でも、対象アプリを完全終了してから作業してください。' `
        -ForegroundColor DarkGray

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host 'AppData\Localが見つかりません。' `
            -ForegroundColor Yellow
        return
    }

    $items = @(
        Get-ChildEntryRanking `
            -Path $Path `
            -Top $Top
    )

    if ($items.Count -eq 0) {
        Write-Host '集計対象がありません。' `
            -ForegroundColor DarkGray
        return
    }

    $rank = 0

    $classifiedItems = foreach ($item in $items) {
        $rank++

        $guide = Get-LocalCleanupClassification `
            -Name $item.Name `
            -Path $item.Path `
            -Type $item.Type

        [PSCustomObject]@{
            Rank           = $rank
            Type           = $item.Type
            SizeGB         = $item.SizeGB
            Name           = $item.Name
            Classification = $guide.Classification
            Risk           = $guide.Risk
            Action         = $guide.Action
            Reason         = $guide.Reason
            Path           = $item.Path
        }
    }

    # 全項目の一覧
    $classifiedItems |
        Format-Table `
            Rank,
            Type,
            @{
                Label = 'GB'
                Expression = {
                    '{0:N2}' -f $_.SizeGB
                }
            },
            Name,
            @{
                Label = '分類'
                Expression = {
                    $_.Classification
                }
            },
            @{
                Label = 'リスク'
                Expression = {
                    $_.Risk
                }
            } `
            -AutoSize

    # 項目ごとの詳細
    Write-Host ''
    Write-Host '=== AppData\Local 整理ガイド詳細 ===' `
        -ForegroundColor Green

    foreach ($item in $classifiedItems) {
        Write-Host ''
        Write-Host (
            '[{0}] {1}: {2:N2} GB' -f `
                $item.Classification,
                $item.Name,
                $item.SizeGB
        ) -ForegroundColor Cyan

        Write-Host ('  パス: {0}' -f $item.Path)
        Write-Host ('  リスク: {0}' -f $item.Risk)
        Write-Host ('  推奨: {0}' -f $item.Action)
        Write-Host ('  理由: {0}' -f $item.Reason) `
            -ForegroundColor DarkGray
    }

    # 分類別の合計
    Write-Host ''
    Write-Host '=== 分類別の現在容量 ===' `
        -ForegroundColor Green

    $classifiedItems |
        Group-Object -Property Classification |
        ForEach-Object {
            $totalGB = (
                $_.Group |
                    Measure-Object -Property SizeGB -Sum
            ).Sum

            [PSCustomObject]@{
                Classification = $_.Name
                Count          = $_.Count
                TotalGB        = [double]$totalGB
            }
        } |
        Sort-Object -Property TotalGB -Descending |
        Format-Table `
            @{
                Label = '分類'
                Expression = {
                    $_.Classification
                }
            },
            @{
                Label = '項目数'
                Expression = {
                    $_.Count
                }
            },
            @{
                Label = '現在 GB'
                Expression = {
                    '{0:N2}' -f $_.TotalGB
                }
            } `
            -AutoSize

    Write-Host ''
    Write-Host '分類の意味:' -ForegroundColor Cyan
    Write-Host '・削除可能: 一時データやダンプなど。アプリ終了後の削除候補。'
    Write-Host '・アプリから清掃: 手動削除より、アプリの設定や公式コマンドを優先。'
    Write-Host '・圧縮候補: 保存が必要な古いログ等。まず削除可否を判断。'
    Write-Host '・触らない: アプリ本体、仮想ディスク、パッケージデータ等。'
    Write-Host '・要確認: さらに1階層掘って用途を確認する。'
}

# =====================================================================
# 使用済み容量を表示
# =====================================================================

Get-CDriveUsedBreakdown -Top 15

# =====================================================================
# Users の直下をもう一段表示
# =====================================================================

Show-ChildRanking `
    -Title 'Users 使用量の内訳' `
    -Path 'C:\Users' `
    -Top $ChildTop

# =====================================================================
# 使用量が突出しているユーザーをさらに2階層表示
# =====================================================================

Show-DominantUserBreakdown `
    -UsersPath 'C:\Users' `
    -MinimumPercent 50 `
    -UserTop 1 `
    -Level1Top $ChildTop `
    -Level2Top $ChildTop

# =====================================================================
# AppData\Local の最新TOP20を分類付きで表示
# =====================================================================

Show-LocalCleanupGuide `
    -Path $env:LOCALAPPDATA `
    -Top 20

Write-Host ''
Write-Host `
    '※ このスクリプトは調査・ランキング表示専用です。ファイル削除は行いません。' `
    -ForegroundColor Yellow
