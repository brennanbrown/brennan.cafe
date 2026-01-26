#!/usr/bin/env bash

# ============================================================================
# DOCKER INSTALLATION SCRIPT
# ============================================================================
# Description: Install Docker and Docker Compose on brennan.cafe homelab
# Author: Brennan Kenneth Brown
# Usage: sudo ./02-install-docker.sh
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

print_header "🐳 Docker Installation for brennan.cafe"

check_root

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_info "Docker is already installed: $DOCKER_VERSION"
    read -p "Reinstall Docker? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping Docker installation"
        exit 0
    fi
fi

print_info "System: $(lsb_release -ds)"
echo ""

read -p "Install Docker and Docker Compose? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Aborted by user"
    exit 1
fi

# ============================================================================
# REMOVE OLD VERSIONS
# ============================================================================

print_header "🧹 Removing Old Docker Versions"

print_info "Removing any existing Docker installations..."

apt remove -y \
    docker \
    docker-engine \
    docker.io \
    containerd \
    runc \
    2>/dev/null || true

print_success "Old Docker versions removed"

# ============================================================================
# INSTALL PREREQUISITES
# ============================================================================

print_header "📦 Installing Prerequisites"

print_info "Updating package list..."
apt update -qq

print_info "Installing required packages..."
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

print_success "Prerequisites installed"

# ============================================================================
# INSTALL DOCKER
# ============================================================================

print_header "🐳 Installing Docker Engine"

print_info "Adding Docker's official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

print_info "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

print_info "Updating package list..."
apt update -qq

print_info "Installing Docker Engine..."
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

print_success "Docker Engine installed"

# ============================================================================
# CONFIGURE DOCKER
# ============================================================================

print_header "⚙️  Configuring Docker"

# Add user to docker group (no sudo needed for docker commands)
print_info "Adding $SUDO_USER to docker group..."
usermod -aG docker $SUDO_USER

# Create Docker daemon configuration
print_info "Creating Docker daemon configuration..."
mkdir -p /etc/docker

cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {
      "base": "172.20.0.0/16",
      "size": 24
    }
  ],
  "dns": ["1.1.1.1", "1.0.0.1"],
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false,
  "metrics-addr": "127.0.0.1:9323"
}
EOF

print_success "Docker daemon configured"

# ============================================================================
# ENABLE IP FORWARDING (Required for Docker)
# ============================================================================

print_info "Enabling IP forwarding for Docker..."

# Update sysctl for Docker networking
cat > /etc/sysctl.d/98-docker.conf << 'EOF'
# Docker networking requirements
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

sysctl -p /etc/sysctl.d/98-docker.conf > /dev/null

print_success "IP forwarding enabled"

# ============================================================================
# START DOCKER
# ============================================================================

print_header "🚀 Starting Docker"

print_info "Enabling Docker service..."
systemctl enable docker
systemctl enable containerd

print_info "Starting Docker service..."
systemctl restart docker

# Wait for Docker to be ready
sleep 3

print_success "Docker is running"

# ============================================================================
# VERIFY INSTALLATION
# ============================================================================

print_header "✅ Verifying Installation"

# Docker version
DOCKER_VERSION=$(docker --version)
print_success "Docker installed: $DOCKER_VERSION"

# Docker Compose version
COMPOSE_VERSION=$(docker compose version)
print_success "Docker Compose installed: $COMPOSE_VERSION"

# Test Docker
print_info "Running test container..."
if docker run --rm hello-world > /dev/null 2>&1; then
    print_success "Docker test successful"
else
    print_error "Docker test failed"
    exit 1
fi

# ============================================================================
# DOCKER COMPOSE STANDALONE (Optional)
# ============================================================================

print_header "📋 Docker Compose Standalone"

print_info "Docker Compose is available via 'docker compose' command"
print_info "Creating 'docker-compose' alias for compatibility..."

# Create symlink for docker-compose command (for compatibility)
ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose 2>/dev/null || true

if command -v docker-compose &> /dev/null; then
    print_success "docker-compose command available"
else
    print_info "Use 'docker compose' instead of 'docker-compose'"
fi

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

print_header "🛡️  Updating Firewall for Docker"

print_info "Configuring UFW for Docker..."

# Docker needs these rules
ufw allow in on docker0 comment 'Docker internal network'
ufw allow out on docker0 comment 'Docker internal network'

print_success "Firewall configured for Docker"

# ============================================================================
# CREATE DIRECTORIES
# ============================================================================

print_header "📁 Creating Docker Directories"

HOMELAB_ROOT="/home/$SUDO_USER/brennan.cafe"

print_info "Creating brennan.cafe directory structure..."

sudo -u $SUDO_USER mkdir -p $HOMELAB_ROOT/{docker,scripts,backups,docs}
sudo -u $SUDO_USER mkdir -p $HOMELAB_ROOT/docker/{caddy,nextcloud,jellyfin,hedgedoc,uptime-kuma,plausible}
sudo -u $SUDO_USER mkdir -p $HOMELAB_ROOT/scripts/{setup,maintenance,monitoring,deployment}

print_success "Directory structure created at $HOMELAB_ROOT"

# ============================================================================
# PERFORMANCE TUNING (Optional for older hardware)
# ============================================================================

print_header "⚡ Performance Tuning"

print_info "Configuring Docker for older hardware (W520)..."

# Limit container resources by default
cat > /etc/systemd/system/docker.service.d/override.conf << 'EOF'
[Service]
# Limit Docker daemon resources on older hardware
CPUQuota=80%
MemoryLimit=8G
EOF

systemctl daemon-reload
systemctl restart docker

print_success "Performance tuning applied"

# ============================================================================
# SUMMARY
# ============================================================================

print_header "✨ Docker Installation Complete"

echo "Docker has been successfully installed and configured!"
echo ""
echo "  ✓ Docker Engine: $DOCKER_VERSION"
echo "  ✓ Docker Compose: $COMPOSE_VERSION"
echo "  ✓ User '$SUDO_USER' added to docker group"
echo "  ✓ Docker daemon configured with logging limits"
echo "  ✓ IP forwarding enabled for Docker networking"
echo "  ✓ Directory structure created at $HOMELAB_ROOT"
echo ""
echo "Next steps:"
echo "  1. Log out and back in for docker group to take effect"
echo "  2. Run: docker ps (should work without sudo)"
echo "  3. Run: ./03-install-cloudflared.sh"
echo ""
print_info "IMPORTANT: You must log out and log back in before docker commands work without sudo!"
echo ""

# Show Docker status
docker info | head -n 20

print_success "Docker is ready for brennan.cafe services 🐳"

# Helpful commands
print_header "📚 Useful Docker Commands"
echo "  docker ps                  # List running containers"
echo "  docker compose up -d       # Start services in background"
echo "  docker compose down        # Stop services"
echo "  docker compose logs -f     # Follow logs"
echo "  docker system prune -a     # Clean up unused images/containers"
echo ""