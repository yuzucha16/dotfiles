#requires -Version 7
<#
.SYNOPSIS
  AI 作業部屋（WSL の room-<Area>）に、starship・starship.toml・fzf（Ctrl-R の履歴検索）・履歴の種を入れる。何度実行しても同じ結果になる。
.DESCRIPTION
  部屋は /mnt/c が空で ai に sudo が無いので、Windows 側で取得・検証したものを wsl.exe の標準入力で ai のホームへ送る。
  ~/.bashrc は上書きせず、starship と fzf の初期化をそれぞれ追記する（room.py と uv の追記を残すため）。
  履歴の種は、先頭行がまだ無いときだけ ~/.bash_history の先頭に足す。
  例: pwsh -NoProfile -File windows\room\room-shell-setup.ps1 -Area myenv
#>
param(
    [string]$Area = 'myenv'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 版と SHA-256 を固定する（配布元: https://github.com/starship/starship/releases）。musl 版は x86_64 のみ
$Version = 'v1.27.0'
$Sha256 = '10c8eb4cb3b761d9bf59ea828444c2dab36c900b7d69a69e08814b286969df89'
$Url = "https://github.com/starship/starship/releases/download/$Version/starship-x86_64-unknown-linux-musl.tar.gz"

# fzf（配布元: https://github.com/junegunn/fzf/releases。SHA-256 は fzf_<版>_checksums.txt と同じ）
$FzfVersion = '0.74.5'
$FzfSha256 = 'd47d7f882972c7d674dbbba998ffa4116e68379616ffac7695d0671e9a722c5f'
$FzfUrl = "https://github.com/junegunn/fzf/releases/download/v$FzfVersion/fzf-$FzfVersion-linux_amd64.tar.gz"

# ~/.bashrc に足す fzf のブロック（Ctrl-R のみ。Ctrl-T・Alt-C・補完は使わない）。common.sh と値を揃えて直書き
$FzfBlock = @'

# fzf (dotfiles)
export FZF_DEFAULT_OPTS='--height=40% --reverse --border --info=inline'
export FZF_CTRL_R_OPTS='--no-sort --exact'
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
  bind -r '\ec' 2>/dev/null; bind -r '\C-t' 2>/dev/null
fi
'@

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Toml = Join-Path $Root 'home\.config\starship.toml'
$Seed = Join-Path $Root 'manifests\history.seed.sh.txt'
foreach ($f in $Toml, $Seed) {
    if (-not (Test-Path $f)) { throw "見つからない: $f" }
}

# automount を切った部屋は Windows のパスを変換できず、WSLENV 由来の警告が出る。この処理だけ外す
$env:WSLENV = $null
$Distro = "room-$Area"
$global:LASTEXITCODE = 0
wsl.exe -d $Distro -u ai -- true *> $null
if ($LASTEXITCODE -ne 0) { throw "部屋に入れない: $Distro（先に room init $Area）" }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory $tmp | Out-Null
try {
    $tgz = Join-Path $tmp 'starship.tar.gz'
    Invoke-WebRequest $Url -OutFile $tgz
    $actual = (Get-FileHash $tgz -Algorithm SHA256).Hash
    if ($actual -ine $Sha256) { throw "SHA-256 が一致しない: $actual" }

    $fzfTgz = Join-Path $tmp 'fzf.tar.gz'
    Invoke-WebRequest $FzfUrl -OutFile $fzfTgz
    $actual = (Get-FileHash $fzfTgz -Algorithm SHA256).Hash
    if ($actual -ine $FzfSha256) { throw "fzf の SHA-256 が一致しない: $actual" }

    $fzfB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($fzfTgz))
    $fzfBlockB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($FzfBlock -replace "`r", '')))
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($tgz))
    $tomlB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Toml))
    $seedB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Seed))

    $script = @"
set -e
mkdir -p ~/.local/bin ~/.config
echo '$b64' | base64 -d > /tmp/starship.tgz
echo '$Sha256  /tmp/starship.tgz' | sha256sum -c -
tar -xzf /tmp/starship.tgz -C ~/.local/bin starship
rm -f /tmp/starship.tgz
echo '$tomlB64' | base64 -d | tr -d '\r' > ~/.config/starship.toml
echo '$seedB64' | base64 -d | tr -d '\r' > /tmp/history.seed
touch ~/.bash_history
if ! grep -qxF "`$(head -n 1 /tmp/history.seed)" ~/.bash_history; then
  cat /tmp/history.seed ~/.bash_history > /tmp/history.new
  mv /tmp/history.new ~/.bash_history
fi
rm -f /tmp/history.seed
if ! grep -qF 'starship init bash' ~/.bashrc; then
  printf '\n# starship (dotfiles)\ncommand -v starship >/dev/null 2>&1 && eval "`$(starship init bash)"\n' >> ~/.bashrc
fi
echo '$fzfB64' | base64 -d > /tmp/fzf.tgz
echo '$FzfSha256  /tmp/fzf.tgz' | sha256sum -c -
tar -xzf /tmp/fzf.tgz -C ~/.local/bin fzf
rm -f /tmp/fzf.tgz
if ! grep -qF '# fzf (dotfiles)' ~/.bashrc; then
  echo '$fzfBlockB64' | base64 -d >> ~/.bashrc
fi
~/.local/bin/starship --version | head -n 1
~/.local/bin/fzf --version | head -n 1
"@
    # 標準入力は LF 固定で渡す（CRLF だと bash が壊れる）
    $global:LASTEXITCODE = 0
    ($script -replace "`r", '') | wsl.exe -d $Distro -u ai -- bash -s
    if ($LASTEXITCODE -ne 0) { throw "部屋での処理が失敗した（終了コード $LASTEXITCODE）" }
    Write-Host "OK: $Distro に starship $Version と fzf $FzfVersion を入れた。新しい bash で有効になる"
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
