@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem === このbatの親 (= dotfiles 直下) を安全に取得 ===
for %%I in ("%~dp0..") do set "DOTS_DIR=%%~fI"

rem ---- MODE 初期化（引数優先 / フォールバックで choice）----
set "MODE=LINK"

rem 1) 引数で指定可: copy / copyback / link
if /I "%~1"=="copy"     set "MODE=COPY"
if /I "%~1"=="copyback" set "MODE=COPYBACK"
if /I "%~1"=="link"     set "MODE=LINK"

echo MODE=%MODE%
echo.

REM set "MAPFILE=%DOTS_DIR%\old\20_copy_dotfiles_map.txt"
set "FILES[0]=notepadpp\config.xml|%USERPROFILE%\scoop\apps\notepadplusplus\current\config.xml"
set "FILES[1]=notepadpp\contextMenu.xml|%USERPROFILE%\scoop\apps\notepadplusplus\current\contextMenu.xml"
set "FILES[2]=notepadpp\shortcuts.xml|%USERPROFILE%\scoop\apps\notepadplusplus\current\shortcuts.xml"
set "FILES[3]=notepadpp\stylers.xml|%USERPROFILE%\scoop\apps\notepadplusplus\current\stylers.xml"
set "FILES[4]=nvim|%USERPROFILE%\.config\nvim"
set "FILES[5]=starship.toml|%USERPROFILE%\.config\starship.toml"
set "FILES[6]=startup.bat|%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\startup.bat"
set "FILES[7]=settings.json|%USERPROFILE%\scoop\apps\windows-terminal\current\settings\settings.json"
set "MAX_IDX=7"

REM set "FILES[8]=.gitconfig|%USERPROFILE%\.config\git\config"
REM            @("Microsoft.PowerShell_profile.ps1",   "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
REM            @("profile.ps1",                        "$HOME\Documents\PowerShell\profile.ps1"),
REM            @("config",		               	        "$Home\.config\bat\config"),
REM            @(".vimrc",                             "$Home\.vimrc"),

REM === iterate list ===
for /L %%i in (0,1,%MAX_IDX%) do (
  for /F "tokens=1,2 delims=|" %%a in ("!FILES[%%i]!") do (
    call :PROCESS "%%~a" "%%~b"
  )
)

echo.
echo Finished. MODE=%MODE%
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

rem 正規化（末尾\除去）
if "%SRC:~-1%"=="\" set "SRC=%SRC:~0,-1%"
if "%DST:~-1%"=="\" set "DST=%DST:~0,-1%"

echo SRC="%SRC%"
echo DST="%DST%"

if not exist "%SRC%" (
  echo [SKIP] no source
  goto :EOF
)

for %%P in ("%DST%") do set "DSTDIR=%%~dpP"
if not exist "!DSTDIR!" mkdir "!DSTDIR!" >nul 2>&1

REM rem Startup は LINK を諦めて COPY
REM echo "%DST%" | findstr /I "\\Start Menu\\Programs\\Startup\\" >nul
REM if not errorlevel 1 (
REM   echo [WARN] Startup は COPY フォールバック
REM   if not exist "%DSTDIR%" mkdir "%DSTDIR%" >nul 2>&1
REM   copy /Y "%SRC%" "%DST%" >nul
REM   echo [LINK->COPY rc=%ERRORLEVEL%]
REM   goto :EOF
REM )

REM rem WT settings.json も COPY 推奨
REM echo "%DST%" | findstr /I "\\windows-terminal\\current\\settings\\settings.json" >nul
REM if not errorlevel 1 (
REM   echo [WARN] WT settings は COPY フォールバック
REM   if not exist "%DSTDIR%" mkdir "%DSTDIR%" >nul 2>&1
REM   copy /Y "%SRC%" "%DST%" >nul
REM   echo [LINK->COPY rc=%ERRORLEVEL%]
REM   goto :EOF
REM )

rem 既存除去（reparse対応）
if exist "%DST%" (
  rmdir "%DST%" 2>nul
  if exist "%DST%" (
    fsutil reparsepoint delete "%DST%" >nul 2>&1
  )
  if exist "%DST%" (
    rmdir /S /Q "%DST%" 2>nul
    del   /F /Q "%DST%" 2>nul
  )
)

rem ディレクトリ/ファイルで分岐（\*判定）
if exist "%SRC%\*" (
  rem ディレクトリは /J 優先 → ダメなら /D
  mklink /J "%DST%" "%SRC%" >nul || mklink /D "%DST%" "%SRC%" >nul
) else (
REM   rem ファイルは：symlink が失敗したら COPY（ハードリンクは使わない）
REM   mklink "%DST%" "%SRC%" >nul || (
REM     echo [INFO] symlink failed; fallback COPY
REM     for %%P in ("%DST%") do if not exist "%%~dpP" mkdir "%%~dpP" >nul 2>&1
REM     copy /Y "%SRC%" "%DST%" >nul
  )
)
echo .

if exist "%DST%" (
  echo [OK] "%DST%" -> "%SRC%"
) else (
  echo [ERR] failed create (policy/permission?)
)
goto :EOF

:END
pause
endlocal
