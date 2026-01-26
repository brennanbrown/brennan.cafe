#!/usr/bin/env bash

# ============================================================================
# HEALTH CHECK SCRIPT
# ============================================================================
# Description: Monitor brennan.cafe homelab services and system health
# Author: Brennan Kenneth Brown
# Usage: ./health-check.sh [--verbose] [--notify]
# Location: ~/brennan.cafe/scripts/monitoring/health-check.sh
# ============================================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Options
VERBOSE=false
NOTIFY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --notify)
            NOTIFY=true
            shift
            ;;
        *)
            echo "Usage: $0 [--verbose] [--notify]"
            exit 1
            ;;
    esac
done

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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_detail() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}  →${NC} $1"
    fi
}

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

ISSUES_FOUND=0
WARNINGS_FOUND=0
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE="/tmp/brennan-cafe-health-$(date +%Y%m%d).log"

# ============================================================================
# SYSTEM HEALTH CHECKS
# ============================================================================

check_system_health() {
    print_header "🏥 System Health Check"
    
    # CPU Temperature
    if command -v sensors &> /dev/null; then
        TEMP=$(sensors | grep 'Package id 0' | awk '{print $4}' | sed 's/+//;s/°C//' 2>/dev/null || echo "0")
        TEMP_NUM=${TEMP%.*}
        
        if [ "$TEMP_NUM" -gt 85 ]; then
            print_error "High CPU temperature: ${TEMP}°C"
            ((ISSUES_FOUND++))
        elif [ "$TEMP_NUM" -gt 75 ]; then
            print_warning "Elevated CPU temperature: ${TEMP}°C"
            ((WARNINGS_FOUND++))
        else
            print_success "CPU temperature OK: ${TEMP}°C"
        fi
        print_detail "Thermal throttling threshold: 85°C"
    else
        print_warning "Temperature monitoring not available (lm-sensors not installed)"
    fi
    
    # Memory Usage
    MEM_TOTAL=$(free -m | awk 'NR==2{print $2}')
    MEM_USED=$(free -m | awk 'NR==2{print $3}')
    MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
    
    if [ "$MEM_PERCENT" -gt 90 ]; then
        print_error "High memory usage: ${MEM_PERCENT}% (${MEM_USED}MB/${MEM_TOTAL}MB)"
        ((ISSUES_FOUND++))
    elif [ "$MEM_PERCENT" -gt 80 ]; then
        print_warning "Elevated memory usage: ${MEM_PERCENT}%"
        ((WARNINGS_FOUND++))
    else
        print_success "Memory usage OK: ${MEM_PERCENT}% (${MEM_USED}MB/${MEM_TOTAL}MB)"
    fi
    print_detail "Critical threshold: 90%"
    
    # Disk Usage
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
    DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
    
    if [ "$DISK_USAGE" -gt 90 ]; then
        print_error "High disk usage: ${DISK_USAGE}% (${DISK_USED}/${DISK_TOTAL})"
        ((ISSUES_FOUND++))
    elif [ "$DISK_USAGE" -gt 80 ]; then
        print_warning "Elevated disk usage: ${DISK_USAGE}%"
        ((WARNINGS_FOUND++))
    else
        print_success "Disk usage OK: ${DISK_USAGE}% (${DISK_USED}/${DISK_TOTAL})"
    fi
    print_detail "Critical threshold: 90%"
    
    # Load Average
    LOAD_1MIN=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    LOAD_5MIN=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $2}' | sed 's/,//')
    LOAD_15MIN=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $3}')
    
    # Compare load to CPU cores (assuming 4 cores for W520)
    CPU_CORES=4
    LOAD_THRESHOLD=$((CPU_CORES * 2))
    
    if (( $(echo "$LOAD_1MIN > $LOAD_THRESHOLD" | bc -l) )); then
        print_error "High load average: ${LOAD_1MIN} (threshold: ${LOAD_THRESHOLD})"
        ((ISSUES_FOUND++))
    else
        print_success "Load average OK: ${LOAD_1MIN}, ${LOAD_5MIN}, ${LOAD_15MIN}"
    fi
    print_detail "CPU cores: $CPU_CORES, Critical threshold: ${LOAD_THRESHOLD}"
}

# ============================================================================
# SERVICE HEALTH CHECKS
# ============================================================================

check_services() {
    print_header "🔍 Service Health Check"
    
    # System services
    local services=("ssh" "docker" "fail2ban" "ufw" "cloudflared")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            print_success "$service is running"
            print_detail "$(systemctl status "$service" --no-pager -l | head -n 3 | tail -n 1)"
        elif systemctl list-unit-files | grep -q "^$service.service"; then
            print_error "$service is not running"
            ((ISSUES_FOUND++))
            print_detail "Start with: sudo systemctl start $service"
        else
            print_warning "$service is not installed"
            ((WARNINGS_FOUND++))
        fi
    done
    
    # Docker services
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        print_info "Checking Docker containers..."
        
        cd ~/brennan.cafe/docker 2>/dev/null || cd /home/brennan/brennan.cafe/docker 2>/dev/null || true
        
        if docker compose ps &> /dev/null; then
            while IFS= read -r line; do
                if [[ $line == *"Up"* ]]; then
                    local service_name=$(echo "$line" | awk '{print $1}')
                    print_success "$service_name container is running"
                elif [[ $line == *"Exit"* ]] || [[ $line == *"Down"* ]]; then
                    local service_name=$(echo "$line" | awk '{print $1}')
                    print_error "$service_name container is not running"
                    ((ISSUES_FOUND++))
                    print_detail "Restart with: docker compose restart $service_name"
                fi
            done <<< "$(docker compose ps --format 'table {{.Name}}\t{{.Status}}' | tail -n +2)"
        else
            print_warning "Docker Compose not configured"
            ((WARNINGS_FOUND++))
        fi
    else
        print_warning "Docker is not running"
        ((WARNINGS_FOUND++))
    fi
}

# ============================================================================
# NETWORK HEALTH CHECKS
# ============================================================================

check_network() {
    print_header "🌐 Network Health Check"
    
    # Internet connectivity
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_success "Internet connectivity OK"
    else
        print_error "No internet connectivity"
        ((ISSUES_FOUND++))
    fi
    
    # DNS resolution
    if nslookup google.com &> /dev/null; then
        print_success "DNS resolution working"
    else
        print_error "DNS resolution failed"
        ((ISSUES_FOUND++))
    fi
    
    # Cloudflare tunnel (if configured)
    if systemctl is-active --quiet cloudflared 2>/dev/null; then
        print_success "Cloudflare tunnel is running"
        
        # Test tunnel connectivity
        if curl -sf https://brennan.cafe &> /dev/null; then
            print_success "Cloudflare tunnel responding"
        else
            print_warning "Cloudflare tunnel not responding"
            ((WARNINGS_FOUND++))
        fi
    else
        print_warning "Cloudflare tunnel not running"
        ((WARNINGS_FOUND++))
    fi
    
    # Local network interfaces
    print_detail "Network interfaces:"
    if [ "$VERBOSE" = true ]; then
        ip addr show | grep -E "^[0-9]+:" | while read line; do
            echo "  → $line"
        done
    fi
}

# ============================================================================
# SECURITY HEALTH CHECKS
# ============================================================================

check_security() {
    print_header "🔒 Security Health Check"
    
    # Firewall status
    if ufw status | grep -q "Status: active"; then
        print_success "UFW firewall is active"
        
        # Check if essential ports are allowed
        if ufw status | grep -q "22/tcp"; then
            print_success "SSH port (22) is allowed"
        else
            print_error "SSH port not allowed in firewall"
            ((ISSUES_FOUND++))
        fi
        
        if ufw status | grep -q "80/tcp"; then
            print_success "HTTP port (80) is allowed"
        else
            print_warning "HTTP port not allowed in firewall"
            ((WARNINGS_FOUND++))
        fi
    else
        print_error "UFW firewall is not active"
        ((ISSUES_FOUND++))
    fi
    
    # Fail2Ban status
    if systemctl is-active --quiet fail2ban; then
        print_success "Fail2Ban is running"
        
        # Check jail status
        if fail2ban-client status sshd &> /dev/null; then
            local banned_count=$(fail2ban-client status sshd | grep "Currently banned:" | awk '{print $3}')
            print_detail "SSH jail: $banned_count IPs currently banned"
        fi
    else
        print_error "Fail2Ban is not running"
        ((ISSUES_FOUND++))
    fi
    
    # SSH configuration
    if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null || \
       grep -q "PasswordAuthentication no" /etc/ssh/sshd_config.d/* 2>/dev/null; then
        print_success "SSH password authentication disabled"
    else
        print_warning "SSH password authentication may be enabled"
        ((WARNINGS_FOUND++))
    fi
    
    # Recent failed login attempts
    local failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | grep "$(date '+%b %d')" | wc -l || echo "0")
    if [ "$failed_logins" -gt 10 ]; then
        print_warning "High number of failed SSH attempts today: $failed_logins"
        ((WARNINGS_FOUND++))
    else
        print_success "SSH login attempts normal: $failed_logins today"
    fi
}

# ============================================================================
# BACKUP HEALTH CHECKS
# ============================================================================

check_backups() {
    print_header "💾 Backup Health Check"
    
    local backup_dir="$HOME/brennan.cafe/backups"
    
    if [ -d "$backup_dir" ]; then
        # Manual backups
        local manual_count=$(find "$backup_dir/manual" -maxdepth 1 -type d 2>/dev/null | wc -l)
        if [ "$manual_count" -gt 1 ]; then
            print_success "Manual backups available: $((manual_count-1)) directories"
            
            # Check most recent backup
            local latest_backup=$(find "$backup_dir/manual" -maxdepth 1 -type d -name "site-*" 2>/dev/null | sort | tail -n 1)
            if [ -n "$latest_backup" ]; then
                local backup_age=$(find "$latest_backup" -mtime -1 | wc -l)
                if [ "$backup_age" -gt 0 ]; then
                    print_success "Recent backup found (last 24 hours)"
                else
                    print_warning "No recent backups (older than 24 hours)"
                    ((WARNINGS_FOUND++))
                fi
            fi
        else
            print_warning "No manual backups found"
            ((WARNINGS_FOUND++))
        fi
        
        # Restic backups (if configured)
        if [ -d "$backup_dir/restic" ]; then
            print_info "Restic backup directory exists"
            # Could add restic snapshot checks here
        fi
    else
        print_warning "Backup directory not found: $backup_dir"
        ((WARNINGS_FOUND++))
    fi
}

# ============================================================================
# PERFORMANCE HEALTH CHECKS
# ============================================================================

check_performance() {
    print_header "⚡ Performance Health Check"
    
    # Docker container resource usage
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        print_info "Docker container resource usage:"
        
        while IFS= read -r line; do
            if [[ $line == *"%"* ]] && [[ $line != *"CONTAINER"* ]]; then
                local container=$(echo "$line" | awk '{print $2}')
                local cpu=$(echo "$line" | awk '{print $3}')
                local mem=$(echo "$line" | awk '{print $4}')
                
                if [[ $cpu == *"%"* ]]; then
                    local cpu_num=${cpu%.*}
                    if [ "$cpu_num" -gt 80 ]; then
                        print_warning "$container: High CPU usage $cpu"
                        ((WARNINGS_FOUND++))
                    fi
                fi
                
                if [[ $mem == *"%"* ]]; then
                    local mem_num=${mem%.*}
                    if [ "$mem_num" -gt 80 ]; then
                        print_warning "$container: High memory usage $mem"
                        ((WARNINGS_FOUND++))
                    fi
                fi
                
                if [ "$VERBOSE" = true ]; then
                    print_detail "$container: CPU $cpu, Memory $mem"
                fi
            fi
        done <<< "$(docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}')"
    fi
    
    # Disk I/O (if iostat is available)
    if command -v iostat &> /dev/null; then
        local io_wait=$(iostat -x 1 1 | grep -E "Device|sd[a-z]" | tail -n +2 | awk '{sum+=$10} END {printf "%.1f", sum/NR}')
        print_detail "Average I/O wait: ${io_wait}%"
        
        if (( $(echo "$io_wait > 20" | bc -l) )); then
            print_warning "High I/O wait: ${io_wait}%"
            ((WARNINGS_FOUND++))
        fi
    fi
}

# ============================================================================
# SUMMARY AND REPORTING
# ============================================================================

generate_summary() {
    print_header "📊 Health Check Summary"
    
    echo "Health check completed at: $TIMESTAMP"
    echo ""
    
    if [ "$ISSUES_FOUND" -eq 0 ] && [ "$WARNINGS_FOUND" -eq 0 ]; then
        print_success "All systems healthy! 🌻"
        echo "No issues or warnings detected."
    else
        echo "Issues found: $ISSUES_FOUND"
        echo "Warnings found: $WARNINGS_FOUND"
        echo ""
        
        if [ "$ISSUES_FOUND" -gt 0 ]; then
            print_error "Critical issues require immediate attention"
        fi
        
        if [ "$WARNINGS_FOUND" -gt 0 ]; then
            print_warning "Warnings should be reviewed soon"
        fi
    fi
    
    # Log results
    {
        echo "=== brennan.cafe Health Check Report ==="
        echo "Timestamp: $TIMESTAMP"
        echo "Issues: $ISSUES_FOUND"
        echo "Warnings: $WARNINGS_FOUND"
        echo ""
        echo "Full log details available with: --verbose flag"
    } >> "$LOG_FILE"
    
    # Notification (if requested)
    if [ "$NOTIFY" = true ]; then
        if [ "$ISSUES_FOUND" -gt 0 ]; then
            notify-send "brennan.cafe Health Alert" "$ISSUES_FOUND critical issues found" -u critical
        elif [ "$WARNINGS_FOUND" -gt 0 ]; then
            notify-send "brennan.cafe Health Warning" "$WARNINGS_FOUND warnings found" -u normal
        else
            notify-send "brennan.cafe Health Check" "All systems healthy" -u low
        fi
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo "🌻 brennan.cafe Homelab Health Check"
    echo "Started at: $TIMESTAMP"
    echo ""
    
    check_system_health
    check_services
    check_network
    check_security
    check_backups
    check_performance
    generate_summary
    
    echo ""
    if [ "$ISSUES_FOUND" -gt 0 ]; then
        exit 1
    elif [ "$WARNINGS_FOUND" -gt 0 ]; then
        exit 2
    else
        exit 0
    fi
}

# Run main function
main
