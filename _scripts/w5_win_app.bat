@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM C++ ビルドツール（MSVC）＋ 推奨構成 をサイレントで
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --source winget --override "--quiet --wait --norestart --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools"

:END
pause
endlocal
