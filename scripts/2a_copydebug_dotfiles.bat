@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

REM ===== 設定 =====
for %%I in ("%~dp0..") do set "DOTS_DIR=%%~fI"
set "MAPFILE=%~dp020_copy_dotfiles_map.txt"

if not exist "%MAPFILE%" (
  echo Mapping file not found: "%MAPFILE%"
  goto :END
)

REM ===== メインループ =====
for /F "usebackq eol=# tokens=1,2 delims=|" %%A in ("%MAPFILE%") do call :PROCESS "%%~A" "%%~B"
goto :END


:PROCESS
set "REL=%~1"
set "DST_RAW=%~2"
if "%REL%"=="" exit /b
if "%DST_RAW%"=="" exit /b

set "DST=%DST_RAW%"
call set "DST=%%DST%%"

set "SRC=%REL%"
if not "%SRC:~1,1%"==":" if not "%SRC:~0,1%"=="\" if not "%SRC:~0,2%"=="\\" (
  set "SRC=%DOTS_DIR%\%SRC%"
)

if not exist "%SRC%" exit /b

if exist "%SRC%\" (
  call :COPY_DIR "%SRC%" "%DST%"
) else (
  call :COPY_FILE "%SRC%" "%DST%"
)
exit /b


:COPY_DIR
rmdir /S /Q "%~2" 2>nul
mkdir "%~2" 2>nul
xcopy "%~1" "%~2" /E /I /Q /Y >nul
if errorlevel 1 echo Failed: %~1
exit /b


:COPY_FILE
for %%P in ("%~2") do set "DST_PARENT=%%~dpP"
if not exist "!DST_PARENT!" mkdir "!DST_PARENT!" >nul 2>&1
copy /Y "%~1" "%~2" >nul
if errorlevel 1 echo Failed: %~1
exit /b


:END
endlocal
pause

