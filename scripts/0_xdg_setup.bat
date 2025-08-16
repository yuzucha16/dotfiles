@echo on
setlocal EnableExtensions

rem Debug+Auto-yes version: runs non-interactively and logs everything
set "ARG_DRYRUN=0"
set "ARG_PURGEENV=1"
for %%A in (%*) do (
  if /I "%%~A"=="/DRYRUN"   set "ARG_DRYRUN=1"
  if /I "%%~A"=="/PURGEENV" set "ARG_PURGEENV=1"
)

echo ======================================
echo   Scoop cleanup (Debug + Auto-yes)
echo   DRYRUN=%ARG_DRYRUN%  PURGEENV=%ARG_PURGEENV%
echo ======================================

rem ---- Detect Scoop paths ----
set "SCOOP_ROOT_DEFAULT=%USERPROFILE%\scoop"
set "SCOOP_SHIMS_DEFAULT=%SCOOP_ROOT_DEFAULT%\shims"
set "SCOOP_SHIMS_FOUND="
set "SCOOP_ROOT_FOUND="

where scoop.cmd
if %errorlevel%==0 (
  for /f "usebackq delims=" %%P in (`where scoop.cmd`) do (
    if not defined SCOOP_SHIMS_FOUND (
      set "SCOOP_SHIMS_FOUND=%%~dpP"
      for %%Q in ("%%~dpP..\") do set "SCOOP_ROOT_FOUND=%%~fQ"
    )
  )
)

if not defined SCOOP_SHIMS_FOUND (
  if exist "%SCOOP_SHIMS_DEFAULT%\scoop.cmd" (
    set "SCOOP_SHIMS_FOUND=%SCOOP_SHIMS_DEFAULT%\"
    set "SCOOP_ROOT_FOUND=%SCOOP_ROOT_DEFAULT%"
  )
)

if not defined SCOOP_SHIMS_FOUND (
  echo [Info] scoop.cmd not found anywhere.
  set "SCOOP_SHIMS_FOUND=%SCOOP_SHIMS_DEFAULT%\"
  set "SCOOP_ROOT_FOUND=%SCOOP_ROOT_DEFAULT%"
)

echo [Target] SHIMS = %SCOOP_SHIMS_FOUND%
echo [Target] ROOT  = %SCOOP_ROOT_FOUND%

rem ---- Show current state before deletion ----
if exist "%SCOOP_ROOT_FOUND%" (
  echo [Before] Listing Scoop root:
  dir /a "%SCOOP_ROOT_FOUND%"
) else (
  echo [Before] Scoop root NOT found at "%SCOOP_ROOT_FOUND%"
)

rem ---- Backup PATH from registry (user) ----
for /f "tokens=2,*" %%A in ('reg query HKCU\Environment /v PATH 2^>nul') do (
  set "OLD_PATH=%%B"
)
echo [Before] User PATH (registry):
echo %OLD_PATH%

if defined OLD_PATH (
  set "STAMP=%DATE: =0%_%TIME: =0%"
  set "STAMP=%STAMP::=%"
  set "STAMP=%STAMP:/=%"
  set "STAMP=%STAMP:.=%"
  set "STAMP=%STAMP:,=%"
  set "BACKUP_FILE=%USERPROFILE%\scoop_path_backup_%STAMP%.txt"
  if "%ARG_DRYRUN%"=="0" (
    >"%BACKUP_FILE%" echo %OLD_PATH%
    echo [Backup] PATH saved to %BACKUP_FILE%
  ) else (
    echo [DRYRUN] Would backup PATH to %BACKUP_FILE%
  )
)

rem ---- Filter PATH (remove \scoop\shims) ----
if defined OLD_PATH (
  setlocal EnableDelayedExpansion
  set "NEW_PATH="
  for %%S in ("!OLD_PATH:;=";"!") do (
    set "ITEM=%%~S"
    echo Checking PATH item: !ITEM!
    echo "!ITEM!" | findstr /I /C:"\scoop\shims" >nul
    if errorlevel 1 (
      if defined NEW_PATH (set "NEW_PATH=!NEW_PATH!;!ITEM!") else set "NEW_PATH=!ITEM!"
    ) else (
      echo [PATH-REMOVE] !ITEM!
    )
  )
  echo [Preview] New PATH will be:
  echo !NEW_PATH!
  if "%ARG_DRYRUN%"=="0" (
    setx PATH "!NEW_PATH!"
    endlocal
    rem verify write-back
    for /f "tokens=2,*" %%A in ('reg query HKCU\Environment /v PATH 2^>nul') do set "CHK_PATH=%%B"
    echo [After] User PATH (registry):
    echo %CHK_PATH%
  ) else (
    echo [DRYRUN] Would set PATH to new value
    endlocal
  )
)

rem ---- Delete Scoop root ----
if exist "%SCOOP_ROOT_FOUND%" (
  if "%ARG_DRYRUN%"=="0" (
    echo Removing directory: "%SCOOP_ROOT_FOUND%"
    rmdir /s /q "%SCOOP_ROOT_FOUND%"
    if exist "%SCOOP_ROOT_FOUND%" (
      echo [ERROR] Directory still exists after rmdir.
      echo Trying attrib -R and retry...
      attrib -R /S /D "%SCOOP_ROOT_FOUND%\*" 2>nul
      rmdir /s /q "%SCOOP_ROOT_FOUND%"
    )
  ) else (
    echo [DRYRUN] Would remove "%SCOOP_ROOT_FOUND%"
  )
) else (
  echo [Info] Scoop root not found at "%SCOOP_ROOT_FOUND%"
)

rem verify deletion
if exist "%SCOOP_ROOT_FOUND%" (
  echo [After] STILL EXISTS: "%SCOOP_ROOT_FOUND%"
) else (
  echo [After] Removed: "%SCOOP_ROOT_FOUND%"
)

rem ---- Purge env vars if requested ----
if "%ARG_PURGEENV%"=="1" (
  call :PurgeEnvVar "SCOOP"         %ARG_DRYRUN%
  call :PurgeEnvVar "SCOOP_HOME"    %ARG_DRYRUN%
  call :PurgeEnvVar "SCOOP_GLOBAL"  %ARG_DRYRUN%
  call :PurgeEnvVar "SCOOP_BRANCH"  %ARG_DRYRUN%
)

echo Cleanup finished (debug+auto).
goto :END

:PurgeEnvVar
set "_VARNAME=%~1"
if defined %~1 (
  if "%~2"=="0" (
    echo Clearing env var %_VARNAME%
    setx %_VARNAME% ""
  ) else (
    echo [DRYRUN] Would clear %_VARNAME%
  )
) else (
  echo Env var %_VARNAME% not set
)
exit /b 0

:END
endlocal
