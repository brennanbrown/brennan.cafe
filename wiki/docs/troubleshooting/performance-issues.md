# Performance Issues

Performance-related problems and optimization techniques.

## System Performance

### High Resource Usage

**Symptoms:**
- Slow response times
- High CPU usage
- Memory exhaustion
- System unresponsiveness

**Diagnosis:**
```bash
# Check system load
uptime
free -h
df -h

# Check Docker resource usage
docker stats --no-stream

# Check individual processes
docker exec service_name top

# Check memory usage by service
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}"
```

**Solutions:**

#### Optimize Memory Usage
```bash
# Clean up Docker
docker system prune -f

# Remove unused volumes
docker volume prune -f

# Restart services
docker compose restart
```

#### Optimize CPU Usage
```bash
# Limit CPU usage
docker update service_name --cpus=0.5

# Set CPU limits in docker-compose.yml
services:
  service_name:
    cpus: 0.5
    cpuset: "0,1"
```

#### Increase Resources
```bash
# Check available resources
free -h
lscpu

# Increase memory limits
docker update service_name --memory=512m

# Update docker-compose.yml
services:
  service_name:
    mem_limit: 512m
    mem_reservation: 256m
```

### Disk I/O Issues

**Symptoms:**
- Slow disk operations
- High I/O wait
- Database performance issues

**Diagnosis:**
```bash
# Check disk I/O
iostat -x 1

# Check disk usage
df -h

# Check Docker disk usage
docker system df

# Check for disk I/O bottlenecks
docker exec service_name iotop
```

**Solutions:**

#### Optimize Disk Usage
```bash
# Clean up Docker images
docker image prune -f

# Clean up containers
docker container prune -f

# Clean up volumes
docker volume prune -f
```

#### Optimize Database Performance
```bash
# PostgreSQL optimization
docker exec postgres psql -U homelab -d homelab -c "VACUUM ANALYZE;"

# MariaDB optimization
docker exec mariadb mysql -u root -prootpassword123 -e "OPTIMIZE TABLE flarum_posts;"

# Check database size
docker exec postgres psql -U homelab -d homelab -c "
  SELECT pg_size_pretty(pg_database_size('homelab'));
"
```

## Application Performance

### Slow Web Applications

**Symptoms:**
- Slow page loads
- High latency
- Timeout errors

**Diagnosis:**
```bash
# Test response time
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://service.brennan.page

# Check application logs
docker logs service_name --tail 50 | grep -i error

# Check database queries
docker exec postgres psql -U homelab -d homelab -c "
  SELECT query, mean_time, calls 
  FROM pg_stat_statements 
  ORDER BY mean_time DESC 
  LIMIT 10;
"
```

**Solutions:**

#### Optimize Database Queries
```bash
# Add indexes to slow queries
docker exec postgres psql -U homelab -d homelab -c "
  CREATE INDEX CONCURRENTLY idx_slow_query ON table_name(column_name);
"

# Analyze query performance
docker exec postgres psql -U homelab -d homelab -c "EXPLAIN ANALYZE SELECT * FROM table_name WHERE condition;"
```

#### Enable Caching
```bash
# Add caching headers in Caddyfile
header {
    Cache-Control "public, max-age=3600"
    X-Content-Type-Options nosniff
}

# Enable compression
encode {
    gzip
    zstd
}
```

#### Optimize Application Code
```bash
# Check for memory leaks
docker exec service_name ps aux

# Monitor application performance
docker stats service_name --no-stream
```

### Database Performance

**Symptoms:**
- Slow query execution
- High memory usage
- Connection timeouts

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
         pg_size_pretty(pg_database_size(pg_database.datname)) 
  FROM pg_database.datname;
"
```

**Solutions:**

#### Database Optimization
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
# Optimize database connections
environment:
  - DB_MAX_CONNECTIONS=20
  - DB_MIN_CONNECTIONS=5
  - DB_TIMEOUT=30
```

#### Query Optimization
```bash
# Add missing indexes
docker exec postgres psql -U homelab -d homelab -c "
  CREATE INDEX CONCURRENTLY idx_user_email ON users(email);
  CREATE INDEX CONCURRENTLY idx_post_created ON posts(created_at);
"

# Optimize slow queries
docker exec postgres psql -U homelab -d homelab -c "
  EXPLAIN ANALYZE SELECT * FROM posts WHERE user_id = 123 ORDER BY created_at DESC;
"
```

## Network Performance

### High Latency

**Symptoms:**
- Slow response times
- High network latency
- Connection timeouts

**Diagnosis:**
```bash
# Test network latency
ping -c 4 brennan.page

# Test DNS resolution time
dig brennan.page | grep "Query time"

# Test service response time
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://service.brennan.page
```

**Solutions:**

#### Optimize Network Configuration
```bash
# Enable HTTP/2
{
    protocols h1 h2 h3
}

# Enable compression
encode {
    gzip
    zstd
}

# Set timeouts
timeouts {
    read 30s
    write 30s
    idle 60s
}
```

#### Enable Caching
```bash
# Add caching headers
header {
    Cache-Control "public, max-age=3600"
    ETag "W/\"{etag}\""
}

# Enable browser caching
@static {
    header Cache-Control "public, max-age=86400"
}
```

### Bandwidth Optimization

**Symptoms:**
- High data transfer costs
- Slow downloads
- Bandwidth throttling

**Diagnosis:**
```bash
# Monitor bandwidth usage
iftop -t

# Check large files
find /opt/homelab -type f -size +100M -exec ls -lh {} \;

# Check Docker network usage
docker stats --no-stream | grep -E "NETWORK|P/S"
```

**Solutions:**

#### Enable Compression
```bash
# Enable gzip compression
encode gzip

# Test compression
curl -H "Accept-Encoding: gzip" -I https://service.brennan.page

# Check compression ratio
curl -H "Accept-Encoding: gzip" -s https://service.brennan.page | wc -c
curl -s https://service.brennan.page | wc -c
```

#### Optimize Assets
```bash
# Minimize CSS/JS files
# Use efficient image formats (WebP, AVIF)
# Enable lazy loading
# Use CDN for static assets
```

## Monitoring and Metrics

### Performance Monitoring

**System Metrics:**
```bash
# System overview
htop

# Docker metrics
docker stats --no-stream

# Service-specific metrics
docker exec service_name ps aux
```

**Application Metrics:**
```bash
# Response time monitoring
curl -w "@json_format{ \"time_total\": %{time_total}, \"time_connect\": %{time_connect} }\n" -o /dev/null -s https://service.brennan.page

# Error rate monitoring
docker logs service_name --since=1h | grep -c "ERROR"

# Throughput monitoring
docker exec service_name netstat -an | grep :80 | wc -l
```

**Database Metrics:**
```bash
# Connection count
docker exec postgres psql -U homelab -d homelab -c "SELECT count(*) FROM pg_stat_activity;"

# Query performance
docker exec postgres psql -U homelab -d homelab -c "
  SELECT query, mean_time, calls 
  FROM pg_stat_statements 
  ORDER BY mean_time DESC 
  LIMIT 5;
"

# Database size
docker exec postgres psql -U homelab -d homelab -c "
  SELECT pg_size_pretty(pg_database_size('homelab'));
"
```

### Alerting

**Resource Alerts:**
```bash
# Memory usage alert
if [ $(free | awk '/^Mem:/ {print $3}' | sed 's/%//') -gt 90 ]; then
    echo "High memory usage alert"
fi

# Disk usage alert
if [ $(df / | awk 'NR==2 {print $5}' | sed 's/%//') -gt 80 ]; then
    echo "High disk usage alert"
fi

# Service restart alert
docker ps --format "{{.Names}}\t{{.Status}}" | grep -q "Restarting" && echo "Service restart alert"
```

## Prevention

### Regular Maintenance
- [ ] Monitor resource usage
- [ ] Optimize database regularly
- [ ] Clean up unused resources
- [ ] Update software regularly

### Best Practices
- Set appropriate resource limits
- Use connection pooling
- Enable caching
- Monitor performance metrics

### Performance Tuning
```yaml
# Recommended docker-compose.yml
services:
  service_name:
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5
    environment:
      - DB_MAX_CONNECTIONS=20
      - DB_MIN_CONNECTIONS=5
```

## Getting Help

### Before Reporting Issues
- [ ] Checked resource usage
- [ ] Monitored performance metrics
- [ ] Tested basic functionality
- [ ] Reviewed optimization settings

### Information to Include
- Resource usage statistics
- Performance metrics
- Error logs
- Recent changes
- Optimization attempts
