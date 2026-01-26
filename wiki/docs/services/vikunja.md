# Vikunja Task Management

**Service**: Vikunja  
**URL**: https://tasks.brennan.page  
**Version**: Latest (v1.0.0-rc3)  
**Status**: ✅ **OPERATIONAL**  
**Purpose**: Task management and project organization  

## Overview

Vikunja is an open-source task management application that provides comprehensive project and task organization capabilities. It offers features similar to popular commercial solutions while maintaining data privacy and self-hosting capabilities.

## Architecture

### Container Configuration
```yaml
services:
  vikunja:
    image: vikunja/vikunja:latest
    container_name: vikunja
    restart: unless-stopped
    environment:
      - VIKUNJA_DATABASE_HOST=postgresql
      - VIKUNJA_DATABASE_TYPE=postgres
      - VIKUNJA_DATABASE_USER=vikunja
      - VIKUNJA_DATABASE_PASSWORD=vikunja_password
      - VIKUNJA_DATABASE_DATABASE=vikunja
      - VIKUNJA_SERVICE_URL=https://tasks.brennan.page
      - VIKUNJA_PUBLIC_URL=https://tasks.brennan.page
      - VIKUNJA_CORS_ENABLE=false
      - VIKUNJA_ENOBLEREGISTRATION=true
      - VIKUNJA_FRONTEND_URL=https://tasks.brennan.page
      - VIKUNJA_MAILER_ENABLED=false
    volumes:
      - vikunja_files:/app/vikunja/files
    networks:
      - internal_db
      - caddy
    mem_limit: 256m
    mem_reservation: 128m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Network Configuration
- **Internal Network**: `internal_db` for database access
- **Web Network**: `caddy` for reverse proxy access
- **Port**: 3456 (internal only)
- **Access**: HTTPS via Caddy reverse proxy

## Features

### Core Functionality
- **Task Management**: Create, edit, and organize tasks
- **Project Organization**: Group tasks into projects
- **Labels and Tags**: Categorize and filter tasks
- **User Registration**: Open registration enabled
- **Due Dates**: Set deadlines and reminders
- **Priority Levels**: Task prioritization
- **Comments**: Task discussion and collaboration

### Advanced Features
- **List Views**: Multiple task list configurations
- **Kanban Boards**: Visual task management
- **Calendar Integration**: Due date visualization
- **Search**: Full-text search capability
- **API**: RESTful API for integrations
- **File Attachments**: File upload support
- **Teams**: Multi-user collaboration

## Configuration

### Environment Variables
- **Database Configuration**: PostgreSQL connection settings
- **URL Configuration**: Public and service URLs
- **Security**: CORS disabled for simplicity
- **Registration**: Open registration enabled
- **Email**: Mailer disabled (can be enabled later)

### Database Integration
```sql
-- Vikunja database schema (auto-created)
-- Tables created by Vikunja migrations:
-- - users
-- - projects  
-- - tasks
-- - labels
-- - task_assignees
-- - task_comments
-- - task_attachments
-- - project_members
-- - namespaces
```

## Security Implementation

### Access Control
- **HTTPS Only**: All traffic encrypted via Caddy
- **User Registration**: Open but can be restricted
- **Database Security**: Dedicated database user with limited privileges
- **Network Isolation**: Database access via internal network only

### Data Protection
- **Local Storage**: All data stored on local PostgreSQL
- **No Third Parties**: No external service dependencies
- **Backup Ready**: Database included in backup strategy
- **Privacy**: Complete data control

## Performance Optimization

### Resource Management
- **Memory Limit**: 256MB maximum
- **Memory Reservation**: 128MB guaranteed
- **File Storage**: Persistent volume for attachments
- **Logging**: Rotated logs with size limits

### Database Optimization
- **Connection Pooling**: Managed by Vikunja application
- **Indexing**: Database indexes created by migrations
- **Query Optimization**: PostgreSQL query optimization
- **Caching**: Application-level caching

## User Experience

### Interface Features
- **Modern UI**: Clean, responsive web interface
- **Dark Mode**: Available (theme preference)
- **Mobile Support**: Responsive design for mobile devices
- **Keyboard Shortcuts**: Productivity shortcuts available
- **Drag & Drop**: Task reorganization

### Workflow Integration
- **Quick Add**: Fast task creation
- **Bulk Operations**: Multiple task management
- **Templates**: Task and project templates
- **Import/Export**: Data portability features

## Maintenance

### Regular Tasks
- **Log Monitoring**: Check for errors and performance issues
- **Database Maintenance**: Monitor database size and performance
- **Backup Verification**: Ensure data backup procedures work
- **User Management**: Monitor user registration and activity

### Health Checks
```bash
# Check container status
docker ps | grep vikunja

# Check service logs
docker logs vikunja --tail 20

# Test database connectivity
docker exec vikunja wget -qO- http://localhost:3456

# Check resource usage
docker stats vikunja

# Test web accessibility
curl -I https://tasks.brennan.page
```

## Troubleshooting

### Common Issues

#### Service Unavailable
**Symptoms**: 503 error or connection refused
**Causes**: Container not running, network issues
**Solutions**:
```bash
# Restart service
cd /opt/homelab/services/vikunja && docker compose restart

# Check logs
docker logs vikunja --tail 50

# Verify network connectivity
docker exec caddy ping -c 2 vikunja
```

#### Database Connection Issues
**Symptoms**: Migration failures, database errors
**Causes**: Incorrect credentials, network issues
**Solutions**:
```bash
# Check database connectivity
docker exec postgresql psql -U vikunja -d vikunja -c "SELECT 1;"

# Verify environment variables
docker exec vikunja env | grep VIKUNJA_DATABASE

# Check database permissions
docker exec postgresql psql -U homelab -d homelab -c "\du"
```

#### Performance Issues
**Symptoms**: Slow response times, high resource usage
**Causes**: Memory limits, database performance
**Solutions**:
```bash
# Check resource usage
docker stats vikunja

# Monitor database queries
docker exec postgresql psql -U homelab -d vikunja -c "SELECT * FROM pg_stat_activity;"

# Check file storage usage
docker exec vikunja du -sh /app/vikunja/files
```

## Integration

### API Access
Vikunja provides a RESTful API for integrations:
- **Base URL**: https://tasks.brennan.page/api/v1
- **Authentication**: Token-based authentication
- **Documentation**: Available at /api/v1/docs
- **Rate Limiting**: Configurable (default limits apply)

### Webhooks
- **Task Events**: Task creation, updates, deletion
- **Project Events**: Project creation, updates
- **User Events**: User registration, profile updates

### Third-Party Integrations
- **Calendar Apps**: CalDAV support available
- **Mobile Apps**: Third-party mobile applications
- **Browser Extensions**: Browser-based integrations
- **Automation Tools**: Zapier, n8n integrations

## Backup and Recovery

### Data Backup
```bash
# Database backup
docker exec postgresql pg_dump -U homelab vikunja > vikunja_backup.sql

# File backup
docker run --rm -v vikunja_vikunja_files:/data -v $(pwd):/backup alpine tar czf /backup/vikunja_files_backup.tar.gz -C /data .

# Configuration backup
cp /opt/homelab/services/vikunja/docker-compose.yml ./vikunja_config_backup.yml
```

### Recovery Procedures
```bash
# Restore database
docker exec -i postgresql psql -U homelab vikunja < vikunja_backup.sql

# Restore files
docker run --rm -v vikunja_vikunja_files:/data -v $(pwd):/backup alpine tar xzf /backup/vikunja_files_backup.tar.gz -C /data

# Restart service
cd /opt/homelab/services/vikunja && docker compose restart
```

## Monitoring

### Metrics
- **User Activity**: Registration, login, task creation
- **Performance**: Response times, error rates
- **Resource Usage**: Memory, CPU, storage
- **Database**: Query performance, connection count

### Logging
- **Application Logs**: Vikunja application events
- **Access Logs**: Caddy proxy logs
- **Database Logs**: PostgreSQL query logs
- **System Logs**: Container and system events

## Future Enhancements

### Planned Improvements
- **Email Integration**: Enable email notifications
- **LDAP Authentication**: Enterprise authentication
- **File Storage**: External storage integration
- **API Enhancements**: Extended API capabilities
- **Mobile App**: Native mobile application

### Scaling Considerations
- **Load Balancing**: Multiple instance deployment
- **Database Scaling**: Read replicas, connection pooling
- **Caching Layer**: Redis integration
- **CDN Integration**: Static asset optimization

---

**Service Owner**: brennan.page Homelab  
**Last Updated**: 2026-01-16  
**Next Review**: After Phase 3 completion  
**Dependencies**: PostgreSQL, Caddy, internal_db network
