@echo off
setlocal

rem --- 優先度: 1) PowerShell Core (pwsh)  2) Windows PowerShell ---

rem Core の存在をチェック
where pwsh >nul 2>nul
if %errorlevel%==0 (
    set "PS=pwsh"
) else (
    set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
)

rem 実行（ExecutionPolicy Bypass）
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp00a_setup_skeleton.ps1"

