# Linkding

**Service**: Linkding  
**Version**: Latest  
**Status**: ✅ **OPERATIONAL**  
**Purpose**: Bookmark Manager  

## Overview

Linkding is a minimalist, open-source bookmark manager that provides a clean, fast, and distraction-free bookmarking experience. It offers a simple interface for organizing and managing bookmarks with tagging and search capabilities.

## Architecture

### Container Configuration
```yaml
services:
  linkding:
    image: sissbruecker/linkding:latest
    container_name: linkding
    restart: unless-stedopped
    environment:
      - LD_DB_ENGINE=postgres
      - LD_DB_HOST=postgresql
      - LD_DB_PORT=5432
      - LD_DB_NAME=linkding
      - LD_DB_USER=linkding
      - LD_DB_PASSWORD=linkding_password
      - LD_SUPERUSER_NAME=admin
      - LD_SUPERUSER_PASSWORD=linkding_admin_password_2026
      - LD_REQUEST_TIMEOUT=30
      - LD_DATA_DIR=/data
      - LD_ENABLE_AUTH_PROXY=true
      - LD_AUTH_PROXY_USERNAME_HEADER=X-Username
      - LD_AUTH_PROXY_LOGOUT_URL=https://bookmarks.brennan.page
      - LD_ENABLE_LOGIN_FORM=true
      - LD_DISABLE_BACKGROUND_TASKS=false
      - LD_ENABLE_URL_VALIDATION=true
      - LD_ENABLE_FAVICONS=true
      - LD_ENABLE_AUTOMATIC_TAGGING=true
      - LD_ENABLE_SHARING=true
      - LD_ENABLE_PUBLIC_SHARING=true
      - LD_ENABLE_API_TOKENS=true
      - LD_ENABLE_REGISTRATION=false
      - LD_ENABLE_FRONTEND_REGISTRATION=false
    volumes:
      - linkding_data:/data
    networks:
      - internal_db
      - caddy
    mem_limit: 128m
    mem_reservation: 64m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Network Configuration
- **External Access**: Via Caddy reverse proxy
- **Database Access**: Via internal_db network
- **Internal Network**: Connected to caddy and internal_db networks
- **Port**: 9090 (internal)

## Features

### Bookmark Management
- **Create Bookmarks**: Add new bookmarks
- **Edit Bookmarks**: Edit bookmark details
- **Delete Bookmarks**: Remove bookmarks
- **Import Bookmarks**: Import bookmarks from browsers
- **Export Bookmarks**: Export bookmarks to browsers

### Organization
- **Tags**: Tag-based bookmark organization
- **Search**: Full-text search in bookmarks
- **Filtering**: Filter bookmarks by tags
- **Sorting**: Sort bookmarks by various criteria
- **Categories**: Bookmark categorization

### Sharing
- **Public Sharing**: Share bookmarks publicly
- **Private Sharing**: Share bookmarks privately
- **URL Sharing**: Share bookmark URLs
- **Collection Sharing**: Share bookmark collections
- **API Access**: API access for developers

### User Features
- **User Accounts**: User account management
- **API Tokens**: API token management
- **Themes**: Dark/light theme support
- **Language**: Multi-language support
- **Mobile**: Mobile-friendly interface

## Configuration

### Database Configuration
- **Database Type**: PostgreSQL
- **Connection**: PostgreSQL connection
- **Database Name**: linkding
- **User**: linkding
- **Password**: linkding_password

### User Management
- **Superuser**: Admin account (admin)
- **Registration**: Registration disabled
- **Authentication**: Form-based authentication
- **Proxy Auth**: Authentication proxy support
- **API Tokens**: API token authentication

### URL Configuration
- **Base URL**: https://bookmarks.brennan.page
- **Domain**: bookmarks.brennan.page
- **Protocol**: HTTPS via Caddy
- **Port**: 9090 (internal)

### Feature Configuration
- **Favicon Support**: Automatic favicon fetching
- **Automatic Tagging**: Automatic tag suggestion
- **URL Validation**: URL validation
- **Background Tasks**: Background task processing
- **API Access**: REST API access

## Access

### Web Interface
- **URL**: https://bookmarks.brennan.page
- **Protocol**: HTTPS via Caddy
- **Authentication**: Login form
- **Security**: SSL/TLS encryption

### User Authentication
- **Username**: admin
- **Password**: linkding_admin_password_2026
- **Method**: Form-based authentication
- **Session**: Session-based authentication
- **Security**: Secure session management

### API Access
- **REST API**: RESTful API access
- **API Tokens**: API token authentication
- **Documentation**: API documentation
- **Rate Limiting**: API rate limiting

## Operations

### Bookmark Operations
```bash
# Create bookmark
# Via web interface: https://bookmarks_url

# Edit bookmark
# Via web interface: https://bookmarks_url

# Delete bookmark
# Via web interface: https://bookmarks_url

# Import bookmarks
# Via web interface: https://bookmarks_url/import

# Export bookmarks
# Via web interface: https://bookmarks_url/export
```

### Service Management
```bash
# Check service status
docker ps | grep linkding

# View service logs
docker logs linkding

# Restart service
docker restart linkding

# Update service
cd /opt/homelab/services/linkding
docker compose pull
docker compose up -d
```

### Database Management
```bash
# Access database
docker exec postgres psql -U linkding -d linkding

# View database schema
\dt

# Backup database
docker exec postgres pg_dump -U linkding linkding > linkding_backup.sql

# Restore database
docker exec -i postgres psql -U linkding linkding < linkding_backup.sql
```

### User Management
```bash
# Access admin interface
# Via web interface: https://bookmarks.brennan.page

# Create user
# Via web interface: https://bookmarks.brennan.page/admin

# Generate API token
# Via web interface: https://bookmarks.brennan.page/settings/tokens

# Reset password
# Via web interface: https://bookmarks.brennan.page/admin
```

## Security

### Container Security
- **Non-root**: Runs as non-root user
- **Resource Limits**: Memory limits enforced
- **Network Isolation**: Limited network access
- **File System**: Limited file system access

### Application Security
- **Input Validation**: Input validation and sanitization
- **XSS Protection**: XSS protection enabled
- **CSRF Protection**: CSRF protection enabled
- **SQL Injection**: SQL injection protection

### Data Protection
- **Database Security**: Database access controls
- **Password Security**: Strong password requirements
- **API Security**: API access controls
- **Privacy**: User privacy protection

## Bookmark Management

### Import/Export
- **Browser Import**: Import from browsers
- **Netscape Format**: Netscape bookmark format
- **HTML Export**: HTML bookmark export
- **API Export**: API-based export
- **Backup**: Regular backup procedures

### Data Organization
- **Tags**: Tag-based organization
- **Search**: Full-text search capability
- **Filtering**: Filter by tags and metadata
- **Sorting**: Sort by date, title, URL
- **Categories**: Category-based organization

### Sharing Features
- **Public Links**: Public sharing links
- **Private Sharing**: Private sharing with authentication
- **Collection Sharing**: Share bookmark collections
- **URL Sharing**: Direct URL sharing
- **API Sharing**: API-based sharing

## Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check database connectivity
docker exec linkding curl -f http://postgresql:5432

# Check database logs
docker logs postgres | grep linkding

# Test database access
docker exec postgres psql -U linkding -d linkding -c "SELECT 1;"
```

#### Service Not Accessible
```bash
# Check container status
docker ps | grep linkding

# Check logs
docker logs linkding --tail 20

# Test internal access
curl -f http://localhost:9090

# Check Caddy proxy
curl -f https://bookmarks.brennan.page
```

#### Authentication Issues
```bash
# Check authentication configuration
docker exec linkding env | grep LD_

# Test admin access
curl -f https://bookmarks.brennanpage/admin

# Reset admin password
# Via web interface: https://bookmarks.brennan.page/admin

# Check database users
docker exec postgres psql -U linkding -d linkding -c "SELECT * FROM auth_user;"
```

### Debug Commands
```bash
# Check container details
docker inspect linkding

# View configuration
docker exec linkding env | grep LD_

# Test database connection
docker exec linkding nc -zv postgresql 5432

# Check file system
docker exec linkding df -h
```

## Best Practices

### Bookmark Management
- **Regular Backups**: Regular bookmark backups
- **Tag Organization**: Consistent tag usage
- **URL Validation**: Validate bookmark URLs
- **Duplicate Removal**: Remove duplicate bookmarks

### Security
- **Strong Passwords**: Use strong passwords
- **Regular Updates**: Keep Linking updated
- **Access Control**: Limit access to bookmarks
- **Privacy Protection**: Protect user privacy

### Performance
- **Database Optimization**: Database performance optimization
- **Search Optimization**: Search performance optimization
- **API Usage**: Efficient API usage
- **Resource Limits**: Monitor resource usage

## Integration

### With PostgreSQL
- **Database Storage**: PostgreSQL database storage
- **Connection Pooling**: Database connection pooling
- **Data Persistence**: Persistent data storage
- **Backup Integration**: Database backup integration

### With Caddy
- **Reverse Proxy**: HTTPS via Caddy
- **SSL Termination**: SSL handled by Caddy
- **Security Headers**: Security headers from Caddy
- **Load Balancing**: Load balancing via Caddy

### With Browsers
- **Import/Export**: Browser import/export
- **Favicon Support**: Automatic favicon fetching
- **Bookmark Sync**: Browser bookmark sync
- **Extension Support**: Browser extension support

### With APIs
- **REST API**: RESTful API access
- **API Tokens**: API token authentication
- **Webhook Support**: Webhook notifications
- **Integration**: Third-party integration

## Advanced Features

### API Integration
- **REST API**: Complete REST API
- **Authentication**: Token-based authentication
- **Rate Limiting**: API rate limiting
- **Documentation**: API documentation
- **Webhooks**: Webhook notifications

### Automation
- **API Scripts**: API automation scripts
- **Batch Operations**: Batch bookmark operations
- **Scheduled Tasks**: Scheduled bookmark tasks
- **Integration**: Third-party integration

### Customization
- **Themes**: Custom theme support
- **Plugins**: Plugin system
- **Extensions**: Extension support
- **Configuration**: Extensive configuration
- **Localization**: Multi-language support

## Monitoring

### User Activity
- **Login Tracking**: User login tracking
- **Bookmark Access**: Bookmark access logging
- **Edit History**: Edit history tracking
- **API Usage**: API usage tracking

### System Metrics
- **Performance**: Performance metrics
- **Resource Usage**: Resource usage tracking
- **Database Usage**: Database usage monitoring
- **API Usage**: API usage monitoring

### Error Monitoring
- **Error Logging**: Error logging
- **Performance Issues**: Performance issue detection
- **User Issues**: User issue tracking
- **System Alerts**: System alerting

## References

- [Linkding Documentation](https://github.com/sissbruecker/linkding)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [REST API Guide](https://restfulapi.net/)
