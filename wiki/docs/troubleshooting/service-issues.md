# Service Issues

Common service-related problems and their solutions.

## Container Issues

### Container Not Starting

**Symptoms:**
- Container shows as "Exited" or "Restarting"
- HTTP 502/503 errors
- Service not responding

**Diagnosis:**
```bash
# Check service status
docker ps -a | grep service_name

# Check service logs
docker logs service_name --tail 50

# Check resource usage
docker stats service_name

# Check system resources
free -h
df -h
```

**Solutions:**

#### Memory Issues
```bash
# Check memory usage
docker stats service_name --no-stream

# Increase memory limit
# Edit docker-compose.yml and increase mem_limit
mem_limit: 256m
```

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :port

# Change port in docker-compose.yml
ports:
  - "8081:80"  # Use different port
```

#### Volume Issues
```bash
# Check volumes
docker volume ls
docker volume inspect volume_name

# Fix permissions
docker exec service_name chown -R user:user /data
```

#### Configuration Errors
```bash
# Check environment variables
docker exec service_name env

# Validate configuration file
docker exec service_name cat /path/to/config
```

### Container Restarts

**Symptoms:**
- Container keeps restarting
- Service unstable
- Memory leaks

**Solutions:**

#### Check Logs
```bash
# Check recent logs
docker logs service_name --tail 100

# Look for error patterns
docker logs service_name | grep -i error
```

#### Resource Limits
```bash
# Check resource limits
docker inspect service_name | grep -A 10 "Resources"

# Increase limits
docker update service_name --memory=512m
```

#### Health Checks
```bash
# Check health status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}"

# Test health endpoint
curl -f http://localhost:port/health || echo "Health check failed"
```

## File System Issues

### Permission Problems
```bash
# Check file permissions
docker exec service_name ls -la /path/to/files

# Fix permissions
docker exec service_name chown -R user:user /path/to/files
docker exec service_name chmod -R 755 /path/to/files
```

### Disk Space Issues
```bash
# Check disk usage
df -h

# Check container disk usage
docker exec service_name du -sh /data

# Clean up old files
docker exec service_name find /data -name "*.log" -mtime +30 -delete
```

### Volume Corruption
```bash
# Check volume integrity
docker volume inspect volume_name

# Recreate volume
docker volume rm volume_name
docker volume create volume_name
```

## Network Issues

### Service Not Accessible
```bash
# Check port mapping
docker port service_name

# Test direct access
curl -I http://localhost:port

# Check network connectivity
docker exec service_name ping google.com
```

### DNS Problems
```bash
# Check DNS resolution
docker exec service_name nslookup service.brennan.page

# Test external DNS
docker exec service_name ping 8.8.8.8
```

### Proxy Issues
```bash
# Check Caddy configuration
docker exec caddy cat /etc/caddy/Caddyfile | grep -A 5 service_name

# Test proxy
curl -H "Host: service.brennan.page" http://localhost:port

# Reload Caddy
docker restart caddy
```

## Performance Issues

### Slow Response Times
```bash
# Check resource usage
docker stats --no-stream

# Check system load
uptime
free -h

# Optimize database
docker exec postgres psql -U homelab -d homelab -c "VACUUM ANALYZE;"
```

### High Memory Usage
```bash
# Check memory usage
docker stats --no-stream

# Clean up Docker
docker system prune -f

# Restart services
docker compose restart
```

### High CPU Usage
```bash
# Check CPU usage
docker stats --no-stream

# Identify process
docker exec service_name top

# Restart service
docker restart service_name
```

## Recovery Procedures

### Service Backup
```bash
# Backup service data
docker cp -r /opt/homelab/services/service_name /opt/homelab/backups/service_name-$(date +%Y%m%d)

# Backup configuration
docker cp /opt/homelab/services/service_name/docker-compose.yml /opt/homelab/backups/
```

### Service Restore
```bash
# Stop service
docker stop service_name

# Remove current data
rm -rf /opt/homelab/services/service_name/data

# Restore from backup
docker cp -r /opt/homelab/backups/service_name-20260116 /opt/homelab/services/service_name/data

# Start service
docker start service_name
```

### Complete Reset
```bash
# Stop and remove everything
docker compose down
rm -rf data
docker volume rm service_volume

# Start fresh
docker compose up -d
```

## Prevention

### Regular Maintenance
- [ ] Monitor resource usage
- [ ] Check error logs
- [ ] Update services regularly
- [ ] Backup data

### Best Practices
- Set appropriate memory limits
- Use health checks
- Monitor disk space
- Keep configurations in version control

### Monitoring
```bash
# System monitoring
docker stats --no-stream

# Log monitoring
docker logs service_name --tail 100 | grep -i error

# Health monitoring
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}"
```

## Getting Help

### Before Reporting Issues
- [ ] Checked container logs
- [ ] Verified resource usage
- [ ] Tested basic connectivity
- [ ] Attempted service restart

### Information to Include
- Container status and logs
- Resource usage statistics
- Network configuration
- Recent changes
- Steps already taken
