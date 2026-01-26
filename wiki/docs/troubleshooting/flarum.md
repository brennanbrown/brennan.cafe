# Flarum Forum Troubleshooting

Flarum is a modern forum software. This page covers common issues and solutions.

## Common Issues

### Database Driver Incompatibility

**Symptoms:**
- "SQLSTATE[HY000] Connection refused" during installation
- Installation page keeps showing despite database being up
- Admin account creation fails

**Root Causes:**
- Flarum Docker image only supports MySQL, not PostgreSQL
- PostgreSQL database created but Flarum expects MySQL
- Network connectivity issues between Flarum and database

**Solutions:**

#### Use MariaDB Instead of PostgreSQL
```yaml
# Add MariaDB to Flarum setup
services:
  flarum:
    image: mondedie/flarum:stable
    environment:
      - DB_HOST=mariadb
      - DB_DRIVER=mysql
      - DB_NAME=flarum
      - DB_USER=flarum
      - DB_PASS=flarum_password
    depends_on:
      - mariadb
  
  mariadb:
    image: mariadb:10.5
    container_name: flarum_mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword123
      - MYSQL_DATABASE=flarum
      - MYSQL_USER=flarum
      - MYSQL_PASSWORD=flarum_password
    volumes:
      - flarum_db_data:/var/lib/mysql
```

#### Complete Installation
```bash
# Visit https://forum.brennan.page
# Fill in installation details:
# MySQL Host: mariadb
# MySQL Database: flarum
# MySQL Username: flarum
# MySQL Password: flarum_password
# Table Prefix: flarum_
# Admin Username: admin
# Admin Email: admin@brennan.page
# Admin Password: admin123456
```

### Installation Reset Issues

**Symptoms:**
- Installation page reappears after restart
- "Base table already exists" errors
- Admin account lost after restart

**Solutions:**

#### Clear Database and Restart
```bash
# Stop services
docker compose down

# Remove database volume
docker volume rm flarum_flarum_db_data

# Start fresh
docker compose up -d

# Complete installation via web interface
```

#### Manual Database Cleanup
```bash
# Access MariaDB and clear database
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "
  DROP DATABASE IF EXISTS flarum;
  CREATE DATABASE flarum;
"

# Restart Flarum
docker restart flarum
```

### Admin Panel Email/Password Errors

**Symptoms:**
- "Something went wrong" when changing email or password
- Email verification required but no mail service configured
- Admin settings cannot be modified

**Root Causes:**
- Flarum tries to send confirmation emails but no mail driver configured
- Mail driver defaults to SMTP but no SMTP service set up

**Solutions:**

#### Configure Mail Driver to "log"
1. Access admin panel: `https://forum.brennan.page/admin`
2. Navigate to Settings → Mail
3. Set Mail Driver to `log`
4. Save settings

#### Password Reset via Logs
```bash
# 1. Click "Change Password" button in admin panel
# 2. Find reset link in logs:
docker logs flarum --tail 100 | grep -E 'reset.*forum\.brennan\.page'

# 3. Visit reset link to set new password
# Example: https://forum.brennan.page/reset/TOKEN_HERE
```

#### Direct Database Password Reset
```bash
# Generate new password hash
docker exec flarum php -r "echo password_hash('newpassword123', PASSWORD_DEFAULT);"

# Update password in database
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "
  UPDATE flarum_users SET password = '\$2y\$10\$NEW_HASH_HERE' WHERE username = 'admin';
"
```

### Performance Issues

**Symptoms:**
- Slow page loading
- High memory usage
- Database timeouts

**Solutions:**

#### Optimize Database
```bash
# Optimize MariaDB
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "
  OPTIMIZE TABLE flarum_posts;
  OPTIMIZE TABLE flarum_users;
  OPTIMIZE TABLE flarum_discussions;
"
```

#### Increase Memory Limits
```yaml
# Update docker-compose.yml
services:
  flarum:
    mem_limit: 256m
    mem_reservation: 128m
```

## Quick Fixes

### Installation Problems
```bash
# Restart installation
docker compose down
docker compose up -d

# Check database connectivity
docker exec flarum ping -c 2 mariadb

# Check logs
docker logs flarum --tail 20
```

### Admin Access Issues
```bash
# Check if admin user exists
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "
  SELECT username FROM flarum_users WHERE username = 'admin';
"

# Create admin if not exists
docker exec flarum_mariadb mysql -u root -prootpassword123 -e "
  INSERT INTO flarum_users (username, email, password, is_activated, joined_at)
  VALUES ('admin', 'admin@brennan.page', '\$2y\$10\$HASH_HERE', 1, NOW());
"
```

### Network Issues
```bash
# Check network connectivity
docker exec flarum ping -c 2 mariadb

# Check port mapping
docker port flarum

# Test direct access
curl -I http://localhost:8888
```

## Recovery Procedures

### Database Backup
```bash
# Backup Flarum database
docker exec flarum_mariadb mysqldump -u root -prootpassword123 flarum > /opt/homelab/backups/flarum-$(date +%Y%m%d).sql
```

### Database Restore
```bash
# Stop services
docker stop flarum

# Remove database volume
docker volume rm flarum_flarum_db_data

# Start services
docker compose up -d

# Restore database
docker exec flarum_mariadb mysql -u root -prootpassword123 flarum < /opt/homelab/backups/flarum-20260116.sql
```

### Complete Reset
```bash
# Stop everything
docker compose down

# Remove all volumes
docker volume rm flarum_flarum_db_data flarum_flarum_data

# Start fresh
docker compose up -d

# Complete installation
```

## Prevention

### Regular Maintenance
- [ ] Monitor database size
- [ ] Check error logs
- [ ] Test admin functionality
- [ ] Backup database regularly

### Best Practices
- Use MariaDB instead of PostgreSQL for Flarum
- Configure mail driver to "log" for development
- Set proper memory limits (256m minimum)
- Keep database backups

### Performance Optimization
```yaml
# Recommended docker-compose.yml
services:
  flarum:
    image: mondedie/flarum:stable
    mem_limit: 256m
    mem_reservation: 128m
    environment:
      - DB_HOST=mariadb
      - DB_DRIVER=mysql
      - FLARUM_ADMIN_USER=admin
      - FLARUM_ADMIN_PASS=admin123456
      - FLARUM_ADMIN_MAIL=admin@brennan.page
```

## Getting Help

### Before Reporting Issues
- [ ] Checked MariaDB connectivity
- [ ] Verified installation completion
- [ ] Tested admin panel access
- [ ] Reviewed error logs

### Information to Include
- Installation status
- Database connection test results
- Admin panel error messages
- Container logs
- Docker compose configuration
