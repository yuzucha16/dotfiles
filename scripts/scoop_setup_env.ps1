if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned # Unrestricted

### XDG Base Directory setting
$home_dir   = $env:USERPROFILE + "\.config"
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

### Package Manager & git installaion
if( !(Test-Path ~/scoop) ){
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}
scoop install git

pause
