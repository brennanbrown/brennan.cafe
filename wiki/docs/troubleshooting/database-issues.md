# Database Issues

Database-related problems and their solutions.

## PostgreSQL Issues

### Connection Problems

**Symptoms:**
- Services can't connect to database
- Connection timeouts
- "Connection refused" errors

**Diagnosis:**
```bash
# Check PostgreSQL status
docker ps | grep postgres

# Test database connectivity
docker exec postgres psql -U homelab -d homelab -c "SELECT 1;"

# Check database logs
docker logs postgres --tail 50

# Check network connectivity
docker exec service_name ping postgres
```

**Solutions:**

#### Restart Database
```bash
# Restart PostgreSQL
docker restart postgres

# Wait for startup
sleep 10

# Test connection
docker exec postgres psql -U homelab -d homelab -c "SELECT 1;"
```

#### User Authentication Issues
```bash
# Check existing users
docker exec postgres psql -U homelab -d homelab -c "\du"

# Recreate user
docker exec postgres psql -U homelab -d homelab -c "
  DROP USER IF EXISTS service_user;
  CREATE USER service_user WITH PASSWORD 'password';
  GRANT ALL PRIVILEGES ON DATABASE service_db TO service_user;
"

# Test new user
docker exec postgres psql -U service_user -d service_db -c "SELECT 1;"
```

#### Network Issues
```bash
# Check network configuration
docker network ls
docker network inspect network_name

# Reconnect service to network
docker network connect network_name service_name
```

### Database Performance

**Symptoms:**
- Slow queries
- High memory usage
- Database locks

**Diagnosis:**
```bash
# Check active connections
docker exec postgres psql -U homelab -d homelab -c "SELECT count(*) FROM pg_stat_activity;"

# Check slow queries
docker exec postgres psql -U homelab -d homelab -c "
  SELECT query, mean_time, calls 
  FROM pg_stat_statements 
  ORDER BY mean_time DESC 
  LIMIT 10;
"

# Check database size
docker exec postgres psql -U homelab -d homelab -c "
  SELECT pg_database.datname, 
         pg_size_pretty(pg_database.datname) 
  FROM pg_database.datname;
"
```

**Solutions:**

#### Optimize Database
```bash
# Vacuum and analyze
docker exec postgres psql -U homelab -d homelab -c "VACUUM ANALYZE;"

# Reindex database
docker exec postgres psql -U homelab -d homelab -c "REINDEX DATABASE homelab;"

# Update statistics
docker exec postgres psql -U homelab -d homelab -c "ANALYZE;"
```

#### Connection Pooling
```yaml
# Update service configuration
environment:
  - DB_MAX_CONNECTIONS=20
  - DB_MIN_CONNECTIONS=5
```

### Storage Issues

**Symptoms:**
- Disk space full
- Database corruption
- WAL file growth

**Diagnosis:**
```bash
# Check disk usage
df -h

# Check database size
docker exec postgres psql -U homelab -d homelab -c "
  SELECT pg_size_pretty(pg_database_size('homelab'));
"

# Check WAL files
docker exec postgres du -sh /var/lib/postgresql/pg_wal
```

**Solutions:**

#### Clean Up WAL Files
```bash
# Archive old WAL files
docker exec postgres psql -U homelab -d homelab -c "SELECT pg_switch_wal();"

# Reduce WAL retention
docker exec postgres psql -U homelab -d postgres -c "
  ALTER SYSTEM SET wal_keep_segments = 10;
"
```

#### Vacuum Full
```bash
# Perform full vacuum (requires exclusive access)
docker exec postgres psql -U homelab -d homelab -c "VACUUM FULL;"
```

## MariaDB/MySQL Issues

### Connection Problems
```bash
# Check MariaDB status
docker ps | grep mariadb

# Test connection
docker exec mariadb mysql -u root -prootpassword123 -e "SELECT 1;"

# Check logs
docker logs mariadb --tail 50
```

### Performance Issues
```bash
# Optimize tables
docker exec mariadb mysql -u root -prootpassword123 -e "
  OPTIMIZE TABLE flarum_posts;
  OPTIMIZE TABLE flarum_users;
"

# Check slow queries
docker exec mariadb mysql -u root -prootpassword123 -e "
  SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;
"
```

## Database Backup and Recovery

### PostgreSQL Backup
```bash
# Full database backup
docker exec postgres pg_dump -U homelab homelab > /opt/homelab/backups/postgres-$(date +%Y%m%d).sql

# Individual database backup
docker exec postgres pg_dump -U homelab freshrss > /opt/homelab/backups/freshrss-$(date +%Y%m%d).sql

# Compressed backup
docker exec postgres pg_dump -U homelab homelab | gzip > /opt/homelab/backups/postgres-$(date +%Y%m%d).sql.gz
```

### PostgreSQL Restore
```bash
# Restore full database
docker exec postgres psql -U homelab -d homelab < /opt/homelab/backups/postgres-20260116.sql

# Restore individual database
docker exec postgres psql -U homelab -d freshrss < /opt/homelab/backups/freshrss-20260116.sql

# Drop and recreate database
docker exec postgres psql -U homelab -d postgres -c "DROP DATABASE IF EXISTS old_db;"
docker exec postgres psql -U homelab -d postgres -c "CREATE DATABASE new_db;"
```

### MariaDB Backup
```bash
# Full backup
docker exec mariadb mysqldump -u root -prootpassword123 --all-databases > /opt/homelab/backups/mariadb-$(date +%Y%m%d).sql

# Individual database backup
docker exec mariadb mysqldump -u root -prootpassword123 flarum > /opt/homelab/backups/flarum-$(date +%Y%m%d).sql
```

### MariaDB Restore
```bash
# Restore full backup
docker exec mariadb mysql -u root -prootpassword123 < /opt/homelab/backups/mariadb-20260116.sql

# Restore individual database
docker exec mariadb mysql -u root -prootpassword123 flarum < /opt/homelab/backups/flarum-20260116.sql
```

## Database Migration

### PostgreSQL Version Upgrade
```bash
# Check current version
docker exec postgres psql -U homelab -d homelab -c "SELECT version();"

# Backup before upgrade
docker exec postgres pg_dump -U homelab homelab > /opt/homelab/backups/pre-upgrade.sql

# Upgrade PostgreSQL (update docker-compose.yml image)
docker compose down
docker compose up -d

# Run upgrade
docker exec postgres pg_upgrade -U homelab -d homelab -b /opt/homelab/backups/pre-upgrade.sql
```

### Data Migration
```bash
# Export data
docker exec postgres pg_dump -U homelab -d old_db > /opt/homelab/backups/old_db.sql

# Create new database
docker exec postgres psql -U homelab -d postgres -c "CREATE DATABASE new_db;"

# Import data
docker exec postgres psql -U homelab -d new_db < /opt/homelab/backups/old_db.sql
```

## Prevention

### Regular Maintenance
- [ ] Monitor database size
- [ ] Check connection limits
- [ ] Run regular backups
- [ ] Optimize performance

### Best Practices
- Set appropriate connection limits
- Use connection pooling
- Monitor slow queries
- Keep regular backups

### Monitoring
```bash
# Database size monitoring
docker exec postgres psql -U homelab -d homelab -c "
  SELECT pg_database.datname, 
         pg_size_pretty(pg_database_size(pg_database.datname)) 
  FROM pg_database.datname;
"

# Connection monitoring
docker exec postgres psql -U homelab -d homelab -c "SELECT count(*) FROM pg_stat_activity;"

# Performance monitoring
docker exec postgres psql -U homelab -d homelab -c "
  SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit
  FROM pg_stat_database 
  WHERE datname = 'homelab';
"
```

## Getting Help

### Before Reporting Issues
- [ ] Checked database connectivity
- [ ] Verified user permissions
- [ ] Tested basic queries
- [ ] Reviewed error logs

### Information to Include
- Database version
- Connection test results
- Error messages
- Recent changes
- Performance statistics
