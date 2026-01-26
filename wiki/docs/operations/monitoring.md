# Monitoring

System and service monitoring for the brennan.page homelab.

## Overview

Monitoring ensures optimal performance, availability, and security of all homelab services.

## Monitoring Stack

### Components
- **Enhanced Monitor Dashboard**: Real-time system monitoring with visual progress bars
- **Docker**: Container monitoring and resource tracking
- **Caddy**: Web server monitoring and SSL certificate management
- **PostgreSQL**: Database monitoring and performance metrics
- **Custom Scripts**: Service-specific health checks and automation

### Monitoring Tools
- **Web Interface**: https://monitor.brennan.page (enhanced dashboard)
- **CLI Tools**: Docker commands, system utilities, health checks
- **Log Analysis**: Centralized log monitoring and error tracking
- **Alerting**: Automated alerts for critical issues and service downtime

## System Monitoring

### Resource Monitoring
```bash
# System overview
htop

# Memory usage
free -h

# Disk usage
df -h

# CPU usage
top

# Process monitoring
ps aux

# Network monitoring
netstat -tulpn
```

### Docker Monitoring
```bash
# Container status
docker ps

# Resource usage
docker stats --no-stream

# Container logs
docker logs container_name

# Container health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}"

# Disk usage by containers
docker system df
```

### Service Health Checks
```bash
# Check all 11 services
services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page" "wiki.brennan.page" "tasks.brennan.page" "notes.brennan.page" "bookmarks.brennan.page" "music.brennan.page" "blog.brennan.page" "forum.brennan.page" "rss.brennan.page")
for service in "${services[@]}"; do
    echo "Checking $service..."
    curl -s -o /dev/null -w "%{http_code} $service\n" "https://$service"
done

# Check response times with enhanced monitoring
for service in "${services[@]}"; do
    echo "Testing $service..."
    response_time=$(curl -w "%{time_total}" -o /dev/null -s "https://$service")
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$service")
    echo "$service: ${status_code} (${response_time}s)"
done
```

## Database Monitoring

### PostgreSQL Monitoring
```bash
# Connection count
docker exec postgres psql -U homelab -d homelab -c "SELECT count(*) FROM pg_stat_activity;"

# Database size
docker exec postgres psql -U homelab -d homelab -c "
  SELECT pg_database.datname, 
         pg_size_pretty(pg_database_size(pg_database.datname)) 
  FROM pg_database.datname;
"

# Slow queries
docker exec postgres psql -U homelab -d homelab -c "
  SELECT query, mean_time, calls 
  FROM pg_stat_statements 
  ORDER BY mean_time DESC 
  LIMIT 10;
"

# Database performance
docker exec postgres psql -U homelab -d homelab -c "
  SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit
  FROM pg_stat_database 
  WHERE datname = 'homelab';
"
```

### MariaDB Monitoring
```bash
# Connection status
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "SHOW STATUS LIKE 'Connections';"

# Database size
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "
  SELECT table_schema, 
         ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
  FROM information_schema.tables 
  GROUP BY table_schema;
"

# Slow queries
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;"
```

## Service Monitoring

### Web Service Monitoring
```bash
# HTTP status checks
curl -I https://service.brennan.page

# Response time monitoring
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://service.brennan.page

# SSL certificate monitoring
openssl s_client -connect service.brennan.page:443 -servername service.brennan.page

# DNS resolution monitoring
nslookup service.brennan.page
```

### Application Monitoring
```bash
# Service-specific health checks
curl -f https://tasks.brennan.page/api/v1/tasks
curl -f https://notes.brennan.page/
curl -f https://bookmarks.brennan.page/
curl -f https://music.brennan.page/music/app/

# API endpoint monitoring
curl -X GET https://service.brennan.page/api/health
curl -X POST https://service.brennan.page/api/test
```

## Log Monitoring

### System Logs
```bash
# System logs
journalctl -n 100 --no-pager

# Service logs
journalctl -u docker -n 100 --no-pager

# Error logs
journalctl -p err -n 50 --no-pager

# Boot logs
journalctl -b -n 100 --no-pager
```

### Docker Logs
```bash
# All container logs
docker logs --tail 100

# Specific container logs
docker logs container_name --tail 100

# Follow logs
docker logs -f container_name

# Error logs
docker logs container_name | grep -i error
```

### Application Logs
```bash
# Service-specific logs
docker logs vikunja --tail 50 | grep -i error
docker logs hedgedoc --tail 50 | grep -i error
docker logs linkding --tail 50 | grep -i error
docker logs navidrome --tail 50 | grep -i error
```

## Performance Monitoring

### Resource Usage
```bash
# Memory usage by service
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}"

# CPU usage
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}"

# Network usage
docker stats --no-stream --format "table {{.Container}}\t{{.NetIO}}"

# Block I/O
docker stats --no-stream --format "table {{.Container}}\t{{.BlockIO}}"
```

### Performance Metrics
```bash
# System load
uptime

# Disk I/O
iostat -x 1

# Network I/O
iftop -t

# Memory pressure
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree"
```

## Monitoring Scripts

### Health Check Script
```bash
#!/bin/bash
# health-check.sh

# System health
echo "=== System Health ==="
free -h | grep -E "Mem|Swap"
df -h | grep -E "/$"
uptime

# Docker health
echo -e "\n=== Docker Health ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}"

# Service health
echo -e "\n=== Service Health ==="
services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page" "wiki.brennan.page" "tasks.brennan.page" "notes.brennan.page" "bookmarks.brennan.page" "music.brennan.page" "blog.brennan.page" "forum.brennan.page" "rss.brennan.page")
for service in "${services[@]}"; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "https://$service")
    echo "$service: $status"
done

# Database health
echo -e "\n=== Database Health ==="
docker exec postgres psql -U homelab -d homelab -c "SELECT count(*) FROM pg_stat_activity;"
```

### Performance Monitor Script
```bash
#!/bin/bash
# performance-monitor.sh

# Resource usage
echo "=== Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}\t{{.NetIO}}"

# System load
echo -e "\n=== System Load ==="
uptime
free -h
df -h

# Database performance
echo -e "\n=== Database Performance ==="
docker exec postgres psql -U homelab -d homelab -c "
  SELECT datname, numbackends, xact_commit, xact_rollback
  FROM pg_stat_database 
  WHERE datname = 'homelab';
"
```

### Alert Script
```bash
#!/bin/bash
# alert.sh

# Check for critical issues
issues=0

# Check system load
load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
if (( $(echo "$load > 2.0" | bc -l) )); then
    echo "High system load: $load"
    issues=$((issues + 1))
fi

# Check memory usage
mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ "$mem_usage" -gt 80 ]; then
    echo "High memory usage: ${mem_usage}%"
    issues=$((issues + 1))
fi

# Check disk usage
disk_usage=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 80 ]; then
    echo "High disk usage: ${disk_usage}%"
    issues=$((issues + 1))
fi

# Check service status (all 11 services)
services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page" "wiki.brennan.page" "tasks.brennan.page" "notes.brennan.page" "bookmarks.brennan.page" "music.brennan.page" "blog.brennan.page" "forum.brennan.page" "rss.brennan.page")
for service in "${services[@]}"; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "https://$service")
    if [ "$status" != "200" ]; then
        echo "Service down: $service ($status)"
        issues=$((issues + 1))
    fi
done

# Send alert if issues found
if [ "$issues" -gt 0 ]; then
    echo "Total issues: $issues" | mail -s "Homelab Alert" admin@brennan.page
fi
```

## Monitoring Dashboard

### Enhanced Dashboard Features
The enhanced monitoring dashboard at https://monitor.brennan.page provides:
- **Real-time Metrics**: Live system resource usage with visual progress bars
- **Service Health**: Automated status checks for all 11 services
- **Performance Monitoring**: Response time tracking and error reporting
- **Interactive Interface**: Modern responsive design with manual refresh
- **Comprehensive Stats**: Memory, disk, CPU, network, and Docker metrics

### Dashboard Access
- **URL**: https://monitor.brennan.page
- **Auto-refresh**: Every 30 seconds
- **Manual Refresh**: Available via refresh button
- **Mobile Friendly**: Responsive design for all devices

### Custom Monitoring Script
```bash
# Enhanced monitoring dashboard script
# /opt/homelab/monitoring/dashboard.sh

#!/bin/bash
clear
while true; do
    echo "=== Enhanced Homelab Monitor ==="
    echo "Time: $(date)"
    echo "Dashboard: https://monitor.brennan.page"
    echo
    
    # System status
    echo "System Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory: $(free -h | awk 'NR==2{printf "%s/%s", $3, $2}')"
    echo "Disk: $(df / | awk 'NR==2{print $5}')"
    echo
    
    # Docker status
    echo "Docker Services:"
    docker ps --format "table {{.Names}}\t{{.Status}}" | head -15
    echo
    
    # Service status (all 11 services)
    echo "Web Services:"
    services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page" "wiki.brennan.page" "tasks.brennan.page" "notes.brennan.page" "bookmarks.brennan.page" "music.brennan.page" "blog.brennan.page" "forum.brennan.page" "rss.brennan.page")
    for service in "${services[@]}"; do
        status=$(curl -s -o /dev/null -w "%{http_code}" "https://$service")
        echo "$service: $status"
    done
    echo
    
    sleep 30
    clear
done
```

## Alerting

### Alert Configuration
```bash
# Email alerts
echo "Subject: Homelab Alert" | sendmail admin@brennan.page

# Slack alerts
curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"Homelab Alert"}' \
    https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK

# Push notifications
# Configure push notification service
```

### Alert Rules
```bash
# High CPU usage
if [ "$(docker stats --no-stream --format "{{.CPUPerc}}" container_name | sed 's/%//')" -gt 80 ]; then
    echo "High CPU usage on container_name"
fi

# High memory usage
if [ "$(docker stats --no-stream --format "{{.MemPerc}}" container_name | sed 's/%//')" -gt 80 ]; then
    echo "High memory usage on container_name"
fi

# Service down
if ! curl -f https://service.brennan.page > /dev/null 2>&1; then
    echo "Service down: service.brennan.page"
fi
```

## Getting Help

### Before Reporting Issues
- [ ] Checked monitoring dashboard
- [ ] Reviewed system metrics
- [ ] Checked service logs
- [ ] Verified alert configuration

### Information to Include
- Monitoring dashboard screenshots
- System metrics
- Error messages
- Recent changes
- Alert history
