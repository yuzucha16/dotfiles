@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem dev settings (dotfiles itself is already cloned by hand, straight into the ghq path, before 10_env; see README)
rem ghq get yuzucha16/adv360-pro-zmk

rem workbase (shared knowledge repo) is cloned straight into the vault, outside ghq:
rem a ghq path would need a junction, and Grep/Glob/rg do not follow junctions.
if not defined WORKS_DIR (
  echo [ERR] WORKS_DIR is not set. Run 10_env.bat and open a new terminal.
  goto :END
)
if exist "%WORKS_DIR%\resources\.git" (
  echo [SKIP] already cloned: %WORKS_DIR%\resources
) else (
  git clone https://github.com/yuzucha16/workbase "%WORKS_DIR%\resources"
)

:END
pause
endlocal
