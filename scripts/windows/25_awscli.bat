@echo off
setlocal EnableExtensions

REM ======================================================
REM  AWS CLI v2 installer (official PowerShell installer)
REM  Runs:  irm https://awscli.amazonaws.com/v2/install.ps1 | iex
REM  Asks y/N first (default N: empty input or n installs nothing).
REM  After installing, sets AWS_CA_BUNDLE=%CERTS_DIR%\ca_bundle.crt (persisted with setx)
REM  only when that file exists. CERTS_DIR comes from 10_env.bat (run it first, in a new terminal).
REM  Usage:  25_awscli.bat
REM  Not in apps.txt on purpose: the official installer is the source of truth.
REM  PS_EXE and SETX_EXE can be replaced (tests do).
REM ======================================================

if not defined PS_EXE set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not defined SETX_EXE set "SETX_EXE=setx"

call :ASKYN "Install AWS CLI v2 with the official installer?"
if errorlevel 2 (
  echo [ERR] invalid answer 5 times. Nothing installed.
  endlocal & exit /b 1
)
if errorlevel 1 (
  echo [SKIP] AWS CLI not installed.
  endlocal & exit /b 0
)

call "%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -Command "irm https://awscli.amazonaws.com/v2/install.ps1 | iex"
if errorlevel 1 (
  echo [ERR] installer failed.
  endlocal & exit /b 1
)
echo [OK] AWS CLI installed.

REM SSL bundle (no question: it follows the install). Skipped when the file does not exist.
set "CA_FILE=%CERTS_DIR%\ca_bundle.crt"
if not defined CERTS_DIR (
  echo [SKIP] CERTS_DIR is not set. Run 10_env.bat and open a new terminal, then set AWS_CA_BUNDLE by hand.
  goto :DONE
)
if not exist "%CA_FILE%" (
  echo [SKIP] %CA_FILE% not found. AWS_CA_BUNDLE not set. Put the CA bundle there and run this script again.
  goto :DONE
)
call "%SETX_EXE%" AWS_CA_BUNDLE "%CA_FILE%" >nul
echo [OK] AWS_CA_BUNDLE=%CA_FILE%

:DONE
echo Open a NEW terminal, then check:  aws --version
endlocal & exit /b 0

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
