@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem dev settings (dotfiles itself is already cloned by hand)
rem ghq get yuzucha16/adv360-pro-zmk

rem workbase (shared knowledge repo) is cloned straight into the vault, outside ghq:
rem a ghq path would need a junction, and Grep/Glob/rg do not follow junctions.
if not defined NOTES_DIR (
  echo [ERR] NOTES_DIR is not set. Run 10_env.bat and open a new terminal.
  goto :END
)
if exist "%NOTES_DIR%\resources\.git" (
  echo [SKIP] already cloned: %NOTES_DIR%\resources
) else (
  git clone https://github.com/yuzucha16/workbase "%NOTES_DIR%\resources"
)

:END
pause
endlocal
