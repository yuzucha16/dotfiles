# Install Notepad++ plugins (scoop version) from pinned GitHub release zips, and seed the Markdown Viewer++ CSS.
# Usage: install-plugins.ps1 -NppDir <...\notepadplusplus\current> [-ResetCss]
# -ResetCss overwrites the Markdown Viewer++ CSS with markdown-viewer.css even if it is not empty.
# Skips a plugin whose dll already exists. Close Notepad++ first (it rewrites plugin settings on exit).
param([Parameter(Mandatory)][string]$NppDir, [switch]$ResetCss)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

# Name must equal the dll name. Pinned versions + SHA256 (update both when upgrading).
$plugins = @(
  @{ Name = 'CSVLint'; Url = 'https://github.com/BdR76/CSVLint/releases/download/0.4.9/CSVLint_x64.zip'; Sha256 = '7335DED4A7B9CE320B5641E916E161EC01A29277014A894ABB3FDAEBF9CC3AF1' },
  @{ Name = 'MarkdownViewerPlusPlus'; Url = 'https://github.com/nea/MarkdownViewerPlusPlus/releases/download/0.8.2/MarkdownViewerPlusPlus-0.8.2-x64.zip'; Sha256 = 'E343C52798D76EF91BBA41821088CC3E199D475C7124571881B560B6A3EC4693' }
)

if (Get-Process notepad++ -ErrorAction SilentlyContinue) {
  Write-Warning 'Notepad++ is running. Close it and run again.'
  exit 1
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ('npp-plugins-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  foreach ($p in $plugins) {
    $dest = Join-Path $NppDir "plugins\$($p.Name)"
    if (Test-Path (Join-Path $dest "$($p.Name).dll")) { Write-Host "[Installed] Notepad++ plugin $($p.Name)"; continue }
    Write-Host "Installing Notepad++ plugin $($p.Name)"
    $zip = Join-Path $tmp "$($p.Name).zip"
    Invoke-WebRequest -Uri $p.Url -OutFile $zip
    if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $p.Sha256) { throw "SHA256 mismatch: $($p.Name)" }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Expand-Archive -LiteralPath $zip -DestinationPath $dest -Force
  }
} finally {
  Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

# Markdown Viewer++ custom CSS (single line): only when htmlCssStyle is empty or the ini is missing (or with -ResetCss)
$ini = Join-Path $NppDir 'plugins\Config\MarkdownViewerPlusPlus.ini'
$css = (Get-Content -LiteralPath (Join-Path $here 'markdown-viewer.css') -Raw).Trim()
if (-not (Test-Path $ini)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $ini) | Out-Null
  Set-Content -LiteralPath $ini -Value "[MarkdownViewerPlusPlus]`r`nhtmlCssStyle=$css" -Encoding ascii
  Write-Host 'Seeded Markdown Viewer++ CSS (new ini)'
} else {
  $text = [IO.File]::ReadAllText($ini)
  if ($text -match '(?m)^htmlCssStyle=\s*$' -or $ResetCss) {
    $text = $text -replace '(?m)^htmlCssStyle=.*$', ('htmlCssStyle=' + $css.Replace('$', '$$'))
    [IO.File]::WriteAllText($ini, $text, (New-Object Text.UTF8Encoding($false)))
    Write-Host 'Seeded Markdown Viewer++ CSS'
  } else {
    Write-Host '[Exists] Markdown Viewer++ CSS'
  }
}
