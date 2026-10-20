@echo off
rem 対話の設定作成。ダブルクリックでも結果が見えるよう、最後に pause する（終了コードは保つ）。
pwsh -NoProfile -File "%~dp0claude-gateway-setup.ps1" %*
set RC=%ERRORLEVEL%
pause
exit /b %RC%
