@echo off
setlocal

set "SCRIPT=%~dp0BatteryHealthQuickCheck.ps1"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -OpenReport
if errorlevel 1 (
  exit /b 1
)

endlocal
