# Docker Commands

This reference covers essential Docker commands for managing the brennan.page homelab infrastructure.

## Container Management

### Basic Container Operations

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start a container
docker start container_name

# Stop a container
docker stop container_name

# Restart a container
docker restart container_name

# Remove a container
docker rm container_name

# Force remove a running container
docker rm -f container_name
```

### Container Information

```bash
# View container logs
docker logs container_name

# View last 50 lines of logs
docker logs --tail 50 container_name

# Follow logs in real-time
docker logs -f container_name

# View container details
docker inspect container_name

# View container resource usage
docker stats container_name

# Execute command in container
docker exec -it container_name bash
```

## Image Management

### Image Operations

```bash
# List images
docker images

# Pull an image
docker pull image_name:tag

# Build an image
docker build -t image_name:tag /path/to/Dockerfile

# Remove an image
docker rmi image_name:tag

# Remove unused images
docker image prune

# Remove all unused images
docker image prune -a
```

### Image Information

```bash
# View image history
docker history image_name:tag

# Inspect image
docker inspect image_name:tag

# Search for images
docker search search_term
```

## Volume Management

### Volume Operations

```bash
# List volumes
docker volume ls

# Create a volume
docker volume create volume_name

# Remove a volume
docker volume rm volume_name

# Remove unused volumes
docker volume prune

# Inspect volume
docker volume inspect volume_name
```

### Volume Usage

```bash
# Backup a volume
docker run --rm -v volume_name:/source -v $(pwd):/backup alpine tar czf /backup/volume-backup.tar.gz -C /source .

# Restore a volume
docker run --rm -v volume_name:/target -v $(pwd):/backup alpine tar xzf /backup/volume-backup.tar.gz -C /target
```

## Network Management

### Network Operations

```bash
# List networks
docker network ls

# Create a network
docker network create network_name

# Remove a network
docker network rm network_name

# Connect container to network
docker network connect network_name container_name

# Disconnect container from network
docker network disconnect network_name container_name

# Inspect network
docker network inspect network_name
```

### Network Configuration

```bash
# Create bridge network with subnet
docker network create --driver bridge --subnet=192.168.0.0/24 network_name

# List containers in network
docker network inspect network_name | jq '.[0].Containers'
```

## Docker Compose

### Basic Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart services
docker compose restart

# View logs
docker compose logs

# View logs for specific service
docker compose logs service_name

# Follow logs
docker compose logs -f

# Rebuild services
docker compose up -d --build

# Pull latest images
docker compose pull

# Remove stopped containers
docker compose down --remove-orphans
```

### Configuration Management

```bash
# Validate compose file
docker compose config

# View configuration
docker compose config --services

# View environment variables
docker compose config --resolve-hash-vars
```

## Resource Management

### Resource Limits

```bash
# View resource usage
docker stats

# View resource usage for specific container
docker stats container_name

# View resource usage with no stream
docker stats --no-stream

# Monitor resource usage continuously
watch docker stats
```

### Cleanup Operations

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Remove all unused resources
docker system prune -a
```

## System Information

### Docker System

```bash
# View Docker system information
docker system info

# View Docker disk usage
docker system df

# View Docker events
docker events

# View Docker version
docker version

# View Docker info
docker info
```

### Service Status

```bash
# Check Docker daemon status
systemctl status docker

# Start Docker daemon
systemctl start docker

# Stop Docker daemon
systemctl stop docker

# Restart Docker daemon
systemctl restart docker
```

## Troubleshooting Commands

### Container Issues

```bash
# Check if container is running
docker ps | grep container_name

# Check container exit code
docker ps -a | grep container_name

# View container logs for errors
docker logs container_name | grep -i error

# Check container resource usage
docker stats container_name

# Inspect container for configuration issues
docker inspect container_name | grep -A 10 -B 10 "Error\|Failed"
```

### Network Issues

```bash
# Check container network connectivity
docker exec container_name ping google.com

# Check port mapping
docker port container_name

# Check network configuration
docker network inspect network_name

# Test DNS resolution
docker exec container_name nslookup google.com
```

### Volume Issues

```bash
# Check volume mounts
docker inspect container_name | grep -A 10 -B 10 "Mounts"

# Check volume permissions
docker exec container_name ls -la /path/to/mount

# Check disk space
docker exec container_name df -h
```

## Performance Optimization

### Resource Optimization

```bash
# Set memory limit
docker run -m 512m image_name

# Set CPU limit
docker run --cpus="0.5" image_name

# View resource usage history
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Image Optimization

```bash
# Use multi-stage builds
# Example Dockerfile
FROM node:alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]
```

## Security Commands

### Security Scanning

```bash
# Scan image for vulnerabilities
docker scan image_name

# View image security details
docker inspect image_name | grep -A 10 -B 10 "Security"

# Check container user
docker exec container_name whoami

# Check container privileges
docker inspect container_name | grep -A 10 -B 10 "Privileged"
```

### Access Control

```bash
# Run as non-root user
docker run --user 1000:1000 image_name

# Read-only filesystem
docker run --read-only image_name

# Drop capabilities
docker run --cap-drop ALL image_name

# Add specific capabilities
docker run --cap-add NET_ADMIN image_name
```

## Backup and Recovery

### Container Backup

```bash
# Export container
docker export container_name > container_backup.tar

# Import container
docker import container_backup.tar new_image_name

# Commit container state
docker commit container_name new_image_name
```

### Data Backup

```bash
# Backup database container
docker exec postgres_container pg_dump -U username database > backup.sql

# Backup application data
docker exec app_container tar czf /backup/app_data.tar.gz /app/data

# Copy files from container
docker cp container_name:/path/to/file ./local_file
```

## Monitoring and Logging

### Log Management

```bash
# Configure log rotation
# In docker-compose.yml:
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"

# View log configuration
docker inspect container_name | grep -A 10 -B 10 "LogConfig"
```

### Health Checks

```bash
# Define health check in Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# View health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Check health details
docker inspect container_name | grep -A 10 -B 10 "Health"
```

## Common Patterns

### Development Workflow

```bash
# Build and run development container
docker build -t app:dev .
docker run -p 3000:3000 -v $(pwd):/app app:dev

# Watch for changes and rebuild
docker run -p 3000:3000 -v $(pwd):/app app:dev npm run dev
```

### Production Deployment

```bash
# Deploy with environment variables
docker run -d \
  --name production_app \
  -e NODE_ENV=production \
  -e DATABASE_URL=postgresql://user:pass@db:5432/db \
  -p 80:3000 \
  app:latest

# Scale services
docker compose up -d --scale app=3
```

## Integration with Homelab

### Service Management

```bash
# Deploy homelab service
cd /opt/homelab/services/service_name
docker compose up -d

# Check service status
docker compose ps

# Update service
docker compose pull
docker compose up -d

# Backup service data
./scripts/backup-service.sh service_name
```

### Monitoring

```bash
# Check all homelab services
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Monitor resource usage
docker stats --format "table {{.Names}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# View service logs
docker compose logs -f
```

## References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Services Documentation](../services/)
- [Operations Documentation](../operations/)
- [Troubleshooting Documentation](../troubleshooting/)
