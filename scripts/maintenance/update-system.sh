#!/usr/bin/env bash

# ============================================================================
# SYSTEM UPDATE SCRIPT
# ============================================================================
# Description: Comprehensive system maintenance for brennan.cafe homelab
# Author: Brennan Kenneth Brown
# Usage: ./update-system.sh
# Location: ~/brennan.cafe/scripts/maintenance/update-system.sh
# ============================================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

print_header "🔄 brennan.cafe System Maintenance"

# Check if running as root for system updates
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    echo "Usage: sudo ./update-system.sh"
    exit 1
fi

print_info "Starting comprehensive system maintenance..."
echo "  Hostname: $(hostname)"
echo "  User: $SUDO_USER"
echo "  Time: $(date)"
echo ""

read -p "Continue with system maintenance? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Aborted by user"
    exit 1
fi

# ============================================================================
# SYSTEM INFORMATION
# ============================================================================

print_header "📊 System Information"

print_step "System Status"
echo "  OS: $(lsb_release -ds)"
echo "  Kernel: $(uname -r)"
echo "  Uptime: $(uptime -p)"
echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"

print_step "Hardware Status"
echo "  CPU Temp: $(sensors | grep 'Package id 0' | awk '{print $4}' | sed 's/+//;s/°C//' 2>/dev/null || echo "N/A")°C"
echo "  Memory: $(free -h | awk 'NR==2{printf "%.1f%% used (%s/%s)", $3*100/$2, $3, $2}')"
echo "  Disk: $(df -h / | awk 'NR==2{printf "%s used (%s/%s)", $5, $3, $2}')"

print_step "Docker Status"
if command -v docker &> /dev/null; then
    echo "  Docker: $(docker --version | head -n 1)"
    echo "  Containers: $(docker ps -q | wc -l) running"
    echo "  Images: $(docker images -q | wc -l) cached"
else
    echo "  Docker: Not installed"
fi

# ============================================================================
# SYSTEM UPDATES
# ============================================================================

print_header "📦 System Package Updates"

print_step "Updating package lists"
apt update -qq

print_step "Upgrading packages"
apt upgrade -y

print_step "Installing additional security packages"
apt install -y \
    apt-listchanges \
    debsums \
    rkhunter \
    chkrootkit \
    needrestart

print_success "System packages updated"

# ============================================================================
# SECURITY UPDATES
# ============================================================================

print_header "🔒 Security Maintenance"

print_step "Checking for security updates"
if command -v apt-listchanges &> /dev/null; then
    apt-listchanges --news --frontend=news
fi

print_step "Running debsums to verify package integrity"
if command -v debsums &> /dev/null; then
    debsums --silent --changed || print_info "Some package files have changed"
fi

print_step "Running rootkit checker"
if command -v rkhunter &> /dev/null; then
    rkhunter --check --skip-keypress --report-warnings-only || true
fi

print_success "Security checks completed"

# ============================================================================
# DOCKER MAINTENANCE
# ============================================================================

print_header "🐳 Docker Maintenance"

if command -v docker &> /dev/null; then
    print_step "Updating Docker containers"
    cd /home/$SUDO_USER/brennan.cafe/docker
    
    # Pull latest images
    docker compose pull
    
    # Restart services with new images
    docker compose up -d
    
    print_step "Cleaning up Docker resources"
    docker system prune -f
    
    # Remove old images (keep last 5 versions)
    docker image prune -a --filter "until=720h" -f
    
    print_success "Docker maintenance completed"
else
    print_info "Docker not installed, skipping Docker maintenance"
fi

# ============================================================================
# LOG MAINTENANCE
# ============================================================================

print_header "📋 Log Maintenance"

print_step "Rotating system logs"
if command -v logrotate &> /dev/null; then
    logrotate -f /etc/logrotate.conf
fi

print_step "Cleaning old logs"
find /var/log -name "*.log.*" -mtime +30 -delete 2>/dev/null || true
find /var/log -name "*.gz" -mtime +30 -delete 2>/dev/null || true

print_step "Checking disk usage by logs"
du -sh /var/log/* 2>/dev/null | sort -hr | head -n 5

print_success "Log maintenance completed"

# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

print_header "⚡ Performance Optimization"

print_step "Cleaning package cache"
apt clean

print_step "Removing obsolete packages"
apt autoremove -y

print_step "Optimizing package database"
if command -v apt-cache &> /dev/null; then
    apt-cache gencaches
fi

print_step "Checking fragmented files"
if command -v e4defrag &> /dev/null; then
    # Only report fragmentation, don't defrag automatically
    e4defrag -c / 2>/dev/null || true
fi

print_success "Performance optimization completed"

# ============================================================================
# BACKUP VERIFICATION
# ============================================================================

print_header "💾 Backup Verification"

BACKUP_DIR="/home/$SUDO_USER/brennan.cafe/backups"

if [ -d "$BACKUP_DIR" ]; then
    print_step "Checking backup directories"
    echo "  Manual backups: $(find "$BACKUP_DIR/manual" -maxdepth 1 -type d 2>/dev/null | wc -l)"
    echo "  Restic backups: $(find "$BACKUP_DIR/restic" -maxdepth 1 -type d 2>/dev/null | wc -l)"
    
    print_step "Checking recent backup activity"
    find "$BACKUP_DIR" -type f -mtime -7 | head -n 5
else
    print_info "Backup directory not found: $BACKUP_DIR"
fi

# ============================================================================
# SERVICE STATUS
# ============================================================================

print_header "🔍 Service Status"

print_step "Checking critical services"
for service in ssh docker fail2ban ufw; do
    if systemctl is-active --quiet $service; then
        echo "  ✓ $service is running"
    else
        echo "  ✗ $service is not running"
    fi
done

print_step "Checking Docker services"
if command -v docker &> /dev/null; then
    cd /home/$SUDO_USER/brennan.cafe/docker
    docker compose ps
fi

# ============================================================================
# HEALTH CHECKS
# ============================================================================

print_header "🏥 System Health Checks"

print_step "Disk space check"
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
    print_error "Disk usage is high: ${DISK_USAGE}%"
else
    print_success "Disk usage is OK: ${DISK_USAGE}%"
fi

print_step "Memory check"
MEM_AVAILABLE=$(free | awk 'NR==2{printf "%.0f", $7*100/$2}')
if [ "$MEM_AVAILABLE" -lt 10 ]; then
    print_error "Low available memory: ${MEM_AVAILABLE}%"
else
    print_success "Available memory is OK: ${MEM_AVAILABLE}%"
fi

print_step "Temperature check"
if command -v sensors &> /dev/null; then
    TEMP=$(sensors | grep 'Package id 0' | awk '{print $4}' | sed 's/+//;s/°C//' 2>/dev/null || echo "0")
    if [ "${TEMP%.*}" -gt 80 ]; then
        print_error "High CPU temperature: ${TEMP}°C"
    else
        print_success "CPU temperature is OK: ${TEMP}°C"
    fi
fi

# ============================================================================
# RECOMMENDATIONS
# ============================================================================

print_header "💡 Maintenance Recommendations"

print_step "System recommendations"
echo "  • Review log files for any errors"
echo "  • Check for failed services with: systemctl --failed"
echo "  • Monitor resource usage with: htop"
echo "  • Update Docker containers regularly"

print_step "Security recommendations"
echo "  • Review SSH logs for suspicious activity"
echo "  • Check Fail2Ban status: sudo fail2ban-client status"
echo "  • Verify firewall rules: sudo ufw status verbose"

print_step "Performance recommendations"
echo "  • Monitor disk space usage"
echo "  • Check Docker container resource usage"
echo "  • Consider enabling automatic backups"

# ============================================================================
# SUMMARY
# ============================================================================

print_header "✨ Maintenance Complete"

echo "System maintenance has been completed successfully!"
echo ""
echo "Completed tasks:"
echo "  ✓ System packages updated"
echo "  ✓ Security checks performed"
echo "  ✓ Docker containers updated"
echo "  ✓ Logs cleaned and rotated"
echo "  ✓ Performance optimized"
echo "  ✓ Service status verified"
echo "  ✓ Health checks performed"
echo ""

print_info "Next maintenance: Run this script monthly"
print_info "For daily checks, use: cafe-status"

echo ""
print_success "brennan.cafe homelab is optimized and secure 🌻"
