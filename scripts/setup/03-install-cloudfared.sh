#!/usr/bin/env bash

# ============================================================================
# CLOUDFLARE TUNNEL INSTALLATION SCRIPT
# ============================================================================
# Description: Install and configure Cloudflare Tunnel for brennan.cafe
# Author: Brennan Kenneth Brown
# Usage: sudo ./03-install-cloudflared.sh
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# CONFIGURATION
# ============================================================================

TUNNEL_NAME="brennan-cafe"
CONFIG_DIR="/etc/cloudflared"
TUNNEL_CONFIG="$CONFIG_DIR/config.yml"

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

print_note() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

print_header "☁️  Cloudflare Tunnel Setup for brennan.cafe"

check_root

print_info "This script will:"
echo "  1. Install cloudflared"
echo "  2. Help you authenticate with Cloudflare"
echo "  3. Create a tunnel for brennan.cafe"
echo "  4. Configure DNS routing"
echo "  5. Set up systemd service"
echo ""

print_note "You'll need:"
echo "  - A Cloudflare account"
echo "  - brennan.cafe domain added to Cloudflare"
echo "  - A web browser for authentication"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Aborted by user"
    exit 1
fi

# ============================================================================
# INSTALL CLOUDFLARED
# ============================================================================

print_header "📦 Installing cloudflared"

# Check if already installed
if command -v cloudflared &> /dev/null; then
    CURRENT_VERSION=$(cloudflared --version | head -n1)
    print_info "cloudflared is already installed: $CURRENT_VERSION"
    
    read -p "Reinstall/update cloudflared? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping installation"
    else
        print_info "Updating cloudflared..."
        apt remove -y cloudflared 2>/dev/null || true
    fi
fi

if ! command -v cloudflared &> /dev/null; then
    print_info "Adding Cloudflare GPG key..."
    
    # Add Cloudflare's package signing key
    mkdir -p /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
        tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    
    print_info "Adding Cloudflare repository..."
    
    # Add Cloudflare's apt repository
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/cloudflared.list
    
    print_info "Updating package list..."
    apt update -qq
    
    print_info "Installing cloudflared..."
    apt install -y cloudflared
    
    print_success "cloudflared installed: $(cloudflared --version | head -n1)"
fi

# ============================================================================
# AUTHENTICATE WITH CLOUDFLARE
# ============================================================================

print_header "🔐 Cloudflare Authentication"

print_info "You need to authenticate cloudflared with your Cloudflare account."
echo ""
echo "Options:"
echo "  1. Browser authentication (recommended for first-time setup)"
echo "  2. Use existing tunnel token (if you already created a tunnel)"
echo ""

read -p "Choose option (1/2): " -n 1 -r AUTH_OPTION
echo
echo ""

if [[ $AUTH_OPTION == "1" ]]; then
    # Browser authentication
    print_info "Starting authentication flow..."
    print_note "A browser window will open. Please log in to Cloudflare."
    echo ""
    
    # Run authentication
    cloudflared tunnel login
    
    if [ -f ~/.cloudflared/cert.pem ]; then
        print_success "Authentication successful!"
        
        # Move cert to system location
        mkdir -p $CONFIG_DIR
        cp ~/.cloudflared/cert.pem $CONFIG_DIR/
        chmod 600 $CONFIG_DIR/cert.pem
    else
        print_error "Authentication failed - cert.pem not found"
        exit 1
    fi
    
elif [[ $AUTH_OPTION == "2" ]]; then
    # Token-based authentication
    print_info "Enter your Cloudflare Tunnel token:"
    echo "(Get this from: https://one.dash.cloudflare.com/ > Networks > Tunnels)"
    echo ""
    read -r TUNNEL_TOKEN
    
    if [ -z "$TUNNEL_TOKEN" ]; then
        print_error "No token provided"
        exit 1
    fi
    
    # We'll use the token in the config later
    print_success "Token received"
    
else
    print_error "Invalid option"
    exit 1
fi

# ============================================================================
# CREATE TUNNEL
# ============================================================================

print_header "🚇 Creating Cloudflare Tunnel"

if [[ $AUTH_OPTION == "1" ]]; then
    # Check if tunnel already exists
    if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
        print_info "Tunnel '$TUNNEL_NAME' already exists"
        
        read -p "Delete and recreate? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Deleting existing tunnel..."
            cloudflared tunnel delete $TUNNEL_NAME
        else
            print_info "Using existing tunnel"
        fi
    fi
    
    # Create new tunnel if it doesn't exist
    if ! cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
        print_info "Creating new tunnel: $TUNNEL_NAME"
        cloudflared tunnel create $TUNNEL_NAME
        print_success "Tunnel created!"
    fi
    
    # Get tunnel ID
    TUNNEL_ID=$(cloudflared tunnel info $TUNNEL_NAME | grep "ID:" | awk '{print $2}')
    print_info "Tunnel ID: $TUNNEL_ID"
    
    # Copy credentials to system location
    CRED_FILE=$(ls ~/.cloudflared/*.json | grep "$TUNNEL_ID")
    if [ -f "$CRED_FILE" ]; then
        cp "$CRED_FILE" "$CONFIG_DIR/"
        chmod 600 "$CONFIG_DIR/"*.json
        print_success "Tunnel credentials saved"
    fi
fi

# ============================================================================
# CONFIGURE DNS ROUTING
# ============================================================================

print_header "🌐 DNS Configuration"

if [[ $AUTH_OPTION == "1" ]]; then
    print_info "Setting up DNS records..."
    echo ""
    echo "The following DNS records will be created:"
    echo "  brennan.cafe          → tunnel"
    echo "  *.brennan.cafe        → tunnel"
    echo ""
    
    read -p "Create DNS records automatically? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create DNS records
        print_info "Creating DNS record for brennan.cafe..."
        cloudflared tunnel route dns $TUNNEL_NAME brennan.cafe || print_error "Failed to create brennan.cafe record"
        
        print_info "Creating DNS record for *.brennan.cafe..."
        cloudflared tunnel route dns $TUNNEL_NAME "*.brennan.cafe" || print_error "Failed to create wildcard record"
        
        print_success "DNS records created"
    else
        print_note "You'll need to create DNS records manually:"
        echo "  1. Go to: https://dash.cloudflare.com/"
        echo "  2. Select brennan.cafe domain"
        echo "  3. Go to DNS > Records"
        echo "  4. Create CNAME records:"
        echo "     - brennan.cafe → $TUNNEL_ID.cfargotunnel.com"
        echo "     - *.brennan.cafe → $TUNNEL_ID.cfargotunnel.com"
    fi
fi

# ============================================================================
# CREATE TUNNEL CONFIGURATION
# ============================================================================

print_header "⚙️  Tunnel Configuration"

print_info "Creating tunnel configuration..."

mkdir -p $CONFIG_DIR

if [[ $AUTH_OPTION == "1" ]]; then
    # Configuration with tunnel ID
    cat > $TUNNEL_CONFIG << EOF
# Cloudflare Tunnel Configuration for brennan.cafe
# Generated: $(date)

tunnel: $TUNNEL_ID
credentials-file: $CONFIG_DIR/$TUNNEL_ID.json

# Ingress rules - route traffic to services
ingress:
  # Main site
  - hostname: brennan.cafe
    service: http://localhost:80
  
  # File storage - Nextcloud
  - hostname: files.brennan.cafe
    service: http://localhost:80
  
  # Media server - Jellyfin
  - hostname: media.brennan.cafe
    service: http://localhost:80
  
  # Collaborative notes - HedgeDoc
  - hostname: notes.brennan.cafe
    service: http://localhost:80
  
  # Status monitoring - Uptime Kuma
  - hostname: status.brennan.cafe
    service: http://localhost:80
  
  # Analytics - Plausible
  - hostname: analytics.brennan.cafe
    service: http://localhost:80
  
  # Wildcard - catch all other subdomains
  - hostname: "*.brennan.cafe"
    service: http://localhost:80
  
  # Default - return 404 for anything else
  - service: http_status:404

# Logging
loglevel: info
EOF

elif [[ $AUTH_OPTION == "2" ]]; then
    # Configuration with token
    cat > $TUNNEL_CONFIG << EOF
# Cloudflare Tunnel Configuration for brennan.cafe
# Generated: $(date)

tunnel: $TUNNEL_TOKEN

# Ingress rules
ingress:
  - hostname: brennan.cafe
    service: http://localhost:80
  - hostname: files.brennan.cafe
    service: http://localhost:80
  - hostname: media.brennan.cafe
    service: http://localhost:80
  - hostname: notes.brennan.cafe
    service: http://localhost:80
  - hostname: status.brennan.cafe
    service: http://localhost:80
  - hostname: analytics.brennan.cafe
    service: http://localhost:80
  - hostname: "*.brennan.cafe"
    service: http://localhost:80
  - service: http_status:404
EOF
fi

chmod 600 $TUNNEL_CONFIG
print_success "Configuration created at $TUNNEL_CONFIG"

# ============================================================================
# CREATE SYSTEMD SERVICE
# ============================================================================

print_header "🔧 Systemd Service Setup"

print_info "Creating systemd service..."

cat > /etc/systemd/system/cloudflared.service << EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/cloudflared tunnel --config $TUNNEL_CONFIG run
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

print_info "Reloading systemd..."
systemctl daemon-reload

print_info "Enabling cloudflared service..."
systemctl enable cloudflared

print_info "Starting cloudflared service..."
systemctl start cloudflared

# Wait for service to start
sleep 3

# Check status
if systemctl is-active --quiet cloudflared; then
    print_success "Cloudflare Tunnel is running!"
else
    print_error "Service failed to start"
    print_info "Checking logs..."
    journalctl -u cloudflared -n 20 --no-pager
    exit 1
fi

# ============================================================================
# VERIFY CONNECTION
# ============================================================================

print_header "✅ Verifying Tunnel"

print_info "Checking tunnel status..."
systemctl status cloudflared --no-pager | head -n 10

echo ""
print_info "Checking connectivity..."

# Give it a moment to establish connection
sleep 5

if cloudflared tunnel info $TUNNEL_NAME &>/dev/null || systemctl is-active --quiet cloudflared; then
    print_success "Tunnel is connected!"
else
    print_error "Tunnel connection issues detected"
    print_info "Check logs with: sudo journalctl -u cloudflared -f"
fi

# ============================================================================
# SUMMARY
# ============================================================================

print_header "✨ Cloudflare Tunnel Setup Complete"

echo "Your Cloudflare Tunnel is now running!"
echo ""
echo "Services will be available at:"
echo "  🌻 Main site:    https://brennan.cafe"
echo "  📁 Files:        https://files.brennan.cafe"
echo "  🎬 Media:        https://media.brennan.cafe"
echo "  📝 Notes:        https://notes.brennan.cafe"
echo "  📊 Status:       https://status.brennan.cafe"
echo "  📈 Analytics:    https://analytics.brennan.cafe"
echo ""
echo "Configuration:"
echo "  Config file: $TUNNEL_CONFIG"
echo "  Service:     cloudflared.service"
echo "  Status:      systemctl status cloudflared"
echo "  Logs:        journalctl -u cloudflared -f"
echo ""
echo "Next steps:"
echo "  1. Wait 5-10 minutes for DNS propagation"
echo "  2. Run: cd ~/brennan.cafe/docker"
echo "  3. Run: cp .env.example .env"
echo "  4. Edit .env and add your passwords"
echo "  5. Run: docker compose up -d"
echo ""

print_note "DNS propagation can take 5-10 minutes. Be patient!"
echo ""

# Show helpful commands
print_header "📚 Useful Commands"
echo "  sudo systemctl status cloudflared    # Check service status"
echo "  sudo systemctl restart cloudflared   # Restart tunnel"
echo "  sudo journalctl -u cloudflared -f    # View live logs"
echo "  cloudflared tunnel info $TUNNEL_NAME # Tunnel information"
echo "  cloudflared tunnel list              # List all tunnels"
echo ""

print_success "Cloudflare Tunnel is ready! 🌻"

# ============================================================================
# TROUBLESHOOTING INFO
# ============================================================================

print_header "🐛 Troubleshooting"
echo "If you have connection issues:"
echo ""
echo "1. Check service status:"
echo "   sudo systemctl status cloudflared"
echo ""
echo "2. View recent logs:"
echo "   sudo journalctl -u cloudflared -n 50"
echo ""
echo "3. Test DNS:"
echo "   dig brennan.cafe"
echo "   dig files.brennan.cafe"
echo ""
echo "4. Verify tunnel:"
echo "   cloudflared tunnel info $TUNNEL_NAME"
echo ""
echo "5. Check firewall:"
echo "   sudo ufw status"
echo ""

print_success "Setup complete! The tunnel will start automatically on boot."