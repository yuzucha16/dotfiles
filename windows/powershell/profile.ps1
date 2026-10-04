# 非対話式で起動された場合は処理を抜ける (zed::claude)
if ([Console]::IsOutputRedirected -or [Console]::IsInputRedirected) { return }

# カーソル点滅を止める (DECSCUSR: 2 = 点滅なしブロック)。Windows Terminal に点滅の設定項目は無いため
[Console]::Write("$([char]27)[2 q")

# 方針: 起動を軽く保つ。ツール (starship/lsd/fzf/fd/zoxide/ghq) は apps.txt で入る前提で、
# 不在時の代替は持たない。コマンド体系は bash/zsh の common.sh と揃えること（基本エイリアスのみ）。

# For starship
# `init powershell` は starship をもう一度呼ぶスタブを返すので、完全版を直接取り込む（約 70ms 速い）
Invoke-Expression (& starship init powershell --print-full-init | Out-String)

# Emacs キーバインド
Set-PSReadLineOption -EditMode Emacs
# 保管候補を予測
Set-PSReadLineOption -PredictionSource History
# 候補一覧表示
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# 履歴 (bash/zsh と同じ件数・除外)
Set-PSReadLineOption -MaximumHistoryCount 50000
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    # 秘匿情報らしい行はメモリ上のみ（PSReadLine 既定の挙動を維持）
    if ($line -match 'password|asplaintext|token|apikey|secret') {
        return [Microsoft.PowerShell.AddToHistoryOption]::MemoryOnly
    }
    if ($line -match '^\s') { return $false }
    return $line -notmatch '^(ls|ll|la|l|cd|pwd|clear|history)$'
}

# Editor (bash/zsh と同じ)
$env:EDITOR = 'vim'
$env:VISUAL = 'vim'

# History search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+n -Function HistorySearchForward

# 社内プロキシ用 CA 証明書 (存在する環境のみ設定)
$caPath = "$env:CERTS_DIR\company-ca.crt"
if (Test-Path $caPath) {
  $env:NODE_EXTRA_CA_CERTS = $caPath
}

# Alias

# ls を lsd に置き換え（bash/zsh の common.sh と同じ体系）
# 組み込みの ls エイリアス (Get-ChildItem) は関数より優先されるため先に外す
Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
function ls { lsd --group-dirs=first --color=auto @args }
function l  { ls -l @args }
function la { ls -a @args }
function ll { ls -la @args }
function lt { ls --tree --depth 2 @args }
function l1 { ls -1 @args }
function l2 { ls --tree --depth 2 @args }
function l3 { ls --tree --depth 3 @args }

# ディレクトリ移動
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function b { Set-Location - }

Set-Alias pd Push-Location
Set-Alias po Pop-Location
function dl { Get-Location -Stack }

# zoxide (z / zi)
Invoke-Expression (& { (zoxide init powershell --cmd z | Out-String) })

# zoxide DB を fzf で選んでジャンプ (Alt+j)
function zfz {
    $dir = zoxide query -l 2>$null | fzf --prompt='zoxide> ' --height=80% --reverse
    if ($dir) { Set-Location -- $dir }
}

# ghq 管理下のリポジトリを fzf で選んで移動 (Alt+k)
function cdg {
    $dir = ghq list -p | fzf
    if ($dir) { Set-Location -- $dir }
}

# 3シェル共通: Alt+j = zfz, Alt+k = cdg（common.sh と揃える。全シェルで未使用のキーを選んだ）
Set-PSReadLineKeyHandler -Chord Alt+j -ScriptBlock { zfz; [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt() }
Set-PSReadLineKeyHandler -Chord Alt+k -ScriptBlock { cdg; [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt() }

# fzf の履歴検索 (Ctrl+r) とファイル検索 (Ctrl+t)。bash/zsh の common.sh と同じキー・同じ見た目。
# PSFzf は使わず、fzf を直接呼ぶ。
$env:FZF_DEFAULT_OPTS = '--height=40% --reverse'

# PSReadLine の履歴ファイルを、新しい順・重複なしで返す
function Get-FzfHistory {
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $lines = Get-Content -Path (Get-PSReadLineOption).HistorySavePath -ReadCount 0
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        if ($lines[$i] -and $seen.Add($lines[$i])) { $lines[$i] }
    }
}

function Invoke-FzfHistory {
    $line = $null; $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $sel = Get-FzfHistory | fzf --scheme=history --tiebreak=index --prompt='history> ' --query="$line"
    if ($sel) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($sel)
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

function Invoke-FzfFile {
    $sel = fd --hidden --follow --exclude .git | fzf -m --scheme=path --prompt='file> ' --preview 'bat --style=plain --color=always --line-range :200 {}'
    if ($sel) {
        # 空白などを含むパスは単一引用符で囲む
        $text = ($sel | ForEach-Object { if ($_ -match "[\s'`"`$;&(){}\[\]]") { "'" + $_.Replace("'", "''") + "'" } else { $_ } }) -join ' '
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($text + ' ')
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock { Invoke-FzfHistory }
Set-PSReadLineKeyHandler -Chord Ctrl+t -ScriptBlock { Invoke-FzfFile }
