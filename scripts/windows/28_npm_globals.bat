@echo off
setlocal EnableExtensions

REM ======================================================
REM  Global npm tools via Volta: volta install <name> for each line of manifests\npm.txt
REM  (volta install keeps them under Volta's shims, so they survive Node switches).
REM  Needs Volta and Node (27_volta.bat). No question is asked.
REM  Continues after a failure and returns 1 at the end if any package failed.
REM  Usage:  28_npm_globals.bat
REM ======================================================

set "LIST=%~dp0..\..\manifests\npm.txt"
set "RC=0"

where volta >nul 2>&1
if errorlevel 1 (
  echo [ERR] volta not found on PATH. Run 27_volta.bat first, then open a new terminal.
  set "RC=1"
  goto :END
)
if not exist "%LIST%" (
  echo [ERR] %LIST% not found.
  set "RC=1"
  goto :END
)

for /f "usebackq eol=# tokens=1" %%P in ("%LIST%") do (
  echo [RUN] volta install %%P
  call volta install %%P
  if errorlevel 1 (
    echo [ERR] volta install %%P failed.
    set "RC=1"
  ) else (
    echo [OK] %%P
  )
)

:END
pause
endlocal & exit /b %RC%
