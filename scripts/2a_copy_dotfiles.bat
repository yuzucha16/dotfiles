@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem === このbatの親 (= dotfiles 直下) を安全に取得 ===
for %%I in ("%~dp0..") do set "DOTS_DIR=%%~fI"

set "MAPFILE=%DOTS_DIR%\scripts\20_copy_dotfiles_map.txt"

rem ---- モード選択 ----
echo Select mode:
echo   A) COPY , B) COPYBACK , C) LINK
choice /C ABC /N /M "Mode? "
set "ANS=%ERRORLEVEL%"
if "%ANS%"=="1" set "MODE=COPY"
if "%ANS%"=="2" set "MODE=COPYBACK"
if "%ANS%"=="3" set "MODE=LINK"

rem ---- MAPFILE 読み込み ----
for /F "usebackq eol=# tokens=1,2 delims=|" %%A in ("%MAPFILE%") do call :PROCESS "%%~A" "%%~B"
goto :END


:PROCESS
set "REL=%~1"
set "DST=%~2"
if not defined REL goto :EOF
if not defined DST goto :EOF
call set "DST=%DST%"

set "SRC=%DOTS_DIR%\%REL%"

if "%MODE%"=="COPY"     call :COPY "%SRC%" "%DST%"
if "%MODE%"=="COPYBACK" call :COPY "%DST%" "%SRC%"
if "%MODE%"=="LINK"     call :LINK "%SRC%" "%DST%"
goto :EOF


:COPY
rem 汎用コピー（ファイル/ディレクトリ両対応）
set "SRC=%~1"
set "DST=%~2"
if exist "%SRC%\NUL" (
  robocopy "%SRC%" "%DST%" /E /COPY:DAT /R:1 /W:1 /NFL /NDL /NP /NJH /NJS >nul
) else (
  for %%P in ("%DST%") do set "DSTDIR=%%~dpP"
  if not exist "!DSTDIR!" mkdir "!DSTDIR!"
  copy /Y "%SRC%" "%DST%" >nul
)
goto :EOF


:LINK
set "SRC=%~1"
set "DST=%~2"
if not exist "%SRC%" (
  echo Skip: no source "%SRC%"
  goto :EOF
)
if exist "%DST%" (
  echo Skip: already exists "%DST%"
  goto :EOF
)
mklink /D "%DST%" "%SRC%"
goto :EOF


:END
pause
endlocal
