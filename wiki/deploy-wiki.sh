#!/usr/bin/env bash
# Wiki deployment script for brennan.page
set -euo pipefail

# Configuration
SITE_DIR="site"
REMOTE="root@159.203.44.169"
REMOTE_DIR="/opt/homelab/wiki"

echo "Building and deploying brennan.page wiki..."

# Build the wiki
echo "Building wiki with MkDocs..."
mkdocs build

# Check if build was successful
if [ ! -d "$SITE_DIR" ]; then
    echo "Error: Build failed - site directory not found"
    exit 1
fi

# Deploy to server
echo "Deploying to server..."
rsync -avz --delete "${SITE_DIR}/" "${REMOTE}:${REMOTE_DIR}/"

# Verify deployment
echo "Verifying deployment..."
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes "${REMOTE}" "test -f ${REMOTE_DIR}/index.html && echo 'Wiki deployed successfully' || echo 'Deployment verification failed'"

echo "Wiki deployment complete!"
echo "Visit https://wiki.brennan.page to view the deployed wiki."
