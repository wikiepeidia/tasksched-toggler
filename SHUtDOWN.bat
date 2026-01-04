@echo off
setlocal EnableDelayedExpansion

:: ==== Admin check ====
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Please run this script as Administrator.
    pause
    exit /b
)

set TASKNAME=SHUTDOWN

:: ==== Get task status ====
for /f "tokens=2 delims=:" %%A in ('schtasks /query /tn "%TASKNAME%" /fo LIST ^| findstr /i "Status"') do (
    set STATUS=%%A
)

set STATUS=!STATUS: =!

if not defined STATUS (
    echo Task "%TASKNAME%" not found.
    pause
    exit /b
)

echo Task "%TASKNAME%" is currently: %STATUS%
echo.
echo Press ANY key within 5 seconds to cancel...

:: ==== Wait 5 seconds, cancel if key pressed ====
choice /c Y /n /t 5 /d Y >nul
if errorlevel 2 (
    echo Cancelled.
    timeout /t 2 >nul
    exit /b
)

:: ==== Toggle logic ====
if /i "%STATUS%"=="Disabled" (
    echo Enabling task...
    schtasks /change /tn "%TASKNAME%" /enable
) else (
    echo Disabling task...
    schtasks /change /tn "%TASKNAME%" /disable
)

echo Done.
timeout /t 2 >nul
exit /b
