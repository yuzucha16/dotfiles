@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM ======================================================
REM  Scoop apps/buckets installer (User mode only)
REM  管理者権限は不要。全てユーザースコープで実行します。
REM ======================================================

REM ▼Scoop のパス
set "SCOOP_ROOT=%USERPROFILE%\scoop"
set "SCOOP_SHIMS=%SCOOP_ROOT%\shims"
if exist "%SCOOP_SHIMS%\scoop.cmd" (
  set "PATH=%SCOOP_SHIMS%;%PATH%"
)

REM Scoop が無ければ導入 (Bypass)
if not exist "%SCOOP_SHIMS%\scoop.cmd" (
  echo Scoop not found. Installing...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb get.scoop.sh | iex"
  if errorlevel 1 (
    echo [ERROR] Scoop install failed.
    goto :END
  )
  if exist "%SCOOP_SHIMS%\scoop.cmd" set "PATH=%SCOOP_SHIMS%;%PATH%"
)

REM ▼最終確認
where scoop.cmd >nul 2>&1
if errorlevel 1 (
  echo [ERROR] scoop.cmd not found on PATH. Please check install.
  goto :END
)

REM ---------------------------------------------
REM  バケツとアプリ
REM ---------------------------------------------
set "BUCKETS=extras versions nonportable sysinternals"

REM ▼git は必須なので先に確保
if not exist "%SCOOP_ROOT%\apps\git\" (
  echo Installing git...
  call scoop.cmd install git
) else (
  echo [Installed] git
)

REM ▼バケツ追加
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
