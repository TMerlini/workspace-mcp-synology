# Push to GitHub Guide

## Your Repository
**GitHub URL:** https://github.com/TMerlini/Google-Workspace-MCP-Synology

## Option 1: Install Git and Push (Recommended)

### Step 1: Install Git for Windows

1. Download Git from: https://git-scm.com/download/win
2. Run the installer (use default settings)
3. Restart your terminal/PowerShell

### Step 2: Configure Git (First Time Only)

Open PowerShell and run:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

### Step 3: Push to GitHub

Navigate to the repository folder and run:

```powershell
cd Z:\Googlemcp

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Coolify-ready Google Workspace MCP"

# Add your GitHub repository as remote
git remote add origin https://github.com/TMerlini/Google-Workspace-MCP-Synology.git

# Push to GitHub
git push -u origin main
```

If the default branch is `master` instead of `main`, use:
```powershell
git branch -M main
git push -u origin main
```

### Step 4: Enter GitHub Credentials

When prompted:
- **Username:** Your GitHub username
- **Password:** Use a Personal Access Token (not your password)

**To create a Personal Access Token:**
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (full control of private repositories)
4. Copy the token and use it as your password

## Option 2: Use GitHub Desktop (Easiest)

### Step 1: Install GitHub Desktop

Download from: https://desktop.github.com/

### Step 2: Add Repository

1. Open GitHub Desktop
2. File → Add Local Repository
3. Choose: `Z:\Googlemcp`
4. If it says "not a git repository", click "create a repository here"
5. Click "Publish repository"
6. Choose your account and repository name
7. Uncheck "Keep this code private" if you want it public
8. Click "Publish Repository"

## Option 3: Use GitHub Web Interface (Manual)

### Step 1: Create a ZIP file

1. Right-click on `Z:\Googlemcp` folder
2. Send to → Compressed (zipped) folder
3. Name it `google-workspace-mcp.zip`

### Step 2: Upload to GitHub

1. Go to: https://github.com/TMerlini/Google-Workspace-MCP-Synology
2. Click "uploading an existing file"
3. Drag and drop the ZIP file
4. Wait for upload to complete
5. Add commit message: "Initial commit: Coolify-ready Google Workspace MCP"
6. Click "Commit changes"

**Note:** This method is less ideal as it doesn't preserve git history.

## Option 4: Use the Automated Script (After Installing Git)

I've created a script for you: `push-to-github.ps1`

After installing Git, simply run:

```powershell
cd Z:\Googlemcp
.\push-to-github.ps1
```

## What Will Be Pushed

The following files will be uploaded to your GitHub repository:

### Documentation
- `START_HERE.md` - Entry point for users
- `QUICKSTART_COOLIFY.md` - 5-minute deployment guide
- `COOLIFY_DEPLOYMENT.md` - Comprehensive deployment docs
- `DEPLOYMENT_CHECKLIST.md` - Step-by-step checklist
- `README_COOLIFY.md` - Coolify setup overview
- `ARCHITECTURE.md` - System architecture diagrams
- `SETUP_SUMMARY.txt` - Text summary

### Configuration Files
- `.env.coolify` - Environment variable template
- `docker-compose.coolify.yml` - Coolify-optimized compose
- `Dockerfile` - Container build instructions
- `docker-compose.yml` - Original compose file
- `pyproject.toml` - Python dependencies

### Source Code
- `main.py` - Server entry point
- `fastmcp_server.py` - FastMCP server implementation
- All service modules (`auth/`, `gmail/`, `gdrive/`, etc.)

### Original Project Files
- `README.md` - Original project documentation
- `LICENSE` - MIT License
- All other original files

## Recommended: Add a Custom README

Before pushing, you might want to create a custom README for your fork:

```powershell
# This will be created for you automatically
```

## After Pushing

Once pushed, your repository will be available at:
https://github.com/TMerlini/Google-Workspace-MCP-Synology

You can then:
1. Share the link with others
2. Deploy directly from GitHub to Coolify
3. Enable GitHub Actions (if needed)
4. Add collaborators
5. Create issues and pull requests

## Troubleshooting

### "Permission denied" error
- Make sure you're using a Personal Access Token, not your password
- Check that the token has `repo` scope

### "Repository not found" error
- Verify the repository URL is correct
- Make sure you're logged into the correct GitHub account

### "Failed to push" error
- Check your internet connection
- Verify the repository exists on GitHub
- Try: `git remote -v` to see if the remote is set correctly

### Large file warnings
- Git will warn about files over 50MB
- The `uv.lock` file is large but should be fine
- If issues occur, add to `.gitignore`: `uv.lock`

## Need Help?

- Git documentation: https://git-scm.com/doc
- GitHub guides: https://guides.github.com/
- GitHub Desktop help: https://docs.github.com/en/desktop

---

**Recommended:** Use Option 1 (Install Git) or Option 2 (GitHub Desktop) for best results.
