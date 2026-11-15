#requires -Version 7
<#
.SYNOPSIS
  AI 作業部屋（WSL の room-<Area>）に、WezTerm の「左 claude / 右 nvim」で使う道具を入れる: nvim・zellij・nvim の設定・claude の bell フック。何度実行しても同じ結果になる。
.DESCRIPTION
  部屋は /mnt/c が空で ai に sudo が無いので、Windows 側で取得・検証したものを wsl.exe の標準入力で ai のホームへ送る（room-shell-setup.ps1 と同じ方式）。
  - nvim: ~/.local/opt/nvim に展開し、~/.local/bin/nvim から張る。zellij: ~/.local/bin/zellij。
  - nvim の設定: home\.config\nvim を ~/.config/nvim へ上書きコピーする（プラグインは初回の nvim 起動で lazy.nvim が取得する）。
  - bell: ~/.claude/settings.json の Notification と Stop に `printf '\a' > /dev/tty` を足す（既にあれば足さない。他の設定は残す）。WezTerm の bell でタブに印が付く。
  例: pwsh -NoProfile -File windows\room\room-dev-setup.ps1 -Area myenv
#>
param(
    [string]$Area = 'myenv'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 版と SHA-256 を固定する（x86_64 のみ。配布元: https://github.com/neovim/neovim/releases、https://github.com/zellij-org/zellij/releases）
$NvimVersion = 'v0.12.6'
$NvimSha256 = '474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87'
$NvimUrl = "https://github.com/neovim/neovim/releases/download/$NvimVersion/nvim-linux-x86_64.tar.gz"
$ZellijVersion = 'v0.46.0'
$ZellijSha256 = 'a8ee599eb357b6142443c91506a4ece3aa8811cb75dcf2b28d194bd66853c79d'
$ZellijUrl = "https://github.com/zellij-org/zellij/releases/download/$ZellijVersion/zellij-x86_64-unknown-linux-musl.tar.gz"

# claude の bell フックを ~/.claude/settings.json に足す python（他のキーは残す）
$BellPy = @'
import json, os
f = os.path.expanduser("~/.claude/settings.json")
d = json.load(open(f)) if os.path.exists(f) else {}
h = d.setdefault("hooks", {})
cmd = "printf '\\a' > /dev/tty 2>/dev/null || true"
for ev in ("Notification", "Stop"):
    lst = h.setdefault(ev, [])
    if not any(x.get("command") == cmd for g in lst for x in g.get("hooks", [])):
        lst.append({"hooks": [{"type": "command", "command": cmd}]})
os.makedirs(os.path.dirname(f), exist_ok=True)
json.dump(d, open(f, "w"), indent=2, ensure_ascii=False)
'@

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$NvimConf = Join-Path $Root 'home\.config\nvim'
if (-not (Test-Path (Join-Path $NvimConf 'init.lua'))) { throw "見つからない: $NvimConf\init.lua" }

# automount を切った部屋は Windows のパスを変換できず、WSLENV 由来の警告が出る。この処理だけ外す
$env:WSLENV = $null
$Distro = "room-$Area"
$global:LASTEXITCODE = 0
wsl.exe -d $Distro -u ai -- true *> $null
if ($LASTEXITCODE -ne 0) { throw "部屋に入れない: $Distro（先に room init $Area）" }

function Invoke-Room([string]$Script) {
    # 標準入力は LF 固定で渡す（CRLF だと bash が壊れる）。パイプは末尾に CRLF を足すので、最後の行は余分な CR が付いてもよい行にする
    $global:LASTEXITCODE = 0
    ($Script -replace "`r", '') | wsl.exe -d $Distro -u ai -- bash -s
    if ($LASTEXITCODE -ne 0) { throw "部屋での処理が失敗した（終了コード $LASTEXITCODE）" }
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory $tmp | Out-Null
try {
    # 1) nvim
    $f = Join-Path $tmp 'nvim.tar.gz'
    Invoke-WebRequest $NvimUrl -OutFile $f
    if ((Get-FileHash $f -Algorithm SHA256).Hash -ine $NvimSha256) { throw 'nvim の SHA-256 が一致しない' }
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
    Invoke-Room @"
set -e
mkdir -p ~/.local/bin ~/.local/opt/nvim
echo '$b64' | base64 -d > /tmp/nvim.tgz
echo '$NvimSha256  /tmp/nvim.tgz' | sha256sum -c -
rm -rf ~/.local/opt/nvim/*
tar -xzf /tmp/nvim.tgz -C ~/.local/opt/nvim --strip-components=1
rm -f /tmp/nvim.tgz
ln -sf ~/.local/opt/nvim/bin/nvim ~/.local/bin/nvim
~/.local/bin/nvim --version | head -n 1
"@

    # 2) zellij
    $f = Join-Path $tmp 'zellij.tar.gz'
    Invoke-WebRequest $ZellijUrl -OutFile $f
    if ((Get-FileHash $f -Algorithm SHA256).Hash -ine $ZellijSha256) { throw 'zellij の SHA-256 が一致しない' }
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
    Invoke-Room @"
set -e
mkdir -p ~/.local/bin
echo '$b64' | base64 -d > /tmp/zellij.tgz
echo '$ZellijSha256  /tmp/zellij.tgz' | sha256sum -c -
tar -xzf /tmp/zellij.tgz -C ~/.local/bin zellij
rm -f /tmp/zellij.tgz
~/.local/bin/zellij --version
echo done
"@

    # 3) nvim の設定（tar.exe は Windows 標準）
    $conf = Join-Path $tmp 'nvim-conf.tar.gz'
    tar.exe -czf $conf -C (Split-Path -Parent $NvimConf) 'nvim'
    if ($LASTEXITCODE -ne 0) { throw 'tar.exe に失敗した' }
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($conf))
    Invoke-Room @"
set -e
mkdir -p ~/.config
echo '$b64' | base64 -d | tar -xzf - -C ~/.config
ls ~/.config/nvim
echo done
"@

    # 4) bell フック
    $pyB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($BellPy -replace "`r", '')))
    Invoke-Room @"
set -e
echo '$pyB64' | base64 -d | python3 -
grep -c 'printf' ~/.claude/settings.json
echo done
"@

    Write-Host "OK: $Distro に nvim $NvimVersion・zellij $ZellijVersion・nvim の設定・bell フックを入れた"
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
