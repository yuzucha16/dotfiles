@echo off
REM XDG Base Directory setting for Windows (BAT version)

set "HOME=%USERPROFILE%"
set "XDG_CONFIG_HOME=%USERPROFILE%\.config"
set "XDG_CACHE_HOME=%USERPROFILE%\.cache"
set "XDG_DATA_HOME=%USERPROFILE%\.local\share"
set "XDG_STATE_HOME=%USERPROFILE%\.local\state"
set "SSH_DIR=%USERPROFILE%\.ssh"

set "WORKS_DIR=%USERPROFILE%\works"
set "GHQ_ROOT=%WORKS_DIR%\repos"
set "CERTS_DIR=%USERPROFILE%\.certs"

REM Persist with setx (User scope)
setx HOME "%HOME%"
setx XDG_CONFIG_HOME "%XDG_CONFIG_HOME%"
setx XDG_CACHE_HOME "%XDG_CACHE_HOME%"
setx XDG_DATA_HOME "%XDG_DATA_HOME%"
setx XDG_STATE_HOME "%XDG_STATE_HOME%"

setx GHQ_ROOT "%GHQ_ROOT%"
setx CERTS_DIR "%CERTS_DIR%"
setx WORKS_DIR "%WORKS_DIR%"

REM Pass CERTS_DIR and WORKS_DIR to WSL (/p converts the path; the WSL user name can differ from the Windows one).
REM Append each to WSLENV only once, then setx once (setx is not reflected in this session, so build the value first).
set "WSLENV_NEW=%WSLENV%"
echo ;%WSLENV_NEW%; | find "CERTS_DIR/p" >nul || ( if defined WSLENV_NEW ( set "WSLENV_NEW=%WSLENV_NEW%;CERTS_DIR/p" ) else ( set "WSLENV_NEW=CERTS_DIR/p" ) )
echo ;%WSLENV_NEW%; | find "WORKS_DIR/p" >nul || ( if defined WSLENV_NEW ( set "WSLENV_NEW=%WSLENV_NEW%;WORKS_DIR/p" ) else ( set "WSLENV_NEW=WORKS_DIR/p" ) )
if not "%WSLENV_NEW%"=="%WSLENV%" setx WSLENV "%WSLENV_NEW%"

REM Create directories
if not exist "%XDG_CONFIG_HOME%"    ( mkdir "%XDG_CONFIG_HOME%" )
if not exist "%XDG_CACHE_HOME%"     ( mkdir "%XDG_CACHE_HOME%" )
if not exist "%XDG_DATA_HOME%"      ( mkdir "%XDG_DATA_HOME%" )
if not exist "%XDG_STATE_HOME%"     ( mkdir "%XDG_STATE_HOME%" )
if not exist "%SSH_DIR%"            ( mkdir "%SSH_DIR%" )
if not exist "%CERTS_DIR%"          ( mkdir "%CERTS_DIR%" )

if not exist "%GHQ_ROOT%"           ( mkdir "%GHQ_ROOT%" )
REM GHQ_ROOT (%WORKS_DIR%\repos) is created here, which also creates WORKS_DIR as its parent. The workflow hook turns
REM WORKS_DIR into a local repo (repos\ is in its .gitignore). The shared repo (workbase) is cloned into
REM %WORKS_DIR%\resources by 50_repos.bat.

REM Show values (note: setx results are NOT reflected in the current session)
echo HOME               =%HOME%
echo XDG_CONFIG_HOME    =%XDG_CONFIG_HOME%
echo XDG_CACHE_HOME     =%XDG_CACHE_HOME%
echo XDG_DATA_HOME      =%XDG_DATA_HOME%
echo XDG_STATE_HOME     =%XDG_STATE_HOME%
echo SSH_DIR            =%SSH_DIR%

echo GHQ_ROOT          =%GHQ_ROOT%
echo CERTS_DIR          =%CERTS_DIR%
echo WORKS_DIR          =%WORKS_DIR%

pause
