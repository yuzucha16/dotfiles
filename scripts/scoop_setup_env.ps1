#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

#Get-ExecutionPolicy
#Set-ExecutionPolicy RemoteSigned # Unrestricted

Get-ExecutionPolicy
{ Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

### scoop installation
$buckets=@( "extras", "versions", "nonportable", "sysinternals" )
$apps   =@(
            "teraterm", "winmerge", "rufus", "irfanview", "googlechrome", "fork", "p4v",
            "windows-terminal", "pwsh", "nu", "starship", "vim", "neovim", "notepadplusplus",
            "PSReadLine", "posh-git", "Terminal-Icons", "scoop-completion", "autohotkey",
            "ghq", "cmake", "gcc", "rustup", "go", "uutils-coreutils", "sudo", "which", "openssh",
            "fzf", "lsd", "bat", "zoxide", "broot"
            )

### XDG Base Directory setting
$home_dir   = $env:USERPROFILE
$config_dir = $env:USERPROFILE + "\.config"
$cache_dir  = $env:USERPROFILE + "\.cache"
$data_dir   = $env:USERPROFILE + "\.local\share"
$state_dir  = $env:USERPROFILE + "\.local\state"
[Environment]::SetEnvironmentVariable('HOME', $home_dir, 'User')
[Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $config_dir, 'User')
[Environment]::SetEnvironmentVariable('XDG_CACHE_HOME',  $cache_dir,  'User')
[Environment]::SetEnvironmentVariable('XDG_DATA_HOME',   $data_dir,   'User')
[Environment]::SetEnvironmentVariable('XDG_STATE_HOME',  $state_dir,  'User')
[Environment]::GetEnvironmentVariables('User')

echo $env:HOME
echo $env:XDG_CONFIG_HOME
echo $env:XDG_CACHE_HOME
echo $env:XDG_DATA_HOME
echo $env:XDG_STATE_HOME

### work or config Directory setting
$bat_dir = $env:USERPROFILE + "\.config\bat"
[Environment]::SetEnvironmentVariable('BAT_CONFIG_PATH', $bat_dir, 'User')
echo $env:BAT_CONFIG_PATH

### Package Manager & git installaion
if( !(Test-Path ~/scoop) ){
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}
scoop install git

### Install app
foreach( $item in $buckets ){
  if( Test-Path ~/scoop/buckets/$item ){
    # Already exists
	Write-Host -ForegroundColor Green [Added]  $item
  }else{
    # starts
	scoop bucket add $item
  }
}


foreach( $item in $apps ){
  if( Test-Path ~/scoop/apps/$item ){
    # Already exists
	Write-Host -ForegroundColor Green [Installed]  $item
  }else{
    # starts
	scoop install $item
  }
}

### Visual Studio Installer for 2022
# path: C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.42.34433\bin\Hostx64\x64
winget install Microsoft.VisualStudio.2022.BuildTools

### Clone my setting
ghq get yuzucha16/dotfiles
ghq get yuzucha16/tips

pause
