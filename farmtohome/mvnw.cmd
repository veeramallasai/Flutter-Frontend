@echo off
setlocal
set "DIR=%~dp0"
:search
if exist "%DIR%backend\mvnw.cmd" (
    cd /d "%DIR%backend"
    call mvnw.cmd %*
    exit /b %ERRORLEVEL%
)
if exist "%DIR%mvnw.cmd" if not "%DIR%"=="%~dp0" (
    call "%DIR%mvnw.cmd" %*
    exit /b %ERRORLEVEL%
)
for %%I in ("%DIR%..") do set "PARENT=%%~fI"
if "%PARENT%"=="%DIR%" (
    echo Error: Could not locate project root with backend\mvnw.cmd
    exit /b 1
)
set "DIR=%PARENT%\"
goto search
