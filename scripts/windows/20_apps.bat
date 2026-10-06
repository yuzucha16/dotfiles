@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM ======================================================
REM  Scoop apps/buckets installer (User mode only)
REM  No admin rights needed. Everything runs in user scope.
REM ======================================================

REM Scoop paths
set "SCOOP_ROOT=%USERPROFILE%\scoop"
set "SCOOP_SHIMS=%SCOOP_ROOT%\shims"
if exist "%SCOOP_SHIMS%\scoop.cmd" (
  set "PATH=%SCOOP_SHIMS%;%PATH%"
)

REM Install Scoop if missing
REM On a new account, "-ExecutionPolicy Bypass" with iwr and iex failed with "Access is denied." (2026-10-06; cause not identified).
REM Follow the steps that worked on the real machine (set CurrentUser to RemoteSigned, then Invoke-RestMethod and Invoke-Expression; the official Scoop steps).
REM The execution policy is changed only when the effective value is Restricted/AllSigned/Undefined (left alone for Unrestricted/RemoteSigned/Bypass, which Scoop accepts).
REM If the change fails, only warn and continue (under Group Policy, Scoop itself shows the reason and stops).
REM PS_EXE is a full path, so PATH and the current directory do not matter (tests replace it).
if not defined PS_EXE set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%SCOOP_SHIMS%\scoop.cmd" (
  echo Scoop not found. Installing...
  call "%PS_EXE%" -NoProfile -Command "if ((Get-ExecutionPolicy).ToString() -in 'Restricted','AllSigned','Undefined') { try { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop } catch { Write-Warning ('Set-ExecutionPolicy failed: ' + $_.Exception.Message) } }; Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression"
  if errorlevel 1 (
    echo [ERROR] Scoop install failed. Execution policy of this account:
    call "%PS_EXE%" -NoProfile -Command "Get-ExecutionPolicy -List | Format-Table -AutoSize | Out-String"
    goto :END
  )
  if exist "%SCOOP_SHIMS%\scoop.cmd" set "PATH=%SCOOP_SHIMS%;%PATH%"
)

REM Final check
where scoop.cmd >nul 2>&1
if errorlevel 1 (
  echo [ERROR] scoop.cmd not found on PATH. Please check install.
  goto :END
)

REM ---------------------------------------------
REM  Buckets and apps
REM ---------------------------------------------
set "BUCKETS=extras versions nonportable sysinternals"

REM git is required, so get it first
if not exist "%SCOOP_ROOT%\apps\git\" (
  echo Installing git...
  call scoop.cmd install git
) else (
  echo [Installed] git
)

REM Add buckets
for %%B in (%BUCKETS%) do (
  if exist "%SCOOP_ROOT%\buckets\%%~B\" (
    echo [Added] %%~B
  ) else (
    echo Adding bucket %%~B ...
    call scoop.cmd bucket add %%~B
  )
)

REM Install apps: common apps.txt + optional apps.PROFILE.txt
REM Usage: 20_apps.bat [profile]   e.g. 20_apps.bat home
for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"
set "PROFILE_NAME=%~1"

REM Collect all names, then install in one scoop call (installed apps are skipped with a notice)
set "APPS="
call :COLLECT "%DOTS_DIR%\manifests\apps.txt"
if defined PROFILE_NAME call :COLLECT "%DOTS_DIR%\manifests\apps.%PROFILE_NAME%.txt"

if defined APPS (
  echo Installing:%APPS%
  call scoop.cmd install%APPS%
)

REM VC++ 2015-2022 x64 runtime: scoop only "suggests" extras/vcredist2022 (lsd, ripgrep, bat, starship, ...).
REM It is NOT installed here: its installer runs elevated (UAC), which breaks "user mode only".
REM Warn only when the runtime is missing; install it by hand if an app fails with VCRUNTIME140 / MSVCP140 not found.
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64" /v Installed 2>nul | find "0x1" >nul
if errorlevel 1 (
  echo [WARN] VC++ 2015-2022 x64 runtime not found. If an app fails with VCRUNTIME140 / MSVCP140 not found, run: scoop install extras/vcredist2022  ^(asks for UAC^)
) else (
  echo [Installed] VC++ 2015-2022 x64 runtime
)

REM Notepad++ config.xml: put the minimal one only when missing or empty (the app rewrites it afterwards; not linked)
set "NPP_DIR=%SCOOP_ROOT%\apps\notepadplusplus\current"
if exist "%NPP_DIR%\" (
  set "NPP_SEED=1"
  if exist "%NPP_DIR%\config.xml" for %%F in ("%NPP_DIR%\config.xml") do if %%~zF gtr 0 set "NPP_SEED="
  if defined NPP_SEED (
    echo Seeding Notepad++ config.xml
    copy /Y "%DOTS_DIR%\windows\notepadpp\config.min.xml" "%NPP_DIR%\config.xml" >nul
  ) else (
    echo [Exists] Notepad++ config.xml
  )
)

echo.
echo Done. Open a NEW terminal to refresh PATH if needed.
echo.
goto :END

:COLLECT
if not exist "%~1" (
  echo [WARN] app list not found: %~1
  goto :EOF
)
echo Using list: %~1
for /F "usebackq eol=# tokens=1" %%A in ("%~1") do set "APPS=!APPS! %%A"
goto :EOF

:END
pause
endlocal
