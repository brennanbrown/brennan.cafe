# Services Home

Welcome to the services section of the brennan.page homelab wiki. This section provides comprehensive documentation for all services running in the homelab infrastructure.

## Service Overview

The brennan.page homelab runs multiple services organized into categories to provide a complete self-hosted environment for productivity, content creation, and community engagement.

## Service Categories

### Infrastructure Services
These services form the foundation of the homelab infrastructure:

- **[Caddy](caddy.md)** - Reverse proxy with automatic HTTPS
- **[PostgreSQL](postgresql.md)** - Primary database server
- **[MariaDB](mariadb.md)** - Database server for Flarum

### Management Services
These services provide management and monitoring capabilities:

- **[Portainer](portainer.md)** - Docker management interface
- **[FileBrowser](filebrowser.md)** - File management interface
- **[Monitor](monitor.md)** - System monitoring dashboard

### Productivity Services
These services enhance personal productivity:

- **[Vikunja](vikunja.md)** - Task management system
- **[HedgeDoc](hedgedoc.md)** - Collaborative markdown notes
- **[Linkding](linkding.md)** - Bookmark manager
- **[Navidrome](navidrome.md)** - Music streaming server

### Content & Community Services
These services enable content creation and community interaction:

- **[WriteFreely](writefreely.md)** - Blog platform
- **[Flarum](flarum.md)** - Community forum
- **[FreshRSS](freshrss.md)** - RSS feed aggregator

## Quick Access

| Service | URL | Category | Status |
|---------|-----|----------|--------|
| Caddy | - | Infrastructure | 🟢 Critical |
| PostgreSQL | - | Infrastructure | 🟢 Critical |
| MariaDB | - | Infrastructure | 🟢 High |
| Portainer | https://docker.brennan.page | Management | 🟢 High |
| FileBrowser | https://files.brennan.page | Management | 🟢 Medium |
| Monitor | https://monitor.brennan.page | Management | 🟢 High |
| Vikunja | https://tasks.brennan.page | Productivity | 🟢 Medium |
| HedgeDoc | https://notes.brennan.page | Productivity | 🟢 Medium |
| Linkding | https://bookmarks.brennan.page | Productivity | 🟢 Medium |
| Navidrome | https://music.brennan.page | Productivity | 🟢 Low |
| WriteFreely | https://blog.brennan.page | Content | 🟢 Medium |
| Flarum | https://forum.brennan.page | Community | 🟢 Medium |
| FreshRSS | https://rss.brennan.page | Community | 🟢 Low |

## Service Architecture

### Network Configuration

All services are connected through Docker networks:

- **caddy**: External network for web access
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

## Getting Started

### Accessing Services

All services are accessible through HTTPS URLs:

1. **Management Services**: Use for system administration
2. **Productivity Services**: Use for personal productivity
3. **Content Services**: Use for content creation and sharing
4. **Community Services**: Use for community interaction

### Service Management

```bash
# Check all services
docker ps

# Check service logs
docker logs service_name

# Restart service
docker restart service_name

# Monitor resource usage
docker stats
```

### Documentation Structure

Each service page includes:

- **Overview**: Service purpose and features
- **Configuration**: Docker compose and environment variables
- **Management**: Admin interfaces and operations
- **Database**: Schema and management commands
- **Performance**: Resource usage and optimization
- **Security**: Access control and best practices
- **Troubleshooting**: Common issues and solutions
- **Backup**: Backup and recovery procedures

## Service Dependencies

### Database Dependencies

| Service | Database | Purpose |
|---------|----------|---------|
| Vikunja | PostgreSQL | Task data |
| HedgeDoc | PostgreSQL | Notes data |
| Linkding | PostgreSQL | Bookmark data |
| Navidrome | PostgreSQL | Music metadata |
| WriteFreely | PostgreSQL | Blog data |
| FreshRSS | PostgreSQL | RSS data |
| Flarum | MariaDB | Forum data |

### Network Dependencies

All services depend on:
- **Caddy**: For HTTPS termination and routing
- **Docker**: For container orchestration
- **Network**: For inter-service communication

## Service Standards

### Security Standards

- **HTTPS**: All web services use HTTPS
- **Authentication**: Service-specific authentication
- **Isolation**: Network and resource isolation
- **Monitoring**: Continuous security monitoring

### Performance Standards

- **Response Time**: Target < 200ms
- **Resource Limits**: Appropriate memory limits
- **Availability**: Target > 99% uptime
- **Monitoring**: Performance metrics tracking

### Documentation Standards

- **Comprehensive**: Complete documentation for all services
- **Current**: Regular updates with changes
- **Consistent**: Standardized documentation format
- **Accessible**: Easy to find and use

## Service Lifecycle

### Deployment

1. **Planning**: Service requirements and resource planning
2. **Configuration**: Docker compose and environment setup
3. **Deployment**: Service deployment and testing
4. **Documentation**: Service documentation creation
5. **Monitoring**: Ongoing monitoring and maintenance

### Maintenance

- **Daily**: Health checks and log monitoring
- **Weekly**: Performance review and updates
- **Monthly**: Security updates and optimization
- **Quarterly**: Comprehensive review and planning

### Updates

- **Security**: Prompt security updates
- **Features**: Feature updates as needed
- **Dependencies**: Regular dependency updates
- **Documentation**: Documentation updates with changes

## Troubleshooting

### Common Issues

- **Service Not Accessible**: Check Caddy configuration and service status
- **Database Connection**: Verify database container and credentials
- **Performance Issues**: Check resource limits and container stats
- **Authentication**: Check service authentication configuration

### Getting Help

1. **Service Documentation**: Check service-specific documentation
2. **Troubleshooting Section**: Review troubleshooting guides
3. **Operations Documentation**: Check operational procedures
4. **SSH Reference**: Use SSH commands for server management

## Service Integration

### Authentication Integration

- **Local Auth**: Most services have their own authentication
- **Database Auth**: Services authenticate with databases using dedicated users
- **Network Isolation**: Services isolated to appropriate networks

### Monitoring Integration

- **Health Checks**: All services have health monitoring
- **Resource Monitoring**: Memory and CPU usage tracking
- **Log Monitoring**: Error detection and alerting
- **Performance Monitoring**: Response time and availability tracking

### Backup Integration

- **Database Backups**: Regular database backups
- **Configuration Backups**: Configuration file backups
- **Volume Backups**: Data volume backups
- **System Backups**: Complete system backups

## Future Services

### Planned Services

- **Plik**: Temporary file sharing service
- **Rallly**: Meeting and poll scheduling
- **Analytics**: System analytics and reporting
- **Automation**: Workflow automation tools

### Service Evolution

- **Enhanced Features**: Continuous feature enhancement
- **Performance Optimization**: Ongoing performance improvements
- **Security Enhancements**: Regular security improvements
- **Integration**: Better service integration

## Related Documentation

- [Operations](../operations/) - Operational procedures
- [Configuration](../configuration/) - Configuration management
- [Troubleshooting](../troubleshooting/) - Common issues and solutions
- [Reference](../reference/) - Command references

## Support

For service-specific issues:

1. **Check Service Documentation**: Review service-specific documentation
2. **Review Troubleshooting**: Check troubleshooting guides
3. **Check Operations**: Review operational procedures
4. **Contact Support**: Use appropriate support channels

---

*Last updated: {{ git_revision_date_localized }}*
