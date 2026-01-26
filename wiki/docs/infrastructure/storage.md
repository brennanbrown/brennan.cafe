# Storage

Storage management and data persistence for the brennan.page homelab.

## Overview

Storage is managed through Docker volumes, ensuring data persistence, backup capabilities, and efficient resource utilization.

## Storage Architecture

### Primary Storage
- **Disk**: 70GB SSD on DigitalOcean droplet
- **Filesystem**: Ext4 with default settings
- **Mount Points**: /opt/homelab, /var/www/brennan.page
- **Usage**: ~3.4GB used (5% of available space)

### Storage Types

#### Docker Volumes
Managed volumes for persistent data:
- **Database Volumes**: PostgreSQL data storage
- **Application Volumes**: Service-specific data
- **Configuration Volumes**: Service configuration files
- **Log Volumes**: Container log storage

#### Host Filesystem
Direct filesystem access:
- **Static Files**: Web content and assets
- **Configuration**: Service configuration files
- **Backups**: Backup storage
- **Logs**: System and application logs

## Docker Volumes

### Database Volumes

#### PostgreSQL Data Volume
```yaml
volumes:
  postgres_data:
    driver: local
```
- **Path**: /var/lib/docker/volumes/postgresql_postgres_data/_data
- **Size**: ~50MB (current usage)
- **Backup**: Automated daily backups
- **Retention**: 30 days retention policy

#### Application Data Volumes

##### Vikunja Files
```yaml
volumes:
  vikunja_files:
    driver: local
```
- **Purpose**: File uploads and attachments
- **Size**: ~10MB (current usage)
- **Backup**: Included in database backups
- **Access**: Via Vikunja web interface

##### HedgeDoc Uploads
```yaml
volumes:
  hedgedoc_uploads:
    driver: local
```
- **Purpose**: File uploads and images
- **Size**: ~5MB (current usage)
- **Backup**: Included in database backups
- **Access**: Via HedgeDoc web interface

##### Linkding Data
```yaml
volumes:
  linkding_data:
    driver: local
```
- **Purpose**: Bookmark data and configuration
- **Size**: ~2MB (current usage)
- **Backup**: Included in database backups
- **Access**: Via Linkding web interface

##### Navidrome Volumes
```yaml
volumes:
  navidrome_data:
    driver: local
  navidrome_cache:
    driver: local
  navidrome_music:
    driver: local
```
- **Data**: ~5MB (metadata and configuration)
- **Cache**: ~20MB (transcoding cache)
- **Music**: User-provided music files
- **Access**: Via Navidrome web interface

### Configuration Volumes

#### Caddy Data Volume
```yaml
volumes:
  caddy_data:
    driver: local
```
- **Purpose**: SSL certificates and Caddy configuration
- **Size**: ~10MB (current usage)
- **Contents**: SSL certificates, configuration files
- **Backup**: Included in system backups

## Host Filesystem

### Directory Structure
```
/opt/homelab/
├── caddy/                 # Caddy configuration
├── services/              # Service configurations
│   ├── postgresql/        # PostgreSQL files
│   ├── vikunja/          # Vikunja files
│   ├── hedgedoc/         # HedgeDoc files
│   ├── linkding/         # Linkding files
│   └── navidrome/        # Navidrome files
├── wiki/                  # Wiki files
└── scripts/               # Management scripts

/var/www/brennan.page/
├── index.html            # Landing page
└── wiki/                 # Built wiki files
```

### Static Content
- **Landing Page**: /var/www/brennan.page/index.html
- **Wiki Content**: /var/www/brennan.page/wiki/
- **Assets**: Images, CSS, JavaScript files
- **Backup**: Regular backups to /opt/homelab/backups/

## Storage Management

### Volume Management Commands

#### List Volumes
```bash
# List all volumes
docker volume ls

# List volumes with size
docker volume ls --format "table {{.Name}}\t{{.Driver}}"

# Inspect volume
docker volume inspect volume_name
```

#### Backup Volumes
```bash
# Backup volume to tar file
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine tar czf /backup/volume_backup.tar.gz -C /data .

# Restore volume from backup
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine tar xzf /backup/volume_backup.tar.gz -C /data
```

#### Cleanup Volumes
```bash
# Remove unused volumes
docker volume prune

# Remove specific volume
docker volume rm volume_name

# Force remove volume
docker volume rm -f volume_name
```

### Disk Usage Monitoring

#### Check Disk Usage
```bash
# Check overall disk usage
df -h

# Check directory sizes
du -sh /opt/homelab/*

# Check Docker usage
docker system df

# Check volume sizes
docker system df -v
```

#### Monitor Growth
```bash
# Monitor disk usage over time
watch -n 300 df -h

# Check large files
find /opt/homelab -type f -size +100M -exec ls -lh {} \;

# Check Docker disk usage
docker system du
```

## Backup Strategy

### Backup Types

#### Database Backups
```bash
# PostgreSQL backup
docker exec postgres pg_dump -U homelab homelab > backup.sql

# Individual database backup
docker exec postgres pg_dump -U homelab vikunja > vikunja_backup.sql

# Compressed backup
docker exec postgres pg_dump -U homelab homelab | gzip > backup.sql.gz
```

#### Volume Backups
```bash
# Backup all volumes
for volume in $(docker volume ls -q); do
    docker run --rm -v $volume:/data -v $(pwd):/backup alpine tar czf /backup/${volume}_backup.tar.gz -C /data .
done

# Backup specific volume
docker run --rm -v postgresql_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
```

#### Configuration Backups
```bash
# Backup service configurations
tar czf configs_backup.tar.gz /opt/homelab/services/

# Backup Caddy configuration
tar czf caddy_backup.tar.gz /opt/homelab/caddy/

# Backup scripts
tar czf scripts_backup.tar.gz /opt/homelab/scripts/
```

### Backup Automation
```bash
#!/bin/bash
# Automated backup script

BACKUP_DIR="/opt/homelab/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR/$DATE

# Database backups
docker exec postgres pg_dump -U homelab homelab > $BACKUP_DIR/$DATE/homelab_$DATE.sql
docker exec postgres pg_dump -U homelab vikunja > $BACKUP_DIR/$DATE/vikunja_$DATE.sql

# Volume backups
docker run --rm -v postgresql_postgres_data:/data -v $BACKUP_DIR/$DATE:/backup alpine tar czf /backup/postgres_$DATE.tar.gz -C /data .

# Configuration backups
tar czf $BACKUP_DIR/$DATE/configs_$DATE.tar.gz /opt/homelab/services/

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} \;
```

## Storage Optimization

### Disk Space Optimization

#### Log Management
```bash
# Configure log rotation
docker compose logs --tail=0 -f

# Clean up old logs
docker system prune --volumes

# Configure container log limits
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

#### Image Cleanup
```bash
# Remove unused images
docker image prune

# Remove all unused resources
docker system prune -a

# Remove specific image
docker rmi image:tag
```

#### Volume Cleanup
```bash
# Remove unused volumes
docker volume prune

# Remove orphaned volumes
docker volume ls -f dangling=true -q | xargs docker volume rm
```

### Performance Optimization

#### Filesystem Optimization
```bash
# Check filesystem health
sudo fsck -n /dev/sda1

# Optimize filesystem
sudo tune2fs -O /dev/sda1

# Check disk I/O
iostat -x 1
```

#### Docker Performance
```bash
# Optimize Docker storage driver
sudo systemctl edit docker
# Add: ExecStart=/usr/bin/dockerd --storage-driver overlay2

# Monitor Docker performance
docker stats --no-stream
```

## Storage Monitoring

### Monitoring Commands

#### Real-time Monitoring
```bash
# Monitor disk usage
watch -n 60 df -h

# Monitor Docker storage
watch -n 300 docker system df

# Monitor volume sizes
watch -n 600 docker volume ls --format "table {{.Name}}\t{{.Size}}"
```

#### Alerting
```bash
# Disk usage alert
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "Disk usage is ${DISK_USAGE}% - Alert!"
fi

# Docker storage alert
DOCKER_USAGE=$(docker system df --format "{{.Size}}" | sed 's/[^0-9.]//g')
if (( $(echo "$DOCKER_USAGE > 50" | bc -l) )); then
    echo "Docker storage usage is ${DOCKER_USAGE}GB - Alert!"
fi
```

## Storage Planning

### Capacity Planning
- **Current Usage**: 3.4GB of 70GB (5%)
- **Growth Rate**: ~100MB per month
- **Available Space**: 66.6GB
- **Time to Full**: ~5 years at current rate

### Expansion Planning
- **Monitoring**: Regular usage monitoring
- **Alerts**: Usage threshold alerts
- **Cleanup**: Regular cleanup procedures
- **Scaling**: Storage expansion options

## Best Practices

### Data Management
- **Regular Backups**: Automated backup procedures
- **Version Control**: Configuration in Git
- **Documentation**: Storage documentation
- **Testing**: Backup restoration testing

### Security
- **Encryption**: Sensitive data encryption
- **Access Control**: Limited storage access
- **Audit Logging**: Storage access logging
- **Compliance**: Data retention policies

### Performance
- **Monitoring**: Regular performance monitoring
- **Optimization**: Storage optimization
- **Cleanup**: Regular cleanup procedures
- **Planning**: Capacity planning

## Troubleshooting

### Common Issues

#### Out of Space
```bash
# Check disk usage
df -h

# Find large files
find /opt/homelab -type f -size +100M -exec ls -lh {} \;

# Clean up Docker
docker system prune -a

# Remove old backups
find /opt/homelab/backups -type f -mtime +30 -delete
```

#### Volume Issues
```bash
# Check volume status
docker volume ls

# Inspect volume
docker volume inspect volume_name

# Repair volume permissions
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine chown -R 1000:1000 /data
```

#### Performance Issues
```bash
# Check I/O performance
iostat -x 1

# Check disk health
sudo smartctl -a /dev/sda

# Monitor Docker performance
docker stats --no-stream
```

## References

- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Linux Filesystem](https://wiki.ubuntu.com/Filesystem)
- [Backup Strategies](https://en.wikipedia.org/wiki/Backup)
