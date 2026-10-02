@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem === Repo root (two levels above this bat: scripts\windows) ===
for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"

rem ---- MODE (argument 1; default LINK) ----
set "MODE=LINK"

rem 1) argument 1: copy / copyback / link
if /I "%~1"=="copy"     set "MODE=COPY"
if /I "%~1"=="copyback" set "MODE=COPYBACK"
if /I "%~1"=="link"     set "MODE=LINK"

echo MODE=%MODE%
echo.

rem ---- Map files: common links.map + optional links.PROFILE.map ----
rem 2) 2nd argument selects the profile: e.g. w2a_copy_dotfiles.bat link home
set "PROFILE_NAME=%~2"

call :LOADMAP "%DOTS_DIR%\manifests\links.map"
if defined PROFILE_NAME call :LOADMAP "%DOTS_DIR%\manifests\links.%PROFILE_NAME%.map"

echo Finished. MODE=%MODE%
goto :END

:LOADMAP
rem Read one map file and call :PROCESS per line (lines starting with # and blank lines are ignored)
set "MAPFILE=%~1"
if not exist "%MAPFILE%" (
  echo [WARN] map not found: %MAPFILE%
  goto :EOF
)
echo Using map: %MAPFILE%
for /F "usebackq eol=# tokens=1,2 delims=|" %%a in ("%MAPFILE%") do call :PROCESS "%%a" "%%b"
goto :EOF

:PROCESS
set "REL=%~1"
set "DST=%~2"
if not defined REL goto :EOF
if not defined DST goto :EOF
call set "DST=%DST%"

set "SRC=%DOTS_DIR%\%REL%"

if "%MODE%"=="COPY"     call :COPY "%SRC%" "%DST%"
if "%MODE%"=="COPYBACK" call :COPY "%DST%" "%SRC%"
if "%MODE%"=="LINK"     call :LINK "%SRC%" "%DST%"
goto :EOF

:COPY
rem Generic copy (files and directories)
set "SRC=%~1"
set "DST=%~2"
if exist "%SRC%\NUL" (
  robocopy "%SRC%" "%DST%" /E /COPY:DAT /R:1 /W:1 /NFL /NDL /NP /NJH /NJS >nul
) else (
  for %%P in ("%DST%") do set "DSTDIR=%%~dpP"
  if not exist "!DSTDIR!" mkdir "!DSTDIR!"
  copy /Y "%SRC%" "%DST%" >nul
)
goto :EOF

:LINK
set "SRC=%~1"
set "DST=%~2"

rem Normalize (strip trailing backslash)
if "%SRC:~-1%"=="\" set "SRC=%SRC:~0,-1%"
if "%DST:~-1%"=="\" set "DST=%DST:~0,-1%"

echo SRC = %SRC%
echo DST = %DST%

if not exist "%SRC%" (
  echo [SKIP] no source
  goto :EOF
)

for %%P in ("%DST%") do set "DSTDIR=%%~dpP"
if not exist "!DSTDIR!" mkdir "!DSTDIR!" >nul 2>&1

rem Clean up the destination: remove links only, back up real files/dirs as .bak-N
rem rmdir removes dir links (junction/symlink) and empty dirs, but not non-empty real dirs
rmdir "%DST%" >nul 2>&1
if exist "%DST%" (
  if exist "%DST%\*" (
    call :BACKUP_DST
  ) else (
    dir /AL "%DST%" >nul 2>&1
    if not errorlevel 1 (
      del "%DST%" >nul 2>&1
    ) else (
      call :BACKUP_DST
    )
  )
)

rem Branch by directory / file
if exist "%SRC%\*" (
  rem Directory: prefer junction (/J), else symlink (/D)
  mklink /J "%DST%" "%SRC%" >nul || mklink /D "%DST%" "%SRC%" >nul
) else (
  rem File: symlink; if it fails fall back to COPY (no hard links)
  mklink "%DST%" "%SRC%" >nul || (
    echo [INFO] symlink failed; fallback COPY
    for %%P in ("%DST%") do if not exist "%%~dpP" mkdir "%%~dpP" >nul 2>&1
    copy /Y "%SRC%" "%DST%" >nul
  )
)
echo.

if exist "%DST%" (
  echo [OK] "%DST%" -> "%SRC%"  >nul 2>&1
) else (
  echo [ERR] failed create (policy/permission?)
)
goto :EOF

:BACKUP_DST
rem Real file/dir: do not delete, move aside
set "BAKNAME=%DST%.bak-%RANDOM%"
echo [BACKUP] "%DST%" -^> "%BAKNAME%"
move /Y "%DST%" "%BAKNAME%" >nul 2>&1
goto :EOF

:END
pause
endlocal
