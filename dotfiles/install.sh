#!/usr/bin/env bash

# ============================================================================
# DOTFILES INSTALLATION SCRIPT
# ============================================================================
# Description: Install dotfiles for brennan.cafe homelab
# Author: Brennan Kenneth Brown
# Usage: ./install.sh
# ============================================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_info() {
    echo -e "${YELLOW}➜${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

backup_file() {
    local file=$1
    if [ -f "$file" ] || [ -d "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$file" "$backup"
        print_info "Backed up existing file to: $backup"
    fi
}

# ============================================================================
# MAIN INSTALLATION
# ============================================================================

print_header "🌻 Installing brennan.cafe Dotfiles"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# ============================================================================
# BASH CONFIGURATION
# ============================================================================

print_info "Installing bash configuration..."

# Backup and install .bashrc
backup_file ~/.bashrc
ln -sf "$DOTFILES_DIR/.bashrc" ~/.bashrc
print_success "Installed .bashrc"

# Backup and install .bash_aliases
backup_file ~/.bash_aliases
ln -sf "$DOTFILES_DIR/.bash_aliases" ~/.bash_aliases
print_success "Installed .bash_aliases"

# Install .bash_profile if it exists
if [ -f "$DOTFILES_DIR/.bash_profile" ]; then
    backup_file ~/.bash_profile
    ln -sf "$DOTFILES_DIR/.bash_profile" ~/.bash_profile
    print_success "Installed .bash_profile"
fi

# Install .inputrc if it exists
if [ -f "$DOTFILES_DIR/.inputrc" ]; then
    backup_file ~/.inputrc
    ln -sf "$DOTFILES_DIR/.inputrc" ~/.inputrc
    print_success "Installed .inputrc"
fi

# ============================================================================
# MICRO EDITOR CONFIGURATION
# ============================================================================

print_info "Installing micro editor configuration..."

# Create .config/micro directory
mkdir -p ~/.config/micro

# Install micro settings
if [ -f "$DOTFILES_DIR/.micro/settings.json" ]; then
    ln -sf "$DOTFILES_DIR/.micro/settings.json" ~/.config/micro/settings.json
    print_success "Installed micro settings.json"
fi

# Install micro bindings if exists
if [ -f "$DOTFILES_DIR/.micro/bindings.json" ]; then
    ln -sf "$DOTFILES_DIR/.micro/bindings.json" ~/.config/micro/bindings.json
    print_success "Installed micro bindings.json"
fi

# Create backups directory for micro
mkdir -p ~/.config/micro/backups

# ============================================================================
# SSH CONFIGURATION
# ============================================================================

print_info "Installing SSH configuration..."

# Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Install SSH config
if [ -f "$DOTFILES_DIR/.ssh/config" ]; then
    backup_file ~/.ssh/config
    ln -sf "$DOTFILES_DIR/.ssh/config" ~/.ssh/config
    chmod 600 ~/.ssh/config
    print_success "Installed SSH config"
fi

# Create SSH sockets directory for connection multiplexing
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh/sockets

# Check if SSH key exists
if [ ! -f ~/.ssh/id_ed25519 ]; then
    print_info "No SSH key found. Generate one with:"
    echo "    ssh-keygen -t ed25519 -C 'brennan@omg.lol'"
    echo ""
    echo "Your public key should be:"
    echo "    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYU6lvu3nmR49iW0mK/Lrqs4P02ouw2wZq1Sa5LkU2v brennan@omg.lol"
else
    print_success "SSH key already exists"
fi

# ============================================================================
# GIT CONFIGURATION (Optional)
# ============================================================================

print_info "Configuring Git..."

# Set Git global config
git config --global user.name "Brennan Kenneth Brown"
git config --global user.email "mail@brennanbrown.ca"
git config --global init.defaultBranch main
git config --global core.editor "micro"
git config --global pull.rebase false
git config --global credential.helper store

print_success "Git configured"

# ============================================================================
# CREATE HOMELAB DIRECTORIES
# ============================================================================

print_info "Creating homelab directory structure..."

HOMELAB_ROOT="$HOME/brennan.cafe"

mkdir -p "$HOMELAB_ROOT"/{docker,scripts,backups,docs}
mkdir -p "$HOMELAB_ROOT/docker"/{caddy,nextcloud,jellyfin,hedgedoc,uptime-kuma,plausible}
mkdir -p "$HOMELAB_ROOT/scripts"/{setup,maintenance,monitoring,deployment}
mkdir -p "$HOMELAB_ROOT/backups"/{restic,manual}

print_success "Created directory structure at $HOMELAB_ROOT"

# ============================================================================
# SOURCE NEW CONFIGURATION
# ============================================================================

print_info "Sourcing new bash configuration..."

# Source the new bashrc (if running in bash)
if [ -n "${BASH_VERSION:-}" ]; then
    source ~/.bashrc
    print_success "Bash configuration reloaded"
else
    print_info "Please restart your shell or run: source ~/.bashrc"
fi

# ============================================================================
# SUMMARY
# ============================================================================

print_header "✨ Dotfiles Installation Complete"

echo "The following dotfiles have been installed:"
echo ""
echo "  ✓ ~/.bashrc (bash configuration)"
echo "  ✓ ~/.bash_aliases (command shortcuts)"
echo "  ✓ ~/.config/micro/settings.json (micro editor config)"
echo "  ✓ ~/.ssh/config (SSH client config)"
echo "  ✓ Git global configuration"
echo "  ✓ Homelab directory structure"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. Run: cd ~/brennan.cafe"
echo "  3. Run setup scripts: cd scripts/setup && sudo ./01-system-hardening.sh"
echo ""

# Show helpful aliases
print_header "📚 Useful Aliases"
echo "Quick navigation:"
echo "  homelab          # cd ~/brennan.cafe"
echo "  cddocker         # cd ~/brennan.cafe/docker"
echo "  cdscripts        # cd ~/brennan.cafe/scripts"
echo ""
echo "Docker shortcuts:"
echo "  dc               # docker compose"
echo "  dcup             # docker compose up -d"
echo "  dcdown           # docker compose down"
echo "  dclogs           # docker compose logs -f"
echo ""
echo "Editing:"
echo "  edit             # micro (your default editor)"
echo "  aliases          # edit aliases file"
echo "  bashrc           # edit bashrc file"
echo ""

print_success "Dotfiles ready! Welcome to brennan.cafe homelab 🌻"

# ============================================================================
# POST-INSTALL CHECKS
# ============================================================================

print_header "🔍 Post-Install Checks"

# Check if micro is installed
if command -v micro &> /dev/null; then
    print_success "micro editor: $(micro --version)"
else
    print_info "micro editor not found. Install with: sudo apt install micro"
fi

# Check if git is configured
if git config --global user.name &> /dev/null; then
    print_success "Git user: $(git config --global user.name)"
else
    print_info "Git not configured"
fi

# Check if SSH key exists
if [ -f ~/.ssh/id_ed25519 ]; then
    print_success "SSH key exists"
    echo "    Public key fingerprint:"
    ssh-keygen -lf ~/.ssh/id_ed25519 | sed 's/^/    /'
else
    print_info "SSH key not found - generate one with ssh-keygen"
fi

echo ""
print_success "All checks complete!"
