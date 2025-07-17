if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

Get-ExecutionPolicy
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
#Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope Process

$dots_dir = $(Split-Path $MyInvocation.MyCommand.Path -Parent) + "\..\"
$files = @(
            @("config",		               	        "$Home\.config\bat\config"),
            @("notepadpp\config.xml",               "$Home\scoop\apps\notepadplusplus\current\config.xml"),
            @("notepadpp\contextMenu.xml",          "$Home\scoop\apps\notepadplusplus\current\contextMenu.xml"),
            @("notepadpp\shortcuts.xml",            "$Home\scoop\apps\notepadplusplus\current\shortcuts.xml"),
            @("notepadpp\stylers.xml",              "$Home\scoop\apps\notepadplusplus\current\stylers.xml"),
            @("notepadpp\Zenburn_Darker-v2.xml",    "$Home\scoop\apps\notepadplusplus\current\themes\Zenburn_Darker-v2.xml"),
            @("nvim",                               "$Home\.config\nvim"),
#            @(".vimrc",                             "$Home\.config\_vimrc"),
            @(".vimrc",                             "$Home\.vimrc"),
            @("starship.toml",                      "$HOME\.config\starship.toml"),
			@("init.nu",                            "$HOME\.cache\starship\init.nu"),
            @("Microsoft.PowerShell_profile.ps1",   "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
            @("profile.ps1",                        "$HOME\Documents\PowerShell\profile.ps1"),
            @("settings.json",                      "$Home\scoop\apps\windows-terminal\current\settings\settings.json"),
            @("config.nu",                          "$HOME\.config\nushell\config.nu"),
            @("env.nu",                             "$HOME\.config\nushell\env.nu"),
			@("Autohotkey64.ahk",                   "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Autohotkey64.ahk"),
			@("Autohotkey64.ahk",                   "$HOME\scoop\apps\autohotkey\current\v2\Autohotkey64.ahk"),
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
