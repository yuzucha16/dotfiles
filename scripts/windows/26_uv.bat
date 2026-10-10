@echo off
setlocal EnableExtensions

REM ======================================================
REM  uv installer (official PowerShell installer) + Python 3.13
REM  Runs:  irm https://astral.sh/uv/install.ps1 | iex
REM  No question about installing. Then:
REM    uv python install 3.13 --default   (python / python3 in the bin dir)
REM    uv python pin --global 3.13        (user-wide default version)
REM    python --version                   (shows the resulting version)
REM  Asks y/N BEFORE installing about the SSL bundle (default N). On y, and only when
REM  %CERTS_DIR%\ca_bundle.crt exists, sets (persisted with setx, and for this run):
REM    UV_SYSTEM_CERTS=true  SSL_CERT_FILE=%CERTS_DIR%\ca_bundle.crt
REM  CERTS_DIR comes from 10_env.bat (run it first, in a new terminal).
REM  Usage:  26_uv.bat
REM  PS_EXE and SETX_EXE can be replaced (tests do).
REM ======================================================

if not defined PS_EXE set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not defined SETX_EXE set "SETX_EXE=setx"
set "PY_VER=3.13"

REM --- SSL bundle question (before installing, so the installer and the Python download use it)
call :ASKYN "Set the SSL bundle for uv (UV_SYSTEM_CERTS, SSL_CERT_FILE)?"
if errorlevel 2 (
  echo [ERR] invalid answer 5 times. Nothing installed.
  endlocal & exit /b 1
)
if errorlevel 1 goto :INSTALL

set "CA_FILE=%CERTS_DIR%\ca_bundle.crt"
if not defined CERTS_DIR (
  echo [SKIP] CERTS_DIR is not set. Run 10_env.bat and open a new terminal. SSL bundle not set.
  goto :INSTALL
)
if not exist "%CA_FILE%" (
  echo [SKIP] %CA_FILE% not found. SSL bundle not set. Put the CA bundle there and run this script again.
  goto :INSTALL
)
call "%SETX_EXE%" UV_SYSTEM_CERTS true >nul
call "%SETX_EXE%" SSL_CERT_FILE "%CA_FILE%" >nul
set "UV_SYSTEM_CERTS=true"
set "SSL_CERT_FILE=%CA_FILE%"
echo [OK] UV_SYSTEM_CERTS=true  SSL_CERT_FILE=%CA_FILE%

:INSTALL
call "%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
if errorlevel 1 (
  echo [ERR] uv installer failed.
  endlocal & exit /b 1
)

REM Reload PATH from the registry (this run does not see what the installer just added). Current entries stay first.
call :REFRESH_PATH
where uv >nul 2>&1
if errorlevel 1 (
  echo [WARN] uv not found on PATH yet. Open a NEW terminal and run:
  echo        uv python install %PY_VER% --default ^&^& uv python pin --global %PY_VER% ^&^& python --version
  endlocal & exit /b 0
)

call uv --version
call uv python install %PY_VER% --default
if errorlevel 1 (
  echo [ERR] uv python install failed.
  endlocal & exit /b 1
)
call uv python pin --global %PY_VER%
if errorlevel 1 (
  echo [ERR] uv python pin --global failed.
  endlocal & exit /b 1
)
echo.
echo [VERSION]
call python --version
if errorlevel 1 echo [WARN] python not found on PATH yet. Open a NEW terminal and run: python --version
endlocal & exit /b 0

:REFRESH_PATH
for /f "usebackq delims=" %%P in (`%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "$env:Path, [Environment]::GetEnvironmentVariable('Path','User'), [Environment]::GetEnvironmentVariable('Path','Machine') -join ';'"`) do set "PATH=%%P"
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
