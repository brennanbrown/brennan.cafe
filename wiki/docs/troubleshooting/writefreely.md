# WriteFreely Blog Troubleshooting

WriteFreely is a minimalist blogging platform. This page covers common issues and solutions.

## Common Issues

### Configuration File Problems

**Symptoms:**
- Container restarting continuously
- "Unable to load configuration: open config.ini: no such file or directory"
- Service shows HTTP 503 errors

**Root Causes:**
- Wrong Docker image used (official image has config issues)
- Config file mounted in wrong location
- Environment variables not properly set

**Solutions:**

#### Use Correct Docker Image
```yaml
# Use algernon/writefreely image instead of official
image: algernon/writefreely:latest
```

#### Create Proper Config File
```bash
mkdir -p data
cat > data/config.ini << 'EOF'
[server]
host = 0.0.0.0
port = 80

[database]
type = sqlite3
filename = writefreely.db

[app]
site_name = Brennan's Blog
site_description = Personal blog and thoughts
host = https://blog.brennan.page
single_user = true
federation = true
EOF
```

#### Mount Config Correctly
```yaml
volumes:
  - ./data:/data
```

### Admin Account Creation

**Symptoms:**
- "No admin user exists yet" error
- Cannot access admin panel
- Login page shows but no admin account created

**Solutions:**

#### Create Admin User
```bash
# Create admin user with correct syntax
docker exec writefreely sh -c 'cd /data && /writefreely/writefreely user create --admin username:password'

# Note: "admin" username is reserved, use different username
docker exec writefreely sh -c 'cd /data && /writefreely/writefreely user create --admin brennan:password123'
```

#### Alternative: Use Web Interface
1. Visit `https://blog.brennan.page`
2. Click "Create account"
3. Use your preferred username and password

### Port Configuration Issues

**Symptoms:**
- HTTP 503 errors from Caddy
- Service accessible internally but not via proxy
- Wrong port in Caddyfile

**Solutions:**

#### Check Actual Port
```bash
# Check what port WriteFreely is actually using
docker exec writefreely netstat -tlnp | grep :8080
```

#### Update Caddyfile
```bash
# Update Caddyfile to use correct port
# Change: reverse_proxy writefreely:80
# To: reverse_proxy writefreely:8080

# Reload Caddy
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### Database Issues

**Symptoms:**
- Database connection errors
- SQLite database file not found
- Permission denied accessing database

**Solutions:**

#### Check Database File
```bash
# Check if database exists
docker exec writefreely ls -la /data/writefreely.db

# Fix permissions if needed
docker exec writefreely chown writefreely:writefreely /data/writefreely.db
```

#### Recreate Database
```bash
# Stop service and remove database
docker compose down
rm -rf data/writefreely.db

# Start service (will create new database)
docker compose up -d
```

## Quick Fixes

### Service Not Responding
```bash
# Restart WriteFreely
docker restart writefreely

# Check logs
docker logs writefreely --tail 20
```

### Cannot Access Admin Panel
```bash
# Create new admin user
docker exec writefreely sh -c 'cd /data && /writefreely/writefreely user create --admin username:password'

# Restart service
docker restart writefreely
```

### HTTP 503 Errors
```bash
# Check Caddy proxy configuration
docker exec caddy cat /etc/caddy/Caddyfile | grep -A 5 blog

# Update port if wrong
docker exec caddy sed -i 's/reverse_proxy writefreely:80/reverse_proxy writefreely:8080/' /etc/caddy/Caddyfile

# Reload Caddy
docker restart caddy
```

## Recovery Procedures

### Data Backup
```bash
# Backup WriteFreely data
docker cp -r /opt/homelab/services/writefreely/data /opt/homelab/backups/writefreely-$(date +%Y%m%d)
```

### Data Restore
```bash
# Stop service
docker stop writefreely

# Remove current data
rm -rf /opt/homelab/services/writefreely/data

# Restore from backup
docker cp -r /opt/homelab/backups/writefreely-20260116 /opt/homelab/services/writefreely/data

# Start service
docker start writefreely
```

### Complete Reset
```bash
# Stop and remove everything
docker compose down
rm -rf data
docker volume rm writefreely_writefreely_data

# Start fresh
docker compose up -d
```

## Prevention

### Regular Maintenance
- [ ] Monitor container status
- [ ] Check disk space usage
- [ ] Backup data regularly
- [ ] Test admin access

### Best Practices
- Use `algernon/writefreely` image for better config handling
- Keep config file in mounted volume
- Use SQLite for simplicity (PostgreSQL not supported)
- Set proper memory limits (128m minimum)

## Getting Help

### Before Reporting Issues
- [ ] Checked container logs
- [ ] Verified config file exists
- [ ] Tested port configuration
- [ ] Attempted service restart

### Information to Include
- Container logs (`docker logs writefreely --tail 50`)
- Config file contents
- Caddyfile configuration
- System resource usage
