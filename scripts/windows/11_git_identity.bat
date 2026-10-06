@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem Create %USERPROFILE%\.gitconfig_local (per-PC git identity) interactively. Run it after git is installed
rem (winget Git before the first clone) and BEFORE 30_link.bat.
rem Usage: 11_git_identity.bat
rem Only when the file does not exist. An existing file is NEVER touched.
rem Why not "git config --global": ~/.gitconfig is a symlink into this repo (home\.gitconfig, made by 30_link.bat).
rem   Before the link, --global would create a real ~/.gitconfig and 30_link.bat would stop with [ERR];
rem   after the link, it would rewrite the file in the repo. ~/.gitconfig includes ~/.gitconfig_local, so write there
rem   with --file. (The include is read only after 30_link.bat has linked ~/.gitconfig.)
rem No log file: the prompts must stay on the console.

set "LOCAL=%USERPROFILE%\.gitconfig_local"

where git >nul 2>&1
if errorlevel 1 (
  echo [ERR] git not found. Install it first ^(winget install Git.Git^).
  set "RC=1"
  goto :END
)

if exist "%LOCAL%" (
  echo [SKIP] already exists: %LOCAL%
  set "RC=0"
  goto :END
)

echo Creating %LOCAL%
rem Every invalid answer counts as a try; give up after 5 so that a closed stdin (e.g. < nul) cannot loop forever.
set /a TRIES=0
:ASK_NAME
set "GIT_NAME="
set /p "GIT_NAME=git user.name  : "
if not defined GIT_NAME (
  echo [WARN] user.name must not be empty.
  set /a TRIES+=1
  if !TRIES! geq 5 goto :NO_INPUT
  goto :ASK_NAME
)
:ASK_EMAIL
set "GIT_EMAIL="
set /p "GIT_EMAIL=git user.email : "
if not defined GIT_EMAIL (
  echo [WARN] user.email must not be empty.
  set /a TRIES+=1
  if !TRIES! geq 5 goto :NO_INPUT
  goto :ASK_EMAIL
)
echo !GIT_EMAIL!| find "@" >nul
if errorlevel 1 (
  echo [WARN] user.email should contain "@".
  set /a TRIES+=1
  if !TRIES! geq 5 goto :NO_INPUT
  goto :ASK_EMAIL
)


git config --file "%LOCAL%" credential.helperselector.selected manager
if errorlevel 1 goto :FAILED
git config --file "%LOCAL%" user.name "!GIT_NAME!"
if errorlevel 1 goto :FAILED
git config --file "%LOCAL%" user.email "!GIT_EMAIL!"
if errorlevel 1 goto :FAILED

echo [DONE] created %LOCAL%
type "%LOCAL%"
set "RC=0"
goto :END

:NO_INPUT
echo [ERR] no valid input after 5 tries. Nothing was written. Run it again.
set "RC=1"
goto :END

:FAILED
echo [ERR] git config failed. Remove %LOCAL% and run again.
set "RC=1"

:END
pause
endlocal & exit /b %RC%
