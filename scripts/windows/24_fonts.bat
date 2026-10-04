@echo off
setlocal EnableExtensions

REM ======================================================
REM  Fonts (PlemolJP NF / MoralerspaceHW) downloader
REM  Gets the latest GitHub release zips with gh into %USERPROFILE%\download
REM  Install is manual: unzip, select the .ttf files, right click, Install for current user.
REM  Usage:  24_fonts.bat
REM  List: manifests\fonts.txt  (owner/repo:asset glob)
REM  gh login is not needed (public release downloads work without it)
REM ======================================================

for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"
set "LIST=%DOTS_DIR%\manifests\fonts.txt"
set "DL_DIR=%USERPROFILE%\download"

if not exist "%LIST%" (
  echo [ERROR] list not found: %LIST%
  goto :END
)

where gh >nul 2>&1
if errorlevel 1 (
  echo [ERROR] gh not found. Run 20_apps.bat first.
  goto :END
)

if not exist "%DL_DIR%\" mkdir "%DL_DIR%"

for /F "usebackq eol=# tokens=1,2 delims=:" %%A in ("%LIST%") do (
  echo %%A %%B
  gh release download --repo %%A --pattern "%%B" --dir "%DL_DIR%" --clobber
)

echo.
echo Downloaded to %DL_DIR%. Unzip and install the fonts manually.

:END
endlocal
