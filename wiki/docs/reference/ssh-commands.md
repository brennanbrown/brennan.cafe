# SSH Commands Reference

This section provides essential SSH commands for managing the brennan.page homelab.

## Connection Information

- **Host**: 159.203.44.169
- **User**: root
- **SSH Key**: `~/.omg-lol-keys/id_ed25519`
- **Domain**: brennan.page

## Standard SSH Command Format

### Basic Command Execution
```bash
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "command"
```

**Critical Flags:**
- `-i ~/.omg-lol-keys/id_ed25519` - Specifies the SSH key
- `-T` - Disables pseudo-terminal allocation (prevents hanging)
- `-o BatchMode=yes` - No password prompts, non-interactive mode

### Multiple Commands
```bash
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  ls -la
  df -h
  echo 'Commands completed'
"
```

### Using Here-Document
```bash
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 << 'EOF'
  cd /opt/homelab/services
  docker compose ps
  docker stats --no-stream
EOF
```

## Common Operations

### System Status
```bash
# System information
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== System Info ==='
  hostnamectl
  echo -e '\n=== Memory Usage ==='
  free -h
  echo -e '\n=== Disk Usage ==='
  df -h
  echo -e '\n=== Uptime ==='
  uptime
"
```

### Docker Operations
```bash
# Check running containers
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "docker ps -a"

# Check Docker stats
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "docker stats --no-stream"

# View container logs
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "docker logs --tail 50 container_name"

# Restart a service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services/servicename
  docker compose restart
"
```

### File System Operations
```bash
# List directory contents
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "ls -lah /opt/homelab"

# Check if file exists
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "test -f /path/to/file && echo 'exists' || echo 'not found'"

# Create directory
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "mkdir -p /opt/homelab/services/newservice"

# Check disk space
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "df -h /opt/homelab"
```

### Service Deployment
```bash
# Deploy a new service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services/servicename
  docker compose pull
  docker compose up -d
  docker compose ps
"
```

## File Transfer Operations

### Upload Files (Local → Server)
```bash
# Single file
scp -i ~/.omg-lol-keys/id_ed25519 localfile.txt root@159.203.44.169:/opt/homelab/

# Directory (recursive)
scp -r -i ~/.omg-lol-keys/id_ed25519 local-directory/ root@159.203.44.169:/opt/homelab/

# Using rsync (preferred for directories)
rsync -avz --exclude '.git' -e "ssh -i ~/.omg-lol-keys/id_ed25519" \
  ./local-directory/ root@159.203.44.169:/opt/homelab/services/
```

### Download Files (Server → Local)
```bash
# Single file
scp -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169:/opt/homelab/file.txt ./

# Directory
scp -r -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169:/opt/homelab/services/ ./

# Using rsync
rsync -avz -e "ssh -i ~/.omg-lol-keys/id_ed25519" \
  root@159.203.44.169:/opt/homelab/backups/ ./local-backups/
```

## File Editing Workflow

### ❌ NEVER DO THIS (Will Hang)
```bash
# DON'T use interactive editors over SSH
ssh ... "micro /etc/config.file"
ssh ... "nano /etc/config.file"
ssh ... "vim /etc/config.file"
```

### ✅ CORRECT File Editing Workflow

**Method 1: Download → Edit → Upload**
```bash
# 1. Download file
scp -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169:/etc/caddy/Caddyfile ./Caddyfile

# 2. Edit locally
micro ./Caddyfile

# 3. Upload back
scp -i ~/.omg-lol-keys/id_ed25519 ./Caddyfile root@159.203.44.169:/etc/caddy/Caddyfile
```

**Method 2: Create Locally, Upload, Move**
```bash
# 1. Create file locally
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  app:
    image: nginx:latest
EOF

# 2. Upload to server
scp -i ~/.omg-lol-keys/id_ed25519 docker-compose.yml root@159.203.44.169:/opt/homelab/services/app/

# 3. Verify upload
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "cat /opt/homelab/services/app/docker-compose.yml"
```

**Method 3: Use echo/cat for Small Changes**
```bash
# For simple config additions
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo 'new configuration line' >> /etc/config.file
"

# For complete file replacement
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "cat > /path/to/file << 'INNEREOF'
file content here
multiple lines
INNEREOF
"
```

## System Maintenance Commands

### Update System
```bash
# Check for updates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  apt update
  apt list --upgradable
"

# Install updates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  apt upgrade -y
"
```

### Check Logs
```bash
# System logs
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "journalctl -n 50 --no-pager"

# SSH authentication logs
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "tail -n 50 /var/log/auth.log"

# Docker logs
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "journalctl -u docker -n 50 --no-pager"
```

### Firewall Management
```bash
# Check UFW status
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "ufw status numbered"

# Add firewall rule
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  ufw allow 22/tcp comment 'SSH Primary'
  ufw allow 80/tcp comment 'HTTP'
  ufw allow 443/tcp comment 'HTTPS'
"
```

## Debugging & Troubleshooting

### Check Service Response
```bash
# Test HTTP/HTTPS endpoints
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  curl -I http://localhost:80
  curl -I https://brennan.page
"

# Check port listening
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  netstat -tulpn | grep ':80\|:443\|:22'
"
```

### Verify Docker Compose Files
```bash
# Validate docker-compose.yml syntax
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services/servicename
  docker compose config
"
```

### Check Process and Resource Usage
```bash
# Top processes
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "ps aux --sort=-%mem | head -n 10"

# Disk usage by directory
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "du -sh /opt/homelab/* | sort -h"
```

## Long-Running Commands

### Background Processes
```bash
# Run command in background
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  nohup apt upgrade -y > /tmp/upgrade.log 2>&1 &
  echo 'Upgrade started in background. Check /tmp/upgrade.log'
"

# Using screen for persistent sessions
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  screen -dmS backup bash -c 'tar czf /backup.tar.gz /opt/homelab'
"

# Check screen sessions
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "screen -ls"
```

## Common Pitfalls & Solutions

### Problem: Command Hangs Indefinitely
**Solution**: Always use `-T` flag and ensure commands don't wait for input

```bash
# ❌ BAD - Will hang
ssh -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169 "apt install package"

# ✅ GOOD - Won't hang
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "apt install -y package"
```

### Problem: Sudo Asks for Password
**Solution**: Run as root user, or configure passwordless sudo

```bash
# Already using root, so no sudo needed
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "command"
```

### Problem: Need to Edit Large Files
**Solution**: Use the download → edit → upload workflow

### Problem: Docker Commands Fail
**Solution**: Ensure you're in the correct directory and Docker is running

```bash
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  systemctl status docker
  docker ps
  cd /opt/homelab/services/servicename && docker compose ps
"
```

## Quick Reference: Standard Deployment Workflow

```bash
# 1. Create/modify files locally
cd ~/homelab/services/newservice
micro docker-compose.yml
micro .env

# 2. Test locally (if possible)
docker compose config

# 3. Upload to server
rsync -avz --exclude '.git' -e "ssh -i ~/.omg-lol-keys/id_ed25519" \
  ~/homelab/services/newservice/ root@159.203.44.169:/opt/homelab/services/newservice/

# 4. Deploy on server
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services/newservice
  docker compose pull
  docker compose up -d
  docker compose ps
"

# 5. Verify deployment
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker ps | grep newservice
  curl -I http://localhost:PORT
"

# 6. Update Caddy if needed
# Download current Caddyfile
scp -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169:/opt/homelab/caddy/Caddyfile ./Caddyfile

# Edit locally
micro Caddyfile

# Upload
scp -i ~/.omg-lol-keys/id_ed25519 ./Caddyfile root@159.203.44.169:/opt/homelab/caddy/Caddyfile

# Reload Caddy
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "docker exec caddy caddy reload --config /etc/caddy/Caddyfile"
```

## Security Reminders

1. **NEVER** disable UFW port 22 while connected via SSH
2. **ALWAYS** use `-T` and `-o BatchMode=yes` for non-interactive operations
3. **NEVER** commit SSH keys or passwords to git
4. **ALWAYS** test firewall rules in a safe order
5. **ALWAYS** keep local backups before making server changes

## Emergency Access

If SSH becomes unresponsive or you get locked out:

1. Use DigitalOcean Console (via web dashboard)
2. Navigate to Droplet → Access → Launch Console
3. Login with root credentials
4. Fix UFW/SSH configuration
5. Test SSH access before closing console

## Additional Resources

- Server IP: 159.203.44.169
- Domain: brennan.page
- SSH Key: ~/.omg-lol-keys/id_ed25519
- Remote base directory: /opt/homelab/
- Local repository: ~/homelab/

**Last Updated**: 2026-01-16
