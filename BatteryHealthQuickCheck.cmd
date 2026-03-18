@echo off
setlocal

set "SCRIPT=%~dp0BatteryHealthQuickCheck.ps1"

if not exist "%SCRIPT%" (
  echo [오류] 스크립트 파일을 찾지 못했습니다.
  echo 경로: "%SCRIPT%"
  echo.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Sta -File "%SCRIPT%" -OpenReport
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo [오류] 실행 중 문제가 발생했습니다. 위 오류 내용을 확인하세요.
  echo 아무 키나 누르면 창이 닫힙니다.
  pause > nul
  exit /b %EXIT_CODE%
)

endlocal
