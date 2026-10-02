@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ======================================================
REM  VS Code extensions installer (Windows)
REM  Installs only the missing extensions listed in manifests\vscode-extensions.win.txt
REM  Usage:  w1b_vscode_extensions.bat [list path]
REM  Export: code --list-extensions to manifests\vscode-extensions.win.txt
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

set "INSTALLED=%TEMP%\vscode_installed_extensions.txt"
call code --list-extensions > "%INSTALLED%"

echo Using list: %LIST%
for /F "usebackq eol=# tokens=1" %%E in ("%LIST%") do (
  findstr /X /I /C:"%%E" "%INSTALLED%" >nul
  if errorlevel 1 (
    echo Installing %%E ...
    call code --install-extension %%E
  ) else (
    echo [Installed] %%E
  )
)

del "%INSTALLED%" >nul 2>&1
echo.
echo Done.

:END
pause
endlocal
