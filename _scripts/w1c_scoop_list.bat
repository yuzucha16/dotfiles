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
doxygen ^
plantuml ^
graphviz ^
vscode ^
neovim ^
goneovim ^
llvm ^
winmerge ^
qownnotes ^
marp ^
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

REM Scoop が無ければ終了 (Bypass)
if not exist "%SCOOP_SHIMS%\scoop.cmd" (
  echo Scoop not found. Finished..
  goto :END
)

REM ▼最終確認
where scoop.cmd >nul 2>&1
if errorlevel 1 (
  echo [ERROR] scoop.cmd not found on PATH. Please check install.
  goto :END
)

REM ▼リスト化
echo Listing ...
call scoop.cmd list

echo.
echo Done.
echo.

:END
pause
endlocal
