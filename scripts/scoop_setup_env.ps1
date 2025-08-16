#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }
#Get-ExecutionPolicy
#Set-ExecutionPolicy RemoteSigned # Unrestricted

#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
#Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope Process
Get-ExecutionPolicy
{ Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

### scoop installation
$buckets=@( "extras", "versions", "nonportable", "sysinternals" )
$apps   =@(
            "autohotkey", "winmerge", "rufus", "irfanview", "teraterm",
            "windows-terminal", "pwsh", "PSReadLine", "scoop-completion",
	    "neovim", "llvm", "goneovim", "notepadplusplus", "obsidian",
            "ghq", "sourcegit",
            "ripgrep", "fd", "which"
            )

# "googlechrome", "nu", "posh-git", "Terminal-Icons", "vim", "winget", "cmake", "gcc", "rustup", "go", "openssh", 
# "uutils-coreutils", "fd",  "lsd", "bat", "zoxide", "broot", "du", "sudo", "fzf", "starship",

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

if( !(Test-Path $config_dir) ){
  mkdir $config_dir
  Write-Host -ForegroundColor Green [Created]  $config_dir
}
if( !(Test-Path $cache_dir) ){
  mkdir $cache_dir
  Write-Host -ForegroundColor Green [Created]  $cache_dir
}
if( !(Test-Path $data_dir) ){
  mkdir $data_dir
  Write-Host -ForegroundColor Green [Created]  $data_dir
}
if( !(Test-Path $state_dir) ){
  mkdir $state_dir
  Write-Host -ForegroundColor Green [Created]  $state_dir
}

echo $env:HOME
echo $env:XDG_CONFIG_HOME
echo $env:XDG_CACHE_HOME
echo $env:XDG_DATA_HOME
echo $env:XDG_STATE_HOME

### work or config Directory setting
#$bat_dir = $env:USERPROFILE + "\.config\bat"
#[Environment]::SetEnvironmentVariable('BAT_CONFIG_PATH', $bat_dir, 'User')
#echo $env:BAT_CONFIG_PATH

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

pause
