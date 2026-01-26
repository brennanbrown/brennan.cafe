# Docker

Docker is the container runtime platform that hosts all services in the brennan.page homelab.

## Overview

Docker provides containerization for all services, ensuring isolation, portability, and efficient resource utilization.

## Installation

Docker and Docker Compose are installed on Ubuntu 24.04 LTS:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Configuration

### Docker Daemon
The Docker daemon is configured with:
- **Logging**: JSON format with rotation
- **Storage**: Default overlay2 driver
- **Network**: Bridge networking with custom networks

### Resource Limits
All containers have resource limits defined:
- **Memory**: Limits and reservations per service
- **CPU**: Shares allocated based on priority
- **Storage**: Volume mounts for persistence

## Networks

### Custom Networks

#### caddy Network
```yaml
networks:
  caddy:
    external: true
    driver: bridge
```
- **Purpose**: External web access via Caddy
- **Services**: All web-facing services
- **Security**: Controlled access to internet

#### internal_db Network
```yaml
networks:
  internal_db:
    external: true
    driver: bridge
    internal: true
```
- **Purpose**: Database communication
- **Services**: PostgreSQL and connected services
- **Security**: Isolated from external access

#### monitoring Network
```yaml
networks:
  monitoring:
    external: true
    driver: bridge
```
- **Purpose**: Service monitoring
- **Services**: Monitoring tools
- **Security**: Limited monitoring access

## Volumes

### Data Persistence
Critical data is stored in Docker volumes:

#### Database Volumes
- `postgresql_postgres_data`: PostgreSQL data
- Automatic backup to host system

#### Application Volumes
- `vikunja_vikunja_files`: Vikunja file uploads
- `hedgedoc_hedgedoc_uploads`: HedgeDoc uploads
- `linkding_linkding_data`: Linkding data
- `navidrome_navidrome_*`: Navidrome data, cache, music

#### Configuration Volumes
- `caddy_data`: SSL certificates and configuration
- Service-specific configuration mounts

## Container Management

### Docker Compose Structure
Each service has its own `docker-compose.yml`:

```yaml
version: '3.8'

services:
  service_name:
    image: image:tag
    container_name: container_name
    restart: unless-stopped
    environment:
      - ENV_VAR=value
    volumes:
      - volume:/path
    networks:
      - network_name
    mem_limit: 256m
    mem_reservation: 128m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Common Patterns

#### Resource Management
```yaml
mem_limit: 256m      # Maximum memory
mem_reservation: 128m  # Guaranteed memory
```

#### Logging
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"   # Max log file size
    max-file: "3"     # Number of log files
```

#### Health Checks
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## Operations

### Common Commands

#### Container Management
```bash
# List all containers
docker ps

# Show container logs
docker logs container_name

# Restart container
docker restart container_name

# Execute command in container
docker exec -it container_name bash
```

#### Resource Monitoring
```bash
# Show resource usage
docker stats

# Show detailed container info
docker inspect container_name
```

#### Image Management
```bash
# List images
docker images

# Pull latest image
docker pull image:tag

# Remove unused images
docker image prune
```

#### Volume Management
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect volume_name

# Backup volume
docker run --rm -v volume:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .
```

### Service Deployment

#### Single Service
```bash
cd /opt/homelab/services/service_name
docker compose up -d
```

#### Multiple Services
```bash
# Deploy all services
cd /opt/homelab
docker compose up -d

# Deploy specific services
docker compose up -d service1 service2
```

#### Updates
```bash
# Pull latest images
docker compose pull

# Restart with new images
docker compose up -d
```

## Security

### Container Security
- **Non-root users**: Services run as non-root where possible
- **Read-only filesystems**: Where applicable
- **Resource limits**: Prevent resource exhaustion
- **Network isolation**: Services isolated by network

### Image Security
- **Official images**: Use official images when possible
- **Specific tags**: Pin to specific versions
- **Regular updates**: Keep images updated
- **Vulnerability scanning**: Regular security scans

### Runtime Security
- **Docker socket**: Limited access to Docker socket
- **Privileged containers**: Avoid privileged containers
- **Host networking**: Avoid host networking where possible

## Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker logs container_name

# Check resource usage
docker stats

# Check disk space
df -h
```

#### Network Issues
```bash
# Check network connectivity
docker exec container1 ping container2

# List networks
docker network ls

# Inspect network
docker network inspect network_name
```

#### Volume Issues
```bash
# List volumes
docker volume ls

# Check volume mounts
docker inspect container_name | grep Mounts
```

#### Resource Issues
```bash
# Check resource limits
docker inspect container_name | grep -i memory

# Monitor resource usage
docker stats container_name
```

### Performance Optimization

#### Memory Usage
- Monitor memory usage with `docker stats`
- Adjust memory limits based on usage
- Use memory reservations for critical services

#### Disk Usage
- Regular cleanup of unused images and containers
- Monitor volume sizes
- Implement log rotation

#### Network Performance
- Use appropriate network drivers
- Monitor network bandwidth
- Optimize container communication

## Best Practices

### Development Workflow
1. **Local Development**: Test configurations locally
2. **Version Control**: Commit changes to Git
3. **Staging**: Deploy to staging environment
4. **Production**: Deploy to production with monitoring

### Configuration Management
- Use environment variables for configuration
- Store secrets in mounted files or Docker secrets
- Version control configuration files
- Document configuration changes

### Monitoring and Alerting
- Monitor container resource usage
- Set up alerts for container failures
- Log aggregation and analysis
- Regular health checks

### Backup and Recovery
- Regular volume backups
- Configuration backups
- Disaster recovery procedures
- Test recovery procedures regularly

## Integration

### With Caddy
- Caddy reverse proxies to containers
- SSL termination at Caddy level
- Load balancing for multiple instances

### With PostgreSQL
- Database containers with persistent storage
- Connection pooling via application layer
- Regular database backups

### With Monitoring
- Container health checks
- Resource usage monitoring
- Log aggregation and analysis

## References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
