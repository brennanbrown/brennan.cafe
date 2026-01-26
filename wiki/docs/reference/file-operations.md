# File Operations

This reference covers file operations for managing the brennan.page homelab infrastructure.

## Local File Operations

### Basic File Commands

```bash
# List files
ls
ls -la
ls -lh

# List files with details
ls -l --human-readable --size

# List hidden files
ls -a

# Sort files by size
ls -lS

# Sort files by date
ls -lt
```

### File Copy and Move

```bash
# Copy file
cp source.txt destination.txt

# Copy directory
cp -r source_dir/ destination_dir/

# Move file
mv old_name.txt new_name.txt

# Move directory
mv old_dir/ new_dir/

# Rename file
mv file.txt new_file.txt
```

### File Creation and Editing

```bash
# Create empty file
touch new_file.txt

# Create file with content
echo "Hello World" > new_file.txt

# Append to file
echo "More content" >> existing_file.txt

# Edit file with nano
nano file.txt

# Edit file with vim
vim file.txt
```

### File Permissions

```bash
# Change file permissions
chmod 644 file.txt

# Change directory permissions
chmod 755 directory/

# Make file executable
chmod +x script.sh

# Change ownership
chown user:group file.txt

# Recursive ownership change
chown -R user:group directory/
```

### File Search

```bash
# Find file by name
find . -name "filename.txt"

# Find file by pattern
find . -name "*.txt"

# Find file by content
grep -r "search_term" .

# Find file by content in specific directory
grep -r "search_term" /path/to/directory/

# Find and replace
sed -i 's/old_text/new_text/g' file.txt
```

## Remote File Operations

### SSH File Transfer

```bash
# Copy file to remote server
scp file.txt root@159.203.44.169:/path/to/destination/

# Copy directory to remote server
scp -r directory/ root@159.203.44.169:/path/to/destination/

# Copy file from remote server
scp root@159.203.44.169:/path/to/file.txt ./local_file.txt

# Copy directory from remote server
scp -r root@159.203.44.169:/path/to/directory/ ./local_directory/
```

### Rsync Operations

```bash
# Sync directory to remote server
rsync -avz local_directory/ root@159.203.44.169:/remote_directory/

# Sync with exclusion
rsync -avz --exclude '*.log' local_directory/ root@159.203.44.169:/remote_directory/

# Sync with deletion
rsync -avz --delete local_directory/ root@159.203.44.169:/remote_directory/

# Dry run (preview changes)
rsync -avz --dry-run local_directory/ root@159.203.44.169:/remote_directory/
```

### SSH File Operations

```bash
# Create file on remote server
ssh root@159.203.44.169 "echo 'Hello World' > /path/to/file.txt"

# Edit file on remote server
ssh root@159.203.44.169 "nano /path/to/file.txt"

# Copy file on remote server
ssh root@159.203.44.169 "cp /path/to/source.txt /path/to/destination.txt"

# Move file on remote server
ssh root@159.203.44.169 "mv /path/to/old.txt /path/to/new.txt"
```

## Docker File Operations

### Container File Operations

```bash
# Copy file from container
docker cp container_name:/path/to/file.txt ./local_file.txt

# Copy file to container
docker cp ./local_file.txt container_name:/path/to/file.txt

# Copy directory from container
docker cp container_name:/path/to/directory/ ./local_directory/

# Copy directory to container
docker cp ./local_directory/ container_name:/path/to/directory/

# Execute file operations in container
docker exec container_name ls -la /path/to/directory/
docker exec container_name cat /path/to/file.txt
docker exec container_name rm /path/to/file.txt
```

### Volume Operations

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect volume_name

# Create volume
docker volume create volume_name

# Remove volume
docker volume rm volume_name

# Backup volume
docker run --rm -v volume_name:/source -v $(pwd):/backup alpine tar czf /backup/volume-backup.tar.gz -C /source .

# Restore volume
docker run --rm -v volume_name:/target -v $(pwd):/backup alpine tar xzf /backup/volume-backup.tar.gz -C /target
```

## Archive Operations

### Creating Archives

```bash
# Create tar archive
tar czf archive.tar.gz directory/

# Create tar archive with specific files
tar czf archive.tar.gz file1.txt file2.txt file3.txt

# Create zip archive
zip -r archive.zip directory/

# Create tar archive with exclusion
tar czf archive.tar.gz --exclude='*.log' directory/
```

### Extracting Archives

```bash
# Extract tar archive
tar xzf archive.tar.gz

# Extract tar archive to specific directory
tar xzf archive.tar.gz -C /path/to/destination/

# Extract zip archive
unzip archive.zip

# Extract tar archive with specific files
tar xzf archive.tar.gz file1.txt file2.txt
```

## Backup Operations

### Local Backup

```bash
# Backup directory
cp -r directory/ backup/directory_$(date +%Y%m%d)

# Backup with tar
tar czf backup/directory_$(date +%Y%m%d).tar.gz directory/

# Backup with rsync
rsync -avz --delete directory/ backup/directory/

# Backup with exclusion
rsync -avz --exclude='*.log' --exclude='*.tmp' directory/ backup/directory/
```

### Remote Backup

```bash
# Backup to remote server
rsync -avz local_directory/ root@159.203.44.169:/backup/directory/

# Backup with compression
tar czf - local_directory/ | ssh root@159.203.44.169 "cat > /backup/directory_$(date +%Y%m%d).tar.gz"

# Backup from remote server
ssh root@159.203.44.169 "tar czf - /path/to/directory/" > backup/directory_$(date +%Y%m%d).tar.gz
```

## File Monitoring

### File System Monitoring

```bash
# Monitor directory for changes
inotifywait -m /path/to/directory/

# Monitor directory with events
inotifywait -m -e create,delete,modify /path/to/directory/

# Monitor recursively
inotifywatch -r /path/to/directory/

# Monitor with output
inotifywait -m /path/to/directory/ --format '%w %e %f'
```

### Log Monitoring

```bash
# Monitor log file
tail -f /var/log/logfile.log

# Monitor multiple log files
tail -f /var/log/*.log

# Monitor with grep
tail -f /var/log/logfile.log | grep "ERROR"

# Monitor with timestamp
tail -f /var/log/logfile.log | while read line; do echo "$(date): $line"; done
```

## File System Operations

### Disk Usage

```bash
# Check disk usage
df -h

# Check directory size
du -sh /path/to/directory/

# Check directory sizes recursively
du -sh /path/to/directory/*

# Check disk usage by type
df -T

# Check inode usage
df -i
```

### File System Cleanup

```bash
# Find large files
find /path/to/directory -type f -size +100M

# Find old files
find /path/to/directory -type f -mtime +30

# Delete old files
find /path/to/directory -type f -mtime +30 -delete

# Clean up temporary files
find /tmp -type f -mtime +7 -delete
```

## Configuration Files

### Configuration File Operations

```bash
# Backup configuration file
cp config.txt config.txt.backup

# Edit configuration file
nano config.txt

# Validate configuration file
config_file_validator /path/to/config.txt

# Reload configuration
systemctl reload service_name
```

### Environment Files

```bash
# Create environment file
cat > .env << EOF
DATABASE_URL=postgresql://user:pass@localhost:5432/db
API_KEY=your_api_key_here
DEBUG=true
EOF

# Source environment file
source .env

# Export environment variables
export $(cat .env | xargs)
```

## Service-Specific Operations

### Caddy Configuration

```bash
# Edit Caddyfile
nano /opt/homelab/caddy/Caddyfile

# Test Caddy configuration
docker exec caddy caddy validate /etc/caddy/Caddyfile

# Reload Caddy configuration
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Check Caddy logs
docker logs caddy --tail 50
```

### Docker Compose Operations

```bash
# Edit docker-compose.yml
nano docker-compose.yml

# Validate docker-compose.yml
docker compose config

# Restart services
docker compose restart

# View service logs
docker compose logs service_name
```

### Database Operations

```bash
# Backup database
docker exec postgres pg_dump -U username database > backup.sql

# Restore database
docker exec -i postgres psql -U username database < backup.sql

# Check database size
docker exec postgres psql -U username -c "SELECT pg_size_pretty(pg_database_size('database'));"
```

## Security Operations

### File Permissions

```bash
# Secure sensitive files
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Secure configuration files
chmod 600 /opt/homelab/.env
chmod 644 /opt/homelab/caddy/Caddyfile

# Secure scripts
chmod 700 /opt/homelab/scripts/
chmod 755 /opt/homelab/scripts/*.sh
```

### File Encryption

```bash
# Encrypt file with gpg
gpg -c sensitive_file.txt

# Decrypt file
gpg -o sensitive_file.txt -d sensitive_file.txt.gpg

# Encrypt directory
tar czf - directory/ | gpg -c > directory.tar.gz.gpg

# Decrypt directory
gpg -d directory.tar.gz.gpg | tar xzf -
```

## Troubleshooting

### File Permission Issues

```bash
# Check file permissions
ls -la /path/to/file

# Fix file permissions
chmod 644 /path/to/file

# Fix directory permissions
chmod 755 /path/to/directory

# Fix ownership
chown user:group /path/to/file
```

### Disk Space Issues

```bash
# Check disk usage
df -h

# Find large files
find / -type f -size +100M 2>/dev/null | head -10

# Clean up old files
find /tmp -type f -mtime +7 -delete

# Clean up log files
find /var/log -name "*.log" -mtime +30 -delete
```

### File Corruption

```bash
# Check file integrity
md5sum file.txt

# Verify file integrity
md5sum -c checksum.md5

# Recover corrupted file
cp corrupted_file.txt backup_file.txt
```

## Automation

### Script File Operations

```bash
#!/bin/bash
# File operations script

# Create backup directory
mkdir -p backup/$(date +%Y%m%d)

# Backup files
cp -r /opt/homelab/services/ backup/$(date +%Y%m%d)/

# Compress backup
tar czf backup/$(date +%Y%m%d).tar.gz backup/$(date +%Y%m%d)/

# Remove uncompressed backup
rm -rf backup/$(date +%Y%m%d)/

echo "Backup completed: backup/$(date +%Y%m%d).tar.gz"
```

### Cron Jobs

```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /path/to/backup_script.sh

# Weekly cleanup on Sunday
0 3 * * 0 /path/to/cleanup_script.sh

# Monthly log rotation
0 4 1 * * /path/to/log_rotation.sh
```

## References

- [Linux File Commands](https://www.gnu.org/software/coreutils/manual/)
- [SSH File Transfer](https://www.ssh.com/ssh/copy-file)
- [Docker File Operations](https://docs.docker.com/storage/)
- [Rsync Documentation](https://rsync.samba.org/documentation.html)
- [Services Documentation](../services/)
- [Operations Documentation](../operations/)
