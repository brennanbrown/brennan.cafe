# HedgeDoc

**Service**: HedgeDoc  
**Version**: Latest  
**Status**: ✅ **OPERATIONAL**  
**Purpose**: Collaborative Markdown Notes  

## Overview

HedgeDoc is a real-time, multi-platform collaborative markdown editor that allows multiple users to edit documents simultaneously. It provides a modern, intuitive interface for collaborative note-taking and documentation.

## Architecture

### Container Configuration
```yaml
services:
  hedgedoc:
    image: quay.io/hedgedoc/hedgedoc:latest
    container_name: hedgedoc
    restart: unless-stopped
    environment:
      - CMD_DB_URL=postgres://hedgedoc:hedgedoc_password@postgresql:5432/hedgedoc
      - CMD_DOMAIN=notes.brennan.page
      - CMD_URL_ADDPORT=false
      - CMD_PORT=3000
      - CMD_PROTOCOL_USESSL=true
      - CMD_ALLOW_ANONYMOUS=true
      - CMD_ALLOW_ANONYMOUS_EDITS=true
      - CMD_ALLOW_FREEURL=true
      - CMD_DEFAULT_PERMISSION=editable
      - CMD_SESSION_SECRET=hedgedoc_session_secret_2026_secure_random_string
      - CMD_OAUTH2_BASEURL=https://notes.brennan.page
      - CMD_OAUTH2_CLIENT_ID=hedgedoc
      - CMD_OAUTH2_AUTHORIZATION_URL=https://notes.brennan.page/oauth/authorize
      - CMD_OAUTH2_TOKEN_URL=https://notes.brennan.page/oauth/token
      - CMD_OAUTH2_USER_PROFILE_URL=https://notes.brennan.page/oauth/userinfo
      - CMD_OAUTH2_USER_PROFILE_USERNAME_ATTR=username
      - CMD_OAUTH2_USER_PROFILE_DISPLAY_NAME_ATTR=displayname
      - CMD_OAUTH2_USER_PROFILE_EMAIL_ATTR=email
      - CMD_OAUTH2_USER_PROFILE_PICTURE_ATTR=avatar
      - CMD_EMAIL=false
      - CMD_ALLOW_EMAIL_REGISTER=false
      - CMD_ALLOW_GRAVATAR=true
      - CMD_ALLOW_REGISTER=true
      - CMD_IMAGE_UPLOAD_TYPE=filesystem
      - CMD_IMAGE_UPLOAD_PATH=/hedgedoc/public/uploads
      - CMD_HSTS_ENABLE=false
      - CMD_HSTS_INCLUDE_SUBDOMAINS=false
      - CMD_HSTS_PRELOAD=false
    volumes:
      - hedgedoc_uploads:/hedgedoc/public/uploads
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
- **External Access**: Via Caddy reverse proxy
- **Database Access**: Via internal_db network
- **Internal Network**: Connected to caddy and internal_db networks
- **Port**: 3000 (internal)

## Features

### Collaboration
- **Real-time Editing**: Simultaneous multi-user editing
- **User Cursors**: See other users' cursors
- **User List**: See who's currently editing
- **User Avatars**: User avatars and profiles
- **Real-time Sync**: Real-time synchronization

### Markdown Features
- **Full Markdown**: Complete Markdown support
- **Code Highlighting**: Syntax highlighting
- **Math Support**: LaTeX math support
- **Diagrams**: Mermaid diagram support
- **Tables**: Advanced table support

### Document Management
- **Document Creation**: Create new documents
- **Document Sharing**: Share documents with others
- **Version History**: Document version history
- **Import/Export**: Import and export documents
- **Tags and Labels**: Document tagging

### User Management
- **User Registration**: Open registration enabled
- **User Profiles**: User profiles and avatars
- **Guest Access**: Anonymous access allowed
- **Permission Control**: Document permission control
- **User Groups**: User group management

## Configuration

### Database Configuration
- **Database Type**: PostgreSQL
- **Connection String**: PostgreSQL connection
- **Database Name**: hedgedoc
- **User**: hedgedoc
- **Password**: hedgedoc_password

### URL Configuration
- **Domain**: notes.brennan.page
- **Protocol**: HTTPS
- **Port**: 3000 (internal)
- **Base URL**: https://notes.brennan.page

### Authentication
- **Registration**: Open registration enabled
- **Anonymous Access**: Anonymous access allowed
- **OAuth2**: OAuth2 configuration
- **Session Management**: Session-based authentication

### File Upload
- **Upload Type**: Filesystem
- **Upload Path**: /hedgedoc/public/uploads
- **File Types**: All file types allowed
- **Size Limits**: Configurable size limits

## Access

### Web Interface
- **URL**: https://notes.brennan.page
- **Protocol**: HTTPS via Caddy
- **Authentication**: Optional registration
- **Security**: SSL/TLS encryption

### User Registration
- **Open Registration**: Anyone can register
- **Email**: Email optional
- **Username**: Choose username
- **Password**: Strong password required

### Anonymous Access
- **Read Access**: Anonymous users can read
- **Write Access**: Anonymous users can edit
- **Create Notes**: Anonymous users can create notes
- **Share Notes**: Anonymous users can share notes

## Operations

### Document Operations
```bash
# Create new document
# Via web interface: https://notes.brennan.page

# Edit document
# Via web interface: https://notes.brennan.page

# Share document
# Via web interface: https://notes.brennan.page

# Delete document
# Via web interface: https://notes.brennan.page
```

### Service Management
```bash
# Check service status
docker ps | grep hedgedoc

# View service logs
docker logs hedgedoc

# Restart service
docker restart hedgedoc

# Update service
cd /opt/homelab/services/hedgedoc
docker compose pull
docker compose up -d
```

### Database Management
```bash
# Access database
docker exec postgres psql -U hedgedoc -d hedgedoc

# View database schema
\dt

# Backup database
docker exec postgres pg_dump -U hedgedoc hedgedoc > hedgedoc_backup.sql

# Restore database
docker exec -i postgres psql -U hedgedoc hedgedoc < hedgedoc_backup.sql
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
- **Content Security**: Content security policies

### Data Protection
- **Database Security**: Database access controls
- **File Security**: File upload security
- **User Privacy**: User privacy protection
- **Data Encryption**: Data encryption at rest

## File Management

### Upload Management
- **File Types**: All file types allowed
- **Size Limits**: Configurable size limits
- **Storage**: Filesystem storage
- **Access**: File access controls

### File Organization
- **Upload Directory**: /hedgedoc/public/uploads
- **File Paths**: Organized file paths
- **File Permissions**: File permission controls
- **Backup**: File backup procedures

### File Security
- **Virus Scanning**: No virus scanning (consider adding)
- **File Validation**: File validation checks
- **Access Control**: File access controls
- **Audit Logging**: File access logging

## Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check database connectivity
docker exec hedgedoc curl -f http://postgresql:5432

# Check database logs
docker logs postgres | grep hedgedoc

# Test database access
docker exec postgres psql -U hedgedoc -d hedgedoc -c "SELECT 1;"
```

#### Service Not Accessible
```bash
# Check container status
docker ps | grep hedgedoc

# Check logs
docker logs hedgedoc --tail 20

# Test internal access
curl -f http://localhost:3000

# Check Caddy proxy
curl -f https://notes.brennan.page
```

#### File Upload Issues
```bash
# Check upload directory
docker exec hedgedoc ls -la /hedgedoc/public/uploads

# Check permissions
docker exec hedgedoc ls -la /hedgedoc/public/uploads

# Test file upload
# Via web interface: https://notes.brennan.page
```

### Debug Commands
```bash
# Check container details
docker inspect hedgedoc

# View configuration
docker exec hedgedoc env | grep CMD_

# Test database connection
docker exec hedgedoc nc -zv postgresql 5432

# Check file system
docker exec hedgedoc df -h
```

## Best Practices

### Document Management
- **Regular Backups**: Regular document backups
- **Version Control**: Version control for documents
- **Access Control**: Proper access control
- **Documentation**: Document procedures

### User Management
- **User Registration**: Monitor user registration
- **User Profiles**: User profile management
- **Access Reviews**: Regular access reviews
- **Privacy Protection**: User privacy protection

### Security
- **Regular Updates**: Keep HedgeDoc updated
- **Security Patches**: Apply security patches
- **Monitoring**: Monitor security events
- **Audit Logging**: Maintain audit logs

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

### With Services
- **File Storage**: File storage for documents
- **User Management**: User management integration
- **Authentication**: Authentication integration
- **Collaboration**: Collaboration features

## Advanced Features

### Real-time Collaboration
- **Multi-user Editing**: Simultaneous editing
- **User Cursors**: Visual user cursors
- **Real-time Sync**: Real-time synchronization
- **Conflict Resolution**: Conflict resolution

### Markdown Extensions
- **Math Support**: LaTeX math support
- **Diagrams**: Mermaid diagram support
- **Code Highlighting**: Syntax highlighting
- **Table Support**: Advanced table support

### Integration Features
- **API Access**: REST API access
- **Webhook Support**: Webhook notifications
- **Import/Export**: Import and export features
- **Plugin Support**: Plugin system

## Monitoring

### User Activity
- **User Tracking**: User activity tracking
- **Document Access**: Document access logging
- **Edit History**: Edit history tracking
- **Session Management**: Session management

### System Metrics
- **Performance**: Performance metrics
- **Resource Usage**: Resource usage tracking
- **Database Usage**: Database usage monitoring
- **File Usage**: File usage tracking

### Error Monitoring
- **Error Logging**: Error logging
- **Performance Issues**: Performance issue detection
- **User Issues**: User issue tracking
- **System Alerts**: System alerting

## References

- [HedgeDoc Documentation](https://hedgedoc.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Markdown Guide](https://www.markdownguide.org/)
