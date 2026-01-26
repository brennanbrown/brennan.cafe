# PostgreSQL Database Service

**Service**: PostgreSQL Database  
**Version**: 15 Alpine  
**Status**: ✅ **OPERATIONAL**  
**Purpose**: Shared database for Phase 3 services  

## Overview

PostgreSQL serves as the central database system for all Phase 3 personal productivity tools. It provides reliable data storage, proper security, and efficient resource management for Vikunja, HedgeDoc, Linkding, and Navidrome services.

## Architecture

### Container Configuration
```yaml
services:
  postgresql:
    image: postgres:15-alpine
    container_name: postgresql
    restart: unless-stopped
    environment:
      - POSTGRES_DB=homelab
      - POSTGRES_USER=homelab
      - POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgres_password:/run/secrets/postgres_password:ro
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - internal_db
    mem_limit: 256m
    mem_reservation: 128m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Network Configuration
- **Internal Network**: `internal_db` network for database access
- **Port**: 5432 (internal only)
- **Access**: Limited to containers on `internal_db` network
- **Security**: No external port exposure

## Database Schema

### Management Database (`homelab`)
The primary database for service management and monitoring:

#### Service Configuration Table
```sql
CREATE TABLE service_configs (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(50) UNIQUE NOT NULL,
    database_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Backup Log Table
```sql
CREATE TABLE backup_log (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(50) NOT NULL,
    backup_type VARCHAR(20) NOT NULL,
    backup_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT true
);
```

#### User Activity Table
```sql
CREATE TABLE user_activity (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    user_identifier VARCHAR(100),
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Service Databases
Each service gets its own dedicated database:

#### Vikunja Database (`vikunja`)
- **Purpose**: Task management data
- **User**: `vikunja` with full privileges
- **Tables**: Created by Vikunja migrations
- **Features**: Tasks, projects, labels, users

#### HedgeDoc Database (`hedgedoc`)
- **Purpose**: Collaborative notes data
- **User**: `hedgedoc` with full privileges
- **Tables**: Created by HedgeDoc migrations
- **Features**: Notes, users, revisions, permissions

#### Linkding Database (`linkding`)
- **Purpose**: Bookmark management data
- **User**: `linkding` with full privileges
- **Tables**: Created by Linkding migrations
- **Features**: Bookmarks, tags, categories

#### Navidrome Database (`navidrome`)
- **Purpose**: Music streaming data
- **User**: `navidrome` with full privileges
- **Tables**: Created by Navidrome migrations
- **Features**: Artists, albums, tracks, playlists

## Security Implementation

### User Management
- **Root User**: `homelab` with administrative privileges
- **Service Users**: Dedicated users for each service
- **Password Security**: Passwords stored in mounted secrets file
- **Privilege Separation**: Users limited to their respective databases

### Access Controls
```sql
-- Database-level permissions
GRANT ALL PRIVILEGES ON DATABASE vikunja TO vikunja;
GRANT ALL PRIVILEGES ON DATABASE hedgedoc TO hedgedoc;
GRANT ALL PRIVILEGES ON DATABASE linkding TO linkding;
GRANT ALL PRIVILEGES ON DATABASE navidrome TO navidrome;

-- Schema-level permissions
GRANT ALL PRIVILEGES ON SCHEMA public TO vikunja;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vikunja;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vikunja;
```

### Network Security
- **Internal Only**: No external port exposure
- **Network Isolation**: Access limited to `internal_db` network
- **Container Security**: Running as non-root user
- **Data Encryption**: Data encrypted at rest

## Performance Optimization

### Resource Management
- **Memory Limit**: 256MB maximum
- **Memory Reservation**: 128MB guaranteed
- **Storage**: Persistent volume for data
- **Logging**: Rotated logs with size limits

### Database Optimization
- **Indexes**: Created for common queries
- **Views**: Service status view for monitoring
- **Functions**: User activity logging function
- **Connections**: Connection pooling via applications

### Monitoring
```sql
-- Service status view
CREATE VIEW service_status AS
SELECT 
    sc.service_name,
    sc.database_name,
    sc.created_at as setup_date,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_stat_activity 
            WHERE datname = sc.database_name 
            AND state = 'active'
        ) THEN 'active'
        ELSE 'inactive'
    END as status,
    pg_size_pretty(pg_database_size(sc.database_name)) as database_size
FROM service_configs sc;
```

## Backup Strategy

### Data Persistence
- **Volume**: `postgres_data` volume for persistent storage
- **Initialization**: Database created via init.sql script
- **Recovery**: Volume can be backed up and restored
- **Integrity**: Database constraints ensure data integrity

### Backup Procedures
```bash
# Database backup
docker exec postgresql pg_dump -U homelab homelab > backup.sql

# Individual database backup
docker exec postgresql pg_dump -U homelab vikunja > vikunja_backup.sql

# Volume backup
docker run --rm -v postgresql_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
```

## Maintenance

### Regular Tasks
- **Log Rotation**: Automatic log rotation configured
- **Performance Monitoring**: Monitor resource usage
- **Backup Verification**: Test backup procedures
- **Security Updates**: Update PostgreSQL image regularly

### Health Checks
```bash
# Check container status
docker ps | grep postgresql

# Check database connectivity
docker exec postgresql pg_isready -U homelab

# Check resource usage
docker stats postgresql

# Check database size
docker exec postgresql psql -U homelab -d homelab -c "SELECT pg_size_pretty(pg_database_size('homelab'));"
```

## Troubleshooting

### Common Issues

#### Connection Refused
**Symptoms**: Services cannot connect to database
**Causes**: Network issues, incorrect credentials
**Solutions**:
```bash
# Check network connectivity
docker exec caddy ping postgresql

# Check PostgreSQL logs
docker logs postgresql --tail 20

# Verify user permissions
docker exec postgresql psql -U homelab -d homelab -c "\du"
```

#### Permission Denied
**Symptoms**: Database access errors
**Causes**: Incorrect user permissions, schema issues
**Solutions**:
```bash
# Grant schema permissions
docker exec postgresql psql -U homelab -d vikunja -c "GRANT ALL PRIVILEGES ON SCHEMA public TO vikunja;"

# Check current permissions
docker exec postgresql psql -U homelab -d vikunja -c "\dp"
```

#### Resource Issues
**Symptoms**: Container restarts, performance issues
**Causes**: Memory limits, storage issues
**Solutions**:
```bash
# Check memory usage
docker stats postgresql

# Check disk space
df -h

# Check PostgreSQL configuration
docker exec postgresql psql -U homelab -d homelab -c "SHOW ALL;"
```

## Integration

### Service Connections
Each service connects using environment variables:
```yaml
environment:
  - VIKUNJA_DATABASE_HOST=postgresql
  - VIKUNJA_DATABASE_USER=vikunja
  - VIKUNJA_DATABASE_PASSWORD=vikunja_password
  - VIKUNJA_DATABASE_DATABASE=vikunja
```

### Network Configuration
Services must be on both networks:
- `internal_db`: For database access
- `caddy`: For web access

## Monitoring

### Metrics
- **Database Size**: Tracked via service_status view
- **Connection Count**: Monitored via pg_stat_activity
- **Resource Usage**: Docker stats
- **Query Performance**: PostgreSQL logs

### Alerts
- **Service Status**: Active/inactive tracking
- **Backup Success**: Backup log table
- **User Activity**: Activity logging function
- **Resource Limits**: Memory usage monitoring

---

**Service Owner**: brennan.page Homelab  
**Last Updated**: 2026-01-16  
**Next Review**: After Phase 3 completion  
**Dependencies**: Docker, internal_db network
