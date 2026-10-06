@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem --- Required components (needed for WSL2) ---
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart

rem --- Enable hypervisor launch ---
bcdedit /set hypervisorlaunchtype auto

echo Please reboot now. After reboot, run the following manually:
wsl --update
wsl --list --online
wsl --install -d Ubuntu-24.04

:END
pause
endlocal
