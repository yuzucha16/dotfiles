@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem --- 必須コンポーネント（WSL2に必要） ---
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart

rem --- ハイパーバイザ起動を有効化 ---
bcdedit /set hypervisorlaunchtype auto

echo Please reboot now. After reboot, run the following manually:
wsl --update
wsl --list --online
wsl --install -d Ubuntu-24.04

:END
pause
endlocal
