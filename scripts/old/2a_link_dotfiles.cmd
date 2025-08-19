@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==== 対象スクリプト確認 ====
set "SCRIPT=%~dp02a_link_dotfiles.ps1"
if not exist "%SCRIPT%" (
  echo [ERROR] Not found: "%SCRIPT%"
  echo.
  echo Press any key to close...
  pause >nul
  exit /b 2
)

REM ==== まず pwsh、なければ powershell ====
set "HOSTEXE="
where pwsh >nul 2>&1 && set "HOSTEXE=pwsh"
if not defined HOSTEXE (
  where powershell >nul 2>&1 && set "HOSTEXE=powershell"
)

if not defined HOSTEXE (
  echo [ERROR] Neither ^"pwsh^" nor ^"powershell^" found in PATH.
  echo.
  echo Press any key to close...
  pause >nul
  exit /b 3
)

echo Using %HOSTEXE% ...
"%HOSTEXE%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %ARGS%
set "RC=%ERRORLEVEL%"

echo.
echo Exit code: %RC%

exit /b %RC%
