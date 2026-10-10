@echo off
setlocal EnableExtensions

REM ======================================================
REM  Volta (Node.js version manager) via scoop + the latest Node LTS
REM  No question about installing. Then:
REM    scoop install volta
REM    volta install node@lts     (pins the current LTS as the default toolchain)
REM    node --version / npm --version / npx --version   (shows the resulting versions)
REM  Asks y/N BEFORE installing about the SSL bundle (default N). On y, and only when
REM  %CERTS_DIR%\ca_bundle.crt exists, sets (persisted with setx, and for this run):
REM    NODE_EXTRA_CA_CERTS=%CERTS_DIR%\ca_bundle.crt
REM  Node is assumed to come from Volta, so this is the only place that sets it
REM  (profile.ps1 no longer does).
REM  CERTS_DIR comes from 10_env.bat (run it first, in a new terminal).
REM  Needs scoop (20_apps.bat). On Windows, Volta needs Developer Mode (symlinks) enabled.
REM  Usage:  27_volta.bat
REM  SETX_EXE can be replaced (tests do).
REM ======================================================

if not defined SETX_EXE set "SETX_EXE=setx"

if exist "%USERPROFILE%\scoop\shims\scoop.cmd" set "PATH=%USERPROFILE%\scoop\shims;%PATH%"
set "RC=0"
set "SHOW_NODE_EXTRA_CA_CERTS="
set "SHOW_VOLTA_HOME="

where scoop.cmd >nul 2>&1
if errorlevel 1 (
  echo [ERR] scoop.cmd not found on PATH. Run 20_apps.bat first.
  set "RC=1"
  goto :END
)

REM --- SSL bundle question
call :ASKYN "Set the SSL bundle for Node (NODE_EXTRA_CA_CERTS)?"
if errorlevel 2 (
  echo [ERR] invalid answer 5 times. Nothing installed.
  set "RC=1"
  goto :END
)
if errorlevel 1 (
  echo [SKIP] SSL bundle not set ^(answered n^). Run this script again and answer y to set it.
  goto :INSTALL
)

set "CA_FILE=%CERTS_DIR%\ca_bundle.crt"
if not defined CERTS_DIR (
  echo [SKIP] CERTS_DIR is not set. Run 10_env.bat and open a new terminal. SSL bundle not set.
  goto :INSTALL
)
if not exist "%CA_FILE%" (
  echo [SKIP] %CA_FILE% not found. SSL bundle not set. Put the CA bundle there and run this script again.
  goto :INSTALL
)
call "%SETX_EXE%" NODE_EXTRA_CA_CERTS "%CA_FILE%" >nul
set "NODE_EXTRA_CA_CERTS=%CA_FILE%"
set "SHOW_NODE_EXTRA_CA_CERTS=%CA_FILE%"
echo [OK] NODE_EXTRA_CA_CERTS set.

:INSTALL
echo [NOTE] Volta on Windows needs Developer Mode (Settings - For developers) for its shims.
call scoop.cmd install volta
if errorlevel 1 (
  echo [ERR] scoop install volta failed.
  set "RC=1"
  goto :END
)

REM Reload PATH and VOLTA_HOME from the registry (scoop sets both as user variables; this run does not see them).
call :REFRESH
where volta >nul 2>&1
if errorlevel 1 (
  echo [WARN] volta not found on PATH yet. Open a NEW terminal and run:
  echo        volta install node@lts ^&^& node --version ^&^& npm --version ^&^& npx --version
  goto :END
)

call volta --version
call volta install node@lts
if errorlevel 1 (
  echo [ERR] volta install node@lts failed.
  set "RC=1"
  goto :END
)
echo.
echo [VERSION]
for %%C in (node npm npx) do (
  echo | set /p "=%%C "
  call %%C --version
)

:END
echo.
echo [ENV] set by this script or scoop ^(User scope, effective in a NEW terminal^)
if defined SHOW_NODE_EXTRA_CA_CERTS echo NODE_EXTRA_CA_CERTS=%SHOW_NODE_EXTRA_CA_CERTS%
if not defined SHOW_NODE_EXTRA_CA_CERTS echo NODE_EXTRA_CA_CERTS=[not set]
if defined VOLTA_HOME echo VOLTA_HOME         =%VOLTA_HOME%
if not defined VOLTA_HOME echo VOLTA_HOME         =[not set]
echo.
pause
endlocal & exit /b %RC%

:REFRESH
for /f "usebackq delims=" %%P in (`%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "$env:Path, [Environment]::GetEnvironmentVariable('Path','User'), [Environment]::GetEnvironmentVariable('Path','Machine') -join ';'"`) do set "PATH=%%P"
for /f "usebackq delims=" %%V in (`%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "[Environment]::GetEnvironmentVariable('VOLTA_HOME','User')"`) do set "VOLTA_HOME=%%V"
exit /b 0

REM :ASKYN "prompt"   exit 0 = yes, 1 = no (n or empty), 2 = invalid 5 times
:ASKYN
set "TRIES=0"
:ASKYN_LOOP
set "ANS="
set /p "ANS=%~1 [y/N]: "
if not defined ANS exit /b 1
if /I "%ANS%"=="y" exit /b 0
if /I "%ANS%"=="n" exit /b 1
set /a TRIES+=1
if %TRIES% GEQ 5 exit /b 2
echo [WARN] please answer y or n.
goto :ASKYN_LOOP
