# FreshRSS Troubleshooting

FreshRSS is an RSS feed aggregator. This page covers common issues and solutions.

## Common Issues

### Installation Problems

**Symptoms:**
- "FreshRSS error during installation!"
- "default-user cannot be empty" error
- Service shows installation page despite being configured

**Root Causes:**
- Missing FRESHRSS_DEFAULT_USER environment variable
- Installation parameters not properly formatted
- Database connection issues

**Solutions:**

#### Proper Installation Parameters
```yaml
# Add proper installation parameters to docker-compose.yml
services:
  freshrss:
    image: freshrss/freshrss:latest
    environment:
      - TZ=America/Toronto
      - CRON_MIN=2,32
      - FRESHRSS_INSTALL=--api-enabled --base-url https://rss.brennan.page --db-base freshrss --db-host postgresql --db-password freshrss_password --db-type pgsql --default-user admin --language en
      - FRESHRSS_USER=--api-password admin123 --email admin@brennan.page --language en --password admin123 --user admin
```

#### Complete Installation
```bash
# Restart FreshRSS with correct configuration
docker compose down
docker compose up -d

# Check installation logs
docker logs freshrss --tail 20
```

### Database Connection Issues

**Symptoms:**
- Cannot connect to PostgreSQL database
- Installation fails with database errors
- Service restarts continuously

**Solutions:**

#### Verify Database Connectivity
```bash
# Test connection from FreshRSS container
docker exec freshrss ping -c 2 postgresql

# Check database user permissions
docker exec postgres psql -U homelab -d freshrss -c "\du"

# Test connection directly
docker exec freshrss php -r "new PDO('pgsql:host=postgresql;dbname=freshrss', 'freshrss', 'freshrss_password');"
```

#### Fix Database Permissions
```bash
# Recreate database user
docker exec postgres psql -U homelab -d postgres -c "
  DROP USER IF EXISTS freshrss;
  CREATE USER freshrss WITH PASSWORD 'freshrss_password';
  GRANT ALL PRIVILEGES ON DATABASE freshrss TO freshrss;
"

# Restart FreshRSS
docker restart freshrss
```

### Feed Issues

**Symptoms:**
- Feeds not updating
- Feed errors in logs
- Slow feed refresh

**Solutions:**

#### Check Cron Configuration
```bash
# Verify cron is running
docker exec freshrss ps aux | grep cron

# Check cron logs
docker logs freshrss | grep -i cron
```

#### Manual Feed Refresh
```bash
# Access FreshRSS web interface
# Go to https://rss.brennan.page
# Click "Refresh all feeds" or individual feed refresh
```

#### Fix Feed URLs
```bash
# Check feed configuration
docker exec freshrss cat /data/config.php | grep -E 'base_url|host'
```

### Performance Issues

**Symptoms:**
- Slow feed loading
- High memory usage
- Database timeouts

**Solutions:**

#### Optimize Database
```bash
# Optimize PostgreSQL
docker exec postgres psql -U homelab -d freshrss -c "
  VACUUM ANALYZE;
  REINDEX DATABASE freshrss;
"
```

#### Increase Memory Limits
```yaml
# Update docker-compose.yml
services:
  freshrss:
    mem_limit: 128m
    mem_reservation: 64m
```

#### Clean Up Old Data
```bash
# Clean up old feed entries
docker exec freshrss php -r "
  // Remove entries older than 30 days
  \$pdo = new PDO('pgsql:host=postgresql;dbname=freshrss', 'freshrss', 'freshrss_password');
  \$pdo->exec('DELETE FROM entries WHERE date < NOW() - INTERVAL 30 days');
"
```

## Quick Fixes

### Installation Errors
```bash
# Restart FreshRSS
docker restart freshrss

# Check logs
docker logs freshrss --tail 20

# Verify environment variables
docker exec freshrss env | grep FRESHRSS
```

### Database Connection
```bash
# Test PostgreSQL connection
docker exec freshrss ping -c 2 postgresql

# Restart database
docker restart postgresql

# Restart FreshRSS
docker restart freshrss
```

### Feed Not Updating
```bash
# Check cron service
docker exec freshrss ps aux | grep cron

# Manual feed refresh
curl -X POST https://rss.brennan.page/api/refresh
```

### Access Issues
```bash
# Check service status
docker ps | grep freshrss

# Test direct access
curl -I http://localhost:80

# Check Caddy proxy
curl -I https://rss.brennan.page
```

## Recovery Procedures

### Data Backup
```bash
# Backup FreshRSS configuration
docker cp -r /opt/homelab/services/freshrss/data /opt/homelab/backups/freshrss-$(date +%Y%m%d)

# Backup database
docker exec postgres pg_dump -U homelab freshrss > /opt/homelab/backups/freshrss-db-$(date +%Y%m%d).sql
```

### Data Restore
```bash
# Stop service
docker stop freshrss

# Remove current data
rm -rf /opt/homelab/services/freshrss/data

# Restore from backup
docker cp -r /opt/homelab/backups/freshrss-20260116 /opt/homelab/services/freshrss/data

# Start service
docker start freshrss
```

### Complete Reset
```bash
# Stop and remove everything
docker compose down
rm -rf data
docker volume rm freshrss_freshrss_data

# Start fresh
docker compose up -d
```

## Prevention

### Regular Maintenance
- [ ] Monitor feed update frequency
- [ ] Check database size
- [ ] Clean up old entries
- [ ] Backup data regularly

### Best Practices
- Use PostgreSQL for better performance
- Set proper memory limits (128m minimum)
- Configure cron for automatic updates
- Keep database backups

### Performance Optimization
```yaml
# Recommended docker-compose.yml
services:
  freshrss:
    image: freshrss/freshrss:latest
    mem_limit: 128m
    mem_reservation: 64m
    environment:
      - TZ=America/Toronto
      - CRON_MIN=2,32
      - FRESHRSS_INSTALL=--api-enabled --base-url https://rss.brennan.page --db-base freshrss --db-host postgresql --db-password freshrss_password --db-type pgsql --default-user admin --language en
      - FRESHRSS_USER=--api-password admin123 --email admin@brennan.page --language en --password admin123 --user admin
```

## Getting Help

### Before Reporting Issues
- [ ] Checked PostgreSQL connectivity
- [ ] Verified installation completion
- [ ] Tested feed updates
- [ ] Reviewed error logs

### Information to Include
- Installation status
- Database connection test results
- Feed update logs
- Container logs
- Docker compose configuration
