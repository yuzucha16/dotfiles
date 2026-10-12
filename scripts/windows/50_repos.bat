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

rem Zed dev extension (VBA highlighting). Not on the extension registry, so it is cloned here and installed by hand.
ghq get tmepple/zed-vba
for /F "delims=" %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"
for /F "delims=" %%P in ('ghq list -p tmepple/zed-vba') do set "ZED_VBA=%%P"
rem Orange (ANSI 256-color 208) because it is easy to miss. ESC is captured with prompt $E (ASCII-only source).
echo %ESC%[38;5;208m[MANUAL] Zed: run "zed: install dev extension" and select: !ZED_VBA!%ESC%[0m

:END
pause
endlocal
