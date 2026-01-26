# Common Issues

This section covers common issues that may occur with the brennan.page homelab infrastructure and their solutions.

## Service Access Issues

### Service Not Accessible

**Symptoms:**
- Service returns 404 error
- Service returns 502 error
- Service times out
- SSL certificate errors

**Solutions:**

1. **Check Service Status**
   ```bash
   docker ps | grep service_name
   ```

2. **Check Service Logs**
   ```bash
   docker logs service_name --tail 50
   ```

3. **Check Caddy Configuration**
   ```bash
   docker exec caddy caddy validate /etc/caddy/Caddyfile
   docker exec caddy caddy reload --config /etc/caddy/Caddyfile
   ```

4. **Check Network Connectivity**
   ```bash
   docker exec caddy curl -f http://service_name:port/
   ```

5. **Restart Services**
   ```bash
   docker restart service_name
   docker restart caddy
   ```

### SSL Certificate Issues

**Symptoms:**
- Certificate expired warnings
- Certificate not trusted
- Mixed content errors

**Solutions:**

1. **Check Certificate Status**
   ```bash
   docker exec caddy caddy list-certificates
   ```

2. **Force Certificate Renewal**
   ```bash
   docker exec caddy caddy reload --config /etc/caddy/Caddyfile
   ```

3. **Check Domain Configuration**
   ```bash
   nslookup service.brennan.page
   dig service.brennan.page
   ```

## Database Issues

### Database Connection Failed

**Symptoms:**
- Service cannot connect to database
- Authentication errors
- Connection timeout errors

**Solutions:**

1. **Check Database Status**
   ```bash
   # PostgreSQL
   docker exec postgresql pg_isready
   
   # MariaDB
   docker exec flarum_mariadb mysqladmin ping
   ```

2. **Check Database Credentials**
   ```bash
   # Check environment variables
   docker exec service_name env | grep DB_
   
   # Test connection manually
   docker exec postgresql psql -U user -d database -c "SELECT 1;"
   ```

3. **Check Network Connectivity**
   ```bash
   docker network ls
   docker exec service_name ping database_container
   ```

4. **Reset Database Password**
   ```bash
   # PostgreSQL
   docker exec postgresql psql -U postgres -c "ALTER USER user PASSWORD 'new_password';"
   
   # MariaDB
   docker exec flarum_mariadb mysql -u root -p -e "SET PASSWORD FOR 'user'@'%' = 'new_password';"
   ```

### Database Performance Issues

**Symptoms:**
- Slow database queries
- High CPU usage
- Memory issues

**Solutions:**

1. **Check Database Performance**
   ```bash
   # PostgreSQL
   docker exec postgresql psql -U user -d database -c "SELECT * FROM pg_stat_activity;"
   
   # MariaDB
   docker exec flarum_mariadb mysql -u root -p -e "SHOW PROCESSLIST;"
   ```

2. **Optimize Database**
   ```bash
   # PostgreSQL
   docker exec postgresql psql -U user -d database -c "VACUUM ANALYZE;"
   
   # MariaDB
   docker exec flarum_mariadb mysql -u root -p -e "OPTIMIZE TABLE table_name;"
   ```

3. **Check Resource Usage**
   ```bash
   docker stats postgresql
   docker stats flarum_mariadb
   ```

## Performance Issues

### High Memory Usage

**Symptoms:**
- Services using excessive memory
- Out of memory errors
- System slowdown

**Solutions:**

1. **Check Resource Usage**
   ```bash
   docker stats
   free -h
   ```

2. **Identify Memory-Hungry Services**
   ```bash
   docker stats --no-stream --format "table {{.Names}}\t{{.MemUsage}}"
   ```

3. **Restart Services**
   ```bash
   docker restart service_name
   ```

4. **Adjust Memory Limits**
   ```yaml
   # In docker-compose.yml
   services:
     service_name:
       mem_limit: 512m
       mem_reservation: 256m
   ```

### Slow Response Times

**Symptoms:**
- Services responding slowly
- High latency
- Timeouts

**Solutions:**

1. **Check Response Times**
   ```bash
   curl -w "Response time: %{time_total}s\n" -o /dev/null -s https://service.brennan.page
   ```

2. **Check Resource Usage**
   ```bash
   docker stats service_name
   ```

3. **Check Database Performance**
   ```bash
   docker exec postgresql psql -U user -d database -c "SELECT * FROM pg_stat_activity WHERE state = 'active';"
   ```

4. **Optimize Configuration**
   ```bash
   # Check service configuration
   docker exec service_name cat /etc/service/config.conf
   ```

## Container Issues

### Container Won't Start

**Symptoms:**
- Container exits immediately
- Container restarts repeatedly
- Container stuck in starting state

**Solutions:**

1. **Check Container Logs**
   ```bash
   docker logs service_name --tail 100
   ```

2. **Check Container Configuration**
   ```bash
   docker compose config
   ```

3. **Check Resource Limits**
   ```bash
   docker inspect service_name | grep -A 10 -B 10 "Memory"
   ```

4. **Rebuild Container**
   ```bash
   cd /opt/homelab/services/service_name
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

### Container Health Issues

**Symptoms:**
- Health check failing
- Unhealthy status
- Service not responding

**Solutions:**

1. **Check Health Status**
   ```bash
   docker ps --format "table {{.Names}}\t{{.Status}}"
   ```

2. **Check Health Configuration**
   ```bash
   docker inspect service_name | grep -A 10 -B 10 "Health"
   ```

3. **Test Health Endpoint**
   ```bash
   docker exec service_name curl -f http://localhost:port/health
   ```

4. **Fix Health Issues**
   ```bash
   # Check service logs
   docker logs service_name --tail 50
   
   # Restart service
   docker restart service_name
   ```

## Network Issues

### Network Connectivity Problems

**Symptoms:**
- Services cannot communicate
- DNS resolution failures
- Port binding issues

**Solutions:**

1. **Check Network Configuration**
   ```bash
   docker network ls
   docker network inspect network_name
   ```

2. **Check Container Networks**
   ```bash
   docker inspect service_name | grep -A 10 -B 10 "Networks"
   ```

3. **Test Connectivity**
   ```bash
   docker exec service_name ping other_service
   docker exec service_name nslookup google.com
   ```

4. **Recreate Networks**
   ```bash
   docker network rm network_name
   docker network create network_name
   ```

### Port Conflicts

**Symptoms:**
- Port already in use errors
- Service cannot bind to port
- Connection refused errors

**Solutions:**

1. **Check Port Usage**
   ```bash
   netstat -tulpn | grep :port
   lsof -i :port
   ```

2. **Find Conflicting Service**
   ```bash
   docker ps --format "table {{.Names}}\t{{.Ports}}"
   ```

3. **Stop Conflicting Service**
   ```bash
   docker stop conflicting_service
   ```

4. **Change Port Configuration**
   ```yaml
   # In docker-compose.yml
   services:
     service_name:
       ports:
         - "8080:80"  # Change port mapping
   ```

## Storage Issues

### Disk Space Issues

**Symptoms:**
- Out of disk space errors
- Services cannot write files
- Backup failures

**Solutions:**

1. **Check Disk Usage**
   ```bash
   df -h
   du -sh /opt/homelab/*
   ```

2. **Find Large Files**
   ```bash
   find /opt/homelab -type f -size +100M
   ```

3. **Clean Up Old Files**
   ```bash
   # Clean old logs
   find /var/log -name "*.log" -mtime +30 -delete
   
   # Clean old backups
   find /opt/homelab/backups -name "*.tar.gz" -mtime +7 -delete
   ```

4. **Clean Docker Resources**
   ```bash
   docker system prune -a
   ```

### Volume Issues

**Symptoms:**
- Volume mount errors
- Data not persisting
- Permission errors

**Solutions:**

1. **Check Volume Status**
   ```bash
   docker volume ls
   docker volume inspect volume_name
   ```

2. **Check Volume Permissions**
   ```bash
   docker exec service_name ls -la /path/to/volume
   ```

3. **Fix Volume Permissions**
   ```bash
   docker exec service_name chown -R user:group /path/to/volume
   ```

4. **Recreate Volume**
   ```bash
   docker volume rm volume_name
   docker volume create volume_name
   ```

## Authentication Issues

### Login Problems

**Symptoms:**
- Cannot log in to services
- Authentication failures
- Password errors

**Solutions:**

1. **Check Authentication Configuration**
   ```bash
   docker exec service_name cat /etc/service/auth.conf
   ```

2. **Reset Passwords**
   ```bash
   # Reset service admin password
   docker exec service_name service-cli reset-password
   ```

3. **Check User Accounts**
   ```bash
   docker exec service_name service-cli list-users
   ```

4. **Create Admin User**
   ```bash
   docker exec service_name service-cli create-admin admin password
   ```

## Configuration Issues

### Configuration Errors

**Symptoms:**
- Service won't start with configuration errors
- Invalid configuration syntax
- Missing configuration files

**Solutions:**

1. **Validate Configuration**
   ```bash
   docker compose config
   ```

2. **Check Configuration Files**
   ```bash
   docker exec service_name cat /etc/service/config.conf
   ```

3. **Fix Configuration Syntax**
   ```bash
   # Use configuration validation tools
   service-config-validator /path/to/config.conf
   ```

4. **Reset Configuration**
   ```bash
   # Copy default configuration
   docker exec service_name cp /etc/service/default.conf /etc/service/config.conf
   ```

## Monitoring Issues

### Monitoring Not Working

**Symptoms:**
- Monitoring dashboard not updating
- Metrics not collecting
- Alerting not working

**Solutions:**

1. **Check Monitoring Service**
   ```bash
   docker ps | grep monitor
   docker logs monitor --tail 50
   ```

2. **Check Metrics Collection**
   ```bash
   curl -f http://localhost:port/metrics
   ```

3. **Check Alert Configuration**
   ```bash
   docker exec monitor cat /etc/monitor/alerts.conf
   ```

4. **Restart Monitoring Service**
   ```bash
   docker restart monitor
   ```

## General Troubleshooting

### System-Wide Issues

**Symptoms:**
- Multiple services failing
- System-wide slowdown
- Resource exhaustion

**Solutions:**

1. **Check System Status**
   ```bash
   docker ps
   free -h
   df -h
   ```

2. **Check System Logs**
   ```bash
   journalctl -n 100 --no-pager
   ```

3. **Check Resource Usage**
   ```bash
   docker stats --no-stream
   top
   ```

4. **Restart System Services**
   ```bash
   systemctl restart docker
   systemctl restart caddy
   ```

### Recovery Procedures

**Complete System Recovery:**

1. **Stop All Services**
   ```bash
   cd /opt/homelab
   docker compose down
   ```

2. **Restore from Backup**
   ```bash
   ./scripts/restore.sh latest_backup.tar.gz
   ```

3. **Restart Services**
   ```bash
   docker compose up -d
   ```

4. **Verify System**
   ```bash
   ./scripts/health-check.sh
   ```

## Getting Help

### Documentation Resources

1. **Service Documentation**: Check service-specific documentation
2. **Operations Documentation**: Review operational procedures
3. **Reference Documentation**: Use command references
4. **Troubleshooting Guides**: Check specific troubleshooting guides

### Support Channels

1. **Service Logs**: Check service logs for error messages
2. **System Logs**: Review system logs for issues
3. **Health Checks**: Run health check scripts
4. **Community**: Check community forums and discussions

### Escalation

1. **Local Issues**: Try local troubleshooting first
2. **Service Issues**: Check service-specific documentation
3. **System Issues**: Check system-wide procedures
4. **Critical Issues**: Use emergency procedures

## Prevention

### Regular Maintenance

- **Daily**: Check service status and logs
- **Weekly**: Review performance metrics
- **Monthly**: Update dependencies and configurations
- **Quarterly**: Review and update documentation

### Monitoring

- **Health Checks**: Automated health monitoring
- **Performance Monitoring**: Resource usage tracking
- **Log Monitoring**: Error detection and alerting
- **Security Monitoring**: Security event monitoring

### Documentation

- **Keep Current**: Update documentation with changes
- **Review Regularly**: Review documentation for accuracy
- **Test Procedures**: Test troubleshooting procedures
- **Share Knowledge**: Share lessons learned

## References

- [Services Documentation](../services/) - Service-specific documentation
- [Operations Documentation](../operations/) - Operational procedures
- [Reference Documentation](../reference/) - Command references
- [Configuration Documentation](../configuration/) - Configuration management
