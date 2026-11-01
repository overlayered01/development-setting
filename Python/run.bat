@echo off
chcp 65001 >nul
setlocal

set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"

cd /d "%~dp0"

set "PYTHON_EXE=python"
if exist "%~dp0.venv\Scripts\python.exe" (
  set "PYTHON_EXE=%~dp0.venv\Scripts\python.exe"
)

if "%~1"=="" (
  set "ARGS=--mode real"
) else (
  set "ARGS=%*"
)

echo [run] "%PYTHON_EXE%" main.py %ARGS%
"%PYTHON_EXE%" "%~dp0main.py" %ARGS%

if errorlevel 1 (
  echo.
  echo [run] 오류로 종료되었습니다. 위 로그를 확인하세요.
  pause
)

endlocal
