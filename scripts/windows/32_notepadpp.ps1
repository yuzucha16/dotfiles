param([switch]$DryRun)
# Apply the Notepad++ settings we care about to config.xml (idempotent upsert).
# config.xml is rewritten by the app on every exit, so it is not tracked in the repo; only the values below are enforced.
# Run via 32_notepadpp.bat. Windows PowerShell 5.1 / PowerShell 7 compatible.

$ErrorActionPreference = 'Stop'

$nppDir = Join-Path $env:USERPROFILE 'scoop\apps\notepadplusplus\current'
$config = Join-Path $nppDir 'config.xml'

if (-not (Test-Path -LiteralPath $nppDir)) {
  Write-Host "[ERR] Notepad++ not found: $nppDir (run 20_apps.bat first)"
  exit 1
}
if (Get-Process -Name 'notepad++' -ErrorAction SilentlyContinue) {
  Write-Host '[ERR] Notepad++ is running. Close it first (it overwrites config.xml on exit).'
  exit 1
}

# GUIConfig name -> attributes to set; '#text' sets the element text
$settings = [ordered]@{
  ToolBar              = @{ visible = 'no'; '#text' = 'small' }
  TabSetting           = @{ replaceBySpace = 'yes'; size = '2' }
  NewDocDefaultSettings = @{ format = '2'; encoding = '4' }   # LF, UTF-8
  Backup               = @{ isSnapshotMode = 'yes' }
  noUpdate             = @{ autoUpdateMode = '0'; '#text' = 'yes' }   # updates are done by scoop
  globalOverride       = @{ font = 'yes'; fontSize = 'yes' }   # font itself comes from the theme (Global override)
  Caret                = @{ blinkRate = '0' }
  DarkMode             = @{ enable = 'yes'; darkThemeName = 'Gruvbox dark medium.xml'; lightThemeName = 'Gruvbox light medium.xml' }
  ScintillaPrimaryView = @{ Wrap = 'yes' }
}

# scoop creates an empty config.xml on install; start from a skeleton in that case
$doc = New-Object System.Xml.XmlDocument
if ((Test-Path -LiteralPath $config) -and (Get-Item -LiteralPath $config).Length -gt 0) {
  $doc.Load($config)
} else {
  $doc.LoadXml('<?xml version="1.0" encoding="UTF-8" ?><NotepadPlus><GUIConfigs /></NotepadPlus>')
}

$root = $doc.DocumentElement
$guis = $root.SelectSingleNode('GUIConfigs')
if (-not $guis) { $guis = $root.AppendChild($doc.CreateElement('GUIConfigs')) }

$changed = 0
foreach ($name in $settings.Keys) {
  $el = $guis.SelectSingleNode("GUIConfig[@name='$name']")
  if (-not $el) {
    $el = $guis.AppendChild($doc.CreateElement('GUIConfig'))
    $el.SetAttribute('name', $name)
    Write-Host "[ADD] $name"
    $changed++
  }
  foreach ($key in $settings[$name].Keys) {
    $val = $settings[$name][$key]
    $cur = if ($key -eq '#text') { $el.InnerText } else { $el.GetAttribute($key) }
    if ($cur -eq $val) { continue }
    Write-Host ("[SET] {0}.{1}: '{2}' -> '{3}'" -f $name, $key, $cur, $val)
    if ($key -eq '#text') { $el.InnerText = $val } else { $el.SetAttribute($key, $val) }
    $changed++
  }
}

if ($changed -eq 0) {
  Write-Host '[OK] already up to date'
  exit 0
}
if ($DryRun) {
  Write-Host "[dry-run] $changed change(s), config.xml not written"
  exit 0
}

if (Test-Path -LiteralPath $config) { Copy-Item -LiteralPath $config "$config.bak" -Force }
$ws = New-Object System.Xml.XmlWriterSettings
$ws.Indent = $true
$ws.IndentChars = '    '
$ws.Encoding = New-Object System.Text.UTF8Encoding($false)
$xw = [System.Xml.XmlWriter]::Create($config, $ws)
try { $doc.Save($xw) } finally { $xw.Close() }
Write-Host "[OK] $changed change(s) written (backup: config.xml.bak)"
