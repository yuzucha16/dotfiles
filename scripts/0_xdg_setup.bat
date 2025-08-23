@echo off
REM XDG Base Directory setting for Windows (BAT version)

set "HOME=%USERPROFILE%"
set "XDG_CONFIG_HOME=%USERPROFILE%\.config"
set "XDG_CACHE_HOME=%USERPROFILE%\.cache"
set "XDG_DATA_HOME=%USERPROFILE%\.local\share"
set "XDG_STATE_HOME=%USERPROFILE%\.local\state"
set "VAULT_HOME=%USERPROFILE%\vault"
set "GHQ_ROOT=%USERPROFILE%\vault\dev\src"

REM 永続化するために setx を使う (User スコープ)
setx HOME "%HOME%"
setx XDG_CONFIG_HOME "%XDG_CONFIG_HOME%"
setx XDG_CACHE_HOME "%XDG_CACHE_HOME%"
setx XDG_DATA_HOME "%XDG_DATA_HOME%"
setx XDG_STATE_HOME "%XDG_STATE_HOME%"
setx VAULT_HOME "%VAULT_HOME%"
setx GHQ_ROOT "%GHQ_ROOT%"

REM ディレクトリ作成
if not exist "%XDG_CONFIG_HOME%"    ( mkdir "%XDG_CONFIG_HOME%" )
if not exist "%XDG_CACHE_HOME%"     ( mkdir "%XDG_CACHE_HOME%" )
if not exist "%XDG_DATA_HOME%"      ( mkdir "%XDG_DATA_HOME%" )
if not exist "%XDG_STATE_HOME%"     ( mkdir "%XDG_STATE_HOME%" )
if not exist "%VAULT_HOME%"         ( mkdir "%VAULT_HOME%" )
if not exist "%GHQ_ROOT%"           ( mkdir "%GHQ_ROOT%" )

REM 確認表示 (現在のセッションでは setx の結果は反映されない点に注意)
echo HOME               =%HOME%
echo XDG_CONFIG_HOME    =%XDG_CONFIG_HOME%
echo XDG_CACHE_HOME     =%XDG_CACHE_HOME%
echo XDG_DATA_HOME      =%XDG_DATA_HOME%
echo XDG_STATE_HOME     =%XDG_STATE_HOME%
echo VAULT_HOME         =%VAULT_HOME%
echo GHQ_ROOT           =%GHQ_ROOT%

pause
