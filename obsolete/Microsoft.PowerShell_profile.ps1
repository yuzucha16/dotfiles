# Import setting
$cur_dir = $(Split-Path $MyInvocation.MyCommand.Path -Parent)

$profile = $cur_dir + "\profile.ps1"
if (Test-Path $profile) {
      . $profile
	  Write-Host `tIncluded -ForegroundColor Green $profile
}
