if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned # Unrestricted

$dots_dir = $(Split-Path $MyInvocation.MyCommand.Path -Parent) + "\..\"
$files = @(
            @("notepadpp\config.xml",               "$Home\scoop\apps\notepadplusplus\current\config.xml"),
            @("notepadpp\contextMenu.xml",          "$Home\scoop\apps\notepadplusplus\current\contextMenu.xml"),
            @("notepadpp\shortcuts.xml",            "$Home\scoop\apps\notepadplusplus\current\shortcuts.xml"),
            @("notepadpp\stylers.xml",              "$Home\scoop\apps\notepadplusplus\current\stylers.xml"),
            @("nvim",                               "$Home\.config\nvim"),
            @("zed_settings.json",                  "$Home\AppData\Roaming\Zed\settings.json"),
            @("zed_keymap.json",                    "$Home\AppData\Roaming\Zed\keymap.json"),
            @(".vimrc",                             "$Home\.config\_vimrc"),
            @("Microsoft.PowerShell_profile.ps1",   "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
            @("profile.ps1",                        "$HOME\Documents\PowerShell\profile.ps1"),
            @("settings.json",                      "$Home\scoop\apps\windows-terminal\current\settings\settings.json"),
            @("config.nu",                          "$HOME\.config\nushell\config.nu"),
            @("env.nu",                             "$HOME\.config\nushell\env.nu"),
            @(".gitconfig",                         "$HOME\.config\git\config")
            )
            # [0]: src file, [1]: dst file

### Add new link
for( $i=0; $i -lt $files.Count; $i++ ){
  $ele = $files[$i];
  $src    = $dots_dir + $ele[0]
  $dst    = $ele[1]

  if( Test-Path $dst ){
	Write-Host `t- -ForegroundColor Blue Skip: $dst
    continue   # skip if already exists
  }
  New-Item -Itemtype SymbolicLink -path $dst -target $src -force
  if( !(Test-Path $dst) ){
	Write-Host `t- -ForegroundColor Red Error: $dst
  }else{
	Write-Host `t- -ForegroundColor Green Success: $dst
  }
}

pause
