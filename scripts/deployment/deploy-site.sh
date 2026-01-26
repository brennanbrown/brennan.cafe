#!/usr/bin/env bash

# ============================================================================
# SITE DEPLOYMENT SCRIPT
# ============================================================================
# Description: Build and deploy Hugo static site for brennan.cafe
# Author: Brennan Kenneth Brown
# Usage: ./deploy-site.sh
# Location: ~/brennan.cafe/scripts/deployment/deploy-site.sh
# ============================================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================================================
# CONFIGURATION
# ============================================================================

# Paths
HOMELAB_ROOT="${HOMELAB_ROOT:-$HOME/brennan.cafe}"
HUGO_DIR="$HOMELAB_ROOT/docs"
PUBLIC_DIR="$HUGO_DIR/public"
DOCKER_DIR="$HOMELAB_ROOT/docker"

# Site configuration
SITE_URL="https://brennan.cafe"
ENVIRONMENT="production"

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

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

print_header "🌻 Deploying brennan.cafe Site"

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    print_error "Hugo is not installed!"
    echo ""
    echo "Install Hugo with:"
    echo "  sudo snap install hugo"
    echo ""
    echo "Or download from: https://gohugo.io/installation/"
    exit 1
fi

HUGO_VERSION=$(hugo version | head -n 1)
print_info "Hugo version: $HUGO_VERSION"

# Check if Hugo directory exists
if [ ! -d "$HUGO_DIR" ]; then
    print_error "Hugo directory not found: $HUGO_DIR"
    echo ""
    echo "Create your Hugo site with:"
    echo "  cd $HOMELAB_ROOT"
    echo "  hugo new site docs"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    print_error "Docker is not running!"
    echo ""
    echo "Start Docker with:"
    echo "  sudo systemctl start docker"
    exit 1
fi

print_success "Pre-flight checks passed"

# ============================================================================
# BACKUP PREVIOUS BUILD
# ============================================================================

print_header "💾 Backing Up Previous Build"

if [ -d "$PUBLIC_DIR" ]; then
    BACKUP_DIR="$HOMELAB_ROOT/backups/manual/site-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$(dirname "$BACKUP_DIR")"
    
    print_info "Creating backup..."
    cp -r "$PUBLIC_DIR" "$BACKUP_DIR"
    print_success "Backup created: $BACKUP_DIR"
else
    print_info "No previous build found, skipping backup"
fi

# ============================================================================
# CLEAN PREVIOUS BUILD
# ============================================================================

print_header "🧹 Cleaning Previous Build"

if [ -d "$PUBLIC_DIR" ]; then
    print_info "Removing old public directory..."
    rm -rf "$PUBLIC_DIR"
    print_success "Old build removed"
fi

# ============================================================================
# BUILD SITE
# ============================================================================

print_header "🔨 Building Site with Hugo"

cd "$HUGO_DIR"

print_info "Building site for production..."
hugo --minify --environment "$ENVIRONMENT"

# Check if build was successful
if [ ! -d "$PUBLIC_DIR" ]; then
    print_error "Build failed! Public directory not created."
    exit 1
fi

# Count files
FILE_COUNT=$(find "$PUBLIC_DIR" -type f | wc -l)
SIZE=$(du -sh "$PUBLIC_DIR" | cut -f1)

print_success "Build complete!"
echo "  Files: $FILE_COUNT"
echo "  Size: $SIZE"

# ============================================================================
# OPTIMIZE BUILD
# ============================================================================

print_header "⚡ Optimizing Build"

cd "$PUBLIC_DIR"

# Count assets
HTML_COUNT=$(find . -name "*.html" | wc -l)
CSS_COUNT=$(find . -name "*.css" | wc -l)
JS_COUNT=$(find . -name "*.js" | wc -l)
IMG_COUNT=$(find . \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.svg" \) | wc -l)

echo "  HTML files: $HTML_COUNT"
echo "  CSS files: $CSS_COUNT"
echo "  JS files: $JS_COUNT"
echo "  Images: $IMG_COUNT"

print_success "Build optimized"

# ============================================================================
# DEPLOY TO DOCKER VOLUME
# ============================================================================

print_header "🚀 Deploying to Caddy"

print_info "Restarting Caddy to pick up new files..."
cd "$DOCKER_DIR"
docker compose restart caddy

# Wait for Caddy to start
sleep 3

# Check if Caddy is running
if docker compose ps caddy | grep -q "Up"; then
    print_success "Caddy restarted successfully"
else
    print_error "Caddy failed to start!"
    docker compose logs caddy --tail=20
    exit 1
fi

# ============================================================================
# VERIFY DEPLOYMENT
# ============================================================================

print_header "✅ Verifying Deployment"

print_info "Testing local access..."

# Test if site is accessible (using localhost since we're on the same machine)
if curl -sf http://localhost > /dev/null; then
    print_success "Site is accessible locally"
else
    print_error "Site is not accessible locally"
    exit 1
fi

# ============================================================================
# GIT COMMIT (Optional)
# ============================================================================

print_header "📝 Git Commit (Optional)"

cd "$HOMELAB_ROOT"

# Check if there are changes
if ! git diff --quiet; then
    print_info "Changes detected in repository"
    
    # Show git status
    git status --short
    
    echo ""
    read -p "Commit changes to git? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Committing changes..."
        
        # Add all changes
        git add .
        
        # Commit with timestamp
        COMMIT_MSG="Deploy site - $(date +"%Y-%m-%d %H:%M:%S")"
        git commit -m "$COMMIT_MSG"
        
        print_success "Changes committed"
        
        # Ask about pushing
        read -p "Push to GitHub? (y/N) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Pushing to GitHub..."
            git push origin main
            print_success "Pushed to GitHub"
        fi
    else
        print_info "Skipping git commit"
    fi
else
    print_info "No changes to commit"
fi

# ============================================================================
# SUMMARY
# ============================================================================

print_header "✨ Deployment Complete"

echo "brennan.cafe has been deployed successfully!"
echo ""
echo "  🌍 URL: $SITE_URL"
echo "  📁 Build: $PUBLIC_DIR"
echo "  📊 Files: $FILE_COUNT"
echo "  💾 Size: $SIZE"
echo ""
echo "Next steps:"
echo "  1. Visit $SITE_URL to verify"
echo "  2. Check Caddy logs: docker compose logs caddy"
echo "  3. Monitor status at: status.brennan.cafe"
echo ""

# Show site stats
print_header "📈 Site Statistics"
echo "Content breakdown:"
echo "  - HTML pages: $HTML_COUNT"
echo "  - CSS files: $CSS_COUNT"
echo "  - JavaScript files: $JS_COUNT"
echo "  - Images: $IMG_COUNT"
echo ""

# Show recent Hugo content
if [ -d "$HUGO_DIR/content/posts" ]; then
    POST_COUNT=$(find "$HUGO_DIR/content/posts" -name "*.md" | wc -l)
    echo "  - Blog posts: $POST_COUNT"
fi

print_success "Deployment successful! 🌻"

# ============================================================================
# CLEANUP OLD BACKUPS (Keep last 5)
# ============================================================================

BACKUP_BASE="$HOMELAB_ROOT/backups/manual"
if [ -d "$BACKUP_BASE" ]; then
    print_info "Cleaning old backups (keeping last 5)..."
    
    # Count backups
    BACKUP_COUNT=$(find "$BACKUP_BASE" -maxdepth 1 -type d -name "site-*" | wc -l)
    
    if [ "$BACKUP_COUNT" -gt 5 ]; then
        # Remove old backups, keep 5 most recent
        find "$BACKUP_BASE" -maxdepth 1 -type d -name "site-*" | sort | head -n -5 | xargs rm -rf
        print_success "Old backups cleaned"
    else
        print_info "Only $BACKUP_COUNT backups, no cleanup needed"
    fi
fi

echo ""
print_info "Done! Your site is live at $SITE_URL 🚀"
