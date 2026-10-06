@echo off
setlocal EnableExtensions

REM ======================================================
REM  Fonts (PlemolJP NF / MoralerspaceHW) downloader
REM  Gets the latest GitHub release zips with gh into %USERPROFILE%\download
REM  Install is manual: unzip, select the .ttf files, right click, Install for current user.
REM  Usage:  24_fonts.bat
REM  List: manifests\fonts.txt  (owner/repo:asset glob)
REM  gh login is not needed (public release downloads work without it)
REM  The output is also saved to tmp\24_fonts.log (git-ignored, overwritten on every run),
REM  and the window waits at the end (pause) so a double-click does not close it.
REM ======================================================

for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"
set "LOG_DIR=%DOTS_DIR%\tmp"
set "LOG=%LOG_DIR%\24_fonts.log"
if not exist "%LOG_DIR%\" mkdir "%LOG_DIR%"

> "%LOG%" echo [INFO] %DATE% %TIME%  %~nx0
call :MAIN >> "%LOG%" 2>&1
set "RC=%errorlevel%"

type "%LOG%"
echo [INFO] exit=%RC%  log=%LOG%
pause
endlocal & exit /b %RC%

:MAIN
set "LIST=%DOTS_DIR%\manifests\fonts.txt"
set "DL_DIR=%USERPROFILE%\download"

if not exist "%LIST%" (
  echo [ERROR] list not found: %LIST%
  exit /b 1
)

where gh >nul 2>&1
if errorlevel 1 (
  echo [ERROR] gh not found. Run 20_apps.bat first.
  exit /b 1
)

if not exist "%DL_DIR%\" mkdir "%DL_DIR%"

set "FAILED=0"
for /F "usebackq eol=# tokens=1,2 delims=:" %%A in ("%LIST%") do (
  echo %%A %%B
  call gh release download --repo %%A --pattern "%%B" --dir "%DL_DIR%" --clobber
  if errorlevel 1 (
    echo [ERROR] download failed: %%A %%B
    set "FAILED=1"
  )
)

echo.
if "%FAILED%"=="1" (
  echo [ERROR] some downloads failed ^(see above^).
  exit /b 1
)
echo Downloaded to %DL_DIR%. Unzip and install the fonts manually.
exit /b 0
