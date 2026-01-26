# FreshRSS

FreshRSS is a self-hosted RSS feed aggregator that allows you to organize, read, and share RSS/Atom feeds. In the brennan.page homelab, it powers the rss.brennan.page subdomain, providing a personal news and content aggregation service.

## Overview

- **Purpose**: RSS feed aggregation and reading
- **URL**: https://rss.brennan.page
- **Version**: Latest stable (Docker Hub)
- **Container**: `freshrss`
- **Database**: PostgreSQL (dedicated database)
- **Network**: `caddy`, `internal_db`

## Features

### Core Functionality
- **Feed Aggregation**: Subscribe to RSS/Atom feeds
- **Categorization**: Organize feeds into categories
- **Reading Interface**: Clean, responsive reading experience
- **Mobile Support**: Mobile-friendly interface
- **Import/Export**: OPML import/export functionality
- **Search**: Full-text search across articles

### Reading Features
- **Article Views**: List, card, and magazine views
- **Mark as Read**: Track read/unread status
- **Favorites**: Save favorite articles
- **Sharing**: Share articles via various methods
- **Offline Reading**: Limited offline capability

## Configuration

### Docker Compose

```yaml
services:
  freshrss:
    image: freshrss/freshrss:latest
    container_name: freshrss
    restart: unless-stopped
    environment:
      - TZ=America/Toronto
      - CRON_MIN=1,31
    ports:
      - "80:80"
    volumes:
      - freshrss_data:/var/www/FreshRSS/data
      - freshrss_extensions:/var/www/FreshRSS/extensions
    networks:
      - caddy
      - internal_db
    depends_on:
      - freshrss_db
    mem_limit: 100m

  freshrss_db:
    image: postgres:15-alpine
    container_name: freshrss_db
    restart: unless-stopped
    environment:
      - POSTGRES_DB=freshrss
      - POSTGRES_USER=freshrss
      - POSTGRES_PASSWORD=${FRESHRSS_DB_PASSWORD}
    volumes:
      - freshrss_db_data:/var/lib/postgresql/data
    networks:
      - internal_db
    mem_limit: 128m

volumes:
  freshrss_data:
  freshrss_extensions:
  freshrss_db_data:
```

### Environment Variables

- `TZ`: Timezone for cron jobs
- `CRON_MIN`: Minutes for cron job execution
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password

### Caddy Configuration

```caddyfile
rss.brennan.page {
    reverse_proxy freshrss:80
    encode gzip
}
```

## Database Schema

### PostgreSQL Tables

```sql
-- Categories table
CREATE TABLE category (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(7) DEFAULT '#888',
    position INTEGER DEFAULT 0
);

-- Feeds table
CREATE TABLE feed (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    url VARCHAR(2048) NOT NULL,
    name VARCHAR(255) NOT NULL,
    website VARCHAR(2048),
    description TEXT,
    category_id INTEGER REFERENCES category(id),
    priority INTEGER DEFAULT 10,
    keep_history INTEGER DEFAULT 0,
    ttl INTEGER DEFAULT 0,
    attributes TEXT,
    last_update DATETIME
);

-- Entries table
CREATE TABLE entry (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    guid VARCHAR(2048) NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    content TEXT,
    link VARCHAR(2048),
    date DATETIME,
    hash VARCHAR(255),
    is_read BOOLEAN DEFAULT 0,
    is_favorite BOOLEAN DEFAULT 0,
    feed_id INTEGER REFERENCES feed(id),
    tags TEXT
);

-- Users table
CREATE TABLE user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mail VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT 1,
    is_admin BOOLEAN DEFAULT 0
);
```

## Management

### Admin Interface

Access the admin interface at:
- URL: https://rss.brennan.page/i/
- Login: Use your FreshRSS account credentials

### Common Operations

```bash
# Check container status
docker ps | grep freshrss

# View logs
docker logs freshrss --tail 50

# Access container shell
docker exec -it freshrss sh

# Restart service
docker restart freshrss
```

### Database Management

```sql
-- Connect to FreshRSS database
docker exec freshrss_db psql -U freshrss -d freshrss

-- List feeds
SELECT id, name, url, last_update FROM feed ORDER BY name;

-- Count articles by feed
SELECT f.name, COUNT(e.id) as article_count 
FROM feed f 
LEFT JOIN entry e ON f.id = e.feed_id 
GROUP BY f.id, f.name 
ORDER BY article_count DESC;

-- Check unread articles
SELECT COUNT(*) as unread_count FROM entry WHERE is_read = 0;

-- List categories
SELECT id, name, color FROM category ORDER BY position;
```

## Feed Management

### Adding Feeds

1. **Manual Addition**: 
   - Navigate to https://rss.brennan.page/i/
   - Click "Add a feed"
   - Enter feed URL
   - Select category
   - Configure options

2. **OPML Import**:
   - Export from other RSS reader
   - Import via FreshRSS interface
   - Bulk feed addition

### Feed Configuration

Feed configuration options:
- **Category**: Organize feeds by topic
- **Priority**: Update frequency priority
- **Keep History**: Number of articles to retain
- **TTL**: Time to live for feed updates
- **Attributes**: Custom feed attributes

### Categories

Create and manage categories:
- **Default Categories**: General, Technology, News, etc.
- **Custom Categories**: Create personalized categories
- **Color Coding**: Visual organization with colors
- **Position**: Order categories in interface

## Reading Interface

### Views

FreshRSS offers multiple viewing modes:
- **List View**: Compact article list
- **Card View**: Visual card layout
- **Magazine View**: Magazine-style layout
- **Global View**: All articles in one stream

### Reading Features

- **Article Reading**: Full article content display
- **Mark as Read**: Track reading progress
- **Favorites**: Save important articles
- **Tags**: Organize articles with tags
- **Search**: Find specific articles

### Mobile Experience

- **Responsive Design**: Works on mobile devices
- **Touch Gestures**: Swipe navigation
- **Mobile Apps**: Third-party mobile apps available

## Performance

### Resource Usage

- **Memory Limit**: 100MB (FreshRSS), 128MB (Database)
- **Storage**: Persistent volumes for data and extensions
- **Database**: PostgreSQL backend
- **Network**: HTTP/HTTPS access via Caddy

### Optimization Tips

- **Feed Limits**: Limit number of feeds per category
- **History Cleanup**: Regular cleanup of old articles
- **Update Frequency**: Configure appropriate update intervals
- **Database Maintenance**: Regular database optimization

### Cron Jobs

FreshRSS uses cron jobs for:
- **Feed Updates**: Automatic feed fetching
- **Cleanup**: Remove old articles
- **Maintenance**: Database optimization

```bash
# Check cron configuration
docker exec freshrss crontab -l

# Manual feed update
docker exec freshrss php /var/www/FreshRSS/app/actualize_script.php

# Force cleanup
docker exec freshrss php /var/www/FreshRSS/app/cleanup.php
```

## Security

### Access Control

- **Authentication**: Required for personal feeds
- **HTTPS**: All traffic encrypted via Caddy
- **Database**: Isolated database user with limited privileges
- **Network**: Only accessible through reverse proxy

### Security Features

- **User Accounts**: Individual user accounts
- **Admin Controls**: Administrative interface
- **Feed Validation**: Feed URL validation
- **Content Filtering**: Basic content filtering

### Best Practices

- **Regular Updates**: Keep FreshRSS updated
- **Backup Strategy**: Regular database and file backups
- **Access Monitoring**: Monitor user access
- **Feed Security**: Validate feed sources

## Extensions

### Popular Extensions

- **Google Reader API**: Google Reader API compatibility
- **Reddit Enhancement**: Reddit feed improvements
- **Twitter Integration**: Twitter feed support
- **Mobile Themes**: Mobile-optimized themes

### Extension Management

```bash
# Install extension (via admin panel or CLI)
docker exec freshrss php /var/www/FreshRSS/cli/extension.php install extension_name

# Update extensions
docker exec freshrss php /var/www/FreshRSS/cli/extension.php update

# List extensions
docker exec freshrss php /var/www/FreshRSS/cli/extension.php list
```

## Monitoring

### Health Checks

```bash
# Check if FreshRSS is responding
curl -f https://rss.brennan.page

# Check service status
docker ps | grep freshrss

# Monitor resource usage
docker stats freshrss freshrss_db
```

### Log Monitoring

```bash
# View recent logs
docker logs freshrss --since=1h

# Monitor for errors
docker logs freshrss | grep -i error

# Check feed update logs
docker logs freshrss | grep -i "actualize"
```

### Performance Metrics

Monitor these metrics:
- Feed update frequency
- Article processing time
- Database query performance
- Active users
- Storage usage

## Troubleshooting

### Common Issues

**Service Not Accessible**
```bash
# Check Caddy configuration
docker exec caddy caddy reload

# Check FreshRSS logs
docker logs freshrss

# Verify database connection
docker exec freshrss curl -f http://localhost
```

**Feed Update Issues**
```bash
# Manual feed update
docker exec freshrss php /var/www/FreshRSS/app/actualize_script.php

# Check feed configuration
docker exec freshrss php /var/www/FreshRSS/cli/feed.php list

# Clear cache
docker exec freshrss php /var/www/FreshRSS/cli/clear.php
```

**Database Issues**
```bash
# Check PostgreSQL status
docker exec freshrss_db pg_isready

# Test database connection
docker exec freshrss ping freshrss_db

# Check database size
docker exec freshrss_db psql -U freshrss -d freshrss -c "SELECT pg_size_pretty(pg_database_size('freshrss'));"
```

## Integration

### API Access

FreshRSS provides API endpoints:
- **Google Reader API**: For third-party clients
- **FreshRSS API**: Native API access
- **Authentication**: API key authentication

### Third-Party Clients

Compatible RSS readers:
- **Feedly**: Via Google Reader API
- **Reeder**: iOS RSS reader
- **NewsBlur**: RSS service
- **Inoreader**: RSS service

## Customization

### Themes

FreshRSS supports theme customization:
- **Built-in Themes**: Multiple theme options
- **Custom CSS**: Add custom styles
- **Mobile Themes**: Mobile-optimized themes
- **Dark Mode**: Dark theme support

### Configuration

Customize FreshRSS behavior:
```php
// Custom configuration example
define('DEFAULT_KEEP_HISTORY', 30);
define('DEFAULT_LIMIT', 25);
define('DEFAULT_VIEW', 'normal');
```

## Backup and Recovery

### Database Backup

```bash
# Backup FreshRSS database
docker exec freshrss_db pg_dump -U freshrss freshrss > freshrss_backup.sql

# Restore database
docker exec -i freshrss_db psql -U freshrss freshrss < freshrss_backup.sql
```

### File Backup

```bash
# Backup FreshRSS data volume
docker run --rm -v freshrss_data:/source -v $(pwd):/backup alpine tar czf /backup/freshrss_data.tar.gz -C /source .

# Restore data volume
docker run --rm -v freshrss_data:/target -v $(pwd):/backup alpine tar xzf /backup/freshrss_data.tar.gz -C /target
```

### OPML Export

Export feeds for backup:
```bash
# Export feeds via CLI
docker exec freshrss php /var/www/FreshRSS/cli/opml.php export > feeds.opml
```

## Maintenance

### Regular Tasks

- **Weekly**: Check for FreshRSS updates
- **Monthly**: Database optimization and cleanup
- **Quarterly**: Review feed subscriptions
- **As Needed**: Feed management and cleanup

### Performance Monitoring

Monitor these metrics:
- Feed update frequency
- Article processing time
- Database performance
- Storage usage
- Active users

## Version Information

- **FreshRSS Version**: Latest stable from Docker Hub
- **Deployed**: 2026-01-17
- **Database**: PostgreSQL 15
- **Last Updated**: 2026-01-17

## Related Services

- **PostgreSQL**: Database backend
- **Caddy**: Reverse proxy and SSL termination
- **Other Content Tools**: Part of content & community platform

## References

- [FreshRSS Official Documentation](https://freshrss.github.io/FreshRSS/)
- [FreshRSS GitHub](https://github.com/FreshRSS/FreshRSS)
- [Docker Hub FreshRSS](https://hub.docker.com/r/freshrss/freshrss)
