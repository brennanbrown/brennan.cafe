# Environment Variables

Service environment variables and configuration.

## Overview

Environment variables provide configuration for services without hardcoding values in container images.

## Database Configuration

### PostgreSQL
```yaml
# PostgreSQL server configuration
POSTGRES_DB=homelab
POSTGRES_USER=homelab
POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password
POSTGRES_INITDB_ARGS=--encoding=UTF-8 --lc-collate=C --lc-ctype=C
```

### Service Database Connections
```yaml
# Vikunja
VIKUNJA_DATABASE_HOST=postgresql
VIKUNJA_DATABASE_TYPE=postgres
VIKUNJA_DATABASE_USER=vikunja
VIKUNJA_DATABASE_PASSWORD=vikunja_password
VIKUNJA_DATABASE_DATABASE=vikunja

# HedgeDoc
HEDGEDOC_DB_HOST=postgresql
HEDGEDOC_DB_USER=hedgedoc
HEDGEDOC_DB_PASSWORD=hedgedoc_password
HEDGEDOC_DB_NAME=hedgedoc
HEDGEDOC_DB_TYPE=postgres

# Linkding
LINKDING_DB_USER=linkding
LINKDING_DB_PASSWORD=linkding_password
LINKDING_DB_DATABASE=linkding
LINKDING_DB_HOST=postgresql
LINKDING_DB_PORT=5432

# Navidrome
ND_DB_HOST=postgresql
ND_DB_USER=navidrome
ND_DB_PASSWORD=navidrome_password
ND_DB_NAME=navidrome

# FreshRSS
FRESHRSS_DB_HOST=postgresql
FRESHRSS_DB_USER=freshrss
FRESHRSS_DB_PASSWORD=freshrss_password
FRESHRSS_DB_NAME=freshrss
```

## Service URLs

### Base URLs
```yaml
# Vikunja
VIKUNJA_SERVICE_URL=https://tasks.brennan.page
VIKUNJA_PUBLIC_URL=https://tasks.brennan.page

# HedgeDoc
CMD_DOMAIN=notes.brennan.page
CMD_URL_ADDRESSES=https://notes.brennan.page
CMD_PROTOCOL_USESSL=true

# Linkding
LINKDING_URL=https://bookmarks.brennan.page

# Navidrome
ND_BASEURL=https://music.brennan.page/music

# FreshRSS
FRESHRSS_BASE_URL=https://rss.brennan.page

# WriteFreely
WRITEFREELY_HOST=https://blog.brennan.page
WRITEFREELY_SITE_NAME=Brennan's Blog
WRITEFREELY_SITE_DESCRIPTION=Personal blog and thoughts

# Flarum
FORUM_URL=https://forum.brennan.page
FLARUM_TITLE=Brennan's Forum
```

## Authentication Configuration

### JWT Secrets
```yaml
# Vikunja
VIKUNJA_AUTH_JWT_SECRET=vikunja_jwt_secret_key_here

# HedgeDoc
CMD_SESSION_SECRET=hedgedoc_session_secret_here

# Linkding
LINKDING_SECRET_KEY=linkding_secret_key_here

# FreshRSS
FRESHRSS_API_PASSWORD=freshrss_api_password_here
```

### Admin Accounts
```yaml
# Flarum
FLARUM_ADMIN_USER=admin
FLARUM_ADMIN_PASS=admin123456
FLARUM_ADMIN_MAIL=admin@brennan.page

# FreshRSS
FRESHRSS_DEFAULT_USER=admin
FRESHRSS_USER_PASSWORD=admin123
FRESHRSS_USER_EMAIL=admin@brennan.page

# WriteFreely
WRITEFREELY_ADMIN_USER=brennan
WRITEFREELY_ADMIN_PASSWORD=admin123
```

## Application Configuration

### Timezone
```yaml
# All services
TZ=America/Toronto
```

### User/Group IDs
```yaml
# File-based services
PUID=1000
PGID=1000

# Navidrome
ND_UID=1000
ND_GID=1000
```

### Application Settings
```yaml
# Vikunja
VIKUNJA_WEB_ENABLED=true
VIKUNJA_MAIL_ENABLED=false
VIKUNJA_ATTACHMENT_MAX_SIZE=20MB
VIKUNJA_ENABLE_TASK_COMMENTS=true
VIKUNJA_ENABLE_TASK_ATTACHMENT=true

# HedgeDoc
CMD_ALLOW_ANONYMOUS=false
CMD_ALLOW_FREEURL=true
CMD_ALLOW_REGISTER=false
CMD_ALLOW_EMAIL_REGISTER=false
CMD_DEFAULT_PERMISSION=limited
CMD_ALLOW_ORIGIN=notes.brennan.page

# Linkding
LINKDING_ENABLE_REGISTRATION=false
LINKDING_ENABLE_PUBLIC_REGISTRATION=false
LINKDING_ENABLE_FAVICON_TAGS=true
LINKDING_ENABLE_URL_VALIDATION=true

# Navidrome
ND_SCANINTERVAL=15m
ND_LOGLEVEL=info
ND_SESSIONTIMEOUT=24h
ND_ENABLE_TRANSCODING=true
ND_MUSICFOLDER=/music

# FreshRSS
FRESHRSS_DEFAULT_LANGUAGE=en
FRESHRSS_ENABLE_API=true
FRESHRSS_ALLOW_ANONYMOUS=false
FRESHRSS_ALLOW_REGISTRATION=false
FRESHRSS_ALLOW_ANONYMOUS_REFRESH=false

# WriteFreely
WRITEFREELY_SINGLE_USER=true
WRITEFREELY_FEDERATION=true
WRITEFREELY_PUBLIC_STATS=false
WRITEFREELY_PRIVATE=false
WRITEFREELY_OPEN_REGISTRATION=false

# Flarum
FLARUM_DEBUG=false
FLARUM_INSTALLATION=false
FLARUM_API_ENABLED=true
FLARUM_MAIL_DRIVER=log
```

## Performance Configuration

### Database Connection Pooling
```yaml
# Vikunja
VIKUNJA_DATABASE_MAXOPENCONNS=25
VIKUNJA_DATABASE_MAXIDLECONNS=25

# HedgeDoc
CMD_DB_MAXCONNS=25

# FreshRSS
FRESHRSS_DB_MAXCONNS=10
```

### Resource Limits
```yaml
# Memory settings
VIKUNJA_WORKER_ENABLED=true
VIKUNJA_WORKER_TYPE=queue
VIKUNJA_WORKER_CONCURRENCY=1

# Cache settings
VIKUNJA_CACHE_ENABLED=true
VIKUNJA_CACHE_TYPE=memory
```

## Security Configuration

### SSL/TLS
```yaml
# HedgeDoc
CMD_PROTOCOL_USESSL=true
CMD_ALLOW_ORIGIN=notes.brennan.page

# FreshRSS
FRESHRSS_HTTPS=true
FRESHRSS_FORCE_HTTPS=true

# WriteFreely
WRITEFREELY_SERVER_HOST=0.0.0.0
WRITEFREELY_SERVER_PORT=80
```

### Access Control
```yaml
# HedgeDoc
CMD_ALLOW_ANONYMOUS=false
CMD_ALLOW_REGISTER=false
CMD_ALLOW_EMAIL_REGISTER=false

# Linkding
LINKDING_ENABLE_REGISTRATION=false
LINKDING_ENABLE_PUBLIC_REGISTRATION=false

# FreshRSS
FRESHRSS_ALLOW_ANONYMOUS=false
FRESHRSS_ALLOW_REGISTRATION=false

# WriteFreely
WRITEFREELY_OPEN_REGISTRATION=false
WRITEFREELY_PRIVATE=false

# Flarum
FLARUM_ENABLE_REGISTRATION=false
```

## Logging Configuration

### Log Levels
```yaml
# Navidrome
ND_LOGLEVEL=info

# FreshRSS
FRESHRSS_LOG_LEVEL=info

# WriteFreely
WRITEFREELY_LOG_LEVEL=info
```

### Log Output
```yaml
# All services
LOG_LEVEL=info
LOG_FORMAT=json
```

## Development Configuration

### Debug Mode
```yaml
# Flarum
FLARUM_DEBUG=true

# FreshRSS
FRESHRSS_ENV=development

# WriteFreely
WRITEFREELY_DEBUG=true
```

### Development URLs
```yaml
# Local development
VIKUNJA_SERVICE_URL=http://localhost:8080
CMD_DOMAIN=localhost
LINKDING_URL=http://localhost:9090
ND_BASEURL=http://localhost:4533
```

## Environment Variable Templates

### Database Service Template
```yaml
# Database connection template
DB_HOST=postgresql
DB_USER=service_user
DB_PASSWORD=service_password
DB_DATABASE=service_db
DB_PORT=5432
DB_TYPE=postgres
```

### Web Service Template
```yaml
# Web service template
SERVICE_URL=https://service.brennan.page
SERVICE_HOST=0.0.0.0
SERVICE_PORT=80
TZ=America/Toronto
```

### Authentication Template
```yaml
# Authentication template
JWT_SECRET=jwt_secret_key_here
SESSION_SECRET=session_secret_here
ADMIN_USER=admin
ADMIN_PASSWORD=admin123
ADMIN_EMAIL=admin@brennan.page
```

## Environment Variable Management

### Secret Management
```bash
# Create secret files
echo "secure_password" > /opt/homelab/secrets/service_password
chmod 600 /opt/homelab/secrets/service_password

# Use in Docker Compose
POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password
```

### Environment Files
```bash
# Create .env file
cat > .env << 'EOF'
# Database configuration
POSTGRES_DB=homelab
POSTGRES_USER=homelab
POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

# Service URLs
VIKUNJA_SERVICE_URL=https://tasks.brennan.page
HEDGEDOC_URL=https://notes.brennan.page
LINKDING_URL=https://bookmarks.brennan.page

# Timezone
TZ=America/Toronto
EOF

# Use in Docker Compose
env_file: .env
```

### Docker Compose Environment Variables
```yaml
services:
  service:
    image: service:latest
    environment:
      - ENV_VAR=value
      - ANOTHER_VAR=another_value
    env_file:
      - .env
      - .env.local
```

## Validation

### Environment Variable Validation
```bash
# Check required environment variables
docker exec service_name env | grep -E "DB_HOST|DB_USER|DB_DATABASE"

# Test database connection
docker exec service_name ping -c 2 postgresql

# Validate service URL
curl -I https://service.brennan.page
```

### Configuration Validation
```bash
# Check service configuration
docker exec service_name env | sort

# Validate database connection
docker exec service_name python -c "
import psycopg2
conn = psycopg2.connect('postgresql://user:pass@host:5432/db')
print('Database connection successful')
"
```

## Troubleshooting

### Missing Environment Variables
```bash
# Check if variables are set
docker exec service_name env | grep VAR_NAME

# Check service logs for missing variables
docker logs service_name | grep -i "environment"

# Add missing variables
docker compose down
# Edit docker-compose.yml
docker compose up -d
```

### Invalid Values
```bash
# Check variable values
docker exec service_name env | grep VAR_NAME

# Test configuration
docker exec service_name python -c "
import os
print(os.environ['VAR_NAME'])
"

# Fix invalid values
docker compose down
# Edit docker-compose.yml
docker compose up -d
```

### Permission Issues
```bash
# Check file permissions
ls -la /opt/homelab/secrets/

# Fix permissions
chmod 600 /opt/homelab/secrets/*
chown root:root /opt/homelab/secrets/*
```

## Best Practices

### Security
- Use password files instead of plain text passwords
- Set appropriate file permissions on secret files
- Don't commit secrets to version control
- Use different passwords for different services

### Performance
- Use appropriate database connection pooling
- Set reasonable timeout values
- Configure appropriate cache settings
- Monitor resource usage

### Maintainability
- Use environment files for configuration
- Document required environment variables
- Use consistent naming conventions
- Validate configurations before deployment

## Getting Help

### Before Reporting Issues
- [ ] Checked environment variables
- [ ] Validated configuration files
- [ ] Tested service connectivity
- [ ] Reviewed error logs

### Information to Include
- Environment variable values
- Configuration file contents
- Error messages
- Service logs
- Recent changes
