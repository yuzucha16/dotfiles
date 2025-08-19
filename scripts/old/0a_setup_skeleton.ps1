# XDG Base Directory setting for Windows (PowerShell version)

$HOME            = $env:USERPROFILE
$XDG_CONFIG_HOME = Join-Path $env:USERPROFILE ".config"
$XDG_CACHE_HOME  = Join-Path $env:USERPROFILE ".cache"
$XDG_DATA_HOME   = Join-Path $env:USERPROFILE ".local\share"
$XDG_STATE_HOME  = Join-Path $env:USERPROFILE ".local\state"
$VAULT_HOME      = Join-Path $env:USERPROFILE "vault"
$GHQ_ROOT        = Join-Path $env:USERPROFILE "vault\dev\src"

# 永続化するために setx を使う (User スコープ)
setx HOME            "$HOME"            | Out-Null
setx XDG_CONFIG_HOME "$XDG_CONFIG_HOME" | Out-Null
setx XDG_CACHE_HOME  "$XDG_CACHE_HOME"  | Out-Null
setx XDG_DATA_HOME   "$XDG_DATA_HOME"   | Out-Null
setx XDG_STATE_HOME  "$XDG_STATE_HOME"  | Out-Null
setx VAULT_HOME      "$VAULT_HOME"      | Out-Null
setx GHQ_ROOT        "$GHQ_ROOT"        | Out-Null

# ディレクトリ作成
foreach ($dir in @($XDG_CONFIG_HOME, $XDG_CACHE_HOME, $XDG_DATA_HOME, $XDG_STATE_HOME, 
                   $VAULT_HOME, "$VAULT_HOME\dev", "$VAULT_HOME\doc", "$VAULT_HOME\share",
                   $GHQ_ROOT)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Output "[Created] $dir"
    }
}

# 確認表示 (現在のセッションでは setx の結果は反映されない点に注意)
Write-Output "HOME=$HOME"
Write-Output "XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
Write-Output "XDG_CACHE_HOME=$XDG_CACHE_HOME"
Write-Output "XDG_DATA_HOME=$XDG_DATA_HOME"
Write-Output "XDG_STATE_HOME=$XDG_STATE_HOME"
Write-Output "VAULT_HOME=$VAULT_HOME"
Write-Output "GHQ_ROOT=$GHQ_ROOT"

Pause
