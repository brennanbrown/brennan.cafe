# Backups

Backup and recovery procedures for the brennan.page homelab.

## Overview

Regular backups are essential for data protection and disaster recovery. This section covers backup strategies, procedures, and recovery processes.

## Backup Strategy

### Backup Types
- **Full Backups**: Complete system backup
- **Incremental Backups**: Changes since last backup
- **Differential Backups**: Changes since last full backup
- **Snapshot Backups**: Point-in-time snapshots

### Backup Schedule
- **Daily**: Database backups
- **Weekly**: Configuration backups
- **Monthly**: Full system backups
- **On-demand**: Before major changes

### Backup Locations
- **Local**: Local storage for quick recovery
- **Remote**: Offsite storage for disaster recovery
- **Cloud**: Cloud storage for long-term retention

## Database Backups

### PostgreSQL Backups
```bash
# Full database backup
docker exec postgres pg_dump -U homelab homelab > /opt/homelab/backups/postgres-$(date +%Y%m%d).sql

# Individual database backup
docker exec postgres pg_dump -U homelab vikunja > /opt/homelab/backups/vikunja-$(date +%Y%m%d).sql
docker exec postgres pg_dump -U homelab hedgedoc > /opt/homelab/backups/hedgedoc-$(date +%Y%m%d).sql
docker exec postgres pg_dump -U homelab linkding > /opt/homelab/backups/linkding-$(date +%Y%m%d).sql
docker exec postgres pg_dump -U homelab navidrome > /opt/homelab/backups/navidrome-$(date +%Y%m%d).sql

# Compressed backup
docker exec postgres pg_dump -U homelab homelab | gzip > /opt/homelab/backups/postgres-$(date +%Y%m%d).sql.gz

# All databases
for db in $(docker exec postgres psql -U homelab -t -c "SELECT datname FROM pg_database WHERE datname NOT IN ('template0', 'template1', 'postgres')"); do
    docker exec postgres pg_dump -U homelab "$db" > "/opt/homelab/backups/${db}-$(date +%Y%m%d).sql"
done
```

### MariaDB Backups
```bash
# Full backup
docker exec flarum_mariadb mysqldump -u root -prootpassword123 --all-databases > /opt/homelab/backups/mariadb-$(date +%Y%m%d).sql

# Individual database
docker exec flarum_mariadb mysqldump -u root -prootpassword123 flarum > /opt/homelab/backups/flarum-$(date +%Y%m%d).sql

# Compressed backup
docker exec flarum_mariadb mysqldump -u root -prootpassword123 --all-databases | gzip > /opt/homelab/backups/mariadb-$(date +%Y%m%d).sql.gz
```

## Service Data Backups

### Volume Backups
```bash
# Backup service volumes
docker run --rm -v service_volume:/data -v /opt/homelab/backups:/backup alpine tar czf /backup/service-$(date +%Y%m%d).tar.gz -C /data .

# Backup all service volumes
for volume in $(docker volume ls --format "{{.Name}}" | grep service); do
    docker run --rm -v "$volume":/data -v /opt/homelab/backups:/backup alpine tar czf "/backup/${volume}-$(date +%Y%m%d).tar.gz" -C /data .
done
```

### Configuration Backups
```bash
# Backup Docker Compose files
find /opt/homelab/services -name "docker-compose.yml" -exec cp {} /opt/homelab/backups/configs/ \;

# Backup Caddyfile
cp /opt/homelab/caddy/Caddyfile /opt/homelab/backups/configs/Caddyfile-$(date +%Y%m%d)

# Backup environment files
find /opt/homelab -name "*.env" -exec cp {} /opt/homelab/backups/configs/ \;
```

## Backup Automation

### Backup Script
```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/opt/homelab/backups"
DATE=$(date +%Y%m%d)
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR/databases"
mkdir -p "$BACKUP_DIR/volumes"
mkdir -p "$BACKUP_DIR/configs"

# Database backups
echo "Backing up databases..."
docker exec postgres pg_dump -U homelab homelab | gzip > "$BACKUP_DIR/databases/postgres-$DATE.sql.gz"

for db in $(docker exec postgres psql -U homelab -t -c "SELECT datname FROM pg_database WHERE datname NOT IN ('template0', 'template1', 'postgres')"); do
    docker exec postgres pg_dump -U homelab "$db" | gzip > "$BACKUP_DIR/databases/${db}-$DATE.sql.gz"
done

# MariaDB backup
if docker ps | grep -q mariadb; then
    docker exec flarum_mariadb mysqldump -u root -prootpassword123 --all-databases | gzip > "$BACKUP_DIR/databases/mariadb-$DATE.sql.gz"
fi

# Volume backups
echo "Backing up volumes..."
for volume in $(docker volume ls --format "{{.Name}}" | grep -E "data|db"); do
    docker run --rm -v "$volume":/data -v "$BACKUP_DIR/volumes":/backup alpine tar czf "/backup/${volume}-$DATE.tar.gz" -C /data .
done

# Configuration backups
echo "Backing up configurations..."
find /opt/homelab/services -name "docker-compose.yml" -exec cp {} "$BACKUP_DIR/configs/" \;
cp /opt/homelab/caddy/Caddyfile "$BACKUP_DIR/configs/Caddyfile-$DATE"

# Clean up old backups
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -name "*$(date -d "$RETENTION_DAYS days ago" +%Y%m%d)*" -delete

echo "Backup completed: $DATE"
```

### Cron Job
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /opt/homelab/scripts/backup.sh >> /opt/homelab/logs/backup.log 2>&1

# Weekly full backup on Sunday at 3 AM
0 3 * * 0 /opt/homelab/scripts/full-backup.sh >> /opt/homelab/logs/backup.log 2>&1
```

## Recovery Procedures

### Database Recovery
```bash
# Stop services
docker compose down

# Restore PostgreSQL database
docker exec postgres psql -U homelab -d postgres -c "DROP DATABASE IF EXISTS database_name;"
docker exec postgres psql -U homelab -d postgres -c "CREATE DATABASE database_name;"
docker exec postgres psql -U homelab -d database_name < /opt/homelab/backups/database_name-20260116.sql

# Restore from compressed backup
gunzip -c /opt/homelab/backups/database_name-20260116.sql.gz | docker exec -i postgres psql -U homelab -d database_name

# Restore MariaDB database
docker exec flarum_mariadb mysql -u root -prootpassword123 < /opt/homelab/backups/mariadb-20260116.sql
```

### Volume Recovery
```bash
# Stop service
docker stop service_name

# Remove current volume
docker volume rm service_volume

# Create new volume
docker volume create service_volume

# Restore from backup
docker run --rm -v service_volume:/data -v /opt/homelab/backups:/backup alpine tar xzf /backup/service_volume-20260116.tar.gz -C /data

# Start service
docker start service_name
```

### Configuration Recovery
```bash
# Restore Docker Compose files
cp /opt/homelab/backups/configs/docker-compose.yml /opt/homelab/services/service_name/

# Restore Caddyfile
cp /opt/homelab/backups/configs/Caddyfile-20260116 /opt/homelab/caddy/Caddyfile

# Restart services
docker compose down
docker compose up -d
```

## Disaster Recovery

### Complete System Recovery
```bash
# 1. System preparation
# Install Docker and Docker Compose
# Create necessary directories
mkdir -p /opt/homelab/{services,backups,logs}

# 2. Restore configurations
cp /opt/homelab/backups/configs/* /opt/homelab/services/

# 3. Restore databases
# Start PostgreSQL
docker compose up -d postgres

# Restore databases
for backup in /opt/homelab/backups/databases/*.sql.gz; do
    db_name=$(basename "$backup" .sql.gz | sed 's/-[0-9]*$//')
    gunzip -c "$backup" | docker exec -i postgres psql -U homelab -d "$db_name"
done

# 4. Restore volumes
for backup in /opt/homelab/backups/volumes/*.tar.gz; do
    volume_name=$(basename "$backup" .tar.gz | sed 's/-[0-9]*$//')
    docker volume create "$volume_name"
    docker run --rm -v "$volume_name":/data -v /opt/homelab/backups:/backup alpine tar xzf "/backup/$(basename "$backup")" -C /data
done

# 5. Start all services
docker compose up -d

# 6. Verify recovery
docker ps
curl -I https://brennan.page
```

### Service-Specific Recovery
```bash
# WriteFreely recovery
docker stop writefreely
rm -rf /opt/homelab/services/writefreely/data
docker cp -r /opt/homelab/backups/writefreely-20260116 /opt/homelab/services/writefreely/data
docker start writefreely

# Flarum recovery
docker stop flarum
docker volume rm flarum_flarum_db_data
docker compose up -d
docker exec flarum_mariadb mysql -u root -prootpassword123 flarum < /opt/homelab/backups/flarum-20260116.sql

# FreshRSS recovery
docker stop freshrss
rm -rf /opt/homelab/services/freshrss/data
docker cp -r /opt/homelab/backups/freshrss-20260116 /opt/homelab/services/freshrss/data
docker start freshrss
```

## Backup Verification

### Integrity Checks
```bash
# Verify backup files
for backup in /opt/homelab/backups/databases/*.sql.gz; do
    echo "Checking $backup..."
    gunzip -t "$backup" && echo "OK" || echo "CORRUPTED"
done

# Test restore
docker exec postgres psql -U homelab -d test_db < /opt/homelab/backups/database_name-20260116.sql
```

### Restoration Tests
```bash
# Monthly restoration test
# Create test environment
docker compose -f docker-compose.test.yml up -d

# Test database restore
docker exec postgres psql -U homelab -d test_db < /opt/homelab/backups/database_name-20260116.sql

# Verify data integrity
docker exec postgres psql -U homelab -d test_db -c "SELECT COUNT(*) FROM users;"

# Clean up test environment
docker compose -f docker-compose.test.yml down
```

## Monitoring and Alerts

### Backup Monitoring
```bash
# Check backup status
ls -la /opt/homelab/backups/databases/ | grep "$(date +%Y%m%d)"

# Check backup size
du -sh /opt/homelab/backups/

# Check backup logs
tail -20 /opt/homelab/logs/backup.log
```

### Alert Configuration
```bash
# Backup failure alert
if [ ! -f "/opt/homelab/backups/databases/postgres-$(date +%Y%m%d).sql.gz" ]; then
    echo "Backup failed for $(date +%Y%m%d)" | mail -s "Backup Alert" admin@brennan.page
fi

# Disk space alert
if [ $(df /opt/homelab/backups | awk 'NR==2 {print $5}' | sed 's/%//') -gt 80 ]; then
    echo "Backup disk usage: $(df /opt/homelab/backups | awk 'NR==2 {print $5}')" | mail -s "Disk Space Alert" admin@brennan.page
fi
```

## Best Practices

### Backup Strategy
- **3-2-1 Rule**: 3 copies, 2 different media, 1 offsite
- **Regular Testing**: Test restores monthly
- **Encryption**: Encrypt sensitive backups
- **Documentation**: Document backup procedures

### Security
- **Access Control**: Limit backup access
- **Encryption**: Encrypt backup files
- **Secure Storage**: Use secure storage locations
- **Audit Logs**: Maintain backup audit logs

### Performance
- **Compression**: Compress backup files
- **Deduplication**: Remove duplicate data
- **Scheduling**: Schedule backups during low usage
- **Monitoring**: Monitor backup performance

## Getting Help

### Before Reporting Issues
- [ ] Checked backup logs
- [ ] Verified backup files exist
- [ ] Tested backup integrity
- [ ] Checked available storage

### Information to Include
- Backup script output
- Error messages
- System status
- Recent changes
- Storage usage
