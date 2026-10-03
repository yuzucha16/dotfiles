@echo off
setlocal EnableExtensions

REM ======================================================
REM  Fonts (PlemolJP NF / MoralerspaceHW) downloader
REM  Gets the latest GitHub release zips with gh into %USERPROFILE%\download
REM  Install is manual: unzip, select the .ttf files, right click, Install for current user.
REM  Usage:  24_fonts.bat [--dry-run]
REM    --dry-run: print the commands only (works without gh / gh login)
REM  List: manifests\fonts.txt  (owner/repo:asset glob)
REM ======================================================

for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"
set "LIST=%DOTS_DIR%\manifests\fonts.txt"
set "DL_DIR=%USERPROFILE%\download"

set "DRY="
if /I "%~1"=="--dry-run" set "DRY=1"
if not "%~1"=="" if not defined DRY (
  echo Usage: %~nx0 [--dry-run]
  goto :END
)

if not exist "%LIST%" (
  echo [ERROR] list not found: %LIST%
  goto :END
)

if defined DRY (
  echo [dry-run] mkdir "%DL_DIR%"
) else (
  where gh >nul 2>&1
  if errorlevel 1 (
    echo [ERROR] gh not found. Run 20_apps.bat first.
    goto :END
  )
  gh auth status >nul 2>&1
  if errorlevel 1 (
    echo [ERROR] gh is not logged in. Run: gh auth login
    goto :END
  )
  if not exist "%DL_DIR%\" mkdir "%DL_DIR%"
)

for /F "usebackq eol=# tokens=1,2 delims=:" %%A in ("%LIST%") do (
  if defined DRY (
    echo [dry-run] gh release download --repo %%A --pattern "%%B" --dir "%DL_DIR%" --clobber
  ) else (
    echo %%A %%B
    gh release download --repo %%A --pattern "%%B" --dir "%DL_DIR%" --clobber
  )
)

echo.
if defined DRY (
  echo [dry-run] done ^(nothing downloaded^)
) else (
  echo Downloaded to %DL_DIR%. Unzip and install the fonts manually.
)

:END
endlocal
