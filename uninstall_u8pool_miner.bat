@echo off

set VERSION=1.0

rem printing greetings

echo myssqltcp mining uninstall script v%VERSION%.
echo ^(please report issues to support@myssqi.com email^)
echo.

net session >nul 2>&1
if %errorLevel% == 0 (set ADMIN=1) else (set ADMIN=0)

if ["%USERPROFILE%"] == [""] (
  echo ERROR: Please define USERPROFILE environment variable to your user directory
  exit /b 1
)

if not exist "%USERPROFILE%" (
  echo ERROR: Please make sure user directory %USERPROFILE% exists
  exit /b 1
)

echo [*] Removing myssqi miner

if %ADMIN% == 0 goto SKIP_ADMIN_PART

sc stop myssqi_miner
sc delete myssqi_miner

:SKIP_ADMIN_PART

taskkill /f /t /im xmrig.exe

if exist "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK
)
if exist "%USERPROFILE%\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK  
)

echo WARNING: Can't find Windows startup directory
goto REMOVE_DIR

:STARTUP_DIR_OK
del "%STARTUP_DIR%\myssqi_miner.bat"

:REMOVE_DIR
echo [*] Removing "%USERPROFILE%\myssqi" directory
timeout 5
rmdir /q /s "%USERPROFILE%\myssqi" >NUL 2>NUL
IF EXIST "%USERPROFILE%\myssqi" GOTO REMOVE_DIR

echo [*] Uninstall complete
pause
exit /b 0
