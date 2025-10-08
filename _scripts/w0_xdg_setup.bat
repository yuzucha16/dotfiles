@echo off
REM XDG Base Directory setting for Windows (BAT version)

set "HOME=%USERPROFILE%"
set "XDG_CONFIG_HOME=%USERPROFILE%\.config"
set "XDG_CACHE_HOME=%USERPROFILE%\.cache"
set "XDG_DATA_HOME=%USERPROFILE%\.local\share"
set "XDG_STATE_HOME=%USERPROFILE%\.local\state"
set "XDG_BIN_HOME=%USERPROFILE%\.local\bin"
set "SSH_DIR=%USERPROFILE%\.ssh"
set "VAULT_HOME=%USERPROFILE%\OneDrive"
set "GHQ_ROOT=%USERPROFILE%\OneDrive\repos"
set "CERTS_DIR=%USERPROFILE%\OneDrive\certs"
set "MY_ROOT=%USERPROFILE%\OneDrive\repos\github.com\yuzucha16"
set "WSL_HOME=\\wsl$\ubuntu-24.04\home\yy"

REM 永続化するために setx を使う (User スコープ)
setx HOME "%HOME%"
setx XDG_CONFIG_HOME "%XDG_CONFIG_HOME%"
setx XDG_CACHE_HOME "%XDG_CACHE_HOME%"
setx XDG_DATA_HOME "%XDG_DATA_HOME%"
setx XDG_STATE_HOME "%XDG_STATE_HOME%"
setx XDG_BIN_HOME "%XDG_BIN_HOME%"
setx VAULT_HOME "%VAULT_HOME%"
setx GHQ_ROOT "%GHQ_ROOT%"
setx MY_ROOT "%MY_ROOT%"
setx WSL_HOME "%WSL_HOME%"

REM ディレクトリ作成
if not exist "%XDG_CONFIG_HOME%"    ( mkdir "%XDG_CONFIG_HOME%" )
if not exist "%XDG_CACHE_HOME%"     ( mkdir "%XDG_CACHE_HOME%" )
if not exist "%XDG_DATA_HOME%"      ( mkdir "%XDG_DATA_HOME%" )
if not exist "%XDG_STATE_HOME%"     ( mkdir "%XDG_STATE_HOME%" )
if not exist "%XDG_BIN_HOME%"       ( mkdir "%XDG_BIN_HOME%" )
if not exist "%SSH_DIR%"            ( mkdir "%SSH_DIR%" )
if not exist "%VAULT_HOME%"         ( mkdir "%VAULT_HOME%" )
if not exist "%GHQ_ROOT%"           ( mkdir "%GHQ_ROOT%" )
if not exist "%CERTS_DIR%"          ( mkdir "%CERTS_DIR%" )

REM 確認表示 (現在のセッションでは setx の結果は反映されない点に注意)
echo HOME               =%HOME%
echo XDG_CONFIG_HOME    =%XDG_CONFIG_HOME%
echo XDG_CACHE_HOME     =%XDG_CACHE_HOME%
echo XDG_DATA_HOME      =%XDG_DATA_HOME%
echo XDG_STATE_HOME     =%XDG_STATE_HOME%
echo XDG_BIN_HOME       =%XDG_BIN_HOME%
echo SSH_DIR            =%SSH_DIR%
echo VAULT_HOME         =%VAULT_HOME%
echo GHQ_ROOT           =%GHQ_ROOT%
echo CERTS_DIR          =%CERTS_DIR%
echo MY_ROOT            =%MY_ROOT%
echo WSL_HOME           =%WSL_HOME%

pause
