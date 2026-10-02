@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ======================================================
REM  VS Code extensions installer (Windows)
REM  Installs the extensions listed in manifests\vscode-extensions.win.txt
REM  (already installed ones are skipped by code itself)
REM  Usage:  w1b_vscode_extensions.bat [list path]
REM  Export: code --list-extensions > manifests\vscode-extensions.win.txt
REM ======================================================

for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"
set "LIST=%~1"
if not defined LIST set "LIST=%DOTS_DIR%\manifests\vscode-extensions.win.txt"

where code >nul 2>&1
if errorlevel 1 (
  echo [ERROR] code not found on PATH. Run w1a_scoop_install.bat first.
  goto :END
)
if not exist "%LIST%" (
  echo [ERROR] list not found: %LIST%
  goto :END
)

echo Using list: %LIST%
set "ARGS="
for /F "usebackq eol=# tokens=1" %%E in ("%LIST%") do set "ARGS=!ARGS! --install-extension %%E"

if defined ARGS call code%ARGS%

echo.
echo Done.

:END
pause
endlocal
