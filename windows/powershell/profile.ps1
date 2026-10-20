# 非対話式で起動された場合は処理を抜ける (zed::claude)
if ([Console]::IsOutputRedirected -or [Console]::IsInputRedirected) { return }

# カーソル点滅を止める (DECSCUSR: 2 = 点滅なしブロック)。Windows Terminal に点滅の設定項目は無いため
[Console]::Write("$([char]27)[2 q")

# 方針: 起動を軽く保つ。ツール (starship/lsd/fzf/fd/zoxide/ghq) は apps.txt で入る前提で、
# 不在時の代替は持たない。コマンド体系は bash/zsh の common.sh と揃えること（基本エイリアスのみ）。

# Scoop の shim は、実体を起動する前にもう1プロセスを起動する（この PC では1回約 170ms）。
# 実体のあるディレクトリを PATH の先頭に足して、git / lsd / fzf などの shim を迂回する
$scoopApps = "$HOME\scoop\apps"
foreach ($d in 'git\current\cmd', 'lsd\current', 'fzf\current', 'fd\current', 'ripgrep\current', 'bat\current', 'zoxide\current', 'gh\current\bin', 'ghq\current') {
    $p = "$scoopApps\$d"
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) { $env:PATH = "$p;$env:PATH" }
}

# starship / zoxide の `init` は、起動のたびに外部コマンドを呼ぶ（この PC では合計約 0.8 秒）。
# 出力を %LOCALAPPDATA%\pwsh-init-cache に保存して使い回す。本体 exe（と設定）の更新日時が変わったら作り直す
function Get-InitCacheFile {
    param([string]$Name, [string[]]$Deps, [scriptblock]$Generate)
    $dir = "$env:LOCALAPPDATA\pwsh-init-cache"
    $key = ($Deps | ForEach-Object { if (Test-Path $_) { (Get-Item $_).LastWriteTimeUtc.Ticks } else { 0 } }) -join '-'
    $file = "$dir\$Name-$key.ps1"
    if (-not (Test-Path $file)) {
        $text = & $Generate
        New-Item -ItemType Directory $dir -Force | Out-Null
        Remove-Item "$dir\$Name-*.ps1" -ErrorAction SilentlyContinue
        [System.IO.File]::WriteAllText($file, $text, [System.Text.UTF8Encoding]::new($true))
    }
    $file
}

# For starship
# pwsh 専用の設定を使う（git_branch / git_status を持たない）。starship が git を調べると、プロセス生成が遅い PC では
# 1回のプロンプトが約 2.2 秒かかる（計測: docs/decisions.md）。ブランチ名は下の Invoke-Starship-PreCommand が出す
if (Test-Path "$HOME\.config\starship-pwsh.toml") { $env:STARSHIP_CONFIG = "$HOME\.config\starship-pwsh.toml" }

# プロンプトの直前に starship が呼ぶ。.git/HEAD を直接読んで、ブランチ名を PS_GIT_BRANCH に入れる（プロセスを起動しない）。
# 表示は starship-pwsh.toml の [env_var.PS_GIT_BRANCH]。リポジトリの外では空にする（空だとモジュールは出ない）
function Invoke-Starship-PreCommand {
    $env:PS_GIT_BRANCH = $null
    if ($PWD.Provider.Name -ne 'FileSystem') { return }
    $dir = $PWD.ProviderPath
    while ($dir) {
        $git = [System.IO.Path]::Combine($dir, '.git')
        if ([System.IO.Directory]::Exists($git)) { $head = [System.IO.Path]::Combine($git, 'HEAD'); break }
        if ([System.IO.File]::Exists($git)) {
            # worktree / submodule: .git ファイルの "gitdir: <path>" が実体
            $line = [System.IO.File]::ReadAllText($git).Trim()
            if ($line -notmatch '^gitdir:\s*(.+)$') { return }
            $head = [System.IO.Path]::Combine([System.IO.Path]::GetFullPath($Matches[1], $dir), 'HEAD')
            break
        }
        $dir = [System.IO.Path]::GetDirectoryName($dir)
    }
    if (-not $head -or -not [System.IO.File]::Exists($head)) { return }
    $text = [System.IO.File]::ReadAllText($head).Trim()
    $env:PS_GIT_BRANCH = if ($text -match '^ref:\s*refs/heads/(.+)$') { $Matches[1] }
                         elseif ($text.Length -ge 7) { $text.Substring(0, 7) }   # detached HEAD
}

# `init powershell` は starship をもう一度呼ぶスタブを返すので、完全版を直接取り込む（約 70ms 速い）。
# 完全版は、継続プロンプトを得るために starship をもう1回呼ぶので、その結果を文字列に置き換える
# （起動のたびに呼ばないため。見つからなければ置き換えず、元のまま動く）。
# 関数を現在のスコープに定義する必要があるので、関数の中ではなく、ここで dot-source する
. (Get-InitCacheFile 'starship' @((Get-Command starship).Source, $(if ($env:STARSHIP_CONFIG) { $env:STARSHIP_CONFIG } else { "$HOME\.config\starship.toml" })) {
    $text = & starship init powershell --print-full-init | Out-String
    $cont = (& starship prompt --continuation | Out-String).TrimEnd("`r", "`n").Replace("'", "''")
    $re = [regex]'(?s)Set-PSReadLineOption -ContinuationPrompt \(\s*Invoke-Native -Executable ''[^'']*'' -Arguments @\(\s*"prompt",\s*"--continuation"\s*\)\s*\)'
    $re.Replace($text, { "Set-PSReadLineOption -ContinuationPrompt '$cont'" })
})

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

# 社内プロキシ用 CA 証明書の環境変数は、27_volta.bat などが setx で永続化する（ここでは設定しない）

# Claude Code を API キー認証で起動する（`claude` は OAuth のまま）。設定は ~/.claude/settings-api.json
function claude-api { claude --settings "$HOME\.claude\settings-api.json" @args }

# Claude Code を Amazon Bedrock で起動する。設定はこの PC 専用の ~/.claude/settings-bedrock.json（claude-bedrock-setup.cmd で作る）
function claude-bedrock {
    $f = "$HOME\.claude\settings-bedrock.json"
    if (-not (Test-Path $f)) { Write-Host "[ERR] $f がありません。先に claude-bedrock-setup.cmd を実行してください。"; return }
    claude --settings $f @args
}

# Claude Code を OAuth（サブスク）で起動する。OAuth より優先される環境変数（API キー、Bedrock などの切替）を、この起動の間だけ外す
function claude-oauth {
    $names = 'ANTHROPIC_API_KEY', 'ANTHROPIC_AUTH_TOKEN', 'CLAUDE_CODE_USE_BEDROCK', 'CLAUDE_CODE_USE_MANTLE', 'CLAUDE_CODE_USE_VERTEX', 'CLAUDE_CODE_USE_FOUNDRY'
    $saved = @{}
    foreach ($n in $names) {
        $saved[$n] = [Environment]::GetEnvironmentVariable($n, 'Process')
        Remove-Item "Env:$n" -ErrorAction SilentlyContinue   # SetEnvironmentVariable($null) は空文字列で残るので使わない
    }
    try { claude @args }
    finally {
        foreach ($n in $names) {
            if ($null -ne $saved[$n]) { Set-Item "Env:$n" $saved[$n] } else { Remove-Item "Env:$n" -ErrorAction SilentlyContinue }
        }
    }
}

# Claude Code を組織の LLM ゲートウェイ（Entra ID などの OIDC で認証）で起動する。設定の場所を ~/.claude-gateway に分けて起動する
# （apiKeyHelper を共通の ~/.claude に入れると OAuth に戻れなくなるため分ける）。
# 設定は claude-gateway-setup.cmd で作り、初回は claude-gateway-token.cmd -Login でサインインする。環境に残った認証の変数は claude-oauth と同じく外す
function claude-gateway {
    $dir = "$HOME\.claude-gateway"
    if (-not (Test-Path "$dir\settings.json")) { Write-Host "[ERR] $dir\settings.json がありません。先に claude-gateway-setup.cmd を実行してください。"; return }
    if (-not (Test-Path "$dir\token.dpapi")) { Write-Host "[ERR] 未サインインです。先に claude-gateway-token.cmd -Login を実行してください。"; return }
    $saved = [Environment]::GetEnvironmentVariable('CLAUDE_CONFIG_DIR', 'Process')
    $env:CLAUDE_CONFIG_DIR = $dir
    try { claude-oauth @args }
    finally { if ($null -ne $saved) { $env:CLAUDE_CONFIG_DIR = $saved } else { Remove-Item Env:CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue } }
}

# 起動する認証を選ぶ: claude-pick（fzf で選ぶ）/ claude-pick oauth|api|bedrock|gateway。残りの引数は claude に渡す（例: claude-pick api --resume）
function claude-pick {
    $modes = 'oauth', 'api', 'bedrock', 'gateway'
    $mode = $args[0]
    $rest = @($args | Select-Object -Skip 1)
    if ($mode -notin $modes) {
        $rest = @($args)
        $mode = $modes | fzf --prompt='claude> ' --height=20% --reverse
    }
    switch ($mode) {
        'oauth'   { claude-oauth @rest }
        'api'     { claude-api @rest }
        'bedrock' { claude-bedrock @rest }
        'gateway' { claude-gateway @rest }
    }
}

# AI 作業部屋（WSL の room-<Area>）の対話シェルに入る。例: room-sh office-admin
# 部屋は増えるたびに Windows Terminal の設定が変わるので、タブには出さず、この関数で入る
function room-sh {
    param([Parameter(Mandatory)][string]$Area)
    wsl.exe -d "room-$Area"
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
function wk { Set-Location $env:WORKS_DIR }
function dof { Set-Location "$env:WORKS_DIR\repos\github.com\yuzucha16\dotfiles" }
function ~ { Set-Location $HOME }
function room { Set-Location "$env:WORKS_DIR\resources\workflow-kit\room" }

Set-Alias pd Push-Location
Set-Alias po Pop-Location
function dl { Get-Location -Stack }

# zoxide (z / zi)
. (Get-InitCacheFile 'zoxide' @((Get-Command zoxide).Source) { zoxide init powershell --cmd z | Out-String })

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
