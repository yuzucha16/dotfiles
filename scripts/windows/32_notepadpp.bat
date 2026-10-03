@echo off
setlocal EnableExtensions

REM ======================================================
REM  Notepad++ config.xml: apply the settings we care about (idempotent)
REM  Usage:  32_notepadpp.bat [-n]
REM    -n: dry run (print the changes only)
REM  Run after 20_apps.bat (installs Notepad++) and 30_link.bat (themes).
REM  Close Notepad++ first: it overwrites config.xml on exit.
REM ======================================================

set "PSARGS="
if /I "%~1"=="-n" set "PSARGS=-DryRun"
if not "%~1"=="" if not defined PSARGS (
  echo Usage: %~nx0 [-n]
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp032_notepadpp.ps1" %PSARGS%
exit /b %errorlevel%
