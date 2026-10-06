@echo off
REM XDG Base Directory setting for Windows (BAT version)

set "HOME=%USERPROFILE%"
set "XDG_CONFIG_HOME=%USERPROFILE%\.config"
set "XDG_CACHE_HOME=%USERPROFILE%\.cache"
set "XDG_DATA_HOME=%USERPROFILE%\.local\share"
set "XDG_STATE_HOME=%USERPROFILE%\.local\state"
set "SSH_DIR=%USERPROFILE%\.ssh"

set "VAULT_HOME=C:\vault"
set "GHQ_ROOT=%VAULT_HOME%\repos"
set "WORKS_DIR=%VAULT_HOME%\works"
set "CERTS_DIR=%USERPROFILE%\.certs"

REM Persist with setx (User scope)
setx HOME "%HOME%"
setx XDG_CONFIG_HOME "%XDG_CONFIG_HOME%"
setx XDG_CACHE_HOME "%XDG_CACHE_HOME%"
setx XDG_DATA_HOME "%XDG_DATA_HOME%"
setx XDG_STATE_HOME "%XDG_STATE_HOME%"

setx VAULT_HOME "%VAULT_HOME%"
setx GHQ_ROOT "%GHQ_ROOT%"
setx CERTS_DIR "%CERTS_DIR%"
setx WORKS_DIR "%WORKS_DIR%"

REM Pass CERTS_DIR to WSL (/p converts the path). Append to WSLENV only once.
if not defined WSLENV ( setx WSLENV "CERTS_DIR/p" ) else ( echo ;%WSLENV%; | find "CERTS_DIR/p" >nul || setx WSLENV "%WSLENV%;CERTS_DIR/p" )

REM Create directories
if not exist "%XDG_CONFIG_HOME%"    ( mkdir "%XDG_CONFIG_HOME%" )
if not exist "%XDG_CACHE_HOME%"     ( mkdir "%XDG_CACHE_HOME%" )
if not exist "%XDG_DATA_HOME%"      ( mkdir "%XDG_DATA_HOME%" )
if not exist "%XDG_STATE_HOME%"     ( mkdir "%XDG_STATE_HOME%" )
if not exist "%SSH_DIR%"            ( mkdir "%SSH_DIR%" )
if not exist "%CERTS_DIR%"          ( mkdir "%CERTS_DIR%" )

if not exist "%VAULT_HOME%"         ( mkdir "%VAULT_HOME%" )
if not exist "%GHQ_ROOT%"           ( mkdir "%GHQ_ROOT%" )
REM WORKS_DIR is not created here: 30_link creates it as the parent of the .obsidian link, and the workflow hook
REM turns it into a local repo. The shared repo (workbase) is cloned into %WORKS_DIR%\resources by 50_repos.bat.

REM Show values (note: setx results are NOT reflected in the current session)
echo HOME               =%HOME%
echo XDG_CONFIG_HOME    =%XDG_CONFIG_HOME%
echo XDG_CACHE_HOME     =%XDG_CACHE_HOME%
echo XDG_DATA_HOME      =%XDG_DATA_HOME%
echo XDG_STATE_HOME     =%XDG_STATE_HOME%
echo SSH_DIR            =%SSH_DIR%

echo VAULT_HOME         =%VAULT_HOME%
echo GHQ_ROOT           =%GHQ_ROOT%
echo CERTS_DIR          =%CERTS_DIR%
echo WORKS_DIR          =%WORKS_DIR%

pause
