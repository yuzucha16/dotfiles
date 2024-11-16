if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned # Unrestricted

$dots_dir = $(Split-Path $MyInvocation.MyCommand.Path -Parent) + "\..\"
$files = @(
            @("config.nu",                          "$HOME\.config\nushell\config.nu"),
            @("env.nu",                             "$HOME\.config\nushell\env.nu")
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
  New-Item -Itemtype SymbolicLink -path $dst -target $src
  if( !(Test-Path $dst) ){
	Write-Host `t- -ForegroundColor Red Error: $dst
  }else{
	Write-Host `t- -ForegroundColor Green Success: $dst
  }
}

pause
