@echo off
setlocal EnableExtensions

set "SCRIPT=%~dp0BatteryHealthQuickCheck.ps1"
set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%SCRIPT%" (
  echo [ERROR] Script file not found:
  echo %SCRIPT%
  echo.
  pause
  exit /b 1
)

if not exist "%PS_EXE%" (
  echo [ERROR] Windows PowerShell was not found:
  echo %PS_EXE%
  echo.
  pause
  exit /b 1
)

"%PS_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Sta -File "%SCRIPT%" -OpenReport
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo [ERROR] Execution failed. See the error message above.
  echo Press any key to close this window...
  pause > nul
  exit /b %EXIT_CODE%
)

endlocal
