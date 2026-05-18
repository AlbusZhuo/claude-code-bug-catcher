# Claude Code Bug Catcher — Windows Installer
# Usage: irm https://raw.githubusercontent.com/anthropics/claude-code-bug-catcher/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "anthropics/claude-code-bug-catcher"
$SkillsDir = "$env:USERPROFILE\.claude\skills"
$TargetDir = "$SkillsDir\bug-catcher"

function Write-Info {
    param([string]$Message)
    Write-Host "[Bug Catcher] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[Bug Catcher] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Err {
    param([string]$Message)
    Write-Host "[Bug Catcher] " -ForegroundColor Red -NoNewline
    Write-Host $Message
    exit 1
}

# Check prerequisites
function Test-Prerequisites {
    if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Err "git is required but not installed. Install git first."
    }

    if (-not (Get-Command "claude" -ErrorAction SilentlyContinue)) {
        Write-Warn "Claude Code CLI not found. Make sure it's installed and in your PATH."
    }
}

# Install skills
function Install-Skills {
    Write-Info "Installing Bug Catcher skills..."

    # Create skills directory if it doesn't exist
    if (-not (Test-Path $SkillsDir)) {
        New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
    }

    # Remove old installation if exists
    if (Test-Path $TargetDir) {
        Write-Warn "Existing installation found. Updating..."
        Remove-Item -Recurse -Force $TargetDir
    }

    # Clone the repo
    try {
        git clone --depth 1 "https://github.com/$Repo.git" $TargetDir 2>$null
    }
    catch {
        Write-Err "Failed to clone repository. Check your internet connection."
    }

    # Remove .git directory
    if (Test-Path "$TargetDir\.git") {
        Remove-Item -Recurse -Force "$TargetDir\.git"
    }

    Write-Info "Skills installed to $TargetDir"
}

# Verify installation
function Test-Installation {
    if (Test-Path "$TargetDir\SKILL.md") {
        Write-Info "Installation complete!"
        Write-Host ""
        Write-Host "  Bug Catcher is now active. It will automatically review code changes"
        Write-Host "  in your next Claude Code session."
        Write-Host ""
        Write-Host "  Manual usage:"
        Write-Host "    /review-bugs           -- Review current file"
        Write-Host "    /review-bugs <file>    -- Review specific file"
        Write-Host "    /review-bugs --staged  -- Review staged changes"
        Write-Host ""
        Write-Host "  Configuration: Create .bug-catcher.json in your project root"
        Write-Host ""
    }
    else {
        Write-Err "Installation verification failed. SKILL.md not found."
    }
}

# Main
Write-Host ""
Write-Info "Installing Claude Code Bug Catcher..."
Write-Host ""

Test-Prerequisites
Install-Skills
Test-Installation
