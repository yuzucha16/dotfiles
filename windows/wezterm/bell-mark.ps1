# claude の Notification / Stop フック。WezTerm のタブに 🔔 を付ける旗（ファイル）を置く。
# WezTerm の update-status が %TEMP%\wezterm-bell\<pane_id> を拾って消す。
$p = $env:WEZTERM_PANE
if ($p) {
    $d = Join-Path $env:TEMP 'wezterm-bell'
    New-Item -ItemType Directory -Force $d | Out-Null
    New-Item -ItemType File -Force (Join-Path $d $p) | Out-Null
}
