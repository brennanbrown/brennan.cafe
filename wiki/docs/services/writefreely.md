# WriteFreely

WriteFreely is a clean, minimalist blogging platform designed for writers. In the brennan.page homelab, it powers the blog.brennan.page subdomain, providing a distraction-free writing and publishing experience.

## Overview

- **Purpose**: Personal blogging platform
- **URL**: https://blog.brennan.page
- **Version**: Latest stable (Docker Hub)
- **Container**: `writefreely`
- **Database**: PostgreSQL (dedicated database)
- **Network**: `caddy`, `internal_db`

## Features

### Core Functionality
- **Markdown Editor**: Clean, distraction-free writing interface
- **Multiple Blogs**: Support for multiple blogs from one installation
- **RSS Feeds**: Automatic RSS feed generation
- **Static Site Generation**: Optional static site generation
- **Custom Themes**: Basic theme customization
- **Import/Export**: Support for importing from other platforms

### Authentication
- **Local Accounts**: Built-in user registration and authentication
- **Anonymous Posts**: Optional anonymous posting capability
- **Password Protection**: Blog-level password protection

## Configuration

### Docker Compose

```yaml
services:
  writefreely:
    image: writeas/writefreely:latest
    container_name: writefreely
    restart: unless-stopped
    environment:
      - WRITEFREELY_DATABASE_TYPE=postgres
      - WRITEFREELY_DATABASE_HOST=postgresql
      - WRITEFREELY_DATABASE_NAME=writefreely
      - WRITEFREELY_DATABASE_USER=writefreely
      - WRITEFREELY_DATABASE_PASSWORD=${WRITEFREELY_DB_PASSWORD}
      - WRITEFREELY_SITE_URL=https://blog.brennan.page
      - WRITEFREELY_SINGLE_USER=true
    ports:
      - "8080:8080"
    volumes:
      - writefreely_data:/go/data
    networks:
      - caddy
      - internal_db
    depends_on:
      - postgresql
    mem_limit: 100m

volumes:
  writefreely_data:
```

### Environment Variables

- `WRITEFREELY_DATABASE_TYPE`: Database type (postgres)
- `WRITEFREELY_DATABASE_HOST`: Database host (postgresql)
- `WRITEFREELY_DATABASE_NAME`: Database name
- `WRITEFREELY_DATABASE_USER`: Database user
- `WRITEFREELY_DATABASE_PASSWORD`: Database password
- `WRITEFREELY_SITE_URL`: Public URL of the blog
- `WRITEFREELY_SINGLE_USER`: Single user mode

### Caddy Configuration

```caddyfile
blog.brennan.page {
    reverse_proxy writefreely:8080
    encode gzip
}
```

## Database Schema

### PostgreSQL Tables

```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) UNIQUE NOT NULL,
    password_hash VARCHAR(128) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(255),
    content TEXT,
    user_id INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Blogs table
CREATE TABLE blogs (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Management

### Admin Interface

Access the admin interface at:
- URL: https://blog.brennan.page/admin
- Login: Use your WriteFreely account credentials

### Common Operations

```bash
# Check container status
docker ps | grep writefreely

# View logs
docker logs writefreely --tail 50

# Access container shell
docker exec -it writefreely sh

# Restart service
docker restart writefreely
```

### Database Management

```sql
-- Connect to WriteFreely database
docker exec postgresql psql -U writefreely -d writefreely

-- List posts
SELECT id, title, status, created_at FROM posts ORDER BY created_at DESC;

-- Count posts by status
SELECT status, COUNT(*) FROM posts GROUP BY status;

-- Check user accounts
SELECT username, email, created_at FROM users;
```

## Content Management

### Creating Posts

1. **Web Interface**: Navigate to https://blog.brennan.page
2. **Login**: Use your account credentials
3. **New Post**: Click "New Post" button
4. **Write**: Use the markdown editor
5. **Publish**: Set status to "published" when ready

### Post Management

- **Drafts**: Save posts as drafts before publishing
- **Publishing**: Change status from "draft" to "published"
- **Editing**: Edit published posts at any time
- **Deleting**: Remove unwanted posts

### Markdown Support

WriteFreely supports standard GitHub-flavored markdown:

```markdown
# Heading 1
## Heading 2

**Bold text** and *italic text*

- List item 1
- List item 2

[Link text](https://example.com)

`Inline code`

```python
# Code block
print("Hello, World!")
```

> Blockquote
```

## Performance

### Resource Usage

- **Memory Limit**: 100MB
- **Storage**: Persistent volume for posts and media
- **Database**: PostgreSQL backend
- **Network**: HTTP/HTTPS access via Caddy

### Optimization Tips

- **Images**: Optimize images before uploading
- **Database**: Regular maintenance and cleanup
- **Caching**: Enable browser caching via Caddy
- **Backups**: Regular database and file backups

## Security

### Access Control

- **Authentication**: Required for posting and admin functions
- **HTTPS**: All traffic encrypted via Caddy
- **Database**: Isolated database user with limited privileges
- **Network**: Only accessible through reverse proxy

### Best Practices

- **Strong Passwords**: Use strong admin passwords
- **Regular Updates**: Keep WriteFreely updated
- **Backup Strategy**: Regular database and file backups
- **Access Logs**: Monitor access via Caddy logs

## Monitoring

### Health Checks

```bash
# Check if WriteFreely is responding
curl -f https://blog.brennan.page

# Check service status
docker ps | grep writefreely

# Monitor resource usage
docker stats writefreely
```

### Log Monitoring

```bash
# View recent logs
docker logs writefreely --since=1h

# Monitor for errors
docker logs writefreely | grep -i error

# Check access patterns
docker logs writefreely | grep -E "GET|POST"
```

## Troubleshooting

### Common Issues

**Service Not Accessible**
```bash
# Check Caddy configuration
docker exec caddy caddy reload

# Check WriteFreely logs
docker logs writefreely

# Verify database connection
docker exec writefreely curl -f http://localhost:8080
```

**Database Connection Issues**
```bash
# Check PostgreSQL status
docker exec postgresql pg_isready

# Test database connection
docker exec writefreely ping postgresql

# Check database credentials
docker exec postgresql psql -U writefreely -d writefreely -c "SELECT 1;"
```

**Post Not Publishing**
```bash
# Check post status in database
docker exec postgresql psql -U writefreely -d writefreely -c "SELECT slug, status FROM posts;"

# Clear WriteFreely cache
docker restart writefreely
```

## Integration

### RSS Feeds

WriteFreely automatically generates RSS feeds:
- Main feed: https://blog.brennan.page/feed
- Individual posts: https://blog.brennan.page/post-slug/feed

### Static Site Generation

Optional static site generation for deployment:
```bash
# Generate static site (if configured)
docker exec writefreely writefreely generate
```

## Customization

### Themes

WriteFreely supports basic theme customization:
- **CSS**: Custom CSS via admin interface
- **Layout**: Limited layout customization
- **Fonts**: Custom font options

### Configuration Files

WriteFreely configuration is stored in `/go/data`:
- `config.ini`: Main configuration file
- `posts/`: Blog posts directory
- `static/`: Static assets directory

## Backup and Recovery

### Database Backup

```bash
# Backup WriteFreely database
docker exec postgresql pg_dump -U writefreely writefreely > writefreely_backup.sql

# Restore database
docker exec -i postgresql psql -U writefreely writefreely < writefreely_backup.sql
```

### File Backup

```bash
# Backup WriteFreely data volume
docker run --rm -v writefreely_data:/source -v $(pwd):/backup alpine tar czf /backup/writefreely_data.tar.gz -C /source .

# Restore data volume
docker run --rm -v writefreely_data:/target -v $(pwd):/backup alpine tar xzf /backup/writefreely_data.tar.gz -C /target
```

## Maintenance

### Regular Tasks

- **Weekly**: Check for WriteFreely updates
- **Monthly**: Database optimization and cleanup
- **Quarterly**: Review security settings
- **As Needed**: Content backup and restoration

### Performance Monitoring

Monitor these metrics:
- Response time
- Database query performance
- Storage usage
- Memory usage

## Version Information

- **WriteFreely Version**: Latest stable from Docker Hub
- **Deployed**: 2026-01-17
- **Database**: PostgreSQL 15
- **Last Updated**: 2026-01-17

## Related Services

- **PostgreSQL**: Database backend
- **Caddy**: Reverse proxy and SSL termination
- **Other Blogs**: Part of content & community platform

## References

- [WriteFreely Official Documentation](https://writefreely.org/docs/)
- [WriteFreely GitHub](https://github.com/writeas/writefreely)
- [Docker Hub WriteFreely](https://hub.docker.com/r/writeas/writefreely)
