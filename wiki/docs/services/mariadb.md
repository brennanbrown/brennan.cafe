# MariaDB

MariaDB is a community-developed, commercially supported fork of the MySQL relational database management system. In the brennan.page homelab, MariaDB is used specifically for the Flarum forum service.

## Overview

- **Purpose**: Database server for Flarum forum
- **Version**: Latest stable (Docker Hub)
- **Location**: `mariadb` container
- **Network**: `internal_db` network
- **Data Volume**: `flarum_mariadb_data`

## Configuration

### Docker Compose

```yaml
services:
  flarum_mariadb:
    image: mariadb:latest
    container_name: flarum_mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: flarum
      MYSQL_USER: flarum
      MYSQL_PASSWORD: ${FLARUM_DB_PASSWORD}
    volumes:
      - flarum_mariadb_data:/var/lib/mysql
    networks:
      - internal_db
    mem_limit: 256m

volumes:
  flarum_mariadb_data:
```

### Environment Variables

- `MYSQL_ROOT_PASSWORD`: MariaDB root password
- `MYSQL_DATABASE`: Default database (flarum)
- `MYSQL_USER`: Database user (flarum)
- `MYSQL_PASSWORD`: User password

## Database Schema

### Flarum Database Structure

```sql
-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Discussions table
CREATE TABLE discussions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Posts table
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    discussion_id INT,
    user_id INT,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (discussion_id) REFERENCES discussions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Management

### Connect to Database

```bash
# Connect as root
docker exec -it flarum_mariadb mysql -u root -p

# Connect as flarum user
docker exec -it flarum_mariadb mysql -u flarum -p flarum
```

### Common Operations

```sql
-- List databases
SHOW DATABASES;

-- List tables
USE flarum;
SHOW TABLES;

-- Check users
SELECT user, host FROM mysql.user;

-- Show table structure
DESCRIBE users;

-- Check database size
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'flarum'
GROUP BY table_schema;
```

### Backup Database

```bash
# Backup flarum database
docker exec flarum_mariadb mysqldump -u root -p flarum > flarum_backup.sql

# Restore database
docker exec -i flarum_mariadb mysql -u root -p flarum < flarum_backup.sql
```

## Performance

### Resource Usage

- **Memory Limit**: 256MB
- **CPU**: Shared with other containers
- **Storage**: Persistent volume
- **Connections**: Limited to Flarum container

### Optimization

```sql
-- Check performance metrics
SHOW STATUS LIKE 'Connections';
SHOW STATUS LIKE 'Queries';
SHOW STATUS LIKE 'Uptime';

-- Optimize tables
OPTIMIZE TABLE users;
OPTIMIZE TABLE discussions;
OPTIMIZE TABLE posts;
```

## Security

### Access Control

- Database only accessible from `internal_db` network
- Separate user for Flarum with limited privileges
- Root access restricted to container

### Best Practices

- Regular backups of database
- Strong passwords for all users
- Monitor connection attempts
- Keep MariaDB updated to latest version

## Monitoring

### Health Checks

```bash
# Check if MariaDB is running
docker ps | grep flarum_mariadb

# Check database connectivity
docker exec flarum_mariadb mysqladmin ping -h localhost

# Check logs
docker logs flarum_mariadb --tail 50
```

### Metrics to Monitor

- Database connections
- Query performance
- Disk usage
- Memory usage

## Troubleshooting

### Common Issues

**Connection Refused**
```bash
# Check if container is running
docker ps | grep flarum_mariadb

# Restart container
docker restart flarum_mariadb
```

**Database Not Found**
```sql
-- Create database if missing
CREATE DATABASE flarum;
GRANT ALL PRIVILEGES ON flarum.* TO 'flarum'@'%';
FLUSH PRIVILEGES;
```

**Performance Issues**
```sql
-- Check slow queries
SHOW VARIABLES LIKE 'slow_query_log';
SHOW PROCESSLIST;

-- Optimize queries
EXPLAIN SELECT * FROM discussions WHERE user_id = 1;
```

## Integration

### Flarum Configuration

Flarum connects to MariaDB using the following configuration:

```php
// config.php
'database' => [
    'driver' => 'mysql',
    'host' => 'flarum_mariadb',
    'port' => '3306',
    'database' => 'flarum',
    'username' => 'flarum',
    'password' => '${FLARUM_DB_PASSWORD}',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => false,
],
```

## Maintenance

### Regular Tasks

- Weekly database backups
- Monthly optimization
- Quarterly security updates
- Monitor disk usage

### Backup Schedule

```bash
# Daily backup (cron job)
0 2 * * * docker exec flarum_mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} flarum | gzip > /backups/flarum_$(date +\%Y\%m\%d).sql.gz
```

## Version Information

- **MariaDB Version**: Latest stable from Docker Hub
- **Deployed**: 2026-01-17
- **Last Updated**: 2026-01-17
- **Compatibility**: Flarum forum software

## Related Services

- **Flarum**: Primary consumer of this database
- **PostgreSQL**: Other services use PostgreSQL
- **Caddy**: Reverse proxy for Flarum web interface

## References

- [MariaDB Official Documentation](https://mariadb.com/kb/en/)
- [Flarum Database Requirements](https://docs.flarum.org/install/)
- [Docker Hub MariaDB](https://hub.docker.com/_/mariadb)
