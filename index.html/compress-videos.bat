@echo off
chcp 65001 >nul 2>&1
echo ============================================================
echo   饭堡堡 · 视频压缩脚本 (ffmpeg)
echo ============================================================
echo.
echo   本脚本将:
echo   · hero.mp4  → 720p / 2Mbps CRF23  → ~5-8 MB
echo   · about.mp4 → 720p / 1.5Mbps CRF25 → ~4-6 MB
echo.
echo   原文件将保留为 *.orig.mp4 (可手动删除)
echo.

:: 查找 ffmpeg(优先 PATH,其次常见位置)
set FFMPEG=
where ffmpeg >nul 2>&1
if %errorlevel% equ 0 set FFMPEG=ffmpeg

if not defined FFMPEG (
  if exist "C:\ffmpeg\bin\ffmpeg.exe" set FFMPEG=C:\ffmpeg\bin\ffmpeg.exe
)
if not defined FFMPEG (
  if exist "F:\ffmpeg\bin\ffmpeg.exe" set FFMPEG=F:\ffmpeg\bin\ffmpeg.exe
)
if not defined FFMPEG (
  if exist "C:\Program Files\ffmpeg\bin\ffmpeg.exe" set FFMPEG=C:\Program Files\ffmpeg\bin\ffmpeg.exe
)

if not defined FFMPEG (
  echo [错误] 未找到 ffmpeg!
  echo.
  echo 请先安装 ffmpeg:
  echo   1. 访问 https://ffmpeg.org/download.html
  echo   2. 下载 Windows builds (ffmpeg-master-latest-win64-gpl.zip)
  echo   3. 解压到 C:\ffmpeg (或任意位置)
  echo   4. 把 bin 目录加到系统 PATH,或者把 ffmpeg.exe 放到本脚本同目录
  echo.
  echo   也可用 winget 安装: winget install Gyan.FFmpeg
  pause
  exit /b 1
)

echo [找到] %FFMPEG%
echo.

:: 切换到 public 目录(双击运行时自动定位)
set SRC=%~dp0public
if exist "%SRC%\hero.mp4" (
  echo ============================================================
  echo   压缩 hero.mp4 ...
  echo ============================================================
  move "%SRC%\hero.mp4" "%SRC%\hero.orig.mp4" >nul 2>&1
  "%FFMPEG%" -i "%SRC%\hero.orig.mp4" ^
    -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" ^
    -c:v libx264 -preset fast -crf 23 ^
    -c:a aac -b:a 128k ^
    -movflags +faststart ^
    "%SRC%\hero.mp4"
  echo done!
  echo.
) else (
  echo [跳过] 未找到 %SRC%\hero.mp4
)

if exist "%SRC%\about.mp4" (
  echo ============================================================
  echo   压缩 about.mp4 ...
  echo ============================================================
  move "%SRC%\about.mp4" "%SRC%\about.orig.mp4" >nul 2>&1
  "%FFMPEG%" -i "%SRC%\about.orig.mp4" ^
    -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" ^
    -c:v libx264 -preset fast -crf 25 ^
    -c:a aac -b:a 96k ^
    -movflags +faststart ^
    "%SRC%\about.mp4"
  echo done!
  echo.
) else (
  echo [跳过] 未找到 %SRC%\about.mp4
)

echo ============================================================
echo   全部完成!
echo.
echo   压缩前后对比:
echo.
powershell -Command "Get-ChildItem '%SRC%\*.mp4' ^| ForEach-Object { Write-Host ('  {0,-25} {1,8:N1} MB' -f $_.Name, ($_.Length/1MB)) }"
echo.
echo   若满意,删掉 *.orig.mp4 备份:
echo   del "%SRC%\*.orig.mp4"
echo ============================================================
pause