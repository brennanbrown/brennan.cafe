# Portainer

**Service**: Portainer  
**Version**: Latest  
**Status**: ✅ **OPERATIONAL**  
**Purpose**: Docker Management Interface  

## Overview

Portainer is a lightweight management UI for Docker that allows you to manage your Docker containers, images, volumes, networks, and more through a web interface.

## Architecture

### Container Configuration
```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - portainer_data:/data
    networks:
      - caddy
    mem_limit: 100m
    mem_reservation: 50m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Network Configuration
- **External Access**: Via Caddy reverse proxy
- **Docker Socket**: Direct Docker daemon access
- **Internal Network**: Connected to caddy network
- **Port**: 9000 (internal only)

## Features

### Container Management
- **List Containers**: View all running and stopped containers
- **Start/Stop**: Start, stop, restart containers
- **Remove**: Remove containers and associated resources
- **Logs**: View container logs in real-time
- **Stats**: Monitor container resource usage

### Image Management
- **Image Registry**: Browse Docker Hub and private registries
- **Pull/Push**: Pull and push Docker images
- **Build**: Build Docker images from Dockerfiles
- **Tag**: Tag and retag images
- **Remove**: Remove unused images

### Volume Management
- **List Volumes**: View all Docker volumes
- **Create**: Create new volumes
- **Remove**: Remove volumes
- **Inspect**: Inspect volume details
- **Backup**: Volume backup and restore

### Network Management
- **List Networks**: View all Docker networks
- **Create**: Create new networks
- **Connect/Disconnect**: Connect/disconnect containers
- **Inspect**: Inspect network configuration
- **Remove**: Remove unused networks

### User Management
- **Users**: Create and manage users
- **Teams**: Create and manage teams
- **Roles**: Assign roles and permissions
- **Authentication**: Configure authentication methods

## Access

### Web Interface
- **URL**: https://docker.brennan.page
- **Authentication**: Admin account setup required
- **Access**: HTTPS via Caddy reverse proxy
- **Security**: SSL/TLS encryption

### Initial Setup
1. Access https://docker.brennan.page
2. Create admin account
3. Set strong password
4. Configure user preferences
5. Start managing Docker resources

### Admin Account
- **Username**: Choose admin username
- **Password**: Strong password (20+ characters)
- **Email**: Optional email address
- **Role**: Administrator privileges

## Configuration

### Environment Variables
Portainer uses minimal configuration:
- **Docker Socket**: Direct Docker daemon access
- **Data Volume**: Persistent data storage
- **Network**: Connected to caddy network

### Data Persistence
- **Portainer Data**: User data, settings, and configuration
- **Volume**: `portainer_data` Docker volume
- **Backup**: Included in system backup procedures
- **Location**: `/var/lib/docker/volumes/portainer_data`

### Security Configuration
- **Docker Socket**: Read-only access to Docker socket
- **Network**: Limited to caddy network
- **Authentication**: Admin account required
- **SSL**: HTTPS via Caddy

## Operations

### Common Operations

#### Container Management
```bash
# View all containers
docker ps

# View container logs
docker logs portainer

# Restart Portainer
docker restart portainer

# Update Portainer
cd /opt/homelab/services/portainer
docker compose pull
docker compose up -d
```

#### Resource Monitoring
```bash
# Check resource usage
docker stats portainer

# Check container details
docker inspect portainer

# Monitor disk usage
docker system df
```

#### Backup and Restore
```bash
# Backup Portainer data
docker run --rm -v portainer_data:/data -v $(pwd):/backup alpine tar czf /backup/portainer_backup.tar.gz -C /data .

# Restore Portainer data
docker run --rm -v portainer_data:/data -v $(pwd):/backup alpine tar xzf /backup/portainer_backup.tar.gz -C /data
```

## Security

### Container Security
- **Non-root**: Runs as non-root user
- **Resource Limits**: Memory limits enforced
- **Network Isolation**: Limited network access
- **Docker Socket**: Read-only Docker socket access

### Access Control
- **Authentication**: Admin account authentication
- **Authorization**: Role-based access control
- **Session Management**: Secure session handling
- **Audit Logging**: User activity logging

### Data Protection
- **Encryption**: Data encrypted at rest
- **Backup**: Regular backup procedures
- **Access Control**: Limited data access
- **Privacy**: User privacy protection

## Troubleshooting

### Common Issues

#### Access Issues
```bash
# Check container status
docker ps | grep portainer

# Check logs
docker logs portainer --tail 20

# Test connectivity
curl -f http://localhost:9000
```

#### Docker Socket Issues
```bash
# Check Docker socket permissions
ls -la /var/run/docker.sock

# Test Docker access
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock alpine docker version
```

#### Performance Issues
```bash
# Check resource usage
docker stats portainer

# Check Docker daemon status
docker system info

# Monitor system resources
top
```

#### UI Issues
```bash
# Clear browser cache
# Try different browser
# Check browser console for errors
# Verify SSL certificate
```

### Debug Commands
```bash
# Check container health
docker inspect portainer

# View detailed logs
docker logs portainer --tail 50

# Test Docker functionality
docker version
docker ps
```

## Best Practices

### Security
- **Strong Passwords**: Use strong admin password
- **Regular Updates**: Keep Portainer updated
- **Access Control**: Limit user access
- **Audit Logging**: Monitor user activity

### Performance
- **Resource Limits**: Monitor resource usage
- **Regular Cleanup**: Clean up unused resources
- **Monitoring**: Monitor performance metrics
- **Optimization**: Optimize Docker usage

### Backup
- **Regular Backups**: Backup Portainer data
- **Testing**: Test backup restoration
- **Documentation**: Document backup procedures
- **Automation**: Automate backup processes

## Integration

### With Docker
- **Direct Access**: Full Docker daemon access
- **Container Management**: Complete container lifecycle
- **Image Management**: Image registry access
- **Volume Management**: Volume and data management

### With Caddy
- **Reverse Proxy**: HTTPS via Caddy
- **SSL Termination**: SSL handled by Caddy
- **Security Headers**: Security headers from Caddy
- **Load Balancing**: Load balancing via Caddy

### With Services
- **Management**: Manage all service containers
- **Monitoring**: Monitor service resource usage
- **Logs**: Access service logs
- **Configuration**: Configure service settings

## Advanced Features

### Stacks
- **Docker Compose**: Manage Docker Compose stacks
- **Stack Management**: Deploy and manage stacks
- **Service Scaling**: Scale services up/down
- **Health Checks**: Configure health checks

### Templates
- **App Templates**: Pre-configured application templates
- **Custom Templates**: Create custom templates
- **Template Sharing**: Share templates with teams
- **Template Management**: Manage template library

### Registry Management
- **Docker Hub**: Browse Docker Hub
- **Private Registries**: Connect private registries
- **Image Management**: Manage image repositories
- **Authentication**: Registry authentication

## Monitoring

### Metrics
- **Container Metrics**: CPU, memory, network, disk
- **Image Metrics**: Image usage and size
- **Volume Metrics**: Volume usage and size
- **Network Metrics**: Network traffic and connections

### Alerts
- **Resource Alerts**: Resource usage alerts
- **Health Alerts**: Container health alerts
- **Security Alerts**: Security event alerts
- **Performance Alerts**: Performance issue alerts

### Logging
- **Access Logs**: User access logging
- **Action Logs**: User action logging
- **Error Logs**: Error and exception logging
- **Audit Logs**: Audit trail logging

## References

- [Portainer Documentation](https://docs.portainer.io/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Security](https://docs.docker.com/engine/security/)
