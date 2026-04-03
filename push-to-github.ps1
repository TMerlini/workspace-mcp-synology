# PowerShell script to push repository to GitHub
# Repository: https://github.com/TMerlini/Google-Workspace-MCP-Synology

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Push to GitHub Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Git is not installed!" -ForegroundColor Red
    Write-Host "`nPlease install Git first:" -ForegroundColor Yellow
    Write-Host "  Download from: https://git-scm.com/download/win`n" -ForegroundColor White
    Write-Host "After installing Git, run this script again.`n" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Repository configuration
$repoUrl = "https://github.com/TMerlini/Google-Workspace-MCP-Synology.git"
$branch = "main"

Write-Host "Repository: $repoUrl" -ForegroundColor White
Write-Host "Branch: $branch`n" -ForegroundColor White

# Check if already initialized
if (Test-Path ".git") {
    Write-Host "✓ Git repository already initialized" -ForegroundColor Green
} else {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Repository initialized`n" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to initialize repository`n" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Check if remote exists
$remotes = git remote
if ($remotes -contains "origin") {
    Write-Host "✓ Remote 'origin' already configured" -ForegroundColor Green
    $currentRemote = git remote get-url origin
    Write-Host "  Current URL: $currentRemote" -ForegroundColor Gray
    
    if ($currentRemote -ne $repoUrl) {
        Write-Host "`nWarning: Remote URL doesn't match!" -ForegroundColor Yellow
        Write-Host "  Expected: $repoUrl" -ForegroundColor White
        Write-Host "  Current:  $currentRemote" -ForegroundColor White
        $updateRemote = Read-Host "`nUpdate remote URL? (y/n)"
        if ($updateRemote -eq "y") {
            git remote set-url origin $repoUrl
            Write-Host "✓ Remote URL updated`n" -ForegroundColor Green
        }
    }
} else {
    Write-Host "Adding remote 'origin'..." -ForegroundColor Yellow
    git remote add origin $repoUrl
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Remote added`n" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to add remote`n" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Check for changes
Write-Host "Checking for changes..." -ForegroundColor Yellow
$status = git status --porcelain
if ($status) {
    Write-Host "✓ Changes detected`n" -ForegroundColor Green
    
    # Show summary of changes
    $newFiles = ($status | Where-Object { $_ -match "^\?\?" }).Count
    $modified = ($status | Where-Object { $_ -match "^ M" }).Count
    $staged = ($status | Where-Object { $_ -match "^M " }).Count
    
    Write-Host "Summary:" -ForegroundColor White
    if ($newFiles -gt 0) { Write-Host "  New files: $newFiles" -ForegroundColor Cyan }
    if ($modified -gt 0) { Write-Host "  Modified: $modified" -ForegroundColor Cyan }
    if ($staged -gt 0) { Write-Host "  Staged: $staged" -ForegroundColor Cyan }
    Write-Host ""
    
    # Add all files
    Write-Host "Adding all files..." -ForegroundColor Yellow
    git add .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Files added`n" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to add files`n" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Commit
    $commitMessage = Read-Host "Enter commit message (or press Enter for default)"
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "Initial commit: Coolify-ready Google Workspace MCP"
    }
    
    Write-Host "`nCommitting changes..." -ForegroundColor Yellow
    git commit -m $commitMessage
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Changes committed`n" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to commit changes`n" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "No changes to commit" -ForegroundColor Yellow
    $continue = Read-Host "`nPush anyway? (y/n)"
    if ($continue -ne "y") {
        Write-Host "`nAborted.`n" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 0
    }
}

# Check current branch
$currentBranch = git branch --show-current
if ([string]::IsNullOrWhiteSpace($currentBranch)) {
    Write-Host "Setting branch to '$branch'..." -ForegroundColor Yellow
    git branch -M $branch
    Write-Host "✓ Branch set to '$branch'`n" -ForegroundColor Green
} elseif ($currentBranch -ne $branch) {
    Write-Host "Current branch: $currentBranch" -ForegroundColor Yellow
    Write-Host "Target branch: $branch" -ForegroundColor Yellow
    $switchBranch = Read-Host "`nSwitch to '$branch'? (y/n)"
    if ($switchBranch -eq "y") {
        git branch -M $branch
        Write-Host "✓ Switched to '$branch'`n" -ForegroundColor Green
    }
}

# Push to GitHub
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Pushing to GitHub..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Note: You'll need to authenticate with GitHub" -ForegroundColor Yellow
Write-Host "  Username: Your GitHub username" -ForegroundColor White
Write-Host "  Password: Use a Personal Access Token" -ForegroundColor White
Write-Host "  (Create token at: https://github.com/settings/tokens)`n" -ForegroundColor Gray

git push -u origin $branch

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  ✓ Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    Write-Host "Your repository is now available at:" -ForegroundColor White
    Write-Host "  https://github.com/TMerlini/Google-Workspace-MCP-Synology`n" -ForegroundColor Cyan
    
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Visit your repository on GitHub" -ForegroundColor White
    Write-Host "  2. Verify all files are there" -ForegroundColor White
    Write-Host "  3. Deploy to Coolify using the GitHub URL`n" -ForegroundColor White
} else {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "  ✗ Failed to push to GitHub" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  • Authentication failed: Use Personal Access Token" -ForegroundColor White
    Write-Host "  • Repository not found: Check the URL" -ForegroundColor White
    Write-Host "  • Permission denied: Check token permissions`n" -ForegroundColor White
    
    Write-Host "For help, see: PUSH_TO_GITHUB.md`n" -ForegroundColor Cyan
}

Read-Host "Press Enter to exit"
