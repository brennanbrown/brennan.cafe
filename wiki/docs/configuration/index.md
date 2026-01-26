# Configuration

Configuration management for the brennan.page homelab.

## Overview

Configuration management ensures consistent, secure, and maintainable service configurations across the homelab infrastructure.

## Configuration Types

### Environment Variables
- **Service Configuration**: Service-specific environment variables
- **Database Configuration**: Database connection strings
- **URL Configuration**: Service URLs and base URLs
- **Security Configuration**: Security settings and credentials

### File Configuration
- **Docker Compose**: Docker Compose files
- **Caddyfile**: Caddy configuration
- **Configuration Files**: Service configuration files
- **Secret Files**: Password and secret files

### Resource Configuration
- **Memory Limits**: Container memory limits
- **CPU Limits**: Container CPU limits
- **Storage Limits**: Storage quotas
- **Network Configuration**: Network settings

## Environment Variables

### Database Configuration
```yaml
# PostgreSQL
POSTGRES_DB=homelab
POSTGRES_USER=homelab
POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

# Vikunja
VIKUNJA_DATABASE_HOST=postgresql
VIKUNJA_DATABASE_TYPE=postgres
VIKUNJA_DATABASE_USER=vikunja
VIKUNJA_DATABASE_PASSWORD=vikunja_password
VIKUNJA_DATABASE_DATABASE=vikunja
VIKUNJA_SERVICE_URL=https://tasks.brennan.page
```

### Service URLs
```yaml
# Base URLs
CMD_BASEURL=https://tasks.brennan.page
CMD_DOMAIN=notes.brennan.page
CMD_SERVICE_URL=https://bookmarks.brennan.page
CMD_BASEURL=/music
```

### Security Configuration
```yaml
# Security settings
CMD_SESSION_SECRET=secure_random_string_here
LD_SUPERUSER_PASSWORD=secure_admin_password
LD_ENABLE_AUTH_PROXY=true
```

### Feature Configuration
```yaml
# Feature toggles
CMD_ALLOW_ANONYMOUS=true
CMD_ENABLE_SHARING=true
CMD_ENABLE_FAVICONS=true
ND_ENABLESHARING=true
LD_ENABLE_AUTOMATIC_TAGGING=true
```

## File Configuration

### Docker Compose Structure
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
```

### Caddyfile Structure
```caddy
# Global options
{
    email admin@brennan.page
    auto_https off
}

# Service configurations
service.brennan.page {
    import compression
    import security
    
    reverse_proxy service_name:port
    handle_errors {
        respond "Service unavailable" 503
    }
}
```

### Configuration Files
```bash
# Service configuration
cd /opt/hemelab/services/service_name
vim docker-compose.yml

# Caddy configuration
cd /opt/hemelab/caddy
vim Caddyfile

# Environment files
cd /opt/hemelab/services/service_name
vim .env
```

## Resource Management

### Memory Limits
```yaml
# Resource limits
mem_limit: 256m      # Maximum memory
mem_reservation: 128m  # Guaranteed memory
```

### CPU Limits
```yaml
# CPU limits
cpus: 0.5        # CPU limit
cpuset: 0.25       # CPU reservation
```

### Storage Management
```yaml
# Volume mounts
volumes:
  - volume_name:/path  # Persistent volume
  - /host/path:/container/path  # Host mount
```

## Port Mappings

### Internal Ports
| Service | Internal Port | External Port | Purpose |
|---------|---------------|-------------|---------|
| PostgreSQL | 5432 | None | Database |
| Vikunja | 3456 | None | Web interface |
| HedgeDoc | 3000 | None | Web interface |
| Linkding | 9090 | None | Web interface |
| Navidrome | 4533 | None | Web interface |
| Portainer | 9000 | None | Web interface |
| Monitor | 8081 | None | Web interface |

### External Ports
| Port | Service | Purpose |
|------|---------|---------|
| 22 | SSH | Server management |
| 80 | HTTP | Web traffic |
| 443 | HTTPS | Secure web traffic |

## Security Configuration

### SSL/TLS
```caddy
# SSL configuration
{
    email admin@brennan.page
    auto_https off
}
```

### Security Headers
```caddy
(security) {
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
    }
}
```

### Authentication
```bash
# SSH configuration
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
MaxAuthTries 3
```

### Firewall
```bash
# UFW configuration
ufw default deny incoming
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

## Configuration Management

### Version Control
```bash
# Git repository
git clone https://github.com/brennanbrown/brennan.page.git
cd brennan.page

# Track configuration changes
git add docker-compose.yml
git commit -m "Update service configuration"
git push
```

### Backup Configuration
```bash
# Backup configurations
tar czf configs_backup.tar.gz /opt/hemelab/services/
tar czf caddy_config_backup.tar.gz /opt/homelab/caddy/
```

### Configuration Deployment
```bash
# Deploy configuration
rsync -avz services/ root@server:/opt/hemelab/services/
rsync caddy/Caddyfile root@server:/opt/hemelab/caddy/

# Reload services
cd /opt/hemelelab/services/service_name
docker compose up -d
```

## Environment Variables

### Database Variables
```bash
# PostgreSQL
POSTGRES_DB=homelab
POSTGRES_USER=homelab
POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

# Vikunja
VIKUNJA_DATABASE_HOST=postgresql
VIKUNJA_DATABASE_TYPE=postgres
VIKUNJA_DATABASE_USER=vikunja
VIKUNJA_DATABASE_PASSWORD=vikunja_password
VIKUNJA_DATABASE_DATABASE=vikunja
```

### Service Variables
```bash
# HedgeDoc
CMD_DB_URL=postgres://hedgedoc:hedgedoc_password@postgresql:5432/hedgedoc
CMD_DOMAIN=notes.brennan.page
CMD_PORT=3000
CMD_PROTOCOL_USESSL=true
CMD_ALLOW_ANONYMOUS=true
```

### Security Variables
```bash
# Session management
CMD_SESSION_SECRET=secure_random_string_here
LD_SUPERUSER_PASSWORD=secure_admin_password
```

## Configuration Files

### Docker Compose Files
```yaml
# Example docker-compose.yml
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
```

### Caddyfile
```caddy
# Example Caddyfile
service.brennan.page {
    import compression
    import security
    
    reverse_proxy service_name:port
    handle_errors {
        respond "Service unavailable" 503
    }
}
```

### Environment Files
```bash
# .env file
DATABASE_URL=postgres://user:password@localhost:5432/database
API_KEY=api_key_here
SECRET_KEY=secret_key_here
```

## Resource Limits

### Memory Allocation
```yaml
# Memory limits by service
services:
  postgresql:
    mem_limit: 256m
    mem_reservation: 128m
  
  vikunja:
    mem_limit: 256m
    mem_reservation: 128m
  
  hedgedoc:
    mem_limit: 256m
    mem_reservation: 128m
  
  linkding:
    mem_limit: 128m
    mem_reservation: 64m
  
  navidrome:
    mem_limit: 256m
    mem_reservation: 128m
```

### Total Resource Usage
- **Total RAM**: 2GB
- **Allocated**: ~1.2GB (60%)
- **Available**: ~800MB (40%)
- **Buffer**: ~800MB for expansion

## Troubleshooting

### Configuration Issues
```bash
# Validate Caddyfile
caddy validate --config /etc/caddy/Caddyfile

# Test database connection
docker exec postgres psql -U user -d database -c "SELECT 1;"

# Test service connectivity
docker exec caddy curl -f http://service_name:port
```

### Environment Variable Issues
```bash
# Check environment variables
docker exec service_name env | grep ENV_VAR

# Test configuration
docker compose config

# Reload configuration
docker compose restart
```

### Resource Issues
```bash
# Check resource usage
docker stats

# Check disk usage
df -h

# Check memory usage
free -h
```

## Best Practices

### Configuration Management
- **Version Control**: Store configurations in Git
- **Documentation**: Document configuration changes
- **Testing**: Test configuration changes
- **Backup**: Regular configuration backups
- **Review**: Regular configuration reviews

### Security Practices
- **Strong Credentials**: Use strong passwords
- **Regular Updates**: Keep software updated
- **Access Control**: Limit access to configurations
- **Audit Logging**: Maintain audit logs

### Performance Optimization
- **Resource Monitoring**: Monitor resource usage
- **Regular Cleanup**: Regular cleanup procedures
- **Optimization**: Performance optimization
- **Capacity Planning**: Capacity planning

### Documentation
- **Configuration Documentation**: Document all configurations
- **Change Management**: Change management procedures
- **Troubleshooting**: Troubleshooting guides
- **Best Practices**: Best practices documentation

## References

- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Caddyfile Reference](https://caddyserver.com/docs/caddyfile/)
- [Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [Resource Limits](https://docs.docker.com/config/containers/resource-constraints/)
