@echo off
:: launch.bat
:: Ejecuta src\setup.ps1 como Administrador obligatoriamente

:: Comprobar si se ejecuta como Administrador
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Este script debe ejecutarse como Administrador.
    echo Haga clic derecho sobre el archivo y seleccione "Ejecutar como Administrador".
    pause
    exit /b 1
)

:: Ejecutar setup.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0src\setup.ps1"
pause
