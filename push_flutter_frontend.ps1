# PowerShell helper script to commit and push Flutter Frontend repository
param(
    [string]$RemoteUrl = "https://github.com/veeramallasai/Flutter-Frontend.git",
    [string]$CommitMessage = "feat: update Flutter frontend base URL for Railway and enhance backend CORS"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Flutter Frontend Repository Push Helper " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Update Git Remote if provided
if ($RemoteUrl -ne "") {
    Write-Host "[1/4] Updating git remote origin to: $RemoteUrl" -ForegroundColor Yellow
    git remote set-url origin $RemoteUrl
} else {
    $currentRemote = git remote get-url origin 2>$null
    Write-Host "[1/4] Current remote origin: $currentRemote" -ForegroundColor Green
}

# 2. Stage files
Write-Host "[2/4] Staging files..." -ForegroundColor Yellow
git add .

# 3. Commit changes
Write-Host "[3/4] Committing changes..." -ForegroundColor Yellow
git commit -m $CommitMessage

# 4. Push to origin main
Write-Host "[4/4] Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin main

Write-Host "`nSuccessfully completed migration push!" -ForegroundColor Green
