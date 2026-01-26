# Maintenance

Regular maintenance procedures for the brennan.page homelab.

## Overview

Regular maintenance ensures optimal performance, security, and reliability of all homelab services.

## Maintenance Schedule

### Daily Maintenance
**Time**: 5 minutes  
**Frequency**: Every day

#### System Health Check
```bash
# Quick system health check
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== System Status ==='
  docker ps
  echo -e '\n=== Resource Usage ==='
  free -h | head -2
  df -h | head -2
  echo -e '\n=== Service Health ==='
  curl -I https://brennan.page
"
```

#### Log Review
```bash
# Check for critical errors
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker logs --tail 20 caddy | grep -i error || echo 'No Caddy errors'
  docker logs --tail 20 postgres | grep -i error || echo 'No PostgreSQL errors'
  journalctl -n 50 --no-pager | grep -i error || echo 'No system errors'
"
```

#### Service Health
```bash
# Check critical services
services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page" "wiki.brennan.page")
for service in "${services[@]}"; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "https://$service")
    if [ "$status" != "200" ]; then
        echo "Service down: $service ($status)"
    fi
done
```

### Weekly Maintenance
**Time**: 30 minutes  
**Frequency**: Every Sunday

#### System Updates
```bash
# Check for updates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Checking Updates ==='
  apt update
  apt list --upgradable
"

# Apply updates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Applying Updates ==='
  apt upgrade -y
  docker system prune -f
"
```

#### Docker Maintenance
```bash
# Clean up Docker
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Docker Cleanup ==='
  docker system prune -f
  docker volume prune -f
  docker network prune -f
  docker image prune -f
"

# Update Docker images
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Updating Docker Images ==='
  cd /opt/homelab
  docker compose pull
  docker compose up -d
"
```

#### Database Maintenance
```bash
# PostgreSQL maintenance
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Database Maintenance ==='
  docker exec postgres psql -U homelab -d homelab -c 'VACUUM ANALYZE;'
  docker exec postgres psql -U homelab -d homelab -c 'REINDEX DATABASE homelab;'
"

# Check database sizes
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Database Sizes ==='
  docker exec postgres psql -U homelab -d homelab -c "
    SELECT pg_database.datname, 
           pg_size_pretty(pg_database_size(pg_database.datname)) 
    FROM pg_database.datname;
"
```

#### Backup Verification
```bash
# Check recent backups
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Backup Verification ==='
  ls -la /opt/homelab/backups/databases/ | grep $(date +%Y%m%d)
  du -sh /opt/homelab/backups/
"

# Test backup integrity
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Backup Integrity Test ==='
  for backup in /opt/homelab/backups/databases/*.sql.gz; do
    echo "Testing $backup..."
    gunzip -t "$backup" && echo "OK" || echo "CORRUPTED"
  done
"
```

### Monthly Maintenance
**Time**: 1 hour  
**Frequency**: First Sunday of month

#### Security Audit
```bash
# Check for security updates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Security Audit ==='
  apt list --upgradable | grep -i security
  docker images | grep -v latest
  docker ps --format '{{.Image}}' | sort | uniq -c | sort -nr
"

# Check user accounts
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== User Accounts ==='
  cat /etc/passwd | grep -E '^[^:]*:[0-9]{4,}:'
  last -n 10
"

# Check SSH access
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== SSH Access ==='
  grep 'Accepted' /var/log/auth.log | tail -10
  cat /etc/ssh/sshd_config | grep -E 'PermitRootLogin|PasswordAuthentication'
"
```

#### Performance Optimization
```bash
# System performance
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Performance Review ==='
  free -h
  df -h
  iostat -x 1 3
  docker stats --no-stream
"

# Database performance
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Database Performance ==='
  docker exec postgres psql -U homelab -d homelab -c "
    SELECT query, mean_time, calls 
    FROM pg_stat_statements 
    ORDER BY mean_time DESC 
    LIMIT 10;
"
```

#### Log Rotation
```bash
# Rotate system logs
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Log Rotation ==='
  journalctl --vacuum-time=30d
  find /var/log -name '*.log' -mtime +30 -delete
  find /opt/homelab/logs -name '*.log' -mtime +30 -delete
"

# Rotate Docker logs
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Docker Log Rotation ==='
  for container in \$(docker ps -q); do
    docker logs \$container --tail 1000 > /opt/homelab/logs/\$(docker inspect \$container --format='{{.Name}}')-$(date +%Y%m%d).log
  done
"
```

#### Documentation Update
```bash
# Update service documentation
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Documentation Update ==='
  cd /opt/homelab/wiki
  docker run --rm -v /opt/homelab/wiki:/docs squidfunk/mkdocs-material build
"

# Update system documentation
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== System Documentation ==='
  echo 'Last maintenance: $(date)' > /opt/homelab/docs/maintenance.log
  echo 'System version: $(uname -a)' >> /opt/homelab/docs/maintenance.log
  echo 'Docker version: $(docker --version)' >> /opt/homelab/docs/maintenance.log
"
```

### Quarterly Maintenance
**Time**: 2 hours  
**Frequency**: Every quarter

#### Major Updates
```bash
# System version upgrade
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Major System Update ==='
  do-release-upgrade -f
  reboot
"

# Docker version upgrade
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Docker Upgrade ==='
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  systemctl restart docker
"

# Service major updates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Service Updates ==='
  cd /opt/homelab
  docker compose pull
  docker compose up -d
"
```

#### Capacity Planning
```bash
# Resource usage analysis
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Capacity Planning ==='
  echo 'Memory Usage:'
  free -h
  echo 'Disk Usage:'
  df -h
  echo 'CPU Usage:'
  uptime
  echo 'Docker Usage:'
  docker system df
"

# Growth projections
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Growth Analysis ==='
  echo 'Database Growth:'
  docker exec postgres psql -U homelab -d homelab -c "
    SELECT pg_size_pretty(pg_database_size('homelab'));
  "
  echo 'Log Growth:'
  du -sh /opt/homelab/logs
  echo 'Backup Growth:'
  du -sh /opt/homelab/backups
"
```

#### Disaster Recovery Test
```bash
# Test backup recovery
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Disaster Recovery Test ==='
  # Create test database
  docker exec postgres psql -U homelab -d postgres -c 'CREATE DATABASE test_recovery;'
  
  # Test restore
  docker exec postgres psql -U homelab -d test_recovery < /opt/homelab/backups/postgres-$(date +%Y%m%d).sql
  
  # Verify data
  docker exec postgres psql -U homelab -d test_recovery -c 'SELECT COUNT(*) FROM pg_stat_activity;'
  
  # Clean up
  docker exec postgres psql -U homelab -d postgres -c 'DROP DATABASE test_recovery;'
"
```

## Maintenance Scripts

### Daily Maintenance Script
```bash
#!/bin/bash
# daily-maintenance.sh

echo "Daily Maintenance - $(date)"

# System health check
echo "=== System Health ==="
free -h | grep -E "Mem|Swap"
df -h | grep -E "/$"
uptime

# Docker health
echo -e "\n=== Docker Health ==="
docker ps --format "table {{.Names}}\t{{.Status}}"

# Service health
echo -e "\n=== Service Health ==="
services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page" "wiki.brennan.page")
for service in "${services[@]}"; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "https://$service")
    echo "$service: $status"
done

# Log check
echo -e "\n=== Log Check ==="
docker logs --tail 10 caddy | grep -i error || echo "No Caddy errors"
docker logs --tail 10 postgres | grep -i error || echo "No PostgreSQL errors"

echo "Daily maintenance completed"
```

### Weekly Maintenance Script
```bash
#!/bin/bash
# weekly-maintenance.sh

echo "Weekly Maintenance - $(date)"

# System updates
echo "=== System Updates ==="
apt update
apt list --upgradable
apt upgrade -y

# Docker cleanup
echo -e "\n=== Docker Cleanup ==="
docker system prune -f
docker volume prune -f
docker network prune -f

# Update services
echo -e "\n=== Service Updates ==="
cd /opt/homelab
docker compose pull
docker compose up -d

# Database maintenance
echo -e "\n=== Database Maintenance ==="
docker exec postgres psql -U homelab -d homelab -c 'VACUUM ANALYZE;'

# Backup verification
echo -e "\n=== Backup Verification ==="
ls -la /opt/homelab/backups/databases/ | grep $(date +%Y%m%d)

echo "Weekly maintenance completed"
```

### Monthly Maintenance Script
```bash
#!/bin/bash
# monthly-maintenance.sh

echo "Monthly Maintenance - $(date)"

# Security audit
echo "=== Security Audit ==="
apt list --upgradable | grep -i security
docker images | grep -v latest

# Performance review
echo -e "\n=== Performance Review ==="
free -h
df -h
docker stats --no-stream

# Log rotation
echo -e "\n=== Log Rotation ==="
journalctl --vacuum-time=30d
find /var/log -name "*.log" -mtime +30 -delete

# Documentation update
echo -e "\n=== Documentation Update ==="
cd /opt/homelab/wiki
docker run --rm -v /opt/homelab/wiki:/docs squidfunk/mkdocs-material build

echo "Monthly maintenance completed"
```

## Automation

### Cron Jobs
```bash
# Add to crontab
crontab -e

# Daily maintenance at 2 AM
0 2 * * * /opt/homelab/scripts/daily-maintenance.sh >> /opt/homelab/logs/maintenance.log 2>&1

# Weekly maintenance on Sunday at 3 AM
0 3 * * 0 /opt/homelab/scripts/weekly-maintenance.sh >> /opt/homelab/logs/maintenance.log 2>&1

# Monthly maintenance on first Sunday at 4 AM
0 4 1-7 * 0 [ $(date +\%u) -eq 7 ] /opt/homelab/scripts/monthly-maintenance.sh >> /opt/homelab/logs/maintenance.log 2>&1
```

### Maintenance Dashboard
```bash
#!/bin/bash
# maintenance-dashboard.sh

clear
while true; do
    echo "=== Maintenance Dashboard ==="
    echo "Time: $(date)"
    echo "Last maintenance: $(cat /opt/homelab/docs/maintenance.log | tail -1)"
    echo
    
    # System status
    echo "System Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory: $(free -h | awk 'NR==2{printf "%s/%s", $3, $2}')"
    echo "Disk: $(df / | awk 'NR==2{print $5}')"
    echo
    
    # Service status
    echo "Services:"
    docker ps --format "table {{.Names}}\t{{.Status}}" | head -10
    echo
    
    # Recent maintenance
    echo "Recent Maintenance:"
    tail -5 /opt/homelab/logs/maintenance.log
    echo
    
    sleep 60
    clear
done
```

## Troubleshooting

### Maintenance Issues

#### Update Failures
```bash
# Check update logs
cat /var/log/dpkg.log | tail -20

# Fix broken packages
dpkg --configure -a
apt --fix-broken install

# Clear package cache
apt clean
apt autoremove
```

#### Service Failures
```bash
# Check service logs
docker logs service_name --tail 50

# Restart service
docker restart service_name

# Check resource usage
docker stats service_name
```

#### Backup Issues
```bash
# Check backup logs
tail -20 /opt/homelab/logs/backup.log

# Check disk space
df -h /opt/homelab/backups

# Test backup integrity
gunzip -t /opt/homelab/backups/database.sql.gz
```

## Best Practices

### Maintenance Planning
- Schedule maintenance during low usage periods
- Communicate maintenance windows to users
- Have rollback procedures ready
- Document all maintenance activities

### Safety Measures
- Always backup before making changes
- Test changes in staging environment
- Monitor system during maintenance
- Have emergency contact procedures

### Documentation
- Keep maintenance logs
- Document changes and procedures
- Update system documentation
- Maintain change log

## Getting Help

### Before Reporting Issues
- [ ] Checked maintenance logs
- [ ] Verified system status
- [ ] Attempted basic recovery
- [ ] Reviewed recent changes

### Information to Include
- Maintenance script output
- Error messages
- System status
- Recent changes
- Steps already taken
