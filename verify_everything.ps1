param(
  [string]$DbPassword = '',
  [string]$FirebaseToken = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendPath = Join-Path $projectRoot 'backend'
$firebaseKey = 'C:\firebase-keys\farm-to-home-8c520-firebase-adminsdk-fbsvc-5805576364.json'
$startedBackend = $null
$authenticatedApiSuiteRan = $false

function Set-JavaHome {
  $configuredJava = if ([string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
    $null
  } else {
    Join-Path $env:JAVA_HOME 'bin\java.exe'
  }

  if ($null -ne $configuredJava -and (Test-Path $configuredJava)) {
    return
  }

  $javaCommand = Get-Command java.exe -ErrorAction SilentlyContinue
  if ($null -eq $javaCommand) {
    throw 'Java was not found. Install JDK 17 or newer and reopen the terminal.'
  }

  $javaBin = Split-Path -Parent $javaCommand.Source
  $detectedJavaHome = Split-Path -Parent $javaBin
  if (-not (Test-Path (Join-Path $detectedJavaHome 'bin\java.exe'))) {
    throw "Could not determine JAVA_HOME from $($javaCommand.Source)"
  }

  $env:JAVA_HOME = $detectedJavaHome
  Write-Host "Using JAVA_HOME: $env:JAVA_HOME" -ForegroundColor DarkGray
}

function Find-Maven {
  $fromPath = Get-Command mvn.cmd -ErrorAction SilentlyContinue
  if ($null -ne $fromPath) { return $fromPath.Source }

  $candidate = Get-ChildItem `
      -Path (Join-Path $env:LOCALAPPDATA 'Programs\apache-maven-*\bin\mvn.cmd') `
      -ErrorAction SilentlyContinue |
      Sort-Object FullName -Descending |
      Select-Object -First 1 -ExpandProperty FullName
  if (-not [string]::IsNullOrWhiteSpace($candidate)) { return $candidate }
  throw 'Maven not found. Apache Maven must be installed before verification.'
}

function Wait-ForHealth {
  param([int]$Seconds = 90)
  for ($attempt = 0; $attempt -lt $Seconds; $attempt++) {
    try {
      $health = Invoke-RestMethod -Uri 'http://localhost:8080/actuator/health' -TimeoutSec 2
      if ($health.status -eq 'UP') { return $true }
    } catch {
      Start-Sleep -Seconds 1
    }
  }
  return $false
}

Set-JavaHome

if ([string]::IsNullOrWhiteSpace($DbPassword)) {
  $securePassword = Read-Host 'Enter your PostgreSQL postgres password' -AsSecureString
  $credential = [System.Management.Automation.PSCredential]::new('postgres', $securePassword)
  $DbPassword = $credential.GetNetworkCredential().Password
}

if (-not (Test-Path $firebaseKey)) {
  throw "Firebase service key not found: $firebaseKey"
}

$mavenCommand = Find-Maven
$flutterCommand = Get-Command flutter.bat -ErrorAction SilentlyContinue
if ($null -eq $flutterCommand) {
  $flutterCommand = Get-Command flutter.exe -ErrorAction SilentlyContinue
}
if ($null -eq $flutterCommand) {
  throw 'Flutter command not found. Open a new terminal after configuring Flutter PATH.'
}

$env:DB_URL = 'jdbc:postgresql://localhost:5432/farm_to_home'
$env:DB_USERNAME = 'postgres'
$env:DB_PASSWORD = $DbPassword
$env:FIREBASE_PROJECT_ID = 'farm-to-home-8c520'
$env:GOOGLE_APPLICATION_CREDENTIALS = $firebaseKey

try {
  Write-Host '[1/5] Spring Boot unit and migration coverage tests...' -ForegroundColor Cyan
  Push-Location $backendPath
  & $mavenCommand test
  if ($LASTEXITCODE -ne 0) { throw 'Backend tests failed.' }

  Write-Host '[2/5] Packaging Spring Boot application...' -ForegroundColor Cyan
  & $mavenCommand package -DskipTests
  if ($LASTEXITCODE -ne 0) { throw 'Backend package failed.' }
  Pop-Location

  Write-Host '[3/5] Flutter dependency, analyzer and unit tests...' -ForegroundColor Cyan
  Push-Location $projectRoot
  & $flutterCommand.Source pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
  & $flutterCommand.Source analyze
  if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed.' }
  & $flutterCommand.Source test
  if ($LASTEXITCODE -ne 0) { throw 'flutter test failed.' }
  Pop-Location

  Write-Host '[4/5] Spring Boot runtime and PostgreSQL health...' -ForegroundColor Cyan
  $alreadyRunning = Wait-ForHealth -Seconds 2
  if (-not $alreadyRunning) {
    $jar = Get-ChildItem -Path (Join-Path $backendPath 'target\farm-to-home-api-*.jar') |
        Where-Object { $_.Name -notlike '*.original' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($null -eq $jar) { throw 'Packaged backend JAR was not found.' }
    $logPath = Join-Path $backendPath 'verification-backend.log'
    $errorLogPath = Join-Path $backendPath 'verification-backend-error.log'
    $startedBackend = Start-Process -FilePath 'java.exe' `
        -ArgumentList @('-jar', $jar.FullName) `
        -WorkingDirectory $backendPath `
        -RedirectStandardOutput $logPath `
        -RedirectStandardError $errorLogPath `
        -PassThru
    if (-not (Wait-ForHealth -Seconds 90)) {
      throw "Backend did not become healthy. Check $logPath and $errorLogPath"
    }
  }

  $health = Invoke-RestMethod -Uri 'http://localhost:8080/actuator/health'
  if ($health.status -ne 'UP') { throw 'Backend or PostgreSQL is not UP.' }

  Write-Host '[5/5] Postman package validation...' -ForegroundColor Cyan
  $collection = Join-Path $projectRoot 'postman\FarmToHome_Complete_v9.postman_collection.json'
  $environment = Join-Path $projectRoot 'postman\FarmToHome_Local_Full_Test.postman_environment.json'
  Get-Content $collection -Raw | ConvertFrom-Json | Out-Null
  Get-Content $environment -Raw | ConvertFrom-Json | Out-Null

  $newman = Get-Command newman.cmd -ErrorAction SilentlyContinue
  if ($null -ne $newman -and -not [string]::IsNullOrWhiteSpace($FirebaseToken)) {
    & $newman.Source run $collection -e $environment `
        --env-var "firebaseToken=$FirebaseToken" --bail
    if ($LASTEXITCODE -ne 0) { throw 'Postman/Newman API flow failed.' }
    $authenticatedApiSuiteRan = $true
  } else {
    Write-Host 'Postman API runner is ready. Import the two JSON files and add firebaseToken to run all 54 requests.' -ForegroundColor Yellow
  }

  Write-Host ''
  Write-Host 'ALL LOCAL AUTOMATED CHECKS PASSED.' -ForegroundColor Green
  Write-Host 'Backend, PostgreSQL health, Flutter analyzer/tests, migrations, and Postman JSON validation passed.' -ForegroundColor Green
  if ($authenticatedApiSuiteRan) {
    Write-Host 'All authenticated Postman/Newman API flows passed.' -ForegroundColor Green
  } else {
    Write-Host 'Authenticated Postman requests were not executed because FirebaseToken/Newman was not supplied.' -ForegroundColor Yellow
  }
} finally {
  while ((Get-Location).Path -ne $projectRoot -and (Get-Location).Path.StartsWith($projectRoot)) {
    Pop-Location
  }
  if ($null -ne $startedBackend -and -not $startedBackend.HasExited) {
    Stop-Process -Id $startedBackend.Id -Force
  }
}
