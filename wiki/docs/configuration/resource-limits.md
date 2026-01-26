# Resource Limits

Memory and CPU limits for services.

## Overview

Resource limits prevent resource contention and ensure fair resource allocation across all homelab services.

## Resource Allocation Strategy

### Memory Allocation
- **Total Available**: 2GB RAM
- **System Reserved**: 512MB (25%)
- **Services Available**: 1.5GB (75%)
- **Current Usage**: ~900MB (45%)

### CPU Allocation
- **Total Available**: 1 vCPU
- **Shared Across**: All services
- **Priority**: Critical services first

### Storage Allocation
- **Total Available**: 70GB SSD
- **System Usage**: ~10GB
- **Service Data**: ~5GB
- **Available**: ~55GB

## Memory Limits

### Service Categories

#### Lightweight Services (64-128MB)
```yaml
# FileBrowser, Monitor, Linkding
services:
  lightweight_service:
    mem_limit: 128m
    mem_reservation: 64m
    cpus: 0.25
```

#### Standard Services (256MB)
```yaml
# Vikunja, HedgeDoc, Navidrome, WriteFreely, Flarum
services:
  standard_service:
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5
```

#### Heavyweight Services (512MB)
```yaml
# PostgreSQL, Portainer
services:
  heavyweight_service:
    mem_limit: 512m
    mem_reservation: 256m
    cpus: 1.0
```

### Current Service Limits

#### Core Services
```yaml
# Caddy
services:
  caddy:
    mem_limit: 100m
    mem_reservation: 50m
    cpus: 0.25

# PostgreSQL
services:
  postgresql:
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5
```

#### Management Services
```yaml
# Portainer
services:
  portainer:
    mem_limit: 100m
    mem_reservation: 50m
    cpus: 0.25

# Enhanced Monitor
services:
  monitor:
    mem_limit: 50m
    mem_reservation: 30m
    cpus: 0.25

# FileBrowser
services:
  filebrowser:
    mem_limit: 50m
    mem_reservation: 30m
    cpus: 0.25
```

#### Productivity Services
```yaml
# Vikunja
services:
  vikunja:
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5

# HedgeDoc
services:
  hedgedoc:
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5

# Linkding
services:
  linkding:
    mem_limit: 128m
    mem_reservation: 64m
    cpus: 0.25

# Navidrome
services:
  navidrome:
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5
```

#### Phase 4 Services
```yaml
# WriteFreely
services:
  writefreely:
    mem_limit: 128m
    mem_reservation: 64m
    cpus: 0.25

# Flarum
services:
  flarum:
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5

# FreshRSS
services:
  freshrss:
    mem_limit: 128m
    mem_reservation: 64m
    cpus: 0.25
```

## CPU Limits

### CPU Allocation Strategy
```yaml
# Low priority services
cpus: 0.25  # 25% of CPU

# Standard services
cpus: 0.5   # 50% of CPU

# High priority services
cpus: 1.0   # 100% of CPU
```

### CPU Pinning
```yaml
# Pin services to specific CPU cores
services:
  service_name:
    cpus: 0.5
    cpuset: "0"  # Use CPU core 0
```

## Resource Monitoring

### Memory Usage Monitoring
```bash
# Check current memory usage
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Check system memory
free -h

# Check memory by service
docker stats service_name --no-stream
```

### CPU Usage Monitoring
```bash
# Check CPU usage
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}"

# Check system load
uptime

# Check CPU by service
docker stats service_name --no-stream
```

### Resource Alerts
```bash
# Memory usage alert
if [ $(docker stats --no-stream --format "{{.MemPerc}}" service_name | sed 's/%//') -gt 80 ]; then
    echo "High memory usage: service_name"
fi

# CPU usage alert
if [ $(docker stats --no-stream --format "{{.CPUPerc}}" service_name | sed 's/%//') -gt 80 ]; then
    echo "High CPU usage: service_name"
fi
```

## Resource Optimization

### Memory Optimization
```yaml
# Optimize memory usage
services:
  service_name:
    mem_limit: 256m
    mem_reservation: 128m
    environment:
      - JAVA_OPTS=-Xmx128m  # Java applications
      - NODE_OPTIONS=--max-old-space-size=128m  # Node.js applications
```

### CPU Optimization
```yaml
# Optimize CPU usage
services:
  service_name:
    cpus: 0.5
    environment:
      - WORKERS=2  # Limit worker processes
      - MAX_CONNECTIONS=25  # Limit database connections
```

### Database Optimization
```yaml
# PostgreSQL memory optimization
services:
  postgresql:
    mem_limit: 256m
    mem_reservation: 128m
    environment:
      - POSTGRES_SHARED_PRELOAD_LIBRARIES=pg_stat_statements
      - POSTGRES_MAX_CONNECTIONS=100
```

## Resource Scaling

### Vertical Scaling
```bash
# Increase memory limit
docker update service_name --memory=512m

# Increase CPU limit
docker update service_name --cpus=1.0

# Update docker-compose.yml
services:
  service_name:
    mem_limit: 512m
    mem_reservation: 256m
    cpus: 1.0
```

### Horizontal Scaling
```yaml
# Scale services
services:
  service_name:
    image: service:latest
    deploy:
      replicas: 2
    resources:
      limits:
        memory: 256M
        cpus: '0.5'
      reservations:
        memory: 128M
        cpus: '0.25'
```

## Resource Limits Configuration

### Docker Compose Configuration
```yaml
version: '3.8'

services:
  service_name:
    image: service:latest
    container_name: service_name
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
        reservations:
          memory: 128M
          cpus: '0.25'
    environment:
      - SERVICE_ENV=value
    volumes:
      - service_data:/data
    networks:
      - caddy
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Runtime Resource Updates
```bash
# Update memory limit
docker update service_name --memory=512m

# Update CPU limit
docker update service_name --cpus=1.0

# Update both
docker update service_name --memory=512m --cpus=1.0
```

## Resource Troubleshooting

### Memory Issues
```bash
# Check OOM killer events
dmesg | grep -i "oom-killer"

# Check memory usage
docker stats service_name --no-stream

# Check system memory
free -h

# Fix memory issues
docker restart service_name
docker update service_name --memory=512m
```

### CPU Issues
```bash
# Check CPU usage
docker stats service_name --no-stream

# Check system load
uptime

# Fix CPU issues
docker restart service_name
docker update service_name --cpus=1.0
```

### Resource Exhaustion
```bash
# Check resource usage
docker stats --no-stream

# Check system resources
free -h
df -h
uptime

# Fix resource exhaustion
docker system prune -f
docker restart $(docker ps -q)
```

## Resource Planning

### Capacity Planning
```bash
# Current resource usage
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}"

# Resource utilization
free -h
df -h

# Growth projections
echo "Memory usage: $(free -h | awk 'NR==2{print $3}')"
echo "Disk usage: $(df -h | awk 'NR==2{print $5}')"
```

### Scaling Decisions
```bash
# When to scale up
if [ $(free -h | awk 'NR==2{print $3}' | sed 's/M//') -gt 1500 ]; then
    echo "Consider scaling up memory"
fi

# When to optimize
if [ $(docker stats --no-stream --format "{{.MemPerc}}" | awk '{sum+=$2} END {print sum}') -gt 80 ]; then
    echo "Consider optimizing memory usage"
fi
```

## Best Practices

### Resource Management
- Set appropriate memory limits for all services
- Use memory reservations to guarantee resources
- Monitor resource usage regularly
- Set up alerts for resource exhaustion

### Performance Optimization
- Use connection pooling for databases
- Optimize application memory usage
- Use caching where appropriate
- Monitor resource bottlenecks

### Resource Efficiency
- Use lightweight alternatives when possible
- Share resources where appropriate
- Clean up unused resources regularly
- Use resource-efficient configurations

## Getting Help

### Before Reporting Issues
- [ ] Checked resource usage
- [ ] Monitored service performance
- [ ] Verified resource limits
- [ ] Reviewed system logs

### Information to Include
- Resource usage statistics
- Service performance metrics
- Resource limit configuration
- Error messages
- Recent changes
