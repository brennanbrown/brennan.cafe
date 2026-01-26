# Reference

This section contains reference materials and quick guides for the brennan.page homelab.

## Quick References

### [SSH Commands](ssh-commands.md)
Essential SSH commands for managing the homelab server, including:
- Connection information and standard command format
- System operations and Docker management
- File transfer and editing workflows
- Troubleshooting and debugging commands
- Security best practices

### [API Documentation](api.md) (Coming Soon)
REST API documentation for all services:
- Authentication endpoints
- Service-specific APIs
- Integration examples
- Error handling

### [Configuration Reference](config.md) (Coming Soon)
Complete configuration reference:
- Environment variables
- Docker compose templates
- Caddy configuration
- Database schemas

## Command Cheatsheets

### Docker Commands
```bash
# Container management
docker ps                    # List running containers
docker ps -a               # List all containers
docker logs container      # View container logs
docker restart container  # Restart container
docker stats              # View resource usage

# Image management
docker images             # List images
docker pull image         # Pull latest image
docker system prune      # Clean up unused resources
```

### System Commands
```bash
# System information
uname -a                 # System info
free -h                  # Memory usage
df -h                    # Disk usage
uptime                   # System uptime

# Process management
ps aux                   # List processes
top                      # Process monitor
kill pid                 # Kill process
```

### Network Commands
```bash
# Network status
ip addr show             # Network interfaces
netstat -tulpn          # Listening ports
ping host               # Test connectivity
curl -I url             # Test HTTP endpoint
```

## File Locations

### Configuration Files
- **Docker Compose**: `/opt/homelab/services/*/docker-compose.yml`
- **Caddy Configuration**: `/opt/homelab/caddy/Caddyfile`
- **Environment Files**: `/opt/homelab/services/*/.env`
- **SSH Keys**: `~/.omg-lol-keys/id_ed25519`

### Data Directories
- **Service Data**: `/opt/homelab/services/*/data/`
- **Database Files**: `/opt/homelab/services/postgresql/data/`
- **Log Files**: `/opt/homelab/logs/`
- **Backups**: `/opt/homelab/backups/`

### Web Directories
- **Wiki Files**: `/opt/homelab/wiki/`
- **Static Files**: `/var/www/`
- **Upload Directories**: `/opt/homelab/uploads/`

## Service URLs

### Management Services
- **Docker Management**: https://docker.brennan.page
- **System Monitoring**: https://monitor.brennan.page
- **File Management**: https://files.brennan.page

### Productivity Services
- **Task Management**: https://tasks.brennan.page
- **Collaborative Notes**: https://notes.brennan.page
- **Bookmark Manager**: https://bookmarks.brennan.page
- **Music Streaming**: https://music.brennan.page/music/app/

### Documentation
- **Main Wiki**: https://wiki.brennan.page
- **Landing Page**: https://brennan.page

## Environment Variables

### Database Connection
```bash
POSTGRES_HOST=postgresql
POSTGRES_PORT=5432
POSTGRES_USER=homelab
POSTGRES_PASSWORD=homelab_password_2026_secure_random_string
POSTGRES_DB=homelab
```

### Service URLs
```bash
MAIN_DOMAIN=brennan.page
TASKS_URL=https://tasks.brennan.page
NOTES_URL=https://notes.brennan.page
BOOKMARKS_URL=https://bookmarks.brennan.page
MUSIC_URL=https://music.brennan.page/music/app/
FILES_URL=https://files.brennan.page
WIKI_URL=https://wiki.brennan.page
```

### Database URLs
```bash
VIKUNJA_DB_URL=postgres://vikunja:vikunja_password@postgresql:5432/vikunja
HEDGEDOC_DB_URL=postgres://hedgedoc:hedgedoc_password@postgresql:5432/hedgedoc
LINKDING_DB_URL=postgres://linkding:linkding_password@postgresql:5432/linkding
NAVIDROME_DB_URL=postgres://navidrome:navidrome_password@postgresql:5432/navidrome
```

## Docker Compose Templates

### Standard Service Template
```yaml
services:
  service_name:
    image: image:latest
    container_name: service_name
    restart: unless-stopped
    environment:
      - ENV_VAR=value
    volumes:
      - volume:/path
    networks:
      - caddy
      - internal_db
    mem_limit: 256m
    mem_reservation: 128m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  volume:

networks:
  caddy:
    external: true
  internal_db:
    external: true
```

### Database-Backed Service Template
```yaml
services:
  service_name:
    image: image:latest
    container_name: service_name
    restart: unless-stopped
    environment:
      - DATABASE_URL=postgres://user:password@postgresql:5432/database
    depends_on:
      - postgresql
    networks:
      - caddy
      - internal_db

  postgresql:
    image: postgres:15
    container_name: postgresql
    restart: unless-stopped
    environment:
      - POSTGRES_USER=homelab
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=database
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - internal_db
```

## Caddy Configuration

### Basic Service Configuration
```caddyfile
service.brennan.page {
    reverse_proxy service_name:80
    encode zstd gzip
}
```

### Service with Authentication
```caddyfile
service.brennan.page {
    reverse_proxy service_name:80
    encode zstd gzip
    
    # Security headers
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
}
```

### File Upload Service
```caddyfile
files.brennan.page {
    reverse_proxy filebrowser:80
    encode zstd gzip
    
    # Increased limits for file uploads
    request_body {
        max_size 100MB
    }
}
```

## Database Schemas

### PostgreSQL Database Structure
```sql
-- Main homelab database
CREATE DATABASE homelab;
CREATE USER homelab WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE homelab TO homelab;

-- Service databases
CREATE DATABASE vikunja;
CREATE USER vikunja WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE vikunja TO vikunja;

CREATE DATABASE hedgedoc;
CREATE USER hedgedoc WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE hedgedoc TO hedgedoc;
```

### Common Database Operations
```bash
# Connect to database
docker exec postgres psql -U homelab -d homelab

# List databases
\l

# List tables
\dt

# Database backup
docker exec postgres pg_dump -U homelab database > backup.sql

# Database restore
docker exec -i postgres psql -U homelab database < backup.sql
```

## Monitoring Commands

### System Monitoring
```bash
# Real-time monitoring
docker stats

# Resource usage summary
docker stats --no-stream

# System overview
glances

# Disk usage
du -sh /opt/homelab/*
```

### Service Health Checks
```bash
# Check all services
for service in caddy postgresql filebrowser vikunja hedgedoc linkding navidrome; do
  echo "Checking $service..."
  docker ps | grep $service
done

# Test service endpoints
curl -I https://files.brennan.page
curl -I https://tasks.brennan.page
curl -I https://notes.brennan.page
```

### Log Monitoring
```bash
# Recent system logs
journalctl -n 50 --no-pager

# Service logs
docker logs service_name --tail 50

# Error logs
docker logs service_name --tail 100 | grep -i error
```

## Backup Commands

### System Backup
```bash
# Full system backup
cd /opt/homelab
./scripts/backup.sh

# Service-specific backup
./scripts/backup-service.sh service_name

# Database backup
docker exec postgres pg_dump -U homelab database > backup.sql
```

### Restore Commands
```bash
# Full system restore
./scripts/restore.sh backup_file.tar.gz

# Service restore
./scripts/restore-service.sh service_name backup_file.tar.gz

# Database restore
docker exec -i postgres psql -U homelab database < backup.sql
```

## Security Commands

### Firewall Management
```bash
# Check firewall status
ufw status numbered

# Add rule
ufw allow 22/tcp comment 'SSH'

# Remove rule
ufw delete allow 22/tcp

# Enable firewall
ufw enable
```

### SSL Certificate Management
```bash
# List certificates
docker exec caddy caddy list-certificates

# Reload Caddy
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Force certificate renewal
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### Security Audit
```bash
# Check failed logins
grep 'Failed password' /var/log/auth.log | tail -20

# Check open ports
netstat -tulpn

# Check user accounts
cat /etc/passwd
```

## Troubleshooting Quick Reference

### Common Issues
1. **Service Not Starting**: Check logs and resource usage
2. **Database Connection**: Verify database connectivity
3. **Network Access**: Check network configuration
4. **SSL Issues**: Verify certificate configuration

### Diagnostic Commands
```bash
# System status
docker ps
free -h
df -h

# Service logs
docker logs service_name --tail 50

# Network test
curl -I https://service.brennan.page

# Database test
docker exec postgres psql -U user -d database -c "SELECT 1;"
```

## Performance Optimization

### Resource Limits
```yaml
# Memory limits
mem_limit: 256m
mem_reservation: 128m

# CPU limits
cpus: 0.5
cpu_shares: 512
```

### Database Optimization
```sql
-- Vacuum and analyze
VACUUM ANALYZE;

-- Reindex database
REINDEX DATABASE database_name;

-- Check database size
SELECT pg_size_pretty(pg_database_size('database_name'));
```

### Caching Configuration
```bash
# Clear Docker cache
docker system prune -a

# Clear package cache
apt clean

# Clear log files
journalctl --vacuum-time=7d
```

## Integration Examples

### Service Integration
```bash
# Add new service to Caddy
echo "newservice.brennan.page {
    reverse_proxy newservice:80
}" >> /opt/homelab/caddy/Caddyfile

# Reload Caddy
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### Database Integration
```bash
# Create new database
docker exec postgres psql -U homelab -c "CREATE DATABASE newservice;"

# Create database user
docker exec postgres psql -U homelab -c "CREATE USER newservice WITH PASSWORD 'password';"

# Grant privileges
docker exec postgres psql -U homelab -c "GRANT ALL PRIVILEGES ON DATABASE newservice TO newservice;"
```

## References

- [Services](../services/) - Service documentation
- [Infrastructure](../infrastructure/) - Infrastructure documentation
- [Operations](../operations/) - Operational procedures
- [Troubleshooting](../troubleshooting/) - Troubleshooting guides
