# Install-Module

# Import
# For scoop completion
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
#Import-Module PSFzf

# For starship
Invoke-Expression (&starship init powershell)

# History search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# 社内プロキシ用 CA 証明書 (存在する環境のみ設定)
$caPath = "$env:CERTS_DIR\company-ca.crt"
if (Test-Path $caPath) {
  $env:NODE_EXTRA_CA_CERTS = $caPath
}

<#
# Alias

# Functions

# FZF search
Set-PsFzfOption -PsReadlineChordProvider 'Ctrl+t' -PsReadlineChordReverseHistory 'Ctrl+r'

# ls を lsd に置き換え
if (Get-Command lsd -ErrorAction SilentlyContinue) {
    # ls → lsd に置き換え
    function ls { lsd --group-dirs=first --color=auto @args }

    # よく使うバリエーション
    function l  { lsd --group-dirs=first --color=auto -l @args }
    function la { lsd --group-dirs=first --color=auto -a @args }
    function ll { lsd --group-dirs=first --color=auto -la @args }
    function lt { lsd --group-dirs=first --color=auto --tree @args }

    # ツリーを深さ制限付きで
    function l1 { lsd --group-dirs=first --color=auto -1 @args }
    function l2 { lsd --group-dirs=first --color=auto --tree --depth 2 @args }
    function l3 { lsd --group-dirs=first --color=auto --tree --depth 3 @args }
}

# ディレクトリ移動（Set-Alias でシンプルに定義）
Set-Alias ..  Set-Location
Set-Alias ... Set-Location

### =========[ fzf 連携 (あれば自動有効化) ]=========
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # 検索コマンド (fd > rg > PowerShell fallback)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = 'fd --hidden --follow --exclude .git'
        $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    } elseif (Get-Command rg -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow -g "!.git"'
        $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    } else {
        # PowerShell のフォールバック（ファイル一覧を出力）
        $env:FZF_DEFAULT_COMMAND = 'powershell -NoProfile -Command "Get-ChildItem -Recurse -File -Force | ForEach-Object FullName"'
        $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    }

    # プレビュー (bat > PowerShell)
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        # bat は --line-range で件数制限できるので head 不要
        $env:FZF_CTRL_T_OPTS = '--preview "bat --style=plain --color=always --line-range :200 {}"'
    } else {
        # PowerShell で先頭200行を表示
        $env:FZF_CTRL_T_OPTS = '--preview "powershell -NoProfile -Command Get-Content -TotalCount 200 -- ''{}''"'
    }

    # ※ PowerShell で公式キーバインドを使う場合は PSFzf モジュールが便利:
    # if (Get-Module -ListAvailable PSFzf) { Import-Module PSFzf }
}

##########
# zoxide 初期化
##########
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # bash の eval に相当
    Invoke-Expression (& { (zoxide init powershell --cmd z | Out-String) })
}

##########
# fd の別名（Ubuntu系で fdfind の場合）
##########
if ((Get-Command fdfind -ErrorAction SilentlyContinue) -and -not (Get-Command fd -ErrorAction SilentlyContinue)) {
    Set-Alias fd fdfind
}

##########
# 1) 直前ディレクトリに即戻る（“b” = back）
##########
# PowerShell 7+ は「Set-Location -」で直前に戻れる
function b { Set-Location - }

##########
# 2) zoxide DB を fzf で選んでジャンプ
##########
function zfz {
    if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) { return }
    $dir = zoxide query -l 2>$null | fzf --prompt='zoxide> ' --height=80% --reverse
    if ($dir) { Set-Location -- $dir }
}

# 候補だけ一覧（番号付き）
function zlist {
    if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) { return }
    $i = 1
    zoxide query -l | ForEach-Object { '{0,4}  {1}' -f $i++, $_ }
}

##########
# 3) プロジェクト起点の fzf cd（Git ルート優先）
##########
function cdf {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) { return }

    $root = $null
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $root = (git rev-parse --show-toplevel 2>$null)
    }
    if ([string]::IsNullOrWhiteSpace($root)) { $root = '.' }

    # ディレクトリ列挙 (fd/fdfind が無ければ PowerShell で代替)
    $dirs = if (Get-Command fd -ErrorAction SilentlyContinue) {
        & fd -t d -H -I --strip-cwd-prefix . $root 2>$null
    } elseif (Get-Command fdfind -ErrorAction SilentlyContinue) {
        & fdfind -t d -H -I --strip-cwd-prefix . $root 2>$null
    } else {
        Get-ChildItem -Directory -Recurse -Force -Path $root | ForEach-Object {
            # --strip-cwd-prefix 相当（ルートからの相対表示）
            $_.FullName.Replace((Resolve-Path $root), '').TrimStart('\','/')
        }
    }

    if (-not $dirs) { return }
    $choice = $dirs | fzf --prompt="cdf ($root)> " --height=80% --reverse
    if ($choice) {
        # ルート + 相対で移動（root末尾のスラッシュを整理）
        $rootClean = $root.TrimEnd('\','/')
        Set-Location -- (Join-Path $rootClean $choice)
    }
}

##########
# 5) 上に n 階層上がる関数（例: up 3）
##########
function up {
    param([int]$n = 1)
    if ($n -lt 0) { return }
    $path = '.'
    for ($i = 0; $i -lt $n; $i++) {
        $path = Join-Path $path '..'
    }
    Microsoft.PowerShell.Management\Set-Location -LiteralPath $path
}

##########
# cd したら自動で ls する（Set-Location をラップ）
# ※ cd は Set-Location のエイリアスなので、これで cd も自動 ls になります
##########
function Set-Location {
    [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess=$true)]
    param(
        [Parameter(ParameterSetName='Path', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string] $Path,

        [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $LiteralPath,

        [switch] $PassThru
    )

    # 引数なしなら ~（ホーム）へ
    if (-not $PSBoundParameters.ContainsKey('Path') -and -not $PSBoundParameters.ContainsKey('LiteralPath')) {
        $PSBoundParameters['Path'] = '~'
    }

    # 本体を実行（無限再帰を避けるためモジュール修飾名を付ける）
    $result = $null
    try {
        $result = Microsoft.PowerShell.Management\Set-Location @PSBoundParameters
    } finally {
        if ($?) {
            # ここで ls（先に定義した lsd 置換があればそれが呼ばれる）
            l
        }
    }
    if ($PassThru) { return $result }
}

##########
# fzf のキーバインド/補完の代替
# （bash の examples/*.bash は PowerShell 非対応のため、PSFzf を使うのが実用的）
##########
# インストール済みなら有効化（任意）
if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    # 代表的なバインド例（お好みで）
    # Set-PsFzfOption -PsReadlineChordProvider 'Ctrl+t' -PsReadlineChordReverseHistory 'Ctrl+r'
}
#>
