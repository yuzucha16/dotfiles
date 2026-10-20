@echo off
rem apiKeyHelper として呼ばれるときは、標準出力にトークンだけを返す（pause や余計な出力を入れない。入れると Claude Code のヘルパーが失敗する）。
rem 対話の -Login のときだけ、ダブルクリックでも結果が見えるよう pause する（終了コードは保つ）。
pwsh -NoProfile -File "%~dp0claude-gateway-token.ps1" %*
set RC=%ERRORLEVEL%
if /i "%~1"=="-Login" pause
exit /b %RC%
