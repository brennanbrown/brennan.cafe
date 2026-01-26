# Services

This section contains detailed documentation for all services running in the brennan.page homelab. Each service has its own configuration, management procedures, and troubleshooting guide.

## Service Categories

### Infrastructure Services
- **[Caddy](caddy.md)** - Reverse proxy with automatic HTTPS
- **[PostgreSQL](postgresql.md)** - Primary database server
- **[MariaDB](mariadb.md)** - Database server for Flarum

### Management Services
- **[Portainer](portainer.md)** - Docker management interface
- **[FileBrowser](filebrowser.md)** - File management interface
- **[Monitor](monitor.md)** - System monitoring dashboard

### Productivity Services
- **[Vikunja](vikunja.md)** - Task management system
- **[HedgeDoc](hedgedoc.md)** - Collaborative markdown notes
- **[Linkding](linkding.md)** - Bookmark manager
- **[Navidrome](navidrome.md)** - Music streaming server

### Content & Community Services
- **[WriteFreely](writefreely.md)** - Blog platform
- **[Flarum](flarum.md)** - Community forum
- **[FreshRSS](freshrss.md)** - RSS feed aggregator

## Quick Reference

| Service | Subdomain | Status | Database | Memory Limit |
|---------|-----------|--------|----------|--------------|
| Caddy | - | 🟢 Critical | None | 256MB |
| PostgreSQL | - | 🟢 Critical | Self | 256MB |
| MariaDB | - | 🟢 High | Self | 256MB |
| Portainer | docker.brennan.page | 🟢 High | None | 100MB |
| FileBrowser | files.brennan.page | 🟢 Medium | None | 50MB |
| Monitor | monitor.brennan.page | 🟢 High | None | 50MB |
| Vikunja | tasks.brennan.page | 🟢 Medium | PostgreSQL | 100MB |
| HedgeDoc | notes.brennan.page | 🟢 Medium | PostgreSQL | 100MB |
| Linkding | bookmarks.brennan.page | 🟢 Medium | PostgreSQL | 50MB |
| Navidrome | music.brennan.page | 🟢 Low | PostgreSQL | 100MB |
| WriteFreely | blog.brennan.page | 🟢 Medium | PostgreSQL | 100MB |
| Flarum | forum.brennan.page | 🟢 Medium | MariaDB | 200MB |
| FreshRSS | rss.brennan.page | 🟢 Low | PostgreSQL | 100MB |

## Service Architecture

### Network Configuration
All services are connected to appropriate Docker networks:
- **caddy**: External network for reverse proxy
- **internal_db**: Internal network for database communication
- **monitoring**: Internal network for monitoring services

### Database Architecture
- **PostgreSQL**: Primary database for most services
- **MariaDB**: Dedicated database for Flarum forum
- **Isolation**: Each service has its own database and user

### Resource Management
- **Total Memory**: 2GB system limit
- **Allocated**: ~1.3GB across all services
- **Swap**: 4GB available for burst capacity
- **Monitoring**: Continuous resource usage tracking

## Common Management Tasks

### Starting/Stopping Services
```bash
# Start a service
docker start service_name

# Stop a service
docker stop service_name

# Restart a service
docker restart service_name

# View service logs
docker logs service_name --tail 50
```

### Database Operations
```bash
# PostgreSQL operations
docker exec postgresql psql -U user -d database

# MariaDB operations
docker exec flarum_mariadb mysql -u user -p database

# Check database status
docker exec postgresql pg_isready
docker exec flarum_mariadb mysqladmin ping
```

### Health Checks
```bash
# Check all services
docker ps

# Check specific service
curl -f https://service.brennan.page

# Monitor resource usage
docker stats
```

## Troubleshooting

### Common Issues
- **Service Not Accessible**: Check Caddy configuration and service status
- **Database Connection**: Verify database container and credentials
- **Performance Issues**: Check resource limits and container stats
- **SSL Problems**: Verify Caddy SSL certificate status

### Getting Help
1. Check the specific service documentation below
2. Review service logs for error messages
3. Check the [Troubleshooting](../troubleshooting/) section
4. Use the [SSH Reference](../reference/ssh-commands.md) for server management

## Service-Specific Documentation

Each service has comprehensive documentation including:
- **Configuration**: Docker compose and environment variables
- **Management**: Admin interfaces and common operations
- **Database**: Schema and management commands
- **Performance**: Resource usage and optimization
- **Security**: Access control and best practices
- **Troubleshooting**: Common issues and solutions
- **Backup**: Backup and recovery procedures

## Maintenance Schedule

### Daily
- Check service status and resource usage
- Review error logs
- Verify backup completion

### Weekly
- Check for service updates
- Review performance metrics
- Clean up old logs

### Monthly
- Database optimization and cleanup
- Review security settings
- Update documentation

## Integration Points

### Reverse Proxy
All web services are accessible through Caddy reverse proxy with automatic HTTPS.

### Authentication
- **Local Auth**: Most services have their own authentication
- **Database Auth**: Services authenticate with databases using dedicated users
- **Network Isolation**: Services isolated to appropriate networks

### Monitoring
All services are monitored through:
- **Container Health Checks**: Docker health monitoring
- **Resource Monitoring**: Memory and CPU usage tracking
- **Service Monitoring**: HTTP endpoint checks
- **Log Monitoring**: Error detection and alerting

## Related Documentation

- [Infrastructure](../infrastructure/) - Underlying infrastructure
- [Configuration](../configuration/) - System configuration
- [Operations](../operations/) - Operational procedures
- [Troubleshooting](../troubleshooting/) - Common issues and solutions
