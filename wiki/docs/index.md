# brennan.page Wiki

Welcome to the brennan.page homelab documentation. This wiki contains comprehensive information about the self-hosted infrastructure, services, and operational procedures.

## Quick Navigation

- **[Getting Started](home/getting-started.md)** - New to the homelab? Start here
- **[Services](services/)** - Detailed documentation for each service
- **[Deployments](deployments/)** - Deployment phases and procedures
- **[Operations](operations/)** - Daily, weekly, and monthly maintenance tasks
- **[Troubleshooting](troubleshooting/)** - Common issues and solutions

## Overview

brennan.page is a self-hosted homelab running on a DigitalOcean droplet (2GB RAM, 1 CPU, 70GB disk) with Ubuntu 24.04 LTS. The infrastructure showcases backend/cloud development skills while providing personal productivity tools and community-building features.

### Key Features

- **Infrastructure as Code**: All configurations tracked in Git
- **Local-First Development**: All changes authored and tested locally
- **Automated Deployment**: Scripts for reliable service deployment
- **Resource Monitoring**: Enhanced monitoring dashboard with real-time metrics
- **Comprehensive Documentation**: This Git-backed static wiki

### Architecture Highlights

- **Reverse Proxy**: Caddy with automatic HTTPS
- **Container Runtime**: Docker with resource limits
- **Network Segmentation**: Isolated networks for different service categories
- **Backup Strategy**: Automated backups with rotation
- **Security**: UFW firewall, fail2ban, SSH key authentication

## Recent Updates

### System Enhancements (2026-01-17)
- **Content & Community Platform**: WriteFreely blog, Flarum forum, FreshRSS reader fully operational
- **Enhanced Security**: Fail2Ban SSH protection with automatic IP blocking (5 IPs banned)
- **Memory Optimization**: 4GB swap file configured for burst capacity
- **Database Architecture**: Added MariaDB for Flarum alongside PostgreSQL for other services
- **HedgeDoc Database Fix**: Resolved connection issues, now fully functional with note persistence
- **Service Verification**: All 11 containers across 8 services confirmed operational
- **Performance**: Maintained ~1.3GB usage (65%) with sub-200ms response times

### Infrastructure Foundation (2026-01-16)
- **Enhanced Monitoring Dashboard**: Real-time system stats with visual progress bars
- **Modern Landing Page**: Complete UI overhaul with service cards and status indicators
- **Productivity Suite**: Vikunja, HedgeDoc, Linkding, Navidrome fully operational
- **PostgreSQL Integration**: All services connected with proper user isolation
- **Service Health Monitoring**: Automated status checks for all services
- **Performance Optimization**: Maintained within 2GB limit

### Documentation Platform (2026-01-16)
- **Monitoring Service**: Replaced Glances with custom monitoring solution
- **Documentation Wiki**: Deployed comprehensive MkDocs documentation
- **All Services**: Core infrastructure operational
- **Resource Efficiency**: Maintained within 2GB limit

### Initial Setup (2026-01-16)
- **Infrastructure Setup**: Docker, Caddy, networking
- **Core Services**: Portainer, FileBrowser, monitoring
- **Landing Page**: Modern dark theme interface
- **Security**: UFW firewall, SSH configuration
- **Automation**: Backup and health check scripts

## Service Status

| Service | Subdomain | Status | Priority | Description |
|---------|-----------|--------|----------|-------------|
| Caddy | - | 🟢 Critical | Foundation | Reverse proxy with SSL |
| Portainer | docker.brennan.page | 🟢 High | Management | Docker management UI |
| Monitor | monitor.brennan.page | 🟢 High | Monitoring | System monitoring dashboard |
| FileBrowser | files.brennan.page | 🟢 Medium | File Management | File management interface |
| Wiki | wiki.brennan.page | 🟢 High | Documentation | MkDocs documentation |
| PostgreSQL | - | 🟢 Critical | Database | Shared database for multiple services |
| MariaDB | - | 🟢 High | Database | Flarum forum database |
| Vikunja | tasks.brennan.page | 🟢 Medium | Productivity | Task management system |
| HedgeDoc | notes.brennan.page | 🟢 Medium | Productivity | Collaborative markdown notes |
| Linkding | bookmarks.brennan.page | 🟢 Medium | Productivity | Bookmark manager |
| Navidrome | music.brennan.page | 🟢 Low | Productivity | Music streaming server |
| WriteFreely | blog.brennan.page | 🟢 Medium | Community | Blog platform |
| Flarum | forum.brennan.page | 🟢 Medium | Community | Community forum |
| FreshRSS | rss.brennan.page | 🟢 Low | Community | RSS reader |

## Resource Usage

- **Total RAM**: 2GB
- **Allocated**: ~1.3GB (65%)
- **Available Buffer**: ~700MB
- **Swap**: 4GB configured (20MB used)
- **Disk Usage**: 13GB/67GB (19%)
- **Containers**: 11 running containers
- **Services**: 8 fully operational services

## Getting Help

1. **Check the Wiki**: Most questions are answered in these documents
2. **Review Logs**: Use `docker logs <service>` for service-specific issues
3. **Check Status**: Visit `monitor.brennan.page` for system overview
4. **SSH Reference**: See [SSH Commands](reference/ssh-commands.md) for server management

---

*Last updated: {{ git_revision_date_localized }}*
