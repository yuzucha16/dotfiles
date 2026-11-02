@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem Link dotfiles per manifests\links.map (symmetric with scripts/linux/30_link.sh)
rem Usage: 30_link.bat [link|unlink] [-n]
rem   link    (default) create symlinks / junctions; existing links are replaced
rem   unlink  remove the links only (real files are left alone)
rem   -n      dry run: print what would be done
rem Prerequisite: Developer Mode ON (mklink without admin)
rem A real file/dir at the destination is NOT touched: [ERR] is printed, move it by hand and re-run

rem === Repo root (two levels above this bat: scripts\windows) ===
for %%I in ("%~dp0..\..") do set "DOTS_DIR=%%~fI"

set "MODE=LINK"
set "DRY=0"
set "ERRCNT=0"

for %%A in (%*) do (
  if /I "%%A"=="link"   ( set "MODE=LINK" ) else (
  if /I "%%A"=="unlink" ( set "MODE=UNLINK" ) else (
  if /I "%%A"=="-n"     ( set "DRY=1" ) else (
    echo [ERR] unknown argument: %%A
    echo Usage: %~nx0 [link^|unlink] [-n]
    exit /b 1
  )))
)

echo [INFO] DOTS_DIR=%DOTS_DIR%
echo [INFO] Mode=%MODE%  DryRun=%DRY%
echo.

set "MAPFILE=%DOTS_DIR%\manifests\links.map"
if not exist "%MAPFILE%" (
  echo [ERR] map not found: %MAPFILE%
  exit /b 1
)

rem Lines starting with # and blank lines are ignored
rem Obsidian: generate the works-side derived config from the master first (scripts\obsidian_sync.py; link mode only)
if "%MODE%"=="LINK" call :OBSIDIAN_SYNC

for /F "usebackq eol=# tokens=1,2,3 delims=|" %%a in ("%MAPFILE%") do call :PROCESS "%%a" "%%b" "%%c"

echo.
if %ERRCNT% gtr 0 (
  echo [DONE] Mode=%MODE% finished with %ERRCNT% [ERR]. Move the files by hand and re-run.
) else (
  echo [DONE] Mode=%MODE% completed.
)
pause
if %ERRCNT% gtr 0 (endlocal & exit /b 1)
endlocal
goto :EOF

:OBSIDIAN_SYNC
set "SYNC=%DOTS_DIR%\scripts\obsidian_sync.py"
set "SYNCOPT="
if "%DRY%"=="1" set "SYNCOPT=-n"
where uv >nul 2>&1 && ( uv run --python 3.13 "%SYNC%" %SYNCOPT% & goto :SYNC_DONE )
where py >nul 2>&1 && ( py -3 "%SYNC%" %SYNCOPT% & goto :SYNC_DONE )
where python >nul 2>&1 && ( python "%SYNC%" %SYNCOPT% & goto :SYNC_DONE )
echo [WARN] no Python (uv / py / python): obsidian_sync.py skipped. The works vault config may be incomplete.
goto :EOF
:SYNC_DONE
if errorlevel 1 (
  echo [ERR] obsidian_sync.py failed
  set /a ERRCNT+=1
)
goto :EOF

:PROCESS
set "REL=%~1"
set "DST=%~2"
set "FLAG=%~3"
if not defined REL goto :EOF
if not defined DST goto :EOF
call set "DST=%DST%"
set "SRC=%DOTS_DIR%\%REL%"

rem Attributes of the destination: 'l' at position 9 = symlink/junction, 'd' at position 1 = directory
set "ATTR="
for %%F in ("%DST%") do set "ATTR=%%~aF"
set "ISLINK=0"
set "ISDIR=0"
if defined ATTR (
  if "!ATTR:~8,1!"=="l" set "ISLINK=1"
  if "!ATTR:~0,1!"=="d" set "ISDIR=1"
)

if "%MODE%"=="LINK"   call :LINK
if "%MODE%"=="UNLINK" call :UNLINK
goto :EOF

:LINK
if not exist "%SRC%" (
  echo [SKIP] no source: %SRC%
  goto :EOF
)
if /I "%FLAG%"=="noparent" for %%P in ("%DST%") do if not exist "%%~dpP" (
  echo [SKIP] parent dir does not exist yet ^(run again after 50_repos^): %DST%
  goto :EOF
)
rem noparent2 = same, but checks the grandparent (for a file whose own parent dir is made by this script, e.g. resources\.claudian)
if /I "%FLAG%"=="noparent2" for %%P in ("%DST%") do for %%G in ("%%~dpP..") do if not exist "%%~fG\" (
  echo [SKIP] grandparent dir does not exist yet ^(run again after 50_repos^): %DST%
  goto :EOF
)
if defined ATTR if "%ISLINK%"=="0" (
  echo [ERR] real file/dir exists, move it by hand: %DST%
  set /a ERRCNT+=1
  goto :EOF
)
if "%DRY%"=="1" (
  echo [DRY] link "%DST%" -^> "%SRC%"
  goto :EOF
)
if "%ISLINK%"=="1" call :RMLINK
for %%P in ("%DST%") do if not exist "%%~dpP" mkdir "%%~dpP" >nul 2>&1
if exist "%SRC%\*" (
  mklink /J "%DST%" "%SRC%" >nul
) else (
  mklink "%DST%" "%SRC%" >nul
)
if errorlevel 1 (
  echo [ERR] mklink failed ^(Developer Mode?^): %DST%
  set /a ERRCNT+=1
) else (
  echo [OK] "%DST%" -^> "%SRC%"
)
goto :EOF

:UNLINK
if not defined ATTR goto :EOF
if "%ISLINK%"=="0" (
  echo [SKIP] not a link, left alone: %DST%
  goto :EOF
)
if "%DRY%"=="1" (
  echo [DRY] unlink "%DST%"
  goto :EOF
)
call :RMLINK
echo [OK] unlinked "%DST%"
goto :EOF

:RMLINK
rem Remove a link only: rmdir for directory links, del for file links
if "%ISDIR%"=="1" ( rmdir "%DST%" >nul 2>&1 ) else ( del "%DST%" >nul 2>&1 )
goto :EOF
