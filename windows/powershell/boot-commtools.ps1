#Requires -Version 7
# Outlook と Teams が起動していなければ、起動する（最小化は付けない。使ってみて、要るか決める）。
# 常時起動はメモリを食うので、タスク スケジューラ（taskschd.msc）から 30 分おきに呼ぶ想定。
# 起動済みなら何もしない。-WhatIf で、起動せずに何をするかだけを表示する。
#
# タスクの登録（taskschd.msc。手で行う）:
#   全般     : 「ユーザーがログオンしているときのみ実行する」（GUI アプリなので、ログオン中でないと起動できない）
#   トリガー : 1 回目はログオン時でもよい。繰り返し間隔 30 分、継続時間「無期限」
#   操作     : プログラム = pwsh.exe（scoop の shim なら絶対パスで指定する）
#              引数       = -NoProfile -WindowStyle Hidden -File "<この ps1 の絶対パス>"
#   条件     : 「AC 電源のときのみ」は外す（ノート PC のバッテリー駆動で止まるため）
[CmdletBinding(SupportsShouldProcess)]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 名前は Get-Process 用（拡張子なし）。Teams は新しい Teams（ms-teams.exe）。
$tools = @(
    @{ Label = 'Outlook'; Process = 'OUTLOOK';  Exe = 'outlook.exe' }
    @{ Label = 'Teams';   Process = 'ms-teams'; Exe = 'ms-teams.exe' }
)

foreach ($t in $tools) {
    if (Get-Process -Name $t.Process -ErrorAction SilentlyContinue) {
        Write-Host "[SKIP] $($t.Label): 起動済み"
        continue
    }
    if ($PSCmdlet.ShouldProcess($t.Exe, "$($t.Label) を起動")) {
        try {
            Start-Process -FilePath $t.Exe
            Write-Host "[OK] $($t.Label) を起動した"
        } catch {
            # 片方が失敗しても、もう片方は起動する
            Write-Host "[ERR] $($t.Label) を起動できない: $($_.Exception.Message)"
        }
    }
}
