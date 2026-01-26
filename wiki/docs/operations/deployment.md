# Deployment

Service deployment and update procedures.

## Overview

Deployment involves creating, updating, and managing services in the homelab environment.

## Deployment Process

### Pre-Deployment Checklist
- [ ] Review service requirements
- [ ] Check resource availability
- [ ] Backup current configuration
- [ ] Test in staging environment
- [ ] Plan rollback procedure

### Service Deployment

#### New Service Deployment
```bash
# Create service directory
mkdir -p /opt/homelab/services/new_service
cd /opt/homelab/services/new_service

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  new_service:
    image: image:tag
    container_name: new_service
    restart: unless-stopped
    environment:
      - ENV_VAR=value
    volumes:
      - new_service_data:/data
    networks:
      - caddy
    mem_limit: 256m
    mem_reservation: 128m

networks:
  caddy:
    external: true

volumes:
  new_service_data:
    driver: local
EOF

# Deploy service
docker compose up -d

# Verify deployment
docker ps | grep new_service
curl -I https://new_service.brennan.page
```

#### Service Update
```bash
# Navigate to service directory
cd /opt/homelab/services/service_name

# Pull new image
docker compose pull

# Update service
docker compose up -d

# Verify update
docker ps | grep service_name
curl -I https://service.brennan.page
```

#### Service Rollback
```bash
# Navigate to service directory
cd /opt/homelab/services/service_name

# Check current image
docker images | grep service_name

# Rollback to previous version
docker compose pull image:previous_tag
docker compose up -d

# Verify rollback
docker ps | grep service_name
```

## Configuration Management

### Environment Variables
```yaml
# Common environment variables
environment:
  - SERVICE_URL=https://service.brennan.page
  - DB_HOST=postgresql
  - DB_USER=service_user
  - DB_PASSWORD=service_password
  - DB_DATABASE=service_db
```

### Resource Limits
```yaml
# Memory limits
mem_limit: 256m
mem_reservation: 128m

# CPU limits
cpus: 0.5
```

### Volume Management
```yaml
# Data volumes
volumes:
  - service_data:/data
  - service_config:/config
  - service_logs:/logs
```

## Network Configuration

### Service Networks
```yaml
# External networks
networks:
  caddy:
    external: true
  internal_db:
    external: true

# Internal networks
networks:
  service_network:
    driver: bridge
```

### Port Configuration
```yaml
# Port mapping (only if needed)
ports:
  - "8080:80"  # Only for direct access
```

## Health Checks

### Health Check Configuration
```yaml
# Health check
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:80/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Health Monitoring
```bash
# Check service health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}"

# Check health endpoint
curl -f https://service.brennan.page/health
```

## Service Dependencies

### Database Dependencies
```yaml
# Database dependency
depends_on:
  postgresql:
    condition: service_healthy
```

### Service Dependencies
```yaml
# Service dependency
depends_on:
  - postgresql
  - caddy
```

## Deployment Automation

### Deployment Script
```bash
#!/bin/bash
# deploy-service.sh

SERVICE_NAME=$1
SERVICE_DIR="/opt/homelab/services/$SERVICE_NAME"

# Check if service exists
if [ ! -d "$SERVICE_DIR" ]; then
    echo "Service directory not found: $SERVICE_DIR"
    exit 1
fi

# Backup current configuration
cd "$SERVICE_DIR"
cp docker-compose.yml docker-compose.yml.backup

# Pull new image
echo "Pulling new image..."
docker compose pull

# Update service
echo "Updating service..."
docker compose up -d

# Verify deployment
echo "Verifying deployment..."
sleep 10
if docker ps | grep -q "$SERVICE_NAME"; then
    echo "Deployment successful"
else
    echo "Deployment failed, rolling back..."
    docker compose down
    cp docker-compose.yml.backup docker-compose.yml
    docker compose up -d
fi
```

### Update Script
```bash
#!/bin/bash
# update-all-services.sh

# Update all services
for service in /opt/homelab/services/*/; do
    if [ -f "$service/docker-compose.yml" ]; then
        service_name=$(basename "$service")
        echo "Updating $service_name..."
        cd "$service"
        docker compose pull
        docker compose up -d
    fi
done

# Verify all services
docker ps
```

## Troubleshooting

### Common Deployment Issues

#### Image Pull Failures
```bash
# Check image availability
docker pull image:tag

# Check Docker Hub status
curl -I https://hub.docker.com

# Use alternative registry
docker pull registry.example.com/image:tag
```

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :port

# Change port in docker-compose.yml
ports:
  - "8081:80"  # Use different port
```

#### Resource Issues
```bash
# Check resource usage
docker stats --no-stream

# Increase memory limit
docker update service_name --memory=512m
```

#### Network Issues
```bash
# Check network connectivity
docker exec service_name ping postgresql

# Check network configuration
docker network ls
docker network inspect network_name
```

### Deployment Verification

#### Service Status
```bash
# Check service status
docker ps | grep service_name

# Check service logs
docker logs service_name --tail 20
```

#### Functionality Tests
```bash
# Test service endpoint
curl -I https://service.brennan.page

# Test service functionality
curl -X POST https://service.brennan.page/api/test
```

#### Integration Tests
```bash
# Test database connectivity
docker exec service_name ping postgresql

# Test network connectivity
docker exec caddy curl -f http://service_name:port
```

## Best Practices

### Security
- Use non-root users
- Limit resource usage
- Use read-only filesystems where possible
- Keep secrets in environment variables

### Performance
- Set appropriate memory limits
- Use health checks
- Monitor resource usage
- Optimize database queries

### Reliability
- Use restart policies
- Implement health checks
- Monitor service logs
- Plan for failures

## Getting Help

### Before Reporting Issues
- [ ] Checked service logs
- [ ] Verified configuration
- [ ] Tested connectivity
- [ ] Attempted basic restart

### Information to Include
- Service name and version
- Docker compose configuration
- Error messages
- System status
- Recent changes
