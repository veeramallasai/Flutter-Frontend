@REM ----------------------------------------------------------------------------
@REM Portable Maven Launcher for FarmToHome Backend
@REM ----------------------------------------------------------------------------
@echo off
setlocal enableextensions

@REM Auto-detect JAVA_HOME if not set or invalid
if not exist "%JAVA_HOME%\bin\java.exe" (
    if exist "C:\Program Files\Java\jdk-26.0.1\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.1"
    ) else (
        for /d %%I in ("C:\Program Files\Java\jdk*") do (
            if exist "%%I\bin\java.exe" set "JAVA_HOME=%%I"
        )
    )
)

@REM Auto-load .env environment variables if present
if exist "%~dp0..\.env" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0..\.env") do (
        if not "%%A"=="" (
            set "%%A=%%B"
        )
    )
)
if exist "%~dp0.env" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0.env") do (
        if not "%%A"=="" (
            set "%%A=%%B"
        )
    )
)

where mvn >nul 2>nul
if %ERRORLEVEL% == 0 (
    mvn %*
    exit /b %ERRORLEVEL%
)

set MAVEN_DIR=%~dp0.mvn\apache-maven-3.9.9
set MVN_CMD=%MAVEN_DIR%\bin\mvn.cmd

if exist "%MVN_CMD%" (
    call "%MVN_CMD%" %*
    exit /b %ERRORLEVEL%
)

echo Maven is not installed on this system. Downloading portable Maven 3.9.9...
if not exist "%~dp0.mvn" mkdir "%~dp0.mvn"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$zipPath = '%~dp0.mvn\maven.zip'; $extractPath = '%~dp0.mvn'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Host 'Downloading Maven...'; Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip' -OutFile $zipPath; Write-Host 'Extracting Maven...'; Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force; Remove-Item -Path $zipPath -Force; Write-Host 'Maven setup complete!'"

if exist "%MVN_CMD%" (
    call "%MVN_CMD%" %*
) else (
    echo Failed to download Maven. Please install Maven manually or run from IDE.
    exit /b 1
)
