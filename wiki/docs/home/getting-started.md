# Getting Started

This guide will help you get familiar with the brennan.page homelab infrastructure and development workflow.

## Prerequisites

### Local Development Environment

- **Git**: For version control
- **Docker**: For local testing (optional but recommended)
- **SSH Client**: For server access
- **Text Editor**: VS Code, micro, or your preferred editor
- **MkDocs**: For documentation (pip install mkdocs mkdocs-material)

### Server Access

- SSH key configured for `root@159.203.44.169`
- Domain `brennan.page` pointing to the server IP (159.203.44.169)
- Basic understanding of Linux command line

## Development Workflow

### 1. Repository Structure

The homelab follows this directory structure according to the spec sheet:

```text
brennan.page/
├── caddy/           # Reverse proxy configuration
├── services/        # Service configurations
├── scripts/         # Management scripts
├── wiki/            # Documentation source
├── docs/            # Project documentation
└── README.md        # Project overview
```

### 2. Local Development

All configuration changes are made locally first:

```bash
# Clone the repository
git clone https://github.com/brennanbrown/brennan.page.git
cd brennan.page

# Make your changes
# Edit docker-compose files, documentation, etc.

# Test configurations locally (when possible)
docker compose config

# Test wiki locally
cd wiki
mkdocs serve
# Access at http://localhost:8000
```

### 3. Version Control

Commit your changes with descriptive messages:

```bash
git add .
git commit -m "Add/update service-name: description of changes"
git push
```

### 4. Deployment

Use the deployment scripts to sync to the server:

```bash
# Deploy specific service
./scripts/deploy-service.sh service_name

# Deploy all services
./scripts/deploy-all.sh

# Deploy wiki
cd wiki
./deploy-wiki.sh
```

## Quick Start

### Accessing Services

All services are accessible through HTTPS:

| Service | URL | Description |
|---------|-----|-------------|
| Main Site | https://brennan.page | Landing page |
| Wiki | https://wiki.brennan.page | Documentation |
| Docker Management | https://docker.brennan.page | Portainer |
| File Management | https://files.brennan.page | FileBrowser |
| System Monitoring | https://monitor.brennan.page | Custom monitor |
| Task Management | https://tasks.brennan.page | Vikunja |
| Notes | https://notes.brennan.page | HedgeDoc |
| Bookmarks | https://bookmarks.brennan.page | Linkding |
| Music | https://music.brennan.page | Navidrome |
| Blog | https://blog.brennan.page | WriteFreely |
| Forum | https://forum.brennan.page | Flarum |
| RSS Reader | https://rss.brennan.page | FreshRSS |

### SSH Access

```bash
# Connect to server
ssh -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169

# Quick status check
docker ps
free -h
df -h
```

## Common Tasks

### Adding a New Service

1. **Create Service Directory:**
   ```bash
   mkdir -p services/newservice
   cd services/newservice
   ```

2. **Create Docker Compose:**
   ```yaml
   version: '3.8'
   services:
     newservice:
       image: image:tag
       container_name: newservice
       restart: unless-stopped
       # ... configuration
   ```

3. **Create Documentation:**
   ```bash
   # Add service documentation
   vi wiki/docs/services/newservice.md
   ```

4. **Update Navigation:**
   ```bash
   # Update wiki/docs/services/index.md
   # Update wiki/mkdocs.yml
   ```

5. **Deploy:**
   ```bash
   ./scripts/deploy-service.sh newservice
   ```

### Updating Documentation

1. **Local Development:**
   ```bash
   cd wiki
   mkdocs serve
   ```

2. **Edit Files:**
   - Update markdown files in `docs/`
   - Test changes locally

3. **Deploy:**
   ```bash
   mkdocs build --clean
   rsync -avz --delete site/ root@159.203.44.169:/opt/homelab/wiki/
   ```

### Monitoring Services

```bash
# Check all services
docker ps

# Check resource usage
docker stats

# Check service logs
docker logs service_name

# Health check script
./scripts/health-check.sh
```

## Service Categories

### Infrastructure Services
- **Caddy**: Reverse proxy with automatic HTTPS
- **PostgreSQL**: Primary database server
- **MariaDB**: Database for Flarum forum

### Management Services
- **Portainer**: Docker management interface
- **FileBrowser**: File management interface
- **Monitor**: System monitoring dashboard

### Productivity Services
- **Vikunja**: Task management system
- **HedgeDoc**: Collaborative markdown notes
- **Linkding**: Bookmark manager
- **Navidrome**: Music streaming server

### Content & Community Services
- **WriteFreely**: Blog platform
- **Flarum**: Community forum
- **FreshRSS**: RSS feed aggregator

## Security

### SSH Access
- Key-based authentication only
- No password authentication
- Regular key rotation recommended

### Web Services
- All services use HTTPS
- Automatic SSL certificate management
- Security headers configured

### Database Security
- Isolated database users
- Encrypted connections
- Regular backups

## Troubleshooting

### Common Issues

**Service Not Accessible:**
```bash
# Check Caddy configuration
docker exec caddy caddy reload

# Check service status
docker ps | grep service_name

# Check service logs
docker logs service_name --tail 50
```

**Wiki Not Updating:**
```bash
# Check wiki build
cd /opt/homelab/wiki
mkdocs build --clean

# Check Caddy wiki configuration
grep -A 5 'wiki.brennan.page' /opt/homelab/caddy/Caddyfile
```

**Database Connection Issues:**
```bash
# Check database status
docker exec postgresql pg_isready
docker exec flarum_mariadb mysqladmin ping

# Test connection
docker exec postgresql psql -U user -d database -c "SELECT 1;"
```

### Getting Help

1. **Check Documentation**: Start with the wiki
2. **Review Logs**: Use `docker logs` for service-specific issues
3. **Check Status**: Visit monitoring dashboard
4. **SSH Reference**: See [SSH Commands](../reference/ssh-commands.md)

## Resources

### Documentation
- **[Services](../services/)**: Detailed service documentation
- **[Operations](../operations/)**: Operational procedures
- **[Troubleshooting](../troubleshooting/)**: Common issues and solutions
- **[Reference](../reference/)**: Command references

### Scripts
- **deploy-service.sh**: Deploy individual services
- **deploy-all.sh**: Deploy all services
- **health-check.sh**: System health monitoring
- **backup.sh**: Backup procedures

### Configuration Files
- **caddy/Caddyfile**: Reverse proxy configuration
- **services/**: Service-specific configurations
- **wiki/mkdocs.yml**: Documentation configuration

## Next Steps

1. **Explore Services**: Visit the various services to understand functionality
2. **Review Documentation**: Read service-specific documentation
3. **Test Deployments**: Try deploying a simple change
4. **Monitor System**: Check the monitoring dashboard regularly
5. **Contribute**: Add improvements or report issues

## Support

For questions or issues:
1. Check the wiki documentation first
2. Review service logs for errors
3. Use the troubleshooting guides
4. Check the [SSH Commands](../reference/ssh-commands.md) reference

---

*Last updated: {{ git_revision_date_localized }}*
