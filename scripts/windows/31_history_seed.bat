@echo off
setlocal EnableExtensions
rem Seed the PSReadLine history with windows\powershell\history.seed.txt
rem Usage: 31_history_seed.bat [-n]
rem   -n   dry run: print what would be done
rem Copies only when the history file does not exist or is empty. An existing history is NEVER touched.
rem Not a symlink: PSReadLine appends to the history file on every command, which would dirty the repo.
rem Run it before the first pwsh session (a running pwsh keeps its own history in memory).
rem Seed lines hold <...> placeholders and do not run as they are (see exmem: shell-command-usecases).
rem The output is also saved to tmp\31_history_seed.log (git-ignored, overwritten on every run),
rem and the window waits at the end (pause) so a double-click does not close it.

for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"
set "LOG_DIR=%DOTS_DIR%\tmp"
set "LOG=%LOG_DIR%\31_history_seed.log"
if not exist "%LOG_DIR%\" mkdir "%LOG_DIR%"

> "%LOG%" echo [INFO] %DATE% %TIME%  %~nx0 %*
call :MAIN "%~1" >> "%LOG%" 2>&1
set "RC=%errorlevel%"

type "%LOG%"
echo [INFO] exit=%RC%  log=%LOG%
pause
endlocal & exit /b %RC%

:MAIN
set "SEED=%DOTS_DIR%\windows\powershell\history.seed.txt"
set "DEST_DIR=%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine"
set "DEST=%DEST_DIR%\ConsoleHost_history.txt"

set "DRY=0"
if /I "%~1"=="-n" set "DRY=1"
if not "%~1"=="" if "%DRY%"=="0" (
  echo Usage: %~nx0 [-n]
  exit /b 1
)

echo [INFO] seed=%SEED%
echo [INFO] dest=%DEST%  DryRun=%DRY%

if not exist "%SEED%" (
  echo [ERR] seed not found: %SEED%
  exit /b 1
)

set "DEST_SIZE=0"
if exist "%DEST%" for %%F in ("%DEST%") do set "DEST_SIZE=%%~zF"

if not "%DEST_SIZE%"=="0" (
  echo [SKIP] history already exists ^(%DEST_SIZE% bytes^): not overwritten
  exit /b 0
)

if "%DRY%"=="1" (
  echo [dry-run] copy "%SEED%" "%DEST%"
  exit /b 0
)

if not exist "%DEST_DIR%\" mkdir "%DEST_DIR%"
copy /Y "%SEED%" "%DEST%" >nul
if errorlevel 1 (
  echo [ERR] copy failed
  exit /b 1
)
echo [DONE] seeded the history. Open a new pwsh.
exit /b 0
