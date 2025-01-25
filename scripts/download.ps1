if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned # Unrestricted

$files = @( "yuzucha16\dotfiles",
            "coreutils\coreutils",
			"ryanoasis\nerd-fonts"
		  )

### Cloning repos
foreach( $item in $files ){
  Write-Host [Clone] $item
  ghq get $item
}

pause
