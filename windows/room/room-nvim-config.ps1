#requires -Version 7
<#
.SYNOPSIS
  AI 作業部屋（WSL の room-<Area>）の ~/.config/nvim へ、dotfiles の nvim の設定（home\.config\nvim）を送り込む。何度実行しても同じ結果になる。
.DESCRIPTION
  nvim・zellij の本体と claude の bell フックは `room init`（段 nvim・zellij・bellhook）が入れる。ここは設定の送り込みだけ。
  設定は dotfiles が持つので、部屋の標準にはしていない（workbase は dotfiles の設定の中身を持たない）。
  上書きコピー（プラグインは初回の nvim 起動で lazy.nvim が取得する）。部屋は /mnt/c が空で ai に sudo が無いので、wsl.exe の標準入力で送る（room-shell-setup.ps1 と同じ方式）。
  例: pwsh -NoProfile -File windows\room\room-nvim-config.ps1 -Area myenv
#>
param(
    [string]$Area = 'myenv'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$NvimConf = Join-Path $Root 'home\.config\nvim'
if (-not (Test-Path (Join-Path $NvimConf 'init.lua'))) { throw "見つからない: $NvimConf\init.lua" }

# automount を切った部屋は Windows のパスを変換できず、WSLENV 由来の警告が出る。この処理だけ外す
$env:WSLENV = $null
$Distro = "room-$Area"
$global:LASTEXITCODE = 0
wsl.exe -d $Distro -u ai -- true *> $null
if ($LASTEXITCODE -ne 0) { throw "部屋に入れない: $Distro（先に room init $Area）" }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory $tmp | Out-Null
try {
    # tar.exe は Windows 標準
    $conf = Join-Path $tmp 'nvim-conf.tar.gz'
    tar.exe -czf $conf -C (Split-Path -Parent $NvimConf) 'nvim'
    if ($LASTEXITCODE -ne 0) { throw 'tar.exe に失敗した' }
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($conf))
    # 標準入力は LF 固定で渡す（CRLF だと bash が壊れる）。最後の行は余分な CR が付いてもよい行にする
    $global:LASTEXITCODE = 0
    (@"
set -e
mkdir -p ~/.config
echo '$b64' | base64 -d | tar -xzf - -C ~/.config
ls ~/.config/nvim
echo done
"@ -replace "`r", '') | wsl.exe -d $Distro -u ai -- bash -s
    if ($LASTEXITCODE -ne 0) { throw "部屋での処理が失敗した（終了コード $LASTEXITCODE）" }
    Write-Host "OK: $Distro の ~/.config/nvim に nvim の設定を送った"
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}