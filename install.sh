#!/usr/bin/env bash
# Claude Code Bug Catcher — One-Line Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code-bug-catcher/main/install.sh | bash

set -euo pipefail

REPO="AlbusZhuo/claude-code-bug-catcher"
SKILLS_DIR="${HOME}/.claude/skills"
TARGET_DIR="${SKILLS_DIR}/bug-catcher"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[Bug Catcher]${NC} $1"; }
warn() { echo -e "${YELLOW}[Bug Catcher]${NC} $1"; }
error() { echo -e "${RED}[Bug Catcher]${NC} $1"; exit 1; }

# Check prerequisites
check_prereqs() {
    if ! command -v git &> /dev/null; then
        error "git is required but not installed. Install git first."
    fi

    if ! command -v claude &> /dev/null; then
        warn "Claude Code CLI not found. Make sure it's installed and in your PATH."
    fi
}

# Install skills
install_skills() {
    info "Installing Bug Catcher skills..."

    # Create skills directory if it doesn't exist
    mkdir -p "${SKILLS_DIR}"

    # Remove old installation if exists
    if [ -d "${TARGET_DIR}" ]; then
        warn "Existing installation found. Updating..."
        rm -rf "${TARGET_DIR}"
    fi

    # Clone the repo
    git clone --depth 1 "https://github.com/${REPO}.git" "${TARGET_DIR}" 2>/dev/null || {
        error "Failed to clone repository. Check your internet connection."
    }

    # Remove .git directory (we don't need it in skills)
    rm -rf "${TARGET_DIR}/.git"

    info "Skills installed to ${TARGET_DIR}"
}

# Verify installation
verify() {
    if [ -f "${TARGET_DIR}/SKILL.md" ]; then
        info "Installation complete!"
        echo ""
        echo "  Bug Catcher is now active. It will automatically review code changes"
        echo "  in your next Claude Code session."
        echo ""
        echo "  Manual usage:"
        echo "    /review-bugs           — Review current file"
        echo "    /review-bugs <file>    — Review specific file"
        echo "    /review-bugs --staged  — Review staged changes"
        echo ""
        echo "  Configuration: Create .bug-catcher.json in your project root"
        echo ""
    else
        error "Installation verification failed. SKILL.md not found."
    fi
}

# Main
main() {
    echo ""
    info "Installing Claude Code Bug Catcher..."
    echo ""

    check_prereqs
    install_skills
    verify
}

main "$@"
