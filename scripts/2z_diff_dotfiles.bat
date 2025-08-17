@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1

rem === 設定 ===
rem 第1引数：マップファイル（省略時は scripts\2_copy_dotfiles_map.txt）
set "SCRIPT_DIR=%~dp0"
set "DEFAULT_MAP=%SCRIPT_DIR%2_copy_dotfiles_map.txt"
if "%~1"=="" (
  set "MAPFILE=%DEFAULT_MAP%"
) else (
  set "MAPFILE=%~1"
)

rem /nopause 指定で最後の pause を無効化
set "NO_PAUSE="
if /I "%~2"=="/nopause" set "NO_PAUSE=1"
if /I "%~1"=="/nopause" ( set "NO_PAUSE=1" & set "MAPFILE=%DEFAULT_MAP%" )

rem DOTS_DIR = このbatの親フォルダの親（= dotfiles 直下想定: ...\dotfiles\scripts\ -> ...\dotfiles）
for %%I in ("%SCRIPT_DIR%..") do set "DOTS_DIR=%%~fI"

if not exist "%MAPFILE%" (
  echo Failed: Mapping file not found - "%MAPFILE%"
  goto :__END
)

rem 結果カウンタ
set /a CNT_MOD=0, CNT_ADD=0, CNT_DEL=0

rem === メイン：map を1行ずつ処理（# や空行はスキップ） ===
for /f "usebackq eol=# tokens=1,2 delims=|" %%A in ("%MAPFILE%") do call :PROCESS_ONE "%%~A" "%%~B"
goto :SUMMARY


:PROCESS_ONE
rem 引数: %1=src( DOTS_DIRからの相対 or ディレクトリ/ファイル名 ) / %2=dst( 絶対; 環境変数可 )
set "REL=%~1"
set "DST=%~2"

rem トリム（両端のダブルクォートを既に外してある想定）
if "!REL!"=="" goto :EOF
if "!DST!"=="" goto :EOF

rem 環境変数展開（%USERPROFILE% など）
call set "DST=%DST%"

rem 絶対パス化（SRC）
set "SRC=%DOTS_DIR%\%REL%"

rem 分岐：ディレクトリ or ファイル
if exist "%SRC%\NUL" (
  rem ディレクトリ比較：中身のファイル単位で比較
  call :DIFF_DIR "%SRC%" "%DST%"
) else (
  rem ファイル比較
  call :DIFF_FILE "%SRC%" "%DST%"
)
goto :EOF


:DIFF_FILE
rem 引数: %1=SRC(絶対ファイル), %2=DST(絶対ファイル)
set "LF=%~1"
set "RF=%~2"

if not exist "%LF%" (
  rem コピー元が無い → 先にDが消えているかも？判定上は「削除（DEL）」とみなす
  if exist "%RF%" (
    echo DIFF ^| DEL ^| "%RF%"
    set /a CNT_DEL+=1
  ) else (
    rem 両方無い場合は出力しない
  )
  goto :EOF
)

if not exist "%RF%" (
  rem 先が無い → 新規追加すべき
  echo DIFF ^| ADD ^| "%RF%"
  set /a CNT_ADD+=1
  goto :EOF
)

rem 両方ある → ハッシュ比較
call :HASH "%LF%"
set "LHASH=!HASH_OUT!"
call :HASH "%RF%"
set "RHASH=!HASH_OUT!"

if /I not "!LHASH!"=="!RHASH!" (
  echo DIFF ^| MOD ^| "%RF%"
  set /a CNT_MOD+=1
)
goto :EOF


:DIFF_DIR
rem 引数: %1=SRC_DIR(絶対), %2=DST_DIR(絶対)
set "SD=%~1"
set "DD=%~2"

rem どちらかが存在しない場合でも、相対ファイル列挙のために変数を持つ
set "HAVE_SD=0"
set "HAVE_DD=0"
if exist "%SD%\NUL" set "HAVE_SD=1"
if exist "%DD%\NUL" set "HAVE_DD=1"

rem 一時ファイル
set "TMP_BASE=%TEMP%\diff_%RANDOM%_%TIME: =0%"
set "LIST_S=%TMP_BASE%_src.txt"
set "LIST_D=%TMP_BASE%_dst.txt"
set "LIST_M=%TMP_BASE%_merged.txt"

rem ソース側：相対ファイル一覧
if "%HAVE_SD%"=="1" (
  >"%LIST_S%" (
    for /r "%SD%" %%F in (*) do (
      set "P=%%~fF"
      set "REL=!P:%SD%\=!"
      echo !REL!
    )
  )
) else (
  type nul > "%LIST_S%"
)

rem 宛先側：相対ファイル一覧
if "%HAVE_DD%"=="1" (
  >"%LIST_D%" (
    for /r "%DD%" %%F in (*) do (
      set "P=%%~fF"
      set "REL=!P:%DD%\=!"
      echo !REL!
    )
  )
) else (
  type nul > "%LIST_D%"
)

rem マージ（和集合）して重複除去
type "%LIST_S%" "%LIST_D%" > "%LIST_M%.raw"
for /f "usebackq delims=" %%R in (`type "%LIST_M%.raw" ^| sort`) do (
  if /I not "%%~R"=="!__LAST__!" (
    set "__LAST__=%%~R"
    call :DIFF_DIR_ONE "%SD%" "%DD%" "%%~R"
  )
)

rem 後始末
del /q "%LIST_S%" "%LIST_D%" "%LIST_M%.raw" 2>nul
set "__LAST__="
goto :EOF


:DIFF_DIR_ONE
rem 引数: %1=SRC_DIR, %2=DST_DIR, %3=REL_FILE
set "SD=%~1"
set "DD=%~2"
set "REL=%~3"

set "SF=%SD%\%REL%"
set "DF=%DD%\%REL%"

rem 片方だけ存在 → ADD / DEL
if exist "%SF%" (
  if exist "%DF%" (
    rem 両方あれば中身比較
    call :DIFF_FILE "%SF%" "%DF%"
  ) else (
    echo DIFF ^| ADD ^| "%DF%"
    set /a CNT_ADD+=1
  )
) else (
  if exist "%DF%" (
    echo DIFF ^| DEL ^| "%DF%"
    set /a CNT_DEL+=1
  ) else (
    rem どちらも無い（理論上ここには来ない）
  )
)
goto :EOF


:HASH
rem 引数: %1=ファイル
set "HASH_OUT="
for /f "tokens=1 delims= " %%H in ('
  certutil -hashfile "%~1" SHA256 ^| findstr /R /I "^[0-9A-F][0-9A-F]"
') do (
  set "HASH_OUT=%%H"
  goto :HASH_DONE
)
:HASH_DONE
goto :EOF


:SUMMARY
if %CNT_MOD% EQU 0 if %CNT_ADD% EQU 0 if %CNT_DEL% EQU 0 (
  echo OK: No differences.
  goto :__END
)
echo ---
echo Summary: MOD=%CNT_MOD% ADD=%CNT_ADD% DEL=%CNT_DEL%

:__END
if not defined NO_PAUSE pause
endlocal
exit /b
