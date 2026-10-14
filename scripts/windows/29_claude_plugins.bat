@echo off
setlocal EnableExtensions

REM ======================================================
REM  Claude Code plugins: for each line "<source>|<plugin>@<marketplace>" of
REM  manifests\claude-plugins.txt run
REM    claude plugin marketplace add <source>
REM    claude plugin install <plugin>@<marketplace>
REM  Needs Claude Code (23_claude.bat). No question is asked.
REM  Continues after a failure and returns 1 at the end if any entry failed.
REM  Usage:  29_claude_plugins.bat
REM ======================================================

set "LIST=%~dp0..\..\manifests\claude-plugins.txt"
set "RC=0"

if exist "%USERPROFILE%\.local\bin\claude.exe" set "PATH=%USERPROFILE%\.local\bin;%PATH%"
where claude >nul 2>&1
if errorlevel 1 (
  echo [ERR] claude not found on PATH. Run 23_claude.bat first, then open a new terminal.
  set "RC=1"
  goto :END
)
if not exist "%LIST%" (
  echo [ERR] %LIST% not found.
  set "RC=1"
  goto :END
)

for /f "usebackq eol=# tokens=1,2 delims=|" %%S in ("%LIST%") do (
  echo [RUN] claude plugin marketplace add %%S
  call claude plugin marketplace add %%S
  if errorlevel 1 (
    echo [ERR] marketplace add %%S failed.
    set "RC=1"
  ) else (
    echo [RUN] claude plugin install %%T
    call claude plugin install %%T
    if errorlevel 1 (
      echo [ERR] plugin install %%T failed.
      set "RC=1"
    ) else (
      echo [OK] %%T
    )
  )
)

:END
pause
endlocal & exit /b %RC%
