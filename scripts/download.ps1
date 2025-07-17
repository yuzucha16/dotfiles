if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

Get-ExecutionPolicy
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
#Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope Process

$files = @( 
           "yuzucha16/tips",
           "yuzucha16/dotfiles",
           "coreutils\coreutils"
	  )
# "astronvim\template",
# "ryanoasis\nerd-fonts"

### Cloning repos
foreach( $item in $files ){
  Write-Host [Clone] $item
  ghq get $item
}

### Visual Studio Installer for 2022
# path: C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x64
winget install Microsoft.VisualStudio.2022.BuildTools

pause
