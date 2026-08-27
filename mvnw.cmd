@echo off
setlocal
set "PROJECT_ROOT=%~dp0"
if exist "%PROJECT_ROOT%backend\mvnw.cmd" (
    cd /d "%PROJECT_ROOT%backend"
    call mvnw.cmd %*
) else (
    echo Error: backend\mvnw.cmd not found.
    exit /b 1
)
