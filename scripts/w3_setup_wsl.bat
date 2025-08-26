@echo off
setlocal EnableExtensions EnableDelayedExpansion

wsl --list --online
wsl --install -d Ubuntu-24.04

:END
pause
endlocal
