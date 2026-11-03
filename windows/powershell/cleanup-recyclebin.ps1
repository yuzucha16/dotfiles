#Requires -Version 7
# ゴミ箱のうち、削除してから -Months か月より前の項目だけを、一覧と容量を見せて確認してから完全に削除する。
# 一括で空にするのは、必要だったものまで消すリスクがある。かといって溜めるとストレージが逼迫するので、
# 「数か月の窓」を超えた分だけを、ときどき捨てる（手で実行する。タスク スケジューラには載せない）。
#
#   pwsh -NoProfile -File cleanup-recyclebin.ps1                 # 2 か月より前を対象に、確認してから削除
#   pwsh -NoProfile -File cleanup-recyclebin.ps1 -Months 3       # 窓を変える
#   pwsh -NoProfile -File cleanup-recyclebin.ps1 -ListOnly       # 一覧と容量を出すだけ（削除しない）
#
# 削除は Shell の "delete" 動詞（ゴミ箱内の項目の完全削除）。取り消せない。
# 日時は Shell が表示用の文字列で返すので、解釈できない項目は「削除しない」側に倒す（件数を報告する）。
[CmdletBinding()]
param(
    [ValidateRange(1, 120)][int]$Months = 2,
    [switch]$ListOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$limit = (Get-Date).AddMonths(-$Months)

$shell = New-Object -ComObject Shell.Application
$recycleBin = $shell.Namespace(0xA)   # 0xA = ゴミ箱

# GetDetailsOf の列: 1 = 元の場所、2 = 削除日時、3 = サイズ
function Get-DeletedDate($item) {
    $text = $recycleBin.GetDetailsOf($item, 2)
    # Shell の日時には、方向制御用の不可視 Unicode 文字が含まれるので除く
    $text = $text -replace '[‎‏‪-‮]', ''
    try { return Get-Date $text -ErrorAction Stop } catch { return $null }
}

$all = @($recycleBin.Items())
$targets = [System.Collections.Generic.List[object]]::new()
$unparsed = 0
foreach ($item in $all) {
    $d = Get-DeletedDate $item
    if ($null -eq $d) { $unparsed++; continue }
    if ($d -lt $limit) { $targets.Add($item) }
}

# 概算サイズ（取得できない項目は集計対象外）
$totalBytes = [long]0
foreach ($item in $targets) {
    try {
        $size = $item.ExtendedProperty('System.Size')
        if ($null -ne $size) { $totalBytes += [long]$size }
    } catch { }
}

$totalSize = if     ($totalBytes -ge 1GB) { '{0:N2} GB' -f ($totalBytes / 1GB) }
             elseif ($totalBytes -ge 1MB) { '{0:N2} MB' -f ($totalBytes / 1MB) }
             elseif ($totalBytes -ge 1KB) { '{0:N2} KB' -f ($totalBytes / 1KB) }
             else                         { "$totalBytes bytes" }

Write-Host ''
Write-Host "基準日時 : $limit"
Write-Host "ゴミ箱   : $($all.Count) 件"
Write-Host "削除対象 : $($targets.Count) 件"
Write-Host "概算容量 : $totalSize"
if ($unparsed -gt 0) { Write-Host "[WARN] 削除日時を読めず、対象外にした項目: $unparsed 件" }
Write-Host ''

if ($targets.Count -eq 0) {
    Write-Host '削除対象はありません。'
    exit 0
}

$targets | ForEach-Object {
    [pscustomobject]@{
        Name         = $_.Name
        OriginalPath = $recycleBin.GetDetailsOf($_, 1)
        DateDeleted  = (Get-DeletedDate $_)
        Size         = $recycleBin.GetDetailsOf($_, 3)
    }
} | Format-Table -AutoSize

if ($ListOnly) {
    Write-Host '-ListOnly のため、削除しません。'
    exit 0
}

Write-Host ''
$answer = Read-Host "$Months か月より前の $($targets.Count) 件（概算 $totalSize）を完全に削除しますか？ (y/N)"
if ($answer -ne 'y') {
    Write-Host 'キャンセルしました。'
    exit 0
}

foreach ($item in $targets) {
    Write-Host "削除: $($item.Name)"
    $item.InvokeVerb('delete')
}

Write-Host ''
Write-Host "完了しました。概算 $totalSize を削除しました。"
