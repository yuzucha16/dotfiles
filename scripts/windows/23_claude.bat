@echo off
setlocal EnableExtensions

REM ======================================================
REM  Claude Code installer (official native installer)
REM  Runs:  irm https://claude.ai/install.ps1 | iex
REM  Asks y/N first (default N: empty input or n installs nothing).
REM  Usage:  23_claude.bat
REM  Not in apps.txt on purpose: the native installer updates itself, scoop does not need to.
REM ======================================================

set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "TRIES=0"

:ASK
set "ANS="
set /p "ANS=Install Claude Code with the official installer? [y/N]: "
if not defined ANS goto :SKIP
if /I "%ANS%"=="y" goto :INSTALL
if /I "%ANS%"=="n" goto :SKIP
set /a TRIES+=1
if %TRIES% GEQ 5 (
  echo [ERR] invalid answer 5 times. Nothing installed.
  endlocal & exit /b 1
)
echo [WARN] please answer y or n.
goto :ASK

:SKIP
echo [SKIP] Claude Code not installed.
endlocal & exit /b 0

:INSTALL
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -Command "irm https://claude.ai/install.ps1 | iex"
if errorlevel 1 (
  echo [ERR] installer failed.
  endlocal & exit /b 1
)
echo [OK] Claude Code installed. Open a new terminal and run: claude
endlocal & exit /b 0
