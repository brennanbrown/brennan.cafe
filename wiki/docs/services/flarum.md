# Flarum

Flarum is a modern, extensible forum software designed for building online communities. In the brennan.page homelab, it powers the forum.brennan.page subdomain, providing a space for community discussions and engagement.

## Overview

- **Purpose**: Community forum platform
- **URL**: https://forum.brennan.page
- **Version**: Latest stable (Docker Hub)
- **Container**: `flarum`
- **Database**: MariaDB (dedicated database)
- **Network**: `caddy`, `internal_db`

## Features

### Core Functionality
- **Modern Interface**: Clean, responsive design
- **Real-time Updates**: Live notifications and updates
- **Rich Formatting**: Markdown-based post formatting
- **User Management**: Registration, profiles, and permissions
- **Moderation Tools**: Content moderation and user management
- **Extensible Architecture**: Plugin system for extensions

### Forum Features
- **Discussions**: Threaded discussions with replies
- **Tags**: Categorization and organization
- **User Profiles**: Customizable user profiles
- **Notifications**: Email and in-app notifications
- **Search**: Full-text search functionality
- **Attachments**: File and image uploads

## Configuration

### Docker Compose

```yaml
services:
  flarum:
    image: mondedie/flarum:latest
    container_name: flarum
    restart: unless-stopped
    environment:
      - DEBUG=false
      - FORUM_URL=https://forum.brennan.page
      - DB_HOST=flarum_mariadb
      - DB_NAME=flarum
      - DB_USER=flarum
      - DB_PASS=${FLARUM_DB_PASSWORD}
      - DB_PREF=flarum_
      - DB_USER_ROOT=root
      - DB_PASS_ROOT=${MYSQL_ROOT_PASSWORD}
      - MAIL_DRIVER=smtp
      - MAIL_HOST=mailhog
      - MAIL_PORT=1025
      - MAIL_USERNAME=null
      - MAIL_PASSWORD=null
      - MAIL_ENCRYPTION=tcp
    volumes:
      - flarum_assets:/flarum/app/assets
      - flarum_extensions:/flarum/app/extensions
      - flarum_config:/flarum/app/config
    networks:
      - caddy
      - internal_db
    depends_on:
      - flarum_mariadb
    mem_limit: 200m

volumes:
  flarum_assets:
  flarum_extensions:
  flarum_config:
```

### Environment Variables

- `FORUM_URL`: Public URL of the forum
- `DB_HOST`: Database host (flarum_mariadb)
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASS`: Database password
- `DB_PREF`: Database table prefix
- `MAIL_DRIVER`: Email configuration

### Caddy Configuration

```caddyfile
forum.brennan.page {
    reverse_proxy flarum:8888
    encode gzip
}
```

## Database Schema

### MariaDB Tables

```sql
-- Users table
CREATE TABLE flarum_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Discussions table
CREATE TABLE flarum_discussions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    user_id INT REFERENCES flarum_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table
CREATE TABLE flarum_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    discussion_id INT REFERENCES flarum_discussions(id),
    user_id INT REFERENCES flarum_users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    number INT NOT NULL
);

-- Tags table
CREATE TABLE flarum_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#888'
);
```

## Management

### Admin Interface

Access the admin interface at:
- URL: https://forum.brennan.page/admin
- Login: Use your Flarum admin account

### Common Operations

```bash
# Check container status
docker ps | grep flarum

# View logs
docker logs flarum --tail 50

# Access container shell
docker exec -it flarum sh

# Restart service
docker restart flarum
```

### Database Management

```sql
-- Connect to Flarum database
docker exec flarum_mariadb mysql -u flarum -p flarum

-- List discussions
SELECT id, title, created_at FROM flarum_discussions ORDER BY last_posted_at DESC;

-- Count posts by user
SELECT u.username, COUNT(p.id) as post_count 
FROM flarum_users u 
LEFT JOIN flarum_posts p ON u.id = p.user_id 
GROUP BY u.id, u.username 
ORDER BY post_count DESC;

-- Check user registrations
SELECT username, email, created_at FROM flarum_users ORDER BY created_at DESC;
```

## User Management

### Registration

Flarum supports user registration:
- **Public Registration**: Can be enabled/disabled in admin panel
- **Email Verification**: Optional email verification
- **Approval Process**: Optional admin approval required

### User Roles

- **Administrator**: Full access to all features
- **Moderator**: Can moderate content and users
- **Member**: Standard user with posting privileges
- **Guest**: Read-only access (if allowed)

### Permissions

Configure permissions in admin panel:
- **Global Permissions**: Site-wide permissions
- **Tag Permissions**: Category-specific permissions
- **Group Permissions**: Role-based permissions

## Content Management

### Discussions

Creating and managing discussions:
1. **New Discussion**: Click "Start Discussion" button
2. **Title**: Enter discussion title
3. **Content**: Write initial post in markdown
4. **Tags**: Select appropriate tags
5. **Publish**: Make discussion live

### Post Formatting

Flarum supports rich markdown formatting:

```markdown
# Heading

**Bold text** and *italic text*

- List item 1
- List item 2

[Link text](https://example.com)

`Inline code`

```javascript
// Code block
function hello() {
    console.log("Hello, World!");
}
```

> Blockquote

@username - Mention users
```

### Attachments

- **Images**: Drag and drop or click to upload
- **Files**: Upload various file types
- **Size Limits**: Configurable in admin panel
- **Storage**: Stored in Docker volume

## Performance

### Resource Usage

- **Memory Limit**: 200MB
- **Storage**: Persistent volumes for assets and extensions
- **Database**: MariaDB backend
- **Network**: HTTP/HTTPS access via Caddy

### Optimization Tips

- **Caching**: Enable Flarum caching
- **Images**: Optimize uploaded images
- **Database**: Regular maintenance and optimization
- **Extensions**: Limit installed extensions

## Security

### Access Control

- **Authentication**: Required for posting and admin functions
- **HTTPS**: All traffic encrypted via Caddy
- **Database**: Isolated database user with limited privileges
- **Network**: Only accessible through reverse proxy

### Security Features

- **CSRF Protection**: Built-in CSRF protection
- **XSS Prevention**: Input sanitization
- **Rate Limiting**: Configurable rate limits
- **Password Security**: Strong password hashing

### Best Practices

- **Regular Updates**: Keep Flarum and extensions updated
- **Backup Strategy**: Regular database and file backups
- **Access Monitoring**: Monitor admin access
- **User Moderation**: Active moderation of content

## Extensions

### Popular Extensions

- **FoF Upload**: Enhanced file upload capabilities
- **FoF Follow Tags**: Follow specific tags
- **FoF Night Mode**: Dark mode support
- **FoF Best Answer**: Mark best answers in discussions

### Extension Management

```bash
# Install extension (via admin panel or CLI)
docker exec flarum composer require flarum/core

# Update extensions
docker exec flarum composer update

# Clear cache
docker exec flarum php flarum cache:clear
```

## Monitoring

### Health Checks

```bash
# Check if Flarum is responding
curl -f https://forum.brennan.page

# Check service status
docker ps | grep flarum

# Monitor resource usage
docker stats flarum
```

### Log Monitoring

```bash
# View recent logs
docker logs flarum --since=1h

# Monitor for errors
docker logs flarum | grep -i error

# Check access patterns
docker logs flarum | grep -E "GET|POST"
```

### Performance Metrics

Monitor these metrics:
- Response time
- Database query performance
- Active users
- New discussions
- Post frequency

## Troubleshooting

### Common Issues

**Forum Not Accessible**
```bash
# Check Caddy configuration
docker exec caddy caddy reload

# Check Flarum logs
docker logs flarum

# Verify database connection
docker exec flarum curl -f http://localhost:8888
```

**Database Connection Issues**
```bash
# Check MariaDB status
docker exec flarum_mariadb mysqladmin ping

# Test database connection
docker exec flarum ping flarum_mariadb

# Check database credentials
docker exec flarum_mariadb mysql -u flarum -p flarum -c "SELECT 1;"
```

**Extension Issues**
```bash
# Clear Flarum cache
docker exec flarum php flarum cache:clear

# Rebuild assets
docker exec flarum php flarum assets:publish

# Check extension status
docker exec flarum php flarum extension:list
```

## Integration

### Email Configuration

Configure email settings for notifications:
```bash
# Set up SMTP (example with MailHog for testing)
MAIL_DRIVER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
```

### RSS Feeds

Flarum supports RSS feeds:
- Recent discussions: https://forum.brennan.page/feed
- Tag-specific feeds: https://forum.brennan.page/tag/tagname/feed

## Customization

### Themes

Flarum supports theme customization:
- **Colors**: Customize color scheme
- **Fonts**: Custom font options
- **Layout**: Limited layout customization
- **Logo**: Custom logo upload

### Custom CSS

Add custom CSS via admin panel:
```css
/* Custom CSS example */
.DiscussionList-item {
    border-bottom: 1px solid #e0e0e0;
}

.UserCard {
    background: #f5f5f5;
}
```

## Backup and Recovery

### Database Backup

```bash
# Backup Flarum database
docker exec flarum_mariadb mysqldump -u root -p flarum > flarum_backup.sql

# Restore database
docker exec -i flarum_mariadb mysql -u root -p flarum < flarum_backup.sql
```

### File Backup

```bash
# Backup Flarum volumes
docker run --rm -v flarum_assets:/source -v flarum_extensions:/source -v flarum_config:/source -v $(pwd):/backup alpine tar czf /backup/flarum_volumes.tar.gz -C /source .

# Restore volumes
docker run --rm -v flarum_assets:/target -v flarum_extensions:/target -v flarum_config:/target -v $(pwd):/backup alpine tar xzf /backup/flarum_volumes.tar.gz -C /target
```

## Maintenance

### Regular Tasks

- **Weekly**: Check for Flarum and extension updates
- **Monthly**: Database optimization and cleanup
- **Quarterly**: Review user activity and moderation
- **As Needed**: Content moderation and user management

### Performance Monitoring

Monitor these metrics:
- Active users
- New discussions per day
- Post frequency
- Database performance
- Storage usage

## Version Information

- **Flarum Version**: Latest stable from Docker Hub
- **Deployed**: 2026-01-17
- **Database**: MariaDB latest
- **Last Updated**: 2026-01-17

## Related Services

- **MariaDB**: Database backend
- **Caddy**: Reverse proxy and SSL termination
- **Other Community Tools**: Part of content & community platform

## References

- [Flarum Official Documentation](https://docs.flarum.org/)
- [Flarum Community](https://discuss.flarum.org/)
- [Docker Hub Flarum](https://hub.docker.com/r/mondedie/flarum)
