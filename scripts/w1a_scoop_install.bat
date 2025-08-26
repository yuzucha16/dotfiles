@echo off
setlocal EnableExtensions EnableDelayedExpansion
set APPS=^
windows-terminal ^
pwsh ^
PSReadLine ^
universal-ctags ^
starship ^
scoop-completion ^
notepadplusplus ^
vscode ^
neovim ^
goneovim ^
llvm ^
winmerge ^
marktext ^
pdf-xchange-editor ^
ghq ^
fork ^
sourcegit ^
fzf ^
ripgrep ^
fd ^
which ^
lsd ^
broot ^
zoxide

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

REM ▼アプリインストール
for %%A in (%APPS%) do (
  if exist "%SCOOP_ROOT%\apps\%%~A\" (
    echo [Installed] %%~A
  ) else (
    echo Installing %%~A ...
    call scoop.cmd install %%~A
  )
)

echo.
echo Done. Open a NEW terminal to refresh PATH if needed.
echo.

:END
pause
endlocal
